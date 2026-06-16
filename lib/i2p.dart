/// A pure-Dart I2P node — decentralized, NAT-traversing, content-addressed file
/// sharing with no native binaries, no separate router install and no router
/// config. Runs the full I2P client (NTCP2 transport, tunnel build/data, netDB,
/// LeaseSet2, repliable datagrams, content-discovery DHT and a BitTorrent-style
/// swarm) in plain Dart, suitable for any Dart or Flutter application.
///
/// Most callers only need [I2pService] — the high-level facade that runs the
/// node in a background isolate and exposes start / fetch / discover / announce
/// / pause / resume. Bind it to your storage with an [I2pContentStore].
///
/// The lower layers ([I2pNode], [I2pWorker], [RouterInfo], …) are exported for
/// advanced use, custom transports and testing.
library i2p;

export 'src/i2p_service.dart'
    show I2pService, I2pContentStore, I2pCallbackStore;
export 'src/i2p_worker.dart' show I2pWorker, I2pWorkerConfig;
export 'src/i2p_node.dart' show I2pNode, i2pBase32;
export 'src/i2p_structures.dart' show RouterInfo, I2pAddress, parseRouterInfo;
export 'src/i2p_reseed.dart' show reseed, reseedRouters;
