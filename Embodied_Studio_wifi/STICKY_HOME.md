# RAVE HOME behaviour — 26 September 2026

## Existing flow and scope

ESP32 Wi-Fi UDP 4210 → unchanged WifiUdpReceiver → Processing smoothing and shared calibration → normalized stretch → existing `/suite/state` on localhost 12100 → Max studio_router.js → rave_sensor_bridge.js → REAPER OSC 8000. Feedback returns on 12101. Audio is processed in REAPER, not Processing or this Max bridge.

Only four existing runtime files change: the Processing sketch, studio_router.js, rave_sensor_bridge.js and studio_rave.maxpat. Calibration/settings, ESP32 parsing, sequence handling, ports, audio files and the other instruments are preserved. The 17-field controller OSC protocol is unchanged. Only Max's internal RAVE list gains a fifth field (gate request).

## HOME and gestures

```
latent_bias  = [2.0286922, 0.0, 0.0, 0.0, 0.4376934, 0.0, -0.4992319, 0.0]
latent_scale = [1.0, 1.0, 1.0, 1.5279988, 1.0, 1.0, 1.0, 1.0]
```

A0 adds up to 0.75 to bias 0 (maximum 2.7786922); A1 adds up to 0.75 to bias 1. This retains the existing sensor assignments. Other coordinates stay at HOME. Positive bias 4 and scale 3 follow the requested values exactly, even though the inspected live preset differed. OSC/plugin float32 precision can change the final decimal place.

The existing trigger opens above 5% stretch (at least 8 ADC counts), after 80 ms of confirmed samples; it closes at/below 3% (at least 4 counts). Both calibrations must be valid. The excursion starts beyond the activation dead zone. Either textile opens the audio gate; both resting close it. Q/W/M still hold excursions while sounding, but physical release overrides a hold and returns HOME.

Latent smoothing is exponential and elapsed-time based: 120 ms movement time constant, 300 ms return time constant. A release completes roughly 95% of its return in 900 ms. The final less-than-one-millionth remainder settles to exact HOME. Output gain has a separate linear-amplitude fade: 80 ms in and 120 ms out. Fade reversal continues from the current level.

## Verified target and normalization

The live REAPER project was RAVE Demo [modified], track 1, first effect AU: RAVE (acids), followed by ReaEQ. The generic parameter list exposed scale 0 as parameter 15 and bias 0 as parameter 16 (one-based); subsequent pairs increment by two. This installed version includes mute_with_playback and adaptive_latency before the latent parameters, unlike the older public source's parameter order.

Automatic latent messages now use REAPER's existing default `/track/1/fx/1/fxparam/N/value` routes. Bias converts with `(value + 3) / 6`; scale converts with `value / 5`. The ranges match both the inspected live UI and the [RAVE source definitions](https://raw.githubusercontent.com/acids-ircam/rave_vst/main/source/PluginProcessor.h). Explicit parameter addresses avoid ambiguous learned assignments on the old two `/rave/latent_bias_*` addresses, and allow all 16 HOME coordinates to be set. Existing manual Max sliders remain wired as before; avoid moving them during HOME control.

The gate uses the existing track 1 volume route, fading up to **−16.3 dB**, the inspected working level. At the end it sends normalized track volume **0 for true silence**. It does not use FX bypass, change input gain, mute the master, or send transport commands. This controls the whole RAVE track, including downstream EQ. Track 2/3 audio or pre-fader sends are not gated by this change. The track fader is owned by the gate while RAVE mode is active; change PLAY_LEVEL_DB in the bridge to set another playing level.

Pause, calibration, leaving RAVE, stale textile input (350 ms), or lost controller/router messages (500 ms) close the gate and return HOME. Closing/crashing Max itself cannot send a fade; manually lower track 1 if Max stops while sounding. REAPER volume mode retains its prior behaviour and can take over the track fader after the mode transition. Switching to a local mode leaves RAVE silent.

## Step-by-step live check

1. Stop the Processing sketch and close Embodied_Studio.maxpat before replacing files, or run the complete updated copy instead. Run only one Studio patch/controller pair. Preserve studio_settings.json.
2. Keep RAVE as track 1 effect 1. Open the Max patch, then run the Processing sketch and select RAVE. Leave both textiles relaxed. Track 1 should become silent, while transport remains in its existing state.
3. In RAVE's generic UI, check all HOME coordinates above. In particular: bias 0 ≈ 2.0286922, bias 4 ≈ +0.4376934, bias 6 ≈ −0.4992319, scale 3 ≈ 1.5279988. If parameters do not match, pause and check the REAPER target/mapping before stretching further. MAX READY acknowledges Max, not REAPER parameter readback.
4. With the source playing, stretch **A0 alone**: output should fade in, bias 0 should increase, bias 1 should stay at zero. Release: volume reaches silence in about 120 ms and bias 0 continues gliding HOME.
5. Repeat with **A1 alone**: sound must also open, bias 1 should increase, bias 0 stays HOME. Stretch both; release just one: sound remains while the other is stretched. Release both: silence.
6. Hover near rest: it should not chatter. Between the ON and OFF thresholds, the previous activation state persists. Check calibration if the textile does not return below OFF.
7. Stretch, then press Space or enter calibration: fade out. Resume relaxed: silence. Briefly disconnect the ESP32: silence after timeout plus fade. Reconnect relaxed: silence. Test another local mode and REAPER volume mode to confirm their original controls.
8. Tune only if needed: EXCURSION, RETURN_MS, MOVE_MS, FADE_IN_MS, FADE_OUT_MS and PLAY_LEVEL_DB are at the top of rave_sensor_bridge.js. Trigger thresholds remain in Processing and are shared across modes.

## Validation status

Processing preprocessing and Java compilation passed. Simulated controller tests passed for both resting, A0-only/A1-only activation, confirmation delay, hysteresis, holds, physical release, pause, calibration, stale input, lost Max feedback, reversed calibration, and local/volume-mode regressions. Max bridge/router tests passed for exact HOME, all 16 routes, fade timing, smooth return, hold/release, watchdog timeout, malformed input and absence of transport commands. These tests do not transmit OSC to REAPER.

Live ESP32 → Max → REAPER parameter response and audible fade quality are **not yet verified**. The parameter map was inspected in the live UI; its response to the new explicit OSC routes still needs step 3.
