# 🌿 **EcoFlow** 🌿

<p align="center">
  <img src="https://github.com/user-attachments/assets/7d206013-1931-4594-8d11-09f6c2a3cd1f" alt="EcoFlow Icon" width="150" height="150">
</p>

---

**EcoFlow** is a smart IoT project for automated soil moisture monitoring and water pump control using the ESP8266. This project is designed to help in creating efficient water irrigation systems, ensuring that plants receive the right amount of water based on soil moisture levels, while providing real-time monitoring through a mobile app.

## 🌱 **Features**

- **Real-Time Soil Moisture Monitoring**: Constantly tracks the moisture levels in the soil.
- **Automated Water Pump Control**: Automatically turns the pump on or off depending on soil moisture threshold levels.
- **Manual Pump Control**: Allows the pump to be turned on or off manually via the mobile app.
- **Threshold Configuration**: Set a custom soil moisture threshold for pump activation.
- **Moisture and Pump Activity History**: View historical data of soil moisture and pump activity logs.
- **Over-the-Air Updates (OTA)**: Wirelessly update the ESP8266 firmware for easy maintenance.
- **Wi-Fi Connectivity**: Uses ESP8266's Wi-Fi to expose an HTTP API for seamless app interaction.

---

## 🛠️ **Hardware Requirements**

### Components

- **ESP8266 NodeMCU**
- **Soil Moisture Sensor**
- **5V 1 channel Relay Module**
- **Water Pump & Pipe**
- **Jumper Wires**
- **Power Supply for ESP8266 and Water Pump**

### Hardware Connections

| Component           | Pin on ESP8266       |
|---------------------|----------------------|
| **Soil Moisture Sensor** | A0                  |
| **Relay Module**     | GPIO4 (D2)           |
| **VCC (Power)**      | Connect to 3.3V/5V   |
| **GND**              | Common GND           |

---

## 🌐 **APIs Overview**

EcoFlow exposes several RESTful API endpoints to control the water pump and retrieve sensor data from the ESP8266. Below is a list of available API routes and their functionality:

### **1. Get Current Soil Moisture**
- **Endpoint**: `/soil-moisture`
- **Method**: `GET`
- **Description**: Returns the current soil moisture level from the sensor.
- **Response**:
  ```json
  {
    "moisture": "Current sensor value (0-1023)"
  }
  ```

### **2. Get Pump Status**
- **Endpoint**: `/pump-status`
- **Method**: `GET`
- **Description**: Returns the current status of the water pump (ON/OFF).
- **Response**:
  ```json
  {
    "status": "ON/OFF"
  }
  ```

### **3. Get Soil Moisture Threshold**
- **Endpoint**: `/get-threshold`
- **Method**: `GET`
- **Description**: Retrieves the current soil moisture threshold value.
- **Response**:
  ```json
  {
    "threshold": 800
  }
  ```

### **4. Set Soil Moisture Threshold**
- **Endpoint**: `/set-threshold`
- **Method**: `POST`
- **Parameters**:
  - `threshold`: New threshold value (integer)
- **Description**: Sets a new soil moisture threshold to control pump activation.
- **Response**:
  ```json
  {
    "message": "Threshold set to 850"
  }
  ```

### **5. Control the Pump**
- **Endpoint**: `/pump-control`
- **Method**: `POST`
- **Parameters**:
  - `status`: `ON` or `OFF`
- **Description**: Turns the water pump on or off manually.
- **Response**:
  ```json
  {
    "message": "Pump is ON/OFF"
  }
  ```

### **6. Get Soil Moisture History**
- **Endpoint**: `/soil-moisture-history`
- **Method**: `GET`
- **Description**: Retrieves a log of recent soil moisture readings with timestamps.
- **Response**:
  ```json
  [
    {
      "moisture": 730,
      "timestamp": "20/03/2025 14:55:13"
    },
    {
      "moisture": 790,
      "timestamp": "20/03/2025 15:15:45"
    }
  ]
  ```

### **7. Get Pump Activity Timeline**
- **Endpoint**: `/pump-activity-timeline`
- **Method**: `GET`
- **Description**: Returns a log of pump activity (ON/OFF) with timestamps.
- **Response**:
  ```json
  [
    {
      "state": "ON",
      "timestamp": "20/03/2025 14:55:13"
    },
    {
      "state": "OFF",
      "timestamp": "20/03/2025 15:25:40"
    }
  ]
  ```

---

## 📱 **App Functionality**

The **EcoFlow** mobile app serves as the user interface for this project. Through the app, users can interact with the ESP8266 and monitor/control the soil moisture and pump.

### **Features of the App**:

- **Real-Time Monitoring**: Displays real-time soil moisture readings.
- **Manual Pump Control**: Switch the water pump ON or OFF from the app.
- **History Views**: View both soil moisture logs and pump activity timeline.
- **Threshold Configuration**: Adjust the soil moisture threshold from the app to automate pump activation based on soil dryness.
- **Notifications**: Receive alerts when soil is too dry or too wet (future feature).

---

## 🚀 **How to Set Up and Run the Project**

### **1. Flash the ESP8266**

1. **Install the Arduino IDE** if you haven't already.
2. **Install the ESP8266 board** by navigating to **File > Preferences** and adding the following URL under **Additional Boards Manager**: 
   ```
   http://arduino.esp8266.com/stable/package_esp8266com_index.json
   ```
3. Install necessary libraries:
   - **ESP8266WiFi**
   - **ESP8266WebServer**
   - **ArduinoOTA**
4. **Upload the Code**:
   - Copy the provided code in the `EcoFlow.ino` file into your Arduino IDE.
   - Make sure to set your **Wi-Fi credentials** (SSID and Password).
   - Upload the code to the ESP8266 using a USB cable.
   
5. After successful upload, the ESP8266 will connect to Wi-Fi, and you can get its IP address from the Serial Monitor.

### **2. Running the API Server**

Once the code is uploaded, the ESP8266 will start serving APIs on the local network. You can access the APIs via your mobile app or by using tools like Postman or a web browser.

### **3. Running the Mobile App**

1. Clone or download the **EcoFlow mobile app** repository.
2. Open the project in your preferred IDE.
3. Update the base URL of the APIs in the app configuration to point to the ESP8266's IP address.
4. Build and run the app on your mobile device or emulator.
   
> 💡 Ensure that both the ESP8266 and the mobile app are connected to the same Wi-Fi network!

---

## 🛠️ **Future Tasks**

- Adding sensor calibration to improve accuracy.
- Implementing push notifications when soil moisture is critically low.
- Adding additional sensors (e.g., temperature, humidity) to monitor more environmental factors.
- Syncing data with a cloud service for remote access.

---
