#include <ArduinoOTA.h>
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <vector>

#define ssid "ssid"
#define password "password"

ESP8266WebServer server(80);

int sensorReading;
const int relayPin = 4;
const int sensorPin = A0;
int threshold = 800;               // Default threshold value for soil moisture
bool pumpStatus = false;           // Pump is initially off
unsigned long previousMillis = 0;  // For timing sensor reads
unsigned long interval = 30000;    // Reading interval
bool manual = false;               // Manual control mode

void setup() {
  Serial.begin(115200);
  while (!Serial) {}

  WiFi.disconnect(true);
  delay(1000);
  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  delay(5000);

  pinMode(relayPin, OUTPUT);
  pinMode(sensorPin, INPUT);

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }

  ArduinoOTA.begin();

  Serial.println("Ready for OTA");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  // Define HTTP API endpoints
  server.on("/soil-moisture", HTTP_GET, handleGetSoilMoisture);
  server.on("/pump-status", HTTP_GET, handleGetPumpStatus);
  server.on("/manual-control", HTTP_POST, handleManualControl);  // Manual mode toggle
  server.on("/get-threshold", HTTP_GET, handleGetThreshold);
  server.on("/pump-control", HTTP_POST, handlePumpControl);      // Pump control
  server.on("/set-threshold", HTTP_POST, handleSetThreshold);

  server.begin();
  Serial.println("HTTP server started");
}

void loop() {
  ArduinoOTA.handle();
  server.handleClient();
  unsigned long currentMillis = millis();

  // Manual mode should override automatic control
  if (manual) {
    return;  // Skip automatic control if in manual mode
  }

  // Read soil moisture at intervals
  if (currentMillis - previousMillis >= interval || currentMillis == 0) {
    previousMillis = currentMillis;
    sensorReading = analogRead(sensorPin);
    Serial.println(sensorReading);

    if (sensorReading > threshold) {  // Soil is dry
      if (!pumpStatus) {
        digitalWrite(relayPin, HIGH);
        pumpStatus = true;
      }
    } else {  // Soil is moist
      if (pumpStatus) {
        digitalWrite(relayPin, LOW);
        pumpStatus = false;
      }
    }
  }
  delay(400);
}

// Function to toggle manual mode
void handleManualControl() {
  if (server.hasArg("mode")) {
    String mode = server.arg("mode");

    if (mode == "ON") {
      manual = true;
      digitalWrite(relayPin, LOW);  // Turn off pump initially in manual mode
      server.send(200, "text/plain", "Manual mode enabled");
    } else if (mode == "OFF") {
      manual = false;
      server.send(200, "text/plain", "Automatic mode enabled");
    } else {
      server.send(400, "text/plain", "Invalid mode. Use 'ON' or 'OFF'");
    }
  } else {
    server.send(400, "text/plain", "Missing 'mode' parameter");
  }
}

// Function to control pump manually
void handlePumpControl() {
  if (!manual) {
    server.send(403, "text/plain", "Manual mode is disabled");
    return;
  }

  if (server.hasArg("status")) {
    String status = server.arg("status");
    if (status == "ON") {
      digitalWrite(relayPin, HIGH);
      pumpStatus = true;
      server.send(200, "text/plain", "Pump is ON (Manual Mode)");
    } else if (status == "OFF") {
      digitalWrite(relayPin, LOW);
      pumpStatus = false;
      server.send(200, "text/plain", "Pump is OFF (Manual Mode)");
    } else {
      server.send(400, "text/plain", "Invalid status");
    }
  } else {
    server.send(400, "text/plain", "Missing 'status' parameter");
  }
}

// Function to get soil moisture data
void handleGetSoilMoisture() {
  String message = String(analogRead(sensorPin));
  server.send(200, "text/plain", message);
}

// Function to get pump status
void handleGetPumpStatus() {
  String status = pumpStatus ? "ON" : "OFF";
  server.send(200, "text/plain", status);
}

// Function to get the current threshold
void handleGetThreshold() {
  String response = String(threshold);
  server.send(200, "text/plain", response);
}

// Function to set threshold value
void handleSetThreshold() {
  if (server.hasArg("threshold")) {
    String newThreshold = server.arg("threshold");
    threshold = newThreshold.toInt();
    server.send(200, "text/plain", "Threshold set to " + newThreshold);
  } else {
    server.send(400, "text/plain", "Missing 'threshold' parameter");
  }
}
