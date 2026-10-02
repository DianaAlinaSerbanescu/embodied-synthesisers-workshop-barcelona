# Embodied Neutone — two stretch sensors

By Diana Alina Serbanescu

Sensor 1 (A0) controls `/neutone/p1`; sensor 2 (A1) controls `/neutone/p2`. Each calibrated range maps to a floating-point value from 0 to 1. Either stretched sensor starts playback. Both relaxed pauses at the current position; the next stretch resumes there.

## Open the new version

1. Stop the old Processing sketch and close the old Max patch, because they use the same ports.
2. Open `Embodied_Neutone.maxpat`. Keep `neutone_bridge.js` next to it. Max relays controls; it does not generate audio and does not need DSP enabled.
3. Open `Embodied_Neutone_Controller/Embodied_Neutone_Controller.pde` in Processing and run it. Keep the Java tab in the same folder. The oscP5 library is required. This version opens in a window.
4. Use your existing ESP32 Wi-Fi sender. Its packet format and UDP port 4210 are unchanged.
5. Select sensor **1**, hold relaxed and press **R**; wait 1.5 seconds. Hold stretched and press **S**; wait 1.5 seconds. Repeat using **2** for the other sensor. Calibration starts unset each time the sketch runs.

## Connect REAPER

Your saved REAPER configuration currently has an OSC input on port **8000**, using the default pattern configuration. The new Max patch sends to `127.0.0.1:8000`.

In REAPER Preferences → Control/OSC/web, check that this OSC surface is enabled and receives on port 8000. Use the Default pattern configuration (which includes `ACTION i/action`). If the live configuration differs from the saved configuration, align the port and mapping before testing.

Put your audio item on the Neutone track and load Neutone FX and your model. Enable Repeat over the desired loop if you want sustained gestures to keep playing after the item ends. Playback commands affect the **whole REAPER project**, so mute other tracks if only Neutone should be audible.

### Teach P1 and P2 their OSC addresses

The assignments belong to the plugin instance: a new project or newly inserted Neutone instance needs its own assignments.

1. In Processing press **1**, then **L**. The interface should say **LEARN: sensor 1**. Only `/neutone/p1` is sent, and playback stays paused.
2. In Neutone’s REAPER FX window use **Param → FX parameter list → Learn → p1** (or right-click its exposed track control and choose Learn).
3. Confirm the detected address is `/neutone/p1`, and accept. Use absolute control; disable soft takeover for immediate sensor response. Avoid options restricting control to a selected track or focused FX unless desired.
4. Back in Processing press **2** while still in Learn mode. Open Learn for **p2** in REAPER, confirm `/neutone/p2`, and accept.
5. Press **L** to leave Learn mode. Press **D** to arm the controller.

If another address appears, cancel and confirm Learn mode is active for the intended sensor before reopening the dialog. Both sensors need calibration before their parameter messages are sent.

## Perform

- Stretch sensor 1: play and change P1.
- Stretch sensor 2: play and change P2.
- Stretch both: play and change both independently.
- Release just one: playback continues while the other remains stretched.
- Release both: pause; stretch either again to resume.

A held stretch sustains playback; continuous motion is not required. P1/P2 continue tracking while armed, including returning to zero when relaxed. Press D to disarm before adjusting parameters manually. The parameter names describe the model’s exposed controls; their sonic meanings depend on the loaded model.

## Controls

| Key | Action |
|---|---|
| 1 / 2 | Select sensor for calibration or Learn |
| R / S | Capture relaxed / stretched endpoint |
| D | Arm/disarm; leave Learn mode |
| L | Toggle isolated OSC Learn mode; disarm playback |
| M / Q | Two independent pause switches; both must be off for playback |
| C | Clear selected sensor calibration |
| X | Reset selected observed range |

The original 5% start / 3% release thresholds, ADC noise floors and 80 ms activation confirmation apply independently to both sensors. An uncalibrated or calibrating sensor cannot trigger playback or send its parameter; the other valid sensor remains usable.

## Connection behaviour

Processing → Max uses port 12000 and `/neutone/state` with P1, P2, valid/send-P1, valid/send-P2, requested-playback. Max → REAPER uses port 8000 and `/neutone/p1`, `/neutone/p2`, plus explicit `/action` integers 1007 (Play) and 1008 (Pause). Transport commands are sent on state changes, not every frame.

Loss of sensor data pauses after approximately 350 ms. If Processing quits or stops sending, Max’s watchdog requests pause after 500 ms. Closing Max normally also requests pause. A Max crash or lost UDP transport packet cannot guarantee delivery; use REAPER’s transport if needed. Avoid manually changing transport while sensor control is armed; disarm/rearm to resynchronize after restarting REAPER.

MAX LINK confirms Max is receiving Processing messages; it is not an acknowledgement from REAPER. REQUEST shows the desired playback state, not measured transport state. If the link is working but REAPER does not respond, check its OSC input, port and parameter assignments.
