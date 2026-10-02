# Embodied Formants — Processing controller + Max/MSP engine

By Diana A. Serbanescu { created, edited and checked }

Processing handles the interface, ESP32 serial input, calibration, gating and mute controls. 
Max generates all audio. 

This is a basic synthesizer: no microphone input or recorded voice is required.

## Start

1. Keep `Embodied_Formants.maxpat` and `formant_engine.js` together. Open the Max patch. Set your output device in Max’s Audio Status if needed.
2. Open `Embodied_Formants_Controller/Embodied_Formants_Controller.pde` in Processing. It requires **oscP5** (Sketch → Import Library → Manage Libraries) and Processing’s bundled Serial library. Processing Sound is not required.
3. Confirm **MAX LINK: RECEIVING** in Processing. Press **D** to enable the Max engine. D starts Max’s audio processing; pressing D again silences these two voices without stopping other Max patches.
4. Select **1** (A0). Hold the sensor relaxed and press **R**; hold steady for 1.5 seconds. Hold it stretched and press **S**, again for 1.5 seconds. Repeat with **2** (A1).
5. Stretch to sound a voice and morph its vowel. Hold to sustain; relax to silence. All performance controls remain in Processing. Max can stay in the background.

## Controls

- **1 / 2:** select A0 / A1 for calibration.
- **R / S:** capture relaxed / stretched position for the selected sensor.
- **M:** mute both voices. **Q / W:** mute A0 / A1 independently.
- **C:** clear the selected sensor’s calibration. **X:** reset its observed range.
- **D:** enable or silence the Max engine. It starts disabled.

## Sound and display

Each new physical activation chooses small independent variations in formant frequencies (about ±9%) and bandwidths (±20%). The variation stays fixed throughout the gesture while stretch continues to morph the vowel. A0 and A1 choose independently. Muting/unmuting or toggling D does not choose a new voice. Gesture counters travel with every OSC packet so a lost activation packet does not lose the change.

Each sensor independently morphs through U → O → A → E → I. Max interpolates the three formants continuously between these illustrative targets (Hz):

| Stretch | Vowel | F1 | F2 | F3 |
|---|---|---:|---:|---:|
| 0% | U | 300 | 870 | 2240 |
| 25% | O | 500 | 1000 | 2400 |
| 50% | A | 730 | 1090 | 2440 |
| 75% | E | 530 | 1840 | 2480 |
| 100% | I | 270 | 2290 | 3010 |

These are synthesis presets, not a universal model of speech. The endpoints are editable in `formant_engine.js`.

Each voice uses an antialiased sawtooth excitation feeding three parallel `reson~` bandpass filters. The excitation stays at 120 Hz for A0 and 135 Hz for A1; stretch changes the resonances, not this pitch. Base filter bandwidths are 80, 100 and 140 Hz, with relative filter gains 0.8, 0.5 and 0.3. Frequency and bandwidth targets ramp over 40 ms in Max. A0 is panned left and A1 right, preserving the original ±0.6 distinction with equal-power panning.

The original 5% activation / 3% release hysteresis, ADC-count floors, 80 ms activation confirmation, calibration rules and 35/90 ms exponential gain fades remain. Once active, each voice’s requested gain settles at 0.15. Vowel timbre can naturally change perceived loudness. Max additionally interpolates received gain over 20 ms. Silence/disarm and connection-loss fades use 90 ms ramps.

The navy/white panels, red graphs, serial diagnostics and keyboard controls retain the original layout. The graphs now show randomized target formant frequencies returned by Max, not measured audio. Drawn peak widths are schematic; they do not visualize randomized bandwidth. **MAX LINK: RECEIVING** confirms control feedback, not that an audio device is producing sound. **VOICE: ACTIVE** means the controller is requesting sound.

## Connection

Both applications run on the same computer by default. Processing sends `/formants/state` to `127.0.0.1:12000` at the drawing rate (target 60 Hz):

`normalizedA0 normalizedA1 gainA0 gainA1 engineArmed gestureIdA0 gestureIdA1`

The first four arguments are floats; the fifth is 0 or 1, and the last two are integer gesture counters. Use this updated controller and Max engine together. Max sends `/formants/feedback` to port 12001 with six numbers: A0 F1/F2/F3 followed by A1 F1/F2/F3. Max decodes OSC with its built-in `udpreceive`; no CNMAT externals are needed. A 500 ms Max watchdog fades both voices if controller packets stop. Processing also retains the 350 ms serial freshness check. Do not run multiple copies using these ports.

If there is no sound: check D is enabled, R and S are calibrated for that sensor, mute is off, MAX LINK is receiving, and the Max output device is correct. If you manually stop Max DSP while D remains enabled, press D off and on to restart it.

Implementation references: [Max reson~](https://docs.cycling74.com/reference/reson~/), [Max udpreceive](https://docs.cycling74.com/reference/udpreceive/), [Max saw~](https://docs.cycling74.com/reference/saw~/).
