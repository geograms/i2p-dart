# Changelog

## 0.1.0

- Initial extraction as a standalone package from the Aurora project.
- Pure-Dart I2P node: NTCP2 transport, inbound + outbound tunnel build/data,
  netDB lookups, LeaseSet2 publish/retrieve, repliable signed datagrams,
  content-discovery DHT (PROVIDE / FINDPROV) and a BitTorrent-style piece swarm.
- High-level `I2pService` facade running the node in a background isolate, with
  a pluggable `I2pContentStore` (no Flutter / app dependency).
