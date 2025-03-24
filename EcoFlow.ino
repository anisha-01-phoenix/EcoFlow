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
bool manual=false;    /// manual control

// Data structure to store moisture readings and timestamps
struct MoistureData {
  int moisture;
  unsigned long timestamp;
};

std::vector<MoistureData> moistureDataList;  // Vector to hold soil moisture data

// Data structure for pump activity (on/off logs)
struct PumpActivity {
  bool pumpState;
  unsigned long timestamp;
};

std::vector<PumpActivity> pumpActivityLog;  // Vector to log pump activity

void setup() {
  Serial.begin(115200);
  while (!Serial) {}
  WiFi.disconnect(true);
  delay(1000);

  WiFi.mode(WIFI_STA);
  WiFi.begin(ssid, password);
  delay(5000);

  // Set relayPin as output and sensorPin as input
  pinMode(relayPin, OUTPUT);  // Output pin for relay module
  pinMode(sensorPin, INPUT);  // Input pin from soil sensor

  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
    Serial.println(WiFi.status());
  }

  // Initialize OTA functionality
  ArduinoOTA.onStart([]() {
    Serial.println("Start updating...");
  });

  ArduinoOTA.onEnd([]() {
    Serial.println("\nEnd");
  });

  ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
    Serial.printf("Progress: %u%%\r", (progress / (total / 100)));
  });

  ArduinoOTA.onError([](ota_error_t error) {
    Serial.printf("Error[%u]: ", error);
    if (error == OTA_AUTH_ERROR) Serial.println("Auth Failed");
    else if (error == OTA_BEGIN_ERROR) Serial.println("Begin Failed");
    else if (error == OTA_CONNECT_ERROR) Serial.println("Connect Failed");
    else if (error == OTA_RECEIVE_ERROR) Serial.println("Receive Failed");
    else if (error == OTA_END_ERROR) Serial.println("End Failed");
  });

  ArduinoOTA.begin();  // Start OTA

  Serial.println("Ready for OTA");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());  // Print ESP8266 IP address

  // Define HTTP API endpoints
  server.on("/soil-moisture", HTTP_GET, handleGetSoilMoisture);
  server.on("/pump-status", HTTP_GET, handleGetPumpStatus);
  server.on("/manual-control", HTTP_GET, handleManualControl); // API for manual or automatic
  server.on("/get-threshold", HTTP_GET, handleGetThreshold);
  server.on("/pump-control", HTTP_POST, handlePumpControl);
  server.on("/set-threshold", HTTP_POST, handleSetThreshold);
  server.on("/soil-moisture-history", HTTP_GET, handleGetSoilMoistureHistory);
  server.on("/pump-activity-timeline", HTTP_GET, handleGetPumpActivityTimeline);


  server.begin();  // Start the HTTP server
  Serial.println("HTTP server started");
}

void loop() {
  // Handle OTA in the loop
  ArduinoOTA.handle();
  server.handleClient();
  unsigned long currentMillis = millis();

  // Read soil moisture sensor at regular intervals
  if (currentMillis - previousMillis >= interval || currentMillis == 0) {
    previousMillis = currentMillis;

    // Read the signal from the soil moisture sensor
    sensorReading = analogRead(sensorPin);
    Serial.println(sensorReading);

    // Store the current moisture reading with a timestamp
    MoistureData data;
    data.moisture = sensorReading;
    data.timestamp = currentMillis;
    moistureDataList.push_back(data);

    // Limit the size of the stored data (for memory management)
    if (moistureDataList.size() > 1000) {
      moistureDataList.erase(moistureDataList.begin());
    }

void handleManualControl()
    {
       // add a extra button to change the status of manual .. default is off 
    }
if (manual)
{
  // POST endpoint to control the pump manually
void handlePumpControl() {
  if (server.hasArg("status")) {
    String status = server.arg("status");
    if (status == "ON") {
      digitalWrite(relayPin, HIGH);  // Turn pump ON
      pumpStatus = true;
      server.send(200, "text/plain", "Pump is ON");
    } else if (status == "OFF") {
      digitalWrite(relayPin, LOW);  // Turn pump OFF
      pumpStatus = false;
      server.send(200, "text/plain", "Pump is OFF");
    } else {
      server.send(400, "text/plain", "Invalid status");
    }
  } else {
    server.send(400, "text/plain", "Missing 'status' parameter");
  }
}
  
  
}
    else 
{
  
    // If soil is dry, turn on the relay (which powers the pump)
    if (sensorReading > threshold) {   // Soil is dry
      if (!pumpStatus) {               // If the pump is currently off, turn it on
        digitalWrite(relayPin, HIGH);  // Activate relay, pump starts
        pumpStatus = true;

        // Log the pump ON event
        logPumpActivity(true);
      }
    } else {                          // Soil is moist, turn off the pump
      if (pumpStatus) {               // If the pump is currently on, turn it off
        digitalWrite(relayPin, LOW);  // Deactivate relay, pump stops
        pumpStatus = false;

        // Log the pump OFF event
        logPumpActivity(false);
      }
    }
}
  }

  delay(400);  // Short delay to avoid overload
}

// Function to log pump activity (on/off)
void logPumpActivity(bool state) {
  PumpActivity activity;
  activity.pumpState = state;
  activity.timestamp = millis();
  pumpActivityLog.push_back(activity);

  // Limit the size of the log (for memory management)
  if (pumpActivityLog.size() > 500) {
    pumpActivityLog.erase(pumpActivityLog.begin());
  }
}


// GET endpoint to get current soil moisture value
void handleGetSoilMoisture() {
  String message = String(analogRead(sensorPin));
  server.send(200, "text/plain", message);
}

// GET endpoint to get current pump status (ON/OFF)
void handleGetPumpStatus() {
  String status = pumpStatus ? "ON" : "OFF";
  server.send(200, "text/plain", status);
}

// GET endpoint to get current soil threshold value
void handleGetThreshold() {
  String response = String(threshold);
  server.send(200, "text/plain", response); 
}



// POST endpoint to set soil moisture threshold
void handleSetThreshold() {
  if (server.hasArg("threshold")) {
    String newThreshold = server.arg("threshold");
    threshold = newThreshold.toInt();
    server.send(200, "text/plain", "Threshold set to " + newThreshold);
  } else {
    server.send(400, "text/plain", "Missing 'threshold' parameter");
  }
}

// GET endpoint to get soil moisture history
void handleGetSoilMoistureHistory() {
  String jsonResponse = "[";
  for (int i = 0; i < moistureDataList.size(); i++) {
    if (i > 0) jsonResponse += ",";
    jsonResponse += "{\"moisture\":" + String(moistureDataList[i].moisture) + 
                    ",\"timestamp\":" + String(moistureDataList[i].timestamp) + "}";
  }
  jsonResponse += "]";
  server.send(200, "application/json", jsonResponse);
}


// GET endpoint to get pump activity timeline 
void handleGetPumpActivityTimeline() {
  String jsonResponse = "[";
  for (int i = 0; i < pumpActivityLog.size(); i++) {
    if (i > 0) jsonResponse += ",";
    jsonResponse += "{\"state\":\"" + String(pumpActivityLog[i].pumpState ? "ON" : "OFF") + 
                    "\",\"timestamp\":" + String(pumpActivityLog[i].timestamp) + "}";
  }
  jsonResponse += "]";
  server.send(200, "application/json", jsonResponse);
}

