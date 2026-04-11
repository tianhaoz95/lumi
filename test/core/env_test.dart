import 'package:flutter_test/flutter_test.dart';
import 'package:lumi/core/env.dart';

void main() {
  test('env constants set', () {
    expect(appwriteEndpoint, 'http://localhost/v1');
    expect(appwriteProjectId, 'lumi-dev');
  });
}
