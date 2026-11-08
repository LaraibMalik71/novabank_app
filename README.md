
# 🏦 NovaBank

NovaBank is a modern mobile banking application built with **Flutter and Dart**, designed to provide a smooth, intuitive, and user-friendly digital banking experience.

The application brings essential banking operations together in one place, including account management, money transfers, bill payments, mobile recharges, transaction tracking, card management, beneficiary management, and personalized profile settings.

## 🛠️ Technology Badges

![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white)
![Provider](https://img.shields.io/badge/State%20Management-Provider-7B61A8)
![SQLite](https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite&logoColor=white)
![Material 3](https://img.shields.io/badge/UI-Material%203-6750A4)

<h2 align="center">📱 App Screenshots</h2>

<h3>1. Authentication</h3>
<p align="center">
  <img src="screenshots/splash.png" width="120" alt="Splash Screen">
  <img src="screenshots/welcome.png" width="120" alt="Welcome Screen">
  <img src="screenshots/signup.png" width="120" alt="Sign Up">
  <img src="screenshots/login.png" width="120" alt="Login">
</p>

<h3>2. Dashboard</h3>
<p align="center">
  <img src="screenshots/dashboard_top.png" width="180" alt="Dashboard Top">
  <img src="screenshots/dashboard_bottom.png" width="180" alt="Dashboard Bottom">
</p>

<h3>3. Transfers and Payments</h3>
<p align="center">
  <img src="screenshots/send_money_wallet.png" width="180" alt="Mobile Wallet Transfer">
  <img src="screenshots/send_money_review.png" width="180" alt="Review Wallet Transfer">
  <img src="screenshots/transfer.png" width="180" alt="Bank Transfer">
</p>
<p align="center">
  <img src="screenshots/transfer_review.png" width="180" alt="Review Bank Transfer">
  <img src="screenshots/pay_bills.png" width="180" alt="Pay Bills">
  <img src="screenshots/pay_bills_review.png" width="180" alt="Review Bill Payment">
</p>
<p align="center">
  <img src="screenshots/recharge.png" width="180" alt="Mobile Recharge">
  <img src="screenshots/recharge_review.png" width="180" alt="Review Recharge">
  <img src="screenshots/add_money.png" width="180" alt="Add Money">
</p>

<h3>4. Transactions</h3>
<p align="center">
  <img src="screenshots/transactions.png" width="180" alt="Transaction History">
  <img src="screenshots/transaction_successful.png" width="180" alt="Successful Transaction">
  <img src="screenshots/transaction_failed.png" width="180" alt="Failed Transaction">
</p>

<h3>5. Card Management</h3>
<p align="center">
  <img src="screenshots/my_cards.png" width="180" alt="My Cards">
  <img src="screenshots/card_details.png" width="180" alt="Card Details">
</p>

<h3>6. Notifications</h3>
<p align="center">
  <img src="screenshots/notifications.png" width="180" alt="Notifications">
</p>

<h3>7. Profile</h3>
<p align="center">
  <img src="screenshots/profile_top.png" width="180" alt="Profile Top">
  <img src="screenshots/profile_bottom.png" width="180" alt="Profile Bottom">
  <img src="screenshots/edit_profile.png" width="180" alt="Edit Profile">
</p>

<h3>8. Beneficiaries</h3>
<p align="center">
  <img src="screenshots/beneficiaries.png" width="180" alt="Beneficiaries">
  <img src="screenshots/add_beneficiary.png" width="180" alt="Add Beneficiary">
</p>

## ✨ Features

- **Authentication:** User registration, login, and persistent session management.
- **Dashboard:** Displays account balance, quick action shortcuts, and recent transactions.
- **Bank Transfers:** Provides an interface for making bank transfers.
- **Mobile Wallet Transfers:** Supports popular Pakistani mobile wallet options.
- **Bill Payments:** Provides a convenient interface for managing bill payments.
- **Mobile Recharge:** Allows users to recharge mobile numbers.
- **Add Money:** Allows users to add money to their in-app account balance.
- **Transaction Management:** View transaction history, filter records, and inspect individual transaction details.
- **Transaction Status:** Handles successful, pending, and failed transaction states.
- **Beneficiary Management:** Add, view, and manage saved beneficiaries.
- **Card Management:** View card details, edit card nicknames, block or unblock cards, and remove cards.
- **Notifications:** View in-app notifications and track unread notifications.
- **Profile Management:** Edit personal details, change password, manage app appearance, and log out.

> **Note:** NovaBank is an internship/demo application. Banking operations are handled locally within the application and are not connected to real banking services or payment networks.

## 🧰 Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile application development |
| Dart | Application programming language |
| Provider | State management |
| SQLite (sqflite) | Local data storage |
| SharedPreferences | Session and user preference storage |
| Cryptography | Password hashing |
| Material 3 | User interface design and components |

## 🏗️ Project Structure

```text
novabank_app/
├── android/
├── ios/
├── lib/
│   ├── models/
│   ├── providers/
│   ├── screens/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   └── widgets/
├── screenshots/
├── test/
├── pubspec.yaml
└── README.md
```

## 🚀 Getting Started

Follow these steps to set up and run NovaBank on your local machine.

### 📋 Prerequisites

Make sure you have the following installed:

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android emulator or a physical Android device

### 📥 Installation

**1. Clone the repository**

```bash
git clone https://github.com/LaraibMalik71/novabank_app.git
```

**2. Navigate to the project directory**

```bash
cd novabank_app
```

**3. Install the required dependencies**

```bash
flutter pub get
```

**4. Run the application**

```bash
flutter run
```

## 🧪 Verification

Use the following commands to check code quality and run the project's tests.

**Analyze the project**

```bash
flutter analyze
```

**Run automated tests**

```bash
flutter test
```

## 👩‍💻 Developer

**Laraib Malik**

- **GitHub:** [@LaraibMalik71](https://github.com/LaraibMalik71)
- **Project Repository:** [NovaBank](https://github.com/LaraibMalik71/novabank_app)


