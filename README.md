
# NovaBank

NovaBank is a modern mobile banking application developed using Flutter and Dart. It provides a clean, professional, and user-friendly banking interface with essential banking features, smooth navigation, and an intuitive digital banking experience.

The application includes account management, money transfers, bill payments, mobile recharges, transaction tracking, card management, beneficiary management, and personalized profile settings.

## Technology Badges

![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white)
![Provider](https://img.shields.io/badge/State%20Management-Provider-7B61A8)
![SQLite](https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite&logoColor=white)
![Material 3](https://img.shields.io/badge/UI-Material%203-6750A4)

## Screenshots

### 1. Authentication

<table>
<tr>
<td align="center"><img src="screenshots/splash.png" width="220"><br><b>Splash Screen</b></td>
<td align="center"><img src="screenshots/welcome.png" width="220"><br><b>Welcome Screen</b></td>
<td align="center"><img src="screenshots/signup.png" width="220"><br><b>Sign Up</b></td>
</tr>
<tr>
<td align="center"><img src="screenshots/login.png" width="220"><br><b>Login</b></td>
<td></td>
<td></td>
</tr>
</table>

### 2. Dashboard

<table>
<tr>
<td align="center"><img src="screenshots/dashboard_top.png" width="220"><br><b>Dashboard — Top</b></td>
<td align="center"><img src="screenshots/dashboard_bottom.png" width="220"><br><b>Dashboard — Bottom</b></td>
<td></td>
</tr>
</table>

### 3. Transfers and Payments

<table>
<tr>
<td align="center"><img src="screenshots/send_money_wallet.png" width="220"><br><b>Mobile Wallet Transfer</b></td>
<td align="center"><img src="screenshots/send_money_review.png" width="220"><br><b>Review Wallet Transfer</b></td>
<td align="center"><img src="screenshots/transfer.png" width="220"><br><b>Bank Transfer</b></td>
</tr>
<tr>
<td align="center"><img src="screenshots/transfer_review.png" width="220"><br><b>Review Bank Transfer</b></td>
<td align="center"><img src="screenshots/pay_bills.png" width="220"><br><b>Pay Bills</b></td>
<td align="center"><img src="screenshots/pay_bills_review.png" width="220"><br><b>Review Bill Payment</b></td>
</tr>
<tr>
<td align="center"><img src="screenshots/recharge.png" width="220"><br><b>Mobile Recharge</b></td>
<td align="center"><img src="screenshots/recharge_review.png" width="220"><br><b>Review Recharge</b></td>
<td align="center"><img src="screenshots/add_money.png" width="220"><br><b>Add Money</b></td>
</tr>
</table>

### 4. Transactions

<table>
<tr>
<td align="center"><img src="screenshots/transactions.png" width="220"><br><b>Transaction History</b></td>
<td align="center"><img src="screenshots/transaction_successful.png" width="220"><br><b>Successful Transaction</b></td>
<td align="center"><img src="screenshots/transaction_failed.png" width="220"><br><b>Failed Transaction</b></td>
</tr>
</table>

### 5. Card Management

<table>
<tr>
<td align="center"><img src="screenshots/my_cards.png" width="220"><br><b>My Cards</b></td>
<td align="center"><img src="screenshots/card_details.png" width="220"><br><b>Card Details</b></td>
<td></td>
</tr>
</table>

### 6. Notifications

<table>
<tr>
<td align="center"><img src="screenshots/notifications.png" width="220"><br><b>Notifications</b></td>
<td></td>
<td></td>
</tr>
</table>

### 7. Profile

<table>
<tr>
<td align="center"><img src="screenshots/profile_top.png" width="220"><br><b>Profile — Top</b></td>
<td align="center"><img src="screenshots/profile_bottom.png" width="220"><br><b>Profile — Bottom</b></td>
<td align="center"><img src="screenshots/edit_profile.png" width="220"><br><b>Edit Profile</b></td>
</tr>
</table>

### 8. Beneficiaries

<table>
<tr>
<td align="center"><img src="screenshots/beneficiaries.png" width="220"><br><b>Beneficiaries</b></td>
<td align="center"><img src="screenshots/add_beneficiary.png" width="220"><br><b>Add Beneficiary</b></td>
<td></td>
</tr>
</table>

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

