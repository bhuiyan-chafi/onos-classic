# ONOS Classic: Open Network Operating System

[![Release](https://img.shields.io/badge/Release-beta--v4.0-blue.svg)](https://github.com/bhuiyan-chafi/onos-classic)
[![Java](https://img.shields.io/badge/Java-17%20LTS-orange.svg)](https://openjdk.org/projects/jdk/17/)
[![Bazel](https://img.shields.io/badge/Bazel-6.5.0%20LTS-green.svg)](https://github.com/bazelbuild/bazel/releases/tag/6.5.0)
[![Platforms](https://img.shields.io/badge/Platforms-Ubuntu%20%7C%20macOS%20%7C%20Windows%20(WSL2)-purple.svg)](./docs/FROM_SOURCE.md)
[![License](https://img.shields.io/badge/License-Apache%202.0-yellow.svg)](LICENSE.txt)

## What is ONOS?

ONOS (Open Network Operating System) is an open-source SDN (Software-Defined Networking) controller platform designed for high availability, performance, and scale. It supports transitioning from legacy networks to SDN and powers production-grade service provider and research networks worldwide.

---

## What's New in `beta-v4.0` (The Resurrection Release)

The **`beta-v4.0`** release revitalizes ONOS Classic, modernizing the entire build toolchain, runtime, and user interface for contemporary hardware and operating systems:

- ☕ **Java 17 LTS Runtime & Compiler:**
  - Fully upgraded build toolchain to OpenJDK 17 LTS (`remotejdk_17`).
  - Upgraded OSGi bundle generator (`bndlib 6.4.0`) to natively support Java 17 bytecode (classfile major version 61) with clean package import elision (`-noimportjava: true`).
  - Configured JEP 403 strong module encapsulation JVM flags (`--add-opens` and `--add-exports`) for Kryo serialization, Atomix distributed store, Netty byte buffers, and Apache Karaf container.
  - Hardened Apache Karaf 4.2.14 with Java 16, 17, and 21 execution environment capabilities (`eecap-17`, `jre-17`).

- ⚡ **Official Bazel 6.5.0 LTS Migration:**
  - Migrated from an unstable 2022 pre-release snapshot (`6.0.0-pre`) to official **Bazel 6.5.0 LTS**.
  - Added headless build support via `bazel build --config=headless //:onos` to decouple core controller compilation from frontend static asset builds.

- 🍏 **100% Native Apple Silicon (macOS arm64) Support:**
  - Native builds on Apple Silicon (M1, M2, M3, M4) Macs without Docker or Rosetta 2 emulation.
  - Native ARM64 Protobuf compiler (`protoc`), gRPC C++ compiler plugin toolchain, Netty epoll fallback to Java NIO on Darwin, and BSD-compatible shell runtime scripts.

- 🌐 **Unified Modern Web GUI:**
  - Consolidated and upgraded to modern **Angular 16+** with Ivy compilation under `web/gui`.
  - Fully deprecated and removed legacy GUI 1 (AngularJS 1.3 / Bower) and redundant GUI 2 split for a cleaner, unified developer experience.

- 🧪 **Automated Smoke Test Suite:**
  - Includes a comprehensive 8-point automated health verification suite ([`resurrect/smoke_test.sh`](./resurrect/smoke_test.sh)) validating Web GUI, REST API cluster & application endpoints, Apache Karaf SSH CLI, OpenFlow 6653, and Atomix 9876.

---

## Top-Level Features

- **High Availability:** Distributed clustering and state management powered by Atomix Raft.
- **Scalability:** Horizontal clustering and sharding of network device control.
- **Northbound Abstractions:** Global network view, network topology graph, flow objectives, and application intents.
- **Pluggable Southbound:** Support for OpenFlow 1.0/1.3, P4Runtime, NETCONF, gNMI, and OVSDB.
- **Modern Web GUI:** Interactive topology viewer, device management, flow inspections, and traffic monitoring.
- **Extensible REST API & CLI:** Rich RESTful endpoints for SDN applications alongside an Apache Karaf SSH management console.
- **SDN-IP:** Seamless interworking between SDN domains and traditional IP networks via BGP.

---

## About This Fork

This repository is maintained for **educational and research purposes** by the Department of Information Engineering at the University of Pisa. The goal is to keep ONOS accessible, buildable on modern environments, and ready for use in SDN labs, experiments, and research.

### References

- **Open Networking Foundation (ONF):** [https://opennetworking.org/](https://opennetworking.org/)
- **Upstream GitHub Mirror (Archive):** [https://github.com/opennetworkinglab/onos](https://github.com/opennetworkinglab/onos)
- **ONOS Architecture Whitepaper:** [ONOS Architecture (PDF)](https://stordis.com/wp-content/uploads/2019/05/Whitepaper-ONOS.pdf)

---

## Documentation

The complete ONOS documentation and guides are available through:
- **[GitHub Wiki (Integrated)](https://github.com/bhuiyan-chafi/onos-classic/wiki):** Native wiki directly attached to this repository.
- **[Searchable Online Mirror](https://andrea-campanella.github.io/onos-classic-wiki/):** Full-text searchable documentation portal powered by MkDocs Material.

---

## Getting Started: Installing ONOS

Choose one of the following installation methods:

- **Build from Source (Ubuntu, macOS, Windows WSL2):** Follow the comprehensive [Building from Source Guide](./docs/FROM_SOURCE.md).
- **Run with Docker Hub:** Follow the [Docker Hub Guide](./docs/FROM_DOCKER_HUB.md).
- **Run with Kathará:** Follow the [Kathará + ONOS Guide](./docs/katharaXonos/FROM_KATHARA_CORE.md).

### Quick Build & Run (Ubuntu / macOS / Windows WSL2)

```bash
# 1. Clone repository
git clone https://github.com/bhuiyan-chafi/onos-classic.git
cd onos-classic

# 2. Configure environment
export ONOS_ROOT=$(pwd)
source $ONOS_ROOT/tools/dev/bash_profile

# 3. Build full ONOS distribution with Java 17
bazel build //:onos

# 4. Launch ONOS locally
bazel run //:onos-local -- clean

# 5. Verify deployment (in another terminal)
./resurrect/smoke_test.sh localhost
```

- **Web GUI:** [http://localhost:8181/onos/ui](http://localhost:8181/onos/ui) (Username: `onos`, Password: `rocks`)
- **CLI:** `ssh -p 8101 onos@localhost` (Password: `rocks`)

---

## Project Contributors

- **Alessio Giorgetti**
  - Role: Associate Professor
  - Affiliation: Department of Information Engineering (Dipartimento di Ingegneria dell'Informazione), University of Pisa, Pisa, Italy
  - GitHub: [@alessiocnit](https://github.com/alessiocnit)

- **ASM CHAFIULLAH BHUIYAN**
  - Role: Research Fellow
  - Affiliation: University of Pisa, Pisa, Italy
  - GitHub: [@bhuiyan-chafi](https://github.com/bhuiyan-chafi)

---

## Official License

ONOS (Open Network Operating System) is published under the [Apache License 2.0](LICENSE.txt).

## Official Acknowledgements

YourKit supports open source projects with innovative and intelligent tools for monitoring and profiling Java and .NET applications.  
YourKit is the creator of [YourKit Java Profiler](https://www.yourkit.com/java/profiler/), [YourKit .NET Profiler](https://www.yourkit.com/.net/profiler/) and [YourKit YouMonitor](https://www.yourkit.com/youmonitor/).

![YourKit](https://www.yourkit.com/images/yklogo.png)
