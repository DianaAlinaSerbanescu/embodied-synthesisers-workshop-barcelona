# Embodied Formants — A0 vowel / A1 pitch

By Diana Alina Serbanescu { created, edited and checked }

Processing is the performance interface; Max generates all audio.

- **A0:** triggers and silences the voice, morphs U → O → A → E → I, and chooses subtle new formant-frequency/bandwidth variations on each activation. The variation stays fixed during the gesture.
- **A1:** slides the same voice’s excitation pitch continuously from **80 to 400 Hz**. Relaxing A1 selects 80 Hz; it does not silence the voice or choose a new timbre.

## Start

1. Close the previous Max patch and stop the previous Processing controller; this version uses the same UDP ports.
2. Unzip the complete package. Keep `Embodied_Formants_Pitch.maxpat` and `formant_pitch_engine.js` together, then open the Max patch.
3. Open `Embodied_Formants_Pitch_Controller/Embodied_Formants_Pitch_Controller.pde` in Processing. The sketch requires **oscP5** and the bundled Serial library. Processing Sound is not used.
4. Run Processing. The original serial setup remains `/dev/cu.usbmodem1101`, 115200 baud, with `fullScreen(2)`. Change the serial path if needed; use `fullScreen(1)` on a single display.
5. Select **1**, capture relaxed with **R** and stretched with **S**, holding each position steady through the 1.5-second capture. Repeat for sensor **2** (A1).
6. Press **D** in Processing to enable sound. Stretch A0 to sound and shape the vowel; move A1 to change pitch. All performance controls are in Processing.

**MAX LINK: RECEIVING** confirms Max’s control feedback. It does not confirm output-device audio. If necessary, choose the output device in Max’s Audio Status. If Max DSP is manually stopped, press D off and on to restart it.

## Controls

| Key | Action |
|---|---|
| 1 / 2 | Select A0 / A1 for calibration |
| R / S | Capture relaxed / stretched position |
| C | Clear selected calibration |
| X | Reset selected observed range |
| D | Enable or silence this engine |
| M / Q | Toggle their respective mute flags for the single voice; both must be unmuted to sound |

W no longer mutes A1 because A1 has no separate voice. A0’s original dead zone, confirmation time, hysteresis and smooth amplitude fades remain. A1 has no activation threshold for pitch: its entire calibrated range is used.

Before A1 is calibrated, pitch starts at 80 Hz. While A1 is being calibrated, has invalid calibration or has its calibration cleared, it holds its last valid pitch. A0 can still sound. Loss of fresh serial data silences the voice through the existing A0 gate. Missing controller packets trigger Max’s 500 ms watchdog and a 90 ms release.

## Mapping and synthesis

Max maps A1 as `pitch = 80 * pow(5, normalizedA1)`. Endpoints are 80 and 400 Hz; halfway is approximately 178.9 Hz. Pitch targets ramp over 40 ms for a continuous glide.

A0 retains the U/O/A/E/I formant presets, with frequencies varying by approximately ±9% and bandwidths by ±20% for each new A0 gesture. Moving A1, muting/unmuting or toggling D does not reroll the timbre. The excitation is an antialiased sawtooth, shaped by three parallel resonant bandpass filters. The resulting single voice is centered across both output channels.

Processing displays Max’s target F1/F2/F3 frequencies on the left and excitation pitch on the right. These are control targets, not measured audio; filter and pitch ramps in Max briefly trail them. Graph peak widths remain schematic.

## OSC

Use this version’s controller and Max files together. Their addresses distinguish this instrument from the previous two-voice version.

- Processing → localhost port 12000: `/formants/pitch/state`, with `A0_stretch A1_pitch_stretch A0_faded_gain engine_armed A0_gesture_id`.
- Max → localhost port 12001: `/formants/pitch/feedback`, with `F1 F2 F3 excitation_pitch`.

The Max patch needs no third-party externals. `formant_pitch_engine.js` supplies mapping and gesture randomization; native MSP objects generate audio.


