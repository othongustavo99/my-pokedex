import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'storage/theme_storage.dart';

void main() {
  runApp(const PokedexApp());
}

class PokedexApp extends StatefulWidget {
  const PokedexApp({super.key});

  @override
  State<PokedexApp> createState() => _PokedexAppState();

  /// Acesso ao estado do tema de qualquer lugar.
  static _PokedexAppState of(BuildContext context) {
    return context.findAncestorStateOfType<_PokedexAppState>()!;
  }
}

class _PokedexAppState extends State<PokedexApp> {
  final ThemeStorage _themeStorage = ThemeStorage();
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final mode = await _themeStorage.getThemeMode();
    if (mounted) setState(() => _themeMode = mode);
  }

  void setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    _themeStorage.saveThemeMode(mode);
  }

  ThemeMode get themeMode => _themeMode;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pokédex',
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.red,
        brightness: Brightness.dark,
      ),
      home: const HomePage(),
    );
  }
}
