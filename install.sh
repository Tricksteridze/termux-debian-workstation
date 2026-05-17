#!/data/data/com.termux/files/usr/bin/bash

# 1. PRE-FLIGHT CHECKS & TERMUX SETUP
echo "[*] Initializing environment checks..."

# Phantom Process Killer Check
PHANTOM_KILLER=$(settings get global settings_enable_monitor_phantom_procs 2>/dev/null)
if [ "$PHANTOM_KILLER" == "false" ]; then
    echo "✅ SUCCESS: Phantom Process Killer is disabled."
else
    echo "⚠️  WARNING: Phantom Process Killer is ACTIVE."
    echo "Please run the ADB command from README to avoid Signal 9 crashes."
fi

echo "[*] Installing Termux dependencies..."
pkg update -y && pkg upgrade -y
pkg install termux-api x11-repo proot-distro pulseaudio wget curl git virglrenderer-android -y

# Install Graphics Bridge
echo "[*] Installing Termux-X11..."
pkg install termux-x11-nightly -y || pkg install termux-x11 -y

# 2. DISTRIBUTION DEPLOYMENT
if [ -d "$PREFIX/var/lib/proot-distro/installed-rootfs/debian" ]; then
    echo "[!] Debian core already exists."
else
    echo "[*] Installing Debian core..."
    proot-distro install debian
fi

# 3. INTERNAL SYSTEM CONFIGURATION (Debian Side)
echo "[*] Configuring internal Debian environment..."

# Installing packages
DEBIAN_PACKAGES="xfce4 xfce4-terminal xwayland dbus-x11 firefox-esr python3 python3-pip nodejs build-essential sudo bash-completion thunar mousepad geany htop vlc mesa-utils"

proot-distro login debian --shared-tmp -- bash -c "
    apt update && apt upgrade -y
    apt install $DEBIAN_PACKAGES -y

    # Global GPU Acceleration Setup (VirGL)
    echo 'export GALLIUM_DRIVER=virpipe' >> /etc/environment
    echo 'export MESA_GL_VERSION_OVERRIDE=4.0' >> /etc/environment
    echo 'export PULSE_SERVER=127.0.0.1' >> /etc/environment

    # Performance: Disable XFCE Compositing for better response
    xfconf-query -c xfwm4 -p /general/use_compositing -n -t bool -s false

    # Stability: Remove light-locker safely
    apt purge -y light-locker || echo 'light-locker not found, skipping...'

    apt clean
"

# 4. START SCRIPT GENERATION
echo "[*] Generating optimized start.sh..."
cat << 'EOF' > ~/start.sh
#!/data/data/com.termux/files/usr/bin/bash

# Cleanup old sessions
pkill -f termux-x11; pkill -f pulseaudio; pkill -f virgl
rm -rf /tmp/.X* /tmp/.X11-unix/X*

echo "[*] Starting Debian Workstation (Termux-X11)..."

# Start Audio and Graphics Servers
pulseaudio --start --exit-idle-time=-1
sleep 3
pacmd load-module module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1
virgl_test_server_android &

# Launch X11 Session
termux-x11 :1 -xstartup "sleep 2; proot-distro login debian --shared-tmp -- bash -c 'export DISPLAY=:1; startxfce4'" &

sleep 3

# Automatically open the Termux-X11 App
am start --user 0 -n com.termux.x11/com.termux.x11.MainActivity
EOF

chmod +x ~/start.sh

echo "----------------------------------------------------"
echo "INSTALLATION SUCCESSFUL"
echo "1. Open Termux-X11 app and ensure 'Display mode' is set to 'Native'."
echo "2. Run './start.sh' to begin."
echo "----------------------------------------------------"
