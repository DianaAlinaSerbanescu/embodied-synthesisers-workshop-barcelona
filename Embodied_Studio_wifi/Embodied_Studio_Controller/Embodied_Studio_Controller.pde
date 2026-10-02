/* Embodied Studio — unified controller.

  By Diana Alina Serbanescu

 * Sensor parser and calibration adapted from the selected workshop building blocks.
 * Audio is in Max; RAVE runs in REAPER. Ports 12100/12101 (controller), 8000 (REAPER).
 * Input is isolated in serialEvent/drainSensorPackets for a future Wi-Fi adapter.
 */

import java.io.File;
import oscP5.*;
import netP5.*;


OscP5 osc;
NetAddress maxAddress;
String maxHost="127.0.0.1";
int maxPort=12100, feedbackPort=12101;
boolean engineArmed=false;
boolean calibrationScreen=true, performancePaused=false;
String settingsStatus="No saved calibration yet";
volatile int lastMaxFeedback=-10000;
int sessionId=int(System.currentTimeMillis()%1000000000L), sequence=0;
int ackSequence=-1, remoteMode=-1;
boolean modeReady=false;
int mode=0;
String[] modeNames={"Sine", "Notes", "Noise / cutoff", "Dual formants", "Formants + pitch", "Coloratura", "Explore / dissolve", "Stretch time", "RAVE", "REAPER volume"};
String[][] labels={{"FREQUENCY", "FREQUENCY"}, {"NOTE / FREQUENCY", "NOTE / FREQUENCY"}, {"CUTOFF", "CUTOFF"}, {"VOWEL / F1", "VOWEL / F1"}, {"VOWEL / F1", "PITCH"}, {"VOWEL / F1", "PITCH"}, {"POSITION", "FRAGMENT"}, {"SPEED", "PITCH SHIFT"}, {"LATENT BIAS 0", "LATENT BIAS 1"}, {"TRACK 1 VOLUME", "TRACK 2 VOLUME"}};
String[] descriptions={"Two sine voices. Relax each sensor for silence.", "Five pentatonic notes per sensor. N chooses a new range for the selected sensor.", "White noise through two low-pass filters. Stretch controls brightness.", "Two independent vowels. A new timbre on each physical gesture.", "A0 shapes and gates the voice. A1 controls pitch (selected engine: 80–89 Hz).", "A0 shapes and gates the voice. A1 spans C4–F6.", "A0 explores the recording. A1 dissolves it into smaller fragments.", "A0 stretches time; relax to pause. A1 shifts pitch. T restarts.", "Stretch either sensor to sound; release both to fade out and return HOME.", "A0: REAPER track 1 volume. A1: track 2 volume. Relaxed -60 dB; stretched 0 dB."};
float[][] held={{0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, 0}, {0, .5}, {0, 0}, {0, 0}};
float[][] feedback=new float[10][8];
boolean[] feedbackReceived=new boolean[10];
float[] gains={0, 0};
boolean[] tracking={false, false};
int[][] gestures=new int[10][2];
boolean muted1=false;
boolean[][] modeMutes=new boolean[10][3];
int[] noteStart={0, 5};
int[] notePool={48, 50, 52, 55, 57, 60, 62, 64, 67, 69, 72, 74, 76, 79, 81};
int[] noteStep={-1, -1};
class Recording {
  String path="", name="No recording selected", error="";
  int id=0, remoteId=0, state=0, waveId=0, channels=0, lastLoad=-10000, restart=0;
  float duration=0, position=0, param=0, pitch=0;
  float[] wave=new float[0];
}
Recording[] recordings={new Recording(), new Recording()};
boolean filePickerOpen=false;
int filePickerMode=-1;
String notice="Calibrate once; your settings are remembered.";

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
  size(1100, 820); // Resizable workshop window; calibration survives mode changes.
  pixelDensity(1);
  surface.setResizable(true);

  setupWiFiReceiver();

  osc = new OscP5(this, feedbackPort);
  maxAddress = new NetAddress(maxHost, maxPort);
  initializePerformance();
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
  float zoom=min(width/1100.0, height/820.0);
  pushMatrix();
  translate((width-1100*zoom)/2, (height-820*zoom)/2);
  scale(zoom);
  if (calibrationScreen)drawCalibration();
  else drawStudio();
  textSize(11);
  text(udpError.length() > 0 ? udpError :
    "UDP " + UDP_PORT + " | ESP32: " + senderAddress + " | packets: " + receivedPackets +
    " | missing: " + missingPackets + " | invalid: " + invalidPackets, 20, 710);
  popMatrix();
}

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

synchronized void oscEvent(OscMessage m) {
  String address=m.addrPattern();
  if (address.equals("/suite/status") && m.typetag().matches("[if]{4}")) {
    float[] n=readNumbers(m, 4);
    if (n==null || n[0]!=sessionId || n[1]<ackSequence || n[2]<0 || n[2]>9 || (n[3]!=0&&n[3]!=1))return;
    ackSequence=round(n[1]);
    remoteMode=round(n[2]);
    modeReady=remoteMode==mode&&n[3]==1;
    lastMaxFeedback=millis();
    return;
  }
  int fmode=address.equals("/basic/feedback")?-2:address.equals("/formants/feedback")?3:address.equals("/formants/pitch/feedback")?4:address.equals("/formants/coloratura/feedback")?5:address.equals("/ravebridge/status")?8:address.equals("/volume/status")?9:-1;
  if (fmode!=-1) {
    int count=fmode==-2?3:fmode==3?6:4;
    float[] n=readNumbers(m, count);
    if (n==null)return;
    int start=0;
    if (fmode==-2) {
      if (n[0]<0||n[0]>2||n[0]!=floor(n[0]))return;
      fmode=round(n[0]);
      start=1;
    }
    for (int i=start; i<n.length; i++)feedback[fmode][i-start]=n[i];
    feedbackReceived[fmode]=true;
    return;
  }
  int idx=address.startsWith("/granular/")?0:address.startsWith("/stretch/")?1:-1;
  if (idx<0)return;
  Recording r=recordings[idx];
  if (address.endsWith("/status")) {
    float[] n=readNumbers(m, idx==0?6:7);
    if (n==null||n[0]!=r.id||n[1]<-2||n[1]>2||n[2]<0||n[3]<0)return;
    r.remoteId=round(n[0]);
    r.state=round(n[1]);
    r.duration=n[2];
    r.position=n[3];
    r.param=n[4];
    r.channels=round(n[n.length-1]);
    if (idx==1)r.pitch=n[5];
  } else if (address.endsWith("/wave")) {
    float[] n=readNumbers(m, 257);
    if (n==null||r.id==0||n[0]!=r.id)return;
    for (int i=1; i<n.length; i++)if (n[i]<0||n[i]>1)return;
    r.wave=new float[256];
    arrayCopy(n, 1, r.wave, 0, 256);
    r.waveId=r.id;
  }
}
float[] readNumbers(OscMessage m, int count) {
  if (!m.typetag().matches("[if]{"+count+"}"))return null;
  float[] n=new float[count];
  for (int i=0; i<count; i++) {
    n[i]=oscNumber(m, i);
    if (Float.isNaN(n[i])||Float.isInfinite(n[i]))return null;
  }
  return n;
}
void sendControllerState() {
  if (osc==null)return;
  Recording r=isSampleMode()?recordings[mode-6]:null;
  OscMessage m=new OscMessage("/suite/state");
  m.add(sessionId);
  m.add(++sequence);
  m.add(mode);
  m.add(held[mode][0]);
  m.add(held[mode][1]);
  m.add(gains[0]);
  m.add(gains[1]);
  m.add(engineArmed?1:0);
  m.add(gestures[mode][0]);
  m.add(gestures[mode][1]);
  m.add(r==null?0:r.id);
  m.add(r==null?0:r.waveId);
  m.add(r==null?0:r.restart);
  m.add(tracking[0]?1:0);
  m.add(tracking[1]?1:0);
  m.add(noteStart[0]);
  m.add(noteStart[1]);
  osc.send(m, maxAddress);
  for (int i=0; i<2; i++) {
    Recording sample=recordings[i];
    if (sample.id>0&&millis()-sample.lastLoad>=1000) {
      // Idempotent requests also recover buffers after Max restarts.
      OscMessage load=new OscMessage("/suite/load");
      load.add(sessionId);
      load.add(i+6);
      load.add(sample.id);
      load.add(sample.path);
      osc.send(load, maxAddress);
      sample.lastLoad=millis();
    }
  }
}
synchronized void audioFileSelected(File file) {
  int selectedMode=filePickerMode;
  filePickerOpen=false;
  filePickerMode=-1;
  if (file==null||selectedMode<6||selectedMode>7)return;
  Recording r=recordings[selectedMode-6];
  String name=file.getName().toLowerCase();
  if (!file.isFile()||!(name.endsWith(".wav")||name.endsWith(".aif")||name.endsWith(".aiff"))) {
    r.error="Choose a WAV or AIFF file";
    return;
  }
  setRecording(selectedMode-6, file);
  saveStudioSettings();
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

boolean isSampleMode() {
  return mode==6||mode==7;
}
boolean dualVoiceMode() {
  return mode<=3;
}
float activePosition(int i, float n) {
  float span=abs(calibration[i].stretched-calibration[i].relaxed);
  float threshold=span<10?.05:min(.99, triggerOnCounts(i)/span);
  return constrain((n-threshold)/(1-threshold), 0, 1);
}
void updateSound() {
  int now=millis();
  float dt=lastSoundTime==0?16:constrain(now-lastSoundTime, 0, 100);
  lastSoundTime=now;
  engineArmed=!calibrationScreen&&!performancePaused&&calibrationComplete()&&maxIsConnected()&&modeReady;
  boolean fresh=sensorDataReceived&&now-lastSensorSampleTime<=sensorTimeoutMs;
  for (int i=0; i<2; i++) {
    float n=i==0?normalized0:normalized1, value=i==0?smoothedValue0:smoothedValue1;
    boolean before=triggerActive[i];
    boolean active=sensorIsAudible(i, value, fresh, now);
    if (active&&!before)gestures[mode][i]++;
    boolean muted=mutedAll||(i==0?muted0:muted1);
    tracking[i]=engineArmed&&!muted&&fresh&&latentReady(i);
    // RAVE alone uses the existing confirmed trigger and dead zone.
    // A held control retains its excursion while sounding; release still returns HOME.
    if (mode==8) {
      if (tracking[i]) held[8][i]=active?activePosition(i, n):0;
      continue;
    }
    // Retain the last value during calibration, disconnect or parameter hold.
    if (mode>=8 ? tracking[i] : fresh&&latentReady(i)&&!muted)
      held[mode][i]=(isSampleMode()&&i==0)?activePosition(i, n):n;
    boolean enabled=engineArmed&&!muted&&active&&(i==0||dualVoiceMode());
    gains[i]=fadeAmplitude(gains[i], enabled?.15:0, dt);
  }
  if (mode==8) {
    // Binary gate request; Max performs the timed audio fade. Either textile opens it.
    // Holds freeze latent excursions, not physical activation or release detection.
    gains[0]=engineArmed&&fresh&&(triggerActive[0]||triggerActive[1])?.15:0;
    gains[1]=0;
  }
  sendControllerState();
}
void randomizeNotes(int i) {
  noteStart[i]=(noteStart[i]+1+int(random(10)))%11;
  noteStep[i]=-1;
}
float noteHz(int i, float n) {
  float position=n*4;
  int step=noteStep[i];
  if (step<0)step=round(position);
  while (step<4&&position>step+.60)step++;
  while (step>0&&position<step-.60)step--;
  noteStep[i]=step;
  return 440*pow(2, (notePool[noteStart[i]+step]-69)/12.0);
}
void selectMode(int next) {
  if (next<0||next>=modeNames.length)return;
  if (calibrationScreen) {
    if (!calibrationComplete()) {
      notice="Finish calibration first.";
      return;
    }
    calibrationScreen=false;
  }
  if (next==mode)return;
  modeMutes[mode][0]=mutedAll;
  modeMutes[mode][1]=muted0;
  modeMutes[mode][2]=muted1;
  engineArmed=false;
  mode=next;
  modeReady=false;
  mutedAll=modeMutes[mode][0];
  muted0=modeMutes[mode][1];
  muted1=modeMutes[mode][2];
  gains[0]=gains[1]=0;
  for (int i=0; i<2; i++) {
    triggerActive[i]=false;
    activationSince[i]=-1;
  }
  notice="Selected "+modeNames[mode]+". Ready automatically after switching.";
  saveStudioSettings();
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

boolean acceptWiFiPacket(String message, String peer) {
  try {
    String[] v=message.trim().split(",", -1);
    if (v.length!=7||!v[0].equals("ES1")) {
      invalidPackets++;
      return false;
    }
    long boot=Long.parseLong(v[1]), seq=Long.parseLong(v[2]);
    if (boot<0||boot>0xffffffffL||seq<0||seq>0xffffffffL) {
      invalidPackets++;
      return false;
    }
    float[] data=new float[4];
    for (int i=0; i<4; i++) {
      data[i]=Float.parseFloat(v[i+3]);
      if (!validADCValue(data[i])) {
        invalidPackets++;
        return false;
      }
    }
    if (wifiFresh()&&!peer.equals(senderAddress)) {
      invalidPackets++;
      return false;
    }
    if (boot==lastBoot&&peer.equals(senderAddress)) {
      long step=(seq-lastSequence)&0xffffffffL;
      if (step==0||step>=0x80000000L) {
        outOfOrderPackets++;
        return false;
      }
      if (step>1)missingPackets+=step-1;
    }
    lastBoot=boot;
    lastSequence=seq;
    senderAddress=peer;
    rawValue0=data[0];
    smoothedValue0=data[1];
    rawValue1=data[2];
    smoothedValue1=data[3];
    sensorDataReceived = true;
    lastWiFiPacket = millis();
    lastSensorSampleTime = lastWiFiPacket; // Keeps the existing audio freshness check current.
    receivedPackets++;
    wifiConnected = true;
    updateObservedRanges();
    collectCalibrationSample(lastWiFiPacket);
    return true;
  }
  catch(Exception e) {
    invalidPackets++;
    return false;
  }
}

public void dispose() {
  try {
    if (udpReceiver!=null)udpReceiver.close();
  }
  catch(Exception e) {
  }
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
  if (key=='k'||key=='K') {
    if (calibrationScreen)finishCalibration();
    else openCalibration();
    return;
  }
  if (calibrationScreen) {
    if (key=='1')selectedSensor=0;
    if (key=='2')selectedSensor=1;
    if (key=='r'||key=='R')startRelaxedCalibration(selectedSensor);
    if (key=='s'||key=='S')startStretchedCalibration(selectedSensor);
    if (key=='c'||key=='C')clearCalibration(selectedSensor);
    if (key==ENTER||key==RETURN)finishCalibration();
    return;
  }

  if (key=='[')selectMode((mode+modeNames.length-1)%modeNames.length);
  if (key==']')selectMode((mode+1)%modeNames.length);
  if (key=='1')selectedSensor=0;
  if (key=='2')selectedSensor=1;
  if (key=='r'||key=='R'||key=='s'||key=='S'||key=='c'||key=='C') {
    openCalibration();
    return;
  }
  if (key=='x'||key=='X')resetObservedRange(selectedSensor);
  if (key==' '||key=='d'||key=='D') {
    performancePaused=!performancePaused;
    notice=performancePaused?"Performance paused / REAPER controls held":"Performance resumes automatically";
  }
  if (key=='m'||key=='M')mutedAll=!mutedAll;
  if (key=='q'||key=='Q')muted0=!muted0;
  if (key=='w'||key=='W')muted1=!muted1;
  if ((key=='n'||key=='N')&&mode==1)randomizeNotes(selectedSensor);
  if ((key=='t'||key=='T')&&mode==7)recordings[1].restart++;
  if ((key=='l'||key=='L')&&isSampleMode()&&!filePickerOpen) {
    Recording r=recordings[mode-6];
    if (r.state==1&&maxIsConnected()) {
      notice="Wait for the current recording to finish loading.";
      return;
    }
    filePickerOpen=true;
    filePickerMode=mode;
    selectInput("Choose a WAV or AIFF recording", "audioFileSelected");
  }
}
synchronized void mousePressed() {
  float zoom=min(width/1100.0, height/820.0);
  float x=(mouseX-(width-1100*zoom)/2)/zoom, y=(mouseY-(height-820*zoom)/2)/zoom;
  if (calibrationScreen) {
    for (int i=0; i<2; i++) {
      int left=i==0?20:580;
      if (y>=310&&y<=358) {
        if (x>=left+18&&x<=left+240) {
          selectedSensor=i;
          startRelaxedCalibration(i);
        } else if (x>=left+258&&x<=left+480) {
          selectedSensor=i;
          startStretchedCalibration(i);
        }
      }
    }
    if (x>=20&&x<=350&&y>=655&&y<=710)finishCalibration();
    return;
  }
  if (x>=860&&x<=1080&&y>=8&&y<=38) {
    openCalibration();
    return;
  }
  if (x>=850&&x<=1080&&y>=687&&y<=714) {
    performancePaused=!performancePaused;
    return;
  }
  for (int i=0; i<modeNames.length; i++)if (x>=20+i*106&&x<=122+i*106&&y>=72&&y<=113)selectMode(i);
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
  if (!calibrationScreen)return;
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
      notice="A"+i+" capture failed: too few fresh samples. Hold steady and retry.";
      println(notice);
      c.cancelCapture();
      continue;
    }
    float measured = c.sum / c.samples;
    float candidateRelaxed = c.mode == 1 ? measured : c.relaxed;
    float candidateStretched = c.mode == 2 ? measured : c.stretched;
    boolean bothReady = (c.mode == 1 || c.relaxedReady) && (c.mode == 2 || c.stretchedReady);
    if (bothReady && abs(candidateStretched - candidateRelaxed) < 10) {
      notice="A"+i+" capture rejected: positions too close. Previous calibration retained.";
      println(notice);
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
    saveStudioSettings();
    notice="A"+i+" capture complete. "+settingsStatus;
  }
}

synchronized void clearCalibration(int sensorIndex) {
  calibration[sensorIndex].reset();
  activationSince[sensorIndex] = -1;
  triggerActive[sensorIndex] = false;
  if (sensorIndex == 0) stretchSound0 = false;
  saveStudioSettings();
  notice="Calibration cleared for A"+sensorIndex+". Capture both positions again.";
}

// --------------------------------------------------
// Header
// --------------------------------------------------

void drawStudio() {
  fill(0, 32, 96);
  textSize(22);
  text("Embodied Studio", 20, 30);
  calibrationButton(860, 8, 220, 30, "Calibration / K", false);
  fill(0);
  textSize(13);
  text("WiFi: "+(sensorDataReceived&&millis()-lastSensorSampleTime<=sensorTimeoutMs?"RECEIVING":wifiConnected?"WAITING FOR DATA":"DISCONNECTED"), 20, 53);
  text("MAX: "+(maxIsConnected()?(modeReady?"READY":"SWITCHING"):"WAITING"), 300, 53);
  text("Selected sensor: A"+selectedSensor+"    Calibration shared across all modes", 520, 53);
  String[] tabs={"Sine", "Notes", "Noise / cutoff", "Dual formants", "Formants + pitch", "Coloratura", "Explore / dissolve", "Stretch time", "RAVE", "REAPER volume"};
  for (int i=0; i<modeNames.length; i++) {
    stroke(i==mode?color(0, 32, 96):color(180));
    strokeWeight(i==mode?2:1);
    fill(i==mode?color(0, 32, 96):color(255));
    rect(20+i*106, 72, 102, 41);
    fill(i==mode?255:0);
    textSize(10);
    textAlign(CENTER, CENTER);
    text(tabs[i], 71+i*106, 92);
  }
  textAlign(LEFT, BASELINE);
  strokeWeight(1);
  drawPanel(0, 20);
  drawPanel(1, 580);
  if (isSampleMode()) {
    drawRecording();
    drawParameter(1, 580);
  } else {
    drawParameter(0, 20);
    drawParameter(1, 580);
  }
  noStroke();
  fill(0, 32, 96);
  textSize(13);
  text(descriptions[mode], 20, 679);
  fill(0);
  textSize(13);
  text("1 / 2 = select sensor", 20, 707);
  text("K = calibration (saved automatically)", 20, 730);
  text("X = reset observed range", 20, 753);
  text("[ / ] or click a tab = switch mode", 420, 707);
  text(mode>=8?"M = hold both   Q / W = hold A0 / A1":dualVoiceMode()?"M = mute both   Q / W = mute A0 / A1":"M / Q = mute voice   W = hold A1", 420, 730);
  text(mode==1?"N = new notes for selected sensor":isSampleMode()?"L = load WAV / AIFF"+(mode==7?"   T = restart":""):"Calibration is retained when switching", 420, 753);
  calibrationButton(850, 687, 230, 28, performancePaused?"Resume / Space":"Pause / Space", performancePaused);
  text(mode==8?(gains[0]>0?"RAVE: SOUND ON":"RAVE: FADING / SILENT"):"REAPER audio: external", 850, 730);
  fill(0);
  textSize(12);
  text(shortLabel(notice, 145), 20, 784);
  for (int i=0; i<2; i++)if (calibration[i].mode!=0) {
    fill(200, 0, 0);
    text("Hold A"+i+" "+(calibration[i].mode==1?"RELAXED":"STRETCHED")+" for calibration", i==0?20:580, 810);
  }
}
void drawPanel(int i, int x) {
  int y=137, w=500, h=286;
  stroke(i==selectedSensor?color(0, 32, 96):color(160));
  strokeWeight(i==selectedSensor?2:1);
  noFill();
  rect(x, y, w, h);
  strokeWeight(1);
  noStroke();
  fill(0, 32, 96);
  textSize(18);
  text("SENSOR A"+i, x+15, y+28);
  SensorCalibration c=calibration[i];
  float raw=i==0?rawValue0:rawValue1, sm=i==0?smoothedValue0:smoothedValue1, n=i==0?normalized0:normalized1;
  float low=i==0?observedMin0:observedMin1, high=i==0?observedMax0:observedMax1;
  fill(0);
  textSize(14);
  text("RAW: "+nf(raw, 0, 1), x+15, y+59);
  text("SMOOTH: "+nf(sm, 0, 2), x+15, y+83);
  text("OBSERVED MIN: "+observedLabel(low), x+15, y+107);
  text("OBSERVED MAX: "+observedLabel(high), x+15, y+131);
  text("RELAXED: "+(c.relaxedReady?nf(c.relaxed, 0, 2):"SET R"), x+15, y+155);
  text("STRETCHED: "+(c.stretchedReady?nf(c.stretched, 0, 2):"SET S"), x+15, y+179);
  text("NORMALIZED: "+nf(n, 0, 3), x+265, y+59);
  fill(0, 32, 96);
  text(labels[mode][i], x+265, y+88);
  textSize(19);
  text(parameterLabel(i), x+265, y+116);
  textSize(13);
  text("STATUS: "+(i==0?sensorStatus0:sensorStatus1), x+265, y+147);
  boolean muted=mutedAll||(i==0?muted0:muted1);
  String status=muted?"HELD / MUTED":!engineArmed?"DISABLED":!latentReady(i)?"SET R / S":mode>=8||i==1&&!dualVoiceMode()?"TRACKING":gains[i]>0?"ACTIVE":"RELAXED / SILENT";
  text("CONTROL: "+status, x+265, y+171);
  fill(0);
  textSize(12);
  text(mode==9?"Full calibrated range → track level -60 to 0 dB":mode==8?"Stretch → excursion from HOME; release → return":i==0||dualVoiceMode()?"Relax to silence / dead zone with smooth fade":"Independent parameter / no sound gate", x+15, y+229);
  stroke(210);
  line(x+15, y+254, x+w-15, y+254);
  stroke(200, 0, 0);
  strokeWeight(3);
  float pos=lerp(x+15, x+w-15, n);
  line(pos, y+246, pos, y+262);
  strokeWeight(1);
}
String observedLabel(float v) {
  return v==Float.MAX_VALUE||v==-Float.MAX_VALUE?"waiting":nf(v, 0, 2);
}
String shortLabel(String s, int maxLength) {
  return s.length()<=maxLength?s:s.substring(0, maxLength-3)+"...";
}
float frequencyFor(int i) {
  float n=held[mode][i];
  if (mode==0)return (i==0?100:180)*pow(i==0?7:1100.0/180, n);
  if (mode==1)return noteHz(i, n);
  if (mode==2)return 40*pow(200, n);
  return 0;
}
String parameterLabel(int i) {
  float n=held[mode][i];
  if (mode<=2)return nf(frequencyFor(i), 0, 1)+" Hz";
  if (mode==3||i==0&&(mode==4||mode==5))return vowelName(n);
  if (mode==4)return nf(80*pow(400.0/360, n), 0, 1)+" Hz";
  if (mode==5)return nf(261.625565*pow(1396.912926/261.625565, n), 0, 1)+" Hz";
  if (mode==6)return i==0?nf(n*100, 0, 1)+" %":nf(250*pow(20.0/250, n), 0, 1)+" ms";
  if (mode==7)return i==0?nf(.125*pow(16, n), 0, 2)+"x":nf(-12+24*n, 0, 1)+" st";
  if (mode==9)return nf(-60+60*n, 0, 1)+" dB";
  if (mode==8)return feedbackReceived[8]?nf(feedback[8][i], 0, 4):"HOME / waiting";
  return nf(n, 0, 3);
}
String vowelName(float n) {
  String[] names={"U", "O", "A", "E", "I"};
  int k=min(3, int(n*4));
  return names[k]+" → "+names[k+1]+"   "+nf(n, 0, 2);
}
void chartFrame(int x, String title) {
  stroke(160);
  noFill();
  rect(x, 450, 500, 205);
  noStroke();
  fill(0);
  textSize(14);
  text(title, x+12, 473);
}
void drawParameter(int i, int x) {
  chartFrame(x, labels[mode][i]+" / A"+i);
  noStroke();
  fill(0, 32, 96);
  textSize(19);
  text(parameterLabel(i), x+15, 503);
  float n=held[mode][i];
  if (mode<=2) {
    stroke(200, 0, 0);
    noFill();
    beginShape();
    float frequency=frequencyFor(i);
    for (int j=0; j<=460; j++) {
      float v;
      if (mode==2) {
        float f=40*pow(200, j/460.0);
        v=1/sqrt(1+pow(f/frequency, 4));
        vertex(x+20+j, 622-v*93);
      } else {
        float phase=TWO_PI*j/460.0*(2+frequency/180);
        v=sin(phase);
        if (mode==1)v=(v+.5*sin(2*phase)+.3*sin(3*phase))/1.8;
        vertex(x+20+j, 579-v*43);
      }
    }
    endShape();
    noStroke();
    fill(0);
    textSize(11);
    text(mode==2?"Filter response illustration / 40–8000 Hz":"Waveform illustration / target frequency", x+15, 641);
  } else if (mode==3||i==0&&(mode==4||mode==5)) {
    int offset=mode==3?i*3:0;
    float[] values={300, 870, 2240};
    if (feedbackReceived[mode])for (int j=0; j<3; j++)values[j]=feedback[mode][offset+j];
    for (int j=0; j<3; j++) {
      float px=x+20+constrain(values[j]/5000, 0, 1)*460;
      stroke(200, 0, 0);
      strokeWeight(3);
      line(px, 615, px, 538+j*12);
      noStroke();
      fill(0, 32, 96);
      textSize(11);
      text("F"+(j+1)+" "+nf(values[j], 0, 0), x+15+j*155, 636);
    }
    strokeWeight(1);
    fill(0);
    textSize(11);
    text(feedbackReceived[mode]?"Last formants reported by Max":"Enable to receive formants from Max", x+15, 524);
  } else {
    stroke(210);
    line(x+20, 568, x+480, 568);
    stroke(200, 0, 0);
    strokeWeight(3);
    float px=lerp(x+20, x+480, n);
    line(px, 550, px, 586);
    strokeWeight(1);
    noStroke();
    fill(0);
    textSize(12);
    text(mode==9?"-60 dB / relaxed":mode==8?"HOME / relaxed":"Relaxed", x+20, 613);
    text(mode==9?"0 dB / stretched":mode==8?"Excursion":"Stretched", x+400, 613);
    text(mode==9?"/track/"+(i+1)+"/volume/db":mode==8?"/rave/latent_bias_"+i:"Calibrated sensor range", x+20, 638);
  }
}
void drawRecording() {
  Recording r=recordings[mode-6];
  chartFrame(20, shortLabel(r.name, 55));
  fill(0);
  textSize(12);
  String state=r.error.length()>0?r.error:r.id==0?"Press L to load WAV / AIFF":!maxIsConnected()?"Waiting for Max":r.state==1?"Loading waveform...":r.state<0?"Load failed: press L to retry":nf(r.duration/1000, 0, 2)+" s / "+(r.channels==1?"mono":"stereo");
  text(state, 32, 496);
  stroke(210);
  line(35, 564, 505, 564);
  if (r.wave.length==256) {
    stroke(200, 0, 0);
    for (int j=0; j<256; j++) {
      float x=35+j*470.0/255;
      line(x, 564-r.wave[j]*47, x, 564+r.wave[j]*47);
    }
  }
  if (r.duration>0) {
    float x=35+constrain(r.position/r.duration, 0, 1)*470;
    stroke(0, 32, 96);
    strokeWeight(2);
    line(x, 515, x, 615);
    strokeWeight(1);
  }
  noStroke();
  fill(0);
  textSize(12);
  text(mode==6?"Grain start / "+parameterLabel(0):"Playback position / speed "+parameterLabel(0), 32, 639);
}

// Persistent calibration and performance defaults. Kept beside the sketch for portability.
File studioSettingsFile() {
  return new File(sketchPath("studio_settings.json"));
}
File defaultRecordingFile() {
  return new File(sketchPath("../Demo_Texture.wav"));
}
boolean calibrationComplete() {
  return latentReady(0)&&latentReady(1);
}
boolean endpointValid(float v) {
  return !Float.isNaN(v)&&!Float.isInfinite(v)&&v>=0&&v<=4095;
}
void initializePerformance() {
  loadStudioSettings();
  for (int i=0; i<2; i++) {
    File chosen=recordings[i].path.length()>0?new File(recordings[i].path):null;
    if (chosen==null||!chosen.isFile())chosen=defaultRecordingFile();
    if (chosen.isFile())setRecording(i, chosen);
    else recordings[i].error="Default recording missing. Press L to choose audio.";
  }
  calibrationScreen=!calibrationComplete();
  notice=calibrationScreen?"Calibrate both sensors here. Valid calibration is saved automatically.":"Saved calibration restored. Instruments enable automatically when connected.";
}
void setRecording(int i, File file) {
  Recording r=recordings[i];
  r.path=file.getAbsolutePath();
  r.name=file.getName();
  r.id=r.id==0?int(System.currentTimeMillis()%10000000L)+i+1:r.id+1;
  r.state=1;
  r.waveId=0;
  r.wave=new float[0];
  r.duration=0;
  r.position=0;
  r.error="";
  r.lastLoad=-10000;
}
void loadStudioSettings() {
  File f=studioSettingsFile();
  if (!f.isFile()) {
    settingsStatus="No saved calibration yet";
    return;
  }
  try {
    JSONObject root=JSONObject.parse(new String(java.nio.file.Files.readAllBytes(f.toPath()), java.nio.charset.StandardCharsets.UTF_8));
    if (root==null||root.getInt("version")!=1)throw new RuntimeException("Unsupported settings");
    JSONArray sensors=root.getJSONArray("sensors");
    if (sensors==null||sensors.size()!=2)throw new RuntimeException("Missing sensors");
    float[] relaxed=new float[2], stretched=new float[2];
    boolean[] rr=new boolean[2], sr=new boolean[2];
    for (int i=0; i<2; i++) {
      JSONObject sensor=sensors.getJSONObject(i);
      relaxed[i]=sensor.getFloat("relaxed");
      stretched[i]=sensor.getFloat("stretched");
      rr[i]=sensor.getBoolean("relaxedReady");
      sr[i]=sensor.getBoolean("stretchedReady");
      if (!endpointValid(relaxed[i])||!endpointValid(stretched[i])||(rr[i]&&sr[i]&&abs(stretched[i]-relaxed[i])<10))throw new RuntimeException("Invalid calibration");
    }
    int savedMode=root.getInt("mode", 0);
    if (savedMode<0||savedMode>=modeNames.length)savedMode=0;
    JSONArray paths=root.getJSONArray("recordings");
    String[] selected={"", ""};
    if (paths!=null&&paths.size()==2)for (int i=0; i<2; i++)selected[i]=paths.getString(i);
    for (int i=0; i<2; i++) {
      calibration[i].relaxed=relaxed[i];
      calibration[i].stretched=stretched[i];
      calibration[i].relaxedReady=rr[i];
      calibration[i].stretchedReady=sr[i];
      recordings[i].path=selected[i];
    }
    mode=savedMode;
    settingsStatus="Saved calibration loaded";
  }
  catch(Exception e) {
    for (int i=0; i<2; i++)calibration[i].reset();
    settingsStatus="Saved settings could not be read. Recalibrate to replace them.";
    println(settingsStatus+" "+e);
  }
}
void saveStudioSettings() {
  try {
    JSONObject root=new JSONObject();
    root.setInt("version", 1);
    root.setInt("mode", mode);
    JSONArray sensors=new JSONArray(), paths=new JSONArray();
    for (int i=0; i<2; i++) {
      SensorCalibration c=calibration[i];
      JSONObject sensor=new JSONObject();
      sensor.setFloat("relaxed", c.relaxed);
      sensor.setFloat("stretched", c.stretched);
      sensor.setBoolean("relaxedReady", c.relaxedReady);
      sensor.setBoolean("stretchedReady", c.stretchedReady);
      sensors.setJSONObject(i, sensor);
      paths.setString(i, recordings[i].path);
    }
    root.setJSONArray("sensors", sensors);
    root.setJSONArray("recordings", paths);
    java.nio.file.Path target=studioSettingsFile().toPath(), temp=target.resolveSibling("studio_settings.tmp");
    java.nio.file.Files.write(temp, root.toString().getBytes(java.nio.charset.StandardCharsets.UTF_8));
    try {
      java.nio.file.Files.move(temp, target, java.nio.file.StandardCopyOption.REPLACE_EXISTING, java.nio.file.StandardCopyOption.ATOMIC_MOVE);
    }
    catch(java.nio.file.AtomicMoveNotSupportedException e) {
      java.nio.file.Files.move(temp, target, java.nio.file.StandardCopyOption.REPLACE_EXISTING);
    }
    settingsStatus=calibrationComplete()?"Calibration saved — ready for all instruments":"Calibration progress saved";
  }
  catch(Exception e) {
    settingsStatus="SAVE FAILED — calibration works only for this session";
    notice=settingsStatus;
    println(settingsStatus+" "+e);
  }
}
void openCalibration() {
  calibrationScreen=true;
  engineArmed=false;
  gains[0]=gains[1]=0;
  tracking[0]=tracking[1]=false;
  notice="Calibration: local audio stopped; RAVE fades HOME; volume controls held.";
  sendControllerState();
}
void finishCalibration() {
  if (!calibrationComplete()) {
    notice="Capture relaxed and stretched positions for both sensors first.";
    return;
  }
  saveStudioSettings();
  calibrationScreen=false;
  performancePaused=false;
  notice=settingsStatus.startsWith("SAVE FAILED")?settingsStatus:"Calibration ready. "+modeNames[mode]+" will enable automatically.";
}
void drawCalibration() {
  fill(0, 32, 96);
  textSize(25);
  text("Embodied Studio / Calibration", 20, 38);
  fill(0);
  textSize(14);
  text("Capture both positions for each sensor. Calibration is shared and saved automatically.", 20, 72);
  text("1 / 2 select sensor     R relaxed     S stretched     C clear selected sensor", 20, 99);
  for (int i=0; i<2; i++) {
    int x=i==0?20:580;
    SensorCalibration c=calibration[i];
    stroke(i==selectedSensor?color(0, 32, 96):color(160));
    strokeWeight(i==selectedSensor?2:1);
    noFill();
    rect(x, 137, 500, 380);
    strokeWeight(1);
    fill(0, 32, 96);
    textSize(21);
    text("SENSOR A"+i, x+18, 174);
    fill(0);
    textSize(16);
    text("Current reading: "+nf(i==0?smoothedValue0:smoothedValue1, 0, 2), x+18, 210);
    text("Relaxed: "+(c.relaxedReady?nf(c.relaxed, 0, 2):"not captured"), x+18, 249);
    text("Stretched: "+(c.stretchedReady?nf(c.stretched, 0, 2):"not captured"), x+18, 281);
    calibrationButton(x+18, 310, 222, 48, "Capture relaxed", c.mode==1);
    calibrationButton(x+258, 310, 222, 48, "Capture stretched", c.mode==2);
    fill(0, 32, 96);
    textSize(15);
    text(c.mode!=0?"Hold "+(c.mode==1?"RELAXED":"STRETCHED")+"...":latentReady(i)?"READY":"Capture both positions", x+18, 401);
    if (c.mode!=0) {
      noStroke();
      fill(0, 32, 96);
      rect(x+18, 421, 464*constrain((millis()-c.started)/float(calibrationDuration), 0, 1), 8);
    }
    fill(0);
    textSize(13);
    text("Status: "+(i==0?sensorStatus0:sensorStatus1), x+18, 474);
  }
  fill(0, 32, 96);
  textSize(17);
  text(settingsStatus, 20, 558);
  fill(0);
  textSize(13);
  text("Saved in studio_settings.json beside the Processing sketch.", 20, 586);
  text("Calibration pauses local instruments and fades RAVE HOME. REAPER volume mode holds.", 20, 613);
  calibrationButton(20, 655, 330, 55, calibrationComplete()?"Done — return to performance":"Complete both sensors to continue", calibrationComplete());
  fill(0);
  textSize(13);
  text("Enter = done     K = calibration screen", 20, 744);
  text(shortLabel(notice, 135), 20, 782);
}
void calibrationButton(float x, float y, float w, float h, String label, boolean selected) {
  stroke(0, 32, 96);
  fill(selected?color(0, 32, 96):color(255));
  rect(x, y, w, h);
  fill(selected?255:color(0, 32, 96));
  textSize(13);
  textAlign(CENTER, CENTER);
  text(label, x+w/2, y+h/2);
  textAlign(LEFT, BASELINE);
}
