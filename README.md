

<div align="center">
  <img src="https://github.com/user-attachments/assets/f4f7fbbf-720d-44e9-8caf-a928b5d9bca7" width="250" alt="FlexPay Main Screen">
  <h1>FlexPay: Instant QR Payments</h1>
  <p>A modern Flutter MVP demonstrating seamless and secure QR code-based money transfers, built with a pragmatic state management approach.</p>

  <p>
    <a href="https://github.com/AhmedMohammed204/flex_pay_service">
      <img src="https://img.shields.io/badge/Backend-ASP.NET-5C2D91?style=for-the-badge&logo=dotnet" alt="Backend">
    </a>
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter">
    <img src="https://img.shields.io/badge/State-Cubit%20%26%20setState-blue?style=for-the-badge" alt="State Management">
    <img src="https://img.shields.io/badge/Status-MVP%2FPrototype-orange?style=for-the-badge" alt="Status">
  </p>
</div>

---

**FlexPay** is the official mobile client for the **[FlexPay ASP.NET Backend Service](https://github.com/AhmedMohammed204/flex_pay_service)**. This app provides a clean, intuitive user interface to test the end-to-end flow of generating, scanning, and processing secure QR code payments.

## ✨ App Showcase

Explore the core user experience of FlexPay through its key screens.

<table>
  <tr>
    <td align="center" valign="top">
      <img src="https://github.com/user-attachments/assets/f4f7fbbf-720d-44e9-8caf-a928b5d9bca7" width="220" alt="Main Screen">
      <br />
      <strong>Flexible Payments</strong>
      <p><em>Generate a main QR for quick transfers or create custom, one-time QR codes.</em></p>
    </td>
    <td align="center" valign="top">
      <img src="https://github.com/user-attachments/assets/9455551b-92f7-4ca6-a834-98075a4794d4" width="220" alt="Create Custom QR">
      <br />
      <strong>Intuitive Creation Flow</strong>
      <p><em>A clean, user-friendly interface for setting up custom payment requests.</em></p>
    </td>
    <td align="center" valign="top">
      <img src="https://github.com/user-attachments/assets/32e1b68c-01ee-4a9d-878d-b76a0ea1cf92" width="220" alt="Scan Screen">
      <br />
      <strong>Scan with Ease</strong>
      <p><em>Use the camera or pick an image from your gallery to process payments instantly.</em></p>
    </td>
     <td align="center" valign="top">
      <img src="https://github.com/user-attachments/assets/df4f0574-a422-435e-ac99-87e96e392597" width="220" alt="History Screen">
      <br />
      <strong>Keep Track</strong>
      <p><em>A clear history of all your generated QR codes and their current status.</em></p>
    </td>
  </tr>
</table>

## 🎯 Core Features

-   📱 **Dynamic & Static QR Codes:** Generate a main, reusable QR code or create custom, single-use codes with specific amounts and passkeys.
-   📸 **Scan & Pay Instantly:** Utilize the device camera or gallery to scan QR codes and authorize payments in seconds.
-   📜 **Transaction History:** Easily view and manage a list of all QR codes you have generated.
-   👤 **Simulated User Environment:** Uses the device's unique ID to simulate a user account, making testing quick and easy.
-   🔗 **Seamless Backend Integration:** All operations are powered by the secure and reliable FlexPay ASP.NET backend.

## 🏗️ Architecture & State Management

This project is built on a clean 3-layer architecture (Presentation, Core, Data) and employs a pragmatic, hybrid approach to state management.

### A Hybrid Approach to State Management

We believe in using the right tool for the job. Instead of relying on a single state management solution for everything, FlexPay combines **Cubit** and **`setState`** for a clean and efficient codebase.

#### Cubit (`flutter_bloc`)
-   **When it's used:** For managing **shared or complex business state** that affects multiple widgets or requires interaction with the Data layer.
-   **Examples in this app:**
    -   Managing the user's balance across different screens.
    -   Fetching and holding the list of QR transaction history.
    -   Handling loading, success, and error states for network requests.
-   **Why?** Cubit separates business logic from the UI, makes state predictable, and is easily testable.

#### `setState`
-   **When it's used:** For managing **local or ephemeral UI state** that is confined to a single widget.
-   **Examples in this app:**
    -   Controlling animations.
    -   Managing the text in a `TextField` or the state of a `Switch`.
    -   Toggling the visibility of a UI element within a single screen.
-   **Why?** It's lightweight, built-in, and perfect for simple UI changes without the boilerplate of a larger state management solution.

This combination allows us to keep simple UI logic contained and easy to manage, while leveraging the power of Cubit for the app's more complex state requirements.

## 🛠️ Tech Stack & Key Packages

-   **Framework:** Flutter
-   **Language:** Dart
-   **State Management:** [`flutter_bloc`](https://pub.dev/packages/flutter_bloc) (Cubit) & `setState`
-   **Networking:** [`dio`](https://pub.dev/packages/dio) - A powerful HTTP client for making API calls.
-   **QR Generation:** [`qr_flutter`](https://pub.dev/packages/qr_flutter) - For creating QR code widgets.
-   **QR Scanning:** [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) - A high-performance QR and barcode scanner.
-   **Device Info:** [`device_info_plus`](https://pub.dev/packages/device_info_plus) - To get the unique device ID.

## 🚀 Get Started: Setup & Run

Follow these steps to get the app running on your local machine.

### Step 1: Set Up the Backend

The mobile app **cannot function** without the backend service.

1.  Clone and run the **[FlexPay ASP.NET Backend Service](https://github.com/AhmedMohammed204/flex_pay_service)**.
2.  Once the backend is running, find its local network IP address and port.
    -   **On Windows:** Open Command Prompt and type `ipconfig`.
    -   **On macOS/Linux:** Open Terminal and type `ifconfig` or `ip a`.
3.  **⚠️ Important:** Do not use `localhost` or `127.0.0.1`. Your mobile device/emulator cannot resolve it. You need the IP address on your local network (e.g., `192.168.1.10`).

### Step 2: Configure and Run the Flutter App

1.  **Clone this repository:**
    ```sh
    git clone https://github.com/AhmedMohammed204/qr_reader.git
    cd qr_reader
    ```

2.  **Install dependencies:**
    ```sh
    flutter pub get
    ```

3.  **Configure the Backend URL:**
    -   Open the project in your IDE.
    -   Navigate to the file where the API base URL is defined (e.g., `lib/core/services/api_constants.dart`).
    -   Update the `baseUrl` string with the IP address and port from **Step 1**.

    ```dart
    // Example in lib/core/services/api_constants.dart
    class ApiConstants {
      // ⬇️ CHANGE THIS TO YOUR BACKEND'S LOCAL IP ADDRESS AND PORT ⬇️
      static const String baseUrl = "http://192.168.1.10:5143";
    }
    ```

4.  **Run the app:**
    -   Connect a physical device or start an emulator.
    -   Run the app from your IDE or use the command line:
        ```sh
        flutter run
        ```

## ⚠️ MVP Disclaimer

This application is a **proof-of-concept** and is **not production-ready**. It is intended to demonstrate the core functionality of a QR payment system.

-   **No Real Authentication:** User identity is tied to the device ID, which is not a secure or persistent method for a real-world app.
-   **Limited Error Handling:** On-screen error handling is functional but not exhaustive.
