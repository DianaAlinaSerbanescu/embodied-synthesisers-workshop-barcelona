// Coloratura-inspired control mapping. Native MSP objects synthesize one voice.
// Change these endpoints together with the Processing controller constants.
var minPitch = 261.625565; // C4
var maxPitch = 1396.912926; // F6
autowatch = 1;
inlets = 1;
outlets = 4; // voice parameters, unused, feedback, DSP start
var vowels = [[300,870,2240],[500,1000,2400],[730,1090,2440],[530,1840,2480],[270,2290,3010]];
var current = vowels[0].slice();
var pitch = minPitch;
var frequencyScale = [1.16,1.16,1.16];
var bandwidths = [80,100,140];
var effectiveBandwidths = bandwidths.slice();
var armed = false;
var lastGesture = 0;
var watchdog = new Task(connectionLost, this);
function clamp(v,lo,hi) { return Math.max(lo,Math.min(hi,v)); }
function chooseVoice() {
    var tractScale = 1.10 + Math.random() * 0.12;
    var base = [80,100,140];
    for (var i=0;i<3;i++) {
        frequencyScale[i] = tractScale * (0.97 + Math.random() * 0.06);
        bandwidths[i] = base[i] * (0.8 + Math.random() * 0.4);
    }
}
function formants(stretch) {
    var position=clamp(stretch,0,1)*4;
    var index=Math.min(3,Math.floor(position));
    var blend=position-index;
    var result=[];
    for(var i=0;i<3;i++) result.push(vowels[index][i]+blend*(vowels[index+1][i]-vowels[index][i]));
    return result;
}
function pitchForStretch(stretch) {
    return minPitch * Math.pow(maxPitch/minPitch,clamp(stretch,0,1));
}
function tuneHighRegister(base, f0) {
    // A synthesis approximation inspired by soprano resonance tuning.
    // Keep the first resonance just above f0 when it overtakes a vowel's F1.
    var f1 = Math.max(base[0], f0 * 1.02);
    // Introduce second-harmonic support smoothly between C5 and C6.
    var blend = clamp((f0 - 523.251131) / (1046.502261 - 523.251131), 0, 1);
    blend = blend * blend * (3 - 2 * blend);
    var f2Target = Math.max(base[1], 2.02 * f0);
    var f2 = Math.max(base[1] + blend * (f2Target - base[1]), f1 + 200);
    var f3 = Math.max(base[2], f2 + 300);
    return [f1,f2,f3];
}
function list() {
    // A0 stretch, A1 pitch stretch, A0 faded gain, engine armed, A0 gesture ID.
    var a=arrayfromargs(arguments);
    if(a.length!==5) return;
    for(var i=0;i<5;i++) if(typeof a[i]!=="number" || !isFinite(a[i])) return;
    if((a[3]!==0 && a[3]!==1) || a[4]<0 || a[4]!==Math.floor(a[4])) return;
    var nextArmed=a[3]===1;
    if(nextArmed && !armed) outlet(3,"start");
    armed=nextArmed;
    if(a[4]!==lastGesture) {
        if(a[4]>0) chooseVoice();
        lastGesture=a[4];
    }
    current=formants(a[0]);
    for(var j=0;j<3;j++) current[j]*=frequencyScale[j];
    pitch=pitchForStretch(a[1]);
    current=tuneHighRegister(current,pitch);
    // Broaden high-register resonances modestly; preserve each gesture's profile.
    effectiveBandwidths=[Math.max(bandwidths[0],0.12*pitch),
                         Math.max(bandwidths[1],0.16*pitch),
                         Math.max(bandwidths[2],0.18*pitch)];
    var gain=armed ? clamp(a[2],0,0.15) : 0;
    outlet(0,current.concat([gain,armed?20:90],effectiveBandwidths,[pitch]));
    outlet(2,current.concat([pitch]));
    watchdog.cancel();
    watchdog.schedule(500);
}
function connectionLost() {
    armed=false;
    outlet(0,current.concat([0,90],effectiveBandwidths,[pitch]));
}
function loadbang() { connectionLost(); }
function notifydeleted() { watchdog.cancel(); }
