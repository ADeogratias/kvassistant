/*
* This class is used to send text to the server and get the response
* from the server
* 
* The function classifierResponse is used to 
* send text to the server and classify the querry
* getSpeechFromText is used to get the audio from the text and return a path to
* 
* The function classifierResponseFromAudio is used to send audio to the server
* and get the response from the server.
* this is sent to the classifierResponse to be sent to the classifier
* and the response is returned
* 
* The function classifierResponse is 
* getSpeechFromText is used to get the audio from the text and return a path to 
* the mobile application so that it can be played
* 
*/ 
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'package:du_voice_assistant/models/message_model.dart';
import 'package:path_provider/path_provider.dart';

//this class is used to send text to the server
class Classifier {
  // this function is used to send text to the classifier on the server
  Future<MessageModel> classifierResponse(String text) async {
    var headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };

    var data = {"question": text};

    var url = Uri.parse('http://voiceassist.umuganda.digital:8000/predict');

    // debugging prints
    // print('Uvuze ngo: $text');

    // print('Sending text to server...');
    var res = await http.post(url, headers: headers, body: json.encode(data));
    if (res.statusCode != 200)
      throw Exception('http.post error: statusCode= ${res.statusCode}');

    final decodedMap = json.decode(res.body.toString());

    // print(decodedMap['answer']);

    return MessageModel(message: decodedMap['answer'], isSender: false);
  }

  //this function is used to send audio to the server
  Future<List<MessageModel>> classifierResponseFromAudio(String path) async {

    // prepare the audio file to be sent
    var url = Uri.parse('https://stt.umuganda.digital/transcribe/');
    var req = new http.MultipartRequest('POST', url)
      ..files.add(await http.MultipartFile.fromPath('file', path
          ));
    req.headers['Content-Type'] = 'multipart/form-data';

    var response = await req.send();

    // Extract String from Streamed Response
    var responseString = await response.stream.bytesToString();
    final decodedMap = json.decode(responseString);

    final text = decodedMap['message'] as String;

    // set the message to be sent and the sender
    final senderMessage = MessageModel(
      message: text,
      isSender: true,
    );

    // print(senderMessage.message);

    final returnedMessage = await classifierResponse(senderMessage.message!);
    final audioPath = await getSpeechFromText(returnedMessage.message!);
    return [senderMessage, returnedMessage, MessageModel(message: audioPath)];
  }

  // this function is used to get audio from text from the TTS server
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

    final bytes = res.bodyBytes;

    // Get temporary directory
    final dir = await getTemporaryDirectory();

    // Create an image name
    var filename = '${dir.path}/audiotest.aac';

    // Save to filesystems
    final file = File(filename);
    await file.writeAsBytes(res.bodyBytes);

    // print('file path for the audio to try playing');
    // print(file.path);

    return file.path;
  }
}
