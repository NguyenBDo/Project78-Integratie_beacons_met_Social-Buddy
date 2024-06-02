import 'dart:async';

import 'package:buddy_bot/firebase_options.dart';
import 'package:buddy_bot/views/body_detect_file.dart';
import 'package:buddy_bot/views/login_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sizer/sizer.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:provider/provider.dart';

import 'config/config_exporter.dart';
import 'languages/localization.dart';
import 'utils/utils_exporter.dart';
import 'views/view_exporter.dart';
import 'controller/flic/flic_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await Firebase.initializeApp();
  DefaultFirebaseOptions.currentPlatform;
  // await FirebaseRemoteConfigService().remoteConfig.setConfigSettings(RemoteConfigSettings(
  //       fetchTimeout: const Duration(minutes: 1),
  //       minimumFetchInterval: const Duration(seconds: 1),
  //     ));
  await initRemoteConfig();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      // statusBarColor: AppColors.white,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light));

  const fatalError = true;

  if (!kDebugMode) {
    // Non-async exceptions
    FlutterError.onError = (errorDetails) {
      if (fatalError) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        // ignore: dead_code
      } else {
        FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      }
    };

    // Async exceptions
    PlatformDispatcher.instance.onError = (error, stack) {
      if (fatalError) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        // ignore: dead_code
      } else {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }
      return true;
    };
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ButtonState(),
      child: const MyApp(),
    ),
  );
}

StreamSubscription? remoteConfigSubscription;

Future<void> initRemoteConfig() async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  try {
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 2),
      ),
    );
    await remoteConfig.fetchAndActivate();

    if (remoteConfigSubscription != null) {
      await remoteConfigSubscription!.cancel();
      remoteConfigSubscription = null;
    }
    try {
      remoteConfigSubscription = remoteConfig.onConfigUpdated.listen((event) async {
        await remoteConfig.activate();
        debugPrint('RemoteConfig UPDATED: ${event.updatedKeys}');
      }, onError: (e) {
        debugPrint('RemoteConfig ERROR: $e');
      });
    } catch (e) {
      debugPrint("REMOTE CONFIG ERROR  ${e.toString()}");
    }
  } catch (e) {
    debugPrint("REMOTE CONFIG ERROR 11111  ${e.toString()}");
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

const _kTestingCrashlytics = false;
const _kShouldTestAsyncErrorOnInit = false;

class _MyAppState extends State<MyApp> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  // late Future<void> _initializeFlutterFireFuture;

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      // final List<int> list = <int>[];
    });
  }

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    if (_kTestingCrashlytics) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    if (_kShouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }

  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await _initializeFlutterFire();
      FirebaseRemoteConfigService().remoteConfig.onConfigUpdated.listen((event) async {
        await FirebaseRemoteConfigService().remoteConfig.activate();
        // Use the new config values here.
        authController.buddyBotMaxCount.value = FirebaseRemoteConfigService().buddyBotMaxCount;
        // debugPrint("here comes ${buddyBotMaxCount.value}  ${event.updatedKeys}");
      });
      // Keep the screen on.
      // KeepScreenOn.turnOn();
      await WakelockPlus.enable();
    });
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      e.printError();
      return;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    authController.connectionStatus.value = result;
    checkIsConnected(authController.connectionStatus.value);
  }

  void checkIsConnected(ConnectivityResult value) {
    if (authController.connectionStatus.value == ConnectivityResult.mobile) {
      // I am connected to a mobile network.
      authController.isConnected.value = true;
      if (isUserConfigured.value == false) {
        UserPresence().configureUserPresence();
      }
      return;
    } else if (authController.connectionStatus.value == ConnectivityResult.wifi) {
      // I am connected to a wifi network.
      authController.isConnected.value = true;
      if (isUserConfigured.value == false) {
        UserPresence().configureUserPresence();
      }
      return;
    }
    authController.isConnected.value = false;
  }

  @override
  Widget build(BuildContext context) {
    ///Set default orientations the application interface can be displayed in (avoid portrait view).
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight, //Amazon Fire device when camera down
      DeviceOrientation.landscapeLeft, //Amazon Fire device when camera Up
    ]);
    return Sizer(builder: (context, orientation, deviceType) {
      return GetMaterialApp(
          translationsKeys: AppTranslation.translationsKeys,
          locale: Get.deviceLocale,
          fallbackLocale: const Locale('en', "US"),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            scaffoldBackgroundColor: AppColors.lightBgColor,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            primaryColor: AppColors.primaryColor,
            secondaryHeaderColor: AppColors.secondaryColor,
            appBarTheme: const AppBarTheme(
              elevation: 0, // This removes the shadow from all App Bars.
            ),
            colorScheme: const ColorScheme.light(
              // change the border color
              primary: AppColors.primaryColor,
              // change the text color
              onSurface: AppColors.mainFontColor,
            ),
          ),
          home: !getIsLogin()? const LoginScreen():
          authController.getPref.read(PrefString.connectedUsers) == true
              ? const HomeScreen()
              : getIsLogin() && getVoucherData() != null
                  ? const QrCodeScreen()
                  : const VoucherCodeScreen());
    });
  }
}
