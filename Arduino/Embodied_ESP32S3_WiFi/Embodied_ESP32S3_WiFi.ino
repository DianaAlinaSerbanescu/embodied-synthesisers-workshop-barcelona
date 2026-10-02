// Adapted from Diana Alina Serbanescu's XIAO ESP32S3 dual stretch-sensor sketch.
// USB is for upload/debug only. Sensor data travels over Wi-Fi UDP.
#include <WiFi.h>
#include <WiFiUdp.h>
#include <esp_system.h>
#include "wifi_config.h"

const int sensorPin0 = A0;
const int sensorPin1 = A1;
const float smoothing = 0.04f;
const uint16_t receiverPort = 4210;
const uint16_t localPort = 4211;
const uint32_t sampleIntervalMs = 10;
WiFiUDP udp;
IPAddress receiverIP;
float smoothedValue0 = 0, smoothedValue1 = 0;
uint32_t bootId, sequence = 0, lastSample = 0, lastRetry = 0;
bool linkReady = false, paused = false;

void setup() {
  Serial.begin(115200); // No wait for a Serial Monitor: runs from USB power/battery.
  analogReadResolution(12);
  pinMode(sensorPin0, INPUT); pinMode(sensorPin1, INPUT);
  smoothedValue0 = analogRead(sensorPin0); smoothedValue1 = analogRead(sensorPin1);
  bootId = esp_random();
  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);
  WiFi.setAutoReconnect(true);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  lastRetry = millis();
  Serial.println("Embodied Wi-Fi sender: connecting to hotspot...");
}

void loop() {
  if (Serial.available()) {
    char c = Serial.read();
    if (c == 'p') { paused = !paused; Serial.println(paused ? "PAUSED" : "RUNNING"); }
  }
  uint32_t now = millis();
  if (WiFi.status() != WL_CONNECTED) {
    if (linkReady) { udp.stop(); linkReady = false; Serial.println("Wi-Fi lost. Reconnecting..."); }
    if (now - lastRetry >= 15000) { WiFi.reconnect(); lastRetry = now; Serial.println("Still connecting to hotspot..."); }
  } else if (!linkReady) {
    // Mac Internet Sharing/hotspot is the DHCP gateway. Override only if needed.
    receiverIP = WiFi.gatewayIP();
    if (RECEIVER_IP_OVERRIDE[0] != '\0') receiverIP.fromString(RECEIVER_IP_OVERRIDE);
    if (uint32_t(receiverIP) != 0 && udp.begin(localPort)) {
      linkReady = true;
      Serial.print("Connected. ESP32 IP: "); Serial.println(WiFi.localIP());
      Serial.print("Sending sensor data to "); Serial.print(receiverIP); Serial.print(":"); Serial.println(receiverPort);
    }
  }
  if (now - lastSample >= sampleIntervalMs) {
    lastSample = now;
    if (!paused) {
      int raw0 = analogRead(sensorPin0), raw1 = analogRead(sensorPin1);
      smoothedValue0 += smoothing * (raw0 - smoothedValue0);
      smoothedValue1 += smoothing * (raw1 - smoothedValue1);
      if (linkReady) {
        char packet[128];
        // ES1,bootID,sequence,raw0,smoothed0,raw1,smoothed1
        int length = snprintf(packet, sizeof(packet), "ES1,%lu,%lu,%d,%.2f,%d,%.2f", (unsigned long)bootId, (unsigned long)sequence++, raw0, smoothedValue0, raw1, smoothedValue1);
        if (length > 0 && length < (int)sizeof(packet) && udp.beginPacket(receiverIP, receiverPort)) {
          udp.write((const uint8_t*)packet, length); udp.endPacket();
        }
      }
    }
  }
  delay(1);
}
