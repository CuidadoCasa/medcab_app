import 'package:app_medcab/firebase_options.dart';
import 'package:app_medcab/src/pages/driver/history/enfermera_history_page.dart';
import 'package:app_medcab/src/pages/driver/history_detail/enfermera_history_detail_page.dart';
import 'package:app_medcab/src/providers/variables_provider.dart';
import 'package:app_medcab/src/shared/colors.dart';
import 'package:flutter/material.dart';
import 'package:app_medcab/src/pages/client/edit/client_edit_page.dart';
import 'package:app_medcab/src/pages/client/history/client_history_page.dart';
import 'package:app_medcab/src/pages/client/history_detail/client_history_detail_page.dart';
import 'package:app_medcab/src/pages/client/map/client_map_page.dart';
import 'package:app_medcab/src/pages/client/travel_calification/client_travel_calification_page.dart';
import 'package:app_medcab/src/pages/client/travel_info/client_travel_info_page.dart';
import 'package:app_medcab/src/pages/client/travel_request/client_travel_request_page.dart';
import 'package:app_medcab/src/pages/driver/edit/driver_edit_page.dart';
import 'package:app_medcab/src/pages/driver/map/driver_map_page.dart';
import 'package:app_medcab/src/pages/driver/register/driver_register_page.dart';
import 'package:app_medcab/src/pages/driver/travel_calification/driver_travel_calification_page.dart';
import 'package:app_medcab/src/pages/driver/travel_request/driver_travel_request_page.dart';
import 'package:app_medcab/src/pages/driver/travel_map/driver_travel_map_page.dart';
import 'package:app_medcab/src/pages/home/home_page.dart';
import 'package:app_medcab/src/pages/login/login_page.dart';
import 'package:app_medcab/src/pages/client/register/client_register_page.dart';
import 'package:app_medcab/src/providers/push_notifications_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:app_medcab/src/pages/client/travel_map/client_travel_map_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env['STRIPE_PK']!;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  final _paletaColors = PaletaColors();

  @override
  void initState() {
    super.initState();

    PushNotificationsProvider pushNotificationsProvider = PushNotificationsProvider();
    pushNotificationsProvider.initPushNotifications();

    pushNotificationsProvider.message.listen((data) {
      navigatorKey.currentState!.pushNamed('driver/travel/request', arguments: data);
    });

  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VariablesProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MedCab',
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [
          Locale('es'),
        ],
        locale: const Locale('es'),
        navigatorKey: navigatorKey,
        initialRoute: 'home',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: _paletaColors.mainA
          ),
          useMaterial3: true,
          // fontFamily: 'Coco',
          appBarTheme: const AppBarTheme(
            elevation: 0
          ),
          primaryColor: _paletaColors.mainB,
          scaffoldBackgroundColor: Colors.white,
        ),
        routes: {
          // 'pruebas': (BuildContext context) => const PruebasPage(),
      
          'home' : (BuildContext context) => const HomePage(),
          'login' : (BuildContext context) => const LoginPage(),
          'client/register' : (BuildContext context) => const ClientRegisterPage(),
          'driver/register' : (BuildContext context) => const DriverRegisterPage(),
          'driver/map' : (BuildContext context) => const DriverMapPage(),
          'driver/travel/request' : (BuildContext context) => const DriverTravelRequestPage(),
          'driver/travel/map' : (BuildContext context) => const DriverTravelMapPage(),
          'driver/travel/calification' : (BuildContext context) => const DriverTravelCalificationPage(),
          'driver/edit' : (BuildContext context) => const DriverEditPage(),
          'driver/history' : (BuildContext context) => const EnfermeraHistoryPage(),
          'driver/history/detail' : (BuildContext context) => const EnfermeraHistoryDetailPage(),
      
          'client/map' : (BuildContext context) => const ClientMapPage(),
          'client/travel/info' : (BuildContext context) => const ClientTravelInfoPage(),
          'client/travel/request' : (BuildContext context) => const ClientTravelRequestPage(),
          'client/travel/map' : (BuildContext context) => const ClientTravelMapPage(),
          'client/travel/calification' : (BuildContext context) => const ClientTravelCalificationPage(),
          'client/edit' : (BuildContext context) => const ClientEditPage(),
          'client/history' : (BuildContext context) => const ClientHistoryPage(),
          'client/history/detail' : (BuildContext context) => const ClientHistoryDetailPage(),
        },
      ),
    );
  }
}
