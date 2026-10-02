autowatch = 1;
inlets = 1;
outlets = 4; // P1, P2, REAPER action, feedback (requested playback, not REAPER acknowledgement)
var playing = -1;
var watchdog = new Task(timeout, this);
function setPlaying(value) {
    if (playing === value) return;
    playing = value;
    // Explicit REAPER actions: Transport: Play / Transport: Pause.
    outlet(2, value ? 1007 : 1008);
}
function list() {
    var a = arrayfromargs(arguments);
    if (a.length !== 5) return;
    for (var i = 0; i < 5; i++) if (typeof a[i] !== 'number' || !isFinite(a[i])) return;
    if (a[0] < 0 || a[0] > 1 || a[1] < 0 || a[1] > 1) return;
    for (var j = 2; j < 5; j++) if (a[j] !== 0 && a[j] !== 1) return;
    watchdog.cancel();
    watchdog.schedule(500);
    // Send valid parameters first so playback begins with the current settings.
    if (a[2]) outlet(0, a[0]);
    if (a[3]) outlet(1, a[1]);
    setPlaying(a[4]);
    outlet(3, playing);
}
function timeout() { setPlaying(0); outlet(3, 0); }
function loadbang() { playing = -1; setPlaying(0); }
function closebang() { watchdog.cancel(); setPlaying(0); }
