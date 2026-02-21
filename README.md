# WESTO – Smart Waste Monitoring and Compression System

WESTO is an IoT-based smart waste monitoring and compression system developed using an ESP32 microcontroller and a Flutter mobile application. The system enables real-time monitoring of waste levels and safe control of a compression mechanism through a direct local connection, without relying on internet connectivity.

---

## 📌 Problem Statement

Traditional waste bins do not provide real-time monitoring or intelligent control, leading to overflow, inefficient waste collection, and poor resource management. This project addresses these issues by introducing a smart waste bin system that allows users to monitor waste levels and trigger compression locally using a mobile application.

---

## 🎯 Objectives

- To design an offline smart waste monitoring system
- To visualize waste levels in real time
- To safely control a waste compression mechanism
- To implement a scalable and maintainable mobile application architecture

---

## 🧠 System Overview

The system consists of two major components:

### 1. ESP32 (Embedded System)
- Operates in **Access Point (AP) mode**
- Creates its own Wi-Fi hotspot
- Hosts a local HTTP server
- Exposes REST APIs for monitoring and control
- Provides a web-based dashboard for testing and debugging

### 2. Flutter Mobile Application
- Connects directly to the ESP32 hotspot
- Verifies device connectivity
- Displays real-time waste status
- Triggers the compressor with user confirmation
- Displays device information
- Works fully offline

---

## 🏗️ Architecture

The Flutter application follows **Clean Architecture**, ensuring separation of concerns and scalability.
Presentation Layer
↓
Domain Layer
↓
Data Layer
↓
ESP32 Firmware (REST APIs)


### Layer Description

- **Presentation Layer**: UI screens, widgets, and ViewModels
- **Domain Layer**: Entities, repositories, and use cases
- **Data Layer**: API services, models, and repository implementations
- **Firmware Layer**: ESP32 HTTP server and hardware control logic

---

## 📂 Project Structure (Flutter)
lib/
├── core/
│ ├── constants/
│ ├── theme/
│ └── utils/
├── data/
│ ├── models/
│ ├── services/
│ └── repositories/
├── domain/
│ ├── entities/
│ ├── repositories/
│ └── usecases/
├── presentation/
│ ├── screens/
│ ├── viewmodels/
│ └── widgets/
└── main.dart


---

## 🔌 ESP32 REST API Endpoints

| Endpoint        | Method | Description                              |
|-----------------|--------|------------------------------------------|
| `/status`       | GET    | Fetch current waste status               |
| `/update`       | GET    | Update waste level (web dashboard)       |
| `/compress`     | POST   | Trigger waste compressor                 |
| `/device/info`  | GET    | Fetch ESP32 device information           |

---

## 📱 Mobile Application Features

- Splash screen and onboarding flow
- Device connection verification screen
- Dashboard with waste level visualization
- Confirmation dialog before compressor activation
- SnackBar-based feedback for user actions
- Device information screen
- Bottom navigation (Dashboard / Device / Profile)

---

## 🧪 How to Run the Project

### ESP32 Setup
1. Open the Arduino sketch
2. Install required libraries:
    - WiFi
    - WebServer
    - ArduinoJson
3. Upload the firmware to the ESP32
4. Connect to Wi-Fi network: `Westo_ESP32`

### Flutter App Setup
1. Clone this repository
2. Run `flutter pub get`
3. Connect the mobile device to `Westo_ESP32` Wi-Fi
4. Run the app using `flutter run`

---

## 🔮 Future Enhancements

- User authentication and profile management
- Cloud integration for remote monitoring
- Push notifications for waste alerts
- Waste level history and analytics
- Multi-bin support
- OTA firmware updates

---

## 📚 Technologies Used

- ESP32 (Arduino framework)
- Flutter (Dart)
- REST API
- MQTT (optional, future scope)
- Clean Architecture principles

---

## 👨‍🎓 Author

**Irfan Fathan**  
Electronics and Communication Engineering Student

---

## 📄 License

This project is developed for academic and educational purposes.
