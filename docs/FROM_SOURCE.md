# Building ONOS Classic from Source (`beta-v4.0`)

This guide provides complete, step-by-step instructions for building and running **ONOS Classic (`beta-v4.0`)** natively from source across all supported operating systems:

- [Ubuntu Linux (20.04 / 22.04 / 24.04 LTS — x86_64 & arm64)](#1-ubuntu-linux-setup)
- [macOS (Apple Silicon M1/M2/M3/M4 & Intel x86_64)](#2-macos-setup-apple-silicon--intel)
- [Windows 10 / 11 (WSL2 & Docker)](#3-windows-10--11-setup)
- [Common Build & Execution Workflow](#4-common-build--execution-workflow)
- [Verification & Automated Health Checks](#5-verification--automated-health-checks)
- [Troubleshooting & FAQs](#6-troubleshooting--faqs)

---

## Prerequisites Overview

| Requirement      | Supported Version           | Notes                                                     |
| :--------------- | :-------------------------- | :-------------------------------------------------------- |
| **Java JDK**     | OpenJDK 17 LTS              | Required for compilation and runtime.                     |
| **Build System** | Bazel 6.5.0 LTS             | Official LTS release. Can also be managed via `bazelisk`. |
| **Python**       | Python 3.8+                 | Native Python 3 (`python-is-python3`).                    |
| **Memory**       | 4GB+ RAM (8GB+ recommended) | Build utilizes parallel Bazel workers.                    |

---

## 1. Ubuntu Linux Setup

Supported on **Ubuntu 20.04 LTS**, **Ubuntu 22.04 LTS**, and **Ubuntu 24.04 LTS** (both `amd64` and `arm64`).

### 1.1 Install System Dependencies

Open a terminal and install the required development tools, Python 3, and OpenJDK 17:

```bash
sudo apt update && sudo apt install -y \
    python3 \
    python-is-python3 \
    build-essential \
    curl \
    wget \
    zip \
    unzip \
    bzip2 \
    perl \
    git \
    openjdk-17-jdk \
    screen \
    xterm
```

### 1.2 Install Bazel 6.5.0 LTS

Download and install the official Bazel 6.5.0 binary matching your CPU architecture:

```bash
# Detect architecture (amd64 or arm64)
ARCH=$(dpkg --print-architecture)
if [ "$ARCH" = "amd64" ]; then BAZEL_ARCH="x86_64"; else BAZEL_ARCH="arm64"; fi

# Download Bazel 6.5.0 LTS
wget "https://github.com/bazelbuild/bazel/releases/download/6.5.0/bazel-6.5.0-linux-${BAZEL_ARCH}" -O bazel

# Install globally
chmod +x bazel
sudo mv bazel /usr/bin/bazel

# Verify installation
bazel version
```

You should see:

```text
Build label: 6.5.0
```

---

## 2. macOS Setup (Apple Silicon & Intel)

Supported on **macOS 12 (Monterey)**, **13 (Ventura)**, **14 (Sonoma)**, and **15 (Sequoia)** on both:

- **Apple Silicon (M1, M2, M3, M4 — `arm64`)**
- **Intel MacBooks / Macs (`x86_64`)**

> [!NOTE]
> ONOS `beta-v4.0` features first-class native compilation on Apple Silicon. Rosetta 2 or Docker emulation is **not** required.

### 2.1 Install Homebrew & Xcode Command Line Tools

If you haven't already, install the Xcode Command Line Tools and [Homebrew](https://brew.sh/):

```bash
# Install Xcode CLI tools
xcode-select --install

# Install Homebrew (if not already installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2.2 Install Dependencies via Homebrew

```bash
brew install openjdk@17 python@3 git curl coreutils
```

Configure Java 17 in your shell profile (`~/.zshrc` or `~/.bash_profile`):

```bash
# Add OpenJDK 17 to PATH
echo 'export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"' >> ~/.zshrc
echo 'export JAVA_HOME=$(/usr/libexec/java_home -v 17)' >> ~/.zshrc
source ~/.zshrc

# Verify Java version
java -version
```

### 2.3 Install Bazel 6.5.0 on macOS

You can install Bazel via **Bazelisk** (recommended) or direct download:

#### Option A: Using Bazelisk (Recommended)

```bash
brew install bazelisk
# Bazelisk automatically reads .bazelversion (6.5.0) in the repo root
```

#### Option B: Direct Binary Download

```bash
# Detect Apple Silicon vs Intel
if [ "$(uname -m)" = "arm64" ]; then BAZEL_ARCH="darwin-arm64"; else BAZEL_ARCH="darwin-x86_64"; fi

curl -L -o bazel "https://github.com/bazelbuild/bazel/releases/download/6.5.0/bazel-6.5.0-${BAZEL_ARCH}"
chmod +x bazel
sudo mv bazel /usr/local/bin/bazel
```

Verify:

```bash
bazel version
```

---

## 3. Windows 10 / 11 Setup

For Windows users, the official and recommended method is using **Windows Subsystem for Linux (WSL2)** with Ubuntu. This provides near-native performance, line-rate POSIX sockets, and direct integration with your Windows browser.

### 3.1 Install WSL2 (Ubuntu 24.04 LTS)

1. Open **PowerShell** as **Administrator** and run:

   ```powershell
   wsl --install -d Ubuntu-24.04
   ```

2. Restart your computer if prompted by Windows.
3. Launch **Ubuntu** from the Windows Start Menu, complete your username/password setup.
4. Inside your Ubuntu WSL2 terminal, follow the [1. Ubuntu Linux Setup](#1-ubuntu-linux-setup) instructions above.

> [!TIP]
> **WSL2 Automatic Port Forwarding:**  
> When ONOS runs inside WSL2, its ports (`8181` for Web GUI, `8101` for CLI) are automatically accessible from your Windows host browser at `http://localhost:8181/onos/ui` without any special port mapping!

### 3.2 Alternative: Run via Docker Desktop

If you prefer containerized development on Windows:

```powershell
# Clone repository
git clone https://github.com/bhuiyan-chafi/onos-classic.git
cd onos-classic

# Build container using multi-arch Dockerfile
docker build -t onos:beta-v4.0 .

# Run ONOS container exposing core ports
docker run -d --name onos -p 8181:8181 -p 8101:8101 -p 6653:6653 -p 9876:9876 onos:beta-v4.0
```

---

## 4. Common Build & Execution Workflow

Once prerequisites are installed on your chosen platform, building and running ONOS follows the unified workflow below.

### 4.1 Clone the Repository

```bash
git clone https://github.com/bhuiyan-chafi/onos-classic.git
cd onos-classic
```

### 4.2 Configure Environment Variables

Add the ONOS environment variables and development shortcuts to your shell profile (`~/.bashrc` on Linux / WSL2 or `~/.zshrc` on macOS):

```bash
# Add ONOS_ROOT and source dev aliases
echo "export ONOS_ROOT=$(pwd)" >> ~/.bashrc
echo "source \$ONOS_ROOT/tools/dev/bash_profile" >> ~/.bashrc

# Reload current shell session
source ~/.bashrc
```

Verify your environment:

```bash
cd $ONOS_ROOT
pwd
```

### 4.3 Build ONOS

ONOS provides two primary compilation modes:

#### Full Distribution Build (Includes Web GUI)

Compiles all core subsystems, drivers, apps, and the unified Angular Web GUI:

```bash
bazel build //:onos
```

#### Headless Build (Fast Controller-Only Compilation)

If you are iterating on backend drivers, distributed stores, or REST APIs and do not need the Web GUI assets rebuilt, use the headless profile:

```bash
bazel build --config=headless //:onos
```

### 4.4 Launch ONOS Locally

Launch the ONOS controller locally from the generated package with a clean runtime state:

```bash
# Using the standard Bazel target:
bazel run //:onos-local -- clean

# Or using the shorthand alias from tools/dev/bash_profile:
ok clean
```

- ONOS will unpack the bundled OpenJDK 17 LTS runtime, stage Apache Karaf, and start all core services.
- The startup output will automatically tail `karaf.log` in your terminal. Keep this terminal open.

### 4.5 Frontend Development Mode (Angular 18 LTS)

For frontend developers working on the Single Page Application (topology visualization, Lion internationalization, device tables, or navigation modules), ONOS Classic features a decoupled Angular 18 workflow with live hot-reloading:

```bash
# 1. Navigate to the Web GUI module
cd $ONOS_ROOT/web/gui

# 2. Install modern frontend dependencies (Angular 18, D3 v7, TypeScript 5)
npm install

# 3. Start the Angular CLI development server with hot-reload
npm start
# Or using the local proxy configuration against a running ONOS backend:
npm run dev
```

- The dev server listens on [http://localhost:4200](http://localhost:4200) with automatic rebuilds on file save.
- To produce optimized production bundles packaged by Bazel:
  ```bash
  npm run build
  ```
- Once compiled into `web/gui/dist/`, Bazel packaging (`bazel build //:onos` or `ok clean`) automatically bundles the modern assets into the OSGi Web Application Bundle without requiring Node or npm inside Bazel.

---

## 5. Verification & Automated Health Checks

### 5.1 Automated Smoke Test Harness

ONOS Classic includes an automated 8-point smoke test script. Open a **new terminal** and run:

```bash
cd $ONOS_ROOT
./resurrect/smoke_test.sh localhost
```

The test validates all critical system gates:

- ✅ TCP Port 8181 (Web GUI & REST API)
- ✅ TCP Port 8101 (Apache Karaf SSH CLI)
- ✅ TCP Port 6653 (OpenFlow Southbound)
- ✅ TCP Port 9876 (Atomix Raft Distributed Store)
- ✅ Northbound REST API `/onos/v1/cluster` operational state
- ✅ Northbound REST API `/onos/v1/applications`
- ✅ Web GUI HTTP endpoint accessibility
- ✅ Karaf SSH CLI service handshake banner

Expected result:

```text
===================================================================
 Smoke Test Summary:
 Total Checks:  8
 Passed:        8
 Failed:        0
 Result:        SUCCESS - ALL CHECKS PASSED
===================================================================
```

### 5.2 Accessing the Web GUI

Open your browser and navigate to:

- **URL:** [http://localhost:8181/onos/ui](http://localhost:8181/onos/ui)
- **Username:** `onos` (or `karaf`)
- **Password:** `rocks` (or `karaf`)

![ONOS Web Login](./images/onos_login.png)

### 5.3 Connecting to the Karaf CLI

Open a new terminal window and connect via SSH:

```bash
# Using the onos client helper:
onos localhost

# Or using standard SSH:
ssh -p 8101 -o StrictHostKeyChecking=no onos@localhost
```

When prompted, enter the password: **`rocks`**.

Once inside the ONOS CLI prompt (`onos>`), test basic commands:

```text
onos> summary
onos> nodes
onos> apps -s -a
onos> devices
```

---

## 6. Troubleshooting & FAQs

### Port Already in Use

If ONOS fails to bind to ports (`8181`, `8101`, `6653`, or `9876`), an existing instance may still be running. Terminate any orphan processes:

```bash
ps -ef | grep karaf | grep -v grep | awk '{print $2}' | xargs kill -9 2>/dev/null || true
```

### Missing Java 17 Module Access Errors

If you run ONOS outside of `onos-local` (e.g. manually invoking Karaf), ensure that the JEP 403 reflection flags defined in [tools/package/bin/onos-service](file:///home/.../onos-classic/tools/package/bin/onos-service) are passed in your `JAVA_OPTS`.

### Resetting Bazel Cache

If you encounter stale build artifacts or need a clean rebuild:

```bash
bazel clean --expunge
bazel build //:onos
```
