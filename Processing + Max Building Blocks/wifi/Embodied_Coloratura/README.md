# Embodied Coloratura

By Diana Alina Serbanescu

A coloratura-inspired synthetic voice, with the performance interface in Processing and all audio generated in Max. This version builds on the A0-vowel/A1-pitch instrument and keeps its calibration, gate, mute, fades and gesture randomization.

## Run this version

1. Stop the previous Processing sketch and close the previous Max patch; these versions use the same UDP ports.
2. Keep `Embodied_Coloratura.maxpat` and `coloratura_engine.js` together. Open the Max patch.
3. Open `Embodied_Coloratura_Controller/Embodied_Coloratura_Controller.pde` in Processing. It needs **oscP5** and Processing’s bundled Serial library.
4. Run the sketch. The existing serial settings remain `/dev/cu.usbmodem1101`, 115200 baud. Change the port if necessary. The existing `fullScreen(2)` setting targets your second display; use `fullScreen(1)` on a single display.
5. Calibrate A0: press **1**, capture relaxed with **R**, then stretched with **S**. Hold each position steady for the 1.5-second capture. Repeat with **2** for A1.
6. Press **D** to enable the engine. Stretch A0 to sound and shape the vowel. Stretch A1 to raise the pitch.

All performance controls are in Processing. Choose Max’s output device in Audio Status if needed. MAX LINK: RECEIVING confirms control feedback, not audible output. D starts Max audio; if you manually stop DSP, toggle D off and on to restart it.

## What changed

- **A1 pitch:** C4 (261.626 Hz) to F6 (1396.913 Hz), continuously mapped on a perceptual scale. Relaxed A1 selects C4 without muting the voice.
- **A0:** still gates the sound and moves through U/O/A/E/I. Each new A0 activation chooses subtle voice variations that remain fixed through the gesture.
- **Higher resonances:** retains your edited 1.10–1.22 tract-frequency multiplier, with the previous small per-formant random variation.
- **High-register tuning:** F1 is raised to at least 1.02 times excitation pitch. Between C5 and C6, F2 progressively gains support near the second harmonic. F2 and F3 retain minimum spacing. Filter bandwidths broaden modestly at high pitch. Frequency, bandwidth and pitch targets ramp over 40 ms in Max.
- **Display:** accepts the complete C4–F6 feedback range, shows the correct pitch scale and extends the resonance graph to 5000 Hz.

The resonance tuning is a synthesis approximation inspired by research on soprano vocal-tract adjustments, not a physiological model. At the top of the range, the resonances increasingly follow pitch and the differences between vowel positions become smaller. The sound remains an electronically synthesized voice, not a sampled or realistic opera singer. Coloratura agility comes from your gestures; no automatic ornaments or vibrato were added.

Reference: Garnier, Henrich, Smith and Wolfe, [The tuning of vocal resonances and the upper limit to the high soprano range](https://www.acoustics.asn.au/conference_proceedings/ICA2010/cdrom-ISMA2010/papers/p11.pdf).

## Controls

- **1 / 2:** select A0 / A1 for calibration.
- **R / S:** capture relaxed / stretched position.
- **C:** clear selected calibration. **X:** reset selected observed range.
- **D:** enable/silence this engine.
- **M / Q:** retain their separate mute flags for the single voice; both must be unmuted to sound.

A0 controls silence. A1 has no gate or mute of its own. Before A1 calibration, pitch starts at C4; during recalibration or after calibration is cleared, it holds its last valid pitch. Processing retains the 350 ms serial freshness check, and Max fades the voice out if OSC stops for 500 ms.

## Changing the range later

In `coloratura_engine.js`, edit the clearly named `minPitch` and `maxPitch` values. The mapping uses both automatically, avoiding mismatched numbers in the exponential formula. Match those two constants in Processing and update the visible endpoint labels. Use the included files together.

OSC: `/formants/coloratura/state` goes to localhost port 12000 with A0 stretch, A1 pitch stretch, A0 faded gain, engine-armed flag and A0 gesture ID. `/formants/coloratura/feedback` returns F1, F2, F3 and excitation pitch to port 12001. Feedback shows control targets, not measured sound; drawn peak widths remain schematic.

