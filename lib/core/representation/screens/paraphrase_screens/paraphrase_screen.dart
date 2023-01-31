import 'dart:convert';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:simple_ocr_plugin/simple_ocr_plugin.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'package:grammar/core/constants/color_constants.dart';
import 'package:grammar/core/constants/dismension_constants.dart';
import 'package:grammar/core/representation/widgets/button_widget.dart';
import 'package:grammar/core/constants/language_constants.dart';
import 'package:grammar/core/helpers/api_helper.dart';
import 'package:grammar/core/helpers/speech_helper.dart';
import 'package:grammar/core/provider/theme_provider.dart';
import 'package:grammar/core/representation/screens/paraphrase_screens/paraphrase_result_screen.dart';

class ParaphraseScreen extends StatefulWidget {
  const ParaphraseScreen({super.key});
  static const routeName = '/paraphrase_screen';

  @override
  State<ParaphraseScreen> createState() => _ParaphraseScreenState();
}

class _ParaphraseScreenState extends State<ParaphraseScreen> {
  bool speechEnabled = false;
  var currentBackPressTime;
  final TextEditingController _paraphraseController = TextEditingController();

  void pickGallery() async {
    PickedFile? image =
        await ImagePicker().getImage(source: ImageSource.gallery);
    cropImage(File(image!.path));
  }

  void pickCamera() async {
    PickedFile? image =
        await ImagePicker().getImage(source: ImageSource.camera);
    cropImage(File(image!.path));
  }

  void cropImage(File filePath) async {
    CroppedFile? croppedFile = await ImageCropper()
        .cropImage(sourcePath: filePath.path, aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ], uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: ColorPalette.primaryColor,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.ratio3x2,
        lockAspectRatio: false,
      )
    ]);
    if (croppedFile != null) {
      EasyLoading.show();
      try {
        String resultString =
            await SimpleOcrPlugin.performOCR(croppedFile.path);
        var jsonResult = json.decode(resultString);
        if (jsonResult['code'] != 200) {
          return EasyLoading.showError(translation(context).errorMessage);
        }
        var text = jsonResult['text'];
        text = text.replaceAll(RegExp(' +'), ' ');
        EasyLoading.dismiss();
        _paraphraseController.value = TextEditingValue(
          text: text,
          selection:
              TextSelection.fromPosition(TextPosition(offset: text.length)),
        );
        setState(() {});
        return EasyLoading.dismiss();
      } catch (e) {
        return EasyLoading.showError(translation(context).errorMessage);
      }
    }
  }

  void _clearTextField() {
    _paraphraseController.clear();
    setState(() {});
  }

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

  @override
  void initState() {
    super.initState();
  }

  Future toggleRecording() => SpeechHelper.toggleRecording(
      onResult: (text) => setState(() => _onSpeechResult(text)),
      onListening: (isListening) {});

  void _onSpeechResult(text) {
    speechEnabled = false;
    _paraphraseController.value = TextEditingValue(
      text: text,
      selection: TextSelection.fromPosition(TextPosition(offset: text.length)),
    );
  }

  @override
  void dispose() {
    _paraphraseController.dispose();
    super.dispose();
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
          title: Text(
            translation(context).paraphrase,
            style: GoogleFonts.quicksand(color: ColorPalette.appbarTextColor),
          ),
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
                  child: SingleChildScrollView(
                      padding:
                          EdgeInsets.symmetric(horizontal: kDefaultPadding / 4),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            SizedBox(
                              height: screnSize.height * 0.4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: kDefaultPadding),
                                decoration: BoxDecoration(
                                    color: ColorPalette.backgroundScaffoldColor,
                                    borderRadius: kDefaultBorderRadius,
                                    boxShadow: [
                                      BoxShadow(
                                        color: ColorPalette.shadowColor
                                            .withOpacity(0.5),
                                        spreadRadius: 1,
                                        blurRadius: 1,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]),
                                child: Column(children: <Widget>[
                                  SizedBox(
                                    height: screnSize.height * 0.3,
                                    child: TextField(
                                      controller: _paraphraseController,
                                      minLines: 5,
                                      maxLines: null,
                                      style: GoogleFonts.quicksand(
                                          fontSize: 18,
                                          color: ColorPalette.textColor),
                                      decoration: InputDecoration(
                                        hintText:
                                            translation(context).typeParaphrase,
                                        hintStyle: GoogleFonts.quicksand(
                                            fontSize: 18,
                                            color: ColorPalette.textColor),
                                        labelStyle: GoogleFonts.quicksand(
                                            fontSize: 18,
                                            color: ColorPalette.textColor),
                                        hintMaxLines: 5,
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                      ),
                                      autofocus: false,
                                      onChanged: ((value) => setState(() {})),
                                    ),
                                  ),
                                  SizedBox(
                                    height: screnSize.height * 0.1,
                                    child: Container(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: <Widget>[
                                            SizedBox(
                                              child: Row(children: <Widget>[
                                                IconButton(
                                                  icon: Icon(
                                                    Icons.camera_alt,
                                                    color: ColorPalette
                                                        .primaryColor,
                                                    size: 30,
                                                  ),
                                                  onPressed: () => pickCamera(),
                                                ),
                                                SizedBox(width: 10),
                                                IconButton(
                                                  icon: Icon(
                                                    Icons
                                                        .photo_size_select_actual,
                                                    color: ColorPalette
                                                        .primaryColor,
                                                    size: 30,
                                                  ),
                                                  onPressed: () =>
                                                      pickGallery(),
                                                ),
                                                SizedBox(width: 10),
                                                IconButton(
                                                  icon: Icon(
                                                    speechEnabled
                                                        ? Icons.mic_off
                                                        : Icons.mic,
                                                    color: ColorPalette
                                                        .primaryColor,
                                                    size: 30,
                                                  ),
                                                  onPressed: () async {
                                                    setState(() {
                                                      speechEnabled = true;
                                                    });
                                                    await toggleRecording();
                                                  },
                                                ),
                                              ]),
                                            ),
                                            SizedBox(
                                                child: Row(
                                              children: <Widget>[
                                                SizedBox(
                                                  child: IconButton(
                                                    icon: Icon(
                                                      Icons.file_copy,
                                                      color: ColorPalette
                                                          .primaryColor,
                                                      size: 30,
                                                    ),
                                                    onPressed: () async {
                                                      ClipboardData? data =
                                                          await Clipboard
                                                              .getData(
                                                                  'text/plain');
                                                      setState(() {
                                                        _paraphraseController
                                                                .value =
                                                            TextEditingValue(
                                                          text: data!.text!,
                                                          selection: TextSelection
                                                              .fromPosition(
                                                                  TextPosition(
                                                                      offset: data
                                                                          .text!
                                                                          .length)),
                                                        );
                                                      });
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  child: _paraphraseController
                                                          .text.isEmpty
                                                      ? null
                                                      : IconButton(
                                                          icon: Icon(
                                                            Icons
                                                                .cancel_outlined,
                                                            color: ColorPalette
                                                                .primaryColor,
                                                            size: 30,
                                                          ),
                                                          onPressed: () {
                                                            _clearTextField();
                                                          },
                                                        ),
                                                ),
                                              ],
                                            )),
                                          ]),
                                    ),
                                  )
                                ]),
                              ),
                            ),
                            SizedBox(
                              height: screnSize.height * 0.15,
                            ),
                            ButtonWidget(
                                title: translation(context).paraphrase,
                                ontap: () async {
                                  EasyLoading.show();
                                  if (_paraphraseController.text.isEmpty) {
                                    return EasyLoading.showToast(
                                        translation(context).requireMessage);
                                  }
                                  ConnectivityResult result =
                                      await (Connectivity()
                                          .checkConnectivity());
                                  if (result == ConnectivityResult.none) {
                                    return EasyLoading.showToast(
                                        translation(context).disconnectMessage);
                                  }
                                  var languageToolUri = Uri.https(
                                      APIHelper.paraphraseAPI,
                                      "rewritearticlepro.php",
                                      {"action": "{rewrite}"});
                                  print(languageToolUri);
                                  var respone = await http.post(
                                    languageToolUri,
                                    body: {
                                      "keep": "0",
                                      "data": _paraphraseController.text
                                    },
                                  );
                                  if (respone.statusCode != 200) {
                                    return EasyLoading.showError(
                                        translation(context).errorMessage);
                                  }
                                  EasyLoading.dismiss();
                                  // ignore: use_build_context_synchronously
                                  Navigator.of(context).pushNamed(
                                      ParaphraseResultScreen.routeName,
                                      arguments: respone.body);
                                })
                          ])))),
        ));
  }
}
