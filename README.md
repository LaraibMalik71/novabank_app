
# NovaBank

NovaBank is a modern mobile banking application developed using Flutter and Dart. It provides a clean, professional, and user-friendly banking interface with essential banking features, smooth navigation, and an intuitive digital banking experience.

The application includes account management, money transfers, bill payments, mobile recharges, transaction tracking, card management, beneficiary management, and personalized profile settings.

## Technology Badges

![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white)
![Provider](https://img.shields.io/badge/State%20Management-Provider-7B61A8)
![SQLite](https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite&logoColor=white)
![Material 3](https://img.shields.io/badge/UI-Material%203-6750A4)


<h2 align="center">📱 App Screenshots</h2>

<h3>1. Authentication</h3>
<p align="center">
  <img src="screenshots/splash.png" width="180" alt="Splash Screen">
  &nbsp;&nbsp;
  <img src="screenshots/welcome.png" width="180" alt="Welcome Screen">
  &nbsp;&nbsp;
  <img src="screenshots/signup.png" width="180" alt="Sign Up">
</p>
<p align="center">
  <img src="screenshots/login.png" width="180" alt="Login">
</p>

<h3>2. Dashboard</h3>
<p align="center">
  <img src="screenshots/dashboard_top.png" width="180" alt="Dashboard Top">
  &nbsp;&nbsp;
  <img src="screenshots/dashboard_bottom.png" width="180" alt="Dashboard Bottom">
</p>

<h3>3. Transfers and Payments</h3>
<p align="center">
  <img src="screenshots/send_money_wallet.png" width="180" alt="Mobile Wallet Transfer">
  &nbsp;&nbsp;
  <img src="screenshots/send_money_review.png" width="180" alt="Review Wallet Transfer">
  &nbsp;&nbsp;
  <img src="screenshots/transfer.png" width="180" alt="Bank Transfer">
</p>
<p align="center">
  <img src="screenshots/transfer_review.png" width="180" alt="Review Bank Transfer">
  &nbsp;&nbsp;
  <img src="screenshots/pay_bills.png" width="180" alt="Pay Bills">
  &nbsp;&nbsp;
  <img src="screenshots/pay_bills_review.png" width="180" alt="Review Bill Payment">
</p>
<p align="center">
  <img src="screenshots/recharge.png" width="180" alt="Mobile Recharge">
  &nbsp;&nbsp;
  <img src="screenshots/recharge_review.png" width="180" alt="Review Recharge">
  &nbsp;&nbsp;
  <img src="screenshots/add_money.png" width="180" alt="Add Money">
</p>

<h3>4. Transactions</h3>
<p align="center">
  <img src="screenshots/transactions.png" width="180" alt="Transaction History">
  &nbsp;&nbsp;
  <img src="screenshots/transaction_successful.png" width="180" alt="Successful Transaction">
  &nbsp;&nbsp;
  <img src="screenshots/transaction_failed.png" width="180" alt="Failed Transaction">
</p>

<h3>5. Card Management</h3>
<p align="center">
  <img src="screenshots/my_cards.png" width="180" alt="My Cards">
  &nbsp;&nbsp;
  <img src="screenshots/card_details.png" width="180" alt="Card Details">
</p>

<h3>6. Notifications</h3>
<p align="center">
  <img src="screenshots/notifications.png" width="180" alt="Notifications">
</p>

<h3>7. Profile</h3>
<p align="center">
  <img src="screenshots/profile_top.png" width="180" alt="Profile Top">
  &nbsp;&nbsp;
  <img src="screenshots/profile_bottom.png" width="180" alt="Profile Bottom">
  &nbsp;&nbsp;
  <img src="screenshots/edit_profile.png" width="180" alt="Edit Profile">
</p>

<h3>8. Beneficiaries</h3>
<p align="center">
  <img src="screenshots/beneficiaries.png" width="180" alt="Beneficiaries">
  &nbsp;&nbsp;
  <img src="screenshots/add_beneficiary.png" width="180" alt="Add Beneficiary">
</p>




## Features

- **Authentication:** User registration, login, and persistent sessions.
- **Dashboard:** Account balance, quick actions, and recent transactions.
- **Bank Transfers:** Transfer money using bank transfer functionality.
- **Mobile Wallet Transfers:** Support for popular Pakistani mobile wallet options.
- **Bill Payments:** User-friendly bill payment interface.
- **Mobile Recharge:** Recharge mobile numbers.
- **Add Money:** Add money to the account balance.
- **Transaction Management:** View transaction history, filter transactions, and inspect transaction details.
- **Transaction Status:** Successful, pending, and failed transaction handling.
- **Beneficiary Management:** Add, view, and manage saved beneficiaries.
- **Card Management:** View cards, edit nicknames, block or unblock cards, and remove cards.
- **Notifications:** View in-app notifications and unread indicators.
- **Profile Management:** Edit profile details, change password, manage appearance, and log out.

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application framework |
| Dart | Programming language |
| Provider | State management |
| SQLite (sqflite) | Local database |
| SharedPreferences | Session and preference storage |
| Cryptography | Password hashing |
| Material 3 | UI design and components |

## Project Structure

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

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android emulator or physical device

### Installation

1. Clone the repository:

```bash
git clone https://github.com/LaraibMalik71/novabank_app.git
```

2. Navigate to the project folder:

```bash
cd novabank_app
```

3. Install dependencies:

```bash
flutter pub get
```

4. Run the application:

```bash
flutter run
```

## Verification

Check the project for issues:

```bash
flutter analyze
```

Run the tests:

```bash
flutter test
```

## Developer

**Laraib Malik**

- GitHub: [@LaraibMalik71](https://github.com/LaraibMalik71)
- Repository: [NovaBank](https://github.com/LaraibMalik71/novabank_app)

