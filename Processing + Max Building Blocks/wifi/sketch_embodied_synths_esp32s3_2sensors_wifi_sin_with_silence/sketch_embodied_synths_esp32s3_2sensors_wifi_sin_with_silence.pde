/*
 * Diana A. Serbanescu
 * Embodied Stretch Synth
 *
 * Dual stretch-sensor Processing sketch
 *
 * Receives:
 * raw0,smoothed0,raw1,smoothed1
 *
 * Sensor A0 controls sine oscillator 0.
 * Sensor A1 controls sine oscillator 1.
 *
 * Controls:
 * 1 = select sensor A0
 * 2 = select sensor A1
 *
 * R = calibrate relaxed position of selected sensor
 * S = calibrate stretched position of selected sensor
 *
 * M = mute/unmute both oscillators
 * Q = mute/unmute sensor A0
 * W = mute/unmute sensor A1
 *
 * C = reset calibration of selected sensor
 * X = reset observed range of selected sensor
 */
import processing.sound.*;
import oscP5.*;
import netP5.*;

SinOsc sine0;
SinOsc sine1;

// --------------------------------------------------
// Sensor selection
// --------------------------------------------------

int selectedSensor = 0;

// --------------------------------------------------
// Wi-Fi connection
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

// Temporary fallback values.
// Interactive calibration will replace these.
float relaxedSensor0 = 1200;
float stretchedSensor0 = 1600;

float relaxedSensor1 = 1200;
float stretchedSensor1 = 1600;

boolean relaxedCalibrated0 = false;
boolean stretchedCalibrated0 = false;

boolean relaxedCalibrated1 = false;
boolean stretchedCalibrated1 = false;

// Only one calibration operation runs at a time.
boolean calibratingRelaxed = false;
boolean calibratingStretched = false;

int calibrationSensor = 0;

int calibrationStartTime = 0;
int calibrationDuration = 1500;

float calibrationSum = 0;
int calibrationSamples = 0;

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

// Give the two oscillators slightly different ranges
// so that they remain distinguishable.

float minFreq0 = 100;
float maxFreq0 = 700;

float minFreq1 = 180;
float maxFreq1 = 1100;

float freq0 = minFreq0;
float freq1 = minFreq1;

// --------------------------------------------------
// OSC
// --------------------------------------------------

OscP5 osc;
NetAddress maxAddress;

// --------------------------------------------------
// Sound
// --------------------------------------------------

// A small relaxed zone prevents resting noise from repeatedly triggering sound.
// Start above 5% stretch; stop below 3%. Both endpoints must be calibrated.
float soundOnStretch = 0.25;
float soundOffStretch = 0.08;
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

  setupWiFiReceiver();

  sine0 = new SinOsc(this);
  sine1 = new SinOsc(this);

  sine0.play(minFreq0, 0);
  sine1.play(minFreq1, 0);

  sine0.pan(pan0);
  sine1.pan(pan1);

  sine0.amp(0);
  sine1.amp(0);
  
  // communication sending port is 8000, 12000 is Processing's own OSC listening port
  osc = new OscP5(this, 12000);
  maxAddress = new NetAddress("127.0.0.1", 8000);
}

// --------------------------------------------------
// Main loop
// --------------------------------------------------

void draw() {
  background(255);

  receiveWiFi();

  updateCalibration();

  updateSensorStatuses();
  updatePitches();
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
  text("Calibrate R / S: sound sustains while stretched; relaxed is silent.", 20, 665);
  textSize(11);
  text(udpError.length()>0?udpError:"UDP "+UDP_PORT+" | ESP32: "+senderAddress+" | packets: "+receivedPackets,20,710);
  drawCalibrationMessage();
  popMatrix();
}

// --------------------------------------------------
// Pitch mapping
// --------------------------------------------------

void updatePitches() {
  normalized0 = calculateNormalizedValue(
    smoothedValue0,
    relaxedSensor0,
    stretchedSensor0
  );

  normalized1 = calculateNormalizedValue(
    smoothedValue1,
    relaxedSensor1,
    stretchedSensor1
  );

  // Exponential frequency mapping
  freq0 = minFreq0 * pow(
    maxFreq0 / minFreq0,
    normalized0
  );

  freq1 = minFreq1 * pow(
    maxFreq1 / minFreq1,
    normalized1
  );
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

boolean stretchIsAudible(boolean wasAudible, float stretch,
                         boolean calibrated, boolean fresh) {
  if (!calibrated || !fresh) return false;
  return stretch > (wasAudible ? soundOffStretch : soundOnStretch);
}

float fadeAmplitude(float current, float target, float elapsedMs) {
  float fadeMs = target > current ? 35.0 : 90.0;
  float result = current + (target - current) * (1 - exp(-elapsedMs / fadeMs));
  return target == 0 && result < 0.0001 ? 0 : result;
}

boolean isSensorCalibrating(int sensorIndex) {
  return calibrationSensor == sensorIndex &&
    (calibratingRelaxed || calibratingStretched);
}

void updateSound() {
  int now = millis();
  float elapsedMs = lastSoundTime == 0 ? 16 : max(0, now - lastSoundTime);
  lastSoundTime = now;
  boolean calibrating0 = isSensorCalibrating(0);
  boolean calibrating1 = isSensorCalibrating(1);
  boolean fresh = sensorDataReceived && now - lastSensorSampleTime <= sensorTimeoutMs;
  boolean calibrated0 = relaxedCalibrated0 && stretchedCalibrated0 &&
    abs(stretchedSensor0 - relaxedSensor0) >= 10;
  boolean calibrated1 = relaxedCalibrated1 && stretchedCalibrated1 &&
    abs(stretchedSensor1 - relaxedSensor1) >= 10;
  stretchSound0 = stretchIsAudible(stretchSound0, normalized0, calibrated0, fresh);
  stretchSound1 = stretchIsAudible(stretchSound1, normalized1, calibrated1, fresh);
  float target0 = !mutedAll && !muted0 && !calibrating0 && stretchSound0
    ? amplitude0 : 0;
  float target1 = !mutedAll && !muted1 && !calibrating1 && stretchSound1
    ? amplitude1 : 0;
  outputAmplitude0 = fadeAmplitude(outputAmplitude0, target0, elapsedMs);
  outputAmplitude1 = fadeAmplitude(outputAmplitude1, target1, elapsedMs);
  sine0.freq(freq0);
  sine1.freq(freq1);
  sine0.amp(outputAmplitude0);
  sine1.amp(outputAmplitude1);
}




// --------------------------------------------------
// Sensor status
// --------------------------------------------------

void updateSensorStatuses() {
  if (!sensorDataReceived) {
    sensorStatus0 = "WAITING";
    sensorStatus1 = "WAITING";

    amountBelow0 = 0;
    amountAbove0 = 0;

    amountBelow1 = 0;
    amountAbove1 = 0;

    return;
  }

  float calibratedMin0 =
    min(relaxedSensor0, stretchedSensor0) -
    calibrationMargin;

  float calibratedMax0 =
    max(relaxedSensor0, stretchedSensor0) +
    calibrationMargin;

  amountBelow0 = 0;
  amountAbove0 = 0;

  if (smoothedValue0 < calibratedMin0) {
    sensorStatus0 = "BELOW MIN";
    amountBelow0 = calibratedMin0 - smoothedValue0;
  } else if (smoothedValue0 > calibratedMax0) {
    sensorStatus0 = "ABOVE MAX";
    amountAbove0 = smoothedValue0 - calibratedMax0;
  } else {
    sensorStatus0 = "OK";
  }

  float calibratedMin1 =
    min(relaxedSensor1, stretchedSensor1) -
    calibrationMargin;

  float calibratedMax1 =
    max(relaxedSensor1, stretchedSensor1) +
    calibrationMargin;

  amountBelow1 = 0;
  amountAbove1 = 0;

  if (smoothedValue1 < calibratedMin1) {
    sensorStatus1 = "BELOW MIN";
    amountBelow1 = calibratedMin1 - smoothedValue1;
  } else if (smoothedValue1 > calibratedMax1) {
    sensorStatus1 = "ABOVE MAX";
    amountAbove1 = smoothedValue1 - calibratedMax1;
  } else {
    sensorStatus1 = "OK";
  }
}

// --------------------------------------------------
// WiFi input
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
    collectCalibrationSample();
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

void collectCalibrationSample() {
  if (!calibratingRelaxed &&
      !calibratingStretched) {
    return;
  }

  if (calibrationSensor == 0) {
    calibrationSum += smoothedValue0;
  } else {
    calibrationSum += smoothedValue1;
  }

  calibrationSamples++;
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

    " | FREQ: " +
    nf(freq0, 0, 1) +

    " Hz | STATUS: " +
    sensorStatus0
  );

  println(
    "A1 RAW: " +
    nf(rawValue1, 0, 1) +

    " | SMOOTH: " +
    nf(smoothedValue1, 0, 2) +

    " | FREQ: " +
    nf(freq1, 0, 1) +

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

void keyPressed() {
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
      "Both oscillators muted." :
      "Both oscillators unmuted."
    );
  }

  if (key == 'q' || key == 'Q') {
    muted0 = !muted0;

    println(
      muted0 ?
      "Sensor A0 oscillator muted." :
      "Sensor A0 oscillator unmuted."
    );
  }

  if (key == 'w' || key == 'W') {
    muted1 = !muted1;

    println(
      muted1 ?
      "Sensor A1 oscillator muted." :
      "Sensor A1 oscillator unmuted."
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
  if (!sensorDataReceived) {
    println(
      "Cannot calibrate: no sensor data received."
    );

    return;
  }

  if (calibratingRelaxed ||
      calibratingStretched) {
    println(
      "Calibration is already running."
    );

    return;
  }

  calibrationSensor = sensorIndex;

  calibratingRelaxed = true;
  calibratingStretched = false;

  calibrationStartTime = millis();

  calibrationSum = 0;
  calibrationSamples = 0;

  println(
    "Calibrating relaxed position for A" +
    calibrationSensor +
    "..."
  );
}

void startStretchedCalibration(int sensorIndex) {
  if (!sensorDataReceived) {
    println(
      "Cannot calibrate: no sensor data received."
    );

    return;
  }

  if (calibratingRelaxed ||
      calibratingStretched) {
    println(
      "Calibration is already running."
    );

    return;
  }

  calibrationSensor = sensorIndex;

  calibratingRelaxed = false;
  calibratingStretched = true;

  calibrationStartTime = millis();

  calibrationSum = 0;
  calibrationSamples = 0;

  println(
    "Calibrating stretched position for A" +
    calibrationSensor +
    "..."
  );
}

void updateCalibration() {
  if (!calibratingRelaxed &&
      !calibratingStretched) {
    return;
  }

  int elapsed =
    millis() - calibrationStartTime;

  if (elapsed < calibrationDuration) {
    return;
  }

  if (calibrationSamples == 0) {
    println(
      "Calibration failed: no samples received."
    );

    stopCalibration();
    return;
  }

  float measuredValue =
    calibrationSum /
    calibrationSamples;

  if (calibrationSensor == 0) {
    if (calibratingRelaxed) {
      relaxedSensor0 = measuredValue;
      relaxedCalibrated0 = true;

      println(
        "A0 relaxed value recorded: " +
        nf(relaxedSensor0, 0, 2)
      );
    }

    if (calibratingStretched) {
      stretchedSensor0 = measuredValue;
      stretchedCalibrated0 = true;

      println(
        "A0 stretched value recorded: " +
        nf(stretchedSensor0, 0, 2)
      );
    }
  } else {
    if (calibratingRelaxed) {
      relaxedSensor1 = measuredValue;
      relaxedCalibrated1 = true;

      println(
        "A1 relaxed value recorded: " +
        nf(relaxedSensor1, 0, 2)
      );
    }

    if (calibratingStretched) {
      stretchedSensor1 = measuredValue;
      stretchedCalibrated1 = true;

      println(
        "A1 stretched value recorded: " +
        nf(stretchedSensor1, 0, 2)
      );
    }
  }

  stopCalibration();
}

void stopCalibration() {
  calibratingRelaxed = false;
  calibratingStretched = false;

  calibrationSum = 0;
  calibrationSamples = 0;
}

// --------------------------------------------------
// Reset calibration
// --------------------------------------------------

void clearCalibration(int sensorIndex) {
  if (sensorIndex == 0) {
    relaxedSensor0 = 1200;
    stretchedSensor0 = 1600;

    relaxedCalibrated0 = false;
    stretchedCalibrated0 = false;

    println(
      "A0 calibration reset to fallback values."
    );
  } else {
    relaxedSensor1 = 1200;
    stretchedSensor1 = 1600;

    relaxedCalibrated1 = false;
    stretchedCalibrated1 = false;

    println(
      "A1 calibration reset to fallback values."
    );
  }

  // Reset only this sensor; another sensor's capture must continue.
  if (isSensorCalibrating(sensorIndex)) {
    stopCalibration();
  }
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
    wifiConnected ?
    color(0, 32, 96) :
    color(0)
  );

  text(
    "Serial: " +
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

    relaxedSensor0,
    stretchedSensor0,

    normalized0,
    freq0,

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

    relaxedSensor1,
    stretchedSensor1,

    normalized1,
    freq1,

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
    nf(relaxedValue, 0, 2),
    x,
    y
  );

  y += lineHeight;

  text(
    "STRETCHED: " +
    nf(stretchedValue, 0, 2),
    x,
    y
  );

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
    "FREQUENCY: " +
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
      "RANGE: OK",
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
  drawWaveform(
    20,
    380,
    500,
    170,
    freq0,
    minFreq0,
    maxFreq0,
    outputAmplitude0 / amplitude0,
    "A0 WAVEFORM"
  );
}

void drawWaveform1() {
  drawWaveform(
    580,
    380,
    500,
    170,
    freq1,
    minFreq1,
    maxFreq1,
    outputAmplitude1 / amplitude1,
    "A1 WAVEFORM"
  );
}

void drawWaveform(
  int waveX,
  int waveY,
  int waveWidth,
  int waveHeight,
  float frequency,
  float minimumFrequency,
  float maximumFrequency,
  float waveLevel,
  String label
) {
  stroke(160);
  noFill();

  rect(
    waveX,
    waveY,
    waveWidth,
    waveHeight
  );

  fill(0);
  noStroke();
  textSize(14);

  text(
    label,
    waveX + 10,
    waveY + 20
  );

  float centreY =
    waveY +
    waveHeight * 0.56;

  stroke(210);

  line(
    waveX,
    centreY,
    waveX + waveWidth,
    centreY
  );

  stroke(200, 0, 0);
  noFill();

  float cycles = map(
    frequency,
    minimumFrequency,
    maximumFrequency,
    1,
    20
  );

  beginShape();

  for (int localX = 0;
       localX < waveWidth;
       localX++) {

    float phase = map(
      localX,
      0,
      waveWidth,
      0,
      TWO_PI * cycles
    );

    float waveValue =
      sin(phase);

    float y =
      centreY +
      waveValue * waveLevel *
      waveHeight *
      0.28;

    vertex(
      waveX + localX,
      y
    );
  }

  endShape();
}

// --------------------------------------------------
// Controls display
// --------------------------------------------------

void drawControls() {
  fill(0);
  textSize(14);

  text(
    "1 / 2 = select sensor",
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

void drawCalibrationMessage() {
  if (!calibratingRelaxed &&
      !calibratingStretched) {
    return;
  }

  fill(0, 32, 96);
  textSize(18);

  String positionName =
    calibratingRelaxed ?
    "RELAXED" :
    "MAXIMUM STRETCH";

  text(
    "Hold sensor A" +
    calibrationSensor +
    " at " +
    positionName +
    "...",
    20,
    690
  );
}
