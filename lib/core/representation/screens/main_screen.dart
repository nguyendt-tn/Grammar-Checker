import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar/core/constants/color_constants.dart';
import 'package:grammar/core/constants/language_constants.dart';
import 'package:grammar/core/provider/theme_provider.dart';
import 'package:grammar/core/representation/screens/grammar_check_screens/grammar_check_screen.dart';
import 'package:grammar/core/representation/screens/paraphrase_screens/paraphrase_screen.dart';
import 'package:grammar/core/representation/screens/setting_screens/setting_screen.dart';
import 'package:grammar/core/representation/screens/translate_screens/translate_screen.dart';
import 'package:provider/provider.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const routeName = 'main_screen';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    initTheme();
  }

  void initTheme() {
    final themeProvider = Provider.of<ThemeNotifier>(context, listen: false);
    ColorPalette.changeTheme(themeProvider.dark!);
  }

  int _currentIndex = 0;
  final List<Widget> _widgetOptions = <Widget>[
    GrammarCheckScreen(),
    ParaphraseScreen(),
    TranslateScreen(),
    SettingScreen()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_currentIndex),
      ),
      bottomNavigationBar: SalomonBottomBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: ColorPalette.primaryColor,
          unselectedItemColor: ColorPalette.primaryColor.withOpacity(0.7),
          items: [
            SalomonBottomBarItem(
              icon: Icon(
                Icons.spellcheck,
                size: 32,
              ),
              title: Text(translation(context).grammar,
                  style: GoogleFonts.quicksand()),
            ),
            SalomonBottomBarItem(
              icon: Icon(
                Icons.article,
                size: 32,
              ),
              title: Text(translation(context).paraphrase,
                  style: GoogleFonts.quicksand()),
            ),
            SalomonBottomBarItem(
              icon: Icon(
                Icons.translate,
                size: 32,
              ),
              title: Text(translation(context).translate,
                  style: GoogleFonts.quicksand()),
            ),
            SalomonBottomBarItem(
              icon: Icon(
                Icons.settings,
                size: 32,
              ),
              title: Text(translation(context).setting,
                  style: GoogleFonts.quicksand()),
            ),
          ]),
    );
  }
}
