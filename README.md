# 🖥️ Termux Debian X11 Workstation

> **Run a full Debian Linux desktop on Android — GPU-accelerated, audio-ready, no root required.**

```bash
curl -fsSL https://raw.githubusercontent.com/Tricksteridze/termux-debian-x11/main/install.sh | bash
```

---

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
  - [1. Install Termux](#1-install-termux)
  - [2. Install Termux-X11](#2-install-termux-x11)
  - [3. Disable Phantom Process Killer (Android 12+)](#3-disable-phantom-process-killer-android-12)
- [Installation](#installation)
- [Usage](#usage)
- [What's Included](#whats-included)
- [Roadmap](#roadmap)

---

## Overview

This project sets up a fully functional **Debian XFCE desktop** inside Termux on Android, rendered through **Termux-X11** for a near-native graphical experience. No root required.

**Features:**
- 🚀 XFCE4 desktop with GPU acceleration via VirGL
- 🔊 PulseAudio integration for working system audio
- 🦊 Firefox ESR, Geany, Thunar, VLC out of the box
- ⚡ Compositing disabled for better performance on mobile hardware
- 📦 Clean, minimal setup — no VNC overhead

---

## Prerequisites

Before running the install script, complete the following steps.

### 1. Install Termux

> ⚠️ **Do NOT install Termux from the Google Play Store** — that version is outdated and unsupported.

Install from **F-Droid** (recommended):

[![Download on F-Droid](https://img.shields.io/badge/F--Droid-Download-green?style=for-the-badge&logo=fdroid)](https://f-droid.org/packages/com.termux/)

Or grab the latest APK directly from [GitHub Releases](https://github.com/termux/termux-app/releases).

Also install **Termux:API** from the same source:

[![Termux:API](https://img.shields.io/badge/Termux%3AAPI-F--Droid-blue?style=for-the-badge)](https://f-droid.org/packages/com.termux.api/)

---

### 2. Install Termux-X11

Termux-X11 is the graphics bridge that renders the Linux desktop on your Android screen.

[![Download Termux-X11](https://img.shields.io/badge/Termux--X11-GitHub%20Releases-orange?style=for-the-badge&logo=github)](https://github.com/termux/termux-x11/releases)

Download and install the **companion APK** (`termux-x11-arm64-v8a-debug.apk` or similar) on your device.

> After installation, open Termux-X11 at least once, then go to its settings and set **Display mode → Native**.

---

### 3. Disable Phantom Process Killer (Android 12+)

Android 12 and later aggressively kills background processes spawned by apps like Termux. This **will** cause your desktop session to crash with `Signal 9` if not addressed.

**Option A — via Wireless ADB (no PC needed on Android 11+):**

1. Enable **Developer Options**: *Settings → About Phone → tap Build Number 7 times*
2. Enable **Wireless debugging**: *Settings → Developer Options → Wireless Debugging*
3. Connect from another terminal or via **Shizuku** / **LADB** app
4. Run:

```bash
adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent"
adb shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647"
```

**Option B — via USB ADB (requires a PC):**

```bash
# On your PC with ADB installed:
adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent"
adb shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647"
```

> **Verify it worked:** After running the install script, it will check and report `✅ SUCCESS: Phantom Process Killer is disabled.`

---

## Installation

Once prerequisites are done, run this single command inside Termux:

```bash
curl -fsSL https://raw.githubusercontent.com/Tricksteridze/termux-debian-x11/main/install.sh | bash
```

The script will:
1. Update Termux packages
2. Install all required dependencies (X11, VirGL, PulseAudio, etc.)
3. Deploy a Debian rootfs via `proot-distro`
4. Configure GPU acceleration and audio
5. Generate a ready-to-use `~/start.sh` launcher

> ⏱️ First run takes **10–20 minutes** depending on your connection speed.

---

## Usage

After installation completes:

```bash
~/start.sh
```

This will:
- Start PulseAudio (sound server)
- Launch the VirGL GPU bridge
- Start Termux-X11 display server
- Boot into XFCE4 desktop
- Automatically open the Termux-X11 app

---

## What's Included

| Component | Purpose |
|-----------|---------|
| Debian (proot) | Linux userland, no root needed |
| XFCE4 | Lightweight desktop environment |
| Termux-X11 | Native Android display output |
| VirGL | GPU acceleration bridge |
| PulseAudio | Audio over TCP to Android |
| Firefox ESR | Web browser |
| Geany | Lightweight code editor |
| Thunar | File manager |
| VLC | Media player |
| Python 3 + Node.js | Development runtimes |
| build-essential | Compilers and dev tools |

---

## Roadmap

- [ ] **Remote browser access over local network** — connect to the desktop from any device on your Wi-Fi using a browser (noVNC or similar), no app installation required on the client side
- [ ] **Remote access outside local network** — secure tunnel support (e.g. via Tailscale or ngrok) so you can reach your Android workstation from anywhere
- [ ] Persistent session recovery after app restart
- [ ] One-tap launcher shortcut via Termux widget

---

<details>
<summary>📌 Troubleshooting</summary>

**Black screen in Termux-X11?**
Make sure Display mode is set to **Native** in Termux-X11 settings.

**Audio not working?**
The PulseAudio TCP module needs `127.0.0.1` to be accessible. Try restarting with `~/start.sh`.

**Session crashes after a few minutes?**
Phantom Process Killer is still active. Reapply the ADB commands from [Step 3](#3-disable-phantom-process-killer-android-12).

**`pkg install` fails with 404?**
Run `pkg update` first, then retry.

**black screen on startup?**
It's okay, it might take a while.

</details>

---

<p align="center">
  <sub>Built for Android · Powered by proot-distro, Termux-X11, and VirGL</sub>
</p>
