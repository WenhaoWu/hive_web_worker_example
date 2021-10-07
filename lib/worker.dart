import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:js/js.dart';
import 'package:js/js_util.dart' as js_util;

import 'package:hive/hive.dart';

import 'presisted_asset_manager.dart';

@JS('self')
external dynamic get globalScopeSelf;

@JS('JSON.stringify')
external String stringify(Object obj);

Stream<T> callbackToStream<J, T>(
  String name,
  Future<T> Function(J jsValue) unwrapValue,
) {
  var controller = StreamController<T>.broadcast(sync: true);
  js_util.setProperty(js.context['self'], name, js.allowInterop((J event) {
    unwrapValue(event).then((value) => controller.add(value));
  }));
  return controller.stream;
}

void jsSendMessage(dynamic object, dynamic m) {
  js.context.callMethod('postMessage', [m]);
}

main() async {
  final assetManager = PersistedAssetManager(Hive);

  callbackToStream('onmessage', (html.MessageEvent e) async {
    final data = js_util.getProperty(e, 'data');
    final request = js_util.getProperty(data, 'request');
    final id = js_util.getProperty(request, 'id');
    final payload = js_util.getProperty(request, 'payload');

    if (request != null) {
      switch (id) {
        case 'getAsset':
          final asset = await assetManager.getAsset(payload);
          final result = {
            "response": {
              "request": stringify(request).replaceAll("\"", ""),
              "result": asset,
            }
          };
          return json.encode(result);
      }
    }
    throw UnimplementedError(e.toString());
  }).listen((message) {
    jsSendMessage(js.context, '$message');
  });
}
