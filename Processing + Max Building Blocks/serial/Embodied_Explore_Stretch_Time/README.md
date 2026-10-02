# Embodied Stretch Time

## Start here

1. Close the previous instrument's Max patch and stop its Processing sketch (they use the same OSC ports).
2. Open **Embodied_Stretch_Time.maxpat** in Max. Keep **stretch_time_engine.js** beside it.
3. Open **Embodied_Stretch_Time_Controller/Embodied_Stretch_Time_Controller.pde** in Processing and run it. It uses the existing Serial and oscP5 libraries, serial port and fullscreen settings.
4. In Processing press **L** and choose a mono or stereo WAV/AIFF recording. Demo_Texture.wav and Demo_Voice.wav are included. Wait for its waveform to appear and MAX LINK to show RECEIVING.
5. Select A0 with **1**: press **R** while relaxed and hold through calibration; press **S** while stretched and hold. Repeat for A1 using **2**.
6. Press **D** to enable the engine, then stretch A0. Audio plays through Max's selected audio output. If silent, check Max Audio Status/output device, the serial connection, calibration, and mute state.

## Play

- **A0 — speed:** above the activation threshold, continuous exponential mapping from 1/8× to 2×. 1/8× takes eight times as long; 1× is original speed; 2× takes half the time. Original speed is about three quarters through the active sensor range.
- **Relax A0 — fade and pause:** the recording resumes from its paused position on the next gesture. There is a short smoothing transition before it fully stops. Active amplitude stays approximately constant.
- **A1 — pitch:** one octave down to one octave up (−12 to +12 semitones). Midway is the original pitch. A1 defaults to original pitch before calibration and holds its last value during calibration.
- **T — restart:** briefly fades, returns to the beginning, then resumes if A0 is active.
- **M / Q — mute**, **D — enable/silence**, **L — load recording**.
- **1 / 2 — select sensor**, **R / S — relaxed/stretched calibration**, **C — clear selected calibration**, **X — reset observed range**.

The recording loops. The Processing waveform shows the actual playback position reported by Max; speed and pitch displays show the smoothed parameter values (speed remains displayed while paused). Stereo files keep their channels; mono files play in both channels.

## How it works

Processing retains serial input, calibration, dead zone, mute controls and the visual interface. It sends OSC on localhost port 12000; Max returns status and waveform data on port 12001. Max uses native groove~ with timestretch enabled, so speed and pitch can change independently. The JavaScript handles control smoothing, file loading, waveform preparation and status; groove~ performs the audio processing. A 500 ms controller timeout fades and pauses playback.

Very slow speeds and large pitch shifts can introduce audible stretching textures, depending on the recording. This is independent speed/pitch transformation, not formant-preserving vocal synthesis.

Reference: https://docs.cycling74.com/reference/groove~/

## Verification and previous version

The Processing sketch compiled successfully. Automated checks covered mapping endpoints, calibration hold, gate release, OSC status/waveform handling, loading, mono/stereo selection, restart, pause/resume, packet validation, timeout silence and Max patch connections. The Processing interface was rendered and visually checked. Live audio and physical sensor operation have not been verified for this version.

The supplied folder retains the earlier source in Previous_Explore_Dissolve. The distribution ZIP contains only the new instrument and the two demo recordings.
