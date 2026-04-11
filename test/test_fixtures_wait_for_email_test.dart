import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';
import '../integration_test/helpers/test_fixtures.dart' as helpers;

void main() {
  test('waitForEmail returns message body when mailhog responds', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    var callCount = 0;

    server.listen((HttpRequest request) async {
      request.response.headers.contentType = ContentType.json;
      if (callCount == 0) {
        // first call: no messages
        final resp = json.encode({'items': []});
        request.response.write(resp);
      } else {
        // subsequent calls: return a matching message
        final resp = json.encode({
          'items': [
            {
              'Content': {
                'Headers': {'To': ['test@lumi.com']},
                'Body': 'Hello Test User'
              }
            }
          ]
        });
        request.response.write(resp);
      }
      await request.response.close();
      callCount++;
    });

    final mailhogUrl = 'http://${server.address.host}:${server.port}';

    final body = await helpers.waitForEmail('test@lumi.com',
        timeout: Duration(seconds: 5), pollInterval: Duration(milliseconds: 100), mailhogUrl: mailhogUrl);

    expect(body, equals('Hello Test User'));

    await server.close(force: true);
  });
}
