# Embodied RAVE — Processing → Max → REAPER

## Open these files

1. Stop other Processing sketches using the ESP32 serial port.
2. Open Embodied_RAVE_REAPER.maxpat in Max, keeping rave_sensor_bridge.js beside it. Close the older copy of the latent-space patch to avoid competing controls.
3. In REAPER, open your existing project with the RAVE/Neutone model and its existing OSC mappings. Start the audio source or transport as your project requires.
4. Open Embodied_RAVE_Controller/Embodied_RAVE_Controller.pde in Processing and run it. Serial and oscP5 libraries are required, as in the preceding controller. The existing serial port /dev/cu.usbmodem1101, baud rate 115200 and fullScreen(2) settings are retained; adjust these in setup if your hardware/display differs.
5. Select A0 with 1. Press R and hold relaxed throughout calibration, then S and hold stretched. Select A1 with 2 and repeat.
6. Press D to enable parameter control. Stretch each sensor and verify the corresponding parameter moves in REAPER.

## Mapping and interaction

A0 → /rave/latent_bias_0, continuously from 0 to 1.
A1 → /rave/latent_bias_1, continuously from 0 to 1.

These are the normalized ranges and addresses already present in your supplied Max patch. What those values mean inside the model depends on your existing REAPER/plugin mapping. This package does not install a REAPER OSC mapping or change the model.

Both controls include the original Max 50 ms ramps. The calibration handles either sensor direction. Relaxed means 0 and stretched means 1; there is no sound activation threshold because these gestures control latent parameters rather than volume.

D enables/holds both controls. M holds/releases both controls; Q holds/releases A0 only. These controls do not mute audio. REAPER continues at the last parameter settings. Calibration holds only the affected parameter, and missing/stale serial input holds both. If Processing stops, Max receives no new targets and any already-running 50 ms ramp finishes.

1/2 select the sensor; R/S calibrate; C clears the selected calibration; X resets its observed range. The blue/white interface, sensor diagnostics and calibration workflow are retained. The lower panels show latent targets and the last sensor target acknowledged by Max, not measured plugin values.

## Max and REAPER connections

Processing sends /ravebridge/state with value0, value1, enable0, enable1 to localhost:12002. Max validates the packet and feeds the original latent-bias ramp chains directly, preserving floating-point resolution. Max replies with /ravebridge/status to Processing on port 12003. MAX LINK: RECEIVING indicates Max acknowledgements, not confirmation from REAPER.

The original patch's four outbound controls remain unchanged:
- /rave/latent_bias_0 → localhost:8000
- /rave/latent_bias_1 → localhost:8000
- /neutone/p1 → localhost:8000 (manual)
- /neutone/input_gain → localhost:8000 (manual)

The original manual sliders remain usable. Hold sensor control before adjusting latent sliders manually. The sliders are not motorized by incoming sensor targets; use the Processing display to see those values. Resume sensor movement to take control again.

If Max responds but REAPER does not move, check the existing REAPER OSC receiver uses port 8000 and maps these exact addresses to the intended FX parameters. The controller does not generate audio, load a model, start REAPER playback, or set input gain. Preserve your existing working audio routing and gain configuration.

## Verification

Processing preprocessing/Java compilation passed. Automated checks passed for independent ranges, uncalibrated and calibration holds, M/Q holds, stale-data hold, feedback decoding, Max packet validation and bridge connections. The interface was rendered and visually checked. Live ESP32 → Max → REAPER/model operation has not been verified.

Your original patch was not edited; this is a separate adapted copy.
