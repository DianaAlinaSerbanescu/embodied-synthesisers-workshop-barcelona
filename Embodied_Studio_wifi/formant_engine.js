// Max js: control mapping only. Audio runs in native MSP objects.
autowatch = 1;
inlets = 1;
outlets = 4; // voice 0, voice 1, feedback, DSP start
var vowels = [[300,870,2240],[500,1000,2400],[730,1090,2440],[530,1840,2480],[270,2290,3010]];
var current = [vowels[0].slice(), vowels[0].slice()];
var armed = false;
var lastGesture = [0, 0];
var frequencyScale = [[1,1,1], [1,1,1]];
var bandwidths = [[80,100,140], [80,100,140]];
function chooseVoice(voice) {
    // A shared vocal-tract shift plus small independent formant differences.
    var tractScale = 0.94 + Math.random() * 0.12;
    var baseBandwidths = [80,100,140];
    for (var j=0; j<3; j++) {
        frequencyScale[voice][j] = tractScale * (0.97 + Math.random() * 0.06);
        bandwidths[voice][j] = baseBandwidths[j] * (0.8 + Math.random() * 0.4);
    }
}
var watchdog = new Task(connectionLost, this);
function clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)); }
function formants(stretch) {
    var position = clamp(stretch, 0, 1) * 4;
    var index = Math.min(3, Math.floor(position));
    var blend = position - index;
    var result = [];
    for (var i = 0; i < 3; i++) result.push(vowels[index][i] + blend * (vowels[index+1][i] - vowels[index][i]));
    return result;
}
function list() {
    var a = arrayfromargs(arguments);
    if (a.length !== 7) return;
    for (var i=0; i<7; i++) if (typeof a[i] !== "number" || !isFinite(a[i])) return;
    if (a[5] < 0 || a[6] < 0 || a[5] !== Math.floor(a[5]) || a[6] !== Math.floor(a[6])) return;
    var nextArmed = a[4] === 1;
    // Start Max audio when D arms the engine. Disarming gates our voices only.
    if (nextArmed && !armed) outlet(3, "start");
    armed = nextArmed;
    for (var voice=0; voice<2; voice++) {
        var gesture = a[voice+5];
        if (gesture !== lastGesture[voice]) {
            if (gesture > 0) chooseVoice(voice);
            lastGesture[voice] = gesture;
        }
        current[voice] = formants(a[voice]);
        for (var j=0; j<3; j++) current[voice][j] *= frequencyScale[voice][j];
        var gain = armed ? clamp(a[voice+2],0,0.15) : 0;
        outlet(voice, current[voice].concat([gain, armed ? 20 : 90], bandwidths[voice]));
    }
    outlet(2, current[0].concat(current[1]));
    watchdog.cancel();
    watchdog.schedule(500);
}
function connectionLost() {
    armed = false;
    for (var i=0; i<2; i++) outlet(i, current[i].concat([0,90], bandwidths[i]));
}
function loadbang() { connectionLost(); }
function notifydeleted() { watchdog.cancel(); }
