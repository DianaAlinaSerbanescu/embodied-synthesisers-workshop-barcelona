# Embodied Stretch Synth — Explore and Dissolve


By Diana Alina Serbanescu, with voice sample by Diana Alina Serbanescu

Processing is the interface and ESP32 controller. Max loads your recording and generates overlapping sound fragments. This is a separate instrument; the earlier formant and coloratura versions remain unchanged.

## First run

1. Stop the earlier Processing controller and close its Max patch. This instrument uses the same local OSC ports.
2. Unzip the complete folder. Keep **Embodied_Explore_Dissolve.maxpat**, **granular_engine.js** and **grain_voice.maxpat** together.
3. Open **Embodied_Explore_Dissolve.maxpat** in Max.
4. Open **Embodied_Explore_Dissolve_Controller/Embodied_Explore_Dissolve_Controller.pde** in Processing and run it. It requires **oscP5** and Processing’s bundled Serial library; it does not require Processing Sound.
5. In Processing, press **L** and choose **Demo_Texture.wav** from this package, or a mono/stereo WAV or AIFF of your own. Wait for the recording’s duration and waveform to appear.
6. Select A0 with **1**. Hold it relaxed, press **R**, and hold steady for 1.5 seconds. Stretch it, press **S**, and hold for another 1.5 seconds. Repeat with **2** for A1.
7. Press **D** in Processing to enable the engine. Stretch A0 to play; move A1 to dissolve the recording into shorter fragments.

The original serial settings are `/dev/cu.usbmodem1101` at 115200 baud. Change the port in `setup()` if your ESP32 uses another name. The existing `fullScreen(2)` setting targets the second display; use `fullScreen(1)` on a single display. Choose Max’s output device in Audio Status if necessary.

## How to play

**A0 — explore:** stretch to scan from the beginning toward the end of the recording. Hold still to sustain fragments from that position. Release to silence. The resting dead zone is excluded from the scan mapping, so the beginning remains accessible when A0 activates.

**A1 — dissolve:** relaxed gives approximately **250 ms** fragments; fully stretched gives **20 ms**. The mapping is exponential, with about 71 ms halfway. Longer fragments retain more local detail; short repeated fragments become textural or buzzy. A1 does not gate or mute the sound.

Each fragment plays forward at the recording’s original speed. Moving A0 changes where future fragments begin; holding A0 does not resume ordinary full-file playback. There is no intentional pitch transposition, although rapid repetition of fragments can introduce a perceived tone or alter timbre. This is the “explore and dissolve” instrument; independent time-stretch/pitch controls are not included yet.

Try a short spoken phrase, a breath, a sustained vowel, fabric friction, or a field recording. Start with a few seconds of contrasting material. The included eight-second stereo **Demo_Texture.wav** is an original synthetic test sound with moving harmonics, chirps and noise texture; it is not a voice recording.

## Interface and keys

The original navy-and-white two-panel layout, sensor diagnostics, selection highlight, calibration and mute logic are retained. The left graph shows a sampled waveform overview and the current fragment window. The right graph shows fragment duration and a diagram of overlapping grain envelopes.

| Key | Function |
|---|---|
| **L** | Choose a WAV/AIFF recording |
| **1 / 2** | Select A0 / A1 for calibration |
| **R / S** | Capture relaxed / stretched position |
| **C** | Clear the selected calibration |
| **X** | Reset the selected observed range |
| **D** | Enable or silence this engine |
| **M / Q** | Toggle the original master/A0 mute flags; both must be unmuted |

W has no separate voice to mute. A1 calibration holds its last valid fragment size; before calibration, the default is 250 ms. A0 calibration silences the instrument. The L file picker is temporarily disabled while Max is loading/preparing a recording. Canceling the picker preserves the current recording. Loading another recording fades the output and waits for old fragments to finish before replacing the buffer.

The waveform is a sampled peak overview, not a sample-accurate editor or live audio measurement. The highlighted window reflects the smoothed control target; existing grains finish their captured windows as new grains follow movement. Mono recordings are duplicated to both output channels. Stereo recordings retain their left and right channels. Multichannel files and recordings shorter than 21 ms are rejected.

## Troubleshooting

- **MAX LINK: WAITING:** confirm the matching Max patch is open and no other copy is using UDP ports 12000/12001.
- **No waveform:** press L to choose a file, wait for loading, or retry if an error is shown. Max and Processing must run on the same computer for local file paths to work.
- **No sound:** confirm D is enabled, the file is ready, A0 has both calibration endpoints, A0 is above its activation threshold, and neither mute flag is active. Check Max’s output device.
- **DSP manually stopped in Max:** toggle D off and on in Processing to restart it.
- **Very quiet material:** this version keeps a conservative fixed active gain and does not normalize your recording. Adjust listening volume or use a suitably leveled source file.

MAX LINK: RECEIVING confirms a round trip of control messages. It does not prove that the audio output device is sounding. Loading errors also appear in Max’s console.

## Implementation

Max stores the file in a uniquely named `buffer~`. A 64-voice `poly~` plays fragments using `play~`, with Hann-shaped envelopes. Each grain captures its start, end and duration, preserving a 1x read rate. Grains launch about four times per grain duration; the 5 ms control scheduler quantizes their spacing slightly. The 64 slots allow long grains to finish during a sudden change to short grains. Inactive grain voices are muted to reduce CPU use.

Processing retains the activation confirmation, ADC-count floors, relaxed-zone hysteresis and smooth amplitude fades. The active gain is approximately constant. Position and duration controls are smoothed in Max. Missing serial data releases the A0 gate; loss of OSC for 500 ms triggers a 90 ms Max fade. File loading also fades the output. Final output clips are guards against excursions, not a loudness normalizer.

Processing → localhost UDP 12000:

- `/granular/state`: scan position, A1 normalized size, faded gain, engine flag, selected file ID, waveform acknowledgement ID.
- `/granular/load`: file ID and absolute file path as a single OSC string.

Max → UDP 12001:

- `/granular/status`: file ID, state, duration in ms, fragment start in ms, effective fragment duration, channel count.
- `/granular/wave`: file ID and 256 sampled peaks.

File requests and waveform delivery are retried until acknowledged. Audio is gated when the controller’s selected file ID does not match Max’s loaded file. No third-party Max externals are required.

Technical references: [Cycling ’74 granular synthesis tutorial](https://docs.cycling74.com/learn/articles/11_polychapter02/), [play~](https://docs.cycling74.com/reference/play~/), [buffer~](https://docs.cycling74.com/reference/buffer~/).

