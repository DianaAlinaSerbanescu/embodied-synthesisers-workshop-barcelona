/*
 * Diana A. Serbanescu
 * Embodied Stretch Synth
 *
 * Dual stretch-sensor Processing sketch
 *
 * Receives:
 * raw0,smoothed0,raw1,smoothed1
 *
 * A0 shapes and triggers one Max/MSP formant voice; A1 controls its pitch.
 * Calibration is independent per sensor; only A0 triggers sound.
 * Max maps stretch continuously through U / O / A / E / I.
 * D = arm/silence the Max engine; no audio is generated in Processing.
 *
 * Controls:
 * 1 = select sensor A0
 * 2 = select sensor A1
 *
 * R = calibrate relaxed position of selected sensor
 * S = calibrate stretched position of selected sensor
 *
 * M = mute/unmute the voice
 * Q = mute/unmute the voice (A0 gate)
 *
 * C = reset calibration of selected sensor
 * X = reset observed range of selected sensor
 */

import oscP5.*;
import netP5.*;

// Processing owns the controller only. Max owns all audio and vowel mapping.
OscP5 osc;
NetAddress maxAddress;
String maxHost = "127.0.0.1";
int maxPort = 12000;
int feedbackPort = 12001;
boolean engineArmed = false; // D enables sound from the Processing interface.
volatile int lastMaxFeedback = -10000;
volatile float[] formantFeedback = {300, 870, 2240, 80};
float pitchStretch = 0; // Hold last valid A1 control value during calibration.
String[] vowelNames = {"U", "O", "A", "E", "I"};

// --------------------------------------------------
// Sensor selection
// --------------------------------------------------

int selectedSensor = 0;

// --------------------------------------------------
// Wi-Fi state
// --------------------------------------------------

final int UDP_PORT = 4210;
WifiUdpReceiver udpReceiver;

boolean udpReady = false;
boolean wifiConnected = false;
boolean sensorDataReceived = false;
String udpError = "";
String senderAddress = "waiting";

int lastWiFiPacket = -10000;
long lastBoot = -1;
long lastSequence = -1;

long receivedPackets = 0;
long missingPackets = 0;
long invalidPackets = 0;
long outOfOrderPackets = 0;

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
int[] gestureId = {0, 0}; // Counts physical activations, independent of mute/fade.
int sensorTimeoutMs = 350;
volatile int lastSensorSampleTime = 0;
boolean stretchSound0 = false;
boolean stretchSound1 = false;
float outputAmplitude0 = 0;
int lastSoundTime = 0;

float amplitude0 = 0.15;

boolean mutedAll = false;
boolean muted0 = false;

// One centered voice, sent to both output channels by Max.

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
  
  setupWiFiReceiver();

  osc = new OscP5(this, feedbackPort);
  maxAddress = new NetAddress(maxHost, maxPort);
  frameRate(60);
}

// --------------------------------------------------
// Main loop
// --------------------------------------------------

synchronized void draw() {
  background(255);

  receiveWiFi();
  updateCalibration();

  updateSensorStatuses();
  updateStretch();
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
  text("A0: vowel + new timbre per gesture. A1: pitch 80–400 Hz. Relax A0 for silence.", 20, 665);
  text("D = " + (engineArmed ? "silence engine" : "enable engine"), 800, 590);
  text(maxIsConnected() ? "MAX LINK: RECEIVING" : "MAX LINK: WAITING", 800, 614);
  textSize(11);
  text(udpError.length() > 0 ? udpError :
    "UDP " + UDP_PORT + " | ESP32: " + senderAddress + " | packets: " + receivedPackets +
    " | missing: " + missingPackets + " | invalid: " + invalidPackets, 20, 710);
  drawCalibrationMessage();
  popMatrix();
}

// --------------------------------------------------
// Normalized stretch (vowel mapping is in Max)
// --------------------------------------------------

void updateStretch() {
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

}

String vowelPosition(float stretch) {
  float position = constrain(stretch, 0, 1) * 4;
  int index = min(3, int(position));
  float blend = position - index;
  if (blend < 0.01) return vowelNames[index];
  if (blend > 0.99) return vowelNames[index + 1];
  return vowelNames[index] + " > " + vowelNames[index + 1] + "  " + nf(blend * 100, 0, 0) + "%";
}

boolean maxIsConnected() {
  return millis() - lastMaxFeedback < 700;
}

void oscEvent(OscMessage message) {
  if (!message.checkAddrPattern("/formants/pitch/feedback") || !message.typetag().matches("[if]{4}")) return;
  float[] next = new float[4];
  for (int i = 0; i < next.length; i++) {
    next[i] = message.typetag().charAt(i) == 'i' ? message.get(i).intValue() : message.get(i).floatValue();
    if (Float.isNaN(next[i]) || Float.isInfinite(next[i]) || next[i] < (i == 3 ? 80 : 100) || next[i] > (i == 3 ? 400 : 5000)) return;
  }
  formantFeedback = next;
  lastMaxFeedback = millis();
}

void sendControllerState() {
  if (osc == null) return;
  OscMessage message = new OscMessage("/formants/pitch/state");
  message.add(normalized0);
  message.add(pitchStretch);
  message.add(outputAmplitude0);
  message.add(engineArmed ? 1 : 0);
  message.add(gestureId[0]);
  osc.send(message, maxAddress);
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
  if (!previous && triggerActive[i]) gestureId[i]++;
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

boolean pitchSensorReady() {
  SensorCalibration c = calibration[1];
  return c.relaxedReady && c.stretchedReady && c.mode == 0 && abs(c.stretched - c.relaxed) >= 10;
}

void updateSound() {
  int now = millis();
  float elapsedMs = lastSoundTime == 0 ? 16 : max(0, now - lastSoundTime);
  lastSoundTime = now;
  boolean calibrating0 = isSensorCalibrating(0);
  boolean fresh = sensorDataReceived && now - lastSensorSampleTime <= sensorTimeoutMs;
  stretchSound0 = sensorIsAudible(0, smoothedValue0, fresh, now);
  // A1 never gates the voice: fully relaxed selects the lowest pitch.
  if (pitchSensorReady() && fresh) pitchStretch = normalized1;
  float target0 = engineArmed && !mutedAll && !muted0 && !calibrating0 && stretchSound0
    ? amplitude0 : 0;
  outputAmplitude0 = fadeAmplitude(outputAmplitude0, target0, elapsedMs);
  sendControllerState();
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
// Wi-Fi input
// --------------------------------------------------

void setupWiFiReceiver() {
  try {
    udpReceiver = new WifiUdpReceiver(UDP_PORT);
    udpReady = true;
    println("Listening for ESP32 Wi-Fi data on UDP " + UDP_PORT);
  }
  catch (Exception e) {
    udpReady = false;
    udpError = "Cannot listen on UDP " + UDP_PORT + ": " + e.getMessage();
    println(udpError);
  }
}

boolean wifiFresh() {
  return sensorDataReceived && millis()-lastWiFiPacket<=sensorTimeoutMs;
}

void receiveWiFi() {
  if (udpReceiver == null || !udpReady) return;
  try {
    for (int i = 0; i < 128; i++) {
      String[] packet = udpReceiver.poll();
      if (packet == null) break;
      if (packet.length != 2) {
        invalidPackets++;
        continue;
      }
      acceptWiFiPacket(packet[0], packet[1]);
    }
  }
  catch (Exception e) {
    udpError = "UDP receive error: " + e.getMessage();
  }
  wifiConnected = wifiFresh();
}

boolean acceptWiFiPacket(String message,String peer){
  try{
    String[] v=message.trim().split(",",-1);if(v.length!=7||!v[0].equals("ES1")){invalidPackets++;return false;}
    long boot=Long.parseLong(v[1]),seq=Long.parseLong(v[2]);
    if(boot<0||boot>0xffffffffL||seq<0||seq>0xffffffffL){invalidPackets++;return false;}
    float[] data=new float[4];for(int i=0;i<4;i++){data[i]=Float.parseFloat(v[i+3]);if(!validADCValue(data[i])){invalidPackets++;return false;}}
    if(wifiFresh()&&!peer.equals(senderAddress)){invalidPackets++;return false;}
    if(boot==lastBoot&&peer.equals(senderAddress)){
      long step=(seq-lastSequence)&0xffffffffL;if(step==0||step>=0x80000000L){outOfOrderPackets++;return false;}
      if(step>1)missingPackets+=step-1;
    }
    lastBoot=boot;lastSequence=seq;senderAddress=peer;
    rawValue0=data[0];smoothedValue0=data[1];rawValue1=data[2];smoothedValue1=data[3];
    sensorDataReceived = true;
    lastWiFiPacket = millis();
    lastSensorSampleTime = lastWiFiPacket; // Keeps the existing audio freshness check current.
    receivedPackets++;
    wifiConnected = true;
    updateObservedRanges();
    collectCalibrationSample(lastWiFiPacket);
    return true;
  }catch(Exception e){invalidPackets++;return false;}
}

public void dispose(){
  try{if(udpReceiver!=null)udpReceiver.close();}catch(Exception e){}
  super.dispose();
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
  if (key == 'd' || key == 'D') {
    engineArmed = !engineArmed;
    println(engineArmed ? "Max engine armed." : "Max engine silenced.");
  }
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
      "Voice muted." :
      "Voice unmuted."
    );
  }

  if (key == 'q' || key == 'Q') {
    muted0 = !muted0;

    println(
      muted0 ?
      "Voice muted." :
      "Voice unmuted."
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
    "Embodied Stretch Synth — A0 Vowel / A1 Pitch",
    20,
    32
  );

  textSize(15);

  fill(
    wifiConnected ?
    color(0, 32, 96) :
    color(0)
  );

  text(
    "WiFi: " +
    (
      wifiConnected ?
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

    sensorStatus1,
    amountBelow1,
    amountAbove1,

    muted0
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

  text(sensorIndex == 0 ? "Sound threshold: " + nf(triggerOnCounts(0), 0, 1) + " counts" : "Pitch range: 80–400 Hz",
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
    sensorIndex == 0 ? "VOWEL: " + vowelPosition(normalizedValue) :
      maxIsConnected() ? "PITCH: " + nf(formantFeedback[3], 0, 1) + " Hz" : "PITCH: waiting for Max",
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
    sensorIndex == 1 ? (pitchSensorReady() ? "PITCH: TRACKING" : "PITCH: HELD / SET R,S") :
    effectivelyMuted ?
    "SOUND: MUTED" :
    (!engineArmed ? "ENGINE: OFF" : !maxIsConnected() ? "MAX: NO LINK" :
      outputAmplitude0 > 0
      ? "VOICE: ACTIVE" : "VOICE: SILENT"),
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
  drawFormants(0, 20, 380, 500, 170);
}

void drawWaveform1() {
  drawPitchPanel(580, 380, 500, 170);
}

void drawPitchPanel(int x, int y, int w, int h) {
  stroke(160);
  strokeWeight(1);
  noFill();
  rect(x, y, w, h);
  noStroke();
  fill(0);
  textSize(14);
  text("A1 PITCH / SAME VOICE", x + 10, y + 20);
  textSize(12);
  text("Relaxed = 80 Hz; stretched = 400 Hz. A0 controls silence.", x + 10, y + 39);
  float left = x + 20;
  float right = x + w - 20;
  float base = y + 115;
  stroke(210);
  line(left, base, right, base);
  if (maxIsConnected()) {
    float pitch = formantFeedback[3];
    float position = constrain(log(pitch / 80.0) / log(5.0), 0, 1);
    float marker = lerp(left, right, position);
    stroke(200, 0, 0);
    strokeWeight(3);
    line(marker, y + 65, marker, base);
    noStroke();
    fill(0, 32, 96);
    textSize(20);
    text(nf(pitch, 0, 1) + " Hz", x + 190, y + 82);
  }
  strokeWeight(1);
  noStroke();
  fill(0);
  textSize(12);
  text("80 Hz", left, y + h - 8);
  text("Perceptual pitch scale", x + 180, y + h - 8);
  text("400 Hz", right - 45, y + h - 8);
}

void drawFormants(int sensor, int x, int y, int w, int h) {
  stroke(160);
  strokeWeight(1);
  noFill();
  rect(x, y, w, h);
  noStroke();
  fill(0);
  textSize(14);
  text("A0 FORMANTS / VOWEL", x + 10, y + 20);
  float[] feedback = formantFeedback;
  int base = sensor * 3;
  textSize(12);
  text(maxIsConnected() ? "F1 " + nf(feedback[base], 0, 0) + " Hz    F2 " +
    nf(feedback[base + 1], 0, 0) + " Hz    F3 " + nf(feedback[base + 2], 0, 0) + " Hz"
    : "Waiting for formant frequencies from Max", x + 10, y + 39);
  float left = x + 12;
  float bottom = y + h - 28;
  stroke(210);
  line(left, bottom, x + w - 12, bottom);
  if (maxIsConnected()) {
    // Diagram of target resonances, not an audio waveform or measured spectrum.
    stroke(200, 0, 0);
    strokeWeight(3);
    noFill();
    beginShape();
    for (int px = 0; px <= w - 24; px++) {
      float f = 3500.0 * px / (w - 24);
      float value = 0;
      for (int j = 0; j < 3; j++) {
        float bandwidth = j == 0 ? 80 : j == 1 ? 100 : 140;
        float distance = (f - feedback[base + j]) / bandwidth;
        value += (j == 0 ? 1.0 : j == 1 ? 0.7 : 0.45) * exp(-0.5 * distance * distance);
      }
      vertex(left + px, bottom - min(value, 1.2) * 60);
    }
    endShape();
  }
  strokeWeight(1);
  noStroke();
  fill(0);
  text("0 Hz", left, y + h - 8);
  text("Target resonances", x + 185, y + h - 8);
  text("3500 Hz", x + w - 62, y + h - 8);
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
    "M = mute voice",
    580,
    590
  );

  text(
    "Q = mute voice (A0)",
    580,
    614
  );

  text(
    "A1 = pitch; no gate",
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
