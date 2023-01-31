import 'package:flutter/material.dart';
import 'package:grammar/core/representation/screens/grammar_check_screens/grammar_check_result_screen.dart';
import 'package:grammar/core/representation/screens/grammar_check_screens/grammar_check_screen.dart';
import 'package:grammar/core/representation/screens/main_screen.dart';
import 'package:grammar/core/representation/screens/paraphrase_screens/paraphrase_result_screen.dart';
import 'package:grammar/core/representation/screens/paraphrase_screens/paraphrase_screen.dart';
import 'package:grammar/core/representation/screens/setting_screens/setting_screen.dart';
import 'package:grammar/core/representation/screens/splash_screen.dart';
import 'package:grammar/core/representation/screens/translate_screens/translate_result_screen.dart';
import 'package:grammar/core/representation/screens/translate_screens/translate_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings setting) {
    switch (setting.name) {
      case SpashScreen.routeName:
        return MaterialPageRoute(builder: (context) => SpashScreen());
      case MainScreen.routeName:
        return MaterialPageRoute(builder: (context) => MainScreen());
      case GrammarCheckScreen.routeName:
        return MaterialPageRoute(builder: (context) => GrammarCheckScreen());
      case GrammarCheckResultScreen.routeName:
        var args = setting.arguments as Map;
        return MaterialPageRoute(
            builder: (context) => GrammarCheckResultScreen(
                  checkString: args['checkString'],
                  result: args['result'],
                ));
      case ParaphraseScreen.routeName:
        return MaterialPageRoute(builder: (context) => ParaphraseScreen());
      case ParaphraseResultScreen.routeName:
        var args = setting.arguments as String;
        return MaterialPageRoute(
            builder: (context) => ParaphraseResultScreen(
                  result: args,
                ));
      case TranslateScreen.routeName:
        return MaterialPageRoute(builder: (context) => TranslateScreen());
      case TranslateResultScreen.routeName:
        var args = setting.arguments as Map;
        return MaterialPageRoute(
            builder: (context) => TranslateResultScreen(
                  result: args['result'],
                  voiceLanguageCode: args['voiceLanguageCode'],
                ));
      case SettingScreen.routeName:
        return MaterialPageRoute(builder: (context) => SettingScreen());
      default:
    }
    return MaterialPageRoute(
        builder: (context) => Scaffold(
              body: Text("No route defined"),
            ));
  }
}
