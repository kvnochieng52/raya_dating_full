import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'router/app_router.dart';
import 'services/auth_state.dart';
import 'services/connectivity_service.dart';
import 'theme/app_theme.dart';
import 'utils/constants.dart';
import 'widgets/offline_banner.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  await Future.wait([
    AuthState.instance.bootstrap(),
    ConnectivityService.instance.init(),
  ]);

  runApp(const KingdomDatingApp());
}

class KingdomDatingApp extends StatefulWidget {
  const KingdomDatingApp({super.key});

  @override
  State<KingdomDatingApp> createState() => _KingdomDatingAppState();
}

class _KingdomDatingAppState extends State<KingdomDatingApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: _router,
      builder: (context, child) => OfflineBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
