import 'dart:io';
import 'dart:convert';

import 'package:du_voice_assistant/models/classifier.dart';
import 'package:audio_session/audio_session.dart';
import 'package:du_voice_assistant/simple_recorder/simple_recorder_duplicate.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:du_voice_assistant/screens/chat_screen.dart';
import 'package:http/http.dart' as http;

typedef _Fn = void Function();

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Kinayarwanda Voice Assistant'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  final recorder = FlutterSoundRecorder();
  bool isRecorderReady = false;
  File? filePath;

  String _mPath = 'tau_file.aac';
  Codec _codec = Codec.aacMP4;
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();

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

  Future initRecorder() async {
    final status = await Permission.microphone.request();

    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    await recorder.openRecorder();

    isRecorderReady = true;

    recorder.setSubscriptionDuration(Duration(milliseconds: 500));
  }

  Future record() async {
    // await recorder.openAudioSession();
    if (!isRecorderReady) return;

    await recorder.startRecorder(
      toFile: 'test.mp4',
      // codec: Codec.aacMP4,
    );
  }

  // Future stop() async {
  //   if (!isRecorderReady) return;

  //   final path = await recorder.stopRecorder();
  //   final audioFile = File(path!);
  //   filePath = audioFile;

  //   print('File saved to: $audioFile');
  //   // await recorder.closeAudioSession();
  //   getTextFromSpeech();
  // }

  // void getTextFromSpeech() async {
  //   print('Sending audio to server');

  //   String fileToSend = filePath as String;

  //   var url = Uri.parse('https://stt.umuganda.digital/transcribe/');
  //   var req = new http.MultipartRequest('POST', url)
  //     ..files.add(await http.MultipartFile.fromPath('file',
  //         '/data/user/0/com.example.du_voice_assistant/cache/test.mp4'));

  //   req.headers['Content-Type'] = 'multipart/form-data';

  //   var response = await req.send();
  //   // Extract String from Streamed Response
  //   var responseString = await response.stream.bytesToString();
  //   final decodedMap = json.decode(responseString);

  //   // _returnedMessage = decodedMap['message'] as String;
  //   print(decodedMap['message']);
  //   // print(_returnedMessage);

  //   print('Audio sent...***');
  // }

  void stopRecorder() async {
    print('stopped..');
    final path = await _mRecorder!.stopRecorder();
    // .then((value) {
    //   setState(() {
    //     var url = value;
    //     print('\nAudio recorded path = $url\n');
    //     _mplaybackReady = true;
    //   });
    // });
    // _writeFileToStorage();
    // print('Stopped...... hopefully create a file too');

    final messages = await Classifier().classifierResponseFromAudio(
        '/data/user/0/com.example.du_voice_assistant/cache/tau_file.aac');
  }

  _Fn? getRecorderFn() {
    print('happening...');
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped ? record : stopRecorder;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: const Color(0xFF252331),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252331),
        elevation: 1,
        centerTitle: true,
        shadowColor: Colors.grey,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              scale: 1.5,
            ),
            const SizedBox(width: 10),
            const Text('Digital Umuganda'),
          ],
        ),
      ),
      body: SimpleRecorder(),
      // body: Column(
      //   children: [
      //     SizedBox(
      //       height: size.height * 0.4,
      //       child: ElevatedButton(
      //         style: ButtonStyle(
      //           backgroundColor: MaterialStateProperty.all(Colors.blue),
      //           shape: MaterialStateProperty.all(
      //             const CircleBorder(),
      //           ),
      //         ),
      //         child: Icon(
      //           _mRecorder!.isRecording ? Icons.stop : Icons.mic,
      //           size: 100,
      //         ),
      //         onPressed: getRecorderFn(),
      //         // onPressed: () async {
      //         //   if (!recorder.isRecording) {
      //         //     await record();
      //         //   } else {
      //         //     // await recorder.stopRecorder();
      //         //     await stop();
      //         //   }

      //         //   setState(() {});
      //         // },
      //       ),
      //     ),
      //     Expanded(child: ChatScreen()),
      //   ],
      // ),
    );
  }
}
