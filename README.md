# i2p

A **pure-Dart I2P node**. Decentralized, NAT-traversing, content-addressed file
sharing — with **no native binaries, no separate router install, and no router
configuration**. The full I2P client runs in plain Dart, so it works in any Dart
or Flutter application (desktop, mobile, server) by just adding a package.

This package was extracted from the [Aurora](https://github.com/geograms/aurora)
project so it can be reused as a standalone library.

## What it does

- **NTCP2 transport** — Noise XK handshake + data phase against the live network.
- **Tunnels** — builds inbound *and* outbound tunnels (ECIES short build records),
  with gateway diversity, rotation and health scoring.
- **netDB** — reseeds over HTTPS (multi-operator), looks up and publishes
  `LeaseSet2` records to the floodfill DHT.
- **Repliable signed datagrams** — Ed25519-signed `GET`/`DAT` by sha256.
- **Content discovery** — an IPFS-style provider DHT (`PROVIDE` / `FINDPROV`):
  find a blob by its sha256 *without* knowing which device holds it.
- **Swarm** — a BitTorrent-style piece swarm so large files download collectively
  from many devices in parallel, each piece sha256-verified.
- **Background isolate** — the node runs off the UI isolate, with cooperative
  `pause()` / `resume()` for CPU / battery governors.

Everything is **content-addressed by sha256**: you serve and fetch opaque blobs
by hash. Mapping hashes to your app's files/messages is left to you.

## Install

```yaml
dependencies:
  i2p:
    git:
      url: https://github.com/geograms/i2p-flutter.git
```

## Quick start

```dart
import 'dart:typed_data';
import 'package:i2p/i2p.dart';

// Back the node with your own storage (keyed by sha256, base64url, no padding).
class MyStore implements I2pContentStore {
  @override
  Future<Uint8List?> get(String sha256B64u) async { /* return bytes or null */ }
  @override
  Future<void> put(Uint8List bytes, String ext) async { /* persist bytes */ }
}

final i2p = I2pService(store: MyStore(), log: print);

await i2p.ensureStarted();          // reseed + build tunnels (idempotent)
print('reachable at ${i2p.b32}.b32.i2p');

// Make a blob discoverable by its hash:
await i2p.announce(sha256Bytes);

// Fetch by hash from anyone on the network who has it:
await i2p.discover(sha256Bytes, 'jpg');

// Or fetch directly from a known peer's address:
await i2p.fetchByB32('<52chars>.b32.i2p', sha256Bytes, 'jpg');

i2p.pause();   // under battery / CPU pressure — cheap to resume()
await i2p.resume();
i2p.stop();
```

If you don't want to implement the interface, use the callback form:

```dart
final i2p = I2pService(
  store: I2pCallbackStore(
    onGet: (k) async => myMap[k],
    onPut: (bytes, ext) async => myMap[hashOf(bytes)] = bytes,
  ),
);
```

A runnable end-to-end demo is in [`example/i2p_example.dart`](example/i2p_example.dart).

## API surface

Most apps only need **`I2pService`** (the facade) and **`I2pContentStore`** (your
storage hook). For lower-level control the package also exports:

- `I2pWorker` / `I2pWorkerConfig` — the isolate runner you can drive directly.
- `I2pNode` — the node itself (transport, tunnels, datagrams, swarm), if you want
  to run it on your own isolate or embed it.
- `RouterInfo`, `parseRouterInfo`, `reseed`, `reseedRouters` — netDB helpers.

## Notes & limitations

- **Network selection**: `I2pService(netId: 2)` is the live public net. Use an
  isolated `netId` to point at a private testnet (e.g. a local `i2pd`).
- **Datagrams are signed but not yet encrypted** (garlic ECIES for payloads is
  not implemented), so transit routers can read content. Add confidentiality
  before relying on it for private data.
- **2-hop inbound tunnels** are opt-in (`hops`) and not yet established on the
  live net; the default 1-hop path is the proven one. 1-hop forwarding is
  probabilistic, so the node leans on gateway diversity + retry + persistence.
- **Mobile NAT**: phones behind carrier CGNAT may fail the data plane in some
  conditions; see the Aurora project notes for the current state.

## License

Apache-2.0. See [LICENSE](LICENSE).
