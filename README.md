# 🌿 **EcoFlow** 🌿

<p align="center">
  <img src="https://github.com/user-attachments/assets/7d206013-1931-4594-8d11-09f6c2a3cd1f" alt="EcoFlow Icon" width="150" height="150">
</p>

---

**EcoFlow** is a smart IoT project for automated soil moisture monitoring and water pump control using the ESP8266. The system helps create efficient water irrigation solutions by monitoring soil moisture levels and controlling a water pump accordingly. Real-time data and control are available via a mobile app developed in Flutter.

---

> [Demo Video :](https://github.com/anisha-01-phoenix/EcoFlow/blob/master/Project%20Demo.mp4)


https://github.com/user-attachments/assets/4d8cc269-792c-43fb-a347-1ca6c10f7157



---

## 🌱 **Features**

- **Real-Time Soil Moisture Monitoring:** Constantly reads moisture levels from a soil sensor.
- **Automated Water Pump Control:** Automatically activates the pump when the soil is dry based on a configurable threshold.
- **Manual Pump Control:** Allows users to manually switch the pump on or off through the mobile app.
- **Threshold Configuration:** Users can set and update the soil moisture threshold value for triggering pump activation.
- **Historical Data Logging:** Maintains logs of recent soil moisture readings and pump activity events.
- **Over-the-Air (OTA) Updates:** Supports wireless firmware updates for the ESP8266.
- **Wi-Fi Connectivity:** Uses ESP8266’s Wi-Fi to expose a RESTful HTTP API for seamless integration with mobile devices.

---

## 🛠️ **Hardware Requirements**

### Components

- **ESP8266 NodeMCU**
- **Soil Moisture Sensor**
- **5V 1-Channel Relay Module**
- **Water Pump & Pipe**
- **Jumper Wires**
- **Power Supply for the ESP8266 and Water Pump**

### Hardware Connections

| Component              | ESP8266 Pin   | Notes                           |
|------------------------|---------------|---------------------------------|
| **Soil Moisture Sensor** | A0            | Analog sensor input             |
| **Relay Module**       | GPIO4 (D2)   | Controls power to water pump    |
| **Power**              | 3.3V/5V       | Ensure proper voltage selection |
| **GND**                | Common GND    | Shared ground reference         |

> Circuit Diagram : 
![Schematic_ecoflow_circuit_2025-04-11](https://github.com/user-attachments/assets/6b81ecd3-dbe1-45cb-9349-ed878caa538a)
`(Created using EasyEDA)`
---

## 🌐 **Backend API Overview**

The ESP8266 code exposes several RESTful API endpoints that allow the mobile app and other client applications to monitor and control the irrigation system. Below is a detailed list of the available API routes:

### **1. Get Current Soil Moisture**
- **Endpoint:** `/soil-moisture`
- **Method:** `GET`
- **Description:** Returns the current soil moisture sensor reading (analog value).
- **Example Response:**
  ```json
  "750"
  ```

### **2. Get Pump Status**
- **Endpoint:** `/pump-status`
- **Method:** `GET`
- **Description:** Provides the current state of the water pump, either "ON" or "OFF".
- **Example Response:**
  ```json
  "OFF"
  ```

### **3. Get Soil Moisture Threshold**
- **Endpoint:** `/get-threshold`
- **Method:** `GET`
- **Description:** Retrieves the current soil moisture threshold value used for automatic pump control.
- **Example Response:**
  ```json
  "800"
  ```

### **4. Set Soil Moisture Threshold**
- **Endpoint:** `/set-threshold`
- **Method:** `POST`
- **Parameters:**
  - `threshold`: New threshold value (integer)
- **Description:** Updates the soil moisture threshold value for pump activation.
- **Example Response:**
  ```json
  "Threshold set to 850"
  ```

### **5. Manual Pump Control**
- **Endpoint:** `/manual-control`
- **Method:** `POST`
- **Parameters:**
  - `status`: "ON" or "OFF" (string)
- **Description:** Switches the pump state manually. This endpoint sets the system to manual control mode and turns the pump on or off accordingly.
- **Example Response:**
  ```json
  "Pump is ON"
  ```

### **6. Auto Control Mode**
- **Endpoint:** `/auto-control`
- **Method:** `GET`
- **Description:** Reverts the system to automatic control mode.
- **Example Response:**
  ```json
  "Switched to Auto Control mode"
  ```

### **7. Get Soil Moisture History**
- **Endpoint:** `/soil-moisture-history`
- **Method:** `GET`
- **Description:** Retrieves a JSON list of the recent soil moisture readings along with timestamps.
- **Example Response:**
  ```json
  [
    {"moisture":730,"timestamp":1590000000},
    {"moisture":790,"timestamp":1590000030}
  ]
  ```

### **8. Get Pump Activity Timeline**
- **Endpoint:** `/pump-activity-timeline`
- **Method:** `GET`
- **Description:** Provides a JSON list that logs the pump’s state changes (ON/OFF) with timestamps.
- **Example Response:**
  ```json
  [
    {"state":"ON","timestamp":1590000000},
    {"state":"OFF","timestamp":1590000060}
  ]
  ```

---

## 📱 **Mobile App Functionality (Flutter)**

The **EcoFlow** mobile app, developed in Flutter, serves as an intuitive interface for interacting with the ESP8266-based irrigation system. Below is an overview of the app's functionality:
<p align="center">
  <img src="https://github.com/user-attachments/assets/1c781eb4-703c-4b93-9ec7-f8fb2e350422" alt="EcoFlow Icon" width="150" height="300">
</p>

- **Real-Time Monitoring:**  
  The app displays current soil moisture readings, updating in real time so that users can observe the status of their soil conditions.
 <p align="center">
  <img src="https://github.com/user-attachments/assets/0d7fc7ac-70b2-44b5-98fe-8132433fefb1" alt="EcoFlow Icon" width="150" height="300">
  <img src="https://github.com/user-attachments/assets/bbd323a2-8939-4e4f-98c4-5acb40ddf50e" alt="EcoFlow Icon" width="150" height="300">
</p>

- **Manual Pump Control Screen:**  
  Users can manually activate or deactivate the pump. A dedicated screen allows toggling between pump states, which sends a POST request to the `/manual-control` API endpoint.
  <p align="center">
  <img src="https://github.com/user-attachments/assets/55202da2-9804-484b-996a-600d178d96e6" alt="EcoFlow Icon" width="150" height="300">
</p>

- **Threshold Configuration features:**  
  This feature (as shown in the above screen) lets users input a new moisture threshold value by changing the value on the slider. Once the value is changed, the app sends the updated value to the ESP8266 using the `/set-threshold` endpoint. The current threshold can also be viewed using the `/get-threshold` endpoint.

- **Historical Data and Activity Logs:**  
  Two screens in the app show historical data:
  - **Soil Moisture History:** Displays a chronological log of moisture sensor readings.
  - **Pump Activity Timeline:** Shows a detailed timeline indicating when the pump was activated or deactivated.
  <p align="center">
  <img src="https://github.com/user-attachments/assets/245aeae2-a146-430b-bc7c-a3906f3f8bc0" alt="EcoFlow Icon" width="150" height="300">
</p>

- **Automatic Mode Switching:**  
  The app provides a feature to revert to automatic control by invoking the `/auto-control` endpoint. In this mode the pump will be controlled totally based on the sensor inputs.
<p align="center">
  <img src="https://github.com/user-attachments/assets/593683a2-b7f9-4cd5-8f6f-d040a03a5937" alt="EcoFlow Icon" width="150" height="300">
</p>

---

## 🚀 **How to Set Up and Run the Project**

### **1. Flash the ESP8266 Firmware**

1. **Install the Arduino IDE** if not already installed.
2. **Install the ESP8266 Board**:  
   In the Arduino IDE, go to **File > Preferences**, add the following URL to the **Additional Boards Manager URLs**:
   ```
   http://arduino.esp8266.com/stable/package_esp8266com_index.json
   ```
3. **Install Required Libraries:**
   - ESP8266WiFi
   - ESP8266WebServer
   - ArduinoOTA
4. **Configure the Code:**  
   - Open the provided `EcoFlow.ino` file in the Arduino IDE.
   - Update the Wi-Fi credentials (`ssid` and `password`).
5. **Upload the Code:**  
   Flash the firmware to your ESP8266 via USB. Once uploaded, check the Serial Monitor for the IP address assigned to the device.

### **2. Running the API Server**

After flashing the firmware, the ESP8266 starts its HTTP server and serves the endpoints listed above. You can test these endpoints using a browser, Postman, or the mobile app.

### **3. Running the Flutter Mobile App**

1. **Clone or Download the Mobile App Repository:**  
   Ensure you have the project locally.
2. **Open the Project in Your Preferred IDE:**  
   Use Android Studio, VS Code, or any Flutter-compatible IDE.
3. **Configure the Base URL:**  
   Update the API base URL in the app’s configuration to the IP address of your ESP8266.
4. **Build and Run:**  
   Run the app on your mobile device or emulator. Ensure that the device and the ESP8266 are on the same Wi-Fi network.

> App Demo : [Download from here](https://github.com/anisha-01-phoenix/EcoFlow/blob/master/app-debug.apk)

---

## 📊 **Flowchart**

Schematic Flowchart of the working of the app : ![Flowchart](https://github.com/user-attachments/assets/b0f51b24-9c96-44c9-9014-a035951b0c42)

---
