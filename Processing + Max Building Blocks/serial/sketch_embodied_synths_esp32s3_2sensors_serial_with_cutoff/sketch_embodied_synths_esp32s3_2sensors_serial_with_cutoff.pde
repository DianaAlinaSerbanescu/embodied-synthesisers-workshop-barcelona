/*
 * Diana A. Serbanescu
 * Embodied Stretch Synth
 *
 * Dual stretch-sensor Processing sketch
 *
 * Receives:
 * raw0,smoothed0,raw1,smoothed1
 *
 * Each sensor controls an independent white-noise low-pass filter (40–8000 Hz).
 * Calibration and cutoff control are independent per sensor.
 * Gain stays constant while active; existing trigger hysteresis and fades are retained.
 *
 * Controls:
 * 1 = select sensor A0
 * 2 = select sensor A1
 *
 * R = calibrate relaxed position of selected sensor
 * S = calibrate stretched position of selected sensor
 *
 * M = mute/unmute both voices
 * Q = mute/unmute sensor A0
 * W = mute/unmute sensor A1
 *
 * C = reset calibration of selected sensor
 * X = reset observed range of selected sensor
 */

import processing.serial.*;
import processing.sound.*;
import java.util.concurrent.ArrayBlockingQueue;

// Serial callback publishes packets; only draw/keyPressed change instrument state.
class SensorPacket {
  float[] values;
  int received;
  SensorPacket(float[] values, int received) {
    this.values = values;
    this.received = received;
  }
}
ArrayBlockingQueue<SensorPacket> inputPackets = new ArrayBlockingQueue<SensorPacket>(256);

Serial myPort;

WhiteNoise noise0, noise1;
LowPass lowPass0, lowPass1;

// --------------------------------------------------
// Sensor selection
// --------------------------------------------------

int selectedSensor = 0;

// --------------------------------------------------
// Serial state
// --------------------------------------------------

boolean serialConnected = false;
boolean sensorDataReceived = false;

// --------------------------------------------------
// Sensor values
// --------------------------------------------------

float rawValue0 = 0;
float rawValue1 = 0;

float smoothedValue0 = 0;
float smoothedValue1 = 0;

// --------------------------------------------------
// Calibration values
// --------------------------------------------------

// Each sensor owns its endpoints, capture timer, samples and capture mode.
class SensorCalibration {
  float relaxed = 1200;
  float stretched = 1600;
  boolean relaxedReady = false;
  boolean stretchedReady = false;
  int mode = 0; // 0 idle, 1 relaxed, 2 stretched
  int started = 0;
  float sum = 0;
  int samples = 0;

  void cancelCapture() {
    mode = 0;
    sum = 0;
    samples = 0;
  }

  void reset() {
    cancelCapture();
    relaxed = 1200;
    stretched = 1600;
    relaxedReady = false;
    stretchedReady = false;
  }
}
SensorCalibration[] calibration = {new SensorCalibration(), new SensorCalibration()};
int calibrationDuration = 1500;
int calibrationSettleMs = 500;
int minimumCalibrationSamples = 20;

float calibrationMargin = 3.0;

// --------------------------------------------------
// Observed ranges
// --------------------------------------------------

float observedMin0 = Float.MAX_VALUE;
float observedMax0 = -Float.MAX_VALUE;

float observedMin1 = Float.MAX_VALUE;
float observedMax1 = -Float.MAX_VALUE;

// --------------------------------------------------
// Normalized sensor values
// --------------------------------------------------

float normalized0 = 0;
float normalized1 = 0;

// --------------------------------------------------
// Frequencies
// --------------------------------------------------

float minCutoff = 40.0;
float maxCutoff = 8000.0;
float cutoff0 = minCutoff;
float cutoff1 = minCutoff;

// --------------------------------------------------
// Sound
// --------------------------------------------------

// A small relaxed zone prevents resting noise from repeatedly triggering sound.
// Start above 5% stretch; stop below 3%. Both endpoints must be calibrated.
float soundOnStretch = 0.05;
float soundOffStretch = 0.03;
// ADC-count floors keep short calibration spans from amplifying resting noise.
float minimumOnCounts = 8.0;
float minimumOffCounts = 4.0;
int activationConfirmMs = 80;
int[] activationSince = {-1, -1};
boolean[] triggerActive = {false, false};
int sensorTimeoutMs = 350;
volatile int lastSensorSampleTime = 0;
boolean stretchSound0 = false;
boolean stretchSound1 = false;
float outputAmplitude0 = 0;
float outputAmplitude1 = 0;
int lastSoundTime = 0;

float amplitude0 = 0.15;
float amplitude1 = 0.15;

boolean mutedAll = false;
boolean muted0 = false;
boolean muted1 = false;

// Slight stereo separation
float pan0 = -0.6;
float pan1 = 0.6;

// --------------------------------------------------
// Status
// --------------------------------------------------

String sensorStatus0 = "WAITING";
String sensorStatus1 = "WAITING";

float amountBelow0 = 0;
float amountAbove0 = 0;

float amountBelow1 = 0;
float amountAbove1 = 0;

// --------------------------------------------------
// Setup
// --------------------------------------------------

void setup() {
  fullScreen(2);
  pixelDensity(1);

  println("Available serial ports:");
  printArray(Serial.list());

  try {
    myPort = new Serial(
      this,
      "/dev/cu.usbmodem1101",
      115200
    );

    // Opening the serial port can reset the XIAO.
    delay(1500);

    myPort.clear();
    myPort.bufferUntil('\n');

    serialConnected = true;

    println("Connected to XIAO ESP32S3");
  }
  catch (Exception e) {
    serialConnected = false;

    println("SERIAL ERROR:");
    println(e);
  }

  noise0 = new WhiteNoise(this);
  noise1 = new WhiteNoise(this);
  lowPass0 = new LowPass(this);
  lowPass1 = new LowPass(this);

  // Start silent; each filter processes only its own panned noise source.
  noise0.play(0, pan0);
  noise1.play(0, pan1);
  lowPass0.process(noise0, cutoff0);
  lowPass1.process(noise1, cutoff1);
}

// --------------------------------------------------
// Main loop
// --------------------------------------------------

synchronized void draw() {
  background(255);

  drainSensorPackets();
  updateCalibration();

  updateSensorStatuses();
  updateCutoffs();
  updateSound();

  // Scale the original 1100 x 720 layout uniformly to fit the display.
  // Center it so text and waveforms keep their proportions on any screen.
  float interfaceScale = min(width / 1100.0, height / 720.0);
  pushMatrix();
  translate(
    (width - 1100 * interfaceScale) / 2.0,
    (height - 720 * interfaceScale) / 2.0
  );
  scale(interfaceScale);

  drawHeader();
  drawSensorPanel0();
  drawSensorPanel1();

  drawWaveform0();
  drawWaveform1();

  drawControls();
  fill(0, 32, 96);
  textSize(14);
  text("Stretch opens the noise filter: 40–8000 Hz. Hold to sustain; relax for silence.", 20, 665);
  drawCalibrationMessage();
  popMatrix();
}

// --------------------------------------------------
// Continuous perceptual cutoff mapping
// --------------------------------------------------

void updateCutoffs() {
  normalized0 = calculateNormalizedValue(
    smoothedValue0,
    calibration[0].relaxed,
    calibration[0].stretched
  );

  normalized1 = calculateNormalizedValue(
    smoothedValue1,
    calibration[1].relaxed,
    calibration[1].stretched
  );

  cutoff0 = cutoffForStretch(normalized0);
  cutoff1 = cutoffForStretch(normalized1);
}

float cutoffForStretch(float stretch) {
  // Equal amounts of stretch give equal frequency ratios (no note steps).
  return minCutoff * pow(maxCutoff / minCutoff, constrain(stretch, 0, 1));
}

float calculateNormalizedValue(
  float sensorValue,
  float relaxedValue,
  float stretchedValue
) {
  float calibrationRange =
    stretchedValue - relaxedValue;

  if (abs(calibrationRange) < 0.001) {
    return 0;
  }

  float result =
    (sensorValue - relaxedValue) /
    calibrationRange;

  return constrain(result, 0, 1);
}

// --------------------------------------------------
// Sound
// --------------------------------------------------

float triggerOnCounts(int i) {
  return max(minimumOnCounts, abs(calibration[i].stretched - calibration[i].relaxed) * soundOnStretch);
}

boolean sensorIsAudible(int i, float value, boolean fresh, int now) {
  SensorCalibration c = calibration[i];
  float span = c.stretched - c.relaxed;
  float on = triggerOnCounts(i);
  float off = max(minimumOffCounts, abs(span) * soundOffStretch);
  float displacement = (value - c.relaxed) * (span >= 0 ? 1 : -1);
  boolean valid = c.relaxedReady && c.stretchedReady &&
    abs(span) >= 10 && c.mode == 0 && fresh;
  boolean previous = triggerActive[i];
  if (!valid) {
    triggerActive[i] = false;
    activationSince[i] = -1;
  } else if (triggerActive[i]) {
    if (displacement <= off) {
      triggerActive[i] = false;
      activationSince[i] = -1;
    }
  } else if (displacement > on) {
    if (activationSince[i] < 0) activationSince[i] = lastSensorSampleTime;
    if (lastSensorSampleTime - activationSince[i] >= activationConfirmMs) triggerActive[i] = true;
  } else {
    activationSince[i] = -1;
  }
  if (previous != triggerActive[i]) {
    println("TRIGGER A" + i + (triggerActive[i] ? " ON" : " OFF") +
      " smooth=" + value + " relaxed=" + c.relaxed +
      " delta=" + displacement + " onThreshold=" + on +
      " offThreshold=" + off + " | A0=" + smoothedValue0 + " A1=" + smoothedValue1);
  }
  return triggerActive[i];
}

float fadeAmplitude(float current, float target, float elapsedMs) {
  float fadeMs = target > current ? 35.0 : 90.0;
  float result = current + (target - current) * (1 - exp(-elapsedMs / fadeMs));
  return target == 0 && result < 0.0001 ? 0 : result;
}

synchronized boolean isSensorCalibrating(int sensorIndex) {
  return calibration[sensorIndex].mode != 0;
}

void updateSound() {
  int now = millis();
  float elapsedMs = lastSoundTime == 0 ? 16 : max(0, now - lastSoundTime);
  lastSoundTime = now;
  boolean calibrating0 = isSensorCalibrating(0);
  boolean calibrating1 = isSensorCalibrating(1);
  boolean fresh = sensorDataReceived && now - lastSensorSampleTime <= sensorTimeoutMs;
  stretchSound0 = sensorIsAudible(0, smoothedValue0, fresh, now);
  stretchSound1 = sensorIsAudible(1, smoothedValue1, fresh, now);
  float target0 = !mutedAll && !muted0 && !calibrating0 && stretchSound0
    ? amplitude0 : 0;
  float target1 = !mutedAll && !muted1 && !calibrating1 && stretchSound1
    ? amplitude1 : 0;
  outputAmplitude0 = fadeAmplitude(outputAmplitude0, target0, elapsedMs);
  outputAmplitude1 = fadeAmplitude(outputAmplitude1, target1, elapsedMs);
  lowPass0.freq(cutoff0);
  lowPass1.freq(cutoff1);
  // Only the gate envelope controls gain, never the amount of stretch.
  // Filter bandwidth still naturally affects the perceived loudness of noise.
  noise0.amp(outputAmplitude0);
  noise1.amp(outputAmplitude1);
}

// --------------------------------------------------
// Sensor status
// --------------------------------------------------

String calibrationStatus(int i, float value) {
  if (!sensorDataReceived) return "WAITING";
  if (millis() - lastSensorSampleTime > sensorTimeoutMs) return "NO DATA";
  SensorCalibration c = calibration[i];
  if (c.mode != 0) return c.mode == 1 ? "CAPTURING R" : "CAPTURING S";
  if (!c.relaxedReady) return "SET R";
  if (!c.stretchedReady) return "SET S";
  if (abs(c.stretched - c.relaxed) < 10) return "RECALIBRATE";
  if (value < min(c.relaxed, c.stretched) - calibrationMargin) return "BELOW MIN";
  if (value > max(c.relaxed, c.stretched) + calibrationMargin) return "ABOVE MAX";
  return "OK";
}

void updateSensorStatuses() {
  sensorStatus0 = calibrationStatus(0, smoothedValue0);
  sensorStatus1 = calibrationStatus(1, smoothedValue1);
  amountBelow0 = max(0, min(calibration[0].relaxed, calibration[0].stretched) - calibrationMargin - smoothedValue0);
  amountAbove0 = max(0, smoothedValue0 - max(calibration[0].relaxed, calibration[0].stretched) - calibrationMargin);
  amountBelow1 = max(0, min(calibration[1].relaxed, calibration[1].stretched) - calibrationMargin - smoothedValue1);
  amountAbove1 = max(0, smoothedValue1 - max(calibration[1].relaxed, calibration[1].stretched) - calibrationMargin);
}

// --------------------------------------------------
// Serial input
// --------------------------------------------------

void serialEvent(Serial p) {
  String incoming = p.readStringUntil('\n');

  if (incoming == null) {
    return;
  }

  incoming = trim(incoming);

  if (incoming.length() == 0) {
    return;
  }

  // Trigger transitions below provide focused diagnostics without flooding the console.

  // Ignore Arduino status messages
  if (incoming.startsWith("XIAO") ||
      incoming.startsWith("===")) {
    return;
  }

  String[] values = split(incoming, ',');

  if (values.length != 4) {
    println(
      "Expected four comma-separated values, received: " +
      incoming
    );

    return;
  }

  try {
    float newRaw0 =
      float(trim(values[0]));

    float newSmoothed0 =
      float(trim(values[1]));

    float newRaw1 =
      float(trim(values[2]));

    float newSmoothed1 =
      float(trim(values[3]));

    // Reject readings outside the valid 12-bit range.
    // Zero can be valid, so it is not rejected here.
    if (!validADCValue(newRaw0) ||
        !validADCValue(newRaw1) ||
        !validADCValue(newSmoothed0) ||
        !validADCValue(newSmoothed1)) {

      println(
        "Ignored invalid ADC values: " +
        incoming
      );

      return;
    }

    SensorPacket packet = new SensorPacket(
      new float[] {newRaw0, newSmoothed0, newRaw1, newSmoothed1}, millis());
    if (!inputPackets.offer(packet)) {
      inputPackets.poll();
      inputPackets.offer(packet);
    }

  }
  catch (Exception e) {
    println(
      "Parse error on line: " +
      incoming
    );

    println(e);
  }
}

void drainSensorPackets() {
  SensorPacket packet;
  while ((packet = inputPackets.poll()) != null) {
    // Old queued readings must not restart sound or enter a new calibration.
    if (millis() - packet.received > sensorTimeoutMs) continue;
    rawValue0 = packet.values[0];
    smoothedValue0 = packet.values[1];
    rawValue1 = packet.values[2];
    smoothedValue1 = packet.values[3];
    lastSensorSampleTime = packet.received;
    sensorDataReceived = true;
    updateObservedRanges();
    collectCalibrationSample(packet.received);
  }
}

boolean validADCValue(float value) {
  return value >= 0 && value <= 4095;
}

// --------------------------------------------------
// Calibration sample collection
// --------------------------------------------------

synchronized void collectCalibrationSample(int received) {
  for (int i = 0; i < 2; i++) {
    SensorCalibration c = calibration[i];
    int age = received - c.started;
    if (c.mode == 0 || age < calibrationSettleMs || age > calibrationDuration) continue;
    c.sum += i == 0 ? smoothedValue0 : smoothedValue1;
    c.samples++;
  }
}

// --------------------------------------------------
// Console logging
// --------------------------------------------------

void printSensorLog() {
  println(
    "A0 RAW: " +
    nf(rawValue0, 0, 1) +

    " | SMOOTH: " +
    nf(smoothedValue0, 0, 2) +

    " | CUTOFF: " +
    nf(cutoff0, 0, 1) +

    " Hz | STATUS: " +
    sensorStatus0
  );

  println(
    "A1 RAW: " +
    nf(rawValue1, 0, 1) +

    " | SMOOTH: " +
    nf(smoothedValue1, 0, 2) +

    " | CUTOFF: " +
    nf(cutoff1, 0, 1) +

    " Hz | STATUS: " +
    sensorStatus1
  );
}

// --------------------------------------------------
// Observed ranges
// --------------------------------------------------

void updateObservedRanges() {
  if (smoothedValue0 < observedMin0) {
    observedMin0 = smoothedValue0;
  }

  if (smoothedValue0 > observedMax0) {
    observedMax0 = smoothedValue0;
  }

  if (smoothedValue1 < observedMin1) {
    observedMin1 = smoothedValue1;
  }

  if (smoothedValue1 > observedMax1) {
    observedMax1 = smoothedValue1;
  }
}

void resetObservedRange(int sensorIndex) {
  if (sensorIndex == 0) {
    if (sensorDataReceived) {
      observedMin0 = smoothedValue0;
      observedMax0 = smoothedValue0;
    } else {
      observedMin0 = Float.MAX_VALUE;
      observedMax0 = -Float.MAX_VALUE;
    }

    println("A0 observed range reset.");
  } else {
    if (sensorDataReceived) {
      observedMin1 = smoothedValue1;
      observedMax1 = smoothedValue1;
    } else {
      observedMin1 = Float.MAX_VALUE;
      observedMax1 = -Float.MAX_VALUE;
    }

    println("A1 observed range reset.");
  }
}

// --------------------------------------------------
// Keyboard controls
// --------------------------------------------------

synchronized void keyPressed() {
  if (key == '1') {
    selectedSensor = 0;
    println("Selected sensor A0.");
  }

  if (key == '2') {
    selectedSensor = 1;
    println("Selected sensor A1.");
  }

  if (key == 'r' || key == 'R') {
    startRelaxedCalibration(selectedSensor);
  }

  if (key == 's' || key == 'S') {
    startStretchedCalibration(selectedSensor);
  }

  if (key == 'm' || key == 'M') {
    mutedAll = !mutedAll;

    println(
      mutedAll ?
      "Both voices muted." :
      "Both voices unmuted."
    );
  }

  if (key == 'q' || key == 'Q') {
    muted0 = !muted0;

    println(
      muted0 ?
      "Sensor A0 voice muted." :
      "Sensor A0 voice unmuted."
    );
  }

  if (key == 'w' || key == 'W') {
    muted1 = !muted1;

    println(
      muted1 ?
      "Sensor A1 voice muted." :
      "Sensor A1 voice unmuted."
    );
  }

  if (key == 'c' || key == 'C') {
    clearCalibration(selectedSensor);
  }

  if (key == 'x' || key == 'X') {
    resetObservedRange(selectedSensor);
  }
}

// --------------------------------------------------
// Interactive calibration
// --------------------------------------------------

void startRelaxedCalibration(int sensorIndex) {
  startCalibration(sensorIndex, 1);
}

void startStretchedCalibration(int sensorIndex) {
  startCalibration(sensorIndex, 2);
}

synchronized void startCalibration(int sensorIndex, int mode) {
  if (!sensorDataReceived || millis() - lastSensorSampleTime > sensorTimeoutMs) {
    println("Cannot calibrate: no fresh sensor data.");
    return;
  }
  SensorCalibration c = calibration[sensorIndex];
  if (c.mode != 0) {
    println("This sensor is already calibrating.");
    return;
  }
  c.cancelCapture();
  activationSince[sensorIndex] = -1;
  triggerActive[sensorIndex] = false;
  c.started = millis();
  c.mode = mode;
  println("Calibrating A" + sensorIndex + (mode == 1 ? " relaxed" : " stretched"));
}

synchronized void updateCalibration() {
  for (int i = 0; i < 2; i++) {
    SensorCalibration c = calibration[i];
    if (c.mode == 0 || millis() - c.started < calibrationDuration) continue;
    if (c.samples < minimumCalibrationSamples || millis() - lastSensorSampleTime > sensorTimeoutMs) {
      println("A" + i + " calibration failed: too few fresh samples. Hold steady and retry.");
      c.cancelCapture();
      continue;
    }
    float measured = c.sum / c.samples;
    float candidateRelaxed = c.mode == 1 ? measured : c.relaxed;
    float candidateStretched = c.mode == 2 ? measured : c.stretched;
    boolean bothReady = (c.mode == 1 || c.relaxedReady) && (c.mode == 2 || c.stretchedReady);
    if (bothReady && abs(candidateStretched - candidateRelaxed) < 10) {
      println("A" + i + " calibration rejected: positions too close. Previous calibration retained.");
      c.cancelCapture();
      continue;
    }
    if (c.mode == 1) {
      c.relaxed = measured;
      c.relaxedReady = true;
    } else {
      c.stretched = measured;
      c.stretchedReady = true;
    }
    println("A" + i + " calibrated value: " + nf(measured, 0, 2));
    c.cancelCapture();
  }
}

synchronized void clearCalibration(int sensorIndex) {
  calibration[sensorIndex].reset();
  activationSince[sensorIndex] = -1;
  triggerActive[sensorIndex] = false;
  if (sensorIndex == 0) stretchSound0 = false;
  else stretchSound1 = false;
  println("Sensor " + (sensorIndex + 1) + " (A" + sensorIndex + ") calibration cleared. Use R and S.");
}

// --------------------------------------------------
// Header
// --------------------------------------------------

void drawHeader() {
  fill(0, 32, 96);
  textSize(22);

  text(
    "Embodied Stretch Synth — Dual Sensor",
    20,
    32
  );

  textSize(15);

  fill(
    serialConnected ?
    color(0, 32, 96) :
    color(0)
  );

  text(
    "Serial: " +
    (
      serialConnected ?
      "CONNECTED" :
      "DISCONNECTED"
    ),
    20,
    58
  );

  fill(0);

  text(
    "Selected sensor: A" +
    selectedSensor,
    260,
    58
  );
}

// --------------------------------------------------
// Sensor panels
// --------------------------------------------------

void drawSensorPanel0() {
  drawSensorPanel(
    0,
    20,
    85,
    500,
    260,

    rawValue0,
    smoothedValue0,

    observedMin0,
    observedMax0,

    calibration[0].relaxed,
    calibration[0].stretched,

    normalized0,
    cutoff0,

    sensorStatus0,
    amountBelow0,
    amountAbove0,

    muted0
  );
}

void drawSensorPanel1() {
  drawSensorPanel(
    1,
    580,
    85,
    500,
    260,

    rawValue1,
    smoothedValue1,

    observedMin1,
    observedMax1,

    calibration[1].relaxed,
    calibration[1].stretched,

    normalized1,
    cutoff1,

    sensorStatus1,
    amountBelow1,
    amountAbove1,

    muted1
  );
}

void drawSensorPanel(
  int sensorIndex,
  int panelX,
  int panelY,
  int panelWidth,
  int panelHeight,

  float rawValue,
  float smoothedValue,

  float observedMin,
  float observedMax,

  float relaxedValue,
  float stretchedValue,

  float normalizedValue,
  float frequency,

  String status,
  float amountBelow,
  float amountAbove,

  boolean individuallyMuted
) {
  if (selectedSensor == sensorIndex) {
    stroke(0, 32, 96);
    strokeWeight(2);
  } else {
    stroke(160);
    strokeWeight(1);
  }

  noFill();

  rect(
    panelX,
    panelY,
    panelWidth,
    panelHeight
  );

  noStroke();
  fill(0, 32, 96);

  textSize(20);

  text(
    "SENSOR A" +
    sensorIndex,
    panelX + 15,
    panelY + 28
  );

  textSize(15);
  fill(0);

  int x = panelX + 15;
  int y = panelY + 58;
  int lineHeight = 23;

  text(
    "RAW: " +
    nf(rawValue, 0, 1),
    x,
    y
  );

  y += lineHeight;

  text(
    "SMOOTH: " +
    nf(smoothedValue, 0, 2),
    x,
    y
  );

  y += lineHeight;

  text(
    "OBSERVED MIN: " +
    formatObservedValue(observedMin),
    x,
    y
  );

  y += lineHeight;

  text(
    "OBSERVED MAX: " +
    formatObservedValue(observedMax),
    x,
    y
  );

  y += lineHeight;

  text(
    "RELAXED: " +
    (calibration[sensorIndex].relaxedReady ? nf(relaxedValue, 0, 2) : "not set"),
    x,
    y
  );

  y += lineHeight;

  text(
    "STRETCHED: " +
    (calibration[sensorIndex].stretchedReady ? nf(stretchedValue, 0, 2) : "not set"),
    x,
    y
  );

  text("Sound threshold: " + nf(triggerOnCounts(sensorIndex), 0, 1) + " counts",
    panelX + 15, panelY + 225);

  int rightX = panelX + 260;
  int rightY = panelY + 58;

  text(
    "NORMALIZED: " +
    nf(normalizedValue, 0, 3),
    rightX,
    rightY
  );

  rightY += lineHeight;

  text(
    "CUTOFF: " +
    nf(frequency, 0, 1) +
    " Hz",
    rightX,
    rightY
  );

  rightY += lineHeight;

  fill(statusColor(status));

  text(
    "STATUS: " +
    status,
    rightX,
    rightY
  );

  rightY += lineHeight;

  fill(0);

  if (status.equals("BELOW MIN")) {
    text(
      "BELOW BY: " +
      nf(amountBelow, 0, 2),
      rightX,
      rightY
    );
  } else if (status.equals("ABOVE MAX")) {
    text(
      "ABOVE BY: " +
      nf(amountAbove, 0, 2),
      rightX,
      rightY
    );
  } else {
    text(
      status.equals("OK") ? "RANGE: OK" : "RANGE: NOT READY",
      rightX,
      rightY
    );
  }

  rightY += lineHeight;

  boolean effectivelyMuted =
    mutedAll ||
    individuallyMuted;

  fill(
    effectivelyMuted ?
    color(0) :
    color(0, 32, 96)
  );

  text(
    effectivelyMuted ?
    "SOUND: MUTED" :
    ((sensorIndex == 0 ? outputAmplitude0 : outputAmplitude1) > 0
      ? "SOUND: PLAYING" : "SOUND: SILENT"),
    rightX,
    rightY
  );
}

color statusColor(String status) {
  if (status.equals("OK")) {
    return color(0, 32, 96);
  }

  if (status.equals("BELOW MIN")) {
    return color(0);
  }

  if (status.equals("ABOVE MAX")) {
    return color(0);
  }

  return color(0);
}

String formatObservedValue(float value) {
  if (value == Float.MAX_VALUE ||
      value == -Float.MAX_VALUE) {
    return "waiting";
  }

  return nf(value, 0, 2);
}

// --------------------------------------------------
// Waveforms
// --------------------------------------------------

void drawWaveform0() {
  drawFilterResponse(20, 380, 500, 170, cutoff0, "A0 LOW-PASS / LEFT");
}

void drawWaveform1() {
  drawFilterResponse(580, 380, 500, 170, cutoff1, "A1 LOW-PASS / RIGHT");
}

void drawFilterResponse(int x, int y, int w, int h, float cutoff, String label) {
  stroke(160);
  strokeWeight(1);
  noFill();
  rect(x, y, w, h);
  fill(0);
  noStroke();
  textSize(14);
  text(label, x + 10, y + 20);
  textSize(12);
  text("Filter response (schematic) / logarithmic frequency", x + 10, y + 39);

  float left = x + 12;
  float right = x + w - 12;
  float top = y + 52;
  float bottom = y + h - 28;
  stroke(210);
  line(left, bottom, right, bottom);
  // Illustrates the low-pass shape; this is not a live spectrum measurement.
  noFill();
  stroke(200, 0, 0);
  strokeWeight(3);
  beginShape();
  for (int px = 0; px <= w - 24; px++) {
    float f = minCutoff * pow(maxCutoff / minCutoff, px / float(w - 24));
    float response = 1.0 / sqrt(1.0 + pow(f / cutoff, 4));
    vertex(left + px, bottom - response * (bottom - top));
  }
  endShape();
  strokeWeight(1);
  float marker = lerp(left, right, log(cutoff / minCutoff) / log(maxCutoff / minCutoff));
  stroke(0, 32, 96);
  line(marker, top, marker, bottom);
  noStroke();
  fill(0);
  text("40 Hz", left, y + h - 8);
  text("8000 Hz", right - 50, y + h - 8);
}

// --------------------------------------------------
// Controls display
// --------------------------------------------------

void drawControls() {
  fill(0);
  textSize(14);

  text(
    "1 = A0 / 2 = A1",
    20,
    590
  );

  text(
    "R = calibrate relaxed",
    20,
    614
  );

  text(
    "S = calibrate stretched",
    20,
    638
  );

  text(
    "C = reset selected calibration",
    250,
    590
  );

  text(
    "X = reset selected observed range",
    250,
    614
  );

  text(
    "M = mute both",
    580,
    590
  );

  text(
    "Q = mute A0",
    580,
    614
  );

  text(
    "W = mute A1",
    580,
    638
  );
}

// --------------------------------------------------
// Calibration message
// --------------------------------------------------

synchronized void drawCalibrationMessage() {
  fill(0, 32, 96);
  textSize(14);
  for (int i = 0; i < 2; i++) {
    if (calibration[i].mode == 0) continue;
    String positionName = calibration[i].mode == 1 ? "RELAXED" : "STRETCHED";
    text("Hold sensor " + (i + 1) + " (A" + i + ") " + positionName,
      i == 0 ? 20 : 580, 690);
  }
}
