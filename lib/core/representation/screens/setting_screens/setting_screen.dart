import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:grammar/core/constants/color_constants.dart';
import 'package:grammar/core/constants/dismension_constants.dart';
import 'package:grammar/core/constants/language_constants.dart';
import 'package:grammar/core/provider/theme_provider.dart';
import 'package:grammar/core/models/language.dart';
import 'package:grammar/core/representation/widgets/item_setting_widget.dart';
import 'package:grammar/main.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  static const routeName = "/setting_screen";

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  var currentBackPressTime;
  List<Language> languages = [];
  late String currenLanguage;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      EasyLoading.showToast(translation(context).warningExit);
      return Future.value(false);
    }
    return Future.value(true);
  }

  void _launchURL(String _url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';
  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  void initState() {
    super.initState();
    initLanguage();
  }

  void initLanguage() async {
    languages = Language.languageList().toList();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeNotifier>(context, listen: false);
    bool isDarkTheme = themeProvider.dark!;
    Size screnSize = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(kAppbarRadius),
            ),
          ),
          backgroundColor: ColorPalette.primaryColor,
          title: Text(translation(context).setting,
              style:
                  GoogleFonts.quicksand(color: ColorPalette.appbarTextColor)),
          centerTitle: true,
          automaticallyImplyLeading: false,
          elevation: 0,
        ),
        body: WillPopScope(
          onWillPop: onWillPop,
          child: Container(
              color: ColorPalette.backgroundScaffoldColor,
              padding: EdgeInsets.symmetric(
                  horizontal: screnSize.width * 0.05,
                  vertical: screnSize.height * 0.05),
              child: SafeArea(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(kDefaultPadding),
                      decoration: BoxDecoration(
                        color: ColorPalette.backgroundScaffoldColor,
                        borderRadius: kDefaultBorderRadius,
                        boxShadow: [
                          BoxShadow(
                            color: ColorPalette.shadowColor.withOpacity(0.7),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                              padding: EdgeInsets.all(kDefaultPadding),
                              child: InkWell(
                                onTap: () {},
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Expanded(
                                        flex: 1,
                                        child: Container(
                                          alignment: Alignment.centerLeft,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Icon(
                                                isDarkTheme
                                                    ? Icons.dark_mode
                                                    : Icons.light_mode,
                                                size: kDefaultIconSize,
                                                color: ColorPalette.textColor
                                                    .withOpacity(0.7),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                  translation(context)
                                                      .darkTheme,
                                                  style: GoogleFonts.quicksand(
                                                      fontSize:
                                                          kDefaultFontSize,
                                                      color: ColorPalette
                                                          .textColor))
                                            ],
                                          ),
                                        )),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.centerRight,
                                        child: Switch(
                                          activeColor:
                                              ColorPalette.toggleActiveColor,
                                          activeTrackColor: ColorPalette
                                              .toggleActiveTrackColor,
                                          inactiveThumbColor:
                                              ColorPalette.toggleOffColor,
                                          inactiveTrackColor:
                                              Colors.grey.shade400,
                                          splashRadius: 50.0,
                                          value: isDarkTheme,
                                          onChanged: (value) {
                                            themeProvider.toggleTheme();
                                            setState(() {
                                              print(themeProvider.dark!
                                                  .toString());
                                              isDarkTheme = value;
                                              ColorPalette.changeTheme(
                                                  themeProvider.dark!);
                                            });
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              )),
                          Container(
                              padding: EdgeInsets.all(kDefaultPadding),
                              child: InkWell(
                                onTap: () async {
                                  var currentLanguage = await getLocale();
                                  showModalBottomSheet<void>(
                                      backgroundColor:
                                          ColorPalette.backgroundScaffoldColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(
                                              kDefaultPadding * 2),
                                        ),
                                      ),
                                      isScrollControlled: true,
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Wrap(
                                          children: <Widget>[
                                            Container(
                                              height: screnSize.height * 0.05,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    width: 2,
                                                    color: ColorPalette
                                                        .borderColor),
                                                borderRadius:
                                                    BorderRadius.vertical(
                                                  top: Radius.circular(
                                                      kDefaultPadding * 2),
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: screnSize.height * 0.2,
                                              child: SingleChildScrollView(
                                                child: ListView.builder(
                                                  physics:
                                                      BouncingScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount: languages.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    var item = languages[index];
                                                    return Container(
                                                        color: currentLanguage
                                                                    .toString() ==
                                                                item
                                                                    .languageCode
                                                            ? ColorPalette
                                                                .primaryColor
                                                            : ColorPalette
                                                                .backgroundScaffoldColor,
                                                        height:
                                                            screnSize.height *
                                                                0.08,
                                                        child: InkWell(
                                                          onTap: () async {
                                                            if (item != null) {
                                                              Locale _locale =
                                                                  await setLocale(
                                                                      item.languageCode);
                                                              MyApp.setLocale(
                                                                  context,
                                                                  _locale);
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            }
                                                          },
                                                          child: Center(
                                                            child: Text(
                                                              item.name,
                                                              style: GoogleFonts.quicksand(
                                                                  fontSize:
                                                                      kDefaultFontSize,
                                                                  color: currentLanguage
                                                                              .toString() ==
                                                                          item
                                                                              .languageCode
                                                                      ? ColorPalette
                                                                          .backgroundScaffoldColor
                                                                      : ColorPalette
                                                                          .textColor),
                                                            ),
                                                          ),
                                                        ));
                                                  },
                                                ),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    top: BorderSide(
                                                        width: 0.5,
                                                        color: ColorPalette
                                                            .textColor
                                                            .withOpacity(0.7)),
                                                  ),
                                                ),
                                                height: 50,
                                                child: Center(
                                                  child: Text(
                                                    translation(context).cancel,
                                                    style: GoogleFonts.quicksand(
                                                        fontSize:
                                                            kDefaultFontSize,
                                                        color: ColorPalette
                                                            .cancelColor),
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      });
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Icon(
                                                Icons.language,
                                                color: ColorPalette.textColor
                                                    .withOpacity(0.7),
                                                size: kDefaultIconSize,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                  translation(context).language,
                                                  style: GoogleFonts.quicksand(
                                                      fontSize:
                                                          kDefaultFontSize,
                                                      color: ColorPalette
                                                          .textColor))
                                            ]),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text(
                                                  translation(context)
                                                      .currentLanguage,
                                                  style: GoogleFonts.quicksand(
                                                      fontSize:
                                                          kDefaultFontSize,
                                                      color: ColorPalette
                                                          .textColor
                                                          .withOpacity(0.7))),
                                              Icon(Icons.keyboard_arrow_right,
                                                  color: ColorPalette.textColor
                                                      .withOpacity(0.7))
                                            ],
                                          )),
                                    )
                                  ],
                                ),
                              )),
                          ItemSettingWidget(
                            icon: Icons.star,
                            title: translation(context).rateUs,
                            language: "",
                            ontap: () {
                              _launchURL("https://example.com/");
                            },
                          ),
                          ItemSettingWidget(
                            icon: Icons.feedback,
                            title: translation(context).feedback,
                            language: "",
                            ontap: () {
                              Uri emailLaunchUri = Uri(
                                scheme: 'mailto',
                                path: 'support@nguyendt.dev',
                                query: encodeQueryParameters(<String, String>{
                                  'subject':
                                      'Grammar Checker Android - Feedback'
                                }),
                              );
                              _launchURL(emailLaunchUri.toString());
                            },
                          ),
                          ItemSettingWidget(
                            icon: Icons.privacy_tip,
                            title: translation(context).feedback,
                            language: "",
                            ontap: () {
                              _launchURL("https://example.com/");
                            },
                          ),
                          ItemSettingWidget(
                            icon: Icons.lock,
                            title: translation(context).terms,
                            language: "",
                            ontap: () {
                              _launchURL("https://example.com/");
                            },
                          )
                        ],
                      ),
                    )
                  ]))),
        ));
  }
}
