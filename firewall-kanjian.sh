#!/bin/sh
### BEGIN INIT INFO
# Provides:          firewall
# Required-Start:    $syslog
# Required-Stop:     $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: firewall
# Description:       Enable firewall.
### END INIT INFO

case "$1" in
    start)
        echo "Initialisation des règles de firewall pour la NDH"
        # Vider les tables actuelles
iptables -t filter -F

# Vider les règles personnelles
iptables -t filter -X

# Interdire toute connexion entrante et sortante
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD DROP
iptables -t filter -P OUTPUT DROP

# Ne pas casser les connexions etablies
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Autoriser loopback
iptables -t filter -A INPUT -i lo -j ACCEPT
iptables -t filter -A OUTPUT -o lo -j ACCEPT

#Site web
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# DNS
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
#iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT
echo "Règles chargées"
logger -p local0.notice -t Firewall "Firewall up"        ;;
    stop)
        echo "Arrêt du firewall"
        # Vider les tables actuelles
iptables -t filter -F

# Vider les règles personnelles
iptables -t filter -X

# Ouvrir toute connexion entrante et sortante
iptables -t filter -P INPUT ACCEPT
iptables -t filter -P FORWARD ACCEPT
iptables -t filter -P OUTPUT ACCEPT
logger -p local0.notice -t Firewall "Firewall down"
        ;;

    *)
        echo "Usage: /etc/init.d/firewall {start|stop}"
        exit 1
    ;;
esac
exit 0
