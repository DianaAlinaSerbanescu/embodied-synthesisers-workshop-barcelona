// Max control and grain scheduling; native MSP objects render all audio.
autowatch = 1;
inlets = 1;
outlets = 6; // poly commands, master envelope, OSC feedback, DSP, buffer, mono flag
var sample = new Buffer(jsarguments[1]);
var fileId = 0, fileState = 0, duration = 0, channels = 0, frames = 0;
var pendingPath = "", waveform = [], waveBin = 0;
var armed = false, gain = 0, controlFileId = 0, waveAck = 0;
var targetPosition = 0, position = 0, targetGrain = 250, grain = 250;
var lastPacket = 0, lastTick = 0, nextGrain = 0, nextWave = 0, voice = 0;
var expired = true;
var beginTask = new Task(beginRead, this);
var timeoutTask = new Task(loadTimedOut, this);
var waveTask = new Task(buildWaveform, this);
function clamp(v,lo,hi) { return Math.max(lo,Math.min(hi,v)); }
function finite(v) { return typeof v === "number" && isFinite(v); }
function grainForStretch(v) { return 250 * Math.pow(20/250,clamp(v,0,1)); }
function sampleWindow() {
    var d = Math.min(grain,Math.max(0,duration-1));
    var start = clamp(position,0,1) * Math.max(0,duration-1-d);
    return [start,start+d,d];
}
function state() {
    // scan, dissolve, faded gain, armed, selected file ID, waveform acknowledgement
    var a=arrayfromargs(arguments);
    if(a.length!==6) return;
    for(var i=0;i<6;i++) if(!finite(a[i])) return;
    if((a[3]!==0 && a[3]!==1) || a[4]<0 || a[4]!==Math.floor(a[4]) || a[5]<0 || a[5]!==Math.floor(a[5])) return;
    var enable=a[3]===1;
    if(enable && !armed) outlet(3,"start");
    armed=enable;
    targetPosition=clamp(a[0],0,1);
    targetGrain=grainForStretch(a[1]);
    gain=armed ? clamp(a[2],0,0.15) : 0;
    controlFileId=a[4]; waveAck=a[5];
    var now=Date.now();
    if(expired) { nextGrain=now; lastTick=now; }
    expired=false; lastPacket=now;
    outlet(1,[fileState===2 && controlFileId===fileId ? gain : 0,armed?20:90]);
    status();
    if(fileState===2 && waveAck!==fileId && now>=nextWave) sendWave();
}
function status() {
    var w=sampleWindow();
    outlet(2,["/granular/status",fileId,fileState,duration,w[0],w[2],channels]);
}
function load(id,path) {
    if(!finite(id) || id<=0 || id!==Math.floor(id) || typeof path!=="string" || path.length===0) return;
    if(id===fileId) { status(); return; } // repeated UDP request is idempotent
    if(fileState===1) return; // serialize reads and waveform preparation
    beginTask.cancel(); timeoutTask.cancel(); waveTask.cancel();
    fileId=id; pendingPath=path; fileState=1; duration=0; channels=0; waveform=[];
    outlet(1,[0,90]); status();
    // Wait for the output fade and all old grains (maximum 250 ms) to finish.
    beginTask.schedule(300);
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
        fileState=2; nextGrain=Date.now();
        status(); sendWave();
    } catch(e) { fileState=-1; outlet(1,[0,90]); status(); }
}
function sendWave() {
    if(waveform.length!==256) return;
    outlet(2,["/granular/wave",fileId].concat(waveform));
    nextWave=Date.now()+1000;
}
function loadTimedOut() { fileState=-1; duration=0; outlet(1,[0,90]); status(); }
function tick() {
    var now=Date.now();
    if(!expired && now-lastPacket>500) {
        expired=true; armed=false; gain=0; outlet(1,[0,90]);
    }
    var dt=lastTick ? clamp(now-lastTick,0,100) : 5; lastTick=now;
    var smooth=1-Math.exp(-dt/40);
    position+=(targetPosition-position)*smooth;
    grain+=(targetGrain-grain)*smooth;
    if(expired || !armed || gain<=0 || fileState!==2 || controlFileId!==fileId) return;
    if(now<nextGrain) return;
    var w=sampleWindow();
    if(w[2]<20) return;
    voice=voice%64+1;
    outlet(0,["target",voice]);
    outlet(0,w);
    // Four overlapping Hann-windowed fragments; each reads forward at 1x speed.
    nextGrain=now+w[2]/4;
}
function loadbang() { outlet(1,[0,0]); outlet(5,0); }
function notifydeleted() { beginTask.cancel(); timeoutTask.cancel(); waveTask.cancel(); }
