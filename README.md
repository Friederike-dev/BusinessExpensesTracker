# Business Expense Tracker
A comprehensive full-stack application for tracking and managing business expenses with real-time statistics and multi-platform support.

**Note:** C++, CMake, HTML and Swift files are auto-generated Flutter platform code for cross-platform deployment. The core application is built with Dart (Flutter frontend) and Java (Spring Boot backend).

### Architecture & Design Patterns
- **MVC Pattern** in Spring Boot backend
- **Provider Pattern** for Flutter state management
- **Repository Pattern** for data access layer
- **Singleton Pattern** for API service management
- **RESTful API Design** with proper HTTP methods
- **Separation of Concerns** across all layers

### Code Quality & Documentation
- **Professional JavaDoc** documentation for all Java classes and methods
- **Comprehensive Dart comments** explaining complex operations
- **Variable-level documentation** for clarity and maintainability
- **API endpoint documentation** with detailed parameter descriptions
- **Inline comments** for business logic and special operations
- **Consistent naming conventions** following language best practicesg business expenses with real-time statistics and multi-platform support.

## **Key Skills Demonstrated**
- **Full-Stack Development:** Flutter frontend + Spring Boot backend
- **API Design:** RESTful services with comprehensive endpoints
- **State Management:** Provider pattern for Flutter
- **Database Integration:** JPA with H2 database
- **Cross-Platform Development:** Support for 6+ platforms
- **Modern Architecture:** Clean separation of concernsess Expense Tracker


Features
Frontend (Flutter)
- **Cross-platform support** - Windows, macOS, Linux, iOS, Android, Web
- **Modern Material Design** UI with responsive layout
- **Real-time expense tracking** with instant updates
- **Interactive statistics** with charts and graphs
- **Offline capability** with local state management
- **Category-based organization** for better expense management

Backend (Spring Boot)
- **RESTful API** with comprehensive endpoints
- **Real-time data processing** with instant synchronization
- **Advanced statistics** - quarterly and yearly reports
- **H2 in-memory database** for fast development and testing
- **CORS enabled** for seamless frontend integration
- **Health monitoring** with status endpoints

Architecture

```
┌─────────────────┐    HTTP-Requests    ┌──────────────────┐
│   FRONTEND      │ ──────────────────► │    BACKEND       │
│   (Flutter)     │ ◄────────────────── │  (Spring Boot)   │
│   Dynamic Port  │    JSON-Responses   │   Port 8080      │
└─────────────────┘                     └──────────────────┘
                                                │
                                                ▼
                                        ┌──────────────────┐
                                        │    DATABASE      │
                                        │   (H2 Memory)    │
                                        └──────────────────┘
```

Project Structure

```
BusinessExpensesTracker/
├── business_tracker_app/     # Flutter Frontend
│   ├── lib/
│   │   ├── models/          # Data models
│   │   ├── providers/       # State management
│   │   ├── screens/         # UI screens
│   │   ├── services/        # API services
│   │   └── utils/           # Configuration
│   └── ...
└── business_tracker_backend/ # Spring Boot Backend
    └── src/main/java/
        └── com/adlibita/businesstracker/
            ├── controller/  # REST controllers
            ├── model/       # JPA entities
            ├── repository/  # Data access
            └── service/     # Business logic
```

## Tech Stack

### Frontend (Flutter)
- **Flutter 3.32.5** - Cross-platform UI framework
- **Provider** - State management pattern
- **HTTP** - API communication
- **FL Chart** - Data visualization
- **Material Design** - UI components

### Backend (Spring Boot)
- **Spring Boot 3.2.1** - Java framework
- **Spring Data JPA** - Data persistence layer
- **H2 Database** - In-memory database
- **Maven** - Dependency management
- **Jackson** - JSON processing
- **CORS Configuration** - Cross-origin resource sharing

## **Technical Highlights**

### Architecture & Design Patterns
- **MVC Pattern** in Spring Boot backend
- **Provider Pattern** for Flutter state management
- **Repository Pattern** for data access layer
- **RESTful API Design** with proper HTTP methods
- **Separation of Concerns** across all layers

### Development Best Practices
- **Comprehensive Code Documentation** - Detailed JavaDoc and Dart comments
- **Modular Code Structure** with clear separation of concerns
- **Error Handling** and validation throughout the application
- **Configuration Management** for different environments
- **Responsive UI Design** for multiple platforms
- **API Documentation** with clear endpoint descriptions
- **Professional Commenting** - Every method, variable, and complex operation documented

## Quick Start

### Prerequisites
- **Flutter SDK** (3.32.5 or later)
- **Java JDK** (17 or later)
- **Maven** (3.6 or later)

### 1. Clone the Repository
```bash
git clone https://github.com/yourusername/BusinessExpensesTracker.git
cd BusinessExpensesTracker
```

### 2. Start the Backend
```bash
cd business_tracker_backend
mvn clean install
mvn spring-boot:run
```
**Alternative (if above doesn't work):**
```bash
mvn clean package
java -jar target/business-tracker-api-1.0.0.jar
```
Backend will be available at: `http://localhost:8080`

### 3. Start the Frontend
```bash
cd business_tracker_app
flutter pub get
flutter run -d windows  # or your preferred platform
```

### 4. Verify Setup
- Backend health check: `GET http://localhost:8080/api/health`
- Frontend should automatically connect to the backend


API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/health` | Backend status check |
| `GET` | `/api/expenses` | Get all expenses |
| `POST` | `/api/expenses` | Create new expense |
| `PUT` | `/api/expenses/{id}` | Update expense |
| `DELETE` | `/api/expenses/{id}` | Delete expense |
| `GET` | `/api/expenses/stats/quarterly` | Quarterly statistics |
| `GET` | `/api/expenses/stats/yearly` | Yearly statistics |

### macOS Desktop App Notice

> **Known Issue:**  
> The macOS desktop version of this app does **not always work reliably on macOS**, especially when accessing the backend API over the network. This is a well-known limitation of Flutter Desktop on macOS.
>
> - **Web version:** The browser-based (Web) version of the app runs as expected on macOS and is recommended for use on this platform.
> - **Workarounds:** There is currently no stable workaround for the desktop app on macOS. If you encounter issues, please use the Web version or run the app on Windows or Linux.
> - **Status:** Support for the macOS desktop app will be improved as soon as the Flutter team provides a stable solution.



## Testing

### Backend Tests
```bash
cd business_tracker_backend
mvn test
```

### Frontend Tests
```bash
cd business_tracker_app
flutter test
```

Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Windows |  Primary | Fully tested |
| Web |  Supported | Modern browsers |
| Android |  Supported | Android 6.0+ |
| iOS |  Supported | iOS 12.0+ |
| macOS |  Supported | macOS 10.14+ |
| Linux |  Supported | Ubuntu 20.04+ |


Development

Flutter Development
```bash
# Hot reload for development
flutter run -d windows --hot

# Build for production
flutter build windows
flutter build web
flutter build apk
```

### Backend Development
```bash
# Development with auto-reload
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Dspring.profiles.active=dev"

# Build production JAR
mvn clean package
```



Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request



## Copyright
© 2025 [Friederike H.]. All rights reserved.

Acknowledgments

- Flutter team for the amazing framework
- Spring Boot community for excellent documentation
- Material Design for UI inspiration

---

**Star this repository if you find it helpful!**
