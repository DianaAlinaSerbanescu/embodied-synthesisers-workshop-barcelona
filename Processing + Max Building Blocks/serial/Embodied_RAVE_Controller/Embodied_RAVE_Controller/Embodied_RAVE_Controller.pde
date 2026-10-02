/* Dual sensor RAVE controller. A0/A1 -> latent_bias_0/1.
 * R/S calibrate, 1/2 select, D enable, M hold both, Q hold A0.
 * Processing controls parameters; audio remains in REAPER. */

import processing.serial.*;
import java.io.File;
import oscP5.*;
import netP5.*;
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

OscP5 osc;
NetAddress maxAddress;
String maxHost = "127.0.0.1";
int maxPort = 12002;
int feedbackPort = 12003;
boolean engineArmed = false;
volatile int lastMaxFeedback = -10000;
float[] latent = {0, 0};
float[] sentLatent = {0, 0};
boolean[] tracking = {false, false};
boolean[] acknowledged = {false, false};

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

  osc = new OscP5(this, feedbackPort);
  maxAddress = new NetAddress(maxHost, maxPort);
  frameRate(60);
}

// --------------------------------------------------
// Main loop
// --------------------------------------------------

synchronized void draw() {
  background(255);

  drainSensorPackets();
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
  text("A0: latent bias 0. A1: latent bias 1. Audio runs in REAPER.", 20, 665);
  text("D = " + (engineArmed ? "hold controls" : "enable controls"), 800, 590);
  text(maxIsConnected() ? "MAX LINK: RECEIVING" : "MAX LINK: WAITING", 800, 614);
  text("REAPER: no return feedback", 800, 638);
  drawCalibrationMessage();
  popMatrix();
}

// --------------------------------------------------
// Normalized stretch for latent parameters
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
  if (!message.checkAddrPattern("/ravebridge/status") || !message.typetag().matches("[if]{4}")) return;
  float[] n = new float[4];
  for (int i=0; i<4; i++) {
    n[i]=oscNumber(message,i);
    if (Float.isNaN(n[i]) || Float.isInfinite(n[i]) || n[i]<0 || n[i]>1) return;
  }
  if ((n[2]!=0 && n[2]!=1) || (n[3]!=0 && n[3]!=1)) return;
  lastMaxFeedback=millis();
  for (int i=0;i<2;i++) { sentLatent[i]=n[i];acknowledged[i]=n[i+2]==1; }
}

void sendControllerState() {
  if (osc==null) return;
  OscMessage message=new OscMessage("/ravebridge/state");
  message.add(latent[0]);message.add(latent[1]);
  message.add(tracking[0]?1:0);message.add(tracking[1]?1:0);
  osc.send(message,maxAddress);
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

boolean latentReady(int i) {
  SensorCalibration c=calibration[i];
  return c.relaxedReady && c.stretchedReady && c.mode==0 && abs(c.stretched-c.relaxed)>=10;
}

void updateSound() {
  boolean fresh=sensorDataReceived && millis()-lastSensorSampleTime<=sensorTimeoutMs;
  for (int i=0;i<2;i++) {
    tracking[i]=engineArmed && !mutedAll && !(i==0 && muted0) && fresh && latentReady(i);
    if(tracking[i]) latent[i]=i==0?normalized0:normalized1;
  }
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
    println(engineArmed ? "Latent controls enabled." : "Latent controls held.");
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
      "Parameter updates held." :
      "Parameter updates enabled."
    );
  }

  if (key == 'q' || key == 'Q') {
    muted0 = !muted0;

    println(
      muted0 ?
      "Parameter updates held." :
      "Parameter updates enabled."
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
    "Embodied Stretch Synth — RAVE Latent Space",
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

  text("Latent range: 0.000 to 1.000", panelX + 15, panelY + panelHeight - 35);

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
    "LATENT " + sensorIndex + ": " + nf(latent[sensorIndex], 0, 3),
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
    tracking[sensorIndex] ? "CONTROL: TRACKING" : "CONTROL: HELD",
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

void drawWaveform0() { drawLatent(0,20); }
void drawWaveform1() { drawLatent(1,580); }
void drawLatent(int i,int x) {
  int y=380,w=500,h=170;
  stroke(160);strokeWeight(1);noFill();rect(x,y,w,h);
  noStroke();fill(0);textSize(14);
  text("A"+i+" / RAVE LATENT BIAS "+i,x+12,y+22);
  textSize(12);text("/rave/latent_bias_"+i,x+12,y+44);
  fill(0,32,96);textSize(20);text(nf(latent[i],0,3),x+12,y+76);
  stroke(210);line(x+15,y+105,x+w-15,y+105);
  stroke(200,0,0);strokeWeight(3);
  float marker=lerp(x+15,x+w-15,latent[i]);line(marker,y+95,marker,y+115);
  strokeWeight(1);noStroke();fill(0);textSize(12);
  text("0 / relaxed",x+15,y+136);text("1 / stretched",x+w-90,y+136);
  text(acknowledged[i]?"Last target sent by Max: "+nf(sentLatent[i],0,3):"No sensor target sent yet",x+15,y+157);
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
    "M = hold both controls",
    580,
    590
  );

  text(
    "Q = hold A0",
    580,
    614
  );

  text(
    "Relaxed = latent minimum",
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
