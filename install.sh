#!/bin/sh

# Author: GravitySandwichh
# Version: 1.0
# HiveAP 330 MT7916

echo "Welcome to the automated HiveAP 330 Deployment script for MT7916 Upgraded AP\'s"
echo ""
echo ""
echo "Please enter the Access Point name:"
read APName

# Set hostname
echo "Setting Hostname"
uci set system.@system[0].hostname=$APName
uci commit system
/etc/init.d/system reload

# Update opkg manager
echo "Updating Package Manager Repositories"
opkg update

# Install CPU Monitoring
echo "Installing CPU Monitoring"
wget --no-check-certificate -O /tmp/luci-app-cpu-status_0.4-1_all.ipk https://github.com/GravitySandwichh/HiveAP330-MT7916/raw/main/config/luci-app-cpu-status_0.4-1_all.ipk
opkg install /tmp/luci-app-cpu-status_0.4-1_all.ipk
rm /tmp/luci-app-cpu-status_0.4-1_all.ipk
/etc/init.d/rpcd reload

# Install Temp Monitoring
echo "Installing Temperature Monitoring"
wget --no-check-certificate -O /tmp/luci-app-temp-status_0.3-5_all.ipk https://github.com/GravitySandwichh/HiveAP330-MT7916/raw/main/config/luci-app-temp-status_0.3-5_all.ipk
opkg install /tmp/luci-app-temp-status_0.3-5_all.ipk
rm /tmp/luci-app-temp-status_0.3-5_all.ipk
/etc/init.d/rpcd reload

# Download MT7916 Firmware
echo "Downloading MT7916 Firmware"
mkdir /lib/firmware/mediatek/
wget --no-check-certificate -O /lib/firmware/mediatek/mt7916_eeprom.bin https://github.com/openwrt/mt76/raw/master/firmware/mt7916_eeprom.bin
wget --no-check-certificate -O /lib/firmware/mediatek/mt7916_rom_patch.bin https://github.com/openwrt/mt76/raw/master/firmware/mt7916_rom_patch.bin
wget --no-check-certificate -O /lib/firmware/mediatek/mt7916_wa.bin https://github.com/openwrt/mt76/raw/master/firmware/mt7916_wa.bin
wget --no-check-certificate -O /lib/firmware/mediatek/mt7916_wm.bin https://github.com/openwrt/mt76/raw/master/firmware/mt7916_wm.bin

# Install MT7915 Kernel Modules
echo "Installing MT7915e Kernel Modules"
opkg install kmod-mt7915e

# Convert to Dumb AP
echo "Converting to Dumb AP and Enabling Multicast for Chromecast Support"
echo "Downloading new LAN Config"
wget --no-check-certificate -O /etc/config/network https://raw.githubusercontent.com/GravitySandwichh/HiveAP330-MT7916/main/config/network
echo "Disabling DHCP"
uci set dhcp.lan.ignore=1
uci commit dhcp
/etc/init.d/dnsmasq restart
echo "Disabling DHCPv6"
uci set dhcp.lan.dhcpv6=disabled
uci set dhcp.lan.ra=disabled
uci commit
echo "Disabling Firewall"
/etc/init.d/firewall disable
/etc/init.d/firewall stop
echo "Creating RC Script to make sure Firewall and DHCP Server stay disabled on upgrade"
wget --no-check-certificate -O /etc/rc.local https://raw.githubusercontent.com/GravitySandwichh/HiveAP330-MT7916/main/config/rc.local

echo "Configuration has finished! Router will now reboot and request DHCP address. It will be reachable from there. Please note that this can take a while due to the amount of changes made."
/etc/init.d/network reload

sleep 10s

reboot
