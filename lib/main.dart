import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/app_router.dart';
import 'core/widgets/dismiss_keyboard.dart';
import 'core/providers/app_settings_provider.dart';

late AppSettingsProvider appSettings;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await initializeDateFormatting('es');
  await initializeDateFormatting('en');

  appSettings = AppSettingsProvider();
  await appSettings.load();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: appSettings,
      child: Consumer<AppSettingsProvider>(
        builder: (context, settings, _) {
          return AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
            child: MaterialApp(
              title: 'Nail Salon',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              initialRoute: AppRoutes.splash,
              onGenerateRoute: AppRouter.generateRoute,
              builder: (context, child) => DismissKeyboard(child: child!),
            ),
          );
        },
      ),
    );
  }
}
