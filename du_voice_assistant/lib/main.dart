
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

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'recordToStream/record_to_stream.dart';
// import 'play_from_mic/play_from_mic.dart';
// import 'simple_playback/simple_playback.dart';
import 'simple_recorder/simple_recorder.dart';
// import 'soundEffect/sound_effect.dart';
// import 'streamLoop/stream_loop.dart';
// import 'loglevel/loglevel.dart';
// import 'volume_control/volume_control.dart';
// import 'speed_control/speed_control.dart';
// import 'player_onProgress/player_onProgress.dart';
// import 'recorder_onProgress/recorder_onProgress.dart';
// import 'seek/seek.dart';
// import 'streamLoop_justAudio/stream_loop_just_audio.dart';

/*
    This APP is just a driver to call the various Flutter Sound examples.
    Please refer to the examples/README.md and all the examples located under the examples/lib directory.
*/

void main() {
  runApp(ExamplesApp());
}

///
const int tNotWeb = 1;

///
class Example {
  ///
  final String? title;

  ///
  final String? subTitle;

  ///
  final String? description;

  ///
  final WidgetBuilder? route;

  ///
  final int? flags;

  ///
  /* ctor */ Example(
      {this.title, this.subTitle, this.description, this.flags, this.route});

  ///
  void go(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute<void>(builder: route!));
}

///
final List<Example> exampleTable = [

  Example(
    title: 'simpleRecorder',
    subTitle: 'Record and heard the audio',
    flags: 0,
    route: (_) => SimpleRecorder(),
    description: '''
Trying to record an audio and send it to a speech to text model 
on the cloud and get a response back.
''',
  ),

//   Example(
//     title: 'recordToStream',
//     subTitle: 'Record and heard the audio',
//     flags: 0,
//     route: (_) => RecordToStreamExample(),
//     description: '''
// Trying to send audio to server.
// ''',
//   ),
];

///
class ExamplesApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Sound Examples',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ExamplesAppHomePage(title: 'Flutter Sound Examples'),
    );
  }
}

///
class ExamplesAppHomePage extends StatefulWidget {
  ///
  ExamplesAppHomePage({Key? key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  ///
  final String? title;

  @override
  _ExamplesHomePageState createState() => _ExamplesHomePageState();
}

class _ExamplesHomePageState extends State<ExamplesAppHomePage> {
  Example? selectedExample;

  @override
  void initState() {
    selectedExample = exampleTable[0];
    super.initState();
    //_scrollController = ScrollController( );
  }

  @override
  Widget build(BuildContext context) {
    Widget cardBuilder(BuildContext context, int index) {
      var isSelected = (exampleTable[index] == selectedExample);
      return GestureDetector(
        onTap: () => setState(() {
          selectedExample = exampleTable[index];
        }),
        child: Card(
          shape: RoundedRectangleBorder(),
          borderOnForeground: false,
          elevation: 3.0,
          child: Container(
            height: 50,
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isSelected ? Colors.indigo : Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.white,
                width: 3,
              ),
            ),

            //color: isSelected ? Colors.indigo : Colors.cyanAccent,
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(exampleTable[index].title!,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black)),
              Text(exampleTable[index].subTitle!,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black)),
            ]),
          ),
        ),
      );
    }

    Widget makeBody() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(3),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Color(0xFFFAF0E6),
                border: Border.all(
                  color: Colors.indigo,
                  width: 3,
                ),
              ),
              child: ListView.builder(
                  itemCount: exampleTable.length, itemBuilder: cardBuilder),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(3),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Color(0xFFFAF0E6),
                border: Border.all(
                  color: Colors.indigo,
                  width: 3,
                ),
              ),
              child: SingleChildScrollView(
                child: Text(selectedExample!.description!),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: makeBody(),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue,
        child: Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.all(3),
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFFAF0E6),
              border: Border.all(
                color: Colors.indigo,
                width: 3,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text((kIsWeb && (selectedExample!.flags! & tNotWeb != 0))
                    ? 'Not supported on Flutter Web '
                    : ''),
                ElevatedButton(
                  onPressed:
                      (kIsWeb && (selectedExample!.flags! & tNotWeb != 0))
                          ? null
                          : () => selectedExample!.go(context),
                  //color: Colors.indigo,
                  child: Text(
                    'GO',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            )),
      ),
    );
  }
}


// import 'dart:io';

// // import 'package:audioplayers/audioplayers.dart';
// // import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// // import 'package:flutter_sound/flutter_sound.dart';
// import 'package:kvav1/api/sound_recorder.dart';
// // import 'package:avatar_glow/avatar_glow.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:assets_audio_player/assets_audio_player.dart';
// import 'package:audioplayers/audioplayers.dart';


// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final recorder = SoundRecorder();

//   final audioPlayer = AudioPlayer();
//   bool isPlaying = false;
//   Duration duration = Duration.zero;
//   Duration position = Duration.zero;
//   // File? audioFile;

//   @override
//   void initState() {
//     super.initState();

//     recorder.init();

//     // setAudio();

//     /*
//     * lISTEN TO state:
//     * @playing
//     * @paused
//     * @stopped
//     */

//     // audioPlayer.onPlayerStateChanged.listen((state)
//     // {
//     //   setState(() {
//     //     isPlaying = state == true;//PlayerState.isPlaying;
//     //     //  PlayerState.isPlaying;// PlayerState.playing;
//     //   });
//     // });

//     // /*
//     // * Listen to audio duration
//     // */
//     // audioPlayer.onDurationChanged.listen((newDuration)
//     // {
//     //   setState(() {
//     //     duration = newDuration;
//     //   });
//     // });

//     // /*
//     // * Listen to audio position
//     // */
//     // audioPlayer.onPositionChanged.listen((newPosition)
//     // {
//     //   setState(() {
//     //     duration = newPosition;
//     //   });
//     // });
//   }

//   // Future setAudio() async
//   // {
//   //   // Repeat song when completed
//   //   audioPlayer.setReleaseMode(ReleaseMode.loop);

//   //   final result = await FilePicker.platform.pickFiles();

//   //   print('file found: $result');

//   //   // if(result != null)
//   //   // {
//   //   //   final file = File(result.files.single.path!);
//   //   //   audioPlayer.setSourceUrl(file.path);//, isLocal: true);
//   //   // }

//   // }

//   @override
//   void dispose() {
//     recorder.dispose();

//     super.dispose();
//   }

//   String formatTime(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final hours = twoDigits(duration.inHours);
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));

//     return [
//       if (duration.inHours > 0) hours,
//       minutes,
//       seconds,
//     ].join(':');
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(
//           title: Text(widget.title),
//           centerTitle: true,
//         ),
//         backgroundColor: Colors.black87,

//         body: Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               buildStart(),
//               Slider(
//                 min: 0,
//                 value: position.inSeconds.toDouble(),
//                 max: position.inSeconds.toDouble(),
//                 onChanged: (value) async {
//                   final position = Duration(seconds: value.toInt());
//                   // await audioPlayer.seek(position);

//                   // Optionally: Play audio if was paused
//                   // await audioPlayer.resume();
//                 },
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(formatTime(position)),
//                     Text(formatTime(duration - position)),
//                   ],
//                 ),
//               ),
//               CircleAvatar(
//                 radius: 35,
//                 child: IconButton(
//                   icon: Icon(
//                     isPlaying ? Icons.pause : Icons.play_arrow,
//                   ),
//                   iconSize: 50,
//                   onPressed: () async {
//                     print("Play button pressed.");

//                     // final result = await FilePicker.platform.pickFiles();
//                     // print('file found: $result');

//                     if (isPlaying) {
//                       print('is playing paused');

//                       // await audioPlayer.pause();
//                     } else {
//                       print('is playing starts');
//                       final recordFilePath = recorder.audioPath;
//                       print('This is the record path $recordFilePath');
//                       await audioPlayer.play(UrlSource(recordFilePath));
//                       // getApplicationDocumentsDirectory().then((value) => print('value found $value'));
//                       // String url = '/data/user/0/com.example.kvav1/cache/audio_example.aac';
//                       // await audioPlayer.resume();
//                       // await audioPlayer.play(url, isLocal: true);
//                     }
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//         // body: Center(
//         //   child: buildStart(),
//         //   ),
//       );

//   Widget buildStart() {
//     final isRecording = recorder.isRecording;
//     final icon = isRecording ? Icons.stop : Icons.mic;
//     final text = isRecording ? 'STOP' : 'START';
//     final primary = isRecording ? Colors.red : Colors.white;
//     final onPrimary = isRecording ? Colors.white : Colors.black;

//     return ElevatedButton.icon(
//       style: ElevatedButton.styleFrom(
//         minimumSize: Size(175, 50),
//         primary: primary,
//         onPrimary: onPrimary,
//       ),
//       icon: Icon(icon),
//       label: Text(
//         text,
//         style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//       ),
//       onPressed: () async {
//         print("Hello world");
//         await recorder.toggleRecording();
//         final isRecording = recorder.isRecording;

//         setState(() {});

//         /*
//         * Add timer coder here in case dealind with timer.
//         *
//         */
//       },
//     );
//   }
// } /* 
//   * end of class
//   * _MyHomePage page 
//   */
/**************************************************************************************************************************************** */
/**************************************************************************************************************************************** */
/**************************************************************************************************************************************** */
/**************************************************************************************************************************************** */
/**************************************************************************************************************************************** */
/**************************************************************************************************************************************** */
/**************************************************************************************************************************************** */
/**************************************************************************************************************************************** */
/**************************************************************************************************************************************** */






// import 'package:flutter/material.dart';
// import 'package:kvav1/screens/record_and_play_audio.dart';

// void main() => runApp(const EntryRoot());

// class EntryRoot extends StatelessWidget
// {
//   const EntryRoot({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context)
//   {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Record and Play Testing',
//       home: RecordAndPlayScreen(),
//     );
//   }

// }

// Don't touch me ***************************************************

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   // void _incrementCounter() {
//   //   setState(() {
//   //     _counter++;
//   //   });
//   // }

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headlineMedium,
//             ),
//           ],
//         ),
//       ),
//       // floatingActionButton: FloatingActionButton(
//       //   // onPressed: _incrementCounter,
//       //   tooltip: 'Increment',
//       //   child: const Icon(Icons.add),
//       // ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
