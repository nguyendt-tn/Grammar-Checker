import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:grammar/core/constants/color_constants.dart';
import 'package:grammar/core/helpers/asset_helper.dart';
import 'package:grammar/core/provider/theme_provider.dart';
import 'package:grammar/core/representation/screens/main_screen.dart';
import 'package:grammar/core/helpers/image_helper.dart';

class SpashScreen extends StatefulWidget {
  const SpashScreen({Key? key}) : super(key: key);

  static const routeName = "/splash_screen";

  @override
  State<SpashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SpashScreen> {
  @override
  void initState() {
    super.initState();
    redirectIntroScreen();
  }

  void redirectIntroScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    // ignore: use_build_context_synchronously
    Navigator.of(context)
        .pushNamedAndRemoveUntil(MainScreen.routeName, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ThemeNotifier notifier, child) {
      return Stack(
        children: [
          Positioned.fill(
              child: Container(
            color: notifier.dark!
                ? ColorPalette.splashScreenDarkColor
                : ColorPalette.splashScreenLightColor,
          )),
          Positioned.fill(
              child: ImageHelper.loadFromAsset(
                  AssetHelper.imageBackgroundSplash,
                  fit: BoxFit.fitWidth)),
        ],
      );
    });
  }
}
