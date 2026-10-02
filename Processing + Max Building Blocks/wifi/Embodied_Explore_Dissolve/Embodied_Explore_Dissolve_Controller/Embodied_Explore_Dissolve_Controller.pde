/*
 * Diana A. Serbanescu
 * Embodied Stretch Synth
 *
 * Dual stretch-sensor Processing sketch
 *
 * Receives:
 * raw0,smoothed0,raw1,smoothed1
 *
 * A0 scans and gates a recording; A1 dissolves it into 250–20 ms grains.
 * Calibration is independent per sensor; only A0 triggers sound.
 * L opens a WAV/AIFF file; Max owns all audio and waveform analysis.
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

import java.io.File;
import oscP5.*;
import netP5.*;

// Serial callback publishes packets; only draw/keyPressed change instrument state.
class SensorPacket {
  float[] values;
  int received;
  SensorPacket(float[] values, int received) {
    this.values = values;
    this.received = received;
  }
}

// Processing owns the controller; Max loads and granulates the sound file.
OscP5 osc;
NetAddress maxAddress;
String maxHost = "127.0.0.1";
int maxPort = 12000;
int feedbackPort = 12001;
boolean engineArmed = false; // D enables sound from the Processing interface.
volatile int lastMaxFeedback = -10000;
float grainStretch = 0; // Hold last valid A1 value during calibration.
int loadRequestId = 0;
String selectedFilePath = "";
String selectedFileName = "No recording selected";
String fileError = "";
int remoteFileId = 0;
int sampleState = 0; // 0 empty, 1 loading, 2 ready, negative = error
float sampleDuration = 0;
float samplePosition = 0;
float grainDuration = 250;
int sampleChannels = 0;
float[] waveform = new float[0];
int waveformId = 0;
int lastLoadSent = -10000;
boolean filePickerOpen = false;

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
int sensorTimeoutMs = 350;
volatile int lastSensorSampleTime = 0;
boolean stretchSound0 = false;
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
  text("A0: explore the recording / release for silence. A1: dissolve / 250–20 ms fragments.", 20, 665);
  text("D = " + (engineArmed ? "silence engine" : "enable engine"), 800, 590);
  text(maxIsConnected() ? "MAX LINK: RECEIVING" : "MAX LINK: WAITING", 800, 614);
  text("L = load WAV / AIFF", 800, 638);
  drawCalibrationMessage();
  popMatrix();
}

// --------------------------------------------------
// Normalized stretch (grain playback is in Max)
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

boolean maxIsConnected() {
  return millis() - lastMaxFeedback < 700;
}

float oscNumber(OscMessage message, int i) {
  return message.typetag().charAt(i) == 'i' ? message.get(i).intValue() : message.get(i).floatValue();
}

synchronized void oscEvent(OscMessage message) {
  if (message.checkAddrPattern("/granular/status") && message.typetag().matches("[if]{6}")) {
    float[] n = new float[6];
    for (int i = 0; i < n.length; i++) {
      n[i] = oscNumber(message, i);
      if (Float.isNaN(n[i]) || Float.isInfinite(n[i])) return;
    }
    if (n[0] < 0 || n[1] < -2 || n[1] > 2 || n[2] < 0 || n[3] < 0 || n[4] < 0 || n[4] > 251) return;
    lastMaxFeedback = millis();
    remoteFileId = round(n[0]);
    if (remoteFileId != loadRequestId) return;
    sampleState = round(n[1]);
    sampleDuration = n[2]; samplePosition = n[3]; grainDuration = n[4];
    sampleChannels = round(n[5]);
  } else if (message.checkAddrPattern("/granular/wave") && message.typetag().matches("[if]{257}")) {
    int id = round(oscNumber(message, 0));
    if (id != loadRequestId || id == 0) return;
    float[] preview = new float[256];
    for (int i = 0; i < preview.length; i++) {
      preview[i] = oscNumber(message, i + 1);
      if (Float.isNaN(preview[i]) || Float.isInfinite(preview[i]) || preview[i] < 0 || preview[i] > 1) return;
    }
    waveform = preview;
    waveformId = id;
  }
}

float scanPosition() {
  // Map the playable range to the WHOLE recording despite A0's resting dead zone.
  float span = abs(calibration[0].stretched - calibration[0].relaxed);
  float on = span < 10 ? 0.05 : min(0.99, triggerOnCounts(0) / span);
  return constrain((normalized0 - on) / (1 - on), 0, 1);
}

void sendControllerState() {
  if (osc == null) return;
  OscMessage message = new OscMessage("/granular/state");
  message.add(scanPosition());
  message.add(grainStretch);
  message.add(outputAmplitude0);
  message.add(engineArmed ? 1 : 0);
  message.add(loadRequestId);
  message.add(waveformId);
  osc.send(message, maxAddress);
  // Retry a dropped load request, or restore the selected file after Max restarts.
  if (loadRequestId > 0 && selectedFilePath.length() > 0 && remoteFileId != loadRequestId && millis() - lastLoadSent >= 1000) {
    OscMessage loadMessage = new OscMessage("/granular/load");
    loadMessage.add(loadRequestId);
    loadMessage.add(selectedFilePath);
    osc.send(loadMessage, maxAddress);
    lastLoadSent = millis();
  }
}

synchronized void audioFileSelected(File selected) {
  filePickerOpen = false;
  if (selected == null) return;
  String name = selected.getName().toLowerCase();
  if (!selected.isFile() || !(name.endsWith(".wav") || name.endsWith(".aif") || name.endsWith(".aiff"))) {
    fileError = "Choose a WAV or AIFF file";
    return;
  }
  selectedFilePath = selected.getAbsolutePath();
  selectedFileName = selected.getName();
  loadRequestId = loadRequestId == 0 ? int(System.currentTimeMillis() % 10000000) + 1 : loadRequestId + 1;
  waveform = new float[0]; waveformId = 0;
  sampleState = 1; sampleDuration = 0; samplePosition = 0; fileError = "";
  lastLoadSent = -10000;
}

String recordingStatus() {
  if (fileError.length() > 0) return fileError;
  if (loadRequestId == 0) return "Press L to load a recording";
  if (!maxIsConnected()) return "Waiting for Max";
  if (remoteFileId != loadRequestId || sampleState == 1) return "Loading / preparing waveform...";
  if (sampleState == -2) return "Use mono/stereo audio longer than 21 ms";
  if (sampleState < 0) return "Load failed: press L to retry";
  if (sampleState == 2) return nf(sampleDuration / 1000, 0, 2) + " s / " + (sampleChannels == 1 ? "mono" : "stereo");
  return "Press L to load a recording";
}

String shortLabel(String textValue, int limit) {
  return textValue.length() <= limit ? textValue : textValue.substring(0, limit - 3) + "...";
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

boolean grainSensorReady() {
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
  // A1 never gates the voice: relaxed selects long, recognizable fragments.
  if (grainSensorReady() && fresh) grainStretch = normalized1;
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
  if (key == 'l' || key == 'L') {
    if (!filePickerOpen && !(sampleState == 1 && maxIsConnected())) {
      filePickerOpen = true;
      selectInput("Choose a WAV or AIFF recording", "audioFileSelected");
    }
  }
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
  println("Sensor " + (sensorIndex + 1) + " (A" + sensorIndex + ") calibration cleared. Use R and S.");
}

// --------------------------------------------------
// Header
// --------------------------------------------------

void drawHeader() {
  fill(0, 32, 96);
  textSize(22);

  text(
    "Embodied Stretch Synth — Explore and Dissolve",
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

  text(sensorIndex == 0 ? "Sound threshold: " + nf(triggerOnCounts(0), 0, 1) + " counts" : "Fragment range: 250–20 ms",
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
    sensorIndex == 0 ? "SCAN: " + nf(scanPosition() * 100, 0, 1) + "%" :
      "FRAGMENT: " + nf(sampleState == 2 ? grainDuration : 250 * pow(20.0 / 250, grainStretch), 0, 1) + " ms",
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
    sensorIndex == 1 ? (grainSensorReady() ? "SIZE: TRACKING" : "SIZE: HELD / SET R,S") :
    effectivelyMuted ?
    "SOUND: MUTED" :
    (!engineArmed ? "ENGINE: OFF" : !maxIsConnected() ? "MAX: NO LINK" : sampleState != 2 ? "LOAD A RECORDING" :
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
  int x = 20, y = 380, w = 500, h = 170;
  stroke(160); strokeWeight(1); noFill(); rect(x, y, w, h);
  noStroke(); fill(0); textSize(14);
  text("A0 EXPLORE / " + shortLabel(selectedFileName, 40), x + 10, y + 20);
  textSize(12); text(recordingStatus(), x + 10, y + 39);
  float left = x + 12, right = x + w - 12, centre = y + 99;
  stroke(210); line(left, centre, right, centre);
  if (waveform.length == 256 && waveformId == loadRequestId && sampleDuration > 0) {
    noStroke(); fill(0, 32, 96, 35);
    float start = left + (right - left) * samplePosition / sampleDuration;
    float end = left + (right - left) * min(1, (samplePosition + grainDuration) / sampleDuration);
    rect(start, y + 51, max(2, end - start), 94);
    stroke(200, 0, 0); strokeWeight(1);
    for (int i = 0; i < waveform.length; i++) {
      float px = lerp(left, right, i / float(waveform.length - 1));
      line(px, centre - waveform[i] * 42, px, centre + waveform[i] * 42);
    }
    stroke(0, 32, 96); strokeWeight(2); line(start, y + 51, start, y + 145);
  }
  strokeWeight(1); noStroke(); fill(0); textSize(12);
  text("0 s", left, y + h - 8);
  text("Sampled waveform / fragment window", x + 130, y + h - 8);
  text(nf(sampleDuration / 1000, 0, 1) + " s", right - 48, y + h - 8);
}

void drawWaveform1() {
  int x = 580, y = 380, w = 500, h = 170;
  stroke(160); strokeWeight(1); noFill(); rect(x, y, w, h);
  noStroke(); fill(0); textSize(14); text("A1 DISSOLVE / FRAGMENT SIZE", x + 10, y + 20);
  textSize(12); text("Long fragments > short textures. Original playback pitch.", x + 10, y + 39);
  float ms = sampleState == 2 ? grainDuration : 250 * pow(20.0 / 250, grainStretch);
  fill(0, 32, 96); textSize(20); text(nf(ms, 0, 1) + " ms", x + 198, y + 69);
  // Diagram of overlapping grain windows in a fixed 500 ms time window.
  float durationPixels = max(1, ms / 500.0 * (w - 24));
  stroke(200, 0, 0); strokeWeight(1.5); noFill();
  for (float start = 0; start < w - 24; start += durationPixels / 4) {
    beginShape();
    for (int step = 0; step <= 24; step++) {
      float px = start + durationPixels * step / 24;
      if (px > w - 24) break;
      float env = 0.5 - 0.5 * cos(TWO_PI * step / 24);
      vertex(x + 12 + px, y + 137 - env * 54);
    }
    endShape();
  }
  strokeWeight(1); noStroke(); fill(0); textSize(12);
  text("Long: 250 ms", x + 12, y + h - 8);
  text("Grain envelopes / 500 ms", x + 170, y + h - 8);
  text("Short: 20 ms", x + w - 90, y + h - 8);
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
    "A1 = fragment size",
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
