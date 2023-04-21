// import 'dart:io';

// import 'package:dio/dio.dart';
// import 'package:flutter_curl/flutter_curl.dart';

// void main() async {
//   final curl = Curl();
//   final dio = Dio();

//   final url = 'https://stt.staging.umuganda.digital/transcribe/';

//   // Set up curl options
//   curl.setOpt(CurlOption.URL, url);
//   curl.setOpt(CurlOption.POST, 1);
//   curl.setOpt(CurlOption.HTTPHEADER, [
//     'Content-Type: multipart/form-data',
//   ]);
//   curl.setOpt(CurlOption.HTTPPOST, [
//     CurlPost(
//       name: 'file',
//       file: File('/path/to/audio.wav').path,
//     ),
//   ]);

//   // Send the request using Dio
//   final response = await dio.post(
//     url,
//     options: Options(
//       headers: {
//         HttpHeaders.contentTypeHeader: 'multipart/form-data',
//       },
//     ),
//     requestEncoder: (options, data) => curl,
//   );

//   print(response.data);
// }
