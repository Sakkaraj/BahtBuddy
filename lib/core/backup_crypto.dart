import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

const backupRounds = 8000;

/// Version 2 files are AES-GCM ciphertext. The key is stretched from the PIN.
String sealBackup(String plain, String pin) {
  final salt = _bytes(16);
  final iv = _bytes(12);
  final cipher = _aes(pin, salt).encrypt(
    plain,
    iv: enc.IV(Uint8List.fromList(iv)),
  );
  return jsonEncode({
    'version': 2,
    'rounds': backupRounds,
    'salt': base64Encode(salt),
    'iv': base64Encode(iv),
    'data': cipher.base64,
  });
}

String? openBackup(String sealed, String pin) {
  try {
    final decoded = jsonDecode(sealed);
    if (decoded is! Map || decoded['version'] != 2) return null;
    final rounds = decoded['rounds'];
    if (rounds is! int || rounds < 1 || rounds > 100000) return null;
    final salt = base64Decode(decoded['salt'] as String);
    final iv = base64Decode(decoded['iv'] as String);
    final data = decoded['data'] as String;
    return _aes(pin, salt, rounds: rounds).decrypt64(
      data,
      iv: enc.IV(Uint8List.fromList(iv)),
    );
  } catch (_) {
    return null;
  }
}

bool backupIsSealed(String text) {
  try {
    final decoded = jsonDecode(text);
    return decoded is Map && decoded['version'] == 2;
  } catch (_) {
    return false;
  }
}

enc.Encrypter _aes(String pin, List<int> salt, {int rounds = backupRounds}) {
  return enc.Encrypter(
    enc.AES(
      enc.Key(Uint8List.fromList(_stretch(pin, salt, rounds))),
      mode: enc.AESMode.gcm,
    ),
  );
}

List<int> _stretch(String pin, List<int> salt, int rounds) {
  List<int> digest = utf8.encode('backup::${base64Encode(salt)}::$pin');
  for (var i = 0; i < rounds; i++) {
    digest = sha256.convert(digest).bytes;
  }
  return digest;
}

List<int> _bytes(int length) {
  final random = Random.secure();
  return List<int>.generate(length, (_) => random.nextInt(256));
}
