import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'core/database/database_service.dart';
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';
import 'features/auth/auth_screen.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/expenses/transactions_screen.dart';
import 'features/reports/reports_screen.dart';
import 'features/advice/advice_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.init();
  runApp(const ProviderScope(child: MyMoneyApp()));
}

class MyMoneyApp extends StatefulWidget {
  const MyMoneyApp({super.key});

  @override
  State<MyMoneyApp> createState() => _MyMoneyAppState();
}

class _MyMoneyAppState extends State<MyMoneyApp> with WidgetsBindingObserver {
  bool _isAuthenticated = false;
  bool _requiresBiometric = false;
  bool _hasCheckedBiometric = false;
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuth();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      setState(() => _hasCheckedBiometric = false);
    } else if (state == AppLifecycleState.resumed && _isAuthenticated && !_hasCheckedBiometric) {
      _authenticateBiometric();
    }
  }

  Future<void> _checkAuth() async {
    final user = await AuthService.getCurrentUser();
    
    if (user != null) {
      setState(() => _isAuthenticated = true);
      await _authenticateBiometric();
    } else {
      setState(() => _isAuthenticated = false);
    }
  }

  Future<void> _authenticateBiometric() async {
    if (_hasCheckedBiometric) return;
    
    setState(() {
      _requiresBiometric = true;
      _hasCheckedBiometric = true;
    });
    
    await Future.delayed(const Duration(milliseconds: 300));
    await _performBiometric();
  }

  Future<void> _performBiometric() async {
    try {
      final canAuth = await _localAuth.canCheckBiometrics;
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      print('Can authenticate: $canAuth');
      print('Available biometrics: $availableBiometrics');
      
      if (!canAuth || availableBiometrics.isEmpty) {
        print('No biometric available, skipping');
        setState(() => _requiresBiometric = false);
        return;
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access My Money',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );

      print('Authentication result: $authenticated');

      if (authenticated) {
        setState(() => _requiresBiometric = false);
      } else {
        // User cancelled or failed
        setState(() => _requiresBiometric = false);
      }
    } catch (e) {
      print('Biometric error: $e');
      setState(() => _requiresBiometric = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_requiresBiometric) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.fingerprint, size: 80),
                const SizedBox(height: 24),
                const Text('Authenticate to continue', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _authenticateBiometric,
                  child: const Text('Unlock'),
                ),
              ],
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    return MaterialApp(
      title: 'My Money',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: _isAuthenticated ? const MainScreen() : AuthScreen(onAuthenticated: () => setState(() => _isAuthenticated = true)),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const TransactionsScreen(),
    const ReportsScreen(),
    const AdviceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: 'Transactions',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          NavigationDestination(
            icon: Icon(Icons.lightbulb_outlined),
            selectedIcon: Icon(Icons.lightbulb),
            label: 'Advice',
          ),
        ],
      ),
    );
  }
}