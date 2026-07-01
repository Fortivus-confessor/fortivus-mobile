import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Gera e guarda a chave de criptografia do banco local (SQLCipher).
///
/// A chave é aleatória (256 bits) e vive apenas no armazenamento seguro do
/// sistema operacional (Android Keystore / iOS Keychain), nunca no próprio banco
/// nem em SharedPreferences. Assim, mesmo que o arquivo `.db` seja extraído do
/// dispositivo, os dados permanecem ilegíveis sem a chave protegida por hardware.
class DbEncryption {
  DbEncryption._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _keyName = 'db_sqlcipher_key';

  /// Retorna a chave em hexadecimal (64 chars = 32 bytes). Cria na primeira vez.
  static Future<String> getOrCreateKey() async {
    final existing = await _storage.read(key: _keyName);
    if (existing != null && existing.length == 64) {
      return existing;
    }

    final rnd = Random.secure();
    final bytes = List<int>.generate(32, (_) => rnd.nextInt(256));
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    await _storage.write(key: _keyName, value: hex);
    return hex;
  }
}
