import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/beneficiary_provider.dart';
import 'screens/auth_gate.dart';
import 'theme/app_theme.dart';
import 'services/notification_service.dart';
import 'providers/card_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => BeneficiaryProvider()),
        ChangeNotifierProvider(create: (_) => CardProvider()),
      ],
      child: const NovaBankApp(),
    ),
  );
}

class NovaBankApp extends StatelessWidget {
  const NovaBankApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NovaBank',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}
