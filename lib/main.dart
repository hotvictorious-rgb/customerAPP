import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'core/network/api_client.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/address_provider.dart';
import 'providers/app_config_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/banner_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/cashback_provider.dart';
import 'providers/checkout_provider.dart';
import 'providers/catalog_provider.dart';
import 'providers/order_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/returns_provider.dart';
import 'providers/review_provider.dart';
import 'screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final apiClient = ApiClient(storageService: storageService);

  runApp(
    VictoriousMarketApp(
      storageService: storageService,
      apiClient: apiClient,
    ),
  );
}

class VictoriousMarketApp extends StatelessWidget {
  final StorageService storageService;
  final ApiClient apiClient;

  const VictoriousMarketApp({
    super.key,
    required this.storageService,
    required this.apiClient,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AppConfigProvider(apiClient: apiClient)..fetchConfig(),
        ),
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            apiClient: apiClient,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => BannerProvider(apiClient: apiClient)..fetchBanners(),
        ),
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => AddressProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => CheckoutProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => CashbackProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(apiClient: apiClient)..fetchNotifications(),
        ),
        ChangeNotifierProvider(
          create: (_) => ReturnsProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => ReviewProvider(apiClient: apiClient),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      ),
    );
  }
}
