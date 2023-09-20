// ignore_for_file: non_constant_identifier_names

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:toast/toast.dart';
import 'api.dart';
import 'database/db_helper.dart';
import 'model/history.dart';

// ignore: must_be_immutable
class ResultPage extends StatefulWidget {
  final File image;
  final History? history;
  const ResultPage({Key? key, required this.image, this.history})
      : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() => ResultPageState(image);
}

class ResultPageState extends State<ResultPage> {
  DbHelper db = DbHelper();
  // ignore: prefer_typing_uninitialized_variables
  var data;
  File? image;
  String captions_en = "Refresh once !";
  String captions_id = "Refresh once !";
  FlutterTts ftts = FlutterTts();

  ResultPageState(this.image);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          stops: [0.2, 0.6, 0.8],
          colors: [
            Color.fromRGBO(44, 83, 100, 1),
            Color.fromRGBO(32, 58, 67, 1),
            Color.fromRGBO(15, 32, 39, 1),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          // backgroundColor: Color(0x44000000),
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Captions",
            style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: displayImage(image!),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 100,
                width: 200,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Text(
                  captions_en,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                height: 100,
                width: 200,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Text(
                  captions_id,
                  style: const TextStyle(color: Colors.black, fontSize: 20),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        alignment: Alignment.center),
                    onPressed: () {
                      getCaption();
                    },
                    child: const Text(
                      "Refresh",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlue,
                        alignment: Alignment.center),
                    onPressed: () {
                      upsertHistory();
                      Toast.show("UPSERT IMAGE !",
                          duration: Toast.lengthLong,
                          webTexColor: Colors.white,
                          backgroundColor: Colors.black54,
                          backgroundRadius: 15,
                          gravity: Toast.bottom);
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        alignment: Alignment.center),
                    child: const Text(
                      "Audio-EN",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    // elevation: 5.0,
                    // color: Colors.white,
                    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () => speakCaptionEN(),
                  ),
                  const SizedBox(
                    width: 25,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        alignment: Alignment.center),
                    child: const Text(
                      "Audio-ID",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    // elevation: 5.0,
                    // color: Colors.white,
                    // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    onPressed: () => speakCaptionID(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Future getCaption() async {
    var url = Uri.parse(uploadUrl);
    data = await getData(url);

    setState(() {
      captions_en = data['captions_en'];
      captions_id = data['captions_id'];
    });
  }

  speakCaptionEN() async {
    await ftts.setLanguage("en-US");
    await ftts.setPitch(1);
    await ftts.speak(captions_en);
  }

  speakCaptionID() async {
    await ftts.setLanguage("id-ID");
    await ftts.setPitch(1);
    await ftts.speak(captions_id);
  }

  Future<void> upsertHistory() async {
    await Future.delayed(const Duration(seconds: 1));
    var bytes = image!.readAsBytesSync();
    if (await db.getcount(bytes)) {
      //update
      await db.updateHistory(History.fromMap({
        'id': widget.history!.id,
        'caption': captions_en,
        'keterangan': captions_id,
        'image': image,
      }));
    } else {
      //insert
      await db.saveHistory(History(
        caption: captions_en,
        keterangan: captions_id,
        image: bytes,
      ));
    }
  }

  Widget displayImage(File file) {
    return SizedBox(
      height: 250.0,
      width: 200.0,
      // ignore: unnecessary_null_comparison
      child: file == null ? Container() : Image.file(file),
    );
  }
}
