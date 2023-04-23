import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:du_voice_assistant/models/message_model.dart';
import 'package:path_provider/path_provider.dart';

class Classifier {
  Future<MessageModel> classifierResponse(String text) async {
    var headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    var data = {"question": text};

    var url = Uri.parse('http://voiceassist.umuganda.digital:8000/predict');

    print('Uvuze ngo: $text');
    print('');
    var res = await http.post(url, headers: headers, body: json.encode(data));
    if (res.statusCode != 200)
      throw Exception('http.post error: statusCode= ${res.statusCode}');

    final decodedMap = json.decode(res.body.toString());

    print(decodedMap['answer']);

    return MessageModel(message: decodedMap['answer'], isSender: false);
  }

  Future<List<MessageModel>> classifierResponseFromAudio(String path) async {
    // File file = File(path);

    var url = Uri.parse('https://stt.umuganda.digital/transcribe/');
    var req = new http.MultipartRequest('POST', url)
      // ..files.add(await http.MultipartFile.fromBytes(
      ..files.add(await http.MultipartFile.fromPath('file', path
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

    final text = decodedMap['message'] as String;
    print(decodedMap['message']);
    print(text);

    print('Audio sent...***');

    final senderMessage = MessageModel(
      message: text,
      isSender: true,
    );
    print(senderMessage.message);
    final returnedMessage = await classifierResponse(senderMessage.message!);
    final audioPath = await getSpeechFromText(returnedMessage.message!);
    return [senderMessage, returnedMessage, MessageModel(message: audioPath)];
  }

  Future<String> getSpeechFromText(String text) async {
    var headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    var data = {"text": text, "accept": "audio/mp3"};

    var url = Uri.parse('https://tts.umuganda.digital/generate_audio/');
    var res = await http.post(url, headers: headers, body: json.encode(data));
    if (res.statusCode != 200)
      throw Exception('http.post error: statusCode= ${res.statusCode}');

    print('Getting a response');
    print(res.bodyBytes); //.body);

    final bytes = res.bodyBytes;

    // Get temporary directory
    final dir = await getTemporaryDirectory();

    // Create an image name
    var filename = '${dir.path}/audiotest.aac';

    // Save to filesystems
    final file = File(filename);
    await file.writeAsBytes(res.bodyBytes);

    print('file path for the audio to try playing');
    print(file.path);

    return file.path;
  }
}
