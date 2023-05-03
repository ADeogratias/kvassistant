/*
* Chat Screen contains the chat messages and the text field to send the message
* This class renders how the messages are displayed in the chat screen
* 
* Note: the way the response from the server depends on how fast the server responds
* This is slow for text to show on the screen because we are waiting for the TTS server to respond
* and display what is being said to avoid the user from sending another message before the TTS responds 
* and starts speaking before the user sends another message
 */


import 'dart:convert';

import 'package:du_voice_assistant/models/classifier.dart';
import 'package:flutter/material.dart';
import 'package:du_voice_assistant/models/message_model.dart';
import 'package:http/http.dart' as http;

class ChatScreen extends StatefulWidget {
  ChatScreen({
    Key? key,
    required this.messages,
  }) : super(key: key);

  final List<MessageModel> messages;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  List<MessageModel> _messages = [];

  // @override
  // void didChangeDependencies() {
  //   // TODO: implement didChangeDependencies
  //   print('all messages ${_messages.length}');
  //   print('incoming messages ${widget.messages.length}');
  //   if (widget.messages.isNotEmpty != 0) {
  //     setState(() {
  //       _messages.addAll(widget.messages);
  //     });
  //   }
  //   super.didChangeDependencies();
  // }

  void _handleSubmitted(String text) async {
    setState(() {
      // Sender message to be added in array
      _messages.add(MessageModel(
        message: text,
        isSender: true,
      ));
    });
    _textController.clear();

    final message = await Classifier().classifierResponse(text);

    setState(() {
      // Receiver message to be added in the array
      _messages.add(message);
    });
  }

  Widget _buildTextComposer() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onSubmitted: _handleSubmitted,
              decoration: const InputDecoration(
                hintText: 'Send a message',
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(10),
              ),
            ),
          ),
          SizedBox(
            height: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: Colors.white,
            onPressed: () => _handleSubmitted(_textController.text),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(widget.messages.length);
    if (widget.messages.isNotEmpty) {
      _messages.addAll(widget.messages);
      widget.messages.clear();
    }

    // this is to check if the message is from the user or the bot
    // and display the message accordingly in a list view
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];

              return Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.all(10),
                color: message.isSender! ? Colors.green : Colors.blue,
                child: Text(
                  message.message!,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                  textAlign:
                      message.isSender! ? TextAlign.right : TextAlign.left,
                ),
              );
            },
          ),
        ),
        const Divider(height: 1.0),
        _buildTextComposer(),
      ],
    );
  }
}
