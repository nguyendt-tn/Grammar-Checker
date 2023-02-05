import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:grammar/core/provider/theme_provider.dart';
import 'package:http/http.dart' as http;

import 'package:grammar/core/constants/color_constants.dart';
import 'package:grammar/core/constants/language_constants.dart';
import 'package:grammar/core/constants/dismension_constants.dart';
import 'package:grammar/core/helpers/api_helper.dart';
import 'package:grammar/core/models/grammar.dart';
import 'package:provider/provider.dart';

class GrammarCheckResultScreen extends StatefulWidget {
  const GrammarCheckResultScreen(
      {Key? key, required this.result, required this.checkString})
      : super(key: key);
  static const routeName = '/grammnar_check_result_screen';
  final dynamic result;
  final String checkString;
  @override
  State<GrammarCheckResultScreen> createState() =>
      _GrammarCheckResultScreenState();
}

class _GrammarCheckResultScreenState extends State<GrammarCheckResultScreen> {
  List<TextSpan> spans = [];
  List<String> fixs = [];
  int numError = 0;
  bool isShowError = false;
  late Grammar grammar;
  late String correctedGrammar = "";

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      onCreateCheckResult();
    });
  }

  void onCreateCheckResult() {
    spans.clear();
    fixs.clear();
    var jsonResult = widget.result;

    var matches = jsonResult['matches'];

    var spanText = widget.checkString;
    var index = 0;
    var indexError = 0;
    var spanIndex = 0;

    numError = matches.length;

    for (var mistake in matches) {
      setState(() {
        String beforeSpan = spanText.substring(spanIndex, mistake['offset']);
        spanIndex += beforeSpan.length;

        String errorSpan = spanText.substring(mistake['offset'],
            spanIndex + int.parse(mistake['length'].toString()));
        index++;
        fixs.add(beforeSpan);
        fixs.add(errorSpan);
        spans.add(TextSpan(
            text: beforeSpan,
            style: GoogleFonts.quicksand(
                fontWeight: FontWeight.w500,
                fontSize: 20,
                color: ColorPalette.textColor)));
        indexError += 2;
        mistake['indexError'] = indexError;
        spans.add(TextSpan(
            text: errorSpan,
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w500,
              fontSize: 20,
              color: ColorPalette.textColor,
              decoration: TextDecoration.underline,
              decorationColor: getColor(mistake['rule']['issueType']),
              backgroundColor: getBackground(mistake['rule']['issueType']),
              decorationThickness: 2.5,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                List<String> replace = [];
                mistake['replacements']
                    .forEach((item) => {replace.add(item['value'])});
                setState(() {
                  isShowError = true;
                  grammar = Grammar(
                      index: mistake['indexError'] - 1,
                      offset: mistake['offset'],
                      type: mistake['rule']['issueType'],
                      shortMessage: mistake['shortMessage'],
                      replace: replace,
                      errorWord: errorSpan,
                      message: mistake['message']);
                });
              }));
        spanIndex += errorSpan.length;
        if (index == matches.length) {
          String endSpan = spanText.substring(spanIndex, spanText.length);
          spans.add(TextSpan(
              text: endSpan,
              style: GoogleFonts.quicksand(
                  fontWeight: FontWeight.w500,
                  fontSize: 20,
                  color: ColorPalette.textColor)));
          fixs.add(endSpan);
        }
      });
    }
  }

  Color? getColor(String type) {
    if (type == 'grammar') {
      return ColorPalette.grammarColor;
    }
    if (type == 'typographical') {
      return ColorPalette.typoColor;
    }
    if (type == 'misspelling') {
      return ColorPalette.spellColor;
    }
    return ColorPalette.puncColor;
  }

  Color? getBackground(String type) {
    if (type == 'grammar') {
      return ColorPalette.grammarBackgroundColor;
    }
    if (type == 'typographical') {
      return ColorPalette.typoBackgroundColor;
    }
    if (type == 'misspelling') {
      return ColorPalette.spellBackgroundColor;
    }
    return ColorPalette.puncBackgroundColor;
  }

  String getErrorMessage(String type, String shortMessage) {
    type = type.isNotEmpty ? type.capitalize() : "";
    shortMessage = shortMessage.isNotEmpty ? ": $shortMessage" : "";
    return type + shortMessage;
  }

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
                "Result",
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
      floatingActionButton: numError == 0
          ? FloatingActionButton(
              backgroundColor: ColorPalette.primaryColor,
              elevation: 0.0,
              child: Icon(Icons.file_copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: correctedGrammar));
                EasyLoading.showToast(translation(context).saveMessage);
              },
            )
          : Container(),
      body: Container(
        color: ColorPalette.backgroundScaffoldColor,
        padding: EdgeInsets.symmetric(
            horizontal: screnSize.width * 0.05,
            vertical: screnSize.height * 0.05),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              numError != 0
                  ? SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.all(10),
                        child: SingleChildScrollView(
                            child: RichText(
                                text: TextSpan(children: List.from(spans)))),
                      ),
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.height * 0.55,
                      child: Container(
                        alignment: Alignment.topLeft,
                        padding: EdgeInsets.all(10),
                        child: SingleChildScrollView(
                            child: Text(
                          correctedGrammar,
                          style: GoogleFonts.quicksand(
                              fontSize: kDefaultFontSize,
                              color: ColorPalette.textColor),
                        )),
                      )),
              isShowError != false && numError != 0
                  ? Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(0xffffffff),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, 1), // changes position of shadow
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        physics: BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.emoji_objects,
                                  color: getColor(grammar.type ?? ''),
                                  size: 24,
                                ),
                                Text(" "),
                                Text(
                                  getErrorMessage(grammar.type ?? '',
                                      grammar.shortMessage ?? ''),
                                  style: GoogleFonts.quicksand(
                                      fontWeight: FontWeight.w700,
                                      color: getColor(grammar.type ?? ''),
                                      fontSize: 20),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              children: <Widget>[
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    grammar.errorWord ?? "",
                                    style: GoogleFonts.quicksand(
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: Colors.red,
                                        decorationStyle:
                                            TextDecorationStyle.solid,
                                        fontSize: 19),
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: Colors.grey,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                grammar.replace != null
                                    ? Wrap(
                                        children: grammar.replace!
                                            .map((item) => InkWell(
                                                  onTap: () async {
                                                    setState(() {
                                                      numError--;
                                                      spans[
                                                          grammar
                                                              .index] = TextSpan(
                                                          text: item,
                                                          style: GoogleFonts.quicksand(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 20,
                                                              color: ColorPalette
                                                                  .textColor));
                                                      fixs[grammar.index] =
                                                          item;
                                                      isShowError = false;
                                                    });
                                                    if (numError == 0) {
                                                      String result =
                                                          fixs.join("");
                                                      setState(() {
                                                        correctedGrammar =
                                                            result;
                                                      });
                                                      EasyLoading.show();
                                                      var headers = {
                                                        'Content-Type':
                                                            'application/x-www-form-urlencoded',
                                                        'Accept':
                                                            'application/json',
                                                      };
                                                      var languageToolUri =
                                                          Uri.https(
                                                              APIHelper
                                                                  .grammarCheck,
                                                              "v2/check");
                                                      var respone =
                                                          await http.post(
                                                        languageToolUri,
                                                        headers: headers,
                                                        body: {
                                                          "language": "auto",
                                                          "text": result
                                                        },
                                                      );
                                                      if (respone.statusCode !=
                                                          200) {
                                                        return EasyLoading
                                                            .showError(translation(
                                                                    context)
                                                                .errorMessage);
                                                      }
                                                      try {
                                                        spans.clear();
                                                        fixs.clear();
                                                        var jsonResult = json
                                                            .decode(utf8.decode(
                                                                respone
                                                                    .bodyBytes));

                                                        var matches =
                                                            jsonResult[
                                                                'matches'];
                                                        var spanText = result;
                                                        var index = 0;
                                                        var indexError = 0;
                                                        var spanIndex = 0;

                                                        setState(() {
                                                          numError =
                                                              matches.length;
                                                        });
                                                        if (numError == 0) {
                                                          EasyLoading.showSuccess(
                                                              translation(
                                                                      context)
                                                                  .doneGrammar);
                                                          return;
                                                        }
                                                        for (var mistake
                                                            in matches) {
                                                          setState(() {
                                                            String beforeSpan =
                                                                spanText.substring(
                                                                    spanIndex,
                                                                    mistake[
                                                                        'offset']);

                                                            spanIndex +=
                                                                beforeSpan
                                                                    .length;

                                                            String errorSpan =
                                                                spanText.substring(
                                                                    mistake[
                                                                        'offset'],
                                                                    spanIndex +
                                                                        int.parse(
                                                                            mistake['length'].toString()));
                                                            index++;
                                                            fixs.add(
                                                                beforeSpan);
                                                            fixs.add(errorSpan);
                                                            spans.add(TextSpan(
                                                                text:
                                                                    beforeSpan,
                                                                style: GoogleFonts.quicksand(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        20,
                                                                    color: ColorPalette
                                                                        .textColor)));
                                                            indexError += 2;
                                                            mistake['indexError'] =
                                                                indexError;

                                                            spans.add(TextSpan(
                                                                text: errorSpan,
                                                                style: GoogleFonts
                                                                    .quicksand(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  fontSize: 20,
                                                                  color: ColorPalette
                                                                      .textColor,
                                                                  decoration:
                                                                      TextDecoration
                                                                          .underline,
                                                                  decorationColor:
                                                                      getColor(mistake[
                                                                              'rule']
                                                                          [
                                                                          'issueType']),
                                                                  backgroundColor:
                                                                      getBackground(
                                                                          mistake['rule']
                                                                              [
                                                                              'issueType']),
                                                                  decorationThickness:
                                                                      2.5,
                                                                ),
                                                                recognizer:
                                                                    TapGestureRecognizer()
                                                                      ..onTap =
                                                                          () {
                                                                        List<String>
                                                                            replace =
                                                                            [];
                                                                        mistake['replacements'].forEach((item) =>
                                                                            {
                                                                              replace.add(item['value'])
                                                                            });
                                                                        setState(
                                                                            () {
                                                                          isShowError =
                                                                              true;
                                                                          grammar = Grammar(
                                                                              index: mistake['indexError'] - 1,
                                                                              offset: mistake['offset'],
                                                                              type: mistake['rule']['issueType'],
                                                                              shortMessage: mistake['shortMessage'],
                                                                              replace: replace,
                                                                              errorWord: errorSpan,
                                                                              message: mistake['message']);
                                                                        });
                                                                      }));
                                                            spanIndex +=
                                                                errorSpan
                                                                    .length;
                                                            if (index ==
                                                                matches
                                                                    .length) {
                                                              String endSpan =
                                                                  spanText.substring(
                                                                      spanIndex,
                                                                      spanText
                                                                          .length);
                                                              spans.add(TextSpan(
                                                                  text: endSpan,
                                                                  style: GoogleFonts.quicksand(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      fontSize:
                                                                          20,
                                                                      color: ColorPalette
                                                                          .textColor)));
                                                              fixs.add(endSpan);
                                                            }
                                                          });
                                                        }
                                                        EasyLoading.dismiss();
                                                      } catch (e) {
                                                        EasyLoading.showError(
                                                            translation(context)
                                                                .errorMessage);
                                                      }
                                                    }
                                                  },
                                                  child: FittedBox(
                                                    fit: BoxFit.contain,
                                                    child: Container(
                                                      padding:
                                                          EdgeInsets.all(10),
                                                      margin: EdgeInsets.only(
                                                          right: 10,
                                                          bottom: 10),
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color:
                                                            Color(0xFF00B8BA),
                                                      ),
                                                      child: Text(
                                                        item,
                                                        style: GoogleFonts
                                                            .quicksand(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 17),
                                                      ),
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      )
                                    : Container()
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              grammar.message ?? '',
                              style: GoogleFonts.quicksand(
                                  fontWeight: FontWeight.w500, fontSize: 17),
                            ),
                          ],
                        ),
                      ))
                  : Container()
            ]),
      ),
    );
  }
}
