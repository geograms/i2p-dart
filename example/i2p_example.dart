// Minimal end-to-end example: bring up a pure-Dart I2P node, back it with an
// in-memory content store, announce a blob by its sha256 so the network can find
// it, and print our reachable b32 address.
//
// Run with:  dart run example/i2p_example.dart
//
// Note: joining the live I2P network (netId 2) reseeds over HTTPS and builds
// tunnels, which takes a little while on first start.

import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:i2p/i2p.dart';

/// A trivial RAM-backed content store keyed by sha256 (base64url, no padding).
class MemoryStore implements I2pContentStore {
  final Map<String, Uint8List> _blobs = {};

  String add(Uint8List bytes) {
    final key = base64Url.encode(sha256.convert(bytes).bytes).replaceAll('=', '');
    _blobs[key] = bytes;
    return key;
  }

  @override
  Future<Uint8List?> get(String sha256B64u) async => _blobs[sha256B64u];

  @override
  Future<void> put(Uint8List bytes, String ext) async => add(bytes);
}

Future<void> main() async {
  final store = MemoryStore();
  final service = I2pService(
    store: store,
    log: (m) => print('[i2p] $m'),
  );

  // Seed some content we are willing to serve.
  final blob = Uint8List.fromList(utf8.encode('hello from a pure-Dart I2P node'));
  store.add(blob);
  final sha = sha256.convert(blob).bytes;

  print('Starting node (reseed + tunnel build, please wait)…');
  final up = await service.ensureStarted();
  if (!up) {
    print('Node failed to start.');
    return;
  }

  print('Node is up.');
  print('Our address: ${service.b32}.b32.i2p');

  // Announce so other devices can discover this blob by hash, with no prior
  // knowledge of who holds it.
  await service.announce(Uint8List.fromList(sha));
  print('Announced ${base64Url.encode(sha).replaceAll('=', '')}');

  // A second peer would then call:
  //   await otherService.discover(sha, 'txt');
  // and the bytes land in its store, sha256-verified.

  // Keep running a bit so tunnels stay published, then shut down cleanly.
  await Future<void>.delayed(const Duration(seconds: 30));
  service.stop();
  print('Stopped.');
}
