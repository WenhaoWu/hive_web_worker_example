import 'dart:async';
import 'dart:html';
import 'dart:convert';

class DownloadManager {
  late final Worker webWorker;

  final Map<String, Completer<dynamic>> responses = {};

  DownloadManager() {
    webWorker = Worker("worker.dart.js");
    webWorker.onMessage.listen((event) {
      final data = event.data;
      final result = json.decode(data);
      final request = result['response']['request'];
      final response = responses[request]!;
      final payload = result['response']['result'];
      responses.remove(request);
      response.complete(payload);
    });
  }

  Future<T> _workerRequest<T>(Map requestMessage) async {
    final response = responses[requestMessage.toString().replaceAll(" ", "")] =
        Completer<T>();
    webWorker.postMessage({'request': requestMessage});
    return response.future;
  }

  Future<String> getAsset(String assetId) async {
    return await _workerRequest({
      'id': 'getAsset',
      'payload': assetId,
    });
  }
}
