#!/bin/bash


# PRE-SETUP
if (( $EUID != 0 )); then 
   echo "This must be run as root. Try 'sudo !!'." 
   exit 1 
fi

echo "$(tput setaf 6)Updating Packages...$(tput sgr0)"
apt update -y
apt upgrade -y


# SETUP PI-HOLE
echo "$(tput setaf 6)Installing Pi-hole...$(tput sgr0)"
echo "Installing unbound..."
apt install unbound

echo "Configuring unbound..."
echo "
server:
    # If no logfile is specified, syslog is used
    # logfile: '/var/log/unbound/unbound.log'
    verbosity: 0

    interface: 127.0.0.1
    port: 5335
    do-ip4: yes
    do-udp: yes
    do-tcp: yes

    # May be set to yes if you have IPv6 connectivity
    do-ip6: yes

    # You want to leave this to no unless you have *native* IPv6. With 6to4 and
    # Terredo tunnels your web browser should favor IPv4 for the same reasons
    prefer-ip6: no

    # Use this only when you downloaded the list of primary root servers!
    # If you use the default dns-root-data package, unbound will find it automatically
    #root-hints: '/var/lib/unbound/root.hints'

    # Trust glue only if it is within the server's authority
    harden-glue: yes

    # Require DNSSEC data for trust-anchored zones, if such data is absent, the zone becomes BOGUS
    harden-dnssec-stripped: yes

    # Don't use Capitalization randomization as it known to cause DNSSEC issues sometimes
    # see https://discourse.pi-hole.net/t/unbound-stubby-or-dnscrypt-proxy/9378 for further details
    use-caps-for-id: no

    # Reduce EDNS reassembly buffer size.
    # Suggested by the unbound man page to reduce fragmentation reassembly problems
    edns-buffer-size: 1472

    # Perform prefetching of close to expired message cache entries
    # This only applies to domains that have been frequently queried
    prefetch: yes

    # One thread should be sufficient, can be increased on beefy machines. In reality for most users running on small networks or on a single machine, it should be unnecessary to seek performance enhancement by increasing num-threads above 1.
    num-threads: 1

    # Ensure kernel buffer is large enough to not lose messages in traffic spikes
    so-rcvbuf: 1m

    # Ensure privacy of local IP ranges
    private-address: 192.168.0.0/16
    private-address: 169.254.0.0/16
    private-address: 172.16.0.0/12
    private-address: 10.0.0.0/8
    private-address: fd00::/8
    private-address: fe80::/10
" > /etc/unbound/unbound.conf.d/pi-hole.conf

service unbound restart

# TEST RECURSIVE DNS
# dig pi-hole.net @127.0.0.1 -p 5335
# dig sigfail.verteiltesysteme.net @127.0.0.1 -p 5335
# dig sigok.verteiltesysteme.net @127.0.0.1 -p 5335

echo "Installing Pi-Hole..."
wget -O basic-install.sh https://install.pi-hole.net
bash basic-install.sh
# CONFIGURE UPSTREAM DNS AS CUSTOM: 127.0.0.1:5335
# CHECK IF /etc/dhcpcd.conf CONTAINS static domain_name_servers=127.0.0.1:5335

# POST INSTALL
# SET 192.168.178.2 AS DNS-SERVER ON FRITZBOX
# ENABLE DNSSEC IN PI-HOLE SETTINGS
# ADD FOLLOWING ADLISTS, THEN UPDATE GRAVITY
# https://firebog.net/

# AdBlock Plus
# https://secure.fanboy.co.nz/fanboy-annoyance.txt
# https://easylist.to/easylist/fanboy-social.txt
# https://easylist.to/easylist/easylist.txt
# https://easylist.to/easylist/easyprivacy.txt
# https://secure.fanboy.co.nz/fanboy-cookiemonster.txt

# uBlock Origin
# https://pgl.yoyo.org/as/serverlist.php?showintro=0;hostformat=hosts
# https://curben.gitlab.io/malware-filter/urlhaus-filter-domains.txt
# https://github.com/uBlockOrigin/uAssets/blob/master/filters/annoyances.txt
# https://github.com/uBlockOrigin/uAssets/blob/master/filters/filters-2020.txt
# https://github.com/uBlockOrigin/uAssets/blob/master/filters/filters-2021.txt
# https://github.com/uBlockOrigin/uAssets/blob/master/filters/filters.txt
# https://github.com/uBlockOrigin/uAssets/blob/master/filters/legacy.txt
# https://github.com/uBlockOrigin/uAssets/blob/master/filters/privacy.txt
# https://github.com/uBlockOrigin/uAssets/blob/master/filters/resource-abuse.txt
# https://github.com/uBlockOrigin/uAssets/blob/master/filters/unbreak.txt
# https://github.com/uBlockOrigin/uAssets/blob/master/filters/badlists.txt
# https://github.com/uBlockOrigin/uAssets/blob/master/filters/badware.txt

# Disconnect.me
# https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt
# https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt

# SETUP SCRIPT FOR YT ADS
git clone https://github.com/deividgdt/ytadsblocker.git
cd ytadsblocker
chmod a+x ytadsblocker.sh
./ytadsblocker.sh install
systemctl enable ytadsblocker
systemctl start ytadsblocker

# SETUP WIFI-ACCESS-POINT 
echo "Installing dnsmasq..."
apt install dnsmasq -y
systemctl stop dnsmasq

echo "Configuring wlan interface..."
echo "interface wlan0
    static ip_address=192.168.4.1/24
    nohook wpa_supplicant" >> /etc/dhcpcd.conf

echo "Restarting dhcpcd..."
service dhcpcd restart

echo "Configuring dnsmasq..."
mv /etc/dnsmasq.conf /etc/dnsmasq.conf.orig
echo "interface=wlan0      # Use the require wireless interface - usually wlan0
dhcp-range=192.168.4.2,192.168.4.22,255.255.255.0,24h" > /etc/dnsmasq.conf

echo "Enabling dnsmasq and restart..."
systemctl unmask dnsmasq
systemctl enable dnsmasq
systemctl restart dnsmasq

echo "Unlock wlan soft lock with rfkill..."
if command -v rfkill &> /dev/null
then
    rfkill unblock wlan
fi

echo "Install and enable hostapd..."
apt install hostapd -y
systemctl unmask hostapd
systemctl enable hostapd

echo "Configuring Hostapd..."
echo "Provide ssid (1-32 ASCII chars):"
read ssid
echo "Provide wpa2 password (minimum 8 char):"
read passphrase

echo "interface=wlan0
driver=nl80211
ssid=$ssid
hw_mode=g
channel=7
wmm_enabled=0
macaddr_acl=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_passphrase=$passphrase
wpa_key_mgmt=WPA-PSK
wpa_pairwise=TKIP
rsn_pairwise=CCMP
" > /etc/hostapd/hostapd.conf

echo 'DAEMON_CONF="/etc/hostapd/hostapd.conf"' >> /etc/default/hostapd

echo "Starting hostapd..."
systemctl start hostapd

echo "Setting IP forwarding to start at system boot..."
cp /etc/sysctl.conf /etc/sysctl.bak
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

echo "up iptables-restore < /etc/iptables.ipv4.nat" >> /etc/network/interfaces

echo "Activating IP forwarding..."
sh -c "echo 1 > /proc/sys/net/ipv4/ip_forward"

echo "Setting up IP tables to interconnect ports..."
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i wlan0 -o eth0 -j ACCEPT

echo "Saving IP tables..."
sh -c "iptables-save > /etc/iptables.ipv4.nat"

echo "Configuring NAT to start at boot..."
sed -i '/exit 0/ i iptables-restore < /etc/iptables.ipv4.nat' /etc/rc.local

# SETUP TOR
echo "$(tput setaf 6)Installing Tor...$(tput sgr0)"
apt install tor -y

echo "Configuring Tor..."
cp /etc/tor/torrc /etc/tor/torrc.bak
echo "Log notice file /var/log/tor/notices.log
VirtualAddrNetwork 10.192.0.0/10
AutomapHostsSuffixes .onion,.exit
AutomapHostsOnResolve 1
TransPort 192.168.4.1:9040" >> /etc/tor/torrc
# DNSPort 192.168.4.1:53" >> /etc/tor/torrc

echo "Flushing old IP tables..."
iptables -F
iptables -t nat -F

# MAYBE NOT NEEDED AS PIHOLE IS DNS SERVER
# echo "$(tput setaf 6)Rerouting DNS traffic...$(tput sgr0)"
# iptables -t nat -A PREROUTING -i wlan0 -p udp --dport 53 -j REDIRECT --to-ports 53

echo "Rerouting TCP traffic over tor..."
iptables -t nat -A PREROUTING -i wlan0 -p tcp --syn -j REDIRECT --to-ports 9040

echo "Saving IP tables..."
sh -c "iptables-save > /etc/iptables.ipv4.nat"

echo "Setting up logging in /var/log/tor/notices.log..."
touch /var/log/tor/notices.logstart 
chown debian-tor /var/log/tor/notices.log
chmod 644 /var/log/tor/notices.log

echo "Starting Tor..."
service tor start

echo "Setting Tor to start at boot..."
update-rc.d tor enable

# SETUP UTILITIES
apt install firefox-esr vidalia transmission

# define privoxy in ff network settings: 127.0.0.1:8118

# configure transmission to use privoxy
echo "
http_proxy=http://127.0.0.1:8118/
HTTP_PROXY=$http_proxy
export http_proxy HTTP_PROXY
" >> /home/pi/.profile

echo "$(tput setaf 6)Setup complete!

$(tput bold)Verify by visiting: $(tput setaf 3)https://check.torproject.org/$(tput sgr0)

$(tput setaf 6)Rebooting$(tput sgr0)..."
reboot

exit 0
