// Independent sample speed/pitch using native groove~ timestretch.
autowatch = 1;
inlets = 1;
outlets = 7; // groove messages, gain, OSC, DSP, buffer, mono flag, speed ramp
var sample = new Buffer(jsarguments[1]);
var fileId=0, fileState=0, duration=0, channels=0, frames=0;
var pendingPath="", waveform=[], waveBin=0;
var armed=false, gain=0, controlFileId=0, waveAck=0;
var targetSpeed=1, speed=1, targetPitch=0, pitch=0, playhead=0;
var lastPacket=0, lastTick=0, nextWave=0, expired=true;
var lastRestart=0, restarting=false;
var sentSpeed=-1, sentGain=-1, sentPitch=-1;
var beginTask=new Task(beginRead,this);
var timeoutTask=new Task(loadTimedOut,this);
var waveTask=new Task(buildWaveform,this);
var restartTask=new Task(restartNow,this);
function clamp(v,lo,hi) { return Math.max(lo,Math.min(hi,v)); }
function finite(v) { return typeof v === "number" && isFinite(v); }
function speedForStretch(v) { return 0.125*Math.pow(16,clamp(v,0,1)); }
function pitchForStretch(v) { return -12+24*clamp(v,0,1); }
function canPlay() { return !expired && armed && fileState===2 && controlFileId===fileId && gain>0 && !restarting; }
function setSpeed(value,ms) {
    if(value!==sentSpeed) { outlet(6,[value,ms]);sentSpeed=value; }
}
function setGain(value,ms) {
    if(value!==sentGain) { outlet(1,[value,ms]);sentGain=value; }
}
function controls() {
    var audible=canPlay(), ratio=Math.pow(2,pitch/12);
    if(Math.abs(ratio-sentPitch)>0.000001) { outlet(0,["pitchshift",ratio]);sentPitch=ratio; }
    setSpeed(audible?speed:0,40);
    setGain(audible?gain:0,restarting?20:(audible?20:90));
}
function state() {
    // A0 active-range stretch, A1 pitch stretch, gain, armed, file ID, wave ACK, restart counter
    var a=arrayfromargs(arguments);
    if(a.length!==7) return;
    for(var i=0;i<7;i++) if(!finite(a[i])) return;
    if((a[3]!==0 && a[3]!==1)) return;
    for(var j=4;j<7;j++) if(a[j]<0 || a[j]!==Math.floor(a[j])) return;
    var enable=a[3]===1;
    if(enable && !armed) outlet(3,"start");
    armed=enable;
    targetSpeed=speedForStretch(a[0]); targetPitch=pitchForStretch(a[1]);
    gain=armed?clamp(a[2],0,0.15):0;
    controlFileId=a[4];waveAck=a[5];
    var now=Date.now();
    if(expired) lastTick=now;
    expired=false;lastPacket=now;
    if(a[6]!==lastRestart) {
        lastRestart=a[6];
        if(fileState===2 && controlFileId===fileId) {
            restarting=true;setGain(0,20);restartTask.cancel();restartTask.schedule(30);
        }
    }
    controls();status();
    if(fileState===2 && waveAck!==fileId && now>=nextWave) sendWave();
}
function position(v) { if(finite(v)) playhead=clamp(v,0,1); }
function status() {
    outlet(2,["/stretch/status",fileId,fileState,duration,playhead*duration,speed,pitch,channels]);
}
function restartNow() {
    if(fileState===2 && controlFileId===fileId) { outlet(0,0);playhead=0; }
    restarting=false;controls();
}
function load(id,path) {
    if(!finite(id) || id<=0 || id!==Math.floor(id) || typeof path!=="string" || path.length===0) return;
    if(id===fileId) { status(); return; } // repeated UDP request is idempotent
    if(fileState===1) return; // serialize reads and waveform preparation
    beginTask.cancel(); timeoutTask.cancel(); waveTask.cancel();
    restartTask.cancel(); restarting=false;
    fileId=id; pendingPath=path; fileState=1; duration=0; channels=0; waveform=[];
    setGain(0,90); setSpeed(0,90); status();
    // Fade and pause before replacing the recording.
    beginTask.schedule(150);
}
function beginRead() {
    timeoutTask.schedule(15000);
    // offset 0, complete file, native channel count. Never split a path on spaces.
    outlet(4,["read",pendingPath,0,-1,0]);
}
function loaded() {
    if(fileState!==1) return;
    timeoutTask.cancel();
    duration=sample.length(); frames=sample.framecount(); channels=sample.channelcount();
    if(!finite(duration) || duration<21 || frames<2 || channels<1 || channels>2) {
        fileState=-2; duration=0; status(); return;
    }
    outlet(5,channels===1 ? 1 : 0);
    waveform=[]; waveBin=0;
    waveTask.schedule(1);
}
function buildWaveform() {
    if(fileState!==1) return;
    try {
        // An approximate peak preview: up to 2048 central samples per bin/channel.
        // Bound the work for long recordings and spread it over low-priority tasks.
        for(var batch=0;batch<8 && waveBin<256;batch++,waveBin++) {
            var lo=Math.floor(waveBin*frames/256), hi=Math.floor((waveBin+1)*frames/256);
            var count=Math.min(2048,Math.max(1,hi-lo));
            var from=Math.min(frames-count,lo+Math.floor(Math.max(0,hi-lo-count)/2));
            var peak=0;
            for(var ch=1;ch<=channels;ch++) {
                var data=sample.peek(ch,from,count);
                if(typeof data==="number") data=[data];
                for(var k=0;k<data.length;k++) if(isFinite(data[k])) peak=Math.max(peak,Math.abs(data[k]));
            }
            waveform.push(clamp(peak,0,1));
        }
        if(waveBin<256) { waveTask.schedule(1); return; }
        fileState=2; playhead=0; outlet(0,["setloop",0,duration]); outlet(0,0);
        status(); sendWave();
    } catch(e) { fileState=-1; setGain(0,90); setSpeed(0,90); status(); }
}
function sendWave() {
    if(waveform.length!==256) return;
    outlet(2,["/stretch/wave",fileId].concat(waveform));
    nextWave=Date.now()+1000;
}
function loadTimedOut() { fileState=-1; duration=0; setGain(0,90); setSpeed(0,90); status(); }
function tick() {
    var now=Date.now();
    if(!expired && now-lastPacket>500) { expired=true;armed=false;gain=0; }
    var dt=lastTick?clamp(now-lastTick,0,100):20;lastTick=now;
    var smooth=1-Math.exp(-dt/60);
    speed+=(targetSpeed-speed)*smooth;pitch+=(targetPitch-pitch)*smooth;
    controls();
}
function loadbang() { setGain(0,0);setSpeed(0,0);outlet(5,0); }
function notifydeleted() { beginTask.cancel();timeoutTask.cancel();waveTask.cancel();restartTask.cancel(); }
