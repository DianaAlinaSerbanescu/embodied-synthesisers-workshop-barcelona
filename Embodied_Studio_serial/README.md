# Embodied Studio — workshop

By Diana Alina Serbanescu

One Processing interface, one main Max patch, ten instrument modes, and a separate saved-calibration screen.

## First use

1. Extract the complete folder. Close the older standalone controllers and instrument patches.
2. Open **Embodied_Studio.maxpat** in Max, then run **Embodied_Studio_Controller/Embodied_Studio_Controller.pde** in Processing. Keep all accompanying Max/JS files together.
3. On first launch the **Calibration** screen opens. For A0, hold the textile relaxed and click **Capture relaxed**, then hold it stretched and click **Capture stretched**. Repeat for A1. Hold each position through the capture progress bar.
4. Valid captures save automatically. When both sensors show READY, click **Done — return to performance**.
5. Choose any instrument tab and play. **D is no longer required.** Local Max audio starts automatically once the controller acknowledges the selected mode and both sensors are calibrated. The existing relaxed-silence behavior still applies to local sound modes.

Processing requires Serial and oscP5; Processing Sound is not required. The serial port remains `/dev/cu.usbmodem1101` at 115200 baud. If necessary change the port in setup(); available ports are printed to the console. The ESP32 must send the same serial format as the selected building blocks. Max and Processing must still be opened; this package does not launch applications automatically.

## Subsequent performances

The controller restores valid calibration and the last selected instrument, and skips the calibration screen. Calibration is shared by all instruments. Max enables the mode automatically after its short switching interval. After a temporary Max disconnection, controls resume automatically when communication returns, unless performance is paused. Missing sensor data still silences local gated voices or holds REAPER controls.

**Demo_Texture.wav is preloaded into both Explore / dissolve and Stretch time at startup**, even while another mode is selected. Both recordings must finish loading before they can sound; the sample display reports loading or errors. Press L to select another WAV/AIFF. Each sample mode remembers its own selected recording across restarts. If that file is later missing, the bundled demo is used instead.

## Calibration and saved settings

Click **Calibration / K** or press **K** to enter calibration. Local sound stops and external REAPER controls hold their last values while calibrating. The screen provides independent capture buttons for both sensors, current readings, progress and saved status.

Within Calibration: **1 / 2** selects a sensor, **R / S** captures relaxed/stretched endpoints, **C** clears that sensor's calibration, and **Enter** returns to performance once both sensors are ready. Clearing is also saved, so that sensor requires calibration next time. Invalid or incomplete capture attempts do not overwrite an existing valid endpoint.

Settings are saved atomically to **studio_settings.json beside the Processing sketch**. They contain sensor endpoints/readiness, the last instrument and sample file paths. Keep this file when upgrading or moving the Studio folder. No fabricated calibration is distributed in the ZIP. Corrupt/invalid saved calibration returns the controller to Calibration. Write failures are displayed explicitly; if saving fails, the current calibration works only for that session.

Returning with Done resumes performance automatically. Old R/S/C keys from the performance screen now open Calibration; they no longer recalibrate an instrument directly. Per-mode mute/hold switches are retained during the running session but are not saved across restarts.

## Performance controls

- **Click a tab / [ / ]**: select instrument. Local output fades out during switching; the next mode enables automatically after the 180 ms transition.
- **Space / Pause button**: pause/resume local instruments and REAPER parameter updates. The pause persists while switching modes. D remains an optional alias for this action.
- **M**: mute local voices or hold both REAPER parameters.
- **Q / W**: mute individual voices in dual-voice modes. In single-voice modes Q mutes the voice and W holds A1. In REAPER modes Q/W hold the individual parameter.
- **1 / 2**: select sensor. **X**: reset its observed range.
- **K**: open Calibration.
- **L**: replace the recording in either sample mode; the choice is saved.
- **T**: restart Stretch time from the beginning with a short fade.
- **N**: choose a new five-note range for the selected sensor in Notes, without changing calibration.

REAPER audio remains external. Space, M, calibration and leaving a REAPER mode hold controls; they do not mute the REAPER track. Stop/mute that track in REAPER when needed. The volume mode's −60 dB minimum is very quiet, not true silence.

## Instrument mappings

| Mode | A0 | A1 |
|---|---|---|
| Sine | 100–700 Hz | 180–1100 Hz |
| Notes | Five pentatonic notes, voice 0 | Five pentatonic notes, voice 1 |
| Noise / cutoff | Low-pass 40–8000 Hz | Low-pass 40–8000 Hz |
| Dual formants | Vowel U–O–A–E–I, voice 0 | Vowel U–O–A–E–I, voice 1 |
| Formants + pitch | Vowel and activation | Approximately 80–88.89 Hz |
| Coloratura | Vowel and activation | C4–F6, approximately 262–1397 Hz |
| Explore / dissolve | Recording position and activation | Fragments 250–20 ms |
| Stretch time | Speed 1/8×–2×; relax to pause | Pitch −12 to +12 semitones |
| RAVE | Latent bias 0, 0–1 | Latent bias 1, 0–1 |
| REAPER volume | Track 1, −60 to 0 dB | Track 2, −60 to 0 dB |

The selected Formants + Pitch engine actually uses `80 * pow(400/360, stretch)`, although its original label said 80–400 Hz. The selected mapping is preserved and the interface describes the real range. Coloratura is separate. Notes retain the source pool, note hysteresis and harmonic blend; use N for new ranges now that calibration is independent of instrument modes.

## Connections and audio

Processing handles serial input, calibration, sensor normalization, the interface, saved settings and file selection. Max handles local synthesis, sampling and OSC routing. REAPER hosts the existing RAVE/Neutone model and track audio.

Processing → Max: localhost **12100**. Max → Processing: **12101**. Existing REAPER mappings remain on localhost **8000**:

- `/rave/latent_bias_0` and `/rave/latent_bias_1`: RAVE mode.
- `/track/1/volume/db` and `/track/2/volume/db`: REAPER volume mode, using the supplied patch's 50 ms ramps.
- `/neutone/p1` and `/neutone/input_gain`: existing manual controls retained inside studio_rave.maxpat.

Open your existing REAPER project and start its source/transport as required. This package does not create REAPER OSC mappings or identify tracks by plugin name. Track numbers 1 and 2 are preserved from your patch. The interface displays targets; MAX READY is controller acknowledgement, not plugin or track readback. RAVE and volume are separate exclusive control modes.

The main Max patch loads studio_*.maxpat as internal engines; do not open separate old instrument patches. Sine, notes and noise now use native MSP audio objects, retaining their mappings and stereo distinction. The noise filter uses lores~ and is not claimed to be sample-identical to Processing Sound. Formant and granular engines reuse the selected building blocks. Stretch Time uses the earlier completed version, absent from the selected folder.

Only the serial receiver feeds the common sensor queue. A future Wi-Fi input adapter can feed the same values/timestamps; Wi-Fi is not implemented here.

## Verification and provenance

The selected originals were left unchanged. SOURCE_MANIFEST.json lists their hashes. The ZIP contains no calibration/settings from testing. Interface_Preview.png and Calibration_Preview.png are offscreen renders with simulated readings.

Compilation and automated controller/router/engine checks passed, including settings round trips and background preload. See VALIDATION.md. Live ESP32 → Max audio and REAPER response still require checking in your setup; this version is not claimed to have undergone a live performance test.
