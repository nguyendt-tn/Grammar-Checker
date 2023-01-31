import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:grammar/core/constants/color_constants.dart';
import 'package:grammar/core/constants/dismension_constants.dart';
import 'package:grammar/core/constants/language_constants.dart';
import 'package:grammar/core/provider/theme_provider.dart';
import 'package:provider/provider.dart';

class TranslateResultScreen extends StatefulWidget {
  const TranslateResultScreen(
      {Key? key, required this.result, required this.voiceLanguageCode})
      : super(key: key);
  static const routeName = "/translate_result_screen";
  final String result;
  final String voiceLanguageCode;

  @override
  State<TranslateResultScreen> createState() => _TranslateResultScreenState();
}

class _TranslateResultScreenState extends State<TranslateResultScreen> {
  bool isHearing = false;
  FlutterTts flutterTts = FlutterTts();

  @override
  Widget build(BuildContext context) {
    final screnSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(kAppbarRadius),
          ),
        ),
        backgroundColor: ColorPalette.primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Expanded(child: Container()),
            Expanded(
                child: Center(
              child: Text(
                translation(context).result,
                style:
                    GoogleFonts.quicksand(color: ColorPalette.appbarTextColor),
              ),
            )),
            Expanded(
                child: Container(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            )),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: Container(
          color: ColorPalette.backgroundScaffoldColor,
          padding: EdgeInsets.symmetric(
              horizontal: screnSize.width * 0.05,
              vertical: screnSize.height * 0.05),
          child: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ColorPalette.backgroundScaffoldColor,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: ColorPalette.shadowColor.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Text(
                              widget.result,
                              style: TextStyle(
                                  fontSize: 18, color: ColorPalette.textColor),
                            ),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: <Widget>[
                                  SizedBox(
                                      child: Row(children: <Widget>[
                                    IconButton(
                                      icon: Icon(
                                        isHearing == true
                                            ? Icons.volume_up
                                            : Icons.volume_up_outlined,
                                        color: ColorPalette.primaryColor,
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          isHearing = true;
                                        });
                                        await flutterTts.setLanguage(
                                            widget.voiceLanguageCode);
                                        await flutterTts.speak(widget.result);
                                        flutterTts.setCompletionHandler(() {
                                          setState(() {
                                            isHearing = false;
                                          });
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.copy,
                                          color: ColorPalette.primaryColor),
                                      onPressed: () {
                                        Clipboard.setData(
                                            ClipboardData(text: widget.result));
                                        EasyLoading.showToast(
                                            translation(context).saveMessage);
                                      },
                                    )
                                  ]))
                                ]),
                          ]),
                    ),
                  ),
                ]),
          )),
    );
  }
}
