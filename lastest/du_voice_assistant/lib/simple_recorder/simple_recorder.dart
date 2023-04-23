/*
 * Copyright 2018, 2019, 2020, 2021 Dooboolab.
 *
 * This file is part of Flutter-Sound.
 *
 * Flutter-Sound is free software: you can redistribute it and/or modify
 * it under the terms of the Mozilla Public License version 2 (MPL2.0),
 * as published by the Mozilla organization.
 *
 * Flutter-Sound is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * MPL General Public License for more details.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

import 'dart:async';
import 'dart:io';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_curl/flutter_curl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
/*
 * This is an example showing how to record to a Dart Stream.
 * It writes all the recorded data from a Stream to a File, which is completely stupid:
 * if an App wants to record something to a File, it must not use Streams.
 *
 * The real interest of recording to a Stream is for example to feed a
 * Speech-to-Text engine, or for processing the Live data in Dart in real time.
 *
 */

///
typedef _Fn = void Function();

/* This does not work. on Android we must have the Manifest.permission.CAPTURE_AUDIO_OUTPUT permission.
 * But this permission is _is reserved for use by system components and is not available to third-party applications._
 * Pleaser look to [this](https://developer.android.com/reference/android/media/MediaRecorder.AudioSource#VOICE_UPLINK)
 *
 * I think that the problem is because it is illegal to record a communication in many countries.
 * Probably this stands also on iOS.
 * Actually I am unable to record DOWNLINK on my Xiaomi Chinese phone.
 *
 */
//const theSource = AudioSource.voiceUpLink;
//const theSource = AudioSource.voiceDownlink;

const theSource = AudioSource.microphone;

/// Example app.
class SimpleRecorder extends StatefulWidget {
  @override
  _SimpleRecorderState createState() => _SimpleRecorderState();
}

class _SimpleRecorderState extends State<SimpleRecorder> {
  Codec _codec = Codec.aacMP4;
  // Codec _codec = Codec.aacADTS;
  // String _mPath = 'tau_file.mp3';
  String _mPath = 'tau_file.aac';
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;

  String _fileName = 'Recording_';
  String _fileExtension = '.aac';
  String _directoryPath = '/storage/emulated/0/SoundRecorder';

  String _returnedMessage = '';

  @override
  void initState() {
    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _mPlayer!.closePlayer();
    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    if (!kIsWeb) {
      var status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        throw RecordingPermissionException('Microphone permission not granted');
      }

      // status = await Permission.storage.request();
      // if(status != PermissionStatus.granted){
      //   throw RecordingPermissionException('Storage permission not granted');
      // }

      // status = await Permission.accessMediaLocation.request();
      // if (status != PermissionStatus.granted) {
      //   throw RecordingPermissionException('access media location permission not granted');
      // }

      // status = await Permission.manageExternalStorage.request();
      // if (status != PermissionStatus.granted) {
      //   throw RecordingPermissionException('Manager external storage permission not granted');
      // }
    }
    await _mRecorder!.openRecorder();
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _mPath = 'tau_file.webm';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
        return;
      }
    }
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.allowBluetooth |
              AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
          AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    _mRecorderIsInited = true;
  }

  // ----------------------  Here is the code for recording and playback -------

void _createFile() async {
    // var _completeFileName = await generateFileName();
    // File(_directoryPath + '/' + _completeFileName)
    File(_directoryPath + '/' + _mPath)
        .create(recursive: true)
        .then((File file) async {
      //write to file
      Uint8List bytes = await file.readAsBytes();
      file.writeAsBytes(bytes);
      print(file.path);
    });
  }

  void _createDirectory() async {
    bool isDirectoryCreated = await Directory(_directoryPath).exists();
    if (!isDirectoryCreated) {
      Directory(_directoryPath)
          .create()
          // The created directory is returned as a Future.
          .then((Directory directory) {
        print(directory.path);
      });
    }
  }

  void _writeFileToStorage() async {
    _createDirectory();
    _createFile();
  }

  void record() {
    _mRecorder!
        .startRecorder(
      toFile: _mPath,
      codec: _codec,
      audioSource: theSource,
    )
        .then((value) {
      setState(() {});



      // ************************************************************
      // won on the following function
      // _startRecordingVisualizer();
      // print("Recording started");
      // // show new value
      // print("--------->>> $value");
    });
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        var url = value;
        print('\nAudio recorded path = $url\n');
        _mplaybackReady = true;
      });
    });
    // _writeFileToStorage();
    // print('Stopped...... hopefully create a file too');
  }


// ************************************************************
  // void _startRecordingVisualizer() {
  //   _recorderSubscription = _mRecorder.onProgress.listen((e) {
  //     double dbLevel = e.decibels;
  //     double linearLevel = e.amplitude;
  //     setState(() {
  //       // Use dbLevel and linearLevel to update the siri wave visualizer
  //     });
  //   });
  // }

  // String _getFilePath() async{
  //   var directory = await getExternalStorageDirectory();
  //   // final directory = Platform.isIOS ? getTemporaryDirectory() : getExternalStorageDirectory();
  //   // return '${directory.path}/my_audio_file.mp3';
  //   return '${directory.path}/my_audio_file.mp3';
  // }

  void play() {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder!.isStopped &&
        _mPlayer!.isStopped);
    _mPlayer!
        .startPlayer(
            fromURI: _mPath,
            //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
            whenFinished: () {
              setState(() {});
            })
        .then((value) {
      setState(() {});
    });
    print('*********************** Hello World ***********************');
    print(_mPath.runtimeType);
    print('The pay in use is $_mPath');
    getTextFromSpeech();
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {
      setState(() {});
    });
  }

// ----------------------------- UI --------------------------------------------

  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped ? record : stopRecorder;
  }

  _Fn? getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder!.isStopped) {
      return null;
    }
    return _mPlayer!.isStopped ? play : stopPlayer;
  }


  // Future<void> sendAudioFile() async {
  //   final bytes = await rootBundle.load('path/to/audio/file.mp3');
  //   // use the bytes variable to send the file in the post request
  // }

  void getTextFromSpeech() async {
    print('Sending audio to server');

    File file = File(_mPath);

    var url = Uri.parse('https://stt.umuganda.digital/transcribe/');
    var req = new http.MultipartRequest('POST', url)
      // ..files.add(await http.MultipartFile.fromBytes(
      ..files.add(await http.MultipartFile.fromPath(
        'file', '/data/user/0/com.example.du_voice_assistant/cache/tau_file.aac'
        // 'file', (await rootBundle.load('/data/user/0/com.example.du_voice_assistant/cache/tau_file.aac')).buffer.asUint8List(),
        // 'file', (await rootBundle.load('/storage/emulated/0/SoundRecorder/tau_file.aac')).buffer.asUint8List(),
        // 'file', (await rootBundle.load('assets/audios/recordedaudio.mp3')).buffer.asUint8List(),
        // filename:'recordedaudio.mp3', // use the real name if available, or omit
        // filename:'tau_file.aac', // use the real name if available, or omit
      ));
    req.headers['Content-Type'] = 'multipart/form-data';

    var response = await req.send();
    // Extract String from Streamed Response
    var responseString = await response.stream.bytesToString();
    final decodedMap = json.decode(responseString);
    
    _returnedMessage = decodedMap['message'] as String; 
    print(decodedMap['message']);
    print(_returnedMessage);


    // await req
    //     .send()
    //     .then((result) async {
    //       http.Response.fromStream(result).then((response) {
    //         if (response.statusCode == 200) {
    //           print("Uploaded! ");
    //           print('response.body ' + response.body);
    //         }

    //         return response.body;
    //       });
    //     })
    //     .catchError((err) => print('error : ' + err.toString()))
    //     .whenComplete(() {});


    print('Audio sent...***');


    // final file = File('assets/audios/recordedaudio.mp3');
    // final fileStream = file.openRead();
    // final fileSize = await file.length();

    // final header = {'Content-Type: multipart/form-data'};

  }

  // void generateToken(){

  // }

  // bool _called = false;

  Future<void> _getSpeechFromText() async{

    var dio = Dio();
    Directory directory = await getApplicationDocumentsDirectory();

    var headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    if(_returnedMessage!.isEmpty){
      _returnedMessage = "Nitwa Mbaza, nabafasha iki?";
    }
    // _returnedMessage = String toString($_returnedMessage);
    var data =
        '{"text": "$_returnedMessage", "accept": "audio/mp3"}';
    
    print(data);


    var url = Uri.parse('https://tts.umuganda.digital/generate_audio/');
    var res = await http.post(url, headers: headers, body: data);
    if (res.statusCode != 200)
      throw Exception('http.post error: statusCode= ${res.statusCode}');
    
    print('Getting a response');
    print(res.bodyBytes);//.body);
    
    final bytes = res.bodyBytes;

        // Get temporary directory
    final dir = await getTemporaryDirectory();

    // Create an image name
    var filename = '${dir.path}/audiotest.aac';

    // Save to filesystem
    final file = File(filename);
    await file.writeAsBytes(res.bodyBytes);

    print('file path for the audio to try playing');
    print(file.path);

    _mPlayer!.startPlayer(
        fromURI: file.path,
        //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
        // whenFinished: () {
        //   setState(() {});
        // }
        );
    // _mPlayer.play
  //   _mPath = bytes;
  // _mPlayer.startPlayer();
  //   try{
  //   await _mPlayer.startPlayer();
  //  } catch (e, sr){
  //   // try to make the play work for bytes
  //  }
   
   // play(UrlSource(recordFilePath));
    // player.play().
  }



  // void getTextFromSpeech() async {
  //     var url = Uri.parse('https://stt.staging.umuganda.digital/transcribe/');
  //     var req = new http.MultipartRequest('POST', url)..files.add(await http.MultipartFile.fromBytes(
  //         'file', (await rootBundle.load('assets/audios/recordedaudio.mp3')).buffer.asUint8List(),
  //     filename: 'recordedaudio.mp3', // use the real name if available, or omit
  //     ));
  //     req.headers['Content-Type'] = 'multipart/form-data';
  //     // var res = await req.send();
  //     // if (res.statusCode != 200) throw Exception('http.send error: statusCode= ${res.statusCode}');
    
  //     // if (res.statusCode == 200) {
  //     //   // Success
  //     //   print('File uploaded!');
  //     // } else {
  //     //   // Error
  //     //   print('Error uploading file!');
  //     // }
  //     // var response = await http.Response.fromStream(res);
  //     // print('$response');
  //     // // print(res.stream.bytesToString());
  //     // print('success!!');

  //     await req.send()
  //       .then((result) async {
  //         http.Response.fromStream(result).then((response) {
  //           if (response.statusCode == 200) {
  //             print("Uploaded! ");
  //             print('response.body ' + response.body);
  //           }

  //           return response.body;
  //         });
  //       })
  //       .catchError((err) => print('error : ' + err.toString()))
  //       .whenComplete(() {});
  //     // final file = File('assets/audios/recordedaudio.mp3');
  //     // final fileStream = file.openRead();
  //     // final fileSize = await file.length();

  //     // final header = {'Content-Type: multipart/form-data'};
      
  //     // // final curl = Curl();


  //   // request.files.add(multipartFile);
  //   // var url = Uri.parse('https://stt.staging.umuganda.digital/transcribe/');
  //   // var res = await http.MultipartRequest('POST', url)
  //   //   ..files.add(await http.MultipartFile.fromPath('file',
  //   //       '"/home/deo/Downloads/Record (online-voice-recorder.com).mp3"'));
  //   // // if (res..statusCode != 200) throw Exception('http.send error: statusCode= ${res.statusCode}');
  //   // // print(res.body);
  //   // final response = res.send();

  //   // if (response == 200) {
  //   //   // Success
  //   //   print('File uploaded!');
  //   // } else {
  //   //   // Error
  //   //   print('Error uploading file!');
  //   // }


      
  //     // final url = 'https://stt.staging.umuganda.digital/transcribe/';
  //     // final audioFile = await MultipartFile.fromString('assets/audios/recordedaudio.mp3');

  //     // try {
  //     //   final formData = FormData.fromMap({
  //     //     'file': audioFile,
  //     //   });

  //     //   final curl = Curl.create();
  //     //   curl.setOpt(CurlOption.URL, url);
  //     //   curl.setOpt(CurlOption.HTTPHEADER, ['Content-Type: multipart/form-data']);
  //     //   curl.setOpt(CurlOption.POST, true);
  //     //   curl.setOpt(CurlOption.HTTPPOST, formData.toCurlList());

  //     //   final responseBytes = await curl.performOutput();
  //     //   final response = Response(data: responseBytes);

  //     //   print(response.data);
  //     // } catch (e) {
  //     //   print(e);
  //     // }
  //   }

// this throws a request status code of 400
  // void getTextFromSpeech() async {
    // var dio = Dio();
    // final url = 'https://stt.staging.umuganda.digital/transcribe/';
    // final audioFile = await MultipartFile.fromString('assets/audios/recordedaudio.mp3');
    // // final audioFile =
    // //     await MultipartFile.fromFile('assets/audios/recordedaudio.mp3');

    // try {
    //   final response = await Dio().post(
    //     url,
    //     data: FormData.fromMap({
    //       'file': audioFile,
    //     }),
    //     options: Options(
    //       headers: {
    //         'Content-Type': 'multipart/form-data',
    //       },
    //     ),
    //   );
    //   print(response.data);
    // } catch (e) {
    //   print(e);
    // }
  // }

  // void getTextFromSpeech() async {

  //   // String audioasset = "assets/audios/recordedaudio.mp3"; //path to asset
  //   // ByteData bytes = await rootBundle.load(audioasset); //load sound from assets
  //   // Uint8List soundbytes = bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);

  //   var request = http.MultipartRequest('POST', Uri.parse('https://stt.staging.umuganda.digital/transcribe/'));

  //   request.headers['Content-Type'] = 'multipart/form-data';

  //   // Add file to the request
  //   // var fileStream = http.ByteStream(DelegatingStream.typed(file.openRead()));
  //   // var length = await file.length();
  //   // request.files.add(
  //   //     http.MultipartFile('file', fileStream, length, filename: 'audio.wav'));

  //   request.files.add(await http.MultipartFile.fromString('file', 'assets/audios/recordedaudio.mp3'));
  //   // request.files.add(await http.MultipartFile.fromPath('file', 'assets/audios/'));
  //   // ('file', 'assets/audios/recordedaudio.mp3'));//file.path));


  //   // Send the request
  //   var response = await request.send();

  //   if (response.statusCode == 200) {
  //     // Success
  //     print('File uploaded!');
  //   } else {
  //     // Error
  //     print('Error uploading file!');
  //   }
  // }



  @override
  Widget build(BuildContext context) {
    Widget makeBody() {
      return Column(
        children: [
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              ElevatedButton(
                onPressed: getRecorderFn(),
                //color: Colors.white,
                //disabledColor: Colors.grey,
                child: Text(_mRecorder!.isRecording ? 'Stop' : 'Record'),
              ),
              SizedBox(
                width: 20,
              ),
              Text(_mRecorder!.isRecording
                  ? 'Recording in progress'
                  : 'Recorder is stopped'),
            ]),
          ),
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              ElevatedButton(
                onPressed: getPlaybackFn(),
                //color: Colors.white,
                //disabledColor: Colors.grey,
                child: Text(_mPlayer!.isPlaying ? 'Stop' : 'Play'),
              ),
              SizedBox(
                width: 20,
              ),
              Text(_mPlayer!.isPlaying
                  ? 'Playback in progress'
                  : 'Player is stopped'),
            ]),
          ),
          
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              Text(_returnedMessage!.isEmpty 
              ? 'Mwifate amajwi / Record an audio' :'Uvuze ngo: $_returnedMessage'),
            ]),
          ),
          
          Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 80,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(children: [
              ElevatedButton(
                onPressed: ()
                {
                  _getSpeechFromText();
                },
                //color: Colors.white,
                //disabledColor: Colors.grey,
                child: Text('Send Text'),
              ),
              SizedBox(
                width: 20,
              ),

              Text('Get voice back'),
            ]),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: const Text('Simple Recorder'),
      ),
      body: makeBody(),
    );
  } 
}
