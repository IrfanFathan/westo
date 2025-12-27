#  1. Core Functional Modules

## 1.1 Authentication Module
- Login
- Registration
- Forgot Password
- Secure token storage
## 1.2 Device Connectivity Module
- IoT connection status (Connected / Disconnected)
- Last sync timestamp
- Signal strength (optional)
## 1.3 Waste Monitoring Module
- Real-time waste level (%)
- Visual indicator (progress bar / gauge)
- Bin status:
    - Normal
    - Full
    - Critical
## 1.4 Compactor Control Module
- Manual "Compress Waste" button
- Safety lock status
- Compaction progress feedback
## 1.5 User Profile Module

- User details
- Linked devices
- Logout  
# 2. UI/UX Design Guidelines

## 2.1 Theme Color System (Environmental & Industrial)

### Primary Color
- **Deep Green** `#1B5E20`  
  *Represents sustainability and waste management*

### Secondary Color
- **Teal** `#00796B`  
  *Conveys IoT and modern technology aesthetics*

### Accent Color
- **Amber** `#FFB300`  
  *Used for warnings and alert indications*

### Error Color
- **Red** `#D32F2F`  
  *Indicates critical bin status and errors*

### Background
- **Light Grey** `#F5F5F5`
- **Dark mode equivalent** (for low-light environments)

---

## 2.2 Typography

### Font Family
- **Inter** or **Roboto**  
  *Professional appearance with high readability*

### Font Sizes

| Usage            | Size (sp) |
|------------------|-----------|
| App Title        | 22–24     |
| Section Headers  | 18        |
| Body Text        | 14–16     |
| Status Labels    | 12–14     |
| Buttons          | 14–16     |

### Font Weight Usage
- **Headings:** SemiBold (600)
- **Body Text:** Regular (400)
- **Status / Alerts:** Medium (500)  
# File & Folder Structure (Clean Architecture)

```text
lib/
│
├── core/
│   ├── constants/
│   │   ├── colors.dart
│   │   ├── fonts.dart
│   │   └── api_constants.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── validators.dart
│
├── data/
│   ├── models/
│   │   └── waste_status_model.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   └── mqtt_service.dart
│   └── repositories/
│       └── waste_repository_impl.dart
│
├── domain/
│   ├── entities/
│   │   └── waste_status.dart
│   ├── repositories/
│   │   └── waste_repository.dart
│   └── usecases/
│       ├── get_waste_level.dart
│       └── trigger_compressor.dart
│
├── presentation/
│   ├── viewmodels/
│   │   └── waste_viewmodel.dart
│   ├── screens/
│   │   ├── auth/
│   │   ├── dashboard/
│   │   ├── device/
│   │   └── profile/
│   └── widgets/
│       ├── status_card.dart
│       └── waste_gauge.dart
│
└── main.dart
