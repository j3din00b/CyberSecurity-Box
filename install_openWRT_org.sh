#!/bin/sh
clear
echo '########################################################'
echo '#                                                      #'
echo '#                 CyberSecurity-Box                    #'
echo '#                                                      #'
echo '# local Privacy for Voice-Assistent Smart-TV SmartHome #'
echo '#                                                      #'
echo '########################################################'
echo
echo
echo
#Firewall Pihole Unbound Tor Transparentproxy
/etc/init.d/dnsmasq stop
/etc/init.d/dnsmasq disable
opkg update
opkg remove dnsmasq
opkg update >/dev/null
opkg upgrade $(opkg list-upgradable | awk '{print $1}')  >/dev/null
opkg update >/dev/null
opkg install nano wget curl kmod-usb-storage kmod-usb-storage-extras e2fsprogs kmod-fs-ext4 block-mount kmod-fs-vfat kmod-nls-cp437 kmod-nls-iso8859-1 unbound-daemon-heavy unbound-anchor unbound-control unbound-control-setup unbound-host unbound-checkconf ca-certificates acme acme-dnsapi luci-app-acme stubby tor tor-geoip bind-dig openssh-sftp-server ipset ipset-dns tc iptables-mod-ipopt luci-app-qos luci-app-nft-qos nft-qos getdns drill mwan3 luci-app-mwan3 dnsmasq-full --force-overwrite
/etc/init.d/dnsmasq start
clear
echo
echo '########################################################'
echo '#                                                      #'
echo '#                 CyberSecurity-Box                    #'
echo '#                                                      #'
echo '# local Privacy for Voice-Assistent Smart-TV SmartHome #'
echo '#                                                      #'
echo '########################################################'
echo
echo 'Software Packeges installed'
echo
 

release=$(cat /etc/openwrt_release | grep "DISTRIB_RELEASE" | cut -f2 -d '=')
revision=$(cat /etc/openwrt_release | grep "DISTRIB_REVISION" | cut -f2 -d '=')
revision=${revision::-1}
release=${release::-1}
revision=${revision:1}
release=${release:1}
echo $release $revision
 
#Localaddresen
LOCALADDRESS="127.192.0.1/10"

actLoop=$(ifconfig | grep '^l\w*' -m 1 | cut -f1 -d ' ')
actEth=$(ifconfig | grep '^e\w*' -m 1 | cut -f1 -d ' ')
actWlan=$(ifconfig | grep '^w\w*' -m 1 | cut -f1 -d ' ')

#Internet Gateway
INET_GW=$(ip route | grep default | cut -f3  -d ' ')
INET_GW_org=$INET_GW

echo 'Please give me the WAN-IP (Gateway/Router): ('$INET_GW')'
read INET_GW
echo
if [ "$INET_GW" = "" ]
	then
		INET_GW=$INET_GW_org	 
		
fi

WAN_ip=$(echo $INET_GW | cut -f1 -d '.')
WAN_ip=$WAN_ip"."$(echo $INET_GW | cut -f2 -d '.')
WAN_ip=$WAN_ip"."$(echo $INET_GW | cut -f3 -d '.')".250"

WAN_broadcast=$(echo $INET_GW | cut -f1 -d '.')
WAN_broadcast=$WAN_broadcast"."$(echo $INET_GW | cut -f2 -d '.')
WAN_broadcast=$WAN_broadcast"."$(echo $INET_GW | cut -f3 -d '.')".255"

WAN_MOBILE_ip=$(echo $INET_GW | cut -f1 -d '.')
WAN_MOBILE_ip=$WAN_ip"."$(echo $INET_GW | cut -f2 -d '.')
WAN_MOBILE_ip=$WAN_ip"."$(echo $INET_GW | cut -f3 -d '.')".251"

WAN_MOBILE_broadcast=$(echo $INET_GW | cut -f1 -d '.')
WAN_MOBILE_broadcast=$WAN_broadcast"."$(echo $INET_GW | cut -f2 -d '.')
WAN_MOBILE_broadcast=$WAN_broadcast"."$(echo $INET_GW | cut -f3 -d '.')".255"

WAN_MOBILE_GW=$(echo $INET_GW | cut -f1 -d '.')
WAN_MOBILE_GW=$WAN_ip"."$(echo $INET_GW | cut -f2 -d '.')
WAN_MOBILE_GW=$WAN_ip"."$(echo $INET_GW | cut -f3 -d '.')".253"


#complet Internet
Internet="0.0.0.0/0"

#all Adresses
all_IP="0.0.0.0"
all_IP6="[::]"

#Access to Server
ACCESS_SERVER=$(echo $($(echo ip addr show dev $(echo $actEth | cut -f1 -d' ')) | grep inet | cut -f6 -d ' ' ) | cut -f1 -d ' ' )

#Lokal LAN
LAN=$(echo $($(echo ip addr show dev $(echo $actEth | cut -f1 -d' ')) | grep inet | cut -f6 -d ' ' ) | cut -f1 -d ' ' | cut -f1 -d'/' ) 
LAN_org=$LAN

echo 'Type the LAN-IP (Internal Network): ('$LAN')'
read LAN
if [ "$LAN" = "" ]  
	then
		LAN=$LAN_org
fi

LOCAL_DOMAIN='CyberSecBox.local'
echo
echo 'Your local Domain of your LAN? (CyberSecBox.local)'
read LOCAL_DOMAIN
if [ "$LOCAL_DOMAIN" = "" ]
	then
		LOCAL_DOMAIN='CyberSecBox.local'
fi

WIFI_SSID='CyberSecBox'
WIFI_SSID_org=$WIFI_SSID
echo
echo 'The Main-WiFi-SSID? ('$WIFI_SSID')'
read WIFI_SSID
if [ "$WIFI_SSID" = "" ]
        then
                WIFI_SSID=$WIFI_SSID_org
fi


WIFI_PASS='Cyber,Sec9ox'
WIFI_PASS_org=$WIFI_PASS
echo
echo 'And the WiFi-Key? (Cyber,Sec9ox)'
read WIFI_PASS
if [ "$WIFI_PASS" = "" ]
	then
		WIFI_PASS=$WIFI_PASS_org
fi

USERNAME='root'
echo
echo 'Enter the user for the login: (default: root)'
read -s USERNAME
passwd $USERNAME

SUBNET=$(echo $LAN | cut -f3 -d '.')
SUBNET_sep=$SUBNET

if [ $SUBNET_sep -lt 125 ]
        then
                SUBNET=$(($SUBNET + 125))
                if  [ $SUBNET_sep -lt 5 ]
                        then
                                SUBNET_sep=$(($SUBNET_sep + 6))
                fi

        else
                if  [ $SUBNET_sep -gt 250 ]
                        then
                                SUBNET_sep=$(($SUBNET_sep - 62))
                fi

fi

SERVER_range='192.168.'$(($SUBNET_sep - 123))'.2,192.168.'$(($SUBNET_sep - 123))'.200,24h'
CONTROL_range='192.168.'$(($SUBNET_sep - 119))'.2,192.168.'$(($SUBNET_sep - 119))'.200,24h'
HCONTROL_range='192.168.'$(($SUBNET_sep - 118))'.2,192.168.'$(($SUBNET_sep - 118))'.200,24h'
INET_range='192.168.'$SUBNET_sep'.2,192.168.'$SUBNET_sep'.200,24h'
VOICE_range='192.168.'$(($SUBNET_sep + 1))'.2,192.168.'$(($SUBNET_sep + 1))'.200,24h'
ENTERTAIN_range='192.168.'$(($SUBNET_sep - 1))'.2,192.168.'$(($SUBNET_sep - 1))'.200,24h'
GUEST_range='192.168.'$(($SUBNET_sep + 10))'.2,192.168.'$(($SUBNET_sep + 10))'.200,24h'
CMOVIE_range='192.168.'$(($SUBNET_sep + 9))'.2,192.168.'$(($SUBNET_sep + 9))'.200,24h'

SERVER_ip='192.168.'$(($SUBNET_sep - 123))'.254'
CONTROL_ip='192.168.'$(($SUBNET_sep - 119))'.254'
HCONTROL_ip='192.168.'$(($SUBNET_sep - 118))'.254'
INET_ip='192.168.'$SUBNET_sep'.1'
VOICE_ip='192.168.'$(($SUBNET_sep + 1))'.1'
ENTERTAIN_ip='192.168.'$(($SUBNET_sep - 1))'.1'
GUEST_ip='192.168.'$(($SUBNET_sep + 10))'.1'
CMOVIE_ip='192.168.'$(($SUBNET_sep + 9))'.1'

SERVER_broadcast='192.168.'$(($SUBNET_sep - 123))'.255'
CONTROL_broadcast='192.168.'$(($SUBNET_sep - 119))'.255'
HCONTROL_broadcast='192.168.'$(($SUBNET_sep - 118))'.255'
INET_broadcast='192.168.'$SUBNET_sep'.255'
VOICE_broadcast='192.168.'$(($SUBNET_sep + 1))'.255'
ENTERTAIN_broadcast='192.168.'$(($SUBNET_sep - 1))'.255'
GUEST_broadcast='192.168.'$(($SUBNET_sep + 10))'.255'
CMOVIE_broadcast='192.168.'$(($SUBNET_sep + 9))'.255'

SERVER_lan='192.168.'$(($SUBNET_sep - 123))'.0'
CONTROL_lan='192.168.'$(($SUBNET_sep - 119))'.0'
HCONTROL_lan='192.168.'$(($SUBNET_sep - 118))'.0'
INET_lan='192.168.'$SUBNET_sep'.0'
VOICE_lan='192.168.'$(($SUBNET_sep + 1))'.0'
ENTERTAIN_lan='192.168.'$(($SUBNET_sep - 1))'.0'
GUEST_lan='192.168.'$(($SUBNET_sep + 10))'.0'
CMOVIE_lan='192.168.'$(($SUBNET_sep + 9))'.0'

SERVER_net=$SERVER_ip'/24'
CONTROL_net=$CONTROL_ip'/24'
HCONTROL_net=$HCONTROL_ip'/24'
INET_net=$INET_ip'/24'
VOICE_net=$VOICE_ip'/24'
ENTERTAIN_net=$ENTERTAIN_ip'/24'
GUEST_net=$GUEST_ip'/24'
CMOVIE_net=$CMOVIE_ip'/24'
WAN_net=$WAN_ip'/24'
WAN_MOBILE_net=$WAN_MOBILE_ip'/24'

SERVER_domain='server.'$LOCAL_DOMAIN
CONTROL_domain='control.'$LOCAL_DOMAIN
HCONTROL_domain='hcontrol.'$LOCAL_DOMAIN
INET_domain='inet.'$LOCAL_DOMAIN
VOICE_domain='voice.local'
ENTERTAIN_domain='entertain.local'
GUEST_domain='guest.local'
CMOVIE_domain='cmovie.local'


SERVER_ssid='DMZ-'$WIFI_SSID
CONTROL_ssid='Control-'$WIFI_SSID
HCONTROL_ssid='HControl-'$WIFI_SSID
INET_ssid='iNet-'$WIFI_SSID
VOICE_ssid='Voice-'$WIFI_SSID
ENTERTAIN_ssid='Entertain-'$WIFI_SSID
GUEST_ssid='Guest-'$WIFI_SSID
CMOVIE_ssid='Free_CMovie_Portal'
Adversisment_ssid='Telekom'


#----------------------------------------------------------------------------
echo
echo "define variables"
echo
#DHCP
DHCP_port="67"
all_other_DHCP_port="1-66 68-65535"


#Printer_LPR_IPP
Printer_port="515 631 9100"
all_other_Printer_port="1-514 516-630 632-9099 9101-65535"

#NTP
NTP_port="123"
all_other_NTP_port="1-122 124-65535"

#NFS
NFS_port="2049"
all_other_NFS_port="1-2048 2050-65535"

#AFP
AFP_port="548"
all_other_AFP_port="1-547 549-65535"

#SMB
SMB_port="137 138 139 445"
all_other_SMB_port="1-444 446-136 140-65535"

#VPN
VPN_port="500 4500"
all_other_VPN_port="1-499 501-4499 4501-65535"

#Open Directory Proxy (ODProxy)
ODProxy_port="625"
all_other_ODProxy_port="1-624 266-65535"

#Syslog
#UDP
#514
Syslog_port="514"
all_other_Syslog_port="1-513 515-65535"

#NetBIOS
#UDP
#138
NetBIOS_port="138"
all_other_NetBIOS_port="1-137 139-65535"

#WINS
#137
WINS_port="137"
all_other_WINS_port="1-136 138-65535"

#Simple Service Discovery Protocol (SSDP)
#UDP
#1900
SSDP_port="1900"
all_other_SSDP_port="1-1899 1901-65535"

#Web Services Dynamic Discovery (WS-Discovery)
#UDP
#3702
WS_Discovery_port="5357 3702"
all_other_WS_Discovery_port="1-5356 5358-3701 3703-65535"

#Port Control Protocol (PCP)
#5351
PCP_port="5351"
all_other_PCP_port="1-5350 3552-65535"

#Port NETWORK Controler
#8043
CONTROLER_port="8043"
all_other_CONTROLER_port="1-8042 8044-65535"

#Multicast Domain Name Service (mDNS)
#5353
mDNS_port="5353"
all_other_mDNS_port="1-5352 5354-65535"

#Link Local Multicast Name Resolution (LLMNR)
#5357
LLMNR_port="5357"
all_other_LLMNR_port="1-5356 5358-65535"

#Telefonie (SIP)
#5060
SIP_port="5060"
all_other_SIP_port="1-5059 5061-65535"

#Telefonie (RTP, RTCP)
#7077-7097
RTP_RTCP_port="7077-7097"
all_other_RTP_RTCP_port="1-7076 7098-65535"

#Telefonie (SIP, RTP, RTCP)
#7077-7097
SIP_RTP_RTCP_port="5060 7077-7097"
all_other_SIP_RTP_RTCP_port="1-5059 5061-7076 7098-65535"

#FRITZ!Box
AVM_port="8181-8186"
all_other_AVM_port="1-8180 8187-65535"

#FRITZ!Box MESH
AVM_Mesh_port="50842 53805"
all_other_AVM_Mesh_port="1-50841 50843-53804 53806-65535"

#Torrc Ports
TORRC_port="9030 9040 9049 9050 9053 9060"
all_other_TORRC_port="1-9029 9031-9039 9041-9048 9051 9052 9054-9059 9061-65535"


#SPYPE
Skype_port="1000-10000 16000-26000 38562 50000-65000"
all_other_Skype_port="1-999 10001-15999 26001-38561 38563-49999 65001-65535"
Skype_udp_port="38562 3478-3481 50000-60000"
all_other_Skype_udp_port="1-3477 3482-38561 38563-49999 60000-65535"

#MSRDP_Alexa Call (Ports)
#3389
MSRDP_AlexaCall_port="3389"
all_other_MSRDP_AlexaCall_port="1-3388 3390-65535"

#HTTP_s (Ports)
#80, 443, 8080
HTTP_s_port="80 443 8080"
HTTPs_port="443"
HTTP_port="80"
all_other_HTTP_s_port="1-79 81-442 444-8079 8081-65535"

#FTP_Server
FTP_port="20 21"
all_other_FTP_port="1-19 22-65535"

#Remote_Acces_http(s)
#40443-40446
Acces_http_port="40443-40446"
all_other_Acces_http_port="1-40442 40447-65535"

#eMule (Ports)
#4662, 4672
eMule_port="4662 4672"
all_other_eMule_port="1-4661 4663-4671 4673-65535"

#Bittorrent (Ports)
#6881-6999
Bittorrent_port="6881-6999"
all_other_Bittorrent_port="1-6880 7000-65535"

#DNS
DNS_port="53"
all_other_DNS_port="1-52 54-65535"

#Tor_dns
DNS_TOR_port="9053"
all_other_DNS_TOR_port="1-9052 9054-65535"

#DNS Crypt
DNS_CRYPT_port="5300"
all_other_DNS_CRYPT_port="1-5299 5301-65535"

#DNS Stubby
DNS_STUBBY_port="5453"
all_other_DNS_STUBBY_port="1-5452"5454-65535

#DNS_UNBOUND
DNS_UNBOUND_port="5353"
all_other_DNS_UNBOUND_port="1-5352 5354-65535"

#SDNS
SDNS_port="853"
all_other_SDNS_port="1-852 854-65535"

#allDNS Ports
all_DNS_port="53 853 5300 5353 5453 9053 33216 34885 35113 35141 37572 38700 39354 41227 41287 41675 43609 47535 48427 48736 48777 50275 54715 54789 51465 56343 56534 57687 60870"
all_other_all_DNS_port="1-52 54-852 854-5299 5301-5352 5354-5452 5454-9052 9054-33215 33217- 34884 34886-35112 35114-35140 35142-37571 37573-38699 38701-39353 39355-41226 41227-41286 41288-41674 41676-43608 43610-47534 47536-48426 48428-48735 48737-48776 48778-50274 50276-54714 54716-54788 54790-51464 51466-56342 56344-56533 56535-57686 57688-60869 60871-65535"

#NTOPNG Port
#NTOPNG_PORT="3000"
NTOPNG_port="3000"
all_other_NTOPNG_port="1-2999 3001-65535"

#Privoxy Port
#PRIVOXY_PORT="8188"
PRIVOXY_port="8188"
all_other_PRIVOXY_port="1-8187 8189-65535"

#PiHole Port
#PIHOLE_PORT="81"
#PIHOLE_FTL_PORT="4711"
#PiHole Port
PIHOLE_port="81"
PIHOLE_FTL_port="4711"
all_PIHOLE_port="81 4711"
all_other_PIHOLE_port="1-80 82-65535"
all_other_PIHOLE_FTL_port="1-4710 4712-65535"
all_othjer_all_PIHOLE_port="1-80 82-4710 4712-65535"

#Real Time Streaming Protocol (RTSP)
#"554"
RTSP_port="554"
all_other_RTSP_port="1-553 555-65535"

#NNTP
#"119"
NNTP_port="119"
all_other_NNTP_port="1-118 120-65535"

#RPC
RPC_port="111"
all_other_RPC_port="1-110 112-65535"

#LDAP
#"389 636"
LDAP_port="389 636"
all_other_LDAP_port="1-388 390-635 637-65535"

#Password_Server
#"106"
PASSWDSRV_port="106"
all_other_PASSWDSRV_port="1-105 107-65535"

#KERBEROS
#"88 749"
KERBEROS_port="88 749"
all_other_KERBEROS_port="1-87 89-748 750-65535"

#IMAP4 Port
#IMAP_PORT="143 993 626"
IMAP_port="143 993 626"
all_other_IMAP_port="1-142 144-992 994-625 627-65535"

#POP3 Port
#POP3_PORT="110 995"
POP3_port="110 995"
all_other_POP3_port="1-109 111-994 996-65535"

#smtp
#"25 465 587"
SMTP_port="25 465 587"
all_other_SMTP_port="1-24 26-464 466-586 588-65535"

#all Email
email_port="25 110 143 465 587 626 993 995"
all_other_email_port="1-24 26-109 111-142 144-464 466-586 588-625 627-992 994 996-65535"

#NTP
#123
NTP_port="123"
all_other_NTP_port="1-122 124-65535"

#SSH_SFTP (Port)
#22
SSH_port="22"
all_other_SSH_port="1-21 23-65535"

#Telnet (Port)
#23
TELNET_port="23"
all_other_TELNET_port="1-22 24-65535"

#Telnet_SSH_SFTP
#22 23
TELNET_SSH_port="22 23"
all_other_TELNET_SSH_port="1-21 24-65535"

#OPENWRT GUI ACCESS_PORT
ACCESS_HTTP_port="8080"
ACCESS_HTTPS_port="8443"

#TOR Onion Services
TOR_SOCKS_port="9050"
TOR_SOCKS2_port="9150"
TOR_TRANS_port="9040"
TOR_DIR_port="9030"
TOR_OR_port="9049"
TOR_THTTP_port="9060"

#Amazon_Alexa
Amazon_Alexa_port="67-68 8080 40317 49317 33434 123 54838 55443 46053 1000-10000 50000-65000 16000-26000"
all_other_Amazon_Alexa_port='1-24 26-52 54-66 69-79 81-99 101-122 124-442 444-852 854-999 1001-15999 26001-33433 33435-34083 34084-40316 40318-41906 41909-46052 46054-46077 46079-49316 49318-49999 65001-65535'
Amazon_Alexa_UDP_port="4070 5353 40317 49317 33434 50000-60000 3478-3481"
all_other_Amazon_Alexa_UDP_port="1-52 54-66 69-122 124-852 854-1899 1901-3477 3482-4069 4071 4073-4171 4173-5352 5354-5452 5454-33433 33435-40316 40318-49316 49318-49999"

#Office_Client (Port)
# 21 22 25 53 67 80 110 123 139 138 137 443 445 515 548 631 853 2049 5353 9030 9040 9049 9050 9053 9060 9100 50275 54715 54789 51465 56343 56534 57687 60870
OfficeClient_port="21 22 25 53 67 80 110 123 139 138 137 443 445 515 548 631 853 2049 5353 9030 9040 9049 9050 9053 9060 9100 50275 54715 54789 51465 56343 56534 57687 60870"
all_other_OfficeClient_port='1-20 24 26-52 54-66 68-79 81-109 111-122 124-136 140-442 444 446-514 516-547 549-630 632-852 854-2048 2050-5352 5354-8442 8444-9029 9031-9039 9041-9048 9051 9052 9054-9059 9061-9099 9101-40442 40446-50274 50276-51464 51465-54714 54716-54788 54790-56342 56344-56533 56535-57686 57688-60869 60871-65535'

OfficeWebClient_port="21 22 25 53 80 110 123 443 853 5353 9030 9040 9049 9050 9053 9060 50275 54715 54789 51465 56343 56534 57687 60870"
all_other_OfficeWebClient_port='1-20 23 24 26-52 54-79 81-109 111-122 124-442 444-852 854-5299 5301-5352 5354-5452 5454-8079 8081-8442 8444-9029 9031-9039 9041-9049 9051 9052 9054-9059 9061-40274 40276-40442 40446-51464 51466-54714 54716-54788 54790-56342 56344-56533 56535-57686 57688-60869 60871-65535'

#Only_WebClient
all_other_WebClient_port='1-20 23 24 26-52 54-79 81-109 111-122 124-442 444-852 854-5352 5354-5452 5454-8079 8081-8442 8444-9029 9031-9039 9041-9049 9051 9052 9054-9059 9061-40274 40276-40442 40446-51464 51466-54714 54716-54788 54790-56342 56344-56533 56535-57686 57688-60869 60871-65535'
WebClient_port="21 22 25 53 80 110 123 443 853 5353 5453 8080 8443 9030 9040 9049 9050 9053 9060 40275 40443 40444 40445 51465 54715 54789 56343 56534 567687 60870"

#UPNP
UPNP_port="49000"
all_other_UPMP_port="1-48999 49001-65535"

#Block_Incoming
all_proto="esp gre icmp igmp tcp udp"

#Block all other Protocols
all_other_porto="esp gre igmp"

#Block_EXT_HEIGHT_PORT_UDP
all_other_EXT_HEIGHT_PORT_UDP_port="9061-33433 33435-40316 40318-49316 49318-65535"
EXT_HEIGHT_PORT_UDP_port="33434 40317 49317"

#Block_EXT_HEIGHT_PORT
all_other_EXT_HEIGHT_PORT_port="10000-33433 33435-40316 40318-49316 49318-54837 54839-65535"
EXT_HEIGHT_PORT_port="33434 40317 49317 54838"

#-------------------------------------------------------------------------
iptab_DHCP_port="67"
iptab_all_other_DHCP_port="1:66 68:65535"


#Printer_LPR_IPP
iptab_Printer_port="515 631 9100"
iptab_all_other_Printer_port="1:514 516:630 632:9099 9101:65535"

#NTP
iptab_NTP_port="123"
iptab_all_other_NTP_port="1:122 124:65535"

#NFS
iptab_NFS_port="2049"
iptab_all_other_NFS_port="1:2048 2050:65535"

#AFP
iptab_AFP_port="548"
iptab_all_other_AFP_port="1:547 549:65535"

#SMB
iptab_SMB_port="137 138 139 445"
iptab_all_other_SMB_port="1:444 446:136 140:65535"

#VPN
iptab_VPN_port="500 4500"
iptab_all_other_VPN_port="1:499 501:4499 4501:65535"

#Open Directory Proxy (ODProxy)
iptab_ODProxy_port="625"
iptab_all_other_ODProxy_port="1:624 266:65535"

#Syslog
#UDP
#514
iptab_Syslog_port="514"
iptab_all_other_Syslog_port="1:513 515:65535"

#NetBIOS
#UDP
#138
iptab_NetBIOS_port="138"
iptab_all_other_NetBIOS_port="1:137 139:65535"

#WINS
#137
iptab_WINS_port="137"
iptab_all_other_WINS_port="1:136 138:65535"

#Simple Service Discovery Protocol (SSDP)
#UDP
#1900
iptab_SSDP_port="1900"
iptab_all_other_SSDP_port="1:1899 1901:65535"

#Web Services Dynamic Discovery (WS:Discovery)
#UDP
#3702
iptab_WS_Discovery_port="5357 3702"
iptab_all_other_WS_Discovery_port="1:5356 5358:3701 3703:65535"

#Port Control Protocol (PCP)
#5351
iptab_PCP_port="5351"
iptab_all_other_PCP_port="1:5350 3552:65535"

#Port NETWORK Controler
#8043
iptab_CONTROLER_port="8043"
iptab_all_other_CONTROLER_port="1:8042 8044:65535"

#Multicast Domain Name Service (mDNS)
#5353
iptab_mDNS_port="5353"
iptab_all_other_mDNS_port="1:5352 5354:65535"

#Link Local Multicast Name Resolution (LLMNR)
#5357
iptab_LLMNR_port="5357"
iptab_all_other_LLMNR_port="1:5356 5358:65535"

#Telefonie (SIP)
#5060
iptab_SIP_port="5060"
iptab_all_other_SIP_port="1:5059 5061:65535"

#Telefonie (RTP, RTCP)
#7077:7097
iptab_RTP_RTCP_port="7077:7097"
iptab_all_other_RTP_RTCP_port="1:7076 7098:65535"

#Telefonie (SIP, RTP, RTCP)
#7077:7097
iptab_SIP_RTP_RTCP_port="5060 7077:7097"
iptab_all_other_SIP_RTP_RTCP_port="1:5059 5061:7076 7098:65535"

#FRITZ!Box
iptab_AVM_port="8181:8186"
iptab_all_other_AVM_port="1:8180 8187:65535"

#FRITZ!Box MESH
iptab_AVM_Mesh_port="50842 53805"
iptab_all_other_AVM_Mesh_port="1:50841 50843:53804 53806:65535"

#Torrc Ports
iptab_TORRC_port="9030 9040 9049 9050 9053 9060"
iptab_all_other_TORRC_port="1:9029 9031:9039 9041:9048 9051 9052 9054:9059 9061:65535"



#SPYPE
iptab_Skype_port="1000:10000 16000:26000 38562 50000:65000"
iptab_all_other_Skype_port="1:999 10001:15999 26001:38561 38563:49999 65001:65535"
iptab_Skype_udp_port="38562 3478:3481 50000:60000"
iptab_all_other_Skype_udp_port="1:3477 3482:38561 38563:49999 60000:65535"

#MSRDP_Alexa Call (Ports)
#3389
iptab_MSRDP_AlexaCall_port="3389"
iptab_all_other_MSRDP_AlexaCall_port="1:3388 3390:65535"

#HTTP_s (Ports)
#80, 443, 8080
iptab_HTTP_s_port="80 443 8080"
iptab_HTTPs_port="443"
iptab_HTTP_port="80"
iptab_all_other_HTTP_s_port="1:79 81:442 444:8079 8081:65535"

#FTP_Server
iptab_FTP_port="20 21"
iptab_all_other_FTP_port="1:19 22:65535"

#Remote_Acces_http(s)
#40443:40446
iptab_Acces_http_port="40443:40446"
iptab_all_other_Acces_http_port="1:40442 40447:65535"

#eMule (Ports)
#4662, 4672
iptab_eMule_port="4662 4672"
iptab_all_other_eMule_port="1:4661 4663:4671 4673:65535"

#Bittorrent (Ports)
#6881:6999
iptab_Bittorrent_port="6881:6999"
iptab_all_other_Bittorrent_port="1:6880 7000:65535"

#Tor_dns
iptab_DNS_TOR_port="9053"
iptab_all_other_DNS_TOR_port="1:9052 9054:65535"

#DNS Crypt
iptab_DNS_CRYPT_port="5300"
iptab_all_other_DNS_CRYPT_port="1:5299 5301:65535"

#DNS Stubby
iptab_DNS_STUBBY_port="5453"
iptab_all_other_DNS_STUBBY_port="1:5452"5454:65535

#DNS_UNBOUND
iptab_DNS_UNBOUND_port="5353"
iptab_all_other_DNS_UNBOUND_port="1:5352 5354:65535"

#SDNS
iptab_SDNS_port="853"
iptab_all_other_SDNS_port="1:852 854:65535"

#allDNS Ports
iptab_all_DNS_port="53 853 5300 5353 5453 9053 33216 34885 35113 35141 37572 38700 39354 41227 41287 41675 43609 47535 48427 48736 48777 50275 54715 54789 51465 56343 56534 57687 60870"
iptab_all_other_all_DNS_port="1:52 54:852 854:5299 5301:5352 5354:5452 5454:9052 9054:33215 33217: 34884 34886:35112 35114:35140 35142:37571 37573:38699 38701:39353 39355:41226 41227:41286 41288:41674 41676:43608 43610:47534 47536:48426 48428:48735 48737:48776 48778:50274 50276:54714 54716:54788 54790:51464 51466:56342 56344:56533 56535:57686 57688:60869 60871:65535"

#NTOPNG Port
#NTOPNG_PORT="3000"
iptab_NTOPNG_port="3000"
iptab_all_other_NTOPNG_port="1:2999 3001:65535"

#Privoxy Port
#PRIVOXY_PORT="8188"
iptab_PRIVOXY_port="8188"
iptab_all_other_PRIVOXY_port="1:8187 8189:65535"

#PiHole Port
#PIHOLE_PORT="81"
#PIHOLE_FTL_PORT="4711"
#PiHole Port
iptab_PIHOLE_port="81"
iptab_PIHOLE_FTL_port="4711"
iptab_all_PIHOLE_port="81 4711"
iptab_all_other_PIHOLE_port="1:80 82:65535"
iptab_all_other_PIHOLE_FTL_port="1:4710 4712:65535"
iptab_all_othjer_all_PIHOLE_port="1:80 82:4710 4712:65535"

#Real Time Streaming Protocol (RTSP)
#"554"
iptab_RTSP_port="554"
iptab_all_other_RTSP_port="1:553 555:65535"

#NNTP
#"119"
iptab_NNTP_port="119"
iptab_all_other_NNTP_port="1:118 120:65535"

#RPC
iptab_RPC_port="111"
iptab_all_other_RPC_port="1:110 112:65535"

#LDAP
#"389 636"
iptab_LDAP_port="389 636"
iptab_all_other_LDAP_port="1:388 390:635 637:65535"

#Password_Server
#"106"
iptab_PASSWDSRV_port="106"
iptab_all_other_PASSWDSRV_port="1:105 107:65535"

#KERBEROS
#"88 749"
iptab_KERBEROS_port="88 749"
iptab_all_other_KERBEROS_port="1:87 89:748 750:65535"

#IMAP4 Port
#IMAP_PORT="143 993 626"
iptab_IMAP_port="143 993 626"
iptab_all_other_IMAP_port="1:142 144:992 994:625 627:65535"

#POP3 Port
#POP3_PORT="110 995"
iptab_POP3_port="110 995"
iptab_all_other_POP3_port="1:109 111:994 996:65535"

#smtp
#"25 465 587"
iptab_SMTP_port="25 465 587"
iptab_all_other_SMTP_port="1:24 26:464 466:586 588:65535"

#all Email
iptab_email_port="25 110 143 465 587 626 993 995"
iptab_all_other_email_port="1:24 26:109 111:142 144:464 466:586 588:625 627:992 994 996:65535"

#NTP
#123
iptab_NTP_port="123"
iptab_all_other_NTP_port="1:122 124:65535"

#SSH_SFTP (Port)
#22
iptab_SSH_port="22"
iptab_all_other_SSH_port="1:21 23:65535"

#Telnet (Port)
#23
iptab_TELNET_port="23"
iptab_all_other_TELNET_port="1:22 24:65535"

#Telnet_SSH_SFTP
#22 23
iptab_TELNET_SSH_port="22 23"
iptab_all_other_TELNET_SSH_port="1:21 24:65535"

#OPENWRT GUI ACCESS_PORT
iptab_ACCESS_HTTP_port="8080"
iptab_ACCESS_HTTPS_port="8443"

#TOR Onion Services
iptab_TOR_SOCKS_port="9050"
iptab_TOR_SOCKS2_port="9150"
iptab_TOR_TRANS_port="9040"
iptab_TOR_DIR_port="9030"
iptab_TOR_OR_port="9049"
iptab_TOR_THTTP_port="9060"


#Amazon_Alexa
iptab_Amazon_Alexa_port="67:68 8080 40317 49317 33434 123 54838 55443 46053 1000:10000 50000:65000 16000:26000"
iptab_all_other_Amazon_Alexa_port='1:24 26:52 54:66 69:79 81:99 101:122 124:442 444:852 854:999 1001:15999 26001:33433 33435:34083 34084:40316 40318:41906 41909:46052 46054:46077 46079:49316 49318:49999 65001:65535'
iptab_Amazon_Alexa_UDP_port="4070 5353 40317 49317 33434 50000:60000 3478:3481"
iptab_all_other_Amazon_Alexa_UDP_port="1:52 54:66 69:122 124:852 854:1899 1901:3477 3482:4069 4071 4073:4171 4173:5352 5354:5452 5454:33433 33435:40316 40318:49316 49318:49999"

#Office_Client (Port)
# 21 22 25 53 67 80 110 123 139 138 137 443 445 515 548 631 853 2049 5353 9030 9040 9049 9050 9053 9060 9100 50275 54715 54789 51465 56343 56534 57687 60870
iptab_OfficeClient_port="21 22 25 53 67 80 110 123 139 138 137 443 445 515 548 631 853 2049 5353 9030 9040 9049 9050 9053 9060 9100 50275 54715 54789 51465 56343 56534 57687 60870"
iptab_all_other_OfficeClient_port='1:20 24 26:52 54:66 68:79 81:109 111:122 124:136 140:442 444 446:514 516:547 549:630 632:852 854:2048 2050:5352 5354:8442 8444:9029 9031:9039 9041:9048 9051 9052 9054:9059 9061:9099 9101:40442 40446:50274 50276:51464 51465:54714 54716:54788 54790:56342 56344:56533 56535:57686 57688:60869 60871:65535'

iptab_OfficeWebClient_port="21 22 25 53 80 110 123 443 853 5353 9030 9040 9049 9050 9053 9060 50275 54715 54789 51465 56343 56534 57687 60870"
iptab_all_other_OfficeWebClient_port='1:20 23 24 26:52 54:79 81:109 111:122 124:442 444:852 854:5299 5301:5352 5354:5452 5454:8079 8081:8442 8444:9029 9031:9039 9041:9049 9051 9052 9054:9059 9061:40274 40276:40442 40446:51464 51466:54714 54716:54788 54790:56342 56344:56533 56535:57686 57688:60869 60871:65535'

#Only_WebClient
iptab_all_other_WebClient_port='1:20 23 24 26:52 54:79 81:109 111:122 124:442 444:852 854:5352 5354:5452 5454:8079 8081:8442 8444:9029 9031:9039 9041:9049 9051 9052 9054:9059 9061:40274 40276:40442 40446:51464 51466:54714 54716:54788 54790:56342 56344:56533 56535:57686 57688:60869 60871:65535'
iptab_WebClient_port="21 22 25 53 80 110 123 443 853 5353 5453 8080 8443 9030 9040 9049 9050 9053 9060 40275 40443 40444 40445 51465 54715 54789 56343 56534 567687 60870"

#UPNP
iptab_UPNP_port="49000"
iptab_all_other_UPMP_port="1:48999 49001:65535"

#Block_EXT_HEIGHT_PORT_UDP
iptab_all_other_EXT_HEIGHT_PORT_UDP_port="9061:33433 33435:40316 40318:49316 49318:65535"
iptab_EXT_HEIGHT_PORT_UDP_port="33434 40317 49317"

#Block_EXT_HEIGHT_PORT
iptab_all_other_EXT_HEIGHT_PORT_port="10000:33433 33435:40316 40318:49316 49318:54837 54839:65535"
iptab_EXT_HEIGHT_PORT_port="33434 40317 49317 54838"


#Block public DNS Server
DNS_EXT_BLOCK1_SVR="8.8.8.8" 
DNS_EXT_BLOCK2_SVR="8.8.4.4"
DNS_EXT_BLOCK3_SVR="9.9.9.9" 
DNS_EXT_BLOCK4_SVR="149.112.112.112" 
DNS_EXT_BLOCK5_SVR="9.9.9.10" 
DNS_EXT_BLOCK6_SVR="9.9.9.11" 
DNS_EXT_BLOCK7_SVR="9.9.9.12" 
DNS_EXT_BLOCK8_SVR="149.112.112.10" 
DNS_EXT_BLOCK9_SVR="149.112.112.11" 
DNS_EXT_BLOCK10_SVR="208.67.222.222" 
DNS_EXT_BLOCK11_SVR="208.67.220.220" 
DNS_EXT_BLOCK12_SVR="2001:4860:4860::8888" 
DNS_EXT_BLOCK13_SVR="2001:4860:4860::8844" 
DNS_EXT_BLOCK14_SVR="2620:fe::fe" 
DNS_EXT_BLOCK15_SVR="2620:fe::9" 
DNS_EXT_BLOCK16_SVR="2620:fe::11" 
DNS_EXT_BLOCK17_SVR="2620:fe::fe:11"
DNS_EXT_BLOCK18_SVR="2620:fe::10" 
DNS_EXT_BLOCK19_SVR="2620:fe::fe:10"

#Cloudflare_DNS_Server
DNS_Cloudflare1_SVR="1.1.1.1" 
DNS_Cloudflare2_SVR="1.1.1.2"
DNS_Cloudflare3_SVR="1.1.1.3"
DNS_Cloudflare4_SVR="1.0.0.1" 
DNS_Cloudflare5_SVR="1.0.0.2"
DNS_Cloudflare6_SVR="1.0.0.3"  
DNS_Cloudflare7_SVR="2606:4700:4700::1111" 
DNS_Cloudflare8_SVR="2606:4700:4700::1112" 
DNS_Cloudflare9_SVR="2606:4700:4700::1113"
DNS_Cloudflare10_SVR="2606:4700:4700::1001" 
DNS_Cloudflare11_SVR="2606:4700:4700::1002" 
DNS_Cloudflare12_SVR="2606:4700:4700::1003"  
DNS_Cloudflare13_SVR=$SERVER_ip
DNS_Cloudflare14_SVR=$CONTROL_ip
DNS_Cloudflare15_SVR=$HCONTROL_ip
DNS_Cloudflare16_SVR=$INET_ip
DNS_Cloudflare17_SVR=$VOICE_ip
DNS_Cloudflare18_SVR=$ENTERTAIN_ip
DNS_Cloudflare19_SVR=$GUEST_ip
DNS_Cloudflare20_SVR="127.0.0.1" 
DNS_Cloudflare21_SVR="127.0.10.1" 
DNS_Cloudflare22_SVR="0::1"
DNS_Cloudflare23_SVR="dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion"  

#Cloudflare Onion TOR
CLOUDFLARE="dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion"

#Tor Netzwerk
TOR_ROUTING="10.192.0.0/10"

# destinations you don't want routed through Tor
NON_TOR="$WAN_net $INET_net $SERVER_net $CONTROL_net $HCONTROL_net $VOICE_net $ENTERTAIN_net $GUEST_net" 
# s3-1-w.amazonaws.com 52.192.0.0/11 .ix.nflxvideo.net joyn.de joyn.net hvb.de hypovereinsbank.de"

# TV and VoD
JOYN_SVR=""
ZATTOO_SVR=""
WAYPU_SVR=""
PRIME_SVR=""
NETFLIX_SRV="54.204.25.0/28 23.23.189.144/28 34.195.253.0/25 35.163.200.168/28"
VIDEO_SRV="52.192.0.0/11 99.86.3.59/24 18.236.7.30/11 217.148.99.11/28 46.137.171.215/11 34.241.244.104/24 207.45.72.215/11 "$NETFLIX_SRV

echo
echo "variables defineds"
echo
clear
echo '########################################################'
echo '#                                                      #'
echo '#                 CyberSecurity-Box                    #'
echo '#                                                      #'
echo '# local Privacy for Voice-Assistent Smart-TV SmartHome #'
echo '#                                                      #'
echo '########################################################'
echo
#----------------------------------------------------------------------------

uci set system.@system[0]=system
uci set system.@system[0].ttylogin='0'
uci set system.@system[0].log_size='64'
uci set system.@system[0].urandom_seed='0'
uci set system.@system[0].log_proto='udp'
uci set system.@system[0].conloglevel='1'
uci set system.@system[0].cronloglevel='9'
uci set system.@system[0].timezone='CET-1CEST,M3.5.0,M10.5.0/3'
uci set system.@system[0].zonename='Europe/Berlin'
uci set system.@system[0].hostname='CyberSecurity-Box'
uci set system.@system[0].description='CyberSecurity-Box with Tor-Onion-Services'
uci delete system.ntp.server
uci add_list system.ntp.server=$INET_GW 
uci add_list system.ntp.server='0.openwrt.pool.ntp.org'
uci add_list system.ntp.server='1.pool.ntp.org'
uci add_list system.ntp.server='2.openwrt.pool.ntp.org'
uci add_list system.ntp.server='3.pool.ntp.org'
uci set uhttpd.defaults.country='DE'
uci set uhttpd.defaults.state=''
uci set uhttpd.defaults.location='DMZ'
uci set uhttpd.defaults.commonname=$LAN
uci -q delete uhttpd.main.listen_http
uci add_list uhttpd.main.listen_http="0.0.0.0:8080"
uci add_list uhttpd.main.listen_http="[::]:8080"
uci -q delete uhttpd.main.listen_https
uci add_list uhttpd.main.listen_https="0.0.0.0:8443"
uci add_list uhttpd.main.listen_https="[::]:8443"
uci commit  && reload_config  >/dev/null
/etc/init.d/uhttpd restart  >/dev/null

echo
echo 'Default Country-Settings'
echo 


echo
echo 'https activated'
echo


cat << EOF > /etc/banner

  +++         +                  +++               +++++
 +   +        +                 +   +              +    +
+             +                 +                  +    + 
+             +                 +                  +    +
+      +   +  +++    ++   +  ++  +++    ++    ++   +++++    ++   +   +
+       + +   +  +  +  +  + +       +  +  +  +  +  +    +  +  +   + +
+        +    +  +  +++   ++        +  +++   +     +    +  +  +    +
 +   +   +    +  +  +     +     +   +  +     +  +  +    +  +  +   + +
  +++    +    +++    +++  +      +++    +++   ++   +++++    ++   +   +
 
      local Privacy for Voice-Assistents, Smart-TVs and SmartHome 
	   
--------------------------------------------------------------------------
   powered by OpenWrt $(echo $release), $(echo $revision)
--------------------------------------------------------------------------


EOF

cat << EOF > /etc/openwrt_release
DISTRIB_ID='OpenWrt'
DISTRIB_RELEASE='$(echo $release)'
DISTRIB_REVISION='$(echo $revision)'
DISTRIB_TARGET='ipq40xx/generic'
DISTRIB_ARCH='arm_cortex-a7_neon-vfpv4'
DISTRIB_DESCRIPTION='CyberSecurity-Box $(echo $revision)'
DISTRIB_TAINTS=''
EOF


cat << EOF > /etc/device_info
DEVICE_MANUFACTURER='@CyberAndi'
DEVICE_MANUFACTURER_URL='https://cyberandi.tumblr.com/'
DEVICE_PRODUCT='CyberSecurity-Box'
DEVICE_REVISION='v0.5'

EOF

#Datum erstellen
#actdate(date --utc --date "$1" +%F)
datum=$(date +"%y%d%m%H%M")
echo

uci set luci.main.mediaurlbase='/luci-static/bootstrap-dark'
uci set luci.themes.BootstrapDark='/luci-static/bootstrap-dark'
uci commit && reload_config

#save old firewall rules
echo save old firewallrules
echo
iptables-save > rules.v4_old_$datum.bkp

mkdir /www/router
mkdir /www/redirect
mkdir /www/CaptivePortal
mkdir /www/generate_204
mkdir /www/CaptivePortal/pic
echo

cat << EOF > /www/index.html

<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">
	<html xmlns="http://www.w3.org/1999/xhtml">
		<head>
			<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate" />
			<meta http-equiv="refresh" content="0; URL=CaptivePortal/index.htm" />
		</head>
		<body style="background-color: black">
			<a style="color: #008800; font-family: arial, helvetica, sans-serif" href="cgi-bin/luci/" >
				LuCI - Lua Configuration Interface
			</a>
		</body>
	</html>

EOF

echo
echo writes Redirect
echo
cat << EOF > /www/CaptivePortal/theme_variable.css

:root {
	--acceptBgColor: linear-gradient(to left bottom, rgba(0,128,0,0.8), rgba(0,128,0,0.1));
	--activeView: -10;
	--adjust: 100%;
	--alertBgColor: var(--lightRed);
	--alertColor: var(--lightRed);
	--alertRed: #cc0000;
	--alertTop: 3em;
	--AnswerBoxBg: var(--lightRed);
	--animiImage: url('pic/Corona_2.svg');
	--animiStartPosX: 0;
	--animiStartPosY: 0;
	--animiStartPosZ: 0;
	--animiStartPerspective: 150px;
	--animiStopPosX: 0;
	--animiStopPosY: 0;
	--animiStopPosZ: 0;
	--animiStopPerspective: 7000px;
	--animiTransformStyle: preserve-3d;
	--appearance: none;
	--aspectRatio: 16/9;
	--aspectRatioLT: 16/6.7467;
	--autoHeight: auto;
	--autoTop: auto;
	--bgBlur: blur(2.5px);
	--bgLight: rgba(238,238,238,0.75);
	--bgGradientDark: linear-gradient(to bottom, rgba(16,96,0,0.8), rgba(16,96,0,0.7), rgba(16,96,0,0));
	--bgGradientDiagDark: linear-gradient(to top right, rgba(16,96,0,0.8), rgba(16,96,0,0.7), rgba(16,96,0,0));
	--bgGradientDiagLight: linear-gradient(to bottom left, rgba(32,128,0,0.8), rgba(32,128,0,0.1));
	--bgGradientDiagLightActive: linear-gradient(to top right, rgba(32,128,0,0.8), rgba(32,128,0,0.1));
	--bgGradientLight: linear-gradient(to right, rgba(32,128,0,0.8), rgba(32,128,0,0.1));
	--bgGradientLightActive: linear-gradient(to top, rgba(32,128,0,0.8), rgba(32,128,0,0.1));
	--bgModal: linear-gradient(to bottom, rgba(0,0,0,1), rgba(0,0,0,0.3), rgba(0,0,0,1) );
	--bgPosFixed: fixed;
	--bgTransparent: transparent;
	--bgRepeate: no-repeat;
	--bibleTextTransition: 0.75s;
	--bibleTextDisplay: block;
	--bibleTextHidden: none;
	--bibleTextImageDisplay: inline-block;
	--bibleImageShadow: 0.1em 0.1em 0.125em rgb(0 0 0 / 50%), 0 0 0.05em rgba(0, 0, 0, 0.25);
	--blackColor: #000000;
	--bookTextColor: #201000;
	--bookBGColor: #ffeed8;
	--blackGradient: radial-gradient(rgba(0,0,0,.3), rgba(0,0,0,1));
	--blackTrans: rgba(0,0,0,0.5);
	--blockBgColor: linear-gradient(to bottom left, rgba(224,224,0,0.8), rgba(224,224,0,0.1));
	--blueGradient: radial-gradient(rgba(47, 121,160,.3), rgba(47, 121,160,1));
	--blueGradient3: radial-gradient(rgba(47, 121,160,1), rgba(47, 121,160,0.15));
	--blueGradientRight: linear-gradient(to right, rgba(17,17,17,.9), var(--colorBlueMid));
	--blueGradientLeft: linear-gradient(to left, var(--colorBlueTrans), var(--colorBlue));
	--blueScrollPic: rgba(94,149,183,.4);
	--bookBGImage: linear-gradient(to right,rgba(135,100,0,1),  rgba(135,100,0,0.1), rgba(135,100,0,0.1), rgba(135,100,0,0.1), rgba(135,100,0,0.1), rgba(135,100,0,1));
	--bookFont: var(--fontBook);
	--borderDark: 1px solid #000000;
	--borderColorDark: rgba(81,81,81,0.6);
	--borderColorDark: var(--buttonBorderColorDark);
	--borderColorLight: var(--borderLight);
	--borderColorMiddle: rgba(128,128,128,0.6);
	--borderColorMiddle: var(--buttonBorderColorMiddle);
	--borderDark: 0.75px solid rgba(81,81,81,0.6);
	--borderLoader: 2px solid rgb(32,128,0);
	--borderLoader2: 7px solid #aaaaaa;
	--borderLoaderRadius: 50%;
	--borderLoaderTop: 7px solid rgb(32,128,0);
	--borderMiddle: 0.75px solid rgba(128,128,128,0.6);
	--borderNone: 1px solid #44cc00;
	--borderRadius: 5px;
	--borderRadiusNone: 0;
	--borderRadiusNormal: 7px;
	--borderRadiusSmall: 3px;
	--borderRadiusTouch: 15px;
	--borderSelect: 1px solid #cccccc;
	--borderTerminal: 2px solid rgba(68,204,0,0.5);
	--boxBg: rgba(128,128,128,0.6);
	--boxBgDrk: rgba(48,48,48,0.85);
	--boxBgDrkGreen: rgba(0,48,0,0.85);
	--boxBgImage: linear-gradient(to bottom left, rgba(128,128,128,0.8), rgba(128,128,128,0.1));
	--boxBgLgtDrk: rgba(81,81,81,0.6);
	--boxBgLight: rgba(204,204,204,0.85);
	--boxBgLightGreen: rgba(0,204,0,0.6);
	--boxBgMidGreen: rgba(68,136,68,0.85);
	--boxBGView: 49;
	--boxHighLightBorder: rgba(0,224,0,0.9)!important; 
	--boxHighLightBorder: rgba(82,236,168,0.9)!important; 
	--boxHighLightShadow: inset 0 1px 3px rgb(0 0 0 / 10%), 0 0 8px rgb(0 224 0 / 60%);
	--boxPadding: 1em 1.5em;
	--boxShadow: 0.25em 0.25em 0.5em var(--blackTrans);
	--boxShadow: 0.2em 0.2em 0.5em rgba(0,0,0,0.7), 0 0 0.05em #000000;
	--boxShadow2: -0.5em 0.95em 0.5em rgba(0, 0, 0, 0.6);
	--boxSizeingNorm: content-box;
	--boxSizeingBorder: border-box;
	--boxView: 50;
	--bsLogoHeight: 51;
	--buttonBorderColorDark: rgba(81,81,81,0.6);
	--buttonBorderColorMiddle: rgba(128,128,128,0.6);
	--buttonBorderDark: 0.75px solid rgba(81,81,81,0.6);
	--buttonBorderMiddle: 0.75px solid rgba(128,128,128,0.6);
	--buttonBorderMiddle: 0.75px solid rgba(128,128,128,0.6);
	--buttonBoxHeight: 2.1vw;
	--buttonColorNorm: rgba(0,0,0,0.35);
	--buttonColorSelect: rgba(224,0,0,0.75);
	--buttonColorDark: var(--fontDark);
	--buttonColorLight: var(--fontLight);
	--buttonColorStd: rgba(000,113,000,0.75);
	--buttonHeight: 16px;
	--buttonFloat: right;
	--buttonHeightTouch: 60px;
	--buttonTop: -.05em;
	--buttonRight: 0em;
	--buttonPadding: 0 0em 0.25em 0.5em;
	--buttonCursor: pointer;
	--canLeft: 60%;
	--canSize: 30em;
	--centerMargin: auto;
	--centerPos: 50%;
	--colorBlueTrans: rgba(47, 121,160,.3);
	--colorBlue: rgba(47, 121,160,1);
	--colorBlueMid: rgba(94,149,183,0.8);
	--colorBlueDrk: rgba(7, 81,120,1);
	--colorBlueLgth: rgba(107, 181,220,1);
	--colorDrkGrey: rgba(17,17,17,0.75);
	--colorDrkGreyTrans: rgba(17,17,17,0.25);
	--colorLgtGrey: #eeeeee;
	--configHeight: var(--menuHeight);
	--configLableMax: var(--popupMaxWidth);
	--configLableMin: var(--popupMinWidth);
	--configMax: 40em;
	--configMin: 6em;
	--cursorHand: pointer;
	--cursorWait: wait;
	--containerBibleTextWidth: 80vw;
	--default: 0em;
	--defaultValue: unset;
	--devColor: #ff0000;
	--devColorTrans: rgba(255,0,0,0.25);
	--devColor1: #880000;
	--devColor1Trans: rgba(128,0,0,0.25);
	--devColor2: #008800;
	--devColor2Trans: rgba(0,128,0,0.25);
	--devColor3: #00ff00;
	--devColor3Trans: rgba(0,255,0,0.25);
	--devColor4: #000088;
	--devColor4Trans: rgba(0,0,128,0.25);
	--devColor5: #0000ff;
	--devColor5Trans: rgba(0,0,255,0.25);
	--devColor6: #888800;
	--devColor6Trans: rgba(128,128,0,0.25);
	--devColor7: #ffff00;
	--devColor7Trans: rgba(255,255,0,0.25);
	--devColorBG: #AA00AA;
	--devColorBGTrans: rgba(172,0,172,0.25);
	--devColorOverL: #AAAAAA;
	--devColorOverLTrans: rgba(172,172,172,0.25);
	--displayNone: none;
	--displayBlock: block;
	--displayInlineBlock: inline-block;
	--drk-bg: #000000;
	--drkGreen: #004400;
	--blueGradient: radial-gradient(rgba(47, 121,160,.3), rgba(47, 121,160,1));
	--blueGradient2: radial-gradient(rgba(94,149,183,.3), rgba(94,149,183,1));
	--blueTransparent: rgba(47, 121,160, 0.75);
	--dropBgColor: linear-gradient(to bottom left, rgba(224,0,0,0.8), rgba(224,0,0,0.1));
	--dropShadow: var(--boxShadow);
	--factorHDVideo: 56.25;
	--factorHDVideoVW: var(--factorHDVideo) + 'vw';
	--factorLetterBoxSmallVideo: 37.5;
	--factorLetterBoxSmallVideoVW: var(--factorLetterBoxSmallVideo) + 'vw';
	--factorLetterBoxVideo: 48.92;
	--factorLetterBoxVideoVW: var(--factorLetterBoxVideo) + 'vw';
	--fillHeadHeight: var(--lineBoxHeadHeight);
	--flowLeft: left;
	--flowRight: right;
	--focusShadow: 0 0 0.15em var(--colorBlueMid);
	--footerHeight: calc(var(--fontSizeEm) * 2);
	--fontActiveShadow: var(--fontShadow);
	--fontBigShadow: -0.25em 0.425em 0.25em rgba(0, 0, 0, 0.6);
	--fontBold: bold;
	--fontDark: #222222;
	--fontLight: #cccccc;
	--fontNormal: normal;
	--fontSelectShadow: -0.125em 0.2125em 0.125em rgba(224, 224, 224, 0.6);
	--fontShadow: 0.2em 0.2em 0.5em rgb(0 0 0 / 75%), 0 0 0.2em #000000;
	--fontSize: 1.2831vw;
	--fontSizeEm: 16px;
	--fontSizeButton: var(--fontSizeSmall);
	--fontSizeHead: var(--fontSizeNorm);
	--fontSizeHead1: 2.370816vw;
	--fontSizeHead2: 1.97568vw;
	--fontSizeHead3: 1.6464vw;
	--fontSizeHelp: var(--fontSizeXXSmall);
	--fontSizeIfBox: var(--fontSizeXSmall);
	--fontSizeIfBoxHead: var(--fontSizeSmall);
	--fontSizeLabel: 1.15248vw; 
	--fontSizeLabel: var(--fontSizeXSmall);
	--fontSizeMenu: var(--fontSizeSmall);
	--fontSizeMobile: 1.6vw;
	--fontSizeNorm: 1.4vw;
	--fontSizeSmall: 1.1662vw;
	--fontSizeTable: var(--fontSizeXSmall);
	--fontSizeXSmall: 1.029vw;
	--fontSizeXXSmall: 0.8232vw;
	--fontWeight: 650;
	--fontTerminal: var(--mainColor);
	--fontXDrk: var(--drk-bg);
	--fontXLight: var(--lightColor);
	--fontBook: "Times New Roman", Times, serif;
	--footerHeight: 1.5em;
	--footerBGColor: linear-gradient(to left,rgba(17,17,17,.9), var(--colorBlueMid));
	--forwardBgColor: linear-gradient(to left bottom, rgba(0,255,0,0.8), rgba(0,255,0,0.1));
	--fwStateDynWidth: 260px;
	--gray: #444444;
	--halfTransparent: 0.8;
	--headerBgColor: rgba(0,0,0,0.8);
	--headerBGImage: url("pic/CMovie.svg"), var(--blueGradientRight);
	--headerBGImageSmall: var(--blueGradientRight);
	--headerBGSize: 10%, auto;
	--headerBGSizeSmall: auto;
	--headerBGPosX: 7%, 0px;
	--headerBGPosXBig: 10%, 0px;
	--headerBGPosY: 55%, 0px;
	--headerBGPosXSmall: 0px;
	--headerBGPosYSmall: 0px;
	--headerBoxHeight: var(--lineBoxHeadHeight);
	--headerBoxItem: var(--lineBoxHeadHeight);
	--headerH1: "Willkommen bei C&grave;Movie dem Hoffnungsportal";
	--headerH1Small: "C&grave;Movie das Hoffnungsportal";
	--headerH3: "Der Gegenpol zu Chaos und Panik seitens der Medien und Politik";
	--headerH3Small: "Der Gegenpol zu Chaos und Panik";
	--headerHeight: var(--lineHeadHeight);
	--headerHeight: calc(var(--fontSizeEm) * 9.5);
	--headerHeightLarge: calc(var(--fontSizeEm) * 9.5);
	--headerHeightSmall: calc(var(--fontSizeEm) * 4.5);
	--headerItem: var(--lineHeadHeight);
	--headerAlign: center;
	--headerTop: -1em;
	--headerTopH3: -0.4em;
	--headerLineHeight: 1.2;
	--headFont: var(--mainFont);
	--heightTerm: 31em;
	--hidden: none;
	--hoverView: 10;
	--hyphens: auto;
	--inlineVisible: inline-block;
	--inpBoxWidth: 210px;
	--inpFill-bg: var(--lightGray);
	--inpFocus-bg: #ffffcc;
	--inpHeight: var(--mainTextHeight);
	--inpMarginTop: 0.75em;
	--inpPadding: 0.25em 0.5em;
	--inpTxt: #0000aa;
	--inputShadow: inset 1px 1px 3px rgba(0,0,0,0.4);
	--infoBG: var(--bgLight);
	--infoPosLeft: calc(50% - 225px);
	--infoPosTop: 5em;
	--infoMargin: auto;
	--infoWidth: 90vw;
	--infoMaxWidth: 450px;
	--infoMaxHeight: 80vh;
	--infoTextShadow: var(--textNoShadow);
	--infoPadding: 0.25em 0.5em;
	--infoFont: Arial, sans-serif;
	--infoTextWidth: auto;
	--infoImageHeight: 1em;
	--infoFontButtonHeight: 1em;
	--inpWidth: 92%;
	--lastScrollY: 0;
	--lastScrollX: 0;
	--layer2View: 20;
	--layer3View: 30;
	--leftTerm: 16em;
	--light-bg: #cccccc;
	--lightColor: #ffffff;
	--lightGray: #aaaaaa;
	--lightgreen: rgb(32,128,0);
	--lightRed: rgba(196,0,0,0.6);
	--lightRed: rgba(224,0,0,0.75);
	--lineBoxHeadHeight: 3.92vw;
	--lineBoxHeight: 2.1vw;
	--lineBoxInputHeight: var(--buttonBoxHeight);
	--lineHeadHeight: 2.8em;
	--lineHeight: 1.5em;
	--lineInputHeight: var(--buttonHeight);
	--loaderAnimation: spin 2s linear infinite;
	--loaderPadding: 30px;
	--loaderSize: 1.5em;
	--loaderStartAnimation: rotate(0deg);
	--loaderStopAnimation: rotate(360deg);
	--logoWidth: 16.3vw;
	--logoHeight: 8.645833vw;
	--logoPosTop: calc(100vh - var(--logoHeight) - 16px) !important;
	--logoPosPortraiTop: calc(var(--factorHDVideoVW) - var(--logoHeight) - 16px) !important;
	--logoPosLeft: 0em;
	--logoBackShadow: unset;
	--logoShadow: var(--boxShadow);
	--logoPic: url("pic/Title.png");
	--logoSize: cover;
	--logoRepeate: no-repeat;
	--main-bg-color: var(--xDrkGreen);
	--mainBoxTextHeight: 1.68vw;
	--mainColor: #44cc00;
	--mainFont: "OCR A","OCR A Std", "OCR-A","OCR-A Std",Monaco,Andale Mono,Courier New,Courier,monospace;
	--mainHeight: 1em;
	--mainMargin: 0;
	--mainOverflow: hidden;
	--mainPadding: 0;
	--mainPadding: 1em;
	--mainTextHeight: 1.2em;
	--mainVisible: inline;
	--mainZoom: 100%;
	--maxHeight:100%;
	--maxWidth: var(--widthMax);
	--maxTerm: 70%;
	--menuActiveBg: var(--bgGradientLightActive);
	--menuActiveBorder: 1px solid rgba(0, 0, 0,0.8);
	--menuBg: var(--bgGradientLight);
	--menuBorder: 1px solid rgba(0,0,0,0.8);
	--menuBottom: -1.4em;
	--menuBoxHeight: var(--buttonBoxHeight);
	--menuBoxMaxWidth: 13.3vw;
	--menuBoxMinWidth: 11.2vw;
	--menuBtn: 43;
	--menuHeight: var(--mainTextHeight);
	--menuHoverBg: var(--bgGradientLight);
	--menuHoverBorder: 1px solid rgba(196,196,196,0.8);
	--menuMargin: 0 0.5em;
	--menuMaxWidth: 9.5em;
	--menuMinWidth: 8em;
	--menuPadding: 0 0.5em;
	--menuPadding2: 0.5em 1em;
	--menuShadow: 0 0 0.15em rgb(224 224 224 / 50%), 0.25em 0.25em 0.35em rgb(0 0 0 / 50%);
	--menuTop: 3.5em;
	--menuTopTop: 0.25em;
	--menuTopLow: 6.1em;
	--menuTopWidth: max-content;
	--menuView: 40;
	--midGray: #888888;
	--minTerm: 20%;
	--modalView: 100;
	--msgBoxMax: 80%;
	--msgBoxMin: 15%;
	--msgPadding: 1em;
	--noBorder: none;
	--noneBorder: none;
	--noShadow: none;
	--noTransparent: 1;
	--noMarginPadding: 0;
	--opacity: 0.8;
	--overflowAuto: auto;
	--overflowHidden: hidden;
	--overflowNone: none;
	--overflowCut: clip;
	--overflowOverlay: overlay;
	--overflowScroll: scroll;
	--overflowScrollTouch: touch;
	--overflowVisible: visible;
	--overlayDiverence: 0;
	--overlayHeight: 0;
	--overlayCalcHeight: 0;
	--overlayCalcLayerHeight: 0;
	--overlayTop: 0;
	--overlayLayerTop: 0;
	--overlayHeadTop: 0;
	--overlayScreenTop: 0;
	--overlayScreenBottom: 0;
	--overlayBottom: 0;
	--overlayHeadBottom: 0;
	--overlayPos: 0;
	--overlayPosTop: 0;
	--overlayPosHalfTop: 0;
	--overlayPosOverlayTop: 0;
	--overlayPosScreenTop: 0;
	--overlayPosBottom: 0;
	--overlayPosHeadBottom: 0;
	--overlayPosScreenBottom: 0;
	--overlayPosHeadScreenBottom: 0;
	--overlayPosOverlayBottom: 0;
	--overlayPosHeadOverlayBottom: 0;
	--overlayPosHeadTop: 0;
	--overlayPosHeadHalfTop: 0;
	--overlayPosHeadOverlayTop: 0;
	--overlayPosHeadScreenTop: 0;
	--overlayPositionScreenTop: 0;
	--overlayPositionTop: 0;
	--overlayPositionBottom: 0;
	--overlayPositionScreenBottom: 0;
	--overlayTransition: var(--transitionLong);
	--overlayHeightPC: 684;
	--overlay1HeightPC: calc(100vh - 1em);
	--overlay2HeightPC: calc(100vh - 1em);
	--overlay3HeightPC: calc(100vh - 1em);
	--overlay4HeightPC: calc(100vh - 1em);
	--overlay1TopPC: 40px;
	--overlay2TopPC: 804px;
	--overlay3TopPC: 1568px;
	--overlay4TopPC: 2440px;
	--overlayHeightPad: 684;
	--overlay1HeightPad: 554;
	--overlay2HeightPad: 697;
	--overlay3HeightPad: 576;
	--overlay4HeightPad: 697;
	--overlayHeightWPad: 684;
	--overlay1HeightWPad: 684;
	--overlay2HeightWPad: 684;
	--overlay3HeightWPad: 684;
	--overlay4HeightWPad: 684;
	--overlayHeightPhone: 684;
	--overlay1HeightPhone: 280;
	--overlay2HeightPhone: 1477;
	--overlay3HeightPhone: 211;
	--overlay4HeightPhone: 697px;
	--overlayHeightWPhone: 684px;
	--overlay1HeightWPhone: 684;
	--overlay2HeightWPhone: 684;
	--overlay3HeightWPhone: 684;
	--overlay4HeightWPhone: 684;
	--parentValue: inherit;
	--popupActiveBg: var(--bgGradientLightActive);
	--popupActiveBorder: var(--menuActiveBorder);
	--popupActiveColorBg: var(--drk-bg);
	--popupBg: var(--bgGradientDiagLight);
	--popupBorder: var(--menuBorder);
	--popupBorder2: 1px solid var(--xDrkGreen);
	--popupBtn: 48;
	--popupChildMargin: var(--mainMargin);
	--popupChildMarginBottom: -1em;
	--popupChildPadding: 0.5em 1em 0.5em 2em;
	--popupHeight: 33.15em;
	--popupHoverBg: var(--bgGradientLight);
	--popupHoverBorder: var(--menuHoverBorder);
	--popupHoverColorBg: var(--light-bg);
	--popupItemBg: transparent;
	--popupItemMargin: var(--mainMargin);
	--popupItemPadding: var(--menuPadding);
	--popupMarginRight: 2em;
	--popupMarginTop: -0.5em;
	--popupMaxWidth: 12em;
	--popupMinWidth: 6em;
	--popupPosleft: 1em;
	--popupPosTop: 3em;
	--popupView: 45;
	--posBg: center 4.2em;
	--posAbsolute: absolute;
	--posRelative: relative;
	--posFixed: fixed;
	--posStatic: static;
	--posSticky: sticky;
	--posTitle: var(--mainTextHeight);
	--progressbarBoxHeight: 2.1vw;
	--progressbarHeight: 1.5em;
	--repeateBg: no-repeat;
	--ratioHDVideo: 16/9;
	--ratioLetterBox: 16/7;
	--screenHeight: 100vh;
	--screenWide: 100vw;
	--scrollTouch: touch;
	--scrollPos: 0;
	--scrollOpacity: var(--transparent);
	--scrollFixOpacity: var(--noTransparent);
	--scrollPicTransition: var(--transitionXLong);
	--scrollPosFixTop: 0;
	--scrollPosFixBottom: 100vh;
	--scrollPic: 4;
	--scrollPicImage1: url("pic/Unwetter2.jpg");
	--scrollPicImage2: var(--animiImage);
	--scrollPicImage3: '',var(--blueGradient);
	--scrollPicImage4: url("pic/War.jpg");
	--scrollPic1activeTop: var(--scrollPic1TopPC);
	--scrollPic2activeTop: var(--scrollPic2TopPC);
	--scrollPic3activeTop: var(--scrollPic3TopPC);
	--scrollPic4activeTop: var(--scrollPic4TopPC);
	--scrollPic1TopPC: 0px;
	--scrollPic2TopPC: 764;
	--scrollPic3TopPC: 1528;
	--scrollPic4TopPC: 2292;
	--scrollPicHeightPC: 764;
	--scrollPic1HeightPC: 764;
	--scrollPic2HeightPC: 764;
	--scrollPic3HeightPC: 764;
	--scrollPic4HeightPC: 764;
	--scrollPic1TopPad: 0;
	--scrollPic2TopPad: 634;
	--scrollPic3TopPad: 1411;
	--scrollPic4TopPad: 2067;
	--scrollPicHeightPad: 777;
	--scrollPic1HeightPad: 634;
	--scrollPic2HeightPad: 777;
	--scrollPic3HeightPad: 656;
	--scrollPic4HeightPad: 777;
	--scrollPic1TopWPad: 0;
	--scrollPic2TopWPad: 764;
	--scrollPic3TopWPad: 1528;
	--scrollPic4TopWPad: 2292;
	--scrollPicHeightWPad: 764;
	--scrollPic1HeightWPad: 764;
	--scrollPic2HeightWPad: 764;
	--scrollPic3HeightWPad: 764;
	--scrollPic4HeightWPad: 764;
	--scrollPic1TopPhone: 0;
	--scrollPic2TopPhone: 320;
	--scrollPic3TopPhone: 1877;
	--scrollPic4TopPhone: 2088;
	--scrollPicHeightPhone: 320;
	--scrollPic1HeightPhone: 320;
	--scrollPic2HeightPhone: 1557;
	--scrollPic3HeightPhone: 211;
	--scrollPic4HeightPhone: 777;
	--scrollPic1TopWPhone: 0;
	--scrollPic2TopWPhone: 764;
	--scrollPic3TopWPhone: 1528;
	--scrollPic4TopWPhone: 2292;
	--scrollPicHeightWPhone: 764;
	--scrollPicSize: cover;
	--scrollPosScreenTop: var(--scrollPos);
	--scrollPosHeader: calc(var(--scrollPos) + var(--headerHeight));
	--scrollPosScreenBottom: calc(var(--scrollPos) + 100vh);
	--scrollPosFooter: calc(var(--scrollPos) + (100vh - var(--footerHeight)));
	--scrollPosHeaderBottom: calc(var(--scrollPosScreenTop) + var(--headerHeight));
	--scrollPosFooterTop: calc(var(--scrollPosScreenTop) + var(--screenHeight) - var(--footerHeight));
	--scrollPic1TopVisible: calc(var(--scrollPic1activeTop) - var(--scrollPosHeader));
	--scrollPic2TopVisible: calc(var(--scrollPic2activeTop) - var(--scrollPosHeader));
	--scrollPic3TopVisible: calc(var(--scrollPic3activeTop) - var(--scrollPosHeader));
	--scrollPic4TopVisible: calc(var(--scrollPic4activeTop) - var(--scrollPosHeader));
	--scrollSnapStop: always;
	--scrollSnapXMan: x mandatory;
	--scrollSnapYMan: y mandatory;
	--scrollBehaviorSmooth: smooth;
	--scrollSnapAlign: start;
	--selectColor: rgba(0,0,0,0.4);
	--show: visible;
	--sizeBg: contain;
	--startPos: 0px;
	--stdTerm: 25%;
	--tableColor: var(--lightgreen);
	--tableEven: #000000;
	--tableFont: Courier;
	--tableMargin: 1em;
	--tableMarginH4: 0.75em;
	--tableOdd: #222222;
	--tablePadding: 0.5em;
	--tablePaddingH4: 1.5em;
	--tableSelect: #44cc00;
	--tableThTop: 4.1em;
	--terminalFont: "OCR A","OCR A Std", "OCR-A","OCR-A Std",Monaco,Andale Mono,Courier New,Courier,monospace;
	--terminalH4Top: -0.5em;
	--terminalMarginLeft: 0.75em;
	--terminalMax: 65%;
	--terminalMin: 25%;
	--terminalPaddingH4: 1.5em;
	--terminalSelect: text;
	--terminalThpadding: 0.5em;
	--terminalTop: 4.1em;
	--terminalTopCorrect: -0.5em;
	--textCenter: center;
	--textDecoration: underline;
	--textDecoNo: none;
	--textLeft: left;
	--textRight: right;
	--textShadow: var(--fontShadow);
	--textNoShadow: none;
	--textTop: top;
	--thikBorder: 2px;
	--titleHeight: 7.5vw;
	--titleTop: calc(-7.5vw + 1em);
	--titleFontSize: 2vw;
	--titleWidth: 82vw;
	--titleLeft: 4.25em;
	--titleLineHeight: 1;
	--titleVAlign: middle;
	--titleAlign: left;
	--titlePadding: 1em 0.5em;
	--topFix: sticky;
	--topFixMoz: -moz-sticky;
	--topFixWebkit: -webkit-sticky;
	--topTerm: 10em;
	--topLeft: 0;
	--touchAction: none;
	--transBgColor: linear-gradient(to left bottom, rgba(0,224,224,0.8), rgba(0,224,224,0.1));
	--transDiagram: translate(-19%, -50%);
	--transFX: display visibility width height 0.5s;
	--translateCenter: translate(-50%, -50%);
	--transState: translateY(-30%);
	--transparent: 0.0;
	--transitionXLong: 3s;
	--transitionLong: 1.5s;
	--transition: 1s;
	--transitionFaster: 0.75s;
	--transitionNone: 0.0s;
	--transitionFast: 0.5s;
	--transitionXFast: 0.25s;
	--unshow: hidden;
	--user-select: none;
	--userSelect: none;
	--userSelectYes: text;
	--visible: block;
	--whiteColor: #ffffff;
	--whiteTrans: rgba(255,255,255,0.5);
	--widthMax: 100%;
	--xDrkGreen: #001000;
	--xLightGreen: #00c100;
	--YesNoActiveBg: linear-gradient(to top, rgba(128,128,128,1), rgba(128,128,128,0.1));
	--YesNoActiveBorder: 1px solid rgba(128,128,128,1);
	--YesNoBg: linear-gradient(to bottom, rgba(128,128,128,1), rgba(128,128,128,0.1));
	--YesNoBorder: 1px solid #888888;
	--YesNoHoverBg: linear-gradient(to top, rgba(128,128,128,1), rgba(128,128,128,0.1));
	--YesNoHoverBorder: 1px solid rgba(255,255,255,1);
	--YesNoPadding: 0.25em 1em 0.25em 1em;
	--YesNoShadow: -0.25em 0.425em 0.25em rgba(0, 0, 0, 0.6);
	--zIndexFooter: 50;
	--zIndexHeader: 50;
	--zIndexInfo: 55;
	--zIndexMain: 0;
	--zIndexMenu: 50;
	--ticking: false;
	--videoPlay: 0;
	--runFade: 0;
	--activeScroll: 0;
	--indexPosition: 0;
	--timer_on: 0;
	--picDirection: 'up';
	--swipeIn: true;
	--swipePrev: 0;
	--windowOrientation: '';
	--videoHeigth: '1080px';
	--videoWidth: '1920px';
	--swipeIn: true;
	--swipePrev: 0;
}


EOF
echo
echo Theme Variable
echo

cat << EOF > /www/CaptivePortal/theme.css

html, body {
	overflow-x: var(--overflowCut);
	width: var(--screenWide);
	#touch-action: var(--touchAction);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	-webkit-overflow-x: var(--overflowCut);
	-moz-overflow-x: var(--overflowCut);
	-ms-overflow-x: var(--overflowCut);
	left: var(--topLeft);


}

body {
	background-color: var(--drk-bg);
	background-image: var(--blueGradient3);
	font-family: var(--mainFont);
	color: var(--colorLgtGrey);
	background-repeat: var(--repeateBg);
	background-attachment: var(--bgPosFixed);
	-webkit-text-size-adjust: var(--adjust);
	-moz-text-size-adjust: var(--adjust);
	-ms-text-size-adjust: var(--adjust);
	text-size-adjust: var(--adjust);
	width: var(--screenWide) !important;
	height: var(--screenHeight) !important;
	display: var(--displayBlock) !important;
	padding: var(--noMarginPadding);
	margin: var(--noMarginPadding);
	text-shadow: var(--fontShadow);
	overflow: var(--overflowHidden);
	-webkit-overflow-x: var(--overflowHidden);
	-moz-overflow-x: var(--overflowHidden);
	-ms-overflow-x: var(--overflowHidden);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	left: var(--topLeft);
	z-index: 0;
}

body * {
	box-sizing: var(--boxSizeingBorder) ;
	/*overflow-x: var(--overflowCut);
	-webkit-overflow-x: var(--overflowCut);
	-moz-overflow-x: var(--overflowCut);
	-ms-overflow-x: var(--overflowCut);*/
	/*touch-action: var(--touchAction);*/
	-webkit-overflow-x-scrolling: var(--overflowNone);
	-webkit-overflow-y-scrolling: var(--overflowAuto);
	text-size-adjust: var(--adjust);
	-webkit-text-size-adjust: var(--adjust);
	-moz-text-size-adjust: var(--adjust);
	-ms-text-size-adjust: var(--adjust);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	-webkit-overflow-scrolling: var(--overflowScrollTouch);
}

:is(#impressum, #datenschutz, #haftung, #Screen) .Info {
	border-radius: var(--borderRadius);
	background-color: var(--infoBG);
	backdrop-filter: var(--bgBlur);
	color: var(--colorDrkGrey);
	position: var(--posFixed);
	margin: var(--infoMargin);
	display: var(--displayBlock);
	top: var(--infoPosTop);
	left: var(--infoPosLeft);
	width: var(--infoWidth);
	text-shadow: var(--infoTextShadow);
	box-sizing: var(--boxSizeingNorm);
	max-width: var(--infoMaxWidth);
	border: var(--borderDark);
	max-height: var(--infoMaxHeight);
	overflow-y: var(--overflowHidden);
	overflow-x: var(--overflowHidden); 
	box-shadow: var(--boxShadow);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	z-index: 55;
}

:is(#impressum, #datenschutz, #haftung, #Screen) > .Info > .InfoText{
	margin: var(--noMarginPadding);
	padding: var(--infoPadding);
	overflow-y: var(--overflowAuto);
	overflow-x: var(--overflowHidden); 
	width: var(--infoTextWidth);
	max-height: var(--infoMaxHeight);
	user-select: var(--userSelectYes);
	-webkit-user-select: var(--userSelectYes);
	-moz-user-select: var(--userSelectYes);
	z-index: 55;
}

:is(#impressum, #datenschutz, #haftung, #Screen) a{ 
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);

}

:is(#impressum, #datenschutz, #haftung, #Screen) img{
	display: var(--displayInlineBlock);
	height: calc(var(--infoImageHeight) * 0.9);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	line-height: 1;
	vertical-align: baseline;

}

:is(#impressum, #datenschutz, #haftung, #Screen) .buttonModal {
	background-color: var(--buttonColorNorm);
	font-family: var(--infoFont);
	display: var(--displayInlineBlock);
	color: var(--colorDrkGrey);
	float: var(--buttonFloat);
	font-size: var(--infoFontButtonHeight);
	margin: var(--noMarginPadding) !important;
	position: var(--posAbsolute);
	top: var(--buttonTop) !important;
	right:var(--buttonRight)!important;
	width: var(--buttonHeight) !important;
	height: var(--buttonHeight) !important;
	box-sizing: var(--boxSizeingNorm);
	padding: var(--buttonPadding);
	border-top-right-radius: var(--borderRadius);
	cursor: var(--buttonCursor);
	z-index: 54;
}

:is(#impressum, #datenschutz, #haftung, #Screen) .buttonModal:hover, :is(#impressum, #datenschutz, #haftung, #Screen) .info .buttonModal:active {
	background-color: var(--buttonColorSelect);
	font-family: var(--infoFont);
	display: var(--displayInlineBlock);
	color: var(--lightColor);
	text-decoration: var(--textDecoNo) !important;
}

#impressum:target {
	display: var(--displayBlock);
}

#datenschutz:target {
	display: var(--displayBlock);
}

#haftung:target {
	display: var(--displayBlock);
}



header {
	background-image: var(--headerBGImage);
	background-color: var(--colorDrkGrey);
	background-repeat: var(--repeateBg);
	backdrop-filter: var(--bgBlur);
	background-position-x: var(--headerBGPosX);
	background-position-y: var(--headerBGPosY);
	background-size: var(--headerBGSize);
	backdrop-filter: var(--bgBlur);
	color: var(--colorLgtGrey);
	width: var(--maxWidth);
	height: var(--headerHeightLarge) +'em';
	position: var(--posFixed);
	text-align: var(--headerAlign);
	top: var(--headerTop);
	margin: var(--noMarginPadding) auto;
	display: var(--displayBlock);
	overflow: var(--overflowHidden);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	z-index: 50;

}

.headerText {
	text-align: var(--headerAlign);	
}


.headerText h3{
	position: var(--posRelative);
	top: var(--headerTopH3) !important;
	line-height: var(--headerLineHeight);
}


#topMenu {
	position: var(--posFixed);
	display: var(--displayBlock);
	top: var(--menuTopTop) !important;
	padding: 0.5em;
	margin: var(--noMarginPadding) !important;
	width: var(--menuTopWidth);
	left: 0em;
	text-shadow: none;
	cursor: pointer;
	max-height: 2.8em;
	-webkit-overflow-x: var(--overflowCut);
	-moz-overflow-x: var(--overflowCut);
	-ms-overflow-x: var(--overflowCut);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	border-radius: var(--borderRadius);
	transition: var(--transitionFast);
	z-index: 50;
}


#topMenu:active, #topMenu:hover, #topMenu:focus, #topMenu:focus-within, #topMenu:focus-visible {
	background-color: var(--colorDrkGrey);
	box-shadow: var(--boxShadow);
	backdrop-filter: var(--bgBlur);
	max-height: unset;
}


#topMenu a, #topMenu a:hover, #topMenu a:active, #topMenu a:focus, #topMenu a:focus-within, #topMenu a:focus-visible {
	text-decoration: var(--textDecoNo) !important;
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);

}

nav :is(a:hover, a:active, a:focus, a:focus-within, a:focus-visible) {
	text-decoration: var(--textDecoNo);
	color: var(--colorLgtGrey);
	text-shadow: var(--fontShadow);
}
/*
nav > ul {
	background-color: var(--blueTransparent);
	padding: .5em;
	border-radius: 7px;
}
*/
#topMenu:hover > ul, #topMenu:active > ul, #topMenu:focus > ul, #topMenu:focus-within > ul, #topMenu:focus-visible > ul {
	width: 14em;
	margin: var(--noMarginPadding);
	visibility: var(--show);
	height: auto;
	background-color: var(--blueTransparent);
	box-shadow: var(--boxShadow);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);

}

#topMenu > ul {
	width: 14em;
	margin: var(--noMarginPadding);
	margin-bottom: 0.25em;
	visibility: collapse;
	height: 1;
	width: 1;
	display:var(--displayBlock);
	list-style-type: none;
	padding: 0.25em 0;
	border-radius: var(--borderRadius);
	-webkit-overflow-x: var(--overflowCut);
	-moz-overflow-x: var(--overflowCut);
	-ms-overflow-x: var(--overflowCut);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	z-index: 50;

}

#topMenu li:hover, #topMenu li:active, #topMenu li:focus, #topMenu li:focus-within, #topMenu li:focus-visible{
	text-shadow: var(--fontShadow);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
}

#topMenu li {
	display:var(--displayBlock);
	position: var(--posRelative);
	margin: var(--noMarginPadding);
	padding-left: 1em;
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	border-radius: var(--borderRadius);
}

#topMenu li > ul {
	visibility: collapse;
	list-style-type: none;
	height: 0em;
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
}

#topMenu li:hover > ul, #topMenu li:active > ul, #topMenu li:focus > ul, #topMenu li:focus-within > ul, #topMenu li:focus-visible > ul{
	visibility: var(--show);
	height:auto;
	display:var(--displayInlineBlock);
	left: -4em;
	margin: auto var(--noMarginPadding);
	padding-left:5em;
	position: var(--posRelative);
	width: 14em;
	color: var(--lightColor);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	z-index: 50;
}

.iconMenu {
	box-shadow: var(--menuShadow);
	background-color: var(--colorDrkGreyTrans);
	margin: var(--noMarginPadding);
	padding: 0.25em 0.25em 0.25em 0.5em;
	border-radius: var(--borderRadius);
	float: left;
	z-index: 50;
}

.containerIcon {
	display: var(--displayBlock);
	height: 2em;
	vertical-align: middle;
	position: var(--posRelative);
	left: -0.85em;
	opacity: var(--noTransparent);
	z-index: 50;
}

.iconText {
	position: var(--posRelative);
	top: 0.4em;
	padding-left: 0.25em;
	display: var(--displayInlineBlock);
	text-shadow: var(--fontShadow);
	z-index: 50;
}

.iconMenu div {
	width: 1em;
	height: 0.14em;
	background-color: var(--colorLgtGrey);
	margin: 0.20em 0.5em;
	box-shadow: var(--boxShadow);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	z-index: 50;
}

a {
	text-decoration: var(--textDecoNo);
	color: var(--parentValue);
	opacity: var(--halfTransparent);
	cursor: pointer !important;
	user-select: var(--userSelect) !important;
	-webkit-user-select: var(--userSelect) !important;
	-moz-user-select: var(--userSelect) !important;

}

a:hover, a:active {
	text-decoration: var(--textDecoration);
	cursor: pointer !important;
	opacity: unset;
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);

}

#Main {
	background: unset;
	height: var(--screenHeight) !important;
	width: var(--screenWide) !important;
	background-attachment: var(--bgPosFixed);
	background-size: cover;
	background-repeat: none;
	box-sizing: border-box ;
	overflow-x: var(--overflowHidden);
	-webkit-overflow-x: var(--overflowHidden);
	-moz-overflow-x: var(--overflowHidden);
	-ms-overflow-x: var(--overflowHidden);
	-webkit-overflow-x-scrolling: var(--overflowNone);
	overflow-y: var(--overflowAuto);
	text-size-adjust: var(--adjust);
	-webkit-text-size-adjust: var(--adjust);
	-moz-text-size-adjust: var(--adjust);
	-ms-text-size-adjust: var(--adjust);
	left: 0em !important;
	top: 0em !important;
	position: absolute;
	scroll-snap-stop: always;
	scroll-snap-type: y mandatory;
	scroll-behavior: smooth;
}

main#start {
	overflow-x: var(--overflowHidden);
}

cite::before, cite::after {
	font-size: 1.5em !important;
	display: inline-block;
}

cite::before {
	top: 0em !important;
}


cite::after {
	top: .3em !important;
}

.Title cite::before {
	top: 0.15em !important;
}
 
.Title cite::after {
	top: 0.85em !important;
}


.containerDiashow{
	background-size: contain;
	background-repeat: var(--repeateBg);
	background-origin: border-box;
	margin: var(--noMarginPadding);
	padding: var(--noMarginPadding);
	top: 0;
	left: -2.5em;
	width: var(--screenWide) !important;
	min-height: calc(calc(var(--screenWide) / 16) * 6);
	max-height: calc(calc(var(--screenWide) / 16) * 9);
	overflow-x: clip !important;
	overflow-y: clip !important;
	-webkit-aspect-ratio: var(--aspectRatio);
	aspect-ratio: var(--aspectRatio);
	text-align: center;
	position: var(--posRelative) !important;
	-webkit-overflow-scrolling: var(--overflowScrollTouch);
	-webkit-overflow-x: var(--overflowCut);
	-webkit-overflow-y: var(--overflowCut);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);

}

.containerOverlay{
	display: var(--displayBlock);
	scroll-snap-align: start;
	scroll-snap-stop: always;
	scroll-behavior: smooth;
	margin: var(--noMarginPadding);
	padding: var(--noMarginPadding);
	width: var(--screenWide);
	background-attachment: var(--bgPosFixed);
	background-size: cover;
	background-repeat: var(--repeateBg);
	overflow-x: clip;
	overflow-y: auto;
	height: var(--overlayHeightPC);
	min-height: var(--factorLetterBoxSmallVideoVW);
	z-index:10;
}

.containerOverlay:not(> .containerDiashow, .Diashow) {
	text-align: center;
	vertical-align: middle;
	padding: 0em 2.5em 0em 2.5em !important;
}

.containerOverlay:nth-child(1) {
	top: var(--overlay1TopPC);
	height: var(--overlay1HeightPC);
	position: var(--posAbsolute);
}

.containerOverlay:nth-child(2) {
	top: -100vh;
	height: var(--overlay2HeightPC);
	position: var(--posRelative);
}

.containerOverlay:nth-child(3) {
	top: var(--overlay3TopPC);
	height: var(--overlay3HeightPC);
	position: var(--posAbsolute);
	overflow: var(--overflowHidden);
}

.containerOverlay:nth-child(4) {
	top: var(--overlay4TopPC);
	height: var(--overlay4HeightPC);
	position: var(--posAbsolute);
}


.containerBibleText {
	width: var(--containerBibleTextWidth);
}

.containerBibleText img{
	position: var(--posRelative) !important;
	display: var(--bibleTextImageDisplay);
	box-shadow: var(--bibleImageShadow) !important;
	height: 1em;
	top: 0.25em;
}

.containerBibleText:nth-child(1){
	display: var(--bibleTextDisplay);
	position: var(--posAbsolute);
	animation-name: aniBibleTxt1;
	animation-duration: 15s;
	animation-iteration-count: infinite;
	visibility: var(--show);
}	

.containerBibleText:nth-child(2) {
	display: var(--bibleTextDisplay);
	animation-name: aniBibleTxt2;
	animation-duration: 15s;
	animation-iteration-count: infinite;
	visibility: var(--unshow);
}


@keyframes aniBibleTxt1 {
 	0% {
		opacity: var(--transparent);
		display: var(--bibleTextHidden);
		visibility: var(--unshow);
  	}
	5% {
		opacity: var(--noTransparent);
		display: var(--bibleTextDisplay);
		visibility: var(--show);
	}
	45% {
		opacity: var(--noTransparent);
		display: var(--bibleTextDisplay);
		visibility: var(--show);
	}
	50% {
		opacity: var(--transparent);
		display: var(--bibleTextHidden);
		visibility: var(--unshow);

	}
	100% {
		opacity: var(--transparent);
		display: var(--bibleTextHidden);
		visibility: var(--unshow);
	}
}

@keyframes aniBibleTxt2 {
	0% {
		opacity: var(--noTransparent);
		display: var(--bibleTextDisplay);
		visibility: var(--show);
	}
	5% {
		opacity: var(--transparent);
		display: var(--bibleTextHidden);
		visibility: var(--unshow);
	}
	45% {
		opacity: var(--transparent);
		display: var(--bibleTextHidden);
		visibility: var(--unshow);
	}
	50% {
		opacity: var(--noTransparent);
		display: var(--bibleTextDisplay);
		visibility: var(--show);
	}
	100% {
		opacity: var(--noTransparent);
		display: var(--bibleTextDisplay);
		visibility: var(--show);
	}
}



.Content {
	font-family: var(--infoFont);
	background: var(--bgTransparent);
	color: var(--colorLgtGrey) !important;
	text-align: center;
	user-select: var(--userSelectYes);
	-webkit-user-select: var(--userSelectYes);
	-moz-user-select: var(--userSelectYes);
	-moz-hyphens: var(--hyphens);
	-o-hyphens: var(--hyphens);
	-ms-hyphens: var(--hyphens);
	hyphens: var(--hyphens);
	z-index: 15;
}

.ContentText{
	font-family: var(--mainFont);
	text-align: justify !important;
	word-break: break-word;
	background: var(--bgTransparent);
	backdrop-filter: var(--bgBlur);
	color: var(--colorLgtGrey) !important;
	height: auto;
	padding: 6.5em 2.5em 2.5em 2.5em !important;
	user-select: var(--userSelectYes);
	-webkit-user-select: var(--userSelectYes);
	-moz-user-select: var(--userSelectYes);
	-o-user-select: var(--userSelectYes);
	-ms-user-select: var(--userSelectYes);
	-webkit-hyphens: var(--hyphens);
	-moz-hyphens: var(--hyphens);
	-o-hyphens: var(--hyphens);
	-ms-hyphens: var(--hyphens);
	hyphens: var(--hyphens);
	z-index: 16;
	
}

.ContentText::before, cite::before {
	position: var(--posRelative);
	font-size: 2.5em;
	vertical-align: bottom;
	content: '“';
	top: 0.35em;
	left: -0.15em;
	font-family: var(--fontBook);
}

.ContentText::after, cite::after {
	position: var(--posRelative);
	font-size: 2.5em;
	vertical-align: top;
	content: '”';
	top: 0em;
	left: 0em;
	font-family: var(--fontBook);
}

.Content ,.containerDiashow{
	display: var(--displayBlock);
	margin: var(--noMarginPadding);
	padding: var(--noMarginPadding);
	width: var(--screenWide);
	background-attachment: var(--bgPosFixed);
	background-size: cover;
	background-repeat: unset;
	min-height: var(--factorHDVideo)+'vw';
	z-index:10;
}


.contentOverlay {
	top: calc(var(--headerHeight) + 2em) !important;
	position: var(--posRelative);
	display: var(--displayBlock);
	margin: var(--noMarginPadding);
	text-align: center;
}

.contentOverlay:has(:not(a .bibleText)){
	min-height:  var(--factorHDVideo) + 'vw';
}

main .containerOverlay .Overlay.Book {
	margin: var(--headerHeight) auto auto !important;
	overflow-y: var(--overflowScroll) !important;
}

.Content .Book {
	width: 90% !important;
	font-family: var(--fontBook);
	color: var(--bookTextColor);
	text-shadow: none;
	display: var(--displayInlineBlock) !important;
	position: var(--posRelative);
	text-align: justify;
	padding: var(--noMarginPadding);
	width: var(--maxWidth);
	background-color: #000000;
	box-shadow: var(--boxShadow);
	margin: auto;
	box-sizing: border-box!important;
	height: calc(var(--screenHeight) - var(--headerHeight) - 3em) !important;
	overflow-x: var(--overflowCut) !important;
	overflow-y: var(--overflowCut);
	user-select: var(--userSelectYes);
	-webkit-user-select: var(--userSelectYes);
	-moz-user-select: var(--userSelectYes);
	-webkit-hyphens: var(--hyphens);
	-moz-hyphens: var(--hyphens);
	-o-hyphens: var(--hyphens);
	-ms-hyphens: var(--hyphens);
	hyphens: var(--hyphens);
}

.Content .Book .BookContainerLeft{
	display: var(--displayInlineBlock);
	width: 50%;
	height: 100vh;
	top:0;
	left:0;
	box-sizing: var(--boxSizeingNorm) !important;
	position: var(--posRelative);
	float: left;
	overflow-y:var(--overflowCut);
	overflow-x:var(--overflowCut);
	user-select: var(--userSelectYes);
	-webkit-user-select: var(--userSelectYes);
	-moz-user-select: var(--userSelectYes);
}

.Content .Book .BookContainerRight{
	display: var(--displayInlineBlock);
	width: 50%;
	height: 100vh;
	left:0;
	box-sizing: var(--boxSizeingNorm) !important;
	position: var(--posRelative);
	float: left;
	overflow-y:var(--overflowCut);
	overflow-x:var(--overflowCut);
	user-select: var(--userSelectYes);
	-webkit-user-select: var(--userSelectYes);
	-moz-user-select: var(--userSelectYes);

}


.Content .Book .BookContent{
	width: var(--maxWidth);
	height: 100vh !important;
	color: var(--bookTextColor);
	text-shadow: none;
	display: var(--displayBlock);
	box-sizing: var(--boxSizeingNorm) !important;
	position: var(--posRelative);
	top: 0;
	left: 0;
	text-align: justify;
	float: left;
	overflow-y:var(--overflowVisible);
	overflow-x:var(--overflowCut);
	user-select: var(--userSelectYes);
	-webkit-user-select: var(--userSelectYes);
	-moz-user-select: var(--userSelectYes);

}

.Content .Book .leftLast{
	width: var(--maxWidth);
	height: 100vh;
	background-color: var(--bookBGColor);
	background-image: var(--bookBGImage);
	display: var(--displayInlineBlock);
	box-sizing: border-box !important;
	padding: 0.8em 2em 1.5em 1.15em;
	position: var(--posRelative);
	top: 0;
	left: 0;
	float:left;
	overflow: var(--overflowHidden);
	user-select: var(--userSelectYes);
	-webkit-user-select: var(--userSelectYes);
	-moz-user-select: var(--userSelectYes);

}


.Content .Book .left{
	width: var(--maxWidth);
	height: 100vh;
	background-color: var(--bookBGColor);
	background-image: var(--bookBGImage);
	display: var(--displayBlock);
	box-sizing: border-box !important;
	padding: 0.8em 2em 1.5em 1.15em;
	position: var(--posAbsolute);
	top: 0;
	left:0;
	transform-origin: 100%;
	transform: rotateY(0deg);
	transition: var(--transitionFast);
	overflow: var(--overflowHidden);
	user-select: var(--userSelectYes);
	-webkit-user-select: var(--userSelectYes);
	-moz-user-select: var(--userSelectYes);

}

.Content .Book .rightNext{
	width: var(--maxWidth);
	height: 100vh;
	background-color: var(--bookBGColor);
	background-image: var(--bookBGImage);
	display: var(--displayInlineBlock);
	padding: 0.8em 1.15em 1.5em 2em;
	position: var(--posAbsolute);
	box-sizing: border-box !important;
	top: 0;
	right: 0;
	float: right;
	overflow: var(--overflowHidden);
	user-select: var(--userSelectYes);
	-webkit-user-select: var(--userSelectYes);
	-moz-user-select: var(--userSelectYes);

}


.Content .Book .right{
	width: var(--maxWidth);
	height: 100vh;
	background-color: var(--bookBGColor);
	background-image: var(--bookBGImage);
	display: var(--displayBlock);
	padding: 0.8em 1.15em 1.5em 2em;
	position: var(--posAbsolute);
	box-sizing: border-box !important;
	top: 0;
	right: 0;
	float: right;
	transform-origin: 0%;
	transform: rotateY(0deg);
	transition: var(--transiitionFast) ;
	overflow: var(--overflowHidden);
	user-select: var(--userSelectYes);
	-webkit-user-select: var(--userSelectYes);
	-moz-user-select: var(--userSelectYes);

}



.PlayerOverlay {
	box-shadow: var(--logoBackShadow);
	left: var(--logoPosLeft);
	top: var(--logoPosTop);
	display: var(--displayBlock);
	position: var(--posAbsolute);
	vertical-align: middle;
	text-align: center;
	width: var(--screenWide);
	height: var(--logoHeight);
	background-image: var(--logoPic);
	background-size: var(--logoSize);
	background-repeat: var(--logoRepeate);
	margin: var(--noMarginPadding);
	padding: var(--noMarginPadding);
	overflow-x: var(--overflowCut);
	overflow-y: var(--overflowCut);
	transition: var(--transitionFast) ease;
	-webkit-overflow-scrolling: auto;
	-webkit-overflow-x: var(--overflowCut);
	-webkit-overflow-y: var(--overflowCut);
	z-index: 13;
}

.PlayerOverlay:hover, .PlayerOverlay:active{
	visibility: var(--show);
}

.channelLogo {
	box-shadow: var(--logoShadow);
	height: var(--logoHeight);
	width: var(--logoWidth);
	top: var(--logoPosTop) !important;
	position: var(--posAbsolute);
	background-image: var(--logoPic);
	background-size: var(--logoSize);
	background-repeat: var(--logoRepeate);
	z-index: 20;
}


.Diashow{
	--items: 9;
	--runs: calc((100 - var(--items) *2) -2);
	--factor: calc(100 / var(--runs));
	scroll-snap-type: x mandatory;
	scroll-snap-stop: always;
	scroll-behavior: smooth;
	background-size: contain;
	background-repeat: var(--repeateBg);
	background-origin: border-box;
	top:0;
	left:0;
	/*width: 900vw;*/
	height: var(--factorLetterBoxVideoVW);
	margin: auto !important;
	display: var(--displayBlock);
	box-shadow: none;
	opacity: var(--noTransparent) !important;
	overflow: var(--overflowHidden);
	position: var(--posAbsolute);
	/*-webkit-overflow-scrolling: auto;*/
	/*-webkit-overflow-x: var(--overflowCut);*/
	-webkit-overflow-x: var(--overflowScroll);
	-webkit-overflow-scrolling: var(--overflowScrollTouch);
	-webkit-overflow-y: var(--overflowCut);
	/*overflow-x: var(--overflow);*/
	overflow-x: var(--overflowScroll);
	overflow-y: var(--overflowCut);
	transition: left var(--transitionXLong) ease, right var(--transitionXLong) ease;
	transition-property: width, height, position, top, left, right, bottom;
	animation-name: aniDiashow;
	animation-duration: 240s;
	animation-iteration-count: infinite;
}


@keyframes aniDiashow {
	0% {
		left: 0vw;
		visibility: visible !important;
	}
	4.05% {
		left: 0vw;
		visibility: hidden !important;
	}
	4.55% {
		left: -100vw;
		visibility: visible !important;
	}
	10.10% {
		left: -100vw;
		visibility: hidden !important;
	}
	10.60% {
		left: -200vw;
		visibility: visible !important;
	}
	16.15% {
		left: -200vw;
		visibility: hidden !important;
	}
	16.55% {
		left: -300vw;
		visibility: visible !important;
	}
	23.10% {
		left: -300vw;
		visibility: hidden !important;
	}
	23.60% {
		left: -400vw;
		visibility: visible !important;
	}
	30.15% {
		left: -400vw;
		visibility: hidden !important;
	}
	30.55% {
		left: -500vw;
		visibility: visible !important;
	}
	36.10% {
		left: -500vw;
		visibility: hidden !important;
	}
	36.60% {
		left: -600vw;
		visibility: visible !important;
	}
	42.15% {
		left: -600vw;
		visibility: hidden !important;
	}
	42.65% {
		left: -700vw;
		visibility: visible !important;
	}
	48.20% {
		left: -700vw;
	}
	48.70% {
		left: -700vw;
	}
	54.25% {
		left: -700vw;
		visibility: hidden !important;
	}
	54.75% {
		left: -600vw;
		visibility: visible !important;
	}
	60.30% {
		left: -600vw;
		visibility: hidden !important;
	}
	60.85% {
		left: -500vw;
		visibility: visible !important;
	}
	66.40% {
		left: -500vw;
		visibility: hidden !important;
	}
	66.90% {
		left: -400vw;
		visibility: visible !important;
	}
	72.45% {
		left: -400vw;
		visibility: hidden !important;
	}
	72.95% {
		left: -300vw;
		visibility: visible !important;
	}
	78.50% {
		left: -300vw;
		visibility: hidden !important;
	}
	79.00% {
		left: -200vw;
		visibility: visible !important;
	}
	84.55% {
		left: -200vw;
		visibility: hidden !important;
	}
	85.05% {
		left: -100vw;
		visibility: visible !important;

	}
	90.60% {
		left: -100vw;
		visibility: hidden !important;
	}
	91.10% {
		left: 0vw;
		visibility: visible !important;
	}
	96.55% {
		left: 0vw;
	}
	97.05% {
		left: 0vw;
	}
}

#explainEnd {
	transition: var(--transitionXLong);
}

#explainEnd .Overlay{
	opacity: 0.3;
	transition: var(--transitionFast);
	backdrop-filter: var(--bgBlur);
}


#explainEnd:target > .Overlay, #explainEnd:focus > .Overlay, #explainEnd:focus-visible > .Overlay, #explainEnd:focus-within > .Overlay, #explainEnd:active > .Overlay, #explainEnd:hover > .Overlay, #explainEnd:visited > .Overlay {
	opacity: 1;
}

#explainStart {
	perspective: var(--animiStopPerspective) !important;
	transition: var(--transitionXLong);
	overflow: var(--defaultValue) !important;
	overflow-y: var(--overflowOverlay);
}

#explainStart .image {
	perspective: var(--animiStopPerspective) !important;
	transition: var(--transitionXLong);
}


#explainStart .Overlay{
	opacity: 0.3;
	transition: var(--transitionFast);
	backdrop-filter: var(--bgBlur);
}


#explainStart:target, #explainStart:focus, #explainStart:focus-visible, #explainStart:focus-within, #explainStart:active, #explainStart:hover {
	perspective: var(--animiStartPerspective) !important;
}

#explainStart:target > .Overlay, #explainStart:focus > .Overlay, #explainStart:focus-visible > .Overlay, #explainStart:focus-within > .Overlay, #explainStart:active > .Overlay, #explainStart:hover > .Overlay, #explainStart:visited > .Overlay{
	opacity: 1;
}


header:not(:not([style*="visibility: hidden"]))  #NaviDown{
	visibility: var(--show) !important;
}

header:not([style*="visibility: hidden"]) > #NaviDown{
	visibility: var(--show);
}

.containerDiashow:hover .PlayerOverlay{
	width: var(--logoWidth);
}

.containerDiashow:hover .Title, .containerDiashow:hover .Navi, .containerDiashow:hover .dotBackground{
	visibility: var(--unshow) !important;
}

.backgroundTitle:hover .PlayerOverlay{
	width: var(--screenWide) !important;
}


:is(.Content > .containerOverlay > .containerDiashow:hover ) :is(.dotBackground, .Title, .Navi) {
	visibility: var(--unshow) !important;
}

.containerDiashow:hover .Diashow, body .Diashow:hover, body .Diashow:active, body .Diashow:focus, body .Diashow:focus-within {
	animation-play-state: paused;
}

body:is( > .Content > .containerOverlay > .containerDiashow:hover) :is( > .header){
	visibility: hidden !important;
}

.contSlide {
	height: calc(var(--screenWide) * 0.5625); 
	width: var(--screenWide);
	display: var(--displayInlineBlock);
	scroll-snap-align: var(--scrollSnapAlign);
	padding: var(--noMarginPadding);
	margin: var(--noMarginPadding);
	text-align: center;
	float: var(--flowLeft);
	top: var(--topLeft);
	position: var(--posRelative);
	border: solid;
}
/*
.contSlide {
	display: var(--displayBlock);
	background-color: rgba(0, 0, 0, 0.75);
	margin: var(--noMarginPadding);
	padding: var(--noMarginPadding);
	width: var(--screenWide);
	height: var(--screenHeight);
	/*height: var(--factorHDVideo) + 'vw';*/
	-webkit-aspect-ratio: var(--aspectRatio);
	aspect-ratio: var(--aspectRatio);
	box-sizing: border-box;
	position: var(--posRelative);
	float: left;
	overflow-x: var(--overflowCut);
	overflow-y: var(--overflowCut);
	/*-webkit-overflow-scrolling: auto;*/
	-webkit-overflow-x: var(--overflowCut);
	-webkit-overflow-y: var(--overflowCut);
}*/


.Diashow .containerSlide {
	display: var(--displayInlineBlock);
	background-color: rgba(0, 0, 0, 0.75);
	margin: var(--noMarginPadding);
	padding: var(--noMarginPadding);
	width: var(--screenWide);
	height: var(--factorHDVideo) + 'vw';
	-webkit-aspect-ratio: var(--aspectRatio);
	aspect-ratio: var(--aspectRatio);
	box-sizing: border-box;
	float: left;
	overflow-x: var(--overflowCut);
	overflow-y: var(--overflowCut);
	-webkit-overflow-scrolling: auto;
	-webkit-overflow-x: var(--overflowCut);
	-webkit-overflow-y: var(--overflowCut);
}
/*
.Diashow1 .Slide{
	opacity: var(--noTransparent);
	margin: var(--noMarginPadding);
	width: var(--screenWide) !important;
	height:  var(--factorHDVideo) + 'vw' !important;
	-webkit-aspect-ratio: var(--aspectRatio);
	aspect-ratio: var(--aspectRatio);
	display: var(--displayInlineBlock);
	float:left;
	-webkit-overflow-scrolling: auto;
	-webkit-overflow-x: var(--overflowCut);
	-webkit-overflow-y: var(--overflowCut);
	overflow-x: var(--overflowCut);
	overflow-y: var(--overflowCut);
	scroll-snap-align: start;
	scroll-snap-stop: always;
	scroll-behavior: smooth;
}

.Diashow1 a {
	padding: var(--noMarginPadding);
	margin: var(--noMarginPadding);
	display: var(--displayInlineBlock);
	width: var(--screenWide);
	top: 0;
	left: 0;
	float: left;
	text-decoration: var(--textDecoNo) !important;
	color: var(--parentValue) !important; 
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);

}

.Diashow1 a div{
	text-decoration: var(--textDecoNo) !important;
	color: var(--colorLgtGrey) !important;
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);

}

.Diashow1 .Title a{
	color: var(--parentValue) !important;
}


	
.Diashow1 .Overlay {
	margin: auto !important;
	display: var(--displayInlineBlock) !important;
	text-align: center;
	position: var(--posAbsolute) !important;
	top: 0em;
	left: 0em;
	height:  var(--factorHDVideo) + 'vw';
	width: var(--screenWide);
	-webkit-aspect-ratio: var(--aspectRatio);
	aspect-ratio: var(--aspectRatio);
	overflow: var(--overflowHidden);
	overflow-x: var(--overflowCut);
	overflow-y: var(--overflowCut);
	-webkit-overflow-scrolling: auto;
	-webkit-overflow-x: var(--overflowCut);
	-webkit-overflow-y: var(--overflowCut);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);

}

.Diashow1 .Overlay img {
	display: var(--displayInlineBlock) !important;
	text-align: center;
	position: var(--posRelative) !important;
	border-radius: var(--borderRadius);
	top: 0.5em;
	width: 12.51vw;
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
}

.Diashow1 .Overlay .contentOverlay{
	margin: auto !important;
	display: inline !important;
	text-align: center;
	position: var(--posRelative) !important;
	top: 5em;
	left: 0em;
 }
*/
figure.image {
	overflow-x: var(--overflowCut);
	height: inherit;
	width: var(--screenWide) !important;
	border: 2px solid #eeee00;
	padding: var(--noMarginPadding);
	margin: var(--noMarginPadding);
	transform: translateZ(-1px);
}

.Overlay{
	left: 0;
	opacity: var(--noTransparent);
	position: var(--posRelative);
	display: var(--displayInlineBlock);
	#width: var(--screenWide);
	margin: auto;
	#top: calc(-28.125vw - 7.5em);
	left: 0px;
	text-align: center;
	vertical-align: middle;
	backdrop-filter: var(--bgBlur);
	#background-color: rgba(0,0,128,0.4);
	#padding-bottom: 8.5em;
	color: var(--colorLgtGrey);
	font-size: 20px;
	overflow-x: var(--overflowCut);
	-webkit-overflow-scrolling: auto;
	-webkit-overflow-x: var(--overflowCut);
	-webkit-overflow-y: var(--overflowCut);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	text-select: var(--userSelect);
	z-index: 20;
}

.Overlay img {
	border-radius: var(--borderRadius);
	box-shadow: var(--boxShadow);
	-webkit-overflow-scrolling: auto;
	-webkit-overflow-x: var(--overflowCut);
	-webkit-overflow-y: var(--overflowCut);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);

}


.Overlay:nth-child(2) {
	background-size: cover;
	background-repeat: var(--repeateBg);
	background-position: center;
	width: var(--screenWide);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);

}

.Overlay:nth-child(3) {
	background-size: cover;
	background-repeat: var(--repeateBg);
	background-position: center;
	background-color: rgba(0,0,0,1);
	max-height:  var(--factorHDVideo) + 'vw';
	width: var(--screenWide);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	-webkit-overflow-scrolling: auto;
	-webkit-overflow-x: var(--overflowCut);
	overflow-x: var(--overflowCut);

}

.dotContainer {
	position: var(--posAbsolute);
	top: 40.65vw;
	margin: var(--noMarginPadding);
	padding: var(--noMarginPadding);
	width: var(--maxWidth);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);

}

.dot {
	height: 15px;
	width: 15px;
	margin: 0 2px;
	background-color: rgba(255,255,255,0.75);
	border-radius: 50%;
	display: var(--displayInlineBlock);
	transition: background-color var(--transitionFast) ease;
	position: var(--posRelative);
	bottom: 0px;
	box-shadow: var(--boxShadow);
	user-select: var(--userSelect)
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	z-index: 14;
}

.dotBackground {
	text-align:center;
	background-color: var(--colorDrkGreyTrans);
	backdrop-filter: var(--bgBlur);
	display:var(--displayInlineBlock);
	border-radius: 0.5em;
	width: auto;
	padding:0.125em	0.25em;
	box-shadow:var(--menuShadow);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	visibility: var(--unshow);
}

.containerNavi {
	position: var(--posAbsolute);
	margin: var(--noMarginPadding);
	padding: var(--noMarginPadding);
	display: var(--displayBlock);
	left: 0;
	top: calc(-  (var(--factorHDVideo) + 'vw') - 8.645833vw);
	background: var(--bgTransparent);
	width: var(--screenWide);
	height:  var(--factorHDVideo) + 'vw';
	-webkit-aspect-ratio: var(--aspectRatio);
	aspect-ratio: var(--aspectRatio);
	overflow: var(--overflowHidden);
	overflow-x: var(--overflowCut);
	overflow-y: var(--overflowCut);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	z-index: 14;
}

.Navi {
	position: var(--posAbsolute);
	top: calc(28.125vw - 1.75em);
	width: 2.5em;
	color: rgba(255, 255, 255, 1);
	background-color: var(--colorDrkGreyTrans);
	backdrop-filter: var(--bgBlur);
	display: var(--displayBlock);
	text-decoration: var(--textDecoNo) !important;
	vertical-align: middle;
	text-align: center;
	height: fit-content;
	box-shadow: var(--menuShadow);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	cursor: pointer;
	padding: 1em var(--noMarginPadding);
	margin: var(--noMarginPadding);;
	z-index: 14;
}

.Navi:hover, .Navi:active {
	text-decoration: var(--textDecoNo) !important;
}

#NaviLeft {
	left: 0px;
	position: var(--posRelative);
	float:left;
	border-top-right-radius: 0.5em;
	border-bottom-right-radius: 0.5em;
	visibility: var(--unshow);
}

#NaviRight {
	right: 0px;
	position: var(--posRelative);
	float:right;
	border-top-left-radius: 0.5em;
	border-bottom-left-radius: 0.5em;
	visibility: var(--unshow);
}

#NaviPlay {
	left: 45.2vw !important;
	position: var(--posRelative);
	float: left;
	border: unset;
	background: none !important;
	width: 4.5vw;
	visibility: var(--unshow);
	box-shadow: unset !important;
	transistion: visibility var(--transitionXLong);
}

#NaviDown {
	position: var(--posAbsolute);
	top: 1.75em;
	right: 2em;
	min-width: 1.5em !important;
	height: 1.5em !important;
	color: var(--lightColor);
	text-shadow: var(--fontShadow);
	display: var(--displayBlock);
	vertical-align: middle;
	text-align: center;
	box-shadow: var(--menuShadow);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	padding: 5px;
	margin: var(--noMarginPadding);
	border-radius: 50%;
	background-color: var(--colorDrkGreyTrans);
	visibility: var(--unshow);
	z-index: 14;
}

#NaviLeft:hover,
#NaviRight:hover{
	background-color: var(--colorBlueMid);
	color: var(--lightColor);
}

.scrollPic{
	scroll-snap-align: var(--scrollSnapAlign);
	scroll-behavior: var(--scrollBehaviorSmooth);
	scroll-snap-stop: var(--scrollSnapStop);
	height: var(--screenHeight);
	width: var(--screenWide);
	overflow-x: var(--overflowHidden);
	display: var(--displayBlock);
	position: var(--posRelative);
}

.scrollPic .Slide, .scrollPic iframe, .Overlay .Slide, .Overlay iframe{
	display: var(--displayBlock);
	margin: var(--noMarginPadding);
	padding: var(--noMarginPadding);
	width: var(--screenWide);
	background-attachment: var(--bgPosFixed);
	background-size: var(--scrollPicSize);
	background-repeat: var(--repeateBg);
	min-height: var(--factorLetterBoxSmallVideoVW);
	height: calc(var(--screenWide) * 0.5625);
	z-index: 10 !important;
}

.scrollPic .img{
	display: var(--displayBlock);
	margin: var(--noMarginPadding);
	padding: var(--noMarginPadding);
	background-repeat: var(--repeateBg);
	z-index: 10 !important;
}


.containerDiashow{
	position: var(--posAbsolute);
	height: calc(var(--screenWide) * 0.5625) !important;
}

.scrollPic:nth-child(1) {
	background-image: var(--scrollPicImage1);
	background-size: var(--scrollPicSize);
	background-repeat: var(--repeateBg);
	background-position: bottom;
	overflow: var(--overflowHidden);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	z-index: 10 !important;
}

.scrollPic:nth-child(2) {
	background-size: var(--scrollPicSize);
	background-repeat: var(--repeateBg);
	background-position: bottom;
	user-select: var(--userSelect);
	height: var(--screenHeight);
	overflow: var(--overflowHidden);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	z-index: 10 !important;
}
.scrollPic:nth-child(3) {
	background-image: var(--scrollPicImage3);
	background-size: var(--scrollPicSize);
	background-repeat: var(--repeateBg);
	background-position: bottom;
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	z-index: 10 !important;
}

.scrollPic:nth-child(4) {
	background-image: var(--scrollPicImage4);
	background-size: var(--scrollPicSize);
	background-color: var(--blueScrollPic);
	background-blend-mode: overlay;
	background-repeat: var(--repeateBg);
	background-position: top;
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	z-index: 10 !important;
}

.scrollPic:nth-child(2) .img:nth-child(1) {
	position: var(--posAbsolute);
	transform: translateZ(-436px) translateX(-3%) translateY(4%) scale(22%);
	-webkit-transform: translateZ(-436px) translateX(-3%) translateY(4%) scale(0.22);
	filter:blur(6.5px);
	transform-style: var(--animiTransformStyle);
	-webkit-transform-style: var(--animiTransformStyle);
	z-index: 10 !important;	
}

.scrollPic:nth-child(2) .img:nth-child(2) {
	position: var(--posAbsolute);
	transform: translateZ(-300px) translateX(45%) translateY(32%) scale(30.7%);
	-webkit-transform: translateZ(-300px) translateX(45%) translateY(32%) scale(0.307);
	filter: blur(4.68px);
	transform-style: var(--animiTransformStyle);
	-webkit-transform-style: var(--animiTransformStyle);
	z-index: 10 !important;
}

.scrollPic:nth-child(2) .img:nth-child(3) {
	position: var(--posAbsolute);
	transform: translateZ(-220px) translateX(8%) translateY(-42%) scale(45%);
	-webkit-transform: translateZ(-220px) translateX(8%) translateY(-42%) scale(0.45);
	filter: blur(2.75px);
	transform-style: var(--animiTransformStyle);
	-webkit-transform-style: var(--animiTransformStyle);
	z-index: 10 !important;	
}

.scrollPic:nth-child(2) .img:nth-child(4) {
	position: var(--posAbsolute);
	transform: translateZ(-100px) translateX(47%) translateY(-18%) scale(75%);
	-webkit-transform: translateZ(-100px) translateX(47%) translateY(-18%) scale(0.75);
	filter: blur(1.34px);
	transform-style: var(--animiTransformStyle);
	-webkit-transform-style: var(--animiTransformStyle);
	z-index: 10 !important;
}

.scrollPic:nth-child(2) .img:nth-child(5) {
	position: var(--posAbsolute);
	transform: translateZ(-20px) translateX(25%) translateY(0%) scale(100%);
	-webkit-transform: translateZ(-20px) translateX(25%) translateY(0%) scale(1);
	transform-style: var(--animiTransformStyle);
	-webkit-transform-style: var(--animiTransformStyle);
	z-index: 10 !important;
}

.scrollPic:nth-child(2) .img:nth-child(6){
	position: var(--posAbsolute);
	transform: translateZ(100px) translateX(-22%) translateY(68%) scale(135%);
	-webkit-transform: translateZ(100px) translateX(-22%) translateY(68%) scale(1.35);
	filter: blur(2.68px);
	transform-style: var(--animiTransformStyle);
	-webkit-transform-style: var(--animiTransformStyle);
	z-index: 10 !important;	
}

.scrollPic:nth-child(2) .img{
	background-image: var(--scrollPicImage2);
	width: var(--maxWidth);
	height: 100%;
	overflow-y: var(--overflowCut) !important;
	z-index: 10 !important;	
}

.Title {
	position: var(--posRelative);
	top: var(--titleTop);
	text-align: var(--titleAlign) !important;
	font-family: var(--mainFont);
	font-size: var(--titleFontSize);
	left: var(--titleLeft);
	display: var(--displayInlineBlock);
	vertical-align: var(--titleVAlign) !important;
	width: var(--titleWidth);
	height: var(--titleHeight);
	visibility: var(--show);
	color: var(--parentValue) !important;
	-moz-hyphens: var(--hyphens);
	-o-hyphens: var(--hyphens);
	-ms-hyphens: var(--hyphens);
	hyphens: var(--hyphens);
	z-index: 16;
}

#ueber {
	height: var(--screenHeight);
	overflow-y: var(--overflowAuto);
	position: var(--posRelative);
	top: 1em;
}

.modal{
	background-color: rgba(0,0,0,0.75);
	backdrop-filter: blur(2.2px);
	width: var(--maxWidth);
	height: var(--maxHeight);
	display: var(--displayNone);
	opacity: var(--noTransparent);
	position: var(--posFixed);
	top: var(--topLeft);
	left: var(--topLeft);
	transition: var(--transitionFaster);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
}

footer {
	position: var(--posFixed);
	bottom: 0;
	background-color: var(--colorDrkGrey);
	background-image: var(--footerBGColor);
	display: var(--displayBlock);
	width: var(--maxWidth);
	z-index: 100;
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
}


footer .footerText {
	text-align: center;
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);

}

::scrollbar {
	width: 4px;
	box-shadow: 0.25em -0.5em 0.5em rgba(0,0,0,0.75);
}

::scrollbar:hover {
	width: 12px;
}


::scrollbar:horizontal {
	height:5px;
	box-shadow: 0.25em -0.5em 0.5em rgba(0,0,0,0.75);
}

::scrollbar:horizontal:hover {
	height: 13px;
}


::scrollbar-button {
	width: 5px;
	height: 10px;
}

::scrollbar-button:hover {
	color: #000000;
	width: 12px;
	height: 24px;
}

::scrollbar-button:horizontal {
	width: 10px;
	height: 5px;
}

::scrollbar-button:horizontal:hover {
	color: #000000;
	height: 13px;
	width: 26px;
}

::scrollbar-track {
	background: var(--colorDrkGrey);
	box-shadow: 0px 0px 0px;
	border-radius: var(--borderRadiusSmall);
}

::scrollbar-track:horizontal {
	background: var(--colorDrkGrey);
	box-shadow: 0px 0px 0px;
	border-radius: var(--borderRadiusSmall);
}


::scrollbar-thumb {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(0,0,0,0.75);
}

::scrollbar-thumb:horizontal {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(0,0,0,0.75);
}

::scrollbar-thumb:hover {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(255,255,255,0.75);
}

::scrollbar-thumb:horizontal:hover {
	background: var(--colorBlueLgth);
	border: var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(255,255,255,0.75);
}


::-webkit-scrollbar {
	width: 4px;
	box-shadow: 0.25em -0.5em 0.5em rgba(0,0,0,0.75);
}

::-webkit-scrollbar:hover {
	width: 12px;
}


::-webkit-scrollbar:horizontal {
	height:5px;
	box-shadow: 0.25em -0.5em 0.5em rgba(0,0,0,0.75);
}

::-webkit-scrollbar:horizontal:hover {
	height: 13px;
}


::-webkit-scrollbar-button {
	width: 5px;
	height: 10px;
}

::-webkit-scrollbar-button:hover {
	color: #000000;
	width: 12px;
	height: 24px;
}

::-webkit-scrollbar-button:horizontal {
	width: 10px;
	height: 5px;
}

::-webkit-scrollbar-button:horizontal:hover {
	color: #000000;
	height: 13px;
	width: 26px;
}

::-webkit-scrollbar-track {
	background: var(--colorDrkGrey);
	box-shadow: 0px 0px 0px;
	border-radius: var(--borderRadiusSmall);
}

::-webkit-scrollbar-track:horizontal {
	background: var(--colorDrkGrey);
	box-shadow: 0px 0px 0px;
	border-radius: var(--borderRadiusSmall);
}


::-webkit-scrollbar-thumb {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(0,0,0,0.75);
}

::-webkit-scrollbar-thumb:horizontal {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(0,0,0,0.75);
}

::-webkit-scrollbar-thumb:hover {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(255,255,255,0.75);
}

::-webkit-scrollbar-thumb:horizontal:hover {
	background: var(--colorBlueLgth);
	border: var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(255,255,255,0.75);
}



::-moz-scrollbar {
	width: 4px;
	box-shadow: 0.25em -0.5em 0.5em rgba(0,0,0,0.75);
}

::-moz-scrollbar:hover {
	width: 12px;
}


::-moz-scrollbar:horizontal {
	height:5px;
	box-shadow: 0.25em -0.5em 0.5em rgba(0,0,0,0.75);
}

::-moz-scrollbar:horizontal:hover {
	height: 13px;
}


::-moz-scrollbar-button {
	width: 5px;
	height: 10px;
}

::-moz-scrollbar-button:hover {
	color: #000000;
	width: 12px;
	height: 24px;
}

::-moz-scrollbar-button:horizontal {
	width: 10px;
	height: 5px;
}

::-moz-scrollbar-button:horizontal:hover {
	color: #000000;
	height: 13px;
	width: 26px;
}

::-moz-scrollbar-track {
	background: var(--colorDrkGrey);
	box-shadow: 0px 0px 0px;
	border-radius: var(--borderRadiusSmall);
}

::-moz-scrollbar-track:horizontal {
	background: var(--colorDrkGrey);
	box-shadow: 0px 0px 0px;
	border-radius: var(--borderRadiusSmall);
}


::-moz-scrollbar-thumb {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(0,0,0,0.75);
}

::-moz-scrollbar-thumb:horizontal {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(0,0,0,0.75);
}

::-moz-scrollbar-thumb:hover {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(255,255,255,0.75);
}

::-moz-scrollbar-thumb:horizontal:hover {
	background: var(--colorBlueLgth);
	border: var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(255,255,255,0.75);
}


EOF

echo
echo Theme
echo
cat << EOF > /www/CaptivePortal/mobile.css

.scrollPic:not(:nth-child(2)) .containerOverlay{
	overflow-y: var(--overflowCut);
}

.containerOverlay:not(> .containerDiashow, .Diashow) {
	text-align: center;
	vertical-align: middle;
	padding: 0em 2.5em 0em 2.5em !important;
}

.contentOverlay:has(:not(a .bibleText)){
	min-height:  var(--factorHDVideo) + 'vw';
}

.Content {
	font-family: var(--infoFont);
	background: var(--bgTransparent);
	/*position: var(--posAbsolute);
	top: 0px; */
	color: var(--colorLgtGrey) !important;
	/*height: calc(100vh * 4);
	#background-image: var(--blueGradientLeft);
	#padding: 2.5em 2.5em 0em 2.5em !important;*/
	text-align: center;
	user-select: var(--userSelectYes);
	-webkit-user-select: var(--userSelectYes);
	-moz-user-select: var(--userSelectYes);
	-moz-hyphens: var(--hyphens);
	-o-hyphens: var(--hyphens);
	-ms-hyphens: var(--hyphens);
	hyphens: var(--hyphens);
	z-index: 15;
}

.ContentText{
	font-family: var(--mainFont);
	text-align: justify !important;
	word-break: break-word;
	background: var(--bgTransparent);
	backdrop-filter: var(--bgBlur);
	color: var(--colorLgtGrey) !important;
	height: auto;
	#background-image: var(--blueGradientLeft);
	padding: 6.5em 2.5em 2.5em 2.5em !important;
	user-select: var(--userSelectYes);
	-webkit-user-select: var(--userSelectYes);
	-moz-user-select: var(--userSelectYes);
	-o-user-select: var(--userSelectYes);
	-ms-user-select: var(--userSelectYes);
	-webkit-hyphens: var(--hyphens);
	-moz-hyphens: var(--hyphens);
	-o-hyphens: var(--hyphens);
	-ms-hyphens: var(--hyphens);
	hyphens: var(--hyphens);
	z-index: 16;
	
}

.ContentText::before, cite::before {
	position: var(--posRelative);
	font-size: 2.5em;
	vertical-align: bottom;
	content: '“';
	top: 0.35em;
	left: -0.15em;
	font-family: var(--fontBook);
}

.ContentText::after, cite::after {
	position: var(--posRelative);
	font-size: 2.5em;
	vertical-align: top;
	content: '”';
	top: 0em;
	left: 0em;
	font-family: var(--fontBook);
}

/*section.Overlay{
	left: 0;
	opacity: var(--noTransparent);
	position: var(--posRelative);
	display: var(--displayInlineBlock);
	#width: var(--screenWide);
	margin: auto;
	#top: calc(-28.125vw - 7.5em);
	left: 0px;
	text-align: center;
	vertical-align: middle;
	backdrop-filter: var(--bgBlur);
	#background-color: rgba(0,0,128,0.4);
	#padding-bottom: 8.5em;
	color: var(--colorLgtGrey);
	font-size: 20px;
	overflow-x: var(--overflowCut);
	-webkit-overflow-scrolling: auto;
	-webkit-overflow-x: var(--overflowCut);
	-webkit-overflow-y: var(--overflowCut);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
	text-select: var(--userSelect);
	z-index: 20;
}
*/
section.Overlay:nth-child(1) {
	height: -webkit-fill-available;
}

.scrollPic:nth-child(1) .containerOverlay{
	height: -webkit-fill-available;
}

section#ueber {
}


.modal{
	background-color: rgba(0,0,0,0.75);
	backdrop-filter: blur(2.2px);
	width: var(--maxWidth);
	height: var(--maxHeight);
	display: var(--displayNone);
	opacity: var(--noTransparent);
	position: var(--posFixed);
	top: var(--topLeft);
	left: var(--topLeft);
	transition: var(--transitionFaster);
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
}

footer {
	position: var(--posFixed);
	bottom: 0;
	background-color: var(--colorDrkGrey);
	background-image: var(--footerBGColor);
	display: var(--displayBlock);
	width: var(--maxWidth);
	z-index: 100;
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);
}


footer .footerText {
	text-align: center;
	user-select: var(--userSelect);
	-webkit-user-select: var(--userSelect);
	-moz-user-select: var(--userSelect);

}

::scrollbar {
	width: 4px;
	box-shadow: 0.25em -0.5em 0.5em rgba(0,0,0,0.75);
}

::scrollbar:hover {
	width: 12px;
}


::scrollbar:horizontal {
	height:5px;
	box-shadow: 0.25em -0.5em 0.5em rgba(0,0,0,0.75);
}

::scrollbar:horizontal:hover {
	height: 13px;
}


::scrollbar-button {
	width: 5px;
	height: 10px;
}

::scrollbar-button:hover {
	color: #000000;
	width: 12px;
	height: 24px;
}

::scrollbar-button:horizontal {
	width: 10px;
	height: 5px;
}

::scrollbar-button:horizontal:hover {
	color: #000000;
	height: 13px;
	width: 26px;
}

::scrollbar-track {
	background: var(--colorDrkGrey);
	box-shadow: 0px 0px 0px;
	border-radius: var(--borderRadiusSmall);
}

::scrollbar-track:horizontal {
	background: var(--colorDrkGrey);
	box-shadow: 0px 0px 0px;
	border-radius: var(--borderRadiusSmall);
}


::scrollbar-thumb {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(0,0,0,0.75);
}

::scrollbar-thumb:horizontal {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(0,0,0,0.75);
}

::scrollbar-thumb:hover {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(255,255,255,0.75);
}

::scrollbar-thumb:horizontal:hover {
	background: var(--colorBlueLgth);
	border: var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(255,255,255,0.75);
}


::-webkit-scrollbar {
	width: 4px;
	box-shadow: 0.25em -0.5em 0.5em rgba(0,0,0,0.75);
}

::-webkit-scrollbar:hover {
	width: 12px;
}


::-webkit-scrollbar:horizontal {
	height:5px;
	box-shadow: 0.25em -0.5em 0.5em rgba(0,0,0,0.75);
}

::-webkit-scrollbar:horizontal:hover {
	height: 13px;
}


::-webkit-scrollbar-button {
	width: 5px;
	height: 10px;
}

::-webkit-scrollbar-button:hover {
	color: #000000;
	width: 12px;
	height: 24px;
}

::-webkit-scrollbar-button:horizontal {
	width: 10px;
	height: 5px;
}

::-webkit-scrollbar-button:horizontal:hover {
	color: #000000;
	height: 13px;
	width: 26px;
}

::-webkit-scrollbar-track {
	background: var(--colorDrkGrey);
	box-shadow: 0px 0px 0px;
	border-radius: var(--borderRadiusSmall);
}

::-webkit-scrollbar-track:horizontal {
	background: var(--colorDrkGrey);
	box-shadow: 0px 0px 0px;
	border-radius: var(--borderRadiusSmall);
}


::-webkit-scrollbar-thumb {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(0,0,0,0.75);
}

::-webkit-scrollbar-thumb:horizontal {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(0,0,0,0.75);
}

::-webkit-scrollbar-thumb:hover {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(255,255,255,0.75);
}

::-webkit-scrollbar-thumb:horizontal:hover {
	background: var(--colorBlueLgth);
	border: var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(255,255,255,0.75);
}



::-moz-scrollbar {
	width: 4px;
	box-shadow: 0.25em -0.5em 0.5em rgba(0,0,0,0.75);
}

::-moz-scrollbar:hover {
	width: 12px;
}


::-moz-scrollbar:horizontal {
	height:5px;
	box-shadow: 0.25em -0.5em 0.5em rgba(0,0,0,0.75);
}

::-moz-scrollbar:horizontal:hover {
	height: 13px;
}


::-moz-scrollbar-button {
	width: 5px;
	height: 10px;
}

::-moz-scrollbar-button:hover {
	color: #000000;
	width: 12px;
	height: 24px;
}

::-moz-scrollbar-button:horizontal {
	width: 10px;
	height: 5px;
}

::-moz-scrollbar-button:horizontal:hover {
	color: #000000;
	height: 13px;
	width: 26px;
}

::-moz-scrollbar-track {
	background: var(--colorDrkGrey);
	box-shadow: 0px 0px 0px;
	border-radius: var(--borderRadiusSmall);
}

::-moz-scrollbar-track:horizontal {
	background: var(--colorDrkGrey);
	box-shadow: 0px 0px 0px;
	border-radius: var(--borderRadiusSmall);
}


::-moz-scrollbar-thumb {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(0,0,0,0.75);
}

::-moz-scrollbar-thumb:horizontal {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(0,0,0,0.75);
}

::-moz-scrollbar-thumb:hover {
	background: var(--colorBlueLgth);
	border:  var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(255,255,255,0.75);
}

::-moz-scrollbar-thumb:horizontal:hover {
	background: var(--colorBlueLgth);
	border: var(--borderMiddle);
	border-radius: var(--borderRadiusSmall);
	box-shadow: 0em 0em 0.5em rgba(255,255,255,0.75);
}

@media screen and (orientation: landscape)  {
	header h1:before {
		content: var(--headerH1);
	}

	header h3:before {
		content: var(--headerH3);
	}

	
}

/*Ipad Portrait */
@media screen and (orientation: portrait)  {
	header {
		background-image: var(--headerBGImage);
		background-color: var(--colorDrkGrey);
		background-repeat: var(--bgRepeate);
		backdrop-filter: var(--bgBlur);
		background-size: var(--headerBGSize);
		color: var(--colorLgtGrey);
		background-position-x: var(--headerBGPosX);
		background-position-y: var(--headerBGPosY);
	}

	header h1:before {
		content: var(--headerH1Small);

	}
	
	header h1{
		margin-block-end: 0em !important;
	}

	header h3:before {
		content: var(--headerH3Small);
	}

	#topMenu {
		top: var(--menuTopLow) !important;
	}

	#Main {
		overflow-x: clip;
		overflow-y: scroll;
	}

/*	.scrollPic{
		overflow-x: var(--overflowHidden);
		scroll-snap-align: var(--scrollSnapAlign);
		scroll-behavior: var(--scrollBehaviorSmooth);
		scroll-snap-stop: var(--scrollSnapStop);
		height: var(--screenHeight);
		width: var(--screenWide);
		transition: var(--transitionFast);
		display: var(--displayBlock);
	}
*/
	.scrollPic .img{
		display: var(--displayBlock);
		margin: var(--noMarginPadding);
		padding: var(--noMarginPadding);
		background-repeat: var(--repeateBg);
		z-index: 10 !important;
	}

	figure.image {
		overflow-x: clip !important;
		height: inherit;
		width: var(--screenWide) !important;
		border: 2px solid #eeee00;
		padding: var(--noMarginPadding);
		margin: var(--noMarginPadding);
		transform: translateZ(-1px);
	}

	.scrollPic:nth-child(1) {
		background-size: 1024px 576px;
		background-position-y: var(--headerHeight);
		height: calc(56.25 * 10.24px + var(--headerHeight)) !important;
		background-image: var(--scrollPicImage1);
		background-repeat: var(--repeateBg);
		background-position: bottom;
		user-select: var(--userSelect);
		-webkit-user-select: var(--userSelect);
		-moz-user-select: var(--userSelect);
		z-index: 10 !important;
	}


/*	.scrollPic:nth-child(2) {
		background-size: var(--scrollPicSize);
		background-repeat: var(--repeateBg);
		background-position: bottom;
		user-select: var(--userSelect);
		height: var(--screenHeight);
		/*overflow: var(--overflowHidden);*/
		overflow-x: clip;
		/*overflow-y: clip;*/
		-webkit-user-select: var(--userSelect);
		-moz-user-select: var(--userSelect);
		z-index: 10 !important;
	}
*/
	.scrollPic:nth-child(2) .img{
		background-image: var(--scrollPicImage2);
		width: var(--maxWidth);
		height: 100%;
		overflow-y: var(--overflowCut) !important;
		z-index: 10 !important;	
	}

	.scrollPic:nth-child(2) .img:nth-child(1) {
		position: var(--posAbsolute);
		transform: translateZ(-436px) translateX(-3%) translateY(4%) scale(22%);
		-webkit-transform: translateZ(-436px) translateX(-3%) translateY(4%) scale(0.22);
		filter:blur(6.5px);
		transform-style: var(--animiTransformStyle);
		-webkit-transform-style: var(--animiTransformStyle);
		z-index: 10 !important;	
	}

	.scrollPic:nth-child(2) .img:nth-child(2) {
		position: var(--posAbsolute);
		transform: translateZ(-300px) translateX(45%) translateY(32%) scale(30.7%);
		-webkit-transform: translateZ(-300px) translateX(45%) translateY(32%) scale(0.307);
		filter: blur(4.68px);
		transform-style: var(--animiTransformStyle);
		-webkit-transform-style: var(--animiTransformStyle);
		z-index: 10 !important;
	}

	.scrollPic:nth-child(2) .img:nth-child(3) {
		position: var(--posAbsolute);
		transform: translateZ(-220px) translateX(8%) translateY(-42%) scale(45%);
		-webkit-transform: translateZ(-220px) translateX(8%) translateY(-42%) scale(0.45);
		filter: blur(2.75px);
		transform-style: var(--animiTransformStyle);
		-webkit-transform-style: var(--animiTransformStyle);
		z-index: 10 !important;	
	}

	.scrollPic:nth-child(2) .img:nth-child(4) {
		position: var(--posAbsolute);
		transform: translateZ(-100px) translateX(47%) translateY(-18%) scale(75%);
		-webkit-transform: translateZ(-100px) translateX(47%) translateY(-18%) scale(0.75);
		filter: blur(1.34px);
		transform-style: var(--animiTransformStyle);
		-webkit-transform-style: var(--animiTransformStyle);
		z-index: 10 !important;
	}

	.scrollPic:nth-child(2) .img:nth-child(5) {
		position: var(--posAbsolute);
		transform: translateZ(-20px) translateX(25%) translateY(0%) scale(100%);
		-webkit-transform: translateZ(-20px) translateX(25%) translateY(0%) scale(1);
		transform-style: var(--animiTransformStyle);
		-webkit-transform-style: var(--animiTransformStyle);
		z-index: 10 !important;
	}

	.scrollPic:nth-child(2) .img:nth-child(6){
		position: var(--posAbsolute);
		transform: translateZ(100px) translateX(-22%) translateY(68%) scale(135%);
		-webkit-transform: translateZ(100px) translateX(-22%) translateY(68%) scale(1.35);
		filter: blur(2.68px);
		transform-style: var(--animiTransformStyle);
		-webkit-transform-style: var(--animiTransformStyle);
		z-index: 10 !important;	
	}

	
	.scrollPic:nth-child(3) {
		background-color: #000088;
		height: calc(56.25 * 10.24px + var(--headerHeight)) !important;
		background-image: var(--scrollPicImage3);
		background-size: var(--scrollPicSize);
		background-repeat: var(--repeateBg);
		background-position: bottom;
		user-select: var(--userSelect);
		-webkit-user-select: var(--userSelect);
		-moz-user-select: var(--userSelect);
		z-index: 10 !important;
	}

	.scrollPic:nth-child(4) {
		background-image: var(--scrollPicImage4);
		background-size: var(--scrollPicSize);
		background-color: var(--blueScrollPic);
		background-blend-mode: overlay;
		background-repeat: var(--repeateBg);
		background-position: top;
		user-select: var(--userSelect);
		-webkit-user-select: var(--userSelect);
		-moz-user-select: var(--userSelect);
		z-index: 10 !important;
	}

	
	.Diashow1 {
		height: calc(var(--screenWide) * 0.5625) !important;
		width: calc(var(--screenWide) * 9) !important;
		border: 3px solid green;
		margin: var(--mainMargin) !important;
		top: var(--topLeft) !important;
		/*float: var(--flowLeft);*/
		/*text-align: var(--textLeft) !important;*/
		position: var(--posRelative);
		background-color: rgba(128,128,128,0.5);
		display: var(--displayInlineBlock);
		scroll-snap-type: var(--scrollSnapXMan);
		scroll-behavior: var(--scrollBehaviorSmooth);
		overflow-x: var(--overflowScroll);
		overflow-y: var(--overflowCut);
		scroll-snap-stop: var(--scrollSnapStop);
	}

	.txt{
		font-size: 48pt;
		line-height: 1;
		top: 4em;
		position: relative;
		display: inline;
	}
}
/* Phone Portrait*/
@media screen and (min-height: 600px) and (max-width: 668px) and (orientation: portrait)  {

	:root{
		font-weight: var(--fontWeight);
	}
	header {
		background-image: var(--blueGradientRight) !important;
		background-color: var(--colorDrkGrey);
		background-repeat: var(--bgRepeate);
		backdrop-filter: var(--bgBlur);
		color: var(--colorLgtGrey);
		background-position-x: var(--headerBGPosXSmall);
		background-position-y: var(--headerBGPosYSmall);
		background-size: auto !important;
		height: var(--headerHeightLarge);
	}
	
	header h1:before {
		content: var(--headerH1Small);
	}

	header h1{
		margin-block-end: -0.25em !important;
	}

	header h3:before {
		content: var(--headerH3Small);
	}

	header h4{
		display: none;
	}

	#topMenu {
		top: var(--menuTopLow) !important;
		border-radius: var(--borderRadius);
	}

}

@media screen and (min-width: 600px) and (max-height: 668px) and (orientation: landscape)  {
	:root {
		--headerHeight: var(--headerHeightSmall);
		font-weight: var(--fontWeight);
	}

	header {
		height: var(--headerHeightSmall);
		background-image: var(--blueGradientRight);
		background-color: var(--colorDrkGrey);
		background-repeat: var(--bgRepeate);
		backdrop-filter: var(--bgBlur);
		color: var(--colorLgtGrey);
		background-position-x: var(--headerBGPosXSmall);
		background-position-y: var(--headerBGPosYSmall);
		background-size: auto;
	}

	header h1:before {
		content: var(--headerH1);
	}

	header h3:before {
		content: var(--headerH3);
	}

	#topMenu {
		top: var(--menuTop) !important;
		border-radius: var(--borderRadius);
	}

}

/* Window PC Landscapemode 16:9 */

@media screen and (min-width:1280px) and (max-width: 1920px) and (min-height: 720px) and (max-height: 1080px) and (orientation: landscape) and (max-resolution: 192dpi)   {
	header {
		background-position-x: var(--headerBGPosXBig);
	
	}
	header h1:before {
		content: var(--headerH1);
	}

	header h3:before {
		content: var(--headerH3);
	}
}


@media screen and (min-width:689px) and (max-width: 1280px) and (min-height: 720px) and (max-height: 1080px) and (orientation: landscape) and (max-resolution: 192dpi)   {
	header {
		background-position-x: 2.5%;
	}

	header h1:before {
		content: var(--headerH1);
	}

	header h3:before {
		content: var(--headerH3);
	}
	
	#topMenu {
		top: var(--menuTopTop) !important;
		border-radius: var(--borderRadius);
	}

}


EOF

echo
echo mobile
echo

cat << EOF > /www/CaptivePortal/index.htm

<!DOCTYPE html>
<html lang="de">
	
	<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
	<meta http-equiv="Pragma" content="no-cache">
	<meta http-equiv="Expires" content="1">
	<meta http-equiv="content-type" content="text/html, charset=utf-8">
	<meta charset="utf-8">	
	<meta name="Description" content="C&grave;Movie das Hoffnungsportal mit Videostreaming. Als den Gegenpol zu Panik und Chaos seitens der Medien und Politik">
	<link rel="icon" type="image/x-icon" href="/pic/favicon.ico">
	<link rel="alternate" href="index_en.htm" hreflang="en">
	<link href="theme_variable.css" rel="stylesheet" type="text/css" />	
	<link href="theme.css" rel="stylesheet" type="text/css" />
	<link href="mobile.css" rel="stylesheet" type="text/css" />
	<!--link href="mobile_org.css" rel="stylesheet" type="text/css" /-->
	<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, viewport-fit=cover">
	<script src="framewrk.js"></script>
	<head>
		<title>C&grave;Movie das Hoffnungsportal</title>
	</head>	

	<body onload="" onresize="">
		
		<header class="header" id="headerHidden">
			
			<div class="headerText">
			<h1>
				<!-- Text insert by css Tag '.header h1' -->
			</h1>
			<h3>
				<!-- Text insert by css Tag '.header h3' -->
			</h3>
			<h4>
				<a href ="https://www.bibleserver.com/LUT/Offenbarung13%2C1" target="_blank">Sei vorbereitet, auf das was kommt</a>.
			</h4>
			</div>

			<a href="index.htm#explainEnd" id="NaviDown">
				<div>
					&#9660;
				</div>
			</a>
			
		</header>

	
		<nav id="topMenu" class="menu">
    			<a class="containerIcon" href="index.htm#start">
				<div class="iconMenu">
        				<div></div>
        				<div></div>
        				<div></div>  
    				</div>
				<div class="iconText">
					Men&uuml;
				</div>
			</a>
			<ul>
        	        	<li>
					<a href="index.htm#explainStart">Beweggr&uuml;nde</a>
				</li>
				<li><a href="index.htm#mainDiashow">Filme / Podcast</a>
				</li>
				<li>
					<a href="index.htm#Pos7">Glaube</a>
					<ul>
    						<li><a href="index.htm#Pos7">Gottesdienste</a></li>
						<li><a href="index.htm#Pos5">Vortr&auml;ge</a></li>
						<li><a href="prophetie.htm">Prophetien</a></li>
    						<li><a href="index.htm#GScripte">Scripte</a></li>
    						
					</ul>
				</li>   
        			<li>
					<a href="index.htm#Pos5">IT / Multimedia</a> 
  					<ul>
      						<li><a href="https://www.cyberandi.de/DatenschutzMeinungsfreiheit" target="_blank">Datenschutz</a></li>
      						<li><a href="https://www.cyberandi.de" target="_blank">IT-Security / Multimedia</a></li> 
  					</ul>
	 			</li>
        			<li>
					<a href="index.htm#Pos1">Krisenvorsorge</a> 
					<ul>
    						<li><a href="index.htm#Pos1">Beitr&auml;ge</a></li>
    						<li><a href="index.htm#KScripte">Scripte</a></li> 
					</ul>
				</li>
				<li>
					Nachschlagewerke 
  					<ul>
      						<li><a href="https://www.wikipedia.de" target="_blank">Wikipedia</a></li>
      						<li><a href="https://www.bibleserver.com" target="_blank">Bibel</a></li> 
  					</ul>
	 			</li>
				<li>
					<a href="#impressum">Impressum</a>
				</li>

    			</ul>
		</nav>
		<div id="Main">	
			<main class="Content" id="start">
				<div class="scrollPic">
					<div class="containerOverlay">
						<section class="Overlay">
							<div class="contentOverlay">
								<a href="https://www.bibleserver.com/LUT/Johannes16%2C33" target="_blank" class="containerBibleText">		
									<h1 class="bibleText">Jesus spricht:<br>
										<cite>In der Welt habt Ihr Angst;<br>
											aber seid getrost,
											<br>ich habe die Welt &uuml;berwunden</cite>														<br>
										Johannes 16:33<br>
										<img src="pic/Bibelserver.png"> 
									</h1>
								
								</a>
								<a href ="https://www.bibleserver.com/LUT/Offenbarung13%2C1" target="_blank" class="containerBibleText">
									<h1 class="bibleText"><br>
										Sei vorbereitet, auf das was kommt.<br><br>
										<br>
										Siehe: Offenbarung 13:1<br>
										<img src="pic/Bibelserver.png"> 
									</h1>
								</a>
							</div>
						</section>	
					</div>
				</div>

				<div class="scrollPic" id="explainStart">
					<figure class="image">
						<div class="img"> </div>
						<div class="img"> </div>
						<div class="img"> </div>
						<div class="img"> </div>
						<div class="img"> </div>
						<div class="img"> </div>
					</figure>
					<div class="containerOverlay">
						<section class="Overlay" id="ueber">
							<article class="ContentText">Noch kurz eine Erkl&auml;rung zu meinem Glaubensverst&auml;ndnis. Gott Vater hat, schon vor der Sch&ouml;pfung der Erde, einen Plan f&uuml;r die ganze Menschheit. Die Menschen sind als Kinder Gottes erschaffen worden. Aber durch die S&uuml;nde, also das Essen der Frucht, des Baumes der Erkenntnisse, durch Adam und Eva, kam die Trennung von der pers&ouml;nlichen und direkten Begegnung mit Gott Vater. Deshalb sind wir alle Menschen, als Nachfahren Adam und Evas, als S&uuml;nder (von Gott getrennt) geboren. Der Sch&ouml;pfer wollte, da&szlig; wir seine Kinder sein sollen. Daher sind wir die Akteure, welche nach eigenem Willen und Handel, diesen Plan beschleunigen, ausbremsen oder um Verschiebung bitten k&ouml;nnen. Z.B. Bin ich mir sicher, g&auml;be es nicht Nebukadnezar, so h&auml;tte es einen anderen Herrscher gegeben, der die Juden verfolgt und Daniel und seine Freunde vernichten wollte. W&auml;re der Pharao Mose nicht gefolgt, h&auml;tte sicherlich ein anderer K&ouml;nig Mose ins Rote-Meer verfolgt und w&uuml;rde dort umkommen. Genauso sehe ich es mit der neusten Geschichte des 20. Jahrhunderts. H&auml;tte es Hitler und seine Gefolgschaft nicht gegeben, h&auml;tte vermutlich ein Lenin, Mussolini oder sonstiger Diktator die Welt in Chaos, Aufruhr und in die schlimmsten Verbrechen der Menschheit gef&uuml;hrt. Da Gott Vater es zu unserem Heil will. Damit wir verstehen und begreifen, er will uns erl&ouml;sen und in die ewige Verbundenheit und Seligkeit mit Ihm bringen. Deshalb hat er, auch vor ca. 2000 Jahren, seinen Sohn Jesus Christus, als Jungfrauengeburt, auf die Erde geschickt, damit dieser s&uuml;ndfrei, stellvertretend f&uuml;r all unsere Fehler, Vergehen und S&uuml;nden, am Kreuz sterben konnte. So da&szlig; die an Ihn glauben und Ihm nachfolgen, f&uuml;r immer bei Ihm sein k&ouml;nnen. Auch denke ich, da&szlig; Leute wie Abraham, Noah, Jona, Luther, Pabst Benedikt XVI und Andere von Gott eingesetzt wurden. W&auml;ren es nicht diese Menschen gewesen, so w&auml;ren es andere gewesen, die diese Taten in Namen Gottes h&auml;tten ausf&uuml;hren m&uuml;ssen...</article>
											
						</section>
					</div>
				</div>
				<div class="scrollPic" id="mainDiashow">
					<div class="containerOverlay">
						<section class="Overlay containerDiashow" id="mainDiashow">
							<div class="Diashow1" >
								<div class="contSlide" id="Pos1">
									<div class="txt">
										Pos 1
									</div>
								</div>
								<div class="contSlide" id="Pos2">
									<div class="txt">
										Pos 2
									</div>
								</div>
								<div class="contSlide" id="Pos3">
									<div class="txt">
										Pos 3
									</div>
								</div>
								<div class="contSlide" id="Pos4">
									<div class="txt">
										Pos 4
									</div>
								</div>
								<div class="contSlide" id="Pos5">
									<div class="txt">
										Pos 5
									</div>
								</div>
								<div class="contSlide" id="Pos6">
									<div class="txt">
										Pos 6
									</div>
								</div>
								<div class="contSlide" id="Pos7">
									<div class="txt">
										Pos 7
									</div>
								</div>
								<div class="contSlide" id="Pos8">
									<div class="txt">
										Pos 8
									</div>
			
								</div>
								<div class="contSlide" id="Pos9">
									<div class="txt">
										Pos 9
									</div>
								</div>
		
							</div>
						</section>
					</div>
				</div>	
				<div class="scrollPic" id="explainEnd">
					<div class="containerOverlay">
						<section class="Overlay">
							<article class="ContentText">... Selbst die Wiedervereinigung Deutschlands, mit dem Zerfall der UdSSR sind f&uuml;r mich ein Zeichen der Vergebung der S&uuml;nden des 3. Reiches. Und damit es der letzte Ungl&auml;ubige begreift, wurde Benedikt XVI zum Papst ernannt. Auch denke ich, da&szlig; die aktuellen Ereignisse in Europa (Seuchen, Pandemien, Migrationspolitik, Wirtschaftskrise, Konflikte, Kriege, Naturkatastrophen usw.) auch von Gott Vater zugelassen werden. Damit wir Menschen wieder einmal an die Offenbarung erinnert werden. Da er will, da&szlig; wir endlich in Einklang, Freude und Liebe mit Ihm leben. Auch sehe ich, da&szlig; eigene Leben so, da&szlig; wir hier auf der Welt sind, unsere Berufung / Begabung / Charisma zu finden, um es dann im Reich Gottes f&uuml;r immer verwalten zu d&uuml;rfen. So zu sagen als Bew&auml;hrung f&uuml;r unsere Aufgabe / Position im Reich Gottes, sobald wir an Jesus glauben. Jeder kann und darf entscheiden, ob er es will, aber wenn nicht er, wird es ein Anderer machen m&uuml;ssen. Aber wer Jesus als Retter und Erl&ouml;ser sieht und sich als Werkzeug des Hl. Geistes hingibt, darf dann den Weg gehen. Auch denke ich, da&szlig; es in der gegengesetzten Richtung &auml;hnlich ist. Wer Jesus und Gott verneint, wird vom Satan oder Anti-Christen benutzt, um dann den von Gott gewollten B&ouml;sen Gegenpart voranzubringen. Auch da hat jeder seinen eigenen Willen und es kann dann auch eine andere Person sein. Aber wenn wir unsere Aufgaben, Erf&uuml;llung der Mission Gottes usw. getan haben, wird Gott uns aus dem diesigen Leben entziehen und uns in die Position zu versetzen, welche wir in Ewigkeit mit Ihm haben werden. Daher ist der Tod, immer nur eine Gl&uuml;ckliche Position, f&uuml;r den Sterbenden auf Erden, denn er ist gerade auf dem Weg zum Herrn. Nur f&uuml;r die weltlich orientierten Freunde und Angeh&ouml;rigen ist dies ein gro&szlig;er Schmerz und Verlust. Daher w&uuml;nsche ich uns die Weisheit und den Durchblick des Heiligen Geistes, damit wir erkennen was Jesus von uns will.</article>	
						</section>
					</div>
				</div>
			</main>
		</div>
		<footer>
			<aside>		
				<div id="impressum" class="modal">
					<div class="Info">
						<a href="#start" class="buttonModal" onclick="">x</a>
						<div class="InfoText">
							<p>Verantwortlicher im Sinne des Pressegesetzes:
							</p>
							<address>Stawinski Andreas<br>
							Jaspersallee 22<br>
							81245 M&uuml;nchen<br>
							Telefon: 089/74792- 201<br>
							Telefax: 089/74792- 202<br>
							E-Mail: cyberandi&#00064;outlook.de <br>
							Web: <a href="https://www.cyberandi.de" target="_blank">https://cyberandi.tumblr.com</a>
							</address>
							<p>
							Diese Seite nutzt <a href="https://www.torproject.org/">DNS over TOR(onion)<img src="pic/tor.png"></a>. Deshalb gibt es hier keine Zensur durch URL-Filter, der Povider(Telekom, Vodafone, O2 usw.), Geheimdienste und Regierungen.<br>
							Sondern nur einen Porno- und Werbungsblocker, der gegen das Tracking durch Google, Apple, Amazon, Facebook, Otto Group, VG Wort und der Sendeanstalten usw. fungiert.<br>
							Die Technik dahinter ist die Freeware <a href="https://github.com/CyberAndi/CyberSecurity-Box" target="_blank">CyberSecurity-Box</a> <a href="https://github.com/CyberAndi/CyberSecurity-Box" target="_blank"><img src="pic/csb.png"></a>.
							</p>
							Bitte lesen Sie auch die <a href="#datenschutz" onclick="datenschutz();">Datenschutzbestimmungen</a> sowie den <a href="#haftung" onclick="haftung();">Hauftungsausschluss</a> durch.
						</div>
					</div>
				</div>
				<div id="datenschutz" class="modal">
					<div class="Info">
						<a href="#start" class="buttonModal" onclick="">x</a>
						<div class="InfoText">
							<p>Die Nutzung unserer Webseite ist in der Regel ohne Angabe personenbezogener Daten m&ouml;glich. Soweit auf unseren Seiten personenbezogene Daten (beispielsweise name, Anschrift oder eMail-Adreßen) erhoben werden, erfolgt dies, soweit m&ouml;glich, stets auf freiwilliger Basis. Diese Daten werden ohne Ihre ausdr&uuml;ckliche Zustimmung nicht an Dritte weitergegeben.
							</p>
							<p>Wir weisen darauf hin, daß die Daten&uuml;bertragung im Internet (z.B. bei der Kommunikation per E-Mail) Sicherheitsl&uuml;cken aufweisen kann. Ein l&uuml;ckenloser Schutz der Daten vor dem Zugriff durch Dritte ist nicht m&ouml;glich.
							</p
			
							<p>Der Nutzung von im Rahmen der Impreßumspflicht ver&ouml;ffentlichten Kontaktdaten durch Dritte zur &uuml;bersendung von nicht ausdr&uuml;cklich angeforderter Werbung und Informationsmaterialien wird hiermit ausdr&uuml;cklich widersprochen. Die Betreiber der Seiten behalten sich ausdr&uuml;cklich rechtliche Schritte im Falle der unverlangten Zusendung von Werbeinformationen, etwa durch Spam-Mails, vor.
							</p>
							<p>
								Diese Seite nutzt <a href="https://www.torproject.org/">DNS over TOR(onion)<img src="pic/tor.png"></a>. Deshalb gibt es hier keine Zensur durch URL-Filter, der Povider(Telekom, Vodafone, O2 usw.), Geheimdienste und Regierungen.<br>
								Sondern nur einen Porno- und Werbungsblocker, der gegen das Tracking durch Google, Apple, Amazon, Facebook, Otto Group, VG Wort und der Sendeanstalten usw. fungiert.<br>
								Die Technik dahinter ist die Freeware <a href="https://github.com/CyberAndi/CyberSecurity-Box" target="_blank">CyberSecurity-Box</a> <a href="https://github.com/CyberAndi/CyberSecurity-Box" target="_blank"><img src="pic/csb.png"></a>.
							</p>
							<p>Datenschutzerkl&auml;rung f&uuml;r die Nutzung von Facebook-Plugins (Like-Button)<br>
	
								Auf unseren Seiten sind Plugins des sozialen Netzwerks Facebook (“Meta”,“Facebook”,Meta Platforms Inc., 1601 Willow Road, Menlo Park, California, 94025, USA) integriert. Die Facebook-Plugins erkennen Sie an dem Facebook-Logo oder dem “Like-Button” (“Gef&auml;llt mir”) auf unserer Seite. Eine &uuml;bersicht &uuml;ber die Facebook-Plugins finden Sie hier: <a href="https://developers.facebook.com/docs/plugins/" target="_blank">https://developers.facebook.com/docs/plugins/</a>.
								Wenn Sie unsere Seiten besuchen, wird &uuml;ber das Plugin eine direkte Verbindung zwischen Ihrem Browser und dem Facebook-Server hergestellt. Facebook erh&auml;lt dadurch die Information, daß Sie mit Ihrer IP-Adreße unsere Seite besucht haben. Wenn Sie den Facebook “Like-Button” anklicken w&auml;hrend Sie in Ihrem Facebook-Account eingeloggt sind, k&ouml;nnen Sie die Inhalte unserer Seiten auf Ihrem Facebook-Profil verlinken. Dadurch kann Facebook den Besuch unserer Seiten Ihrem Benutzerkonto zuordnen. Wir weisen darauf hin, daß wir als Anbieter der Seiten keine Kenntnis vom Inhalt der &uuml;bermittelten Daten sowie deren Nutzung durch Facebook erhalten. Weitere Informationen hierzu finden Sie in der Datenschutzerkl&auml;rung von facebook unter <a href="https://de-de.facebook.com/policy.php" target="_blank">https://de-de.facebook.com/policy.php</a><br>
				
								Wenn Sie nicht w&uuml;nschen, daß Facebook den Besuch unserer Seiten Ihrem Facebook-Nutzerkonto zuordnen kann, loggen Sie sich bitte aus Ihrem Facebook-Benutzerkonto aus.
							</p>
					
							<p>Datenschutzerkl&auml;rung f&uuml;r die Nutzung von Google Analytics<br>
					
								Diese Website benutzt Google Analytics, einen Webanalysedienst der Alphabet Inc. (“Google”, “Alphabet”). Google Analytics verwendet sog. “Cookies”, Textdateien, die auf Ihrem Computer gespeichert werden und die eine Analyse der Benutzung der Website durch Sie erm&ouml;glichen. Die durch den Cookie erzeugten Informationen &uuml;ber Ihre Benutzung dieser Website werden in der Regel an einen Server von Google in den USA &uuml;bertragen und dort gespeichert. Im Falle der Aktivierung der IP-Anonymisierung auf dieser Webseite wird Ihre IP-Adreße von Google jedoch innerhalb von Mitgliedstaaten der Europ&auml;ischen Union oder in anderen Vertragßtaaten des Abkommens &uuml;ber den Europ&auml;ischen Wirtschaftsraum zuvor gek&uuml;rzt.<br>
					
								Nur in Ausnahmef&auml;llen wird die volle IP-Adreße an einen Server von Google in den USA &uuml;bertragen und dort gek&uuml;rzt. Im Auftrag des Betreibers dieser Website wird Google diese Informationen benutzen, um Ihre Nutzung der Website auszuwerten, um Reports &uuml;ber die Websiteaktivit&auml;ten zusammenzustellen und um weitere mit der Websitenutzung und der Internetnutzung verbundene Dienstleistungen gegen&uuml;ber dem Websitebetreiber zu erbringen. Die im Rahmen von Google Analytics von Ihrem Browser &uuml;bermittelte IP-Adreße wird nicht mit anderen Daten von Google zusammengef&uuml;hrt.<br>
					
								Sie k&ouml;nnen die Speicherung der Cookies durch eine entsprechende Einstellung Ihrer Browser-Software verhindern; wir weisen Sie jedoch darauf hin, daß Sie in diesem Fall gegebenenfalls nicht s&auml;mtliche Funktionen dieser Website vollumf&auml;nglich werden nutzen k&ouml;nnen. Sie k&ouml;nnen dar&uuml;ber hinaus die Erfaßung der durch das Cookie erzeugten und auf Ihre Nutzung der Website bezogenen Daten (inkl. Ihrer IP-Adreße) an Google sowie die Verarbeitung dieser Daten durch Google verhindern, indem sie das unter dem folgenden Link verf&uuml;gbare Browser-Plugin herunterladen und installieren: <a href="https://tools.google.com/dlpage/gaoptout?hl=de">https://tools.google.com/dlpage/gaoptout?hl=de</a>.
							</p>
					
							<p>Datenschutzerkl&auml;rung f&uuml;r die Nutzung von Google Adsense<br>
					
								Diese Website benutzt Google AdSense, einen Dienst zum Einbinden von Werbeanzeigen der Alphabet Inc. (“Google”, “Alphabet”). Google AdSense verwendet sog. “Cookies”, Textdateien, die auf Ihrem Computer gespeichert werden und die eine Analyse der Benutzung der Website erm&ouml;glicht. Google AdSense verwendet auch so genannte Web Beacons (unsichtbare Grafiken). Durch diese Web Beacons k&ouml;nnen Informationen wie der Besucherverkehr auf diesen Seiten ausgewertet werden.
			
								Die durch Cookies und Web Beacons erzeugten Informationen &uuml;ber die Benutzung dieser Website (einschließlich Ihrer IP-Adreße) und Auslieferung von Werbeformaten werden an einen Server von Google in den USA &uuml;bertragen und dort gespeichert. Diese Informationen k&ouml;nnen von Google an Vertragspartner von Google weiter gegeben werden. Google wird Ihre IP-Adreße jedoch nicht mit anderen von Ihnen gespeicherten Daten zusammenf&uuml;hren.
					
								Sie k&ouml;nnen die Installation der Cookies durch eine entsprechende Einstellung Ihrer Browser Software verhindern; wir weisen Sie jedoch darauf hin, daß Sie in diesem Fall gegebenenfalls nicht s&auml;mtliche Funktionen dieser Website voll umf&auml;nglich nutzen k&ouml;nnen. Durch die Nutzung dieser Website erkl&auml;ren Sie sich mit der Bearbeitung der &uuml;ber Sie erhobenen Daten durch Google in der zuvor beschriebenen Art und Weise und zu dem zuvor benannten Zweck einverstanden.
							</p>
					
							<p>Datenschutzerkl&auml;rung f&uuml;r die Nutzung von Google +1<br>
					
								Erfaßung und Weitergabe von Informationen:
								Mithilfe der Google +1-Schaltfl&auml;che k&ouml;nnen Sie Informationen weltweit ver&ouml;ffentlichen. &uuml;ber die Google +1-Schaltfl&auml;che erhalten Sie und andere Nutzer personalisierte Inhalte von Google und unseren Partnern. Google speichert sowohl die Information, daß Sie f&uuml;r einen Inhalt +1 gegeben haben, als auch Informationen &uuml;ber die Seite, die Sie beim Klicken auf +1 angesehen haben. Ihre +1 k&ouml;nnen als Hinweise zusammen mit Ihrem Profilnamen und Ihrem Foto in Google-Diensten, wie etwa in Suchergebnißen oder in Ihrem Google-Profil, oder an anderen Stellen auf Websites und Anzeigen im Internet eingeblendet werden.
								Google zeichnet Informationen &uuml;ber Ihre +1-Aktivit&auml;ten auf, um die Google-Dienste f&uuml;r Sie und andere zu verbeßern. Um die Google +1-Schaltfl&auml;che verwenden zu k&ouml;nnen, ben&ouml;tigen Sie ein weltweit sichtbares, &ouml;ffentliches Google-Profil, das zumindest den f&uuml;r das Profil gew&auml;hlten namen enthalten muß. Dieser name wird in allen Google-Diensten verwendet. In manchen F&auml;llen kann dieser name auch einen anderen namen ersetzen, den Sie beim Teilen von Inhalten &uuml;ber Ihr Google-Konto verwendet haben. Die Identit&auml;t Ihres Google-Profils kann Nutzern angezeigt werden, die Ihre E-Mail-Adreße kennen oder &uuml;ber andere identifizierende Informationen von Ihnen verf&uuml;gen.<br>
				
								Verwendung der erfaßten Informationen:
								Neben den oben erl&auml;uterten Verwendungszwecken werden die von Ihnen bereitgestellten Informationen gem&auml;ß den geltenden Google-Datenschutzbestimmungen genutzt. Alphabet ver&ouml;ffentlicht m&ouml;glicherweise zusammengefaßte Statistiken &uuml;ber die +1-Aktivit&auml;ten der Nutzer bzw. gibt diese an Nutzer und Partner weiter, wie etwa Publisher, Inserenten oder verbundene Websites.
							</p>
					
							<p>Datenschutzerkl&auml;rung f&uuml;r die Nutzung von Twitter<br>
							
								Auf unseren Seiten sind Funktionen des Dienstes Twitter eingebunden. Diese Funktionen werden angeboten durch die Twitter Inc., Twitter, Inc. 1355 Market St, Suite 900, San Francisco, CA 94103, USA. Durch das Benutzen von Twitter und der Funktion “Re-Tweet” werden die von Ihnen besuchten Webseiten mit Ihrem Twitter-Account verkn&uuml;pft und anderen Nutzern bekannt gegeben. Dabei werden auch Daten an Twitter &uuml;bertragen.<br>
					
								Wir weisen darauf hin, daß wir als Anbieter der Seiten keine Kenntnis vom Inhalt der &uuml;bermittelten Daten sowie deren Nutzung durch Twitter erhalten. Weitere Informationen hierzu finden Sie in der Datenschutzerkl&auml;rung von Twitter unter <a href="http://twitter.com/privacy" target="_blank">http://twitter.com/privacy</a>.<br>
					
								Ihre Datenschutzeinstellungen bei Twitter k&ouml;nnen Sie in den Konto-Einstellungen unter <a href="http://twitter.com/account/settings" target="_blank">https://twitter.com/account/settings</a> &auml;ndern.
								<br>
								Quellverweis: Datenschutzerkl&auml;rung von <a href="https://www.erecht24.de" terget="_blank">eRecht24</a>, dem Portal zum Internetrecht von Rechtsanwalt S&ouml;ren Siebert, Facebook Datenschutzerkl&auml;rung, Google Analytics Bedingungen, Google Adsense Datenschutzerkl&auml;rung, Google +1 Bedingungen, Datenschutzerkl&auml;rung f&uuml;r Twitter
							</p>				
						</div>
					</div>
				</div>
				<div id="haftung" class="modal">
					<div class="Info">
						<a href="#start" class="buttonModal" onclick="">x</a>
						<div class="InfoText">
							<p>Haftung f&uuml;r Inhalte<br>
								Als Diensteanbieter sind wir gem&auml;ß § 7 Abs.1 TMG f&uuml;r eigene Inhalte auf diesen Seiten nach den allgemeinen Gesetzen verantwortlich. Nach §§ 8 bis 10 TMG sind wir als Diensteanbieter jedoch nicht verpflichtet, &uuml;bermittelte oder gespeicherte fremde Informationen zu &uuml;berwachen oder nach Umst&auml;nden zu forschen, die auf eine rechtswidrige T&auml;tigkeit hinweisen. Verpflichtungen zur Entfernung oder Sperrung der Nutzung von Informationen nach den allgemeinen Gesetzen bleiben hiervon unber&uuml;hrt. Eine diesbez&uuml;gliche Haftung ist jedoch erst ab dem Zeitpunkt der Kenntnis einer konkreten Rechtsverletzung m&ouml;glich. Bei Bekanntwerden von entsprechenden Rechtsverletzungen werden wir diese Inhalte umgehend entfernen.
							</p>
							<p>
								Haftung f&uuml;r Links<br>
								Unser Angebot enth&auml;lt Links zu externen Webseiten Dritter, auf deren Inhalte wir keinen Einfluss haben. Deshalb k&ouml;nnen wir f&uuml;r diese fremden Inhalte auch keine Gew&auml;hr &uuml;bernehmen. F&uuml;r die Inhalte der verlinkten Seiten ist stets der jeweilige Anbieter oder Betreiber der Seiten verantwortlich. Die verlinkten Seiten wurden zum Zeitpunkt der Verlinkung auf m&ouml;gliche Rechtsverst&ouml; e &uuml;berpr&uuml;ft. Rechtswidrige Inhalte waren zum Zeitpunkt der Verlinkung nicht erkennbar. Eine permanente inhaltliche Kontrolle der verlinkten Seiten ist jedoch ohne konkrete Anhaltspunkte einer Rechtsverletzung nicht zumutbar. Bei Bekanntwerden von Rechtsverletzungen werden wir derartige Links umgehend entfernen.
							</p>
							<p>
								Urheberrecht<br>

								Die durch die Seitenbetreiber erstellten Inhalte und Werke auf diesen Seiten unterliegen dem deutschen Urheberrecht. Die Vervielf&auml;ltigung, Bearbeitung, Verbreitung und jede Art der Verwertung au erhalb der Grenzen des Urheberrechtes bed&uuml;rfen der schriftlichen Zustimmung des jeweiligen Autors bzw. Erstellers. Downloads und Kopien dieser Seite sind nur f&uuml;r den privaten, nicht kommerziellen Gebrauch gestattet. Soweit die Inhalte auf dieser Seite nicht vom Betreiber erstellt wurden, werden die Urheberrechte Dritter beachtet. Insbesondere werden Inhalte Dritter als solche gekennzeichnet. Sollten Sie trotzdem auf eine Urheberrechtsverletzung aufmerksam werden, bitten wir um einen entsprechenden Hinweis. Bei Bekanntwerden von Rechtsverletzungen werden wir derartige Inhalte umgehend entfernen.
							</p>
							<p>
								Quellenangaben: eRecht24 Disclaimer, Disclaimer von <a href="https://www.erecht24.de" terget="_blank">eRecht24</a>, dem Portal zum Internetrecht von Rechtsanwalt S&ouml;ren Siebert
							</p>
						</div>
					</div>
				</div>	
				<div id="Screen" class="modal">
					<div class="Info">
						<a href="#start" class="buttonModal" onclick="">x</a>
						<div class="InfoText">
						</div>
					</div>		
				</div>
			</aside>
			<div class="footerText">
				&#00169; 2022 &#00064;CyberAndi <a href="#impressum" onclick="">Impressum</a>
			</div>
		</footer>
	</body>
</html>


EOF
echo
echo index.htm
echo

cat << EOF > /www/CaptivePortal/prophetie.htm

<!DOCTYPE html>
<html lang="de">
	
	<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
	<meta http-equiv="Pragma" content="no-cache">
	<meta http-equiv="Expires" content="1">
	<meta http-equiv="content-type" content="text/html, charset=utf-8">
	<meta charset="utf-8">	
	<meta name="Description" content="C&grave;Movie das Hoffnungsportal mit Videostreaming. Als den Gegenpol zu Panik und Chaos seitens der Medien und Politik">
	<link rel="icon" type="image/x-icon" href="/pic/favicon.ico">
	<link rel="alternate" href="prophetie_en.htm" hreflang="en">
	<link href="theme_variable.css" rel="stylesheet" type="text/css" />	
	<link href="theme.css" rel="stylesheet" type="text/css" />
	<link href="mobile.css" rel="stylesheet" type="text/css" />
	<meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, viewport-fit=cover">
	<script src="framewrk.js"></script>
	<head>
		<title>C&grave;Movie das Hoffnungsportal</title>
	</head>	
	<body onload="" onresize="">
		
		<header class="header" id="headerHidden">
			
			<div class="headerText">
			<h1>
				<!-- Text insert by css Tag '.header h1' -->
			</h1>
			<h3>
				<!-- Text insert by css Tag '.header h3' -->
			</h3>
			<h4>
				<a href ="https://www.bibleserver.com/LUT/Offenbarung13%2C1" target="_blank">Sei vorbereitet, auf das was kommt</a>.
			</h4>
			</div>

			<a href="#explainEnd" id="NaviDown">
				<div>
					&#9660;
				</div>
			</a>
			
		</header>

	
		<nav id="topMenu" class="menu">
    			<a class="containerIcon" href="#start">
				<div class="iconMenu">
        				<div></div>
        				<div></div>
        				<div></div>  
    				</div>
				<div class="iconText">
					Men&uuml;
				</div>
			</a>
			<ul>
        	        	<li>
					<a href="index.htm#explainStart">Beweggr&uuml;nde</a>
				</li>
				<li>
					<a href="index.htm#mainDiashow">Filme / Podcast</a>
				</li>
				<li>
					<a href="index.htm#Pos7">Glaube</a>
					<ul>
    						<li><a href="index.htm#Pos7">Gottesdienste</a></li>
						<li><a href="index.htm#Pos5">Vortr&auml;ge</a></li>
						<li><a href="prophetie.htm">Prophetien</a></li>
    						<li><a href="index.htm#GScripte">Scripte</a></li>
    						
					</ul>
				</li>   
        			<li>
					<a href="index.htm#Pos5">IT / Multimedia</a> 
  					<ul>
      						<li><a href="https://www.cyberandi.de/DatenschutzMeinungsfreiheit" target="_blank">Datenschutz</a></li>
      						<li><a href="https://www.cyberandi.de" target="_blank">IT-Security / Multimedia</a></li> 
  					</ul>
	 			</li>
        			<li>
					<a href="index.htm#Pos1">Krisenvorsorge</a> 
					<ul>
    						<li><a href="index.htm#Pos1">Beitr&auml;ge</a></li>
    						<li><a href="index.htm#KScripte">Scripte</a></li> 
					</ul>
				</li>
				<li>
					Nachschlagewerke 
  					<ul>
      						<li><a href="https://www.wikipedia.de" target="_blank">Wikipedia</a></li>
      						<li><a href="https://www.bibleserver.com" target="_blank">Bibel</a></li> 
  					</ul>
	 			</li>
				<li>
					<a href="#impressum">Impressum</a>
				</li>

    			</ul>
		</nav>
		<div id="Main">	
			<main class="Content" id="start">
				<div class="containerOverlay">
						<section class="Overlay Book">
							<div class="leftLast">
							<article class="left"><p>
								Ich rede schon seit Jahren, was noch alles kommen k&ouml;nnte. Warum, weil ich es schon vor Jahrzehnten das erste mal davon tr&auml;umte. Und ich tr&auml;umte diesen identischen Traum mehrfach und es waren Jahre dazwischen. Zuletzt 2020/21. Ich hatte auch schon immer das Datum ca. 20 Jahre nach der Jahrtausendwende. 
								Als N&auml;chstes wird sich noch eine Art B&uuml;rgerkrieg weltweit ausbreiten. Und da werden Juden/Christen gegen Moslems, Arm gegen Reich, Umweltsch&uuml;tzer gegen Klimasch&uuml;tzer, LQBT- gegen Biologische Geschlechter-Bef&uuml;rworter, Demokratie- gegen Sozialismus-/Kommunismus-Bef&uuml;rworter usw. aufstehen. Ich wollte es Jahrzehnte nicht wahrhaben. Als ich aber 2020 wieder den selben Traum hatte, viel es mir wie Schuppen von den Augen. Da einige Wochen sp&auml;ter einer dieser Ereignisse des Traumes war wurde. Genauso wurden noch einige weiter Ereignisse des Traumes 2021 wahr. Ich habe mich, seit Jahren, mit  diesen Traum und Eindr&uuml;cke auf verschiedene Weise besch&auml;ftigt.
								</p> 
								<ol>
									<li>
										<b>Wissenschaftlich und Wirtschaftlich</b><br><br>
										Es gab mal eine Theorie von 7 guten Jahren und 7 schlechten Jahren. Dies war f&uuml;r die Wissenschaft und Wirtschaft bis in die 1990er klar. 
										Also:<br>
										Die Finanzkrise um Lehman Brothers 2008 usw.<br>
										Schuldenbremse in der BRD<br>
										Deutschland als der gr&ouml;&szlig;te Finanzier der EU und auch der Welt wir nicht immer diese Leistung bringen.<br>
										Also nahm ich an, da&szlig; es 2018 mit den Finazproblem los gehen wird, die sich jetzt 2022 richtig zeigen. Dazu der Energiewandel. Es wurde halt von der Politik und EZB versucht alles zu verschieben und diese Zyklen, welche fast 2000 Jahre funktionierten, zu ignorieren und zu bek&auml;mpfen.
									</li>
									<br>
									<li>
										<b>Soziologisch und geschichtlich</b><br><br>
										Die ungebremste Einwanderung und das Aufheben aller Traditionen wird fr&uuml;her oder sp&auml;ter zu einer Spaltung der Gesellschaft und der EU f&uuml;hren. Da ab dem Zeitpunkt, wo Deutschland nicht mehr f&uuml;r die EU zahlen kann, die restlichen EU-Staaten aus dem Euro bzw. EU-Raum austreten werden und wir als die EU-Vorreiter dann alleine die Zeche des Euros und der EU zahlen werden m&uuml;ssen. Da aber in Deutschland seit Jahrzehnten versucht wird, jegliche Ethnie, Rasse und Geschlecht zu zerst&ouml;ren, dachte ich immer an Soziale Unruhen welche in einem B&uuml;rgerkrieg enden werden. Und dieser sich dann auch Weltweit ausbreitet. Da ja laut meinen Recherchen &uuml;ber 60% in der BRD nicht deutscher Abstammung sind.  
									</li>
									<br>
									<li>
										<b>Glaubensm&auml;&szlig;ig</b><br>
										<p>
											Aber dies ist ja schon seit ca. 2000 Jahren bekannt. Einfach mal aus der Bibel die Offenbarung 13 und Daniel 2 lesen.<br><br> 
											<cite>	<b>1</b> Und ich sah ein Tier aus dem Meer steigen, das hatte zehn H&ouml;rner und sieben H&auml;upter und auf seinen H&ouml;rnern zehn Kronen und auf seinen H&auml;uptern l&auml;sterliche Namen. 
												<b>2</b> Und das Tier, das ich sah, war gleich einem Panther und seine F&uuml;&szlig;e wie B&auml;renf&uuml;&szlig;e und sein Rachen wie ein L&ouml;wenrachen. Und der Drache gab ihm seine Kraft und seinen Thron und gro&szlig;e Macht.	
												<b>3</b> Und ich sah eines seiner H&auml;upter, als w&auml;re es t&ouml;dlich verwundet, und seine t&ouml;dliche Wunde wurde heil. Und die ganze Erde wunderte sich &uuml;ber das Tier, 
												<b>4</b> und sie beteten den Drachen an, weil er dem Tier die Macht gab, und beteten das Tier an und sprachen: Wer ist dem Tier gleich und wer kann mit ihm k&auml;mpfen? 
												<b>5</b> Und es wurde ihm ein Maul gegeben, zu reden gro&szlig;e Dinge und L&auml;sterungen, und ihm wurde Macht gegeben, es zu tun zweiundvierzig Monate lang. 
												<b>6</b> Und es tat sein Maul auf zur L&auml;sterung gegen Gott, zu l&auml;stern seinen Namen und seine H&uuml;tte und die im Himmel wohnen. 
												<b>7</b> Und es wurde ihm gegeben, zu k&auml;mpfen mit den Heiligen und sie zu &uuml;berwinden; und es wurde ihm gegeben Macht &uuml;ber alle St&auml;mme und V&ouml;lker und Sprachen und Nationen. 
												<b>8</b> Und alle, die auf Erden wohnen, werden ihn anbeten, alle, deren Namen nicht vom Anfang der Welt an geschrieben stehen in dem Lebensbuch des Lammes, das geschlachtet ist. 
												<b>9</b> Hat jemand Ohren, der h&ouml;re! 
												<b>10</b> Wenn jemand ins Gef&auml;ngnis soll, dann wird er ins Gef&auml;ngnis kommen; wenn jemand mit dem Schwert get&ouml;tet werden soll, dann wird er mit dem Schwert get&ouml;tet. Hier ist Geduld und Glaube der Heiligen! 
												<b>11</b> Und ich sah ein zweites Tier aufsteigen aus der Erde; das hatte zwei H&ouml;rner wie ein Lamm und redete wie ein Drache. 
												<b>12</b> Und es &uuml;bt alle Macht des ersten Tieres aus vor seinen Augen und es macht, dass die Erde und die darauf wohnen, das erste Tier anbeten, dessen t&ouml;dliche Wunde heil geworden war. 
												<b>13</b> Und es tut gro&szlig;e Zeichen, sodass es auch Feuer vom Himmel auf die Erde fallen l&auml;sst vor den Augen der Menschen; 
												<b>14</b> und es verf&uuml;hrt, die auf Erden wohnen, durch die Zeichen, die zu tun vor den Augen des Tieres ihm Macht gegeben ist; und sagt denen, die auf Erden wohnen, dass sie ein Bild machen sollen dem Tier, das die Wunde vom Schwert hatte und lebendig geworden war. 
												<b>15</b> Und es wurde ihm gegeben, Geist zu verleihen dem Bild des Tieres, damit das Bild des Tieres reden und machen k&ouml;nne, dass alle, die das Bild des Tieres nicht anbeteten, get&ouml;tet w&uuml;rden. 
												<b>16</b> Und es macht, dass sie allesamt, die Kleinen und Gro&szlig;en, die Reichen und Armen, die Freien und Sklaven, sich ein Zeichen machen an ihre rechte Hand oder an ihre Stirn
												<b>17</b> und dass niemand kaufen oder verkaufen kann, wenn er nicht das Zeichen hat, n&auml;mlich den Namen des Tieres oder die Zahl seines Namens. 
												<b>18</b> Hier ist Weisheit! Wer Verstand hat, der &uuml;berlege die Zahl des Tieres; denn es ist die Zahl eines Menschen, und seine Zahl ist sechshundertsechsundsechzig
											</cite><br>
											Quelle: <a href="https://www.bibleserver.com/LUT/Offenbarung13" target="_blank">https://www.bibleserver.com/LUT/Offenbarung13</a>
										</p>
										<p>	
											Es wird vermutet, da&szlig; das Tier aus dem Meer die EU oder UN(Vereinte Nationen), welche Beschl&uuml;sse zu Klima, Gendern, Abtreibung, Migration usw. erlassen haben, sind. Da es aus dem Gebiet des R&ouml;mischen Reiches(Mittelmeerraum und EU, Naher Osten und Nord Afrika) kommen wird. Wobei die Nordamerikaner auch als ausgewanderte und vertriebene Europ&auml;er dazu z&auml;hlen.
										</p>
										<p id="explainEnd">
											Als Erkl&auml;rung dient hier Daniel 2:25 ff.<br>
											<cite>
												<b>25</b> Arjoch brachte Daniel eilends hinein vor den K&ouml;nig und sprach zu ihm: Ich habe einen Mann gefunden unter den Gefangenen aus Juda, der dem K&ouml;nig die Deutung sagen kann.
												<b>26</b> Der K&ouml;nig antwortete und sprach zu Daniel, den sie Beltschazar nannten: Bist du es, der mir den Traum, den ich gesehen habe, und seine Deutung kundtun kann?
												<b>27</b> Daniel fing an vor dem K&ouml;nig und sprach: Das Geheimnis, nach dem der K&ouml;nig fragt, verm&ouml;gen die Weisen, Zauberer, Zeichendeuter und Sternkundigen dem K&ouml;nig nicht zu sagen.
												<b>28</b> Aber es ist ein Gott im Himmel, der Geheimnisse offenbart. Der hat dem K&ouml;nig Nebukadnezar kundgetan, was am Ende der Tage geschehen soll. Mit deinem Traum und deinen Gesichten, als du schliefst, verhielt es sich so:
												<b>29</b> Du, K&ouml;nig, dachtest auf deinem Bett, was dereinst geschehen w&uuml;rde; und der, der Geheimnisse offenbart, hat dir kundgetan, was geschehen wird.
												<b>30</b> Mir aber ist dies Geheimnis offenbart worden, nicht als w&auml;re meine Weisheit gr&ouml;&szlig;er als die Weisheit aller, die da leben, sondern damit dem K&ouml;nig die Deutung kundw&uuml;rde und du deines Herzens Gedanken erf&uuml;hrest.
												<b>31</b> Du, K&ouml;nig, schautest, und siehe, ein sehr gro&szlig;es und hohes und hell gl&auml;nzendes Bild stand vor dir, das war schrecklich anzusehen.
												<b>32</b> Das Haupt dieses Bildes war von feinem Gold, seine Brust und seine Arme waren von Silber, sein Bauch und seine Lenden waren von Bronze,
												<b>33</b> seine Schenkel waren von Eisen, seine F&uuml;&szlig;e waren teils von Eisen und teils von Ton.
												<b>34</b> Das schautest du, bis ein Stein herunterkam, ohne Zutun von Menschenh&auml;nden; der traf das Bild an seinen F&uuml;&szlig;en, die von Eisen und Ton waren, und zermalmte sie.
												<b>35</b> Da wurden miteinander zermalmt Eisen, Ton, Bronze, Silber und Gold und wurden wie Spreu auf der Sommertenne, und der Wind verwehte sie, dass man sie nirgends mehr finden konnte. Der Stein aber, der das Bild zerschlug, wurde zu einem gro&szlig;en Berg und f&uuml;llte die ganze Welt.
												<b>36</b> Das ist der Traum. Nun wollen wir die Deutung vor dem K&ouml;nig sagen.
												<b>37</b> Du, K&ouml;nig, K&ouml;nig aller K&ouml;nige, dem der Gott des Himmels K&ouml;nigreich, Macht, St&auml;rke und Ehre gegeben hat
												<b>38</b> und dem er alle L&auml;nder, in denen Leute wohnen, dazu die Tiere auf dem Felde und die V&ouml;gel unter dem Himmel in die H&auml;nde gegeben und dem er &uuml;ber alles Gewalt verliehen hat! Du bist das goldene Haupt.
												<b>39</b> Nach dir wird ein anderes K&ouml;nigreich aufkommen, geringer als deines, und dann ein drittes K&ouml;nigreich, das aus Bronze ist und &uuml;ber alle L&auml;nder herrschen wird.
												<b>40</b> Und das vierte K&ouml;nigreich wird hart sein wie Eisen; denn wie Eisen alles zermalmt und zerschl&auml;gt, so wird es auch alles zermalmen und zerbrechen.
												<b>41</b> Dass du aber die F&uuml;&szlig;e und Zehen teils von Ton und teils von Eisen gesehen hast, bedeutet: Das wird ein zerteiltes K&ouml;nigreich sein; doch wird etwas von des Eisens H&auml;rte darin bleiben, wie du ja gesehen hast Eisen mit Ton vermengt.
												<b>42</b> Und dass die Zehen an seinen F&uuml;&szlig;en teils von Eisen und teils von Ton sind, bedeutet: Zum Teil wird's ein starkes und zum Teil ein schwaches Reich sein.
												<b>43</b> Und dass du gesehen hast Eisen mit Ton vermengt, bedeutet: Sie werden sich zwar durch Heiraten miteinander vermischen, aber sie werden doch nicht aneinander festhalten, so wie sich Eisen mit Ton nicht mengen l&auml;sst.
												<b>44</b> Aber zur Zeit dieser K&ouml;nige wird der Gott des Himmels ein Reich aufrichten, das nimmermehr zerst&ouml;rt wird; und sein Reich wird auf kein anderes Volk kommen. Es wird alle diese K&ouml;nigreiche zermalmen und zerst&ouml;ren; aber es selbst wird ewig bleiben,
												<b>45</b> wie du ja gesehen hast, dass ein Stein ohne Zutun von Menschenh&auml;nden vom Berg herunterkam, der Eisen, Bronze, Ton, Silber und Gold zermalmte. Ein gro&szlig;er Gott hat dem K&ouml;nig kundgetan, was dereinst geschehen wird. Der Traum ist zuverl&auml;ssig und die Deutung ist richtig.
												<b>46</b> Da fiel der K&ouml;nig Nebukadnezar auf sein Angesicht und warf sich nieder vor Daniel und befahl, man sollte ihm Speisopfer und R&auml;ucheropfer darbringen.
												<b>47</b> Und der K&ouml;nig antwortete Daniel und sprach: Wahrhaftig, euer Gott ist ein Gott &uuml;ber alle G&ouml;tter und ein Herr &uuml;ber alle K&ouml;nige, der Geheimnisse offenbaren kann, wie du dies Geheimnis hast offenbaren k&ouml;nnen
											</cite>	
											</p>
											Quelle: <a href="https://www.bibleserver.com/LUT/Daniel2%2C25" target="_blank">https://www.bibleserver.com/LUT/Daniel2:25</a>
									</li>
								</ol>
							</article>
							</div>		
						</section>
				</div>
			</main>
		</div>
		<footer>
			<aside>		
				<div id="impressum" class="modal">
					<div class="Info">
						<a href="#start" class="buttonModal" onclick="">x</a>
						<div class="InfoText">
							<p>Verantwortlicher im Sinne des Pressegesetzes:
							</p>
							<address>Stawinski Andreas<br>
							Jaspersallee 22<br>
							81245 M&uuml;nchen<br>
							Telefon: 089/74792- 201<br>
							Telefax: 089/74792- 202<br>
							E-Mail: cyberandi&#00064;outlook.de <br>
							Web: <a href="https://www.cyberandi.de" target="_blank">https://cyberandi.tumblr.com</a>
							</address>
							<p>
							Diese Seite nutzt <a href="https://www.torproject.org/">DNS over TOR(onion)<img src="pic/tor.png"></a>. Deshalb gibt es hier keine Zensur durch URL-Filter, der Povider(Telekom, Vodafone, O2 usw.), Geheimdienste und Regierungen.<br>
							Sondern nur einen Porno- und Werbungsblocker, der gegen das Tracking durch Google, Apple, Amazon, Facebook, Otto Group, VG Wort und der Sendeanstalten usw. fungiert.<br>
							Die Technik dahinter ist die Freeware <a href="https://github.com/CyberAndi/CyberSecurity-Box" target="_blank">CyberSecurity-Box</a> <a href="https://github.com/CyberAndi/CyberSecurity-Box" target="_blank"><img src="pic/csb.png"></a>.
							</p>
							Bitte lesen Sie auch die <a href="#datenschutz" onclick="datenschutz();">Datenschutzbestimmungen</a> sowie den <a href="#haftung" onclick="haftung();">Hauftungsausschluss</a> durch.
						</div>
					</div>
				</div>
				<div id="datenschutz" class="modal">
					<div class="Info">
						<a href="#start" class="buttonModal" onclick="">x</a>
						<div class="InfoText">
							<p>Die Nutzung unserer Webseite ist in der Regel ohne Angabe personenbezogener Daten m&ouml;glich. Soweit auf unseren Seiten personenbezogene Daten (beispielsweise name, Anschrift oder eMail-Adre&szlig;en) erhoben werden, erfolgt dies, soweit m&ouml;glich, stets auf freiwilliger Basis. Diese Daten werden ohne Ihre ausdr&uuml;ckliche Zustimmung nicht an Dritte weitergegeben.
							</p>
							<p>Wir weisen darauf hin, da&szlig; die Daten&uuml;bertragung im Internet (z.B. bei der Kommunikation per E-Mail) Sicherheitsl&uuml;cken aufweisen kann. Ein l&uuml;ckenloser Schutz der Daten vor dem Zugriff durch Dritte ist nicht m&ouml;glich.
							</p
			
							<p>Der Nutzung von im Rahmen der Impre&szlig;umspflicht ver&ouml;ffentlichten Kontaktdaten durch Dritte zur &uuml;bersendung von nicht ausdr&uuml;cklich angeforderter Werbung und Informationsmaterialien wird hiermit ausdr&uuml;cklich widersprochen. Die Betreiber der Seiten behalten sich ausdr&uuml;cklich rechtliche Schritte im Falle der unverlangten Zusendung von Werbeinformationen, etwa durch Spam-Mails, vor.
							</p>
							<p>
								Diese Seite nutzt <a href="https://www.torproject.org/">DNS over TOR(onion)<img src="pic/tor.png"></a>. Deshalb gibt es hier keine Zensur durch URL-Filter, der Povider(Telekom, Vodafone, O2 usw.), Geheimdienste und Regierungen.<br>
								Sondern nur einen Porno- und Werbungsblocker, der gegen das Tracking durch Google, Apple, Amazon, Facebook, Otto Group, VG Wort und der Sendeanstalten usw. fungiert.<br>
								Die Technik dahinter ist die Freeware <a href="https://github.com/CyberAndi/CyberSecurity-Box" target="_blank">CyberSecurity-Box</a> <a href="https://github.com/CyberAndi/CyberSecurity-Box" target="_blank"><img src="pic/csb.png"></a>.
							</p>
							<p>Datenschutzerkl&auml;rung f&uuml;r die Nutzung von Facebook-Plugins (Like-Button)<br>
	
								Auf unseren Seiten sind Plugins des sozialen Netzwerks Facebook (“Meta”,“Facebook”,Meta Platforms Inc., 1601 Willow Road, Menlo Park, California, 94025, USA) integriert. Die Facebook-Plugins erkennen Sie an dem Facebook-Logo oder dem “Like-Button” (“Gef&auml;llt mir”) auf unserer Seite. Eine &uuml;bersicht &uuml;ber die Facebook-Plugins finden Sie hier: <a href="https://developers.facebook.com/docs/plugins/" target="_blank">https://developers.facebook.com/docs/plugins/</a>.
								Wenn Sie unsere Seiten besuchen, wird &uuml;ber das Plugin eine direkte Verbindung zwischen Ihrem Browser und dem Facebook-Server hergestellt. Facebook erh&auml;lt dadurch die Information, da&szlig; Sie mit Ihrer IP-Adre&szlig;e unsere Seite besucht haben. Wenn Sie den Facebook “Like-Button” anklicken w&auml;hrend Sie in Ihrem Facebook-Account eingeloggt sind, k&ouml;nnen Sie die Inhalte unserer Seiten auf Ihrem Facebook-Profil verlinken. Dadurch kann Facebook den Besuch unserer Seiten Ihrem Benutzerkonto zuordnen. Wir weisen darauf hin, da&szlig; wir als Anbieter der Seiten keine Kenntnis vom Inhalt der &uuml;bermittelten Daten sowie deren Nutzung durch Facebook erhalten. Weitere Informationen hierzu finden Sie in der Datenschutzerkl&auml;rung von facebook unter <a href="https://de-de.facebook.com/policy.php" target="_blank">https://de-de.facebook.com/policy.php</a><br>
				
								Wenn Sie nicht w&uuml;nschen, da&szlig; Facebook den Besuch unserer Seiten Ihrem Facebook-Nutzerkonto zuordnen kann, loggen Sie sich bitte aus Ihrem Facebook-Benutzerkonto aus.
							</p>
					
							<p>Datenschutzerkl&auml;rung f&uuml;r die Nutzung von Google Analytics<br>
					
								Diese Website benutzt Google Analytics, einen Webanalysedienst der Alphabet Inc. (“Google”, “Alphabet”). Google Analytics verwendet sog. “Cookies”, Textdateien, die auf Ihrem Computer gespeichert werden und die eine Analyse der Benutzung der Website durch Sie erm&ouml;glichen. Die durch den Cookie erzeugten Informationen &uuml;ber Ihre Benutzung dieser Website werden in der Regel an einen Server von Google in den USA &uuml;bertragen und dort gespeichert. Im Falle der Aktivierung der IP-Anonymisierung auf dieser Webseite wird Ihre IP-Adre&szlig;e von Google jedoch innerhalb von Mitgliedstaaten der Europ&auml;ischen Union oder in anderen Vertrag&szlig;taaten des Abkommens &uuml;ber den Europ&auml;ischen Wirtschaftsraum zuvor gek&uuml;rzt.<br>
					
								Nur in Ausnahmef&auml;llen wird die volle IP-Adre&szlig;e an einen Server von Google in den USA &uuml;bertragen und dort gek&uuml;rzt. Im Auftrag des Betreibers dieser Website wird Google diese Informationen benutzen, um Ihre Nutzung der Website auszuwerten, um Reports &uuml;ber die Websiteaktivit&auml;ten zusammenzustellen und um weitere mit der Websitenutzung und der Internetnutzung verbundene Dienstleistungen gegen&uuml;ber dem Websitebetreiber zu erbringen. Die im Rahmen von Google Analytics von Ihrem Browser &uuml;bermittelte IP-Adre&szlig;e wird nicht mit anderen Daten von Google zusammengef&uuml;hrt.<br>
					
								Sie k&ouml;nnen die Speicherung der Cookies durch eine entsprechende Einstellung Ihrer Browser-Software verhindern; wir weisen Sie jedoch darauf hin, da&szlig; Sie in diesem Fall gegebenenfalls nicht s&auml;mtliche Funktionen dieser Website vollumf&auml;nglich werden nutzen k&ouml;nnen. Sie k&ouml;nnen dar&uuml;ber hinaus die Erfa&szlig;ung der durch das Cookie erzeugten und auf Ihre Nutzung der Website bezogenen Daten (inkl. Ihrer IP-Adre&szlig;e) an Google sowie die Verarbeitung dieser Daten durch Google verhindern, indem sie das unter dem folgenden Link verf&uuml;gbare Browser-Plugin herunterladen und installieren: <a href="https://tools.google.com/dlpage/gaoptout?hl=de">https://tools.google.com/dlpage/gaoptout?hl=de</a>.
							</p>
					
							<p>Datenschutzerkl&auml;rung f&uuml;r die Nutzung von Google Adsense<br>
					
								Diese Website benutzt Google AdSense, einen Dienst zum Einbinden von Werbeanzeigen der Alphabet Inc. (“Google”, “Alphabet”). Google AdSense verwendet sog. “Cookies”, Textdateien, die auf Ihrem Computer gespeichert werden und die eine Analyse der Benutzung der Website erm&ouml;glicht. Google AdSense verwendet auch so genannte Web Beacons (unsichtbare Grafiken). Durch diese Web Beacons k&ouml;nnen Informationen wie der Besucherverkehr auf diesen Seiten ausgewertet werden.
			
								Die durch Cookies und Web Beacons erzeugten Informationen &uuml;ber die Benutzung dieser Website (einschlie&szlig;lich Ihrer IP-Adre&szlig;e) und Auslieferung von Werbeformaten werden an einen Server von Google in den USA &uuml;bertragen und dort gespeichert. Diese Informationen k&ouml;nnen von Google an Vertragspartner von Google weiter gegeben werden. Google wird Ihre IP-Adre&szlig;e jedoch nicht mit anderen von Ihnen gespeicherten Daten zusammenf&uuml;hren.
					
								Sie k&ouml;nnen die Installation der Cookies durch eine entsprechende Einstellung Ihrer Browser Software verhindern; wir weisen Sie jedoch darauf hin, da&szlig; Sie in diesem Fall gegebenenfalls nicht s&auml;mtliche Funktionen dieser Website voll umf&auml;nglich nutzen k&ouml;nnen. Durch die Nutzung dieser Website erkl&auml;ren Sie sich mit der Bearbeitung der &uuml;ber Sie erhobenen Daten durch Google in der zuvor beschriebenen Art und Weise und zu dem zuvor benannten Zweck einverstanden.
							</p>
					
							<p>Datenschutzerkl&auml;rung f&uuml;r die Nutzung von Google +1<br>
					
								Erfa&szlig;ung und Weitergabe von Informationen:
								Mithilfe der Google +1-Schaltfl&auml;che k&ouml;nnen Sie Informationen weltweit ver&ouml;ffentlichen. &uuml;ber die Google +1-Schaltfl&auml;che erhalten Sie und andere Nutzer personalisierte Inhalte von Google und unseren Partnern. Google speichert sowohl die Information, da&szlig; Sie f&uuml;r einen Inhalt +1 gegeben haben, als auch Informationen &uuml;ber die Seite, die Sie beim Klicken auf +1 angesehen haben. Ihre +1 k&ouml;nnen als Hinweise zusammen mit Ihrem Profilnamen und Ihrem Foto in Google-Diensten, wie etwa in Suchergebni&szlig;en oder in Ihrem Google-Profil, oder an anderen Stellen auf Websites und Anzeigen im Internet eingeblendet werden.
								Google zeichnet Informationen &uuml;ber Ihre +1-Aktivit&auml;ten auf, um die Google-Dienste f&uuml;r Sie und andere zu verbe&szlig;ern. Um die Google +1-Schaltfl&auml;che verwenden zu k&ouml;nnen, ben&ouml;tigen Sie ein weltweit sichtbares, &ouml;ffentliches Google-Profil, das zumindest den f&uuml;r das Profil gew&auml;hlten namen enthalten mu&szlig;. Dieser name wird in allen Google-Diensten verwendet. In manchen F&auml;llen kann dieser name auch einen anderen namen ersetzen, den Sie beim Teilen von Inhalten &uuml;ber Ihr Google-Konto verwendet haben. Die Identit&auml;t Ihres Google-Profils kann Nutzern angezeigt werden, die Ihre E-Mail-Adre&szlig;e kennen oder &uuml;ber andere identifizierende Informationen von Ihnen verf&uuml;gen.<br>
				
								Verwendung der erfa&szlig;ten Informationen:
								Neben den oben erl&auml;uterten Verwendungszwecken werden die von Ihnen bereitgestellten Informationen gem&auml;&szlig; den geltenden Google-Datenschutzbestimmungen genutzt. Alphabet ver&ouml;ffentlicht m&ouml;glicherweise zusammengefa&szlig;te Statistiken &uuml;ber die +1-Aktivit&auml;ten der Nutzer bzw. gibt diese an Nutzer und Partner weiter, wie etwa Publisher, Inserenten oder verbundene Websites.
							</p>
					
							<p>Datenschutzerkl&auml;rung f&uuml;r die Nutzung von Twitter<br>
							
								Auf unseren Seiten sind Funktionen des Dienstes Twitter eingebunden. Diese Funktionen werden angeboten durch die Twitter Inc., Twitter, Inc. 1355 Market St, Suite 900, San Francisco, CA 94103, USA. Durch das Benutzen von Twitter und der Funktion “Re-Tweet” werden die von Ihnen besuchten Webseiten mit Ihrem Twitter-Account verkn&uuml;pft und anderen Nutzern bekannt gegeben. Dabei werden auch Daten an Twitter &uuml;bertragen.<br>
					
								Wir weisen darauf hin, da&szlig; wir als Anbieter der Seiten keine Kenntnis vom Inhalt der &uuml;bermittelten Daten sowie deren Nutzung durch Twitter erhalten. Weitere Informationen hierzu finden Sie in der Datenschutzerkl&auml;rung von Twitter unter <a href="http://twitter.com/privacy" target="_blank">http://twitter.com/privacy</a>.<br>
					
								Ihre Datenschutzeinstellungen bei Twitter k&ouml;nnen Sie in den Konto-Einstellungen unter <a href="http://twitter.com/account/settings" target="_blank">https://twitter.com/account/settings</a> &auml;ndern.
								<br>
								Quellverweis: Datenschutzerkl&auml;rung von <a href="https://www.erecht24.de" terget="_blank">eRecht24</a>, dem Portal zum Internetrecht von Rechtsanwalt S&ouml;ren Siebert, Facebook Datenschutzerkl&auml;rung, Google Analytics Bedingungen, Google Adsense Datenschutzerkl&auml;rung, Google +1 Bedingungen, Datenschutzerkl&auml;rung f&uuml;r Twitter
							</p>				
						</div>
					</div>
				</div>
				<div id="haftung" class="modal">
					<div class="Info">
						<a href="#start" class="buttonModal" onclick="">x</a>
						<div class="InfoText">
							<p>Haftung f&uuml;r Inhalte<br>
								Als Diensteanbieter sind wir gem&auml;&szlig; § 7 Abs.1 TMG f&uuml;r eigene Inhalte auf diesen Seiten nach den allgemeinen Gesetzen verantwortlich. Nach §§ 8 bis 10 TMG sind wir als Diensteanbieter jedoch nicht verpflichtet, &uuml;bermittelte oder gespeicherte fremde Informationen zu &uuml;berwachen oder nach Umst&auml;nden zu forschen, die auf eine rechtswidrige T&auml;tigkeit hinweisen. Verpflichtungen zur Entfernung oder Sperrung der Nutzung von Informationen nach den allgemeinen Gesetzen bleiben hiervon unber&uuml;hrt. Eine diesbez&uuml;gliche Haftung ist jedoch erst ab dem Zeitpunkt der Kenntnis einer konkreten Rechtsverletzung m&ouml;glich. Bei Bekanntwerden von entsprechenden Rechtsverletzungen werden wir diese Inhalte umgehend entfernen.
							</p>
							<p>
								Haftung f&uuml;r Links<br>
								Unser Angebot enth&auml;lt Links zu externen Webseiten Dritter, auf deren Inhalte wir keinen Einfluss haben. Deshalb k&ouml;nnen wir f&uuml;r diese fremden Inhalte auch keine Gew&auml;hr &uuml;bernehmen. F&uuml;r die Inhalte der verlinkten Seiten ist stets der jeweilige Anbieter oder Betreiber der Seiten verantwortlich. Die verlinkten Seiten wurden zum Zeitpunkt der Verlinkung auf m&ouml;gliche Rechtsverst&ouml; e &uuml;berpr&uuml;ft. Rechtswidrige Inhalte waren zum Zeitpunkt der Verlinkung nicht erkennbar. Eine permanente inhaltliche Kontrolle der verlinkten Seiten ist jedoch ohne konkrete Anhaltspunkte einer Rechtsverletzung nicht zumutbar. Bei Bekanntwerden von Rechtsverletzungen werden wir derartige Links umgehend entfernen.
							</p>
							<p>
								Urheberrecht<br>

								Die durch die Seitenbetreiber erstellten Inhalte und Werke auf diesen Seiten unterliegen dem deutschen Urheberrecht. Die Vervielf&auml;ltigung, Bearbeitung, Verbreitung und jede Art der Verwertung au erhalb der Grenzen des Urheberrechtes bed&uuml;rfen der schriftlichen Zustimmung des jeweiligen Autors bzw. Erstellers. Downloads und Kopien dieser Seite sind nur f&uuml;r den privaten, nicht kommerziellen Gebrauch gestattet. Soweit die Inhalte auf dieser Seite nicht vom Betreiber erstellt wurden, werden die Urheberrechte Dritter beachtet. Insbesondere werden Inhalte Dritter als solche gekennzeichnet. Sollten Sie trotzdem auf eine Urheberrechtsverletzung aufmerksam werden, bitten wir um einen entsprechenden Hinweis. Bei Bekanntwerden von Rechtsverletzungen werden wir derartige Inhalte umgehend entfernen.
							</p>
							<p>
								Quellenangaben: eRecht24 Disclaimer, Disclaimer von <a href="https://www.erecht24.de" terget="_blank">eRecht24</a>, dem Portal zum Internetrecht von Rechtsanwalt S&ouml;ren Siebert
							</p>
						</div>
					</div>
				</div>	
				<div id="Screen" class="modal">
					<div class="Info">
						<a href="#start" class="buttonModal" onclick="">x</a>
						<div class="InfoText">
						</div>
					</div>		
				</div>
			</aside>
			<div class="footerText">
				&#00169; 2022 &#00064;CyberAndi <a href="#impressum" onclick="">Impressum</a>
			</div>
		</footer>
	</body>
</html>

EOF

echo
echo prophetie
echo


cp /www/index.html /www/generate_204.html
cp /www/index.html /www/hotspot-detect.html


clear
echo '########################################################'
echo '#                                                      #'
echo '#                 CyberSecurity-Box                    #'
echo '#                                                      #'
echo '# local Privacy for Voice-Assistent Smart-TV SmartHome #'
echo '#                                                      #'
echo '#                Network Definitions                   #'
echo '#                                                      #'
echo '########################################################'
echo 
uci -q delete network.lan

uci set network.loopback=interface
uci set network.loopback.device='lo'
uci set network.loopback.ifname='lo'
uci set network.loopback.proto='static'
uci set network.loopback.ipaddr='127.0.0.1'
uci set network.loopback.netmask='255.0.0.0'
uci set network.loopback.dns='127.0.0.1'

uci set network.globals=globals
uci set network.globals.ula_prefix='fdc8:f6c1:ce31::/48'

uci set network.wan=interface >/dev/null
uci set network.wan.device='eth1'
uci set network.wan.proto='static'
uci set network.wan.netmask='255.255.255.0'
uci set network.wan.ip6assign='60'
uci set network.wan.gateway=$INET_GW
uci add_list network.wan.dns='127.0.0.1'
uci set network.wan.ifname='eth1'
uci set network.wan.ipaddr=$WAN_ip
uci set network.wan.metric='10'
uci set network.wan.peerdns='0'
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='wan_mobile'
uci commit network >/dev/null
uci set network.wan_mobile.proto='static'
uci set network.wan_mobile.netmask='255.255.255.0'
uci set network.wan_mobile.ip6assign='60'
uci set network.wan_mobile.gateway=$WAN_MOBILE_GW
uci add_list network.wan_mobile.dns='127.0.0.1'
uci set network.wan_mobile.ifname='eth0.110'
uci set network.wan_mobile.device='eth0.110'
uci set network.wan_mobile.ipaddr= $WAN_MOBILE_ip
uci set network.wan_mobile.metric='20'
uci set network.wan_mobile.peerdns='0'
uci commit network >/dev/null

uci set network.wan6.proto='dhcpv6'
uci set network.wan6.reqaddress='try'
uci set network.wan6.reqprefix='auto'
uci set network.wan6.ifname='eth1'
uci set network.wan6.device='eth1'
uci add_list network.wan6.dns='0::1'
uci set network.wan6.metric='10'
uci set network.wan6.peerdns='0'
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='wan_mobile6'
uci commit network >/dev/null
uci set network.wan_mobile6.proto='dhcpv6'
uci set network.wan_mobile6.reqaddress='try'
uci set network.wan_mobile6.reqprefix='auto'
uci set network.wan_mobile6.ifname='eth0.110'
uci set network.wan_mobile6.device='eth0.110'
uci add_list network.wan_mobile6.dns='0::1'
uci set network.wan_mobile6.metric='20'
uci set network.wan_mobile6.peerdns='0'
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='VOICE'
uci commit network >/dev/null
uci set network.VOICE.proto='static'
uci set network.VOICE.type='bridge'
uci set network.VOICE.ipaddr=$VOICE_ip
uci set network.VOICE.netmask='255.255.255.0'
uci set network.VOICE.ip6assign='56'
uci set network.VOICE.broadcast=$VOICE_broadcast
uci set network.VOICE.igmp_snooping='1'
#uci set network.VOICE.gateway='127.0.0.1'
uci set network.VOICE.gateway=$INET_GW
uci set network.VOICE.ifname='eth0.105'
uci set network.VOICE.device='eth0.105'
uci set network.VOICE.dns=$VOICE_ip
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='ENTERTAIN'
uci commit network >/dev/null
uci set network.ENTERTAIN.proto='static'
uci set network.ENTERTAIN.type='bridge'
uci set network.ENTERTAIN.ipaddr=$ENTERTAIN_ip
uci set network.ENTERTAIN.netmask='255.255.255.0'
uci set network.ENTERTAIN.ip6assign='56'
uci set network.ENTERTAIN.broadcast=$ENTERTAIN_broadcast
uci set network.ENTERTAIN.igmp_snooping='1'
#uci set network.ENTERTAIN.gateway='127.0.0.1'
uci set network.ENTERTAIN.gateway=$INET_GW
uci set network.ENTERTAIN.ifname='eth0.106'
uci set network.ENTERTAIN.device='eth0.106'
uci set network.ENTERTAIN.dns=$ENTERTAIN_ip
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='GUEST'
uci commit network >/dev/null
uci set network.GUEST.proto='static'
uci set network.GUEST.type='bridge'
uci set network.GUEST.ipaddr=$GUEST_ip
uci set network.GUEST.netmask='255.255.255.0'
uci set network.GUEST.ip6assign='56'
uci set network.GUEST.broadcast=$GUEST_broadcast
uci set network.GUEST.igmp_snooping='1'
#uci set network.GUEST.gateway='127.0.0.1'
uci set network.GUEST.gateway=$INET_GW
uci set network.GUEST.ifname='eth0.107'
uci set network.GUEST.device='eth0.107'
uci set network.GUEST.dns=$GUEST_ip
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='CMOVIE'
uci commit network >/dev/null
uci set network.CMOVIE.proto='static'
uci set network.CMOVIE.type='bridge'
uci set network.CMOVIE.ipaddr=$CMOVIE_ip
uci set network.CMOVIE.netmask='255.255.255.0'
uci set network.CMOVIE.ip6assign='56'
uci set network.CMOVIE.broadcast=$CMOVIE_broadcast
uci set network.CMOVIE.igmp_snooping='1'
#uci set network.CMOVIE.gateway='127.0.0.1'
uci set network.CMOVIE.gateway=$INET_GW
uci set network.CMOVIE.ifname='eth0.108'
uci set network.CMOVIE.device='eth0.108'
uci set network.CMOVIE.dns=$CMOVIE_ip
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='SERVER'
uci commit network >/dev/null
uci set network.SERVER.proto='static'
uci set network.SERVER.type='bridge'
uci set network.SERVER.ipaddr=$SERVER_ip
uci set network.SERVER.netmask='255.255.255.0'
uci set network.SERVER.ip6assign='56'
uci set network.SERVER.broadcast=$SERVER_broadcast
uci set network.SERVER.igmp_snooping='1'
#uci set network.SERVER.gateway='127.0.0.1'
uci set network.SERVER.gateway=$INET_GW
uci set network.SERVER.ifname='eth0.101'
uci set network.SERVER.device='eth0.101'
uci set network.SERVER.dns=$SERVER_ip
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='INET'
uci commit network >/dev/null
uci set network.INET.proto='static'
uci set network.INET.type='bridge'
uci set network.INET.ipaddr=$INET_ip
uci set network.INET.netmask='255.255.255.0'
uci set network.INET.ip6assign='56'
uci set network.INET.broadcast=$INET_broadcast
uci set network.INET.igmp_snooping='1'
#uci set network.INET.gateway='127.0.0.1'
uci set network.INET.gateway=$INET_GW
uci set network.INET.ifname='eth0.104'
uci set network.INET.device='eth0.104'
uci set network.INET.dns=$INET_ip
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='CONTROL'
uci commit network >/dev/null
uci set network.CONTROL.proto='static'
uci set network.CONTROL.type='bridge'
uci set network.CONTROL.ipaddr=$CONTROL_ip
uci set network.CONTROL.netmask='255.255.255.0'
uci set network.CONTROL.ip6assign='56'
uci set network.CONTROL.broadcast=$CONTROL_broadcast
uci set network.CONTROL.igmp_snooping='1'
#uci set network.CONTROL.gateway='127.0.0.1'
uci set network.CONTROL.gateway=$INET_GW
uci set network.CONTROL.ifname='eth0.103'
uci set network.CONTROL.device='eth0.103'
uci set network.CONTROL.dns=$CONTROL_ip
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='HCONTROL'
uci commit network >/dev/null
uci set network.HCONTROL.proto='static'
uci set network.HCONTROL.type='bridge'
uci set network.HCONTROL.ipaddr=$HCONTROL_ip
uci set network.HCONTROL.netmask='255.255.255.0'
uci set network.HCONTROL.ip6assign='56'
uci set network.HCONTROL.broadcast=$HCONTROL_broadcast
uci set network.HCONTROL.igmp_snooping='1'
#uci set network.HCONTROL.gateway='127.0.0.1'
uci set network.HCONTROL.gateway=$INET_GW
uci set network.HCONTROL.ifname='eth0.102'
uci set network.HCONTROL.device='eth0.102'
uci set network.HCONTROL.dns=$HCONTROL_ip

uci add network interface >/dev/null
uci rename network.@interface[-1]='REPEATER'
uci commit network >/dev/null
uci set network.REPEATER.proto='none'
uci commit  && reload_config >/dev/null

uci commit network >/dev/null
uci set network.@switch[0]=switch
uci set network.@switch[0].name='switch0'
uci set network.@switch[0].reset='1'
uci set network.@switch[0].enable_vlan='1'
uci commit network >/dev/null

uci set network.@switch_vlan[0]=switch_vlan
uci set network.@switch_vlan[0].device='switch0'
uci set network.@switch_vlan[0].vlan='101'
uci set network.@switch_vlan[0].vid='101'
uci set network.@switch_vlan[0].ports='0t 1t 2 3t 4t 5t'
uci commit network >/dev/null

uci add network switch_vlan
uci set network.@switch_vlan[-1].device='switch0'
uci set network.@switch_vlan[-1].vlan='102'
uci set network.@switch_vlan[-1].vid='102'
uci set network.@switch_vlan[-1].ports='0t 1 2t 3 4t 5t'
uci commit network >/dev/null

uci add network switch_vlan
uci set network.@switch_vlan[-1].device='switch0'
uci set network.@switch_vlan[-1].vLan='103'
uci set network.@switch_vlan[-1].vid='103'
uci set network.@switch_vlan[-1].ports='0t 1t 2t 3t 4t 5t'
uci commit network >/dev/null

uci add network switch_vlan
uci set network.@switch_vlan[-1].device='switch0'
uci set network.@switch_vlan[-1].vlan='104'
uci set network.@switch_vlan[-1].ports='0t 1t 2t 3t 4 5t'
uci set network.@switch_vlan[-1].vid='104'
uci commit network >/dev/null

uci add network switch_vlan
uci set network.@switch_vlan[-1].device='switch0'
uci set network.@switch_vlan[-1].vlan='105'
uci set network.@switch_vlan[-1].ports='0t 1t 2t 3t 4t 5t'
uci set network.@switch_vlan[-1].vid='105'
uci commit network >/dev/null

uci add network switch_vlan
uci set network.@switch_vlan[-1].device='switch0'
uci set network.@switch_vlan[-1].vlan='106'
uci set network.@switch_vlan[-1].ports='0t 1t 2t 3t 4t 5t'
uci set network.@switch_vlan[-1].vid='106'
uci commit network >/dev/null

uci add network switch_vlan
uci set network.@switch_vlan[-1].device='switch0'
uci set network.@switch_vlan[-1].vlan='107'
uci set network.@switch_vlan[-1].ports='0t 1t 2t 3t 4t 5t'
uci set network.@switch_vlan[-1].vid='107'

uci add network switch_vlan
uci set network.@switch_vlan[-1].device='switch0'
uci set network.@switch_vlan[-1].vlan='108'
uci set network.@switch_vlan[-1].ports='0t 1t 2t 3t 4t 5t'
uci set network.@switch_vlan[-1].vid='108'

uci add network switch_vlan
uci set network.@switch_vlan[-1].device='switch0'
uci set network.@switch_vlan[-1].vlan='110'
uci set network.@switch_vlan[-1].ports='0t 1 2t 3t 4t 5t'
uci set network.@switch_vlan[-1].vid='110'
uci commit network >/dev/null

uci add network interface
uci rename network.@interface[-1]='SWITCH_Port'
uci commit network >/dev/null
uci set network.SWITCH_Port.ifname='eth0'
uci set network.SWITCH_Port.proto='none'
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='SWITCH_P101'
uci commit network >/dev/null
uci set network.SWITCH_P101.ifname='eth0.101'
uci set network.SWITCH_P101.proto='none'
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='SWITCH_P102'
uci commit network >/dev/null
uci set network.SWITCH_P102.ifname='eth0.102'
uci set network.SWITCH_P102.proto='none'
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='SWITCH_P103'
uci commit network >/dev/null
uci set network.SWITCH_P103.ifname='eth0.103'
uci set network.SWITCH_P103.proto='none'
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='SWITCH_P104'
uci commit network >/dev/null
uci set network.SWITCH_P104.ifname='eth0.104'
uci set network.SWITCH_P104.proto='none'
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='SWITCH_P105'
uci commit network >/dev/null
uci set network.SWITCH_P105.ifname='eth0.105'
uci set network.SWITCH_P105.proto='none'
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='SWITCH_P106'
uci commit network >/dev/null
uci set network.SWITCH_P106.ifname='eth0.106'
uci set network.SWITCH_P106.proto='none'
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='SWITCH_P107'
uci commit network >/dev/null
uci set network.SWITCH_P107.ifname='eth0.107'
uci set network.SWITCH_P107.proto='none'
uci commit network >/dev/null

uci add network interface >/dev/null
uci rename network.@interface[-1]='SWITCH_P108'
uci commit network >/dev/null
uci set network.SWITCH_P108.ifname='eth0.108'
uci set network.SWITCH_P108.proto='none'
uci commit network >/dev/null

uci add network device >/dev/null
uci rename network.@device[-1]='br_VOICE'
uci commit network >/dev/null
uci set network.br_VOICE.name='br-VOICE'
uci set network.br_VOICE.type='bridge'
uci set network.br_VOICE.ports='eth0.105'
uci set network.br_VOICE.igmp_snooping='1'
uci commit network >/dev/null

uci add network device >/dev/null
uci rename network.@device[-1]='br_ENTERTAIN'
uci commit network >/dev/null
uci set network.br_ENTERTAIN.name='br-ENTERTAIN'
uci set network.br_ENTERTAIN.type='bridge'
uci set network.br_ENTERTAIN.ports='eth0.106'
uci set network.br_ENTERTAIN.igmp_snooping='1'
uci commit network >/dev/null

uci add network device >/dev/null
uci rename network.@device[-1]='br_GUEST'
uci commit network >/dev/null
uci set network.br_GUEST.name='br-GUEST'
uci set network.br_GUEST.type='bridge'
uci set network.br_GUEST.ports='eth0.107'
uci set network.br_GUEST.igmp_snooping='1'
uci commit network >/dev/null

uci add network device >/dev/null
uci rename network.@device[-1]='br_CMOVIE'
uci commit network >/dev/null
uci set network.br_CMOVIE.name='br-CMOVIE'
uci set network.br_CMOVIE.type='bridge'
uci set network.br_CMOVIE.ports='eth0.108'
uci set network.br_CMOVIE.igmp_snooping='1'
uci commit network >/dev/null

uci add network device >/dev/null
uci rename network.@device[-1]='br_SERVER'
uci commit network >/dev/null
uci set network.br_SERVER.name='br-SERVER'
uci set network.br_SERVER.type='bridge'
uci set network.br_SERVER.ports='eth0.101'
uci set network.br_SERVER.igmp_snooping='1'
uci commit network >/dev/null

uci add network device >/dev/null
uci rename network.@device[-1]='br_INET'
uci commit network >/dev/null
uci set network.br_INET.name='br-INET'
uci set network.br_INET.type='bridge'
uci set network.br_INET.ports='eth0.104'
uci set network.br_INET.igmp_snooping='1'
uci commit network >/dev/null

uci add network device >/dev/null
uci rename network.@device[-1]='br_CONTROL'
uci commit network >/dev/null
uci set network.br_CONTROL.name='br-CONTROL'
uci set network.br_CONTROL.type='bridge'
uci set network.br_CONTROL.ports='eth0.103'
uci set network.br_CONTROL.igmp_snooping='1'
uci commit network >/dev/null

uci add network device >/dev/null
uci rename network.@device[-1]='br_HCONTROL'
uci commit network >/dev/null
uci set network.br_HCONTROL.name='br-HCONTROL'
uci set network.br_HCONTROL.type='bridge'
uci set network.br_HCONTROL.ports='eth0.102'
uci set network.br_HCONTROL.igmp_snooping='1'
uci commit network >/dev/null


uci delete mwan3.wanb6
uci delete mwan3.wanb
uci delete mwan3.wanb_m1_w2
uci delete mwan3.wanb_m2_w2
uci delete mwan3.wanb6_m1_w2
uci delete mwan3.wanb6_m2_w2

uci set mwan3.http=rule
uci set mwan3.http.dest_port='80'
uci set mwan3.http.proto='tcp'
uci set mwan3.http.sticky='0'
uci set mwan3.http.ipset='filter6'
uci set mwan3.http.use_policy='balanced'
uci set mwan3.https=rule
uci set mwan3.https.sticky='1'
uci set mwan3.https.dest_port='443'
uci set mwan3.https.proto='tcp'
uci set mwan3.https.use_policy='balanced'
uci set mwan3.default_rule_v4=rule
uci set mwan3.default_rule_v4.dest_ip='0.0.0.0/0'
uci set mwan3.default_rule_v4.use_policy='balanced'
uci set mwan3.default_rule_v4.family='ipv4'
uci set mwan3.default_rule_v6=rule
uci set mwan3.default_rule_v6.dest_ip='::/0'
uci set mwan3.default_rule_v6.use_policy='balanced'
uci set mwan3.default_rule_v6.family='ipv6'
uci set mwan3.globals=globals
uci set mwan3.globals.mmx_mask='0x3F00'
uci set mwan3.globals.rtmon_interval='5'
uci set mwan3.wan=interface
uci set mwan3.wan.enabled='1'
uci set mwan3.wan.family='ipv4'
uci set mwan3.wan.reliability='2'
uci set mwan3.wan.count='1'
uci set mwan3.wan.timeout='2'
uci set mwan3.wan.interval='5'
uci set mwan3.wan.down='3'
uci set mwan3.wan.up='8'
uci set mwan3.wan.initial_state='online'
uci set mwan3.wan.track_method='ping'
uci set mwan3.wan.size='56'
uci set mwan3.wan.max_ttl='60'
uci set mwan3.wan.check_quality='0'
uci set mwan3.wan.failure_interval='5'
uci set mwan3.wan.recovery_interval='5'
uci set mwan3.wan.track_ip='1.1.1.3'
uci set mwan3.wan6=interface
uci set mwan3.wan6.family='ipv6'
uci set mwan3.wan6.reliability='2'
uci set mwan3.wan6.count='1'
uci set mwan3.wan6.timeout='2'
uci set mwan3.wan6.interval='5'
uci set mwan3.wan6.down='3'
uci set mwan3.wan6.up='8'
uci set mwan3.wan6.initial_state='online'
uci set mwan3.wan6.track_ip='2606:4700:4700::1113'
uci set mwan3.wan6.track_method='ping'
uci set mwan3.wan6.size='56'
uci set mwan3.wan6.max_ttl='60'
uci set mwan3.wan6.check_quality='0'
uci set mwan3.wan6.failure_interval='5'
uci set mwan3.wan6.recovery_interval='5'
uci set mwan3.wan6.enabled='1'
uci set mwan3.wan_m1_w3=member
uci set mwan3.wan_m1_w3.interface='wan'
uci set mwan3.wan_m1_w3.metric='1'
uci set mwan3.wan_m1_w3.weight='3'
uci set mwan3.wan_m2_w3=member
uci set mwan3.wan_m2_w3.interface='wan'
uci set mwan3.wan_m2_w3.metric='2'
uci set mwan3.wan_m2_w3.weight='3'
uci set mwan3.wan_mobile_m1_w2=member
uci set mwan3.wan_mobile_m1_w2.metric='1'
uci set mwan3.wan_mobile_m1_w2.weight='2'
uci set mwan3.wan_mobile_m1_w2.interface='wan_mobile'
uci set mwan3.wan_mobile_m2_w2=member
uci set mwan3.wan_mobile_m2_w2.metric='2'
uci set mwan3.wan_mobile_m2_w2.weight='2'
uci set mwan3.wan_mobile_m2_w2.interface='wan_mobile'
uci set mwan3.wan6_m1_w3=member
uci set mwan3.wan6_m1_w3.interface='wan6'
uci set mwan3.wan6_m1_w3.metric='1'
uci set mwan3.wan6_m1_w3.weight='3'
uci set mwan3.wan6_m2_w3=member
uci set mwan3.wan6_m2_w3.interface='wan6'
uci set mwan3.wan6_m2_w3.metric='2'
uci set mwan3.wan6_m2_w3.weight='3'
uci set mwan3.wan_mobile6_m1_w2=member
uci set mwan3.wan_mobile6_m1_w2.metric='1'
uci set mwan3.wan_mobile6_m1_w2.weight='2'
uci set mwan3.wan_mobile6_m1_w2.interface='wan_mobile6'
uci set mwan3.wan_mobile6_m2_w2=member
uci set mwan3.wan_mobile6_m2_w2.metric='2'
uci set mwan3.wan_mobile6_m2_w2.weight='2'
uci set mwan3.wan_mobile6_m2_w2.interface='wan_mobile6'
uci set mwan3.wan_only=policy
uci add_list mwan3.wan_only.use_member='wan_m1_w3' 
uci add_list mwan3.wan_only.use_member='wan6_m1_w3'
uci set mwan3.wan_mobile_only=policy
uci add_list mwan3.wan_mobile_only.use_member='wan_mobile_m1_w2'
uci add_list mwan3.wan_mobile_only.use_member='wan_mobile6_m1_w2'
uci set mwan3.balanced=policy
uci add_list mwan3.balanced.use_member='wan_m1_w3' 
uci add_list mwan3.balanced.use_member='wan_mobile_m1_w2'
uci add_list mwan3.balanced.use_member='wan6_m1_w3'
uci add_list mwan3.balanced.use_member='wan_mobile6_m1_w2'
uci set mwan3.wan_wan_mobile=policy
uci add_list mwan3.wan_wan_mobile.use_member='wan_m1_w3'
uci add_list mwan3.wan_wan_mobile.use_member='wan_mobile_m2_w2'
uci add_list mwan3.wan_wan_mobile.use_member='wan6_m1_w3'
uci add_list mwan3.wan_wan_mobile.use_member='wan_mobile6_m2_w2'
uci set mwan3.wan_mobile_wan=policy
uci add_list mwan3.wan_mobile_wan.use_member='wan_m2_w3'
uci add_list mwan3.wan_mobile_wan.use_member='wan_mobile_m1_w2'
uci add_list mwan3.wan_mobile_wan.use_member='wan6_m2_w3'
uci add_list mwan3.wan_mobile_wan.use_member='wan_mobile6_m1_w2'
uci set mwan3.wan_mobile=interface
uci set mwan3.wan_mobile.initial_state='online'
uci set mwan3.wan_mobile.family='ipv4'
uci set mwan3.wan_mobile.track_method='ping'
uci set mwan3.wan_mobile.count='1'
uci set mwan3.wan_mobile.size='56'
uci set mwan3.wan_mobile.max_ttl='60'
uci set mwan3.wan_mobile.check_quality='0'
uci set mwan3.wan_mobile.timeout='2'
uci set mwan3.wan_mobile.interval='5'
uci set mwan3.wan_mobile.failure_interval='5'
uci set mwan3.wan_mobile.recovery_interval='5'
uci set mwan3.wan_mobile.down='3'
uci set mwan3.wan_mobile.up='3'
uci set mwan3.wan_mobile.enabled='1'
uci set mwan3.wan_mobile.track_ip='1.1.1.3'
uci set mwan3.wan_mobile.reliability='2'
uci set mwan3.wan_mobile6=interface
uci set mwan3.wan_mobile6.initial_state='online'
uci set mwan3.wan_mobile6.track_method='ping'
uci set mwan3.wan_mobile6.count='1'
uci set mwan3.wan_mobile6.size='56'
uci set mwan3.wan_mobile6.max_ttl='60'
uci set mwan3.wan_mobile6.check_quality='0'
uci set mwan3.wan_mobile6.timeout='2'
uci set mwan3.wan_mobile6.interval='5'
uci set mwan3.wan_mobile6.failure_interval='5'
uci set mwan3.wan_mobile6.recovery_interval='5'
uci set mwan3.wan_mobile6.down='3'
uci set mwan3.wan_mobile6.up='3'
uci set mwan3.wan_mobile6.enabled='1'
uci set mwan3.wan_mobile6.family='ipv6'
uci set mwan3.wan_mobile6.track_ip='2606:4700:4700::1113'
uci set mwan3.wan_mobile6.reliability='2'
uci commit mwan3 && reload_config >/dev/null

echo '########################################################'
echo '#                                                      #'
echo '#                 CyberSecurity-Box                    #'
echo '#                                                      #'
echo '# local Privacy for Voice-Assistent Smart-TV SmartHome #'
echo '#                                                      #'
echo '#                Wireless Network Definitions          #'
echo '#                                                      #'
echo '########################################################'
echo 

# Save and apply
uci commit network && reload_config >/dev/null
#/etc/init.d/network restart

dig www.internic.net @1.1.1.1

uci -q delete wireless  >/dev/null

uci set wireless.radio0=wifi-device
uci set wireless.radio0.type='mac80211'
uci set wireless.radio0.path='platform/soc/a000000.wifi'
uci set wireless.radio0.htmode='HT20'
uci set wireless.radio0.country='DE'
uci set wireless.radio0.channel='6'
uci set wireless.radio0.hwmode='11n'

uci delete wireless.default_radio0
uci set wireless.default_radio0=wifi-iface
uci set wireless.default_radio0.device='radio0'
uci set wireless.default_radio0.mode='ap'
uci set wireless.default_radio0.key=$WIFI_PASS
uci set wireless.default_radio0.ssid=$CONTROL_ssid
uci set wireless.default_radio0.encryption='psk2'
uci set wireless.default_radio0.network='CONTROL'

uci delete wireless.wifinet1
uci set wireless.wifinet1=wifi-iface
uci set wireless.wifinet1.ssid=$HCONTROL_ssid
uci set wireless.wifinet1.encryption='psk2'
uci set wireless.wifinet1.device='radio0'
uci set wireless.wifinet1.mode='ap'
uci set wireless.wifinet1.network='HCONTROL'
uci set wireless.wifinet1.key=$WIFI_PASS

#uci delete wireless.wifinet2
#uci set wireless.wifinet2=wifi-iface
#uci set wireless.wifinet2.ssid=$VOICE_ssid
#uci set wireless.wifinet2.device='radio0'
#uci set wireless.wifinet2.mode='ap'
#uci set wireless.wifinet2.network='VOICE'
#uci set wireless.wifinet2.key=$WIFI_PASS
#uci set wireless.wifinet2.encryption='psk2'

#uci delete wireless.wifinet3
#uci set wireless.wifinet3=wifi-iface
#uci set wireless.wifinet3.ssid=$INET_ssid
#uci set wireless.wifinet3.encryption='psk2'
#uci set wireless.wifinet3.device='radio0'
#uci set wireless.wifinet3.mode='ap'
#uci set wireless.wifinet3.network='INET'
#uci set wireless.wifinet3.key=$WIFI_PASS

#uci delete wireless.wifinet4
#uci set wireless.wifinet4=wifi-iface
#uci set wireless.wifinet4.ssid=$ENTERTAIN_ssid
#uci set wireless.wifinet4.encryption='psk2'
#uci set wireless.wifinet4.device='radio0'
#uci set wireless.wifinet4.mode='ap'
#uci set wireless.wifinet4.network='ENTERTAIN'
#uci set wireless.wifinet4.key=$WIFI_PASS

#uci delete wireless.wifinet5
#uci set wireless.wifinet5=wifi-iface
#uci set wireless.wifinet5.ssid=$SERVER_ssid
#uci set wireless.wifinet5.encryption='psk2'
#uci set wireless.wifinet5.device='radio0'
#uci set wireless.wifinet5.mode='ap'
#uci set wireless.wifinet5.network='REPEATER'
#uci set wireless.wifinet5.key=$WIFI_PASS

#uci delete wireless.wifinet6
#uci set wireless.wifinet6=wifi-iface
#uci set wireless.wifinet6.ssid=$GUEST_ssid
#uci set wireless.wifinet6.encryption='psk2'
#uci set wireless.wifinet6.device='radio0'
#uci set wireless.wifinet6.mode='ap'
#uci set wireless.wifinet6.network='GUEST'
#uci set wireless.wifinet6.key=$WIFI_PASS

#uci set wireless.radio1=wifi-device
#uci set wireless.radio1.type='mac80211'
#uci set wireless.radio1.channel='36'
#uci set wireless.radio1.hwmode='11a'
#uci set wireless.radio1.path='platform/soc/a800000.wifi'
#uci set wireless.radio1.htmode='VHT80'
#uci set wireless.radio1.country='DE'

#uci delete wireless.default_radio1
#uci set wireless.default_radio1=wifi-iface
#uci set wireless.default_radio1.device='radio1'
#uci set wireless.default_radio1.mode='ap'
#uci set wireless.default_radio1.key=$WIFI_PASS
#uci set wireless.default_radio1.ssid=$VOICE_ssid
#uci set wireless.default_radio1.encryption='psk2'
#uci set wireless.default_radio1.network='VOICE'

#uci delete wireless.wifinet7
#uci set wireless.wifinet7=wifi-iface
#uci set wireless.wifinet7.ssid=$INET_ssid
#uci set wireless.wifinet7.encryption='psk2'
#uci set wireless.wifinet7.device='radio1'
#uci set wireless.wifinet7.mode='ap'
#uci set wireless.wifinet7.network='INET'
#uci set wireless.wifinet7.key=$WIFI_PASS

#uci delete wireless.wifinet8
#uci set wireless.wifinet8=wifi-iface
#uci set wireless.wifinet8.ssid=$ENTERTAIN_ssid
#uci set wireless.wifinet8.encryption='psk2'
#uci set wireless.wifinet8.device='radio1'
#uci set wireless.wifinet8.mode='ap'
#uci set wireless.wifinet8.network='ENTERTAIN'
#uci set wireless.wifinet8.key=$WIFI_PASS

#uci delete wireless.wifinet9
#uci set wireless.wifinet9=wifi-iface
#uci set wireless.wifinet9.device='radio1'
#uci set wireless.wifinet9.mode='ap'
#uci set wireless.wifinet9.ssid=$SERVER_ssid
#uci set wireless.wifinet9.encryption='psk2'
#uci set wireless.wifinet9.key=$WIFI_PASS
#uci set wireless.wifinet9.network='REPEATER'

#uci delete wireless.wifinet10
#uci set wireless.wifinet10=wifi-iface
#uci set wireless.wifinet10.encryption='psk2'
#uci set wireless.wifinet10.device='radio1'
#uci set wireless.wifinet10.mode='ap'
#uci set wireless.wifinet10.key=$WIFI_PASS
#uci set wireless.wifinet10.network='GUEST'
#uci set wireless.wifinet10.ssid=$GUEST_ssid

#uci delete wireless.wifinet11
#uci set wireless.wifinet11=wifi-iface
#uci set wireless.wifinet11.encryption=''
#uci set wireless.wifinet11.device='radio1'
#uci set wireless.wifinet11.mode='ap'
#uci set wireless.wifinet11.network='CMOVIE'
#uci set wireless.wifinet11.ssid=$CMOVIE_ssid

#uci delete wireless.wifinet12
#uci set wireless.wifinet12=wifi-iface
#uci set wireless.wifinet12.encryption=''
#uci set wireless.wifinet12.device='radio0'
#uci set wireless.wifinet12.mode='ap'
#uci set wireless.wifinet12.network='CMOVIE'
#uci set wireless.wifinet12.ssid=$CMOVIE_ssid

uci delete wireless.radio0.disabled >/dev/null
#uci delete wireless.radio1.disabled >/dev/null

uci commit  && reload_config >/dev/null

clear
echo '########################################################'
echo '#                                                      #'
echo '#                 CyberSecurity-Box                    #'
echo '#                                                      #'
echo '#                  Tor Definitions                     #'
echo '#                                                      #'
echo '########################################################'
echo
echo
echo 'Your Config is:'
echo
echo 'Client-WiFi SSID:     '$INET_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$INET_net
echo
echo 'Smarthome-WiFi SSID:  '$HCONTROL_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$HCONTROL_net
echo
echo 'Voice-Assistent SSID: '$VOICE_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$VOICE_net
echo
echo 'Smart-TV/-DVD SSID:   '$ENTERTAIN_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$ENTERTAIN_net
echo
echo 'Server-WiFi SSID:     '$SERVER_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$SERVER_net
echo
echo 'IR/BT-Control SSID:   '$CONTROL_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$CONTROL_net
echo
echo 'Guests SSID is:       '$GUEST_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$GUEST_net
echo
echo
echo
echo 'IP-Address:           '$ACCESS_SERVER
echo 'Gateway:              '$INET_GW
echo 'Domain:               '$LOCAL_DOMAIN
echo
echo 'GUI-Access:           https://'$INET_ip':8443'
echo 'User:                 '$USERNAME
echo 'Password:             password'
echo

/etc/init.d/tor stop >/dev/null
/etc/init.d/log restart >/dev/null

# Configure Tor client
cat << EOF > /etc/tor/main
AutomapHostsOnResolve 1
VirtualAddrNetworkIPV4 10.192.0.0/10
VirtualAddrNetworkIPv6 fc00::/7

SocksListenAddress 127.0.0.1
SocksListenAddress $(echo $SERVER_ip)
SocksListenAddress $(echo $HCONTROL_ip)
SocksListenAddress $(echo $CONTROL_ip)
SocksListenAddress $(echo $INET_ip)
SocksListenAddress [0::1]

ControlPort 127.0.0.1:9051
ControlPort [0::1]:9051
ControlPort $(echo $SERVER_ip):9051
ControlPort $(echo $HCONTROL_ip):9051
ControlPort $(echo $CONTROL_ip):9051
ControlPort $(echo $INET_ip):9051

DNSPort 127.0.0.1:9053
DNSPort 127.0.0.1:9153
DNSPort 127.0.0.1:853
DNSPort 127.0.10.1:53
DNSPort 127.0.0.1:54
DNSPort [0::1]:9053
DNSPort [0::1]:9153
DNSPort [0::1]:853
DNSPort [0::1]:54

DNSPort $(echo $SERVER_ip):9053
DNSPort $(echo $HCONTROL_ip):9053
DNSPort $(echo $CONTROL_ip):9053
DNSPort $(echo $INET_ip):9053

DNSPort $(echo $SERVER_ip):9153
DNSPort $(echo $HCONTROL_ip):9153
DNSPort $(echo $CONTROL_ip):9153
DNSPort $(echo $INET_ip):9153

DNSPort $(echo $SERVER_ip):54
DNSPort $(echo $HCONTROL_ip):54
DNSPort $(echo $CONTROL_ip):54
DNSPort $(echo $INET_ip):54

TransPort $(echo $SERVER_ip):9040 IsolateClientAddr IsolateClientProtocol IsolateDestAddr IsolateDestPort
TransPort $(echo $HCONTROL_ip):9040 IsolateClientAddr IsolateClientProtocol IsolateDestAddr IsolateDestPort
TransPort $(echo $CONTROL_ip):9040 IsolateClientAddr IsolateClientProtocol IsolateDestAddr IsolateDestPort
TransPort $(echo $INET_ip):9040 IsolateClientAddr IsolateClientProtocol IsolateDestAddr IsolateDestPort
TransPort 127.0.0.1:9040 IsolateClientAddr IsolateClientProtocol IsolateDestAddr IsolateDestPort
TransPort [0::1]:9040 IsolateClientAddr IsolateClientProtocol IsolateDestAddr IsolateDestPort

#SocksPort ist der Port für die Clientverbindung
SocksPort $(echo $SERVER_ip):9050
SocksPort $(echo $HCONTROL_ip):9050
SocksPort $(echo $CONTROL_ip):9050
SocksPort $(echo $INET_ip):9050
SocksPort 127.0.0.1:9050
SocksPort [0::1]:9050

SocksPort $(echo $SERVER_ip):9150
SocksPort $(echo $HCONTROL_ip):9150
SocksPort $(echo $CONTROL_ip):9150
SocksPort $(echo $INET_ip):9150
SocksPort 127.0.0.1:9150
SocksPort [0::1]:9150

#ORPort empfängt Daten aus dem Tor Netzwerk im Internet
#ORPort $(echo $WAN_ip):9049
#DirPort zum Spiegeln der Tor-Server-Adressen
#DirPort $(echo $WAN_ip):9030

HTTPTunnelPort $(echo $SERVER_ip):9060
HTTPTunnelPort $(echo $HCONTROL_ip):9060
HTTPTunnelPort $(echo $CONTROL_ip):9060
HTTPTunnelPort $(echo $INET_ip):9060
HTTPTunnelPort 127.0.0.1:9060
HTTPTunnelPort [0::1]:9060

#ExitPolicy reject *:*
#ExitPolicy stellt den Node Type ein. Hier Weiterleitung
#RelayBandwidthRate 10000 KB
#RelayBandwidthBurst 50000 KB
#BandwidthRate 10000 KB
#RelayBandwidthBurst 50000 KB
#DebuggerAttachment 0
#AccountingStart day 06:00
#AccountingMax 50 GBytes

NumCPUs 1

#Nur sichere Exitnodes Benutzen
StrictExitNodes 1 # war aktiv

ExcludeNodes {AU}, {CA}, {FR}, {GB}, {NZ}, {US}, {DE}, {CH}, {JP}, {FR}, {SE}, {DK}, {NL}, {NO}, {IT}, {ES}, {BE}, {BG}, {EE}, {FI}, {GR}, {IL}, {SG}, {KR}, {HR}, {LV}, {LT}, {LU}, {MT}, {NO}, {AT}, {PL}, {PT}, {RO}, {RU}, {SE}, {SK}, {SI}, {CZ}, {HU}, {CY}, {EU}

SafeSocks 1
WarnUnsafeSocks 1
#Log warn syslog
#Das Schreiben auf die Disk verringern AvoidDiskWrites 1
AvoidDiskWrites 1
RunAsDaemon 1
Nickname EnemyOneEU
AutomapHostsSuffixes .onion,.exit

## Tor hidden sites do not have real IP addresses. This specifies what range of
## IP addresses will be handed to the application as "cookies" for .onion names.
## Of course, you should pick a block of addresses which you aren't going to
## ever need to actually connect to. This is similar to the MapAddress feature
## of the main tor daemon.
## OnionAddrRange 127.42.42.0/24
##
## ServerDNSResolvConfFile filename
## ServerDNSAllowBrokenConfig 0|1
## ServerDNSSearchDomains 1
##
## CacheIPv4DNS 1
##
## HiddenServiceDir /home/pi/hidden_service/
## HiddenServicePort 80 192.168.175.250:80
##
## HiddenServiceDir /var/lib/tor/other_hidden_service/
## HiddenServicePort 80 127.0.0.1:80
## HiddenServicePort 22 127.0.0.1:22
##
## SOCKS5 Username and Password. This is used to isolate the torsocks connection
## circuit from other streams in Tor. Use with option IsolateSOCKSAuth (on by
## default) in tor(1). TORSOCKS_USERNAME and TORSOCKS_PASSWORD environment
## variable overrides these options.
## SOCKS5Username <username>
## SOCKS5Password <password>
##
## Log notice file /var/log/tor/tor-notices.log
DataDirectory /var/lib/tor
User tor

EOF


uci del_list tor.conf.tail_include="/etc/tor/main" >/dev/null
uci add_list tor.conf.tail_include="/etc/tor/main" >/dev/null

uci commit tor && reload_config >/dev/null

/etc/init.d/tor start  >/dev/null

echo '########################################################'
echo '#                                                      #'
echo '#                 CyberSecurity-Box                    #'
echo '#                                                      #'
echo '# local Privacy for Voice-Assistent Smart-TV SmartHome #'
echo '#                                                      #'
echo '#               Tor-Onion-Services activated           #'
echo '#                                                      #'
echo '########################################################'
echo 

#Configure stubby
cat << EOF > /etc/config/stubby
config stubby 'global'
       option manual '0'
       option trigger 'wan'
       # option triggerdelay '2'
       list dns_transport 'GETDNS_TRANSPORT_TLS'
       option tls_authentication '1'
       option tls_query_padding_blocksize '128'
       # option tls_connection_retries '2'
       # option tls_backoff_time '3600'
       # option timeout '5000'
       # option dnssec_return_status '0'
       option appdata_dir '/var/lib/stubby'
       # option trust_anchors_backoff_time 2500
       # option dnssec_trust_anchors '/var/lib/stubby/getdns-root.key'
       option edns_client_subnet_private '1'
       option idle_timeout '10000'
       option round_robin_upstreams '1'
       list listen_address '127.0.0.1@$(echo $DNS_STUBBY_port)'
       list listen_address '0::1@$(echo $DNS_STUBBY_port)'
       list listen_address '$(echo $INET_ip)@$(echo $DNS_STUBBY_port)'
       list listen_address '$(echo $SERVER_ip)@$(echo $DNS_STUBBY_port)'
       list listen_address '$(echo $HCONTROL_ip)@$(echo $DNS_STUBBY_port)'
       list listen_address '$(echo $CONTROL_ip)@$(echo $DNS_STUBBY_port)'
       list listen_address '$(echo $VOICE_ip)@$(echo $DNS_STUBBY_port)'
       list listen_address '$(echo $GUEST_ip)@$(echo $DNS_STUBBY_port)'
       list listen_address '$(echo $ENTERTAIN_ip)@$(echo $DNS_STUBBY_port)'
       # option log_level '7'
       # option command_line_arguments ''
       # option tls_cipher_list 'EECDH+AESGCM:EECDH+CHACHA20'
       # option tls_ciphersuites 'TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:TLS_AES_128_GCM_SHA256'
       option tls_min_version '1.2'
       # option tls_max_version '1.3'

config resolver
        option address '1.1.1.3'
        option tls_auth_name 'family.cloudflare-dns.com'


config resolver
        option address '1.0.0.3'
        option tls_auth_name 'family.cloudflare-dns.com'


#config resolver
#        option address '80.241.218.68'
#        option tls_auth_name 'fdns1.dismail.de'
#        list spki 'sha256/MMi3E2HZr5A5GL+badqe3tzEPCB00+OmApZqJakbqUU='

#config resolver
#        option address '46.182.19.48'
#        option tls_auth_name 'dns2.digitalcourage.de'
#        list spki 'sha256/v7rm6OtQQD3x/wbsdHDZjiDg+utMZvnoX3jq3Vi8tGU='


EOF

uci commit stubby && reload_config >/dev/null

/etc/init.d/stubby restart  >/dev/null
# Configure unbound client

echo
echo '########################################################'
echo '#                                                      #'
echo '#                 CyberSecurity-Box                    #'
echo '#                                                      #'
echo '# local Privacy for Voice-Assistent Smart-TV SmartHome #'
echo '#                                                      #'
echo '#         Stubby Pivaticy over cloudflair.com          #'
echo '#                                                      #'
echo '########################################################'
echo 
echo

/etc/init.d/unbound stop  >/dev/null
/etc/init.d/log restart  >/dev/null

#Configure stubby
cat << EOF > /etc/unbound/unbound_srv.conf

##############################################################################
# User custom options added in the server: clause part of UCI 'unbound.conf'
#
# Add your own option statements here when they are not covered by UCI. This
# file is placed _inside_ the server: clause with an include: statement. Do
# not start other clauses here, because that would brake the server: clause.
# Use 'unbound_ext.conf' to start new clauses at the end of 'unbound.conf'.
##############################################################################
server:

local-zone: "onion" nodefault 
local-zone: "exit" nodefault
local-zone: $INET_domain nodefault
local-zone: $SERVER_domain nodefault
local-zone: $HCONTROL_domain nodefault
local-zone: $CONTROL_domain nodefault
local-zone: $VOICE_domain nodefault
local-zone: $GUEST_domain nodefault
local-zone: $ENTERTAIN_domain nodefault
local-zone: $CMOVIE_domain nodefault

domain-insecure: "onion"
domain-insecure: "exit"
domain-insecure: $CMOVIE_domain
domain-insecure: $ENTERTAIN_domain
domain-insecure: $GUEST_domain
domain-insecure: $VOICE_domain
domain-insecure: $CONTROL_domain
domain-insecure: $HCONTROL_domain
domain-insecure: $SERVER_domain
domain-insecure: $INET_domain

private-domain: $INET_domain
private-address: $INET_net
private-domain: $SERVER_domain
private-address: $SERVER_net
private-domain: $HCONTROL_domain
private-address: $HCONTROL_net
private-domain: $CONTROL_domain
private-address: $CONTROL_net
private-domain: $VOICE_domain
private-address: $VOICE_net
private-domain: $GUEST_domain
private-address: $GUEST_net
private-domain: $ENTERTAIN_domain
private-address: $ENTERTAIN_net
private-domain: $CMOVIE_domain
private-address: $CMOVIE_net

#local-zone: "onion." static
#local-data: "onion. 10800 IN NS localhost. @9053"
#local-data: "onion. 10800 IN SOA localhost. nobody.invalid. 1 3600 1200 604800 10800 @9053"

local-data: "dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion.  IN A 127.0.0.1"
local-data-ptr: "127.0.0.1 dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion"
local-data: "duckduckgogg42xjoc72x3sjasowoarfbgcmvfimaftt6twagswzczad.onion. 60 IN A 10.251.96.119"
local-data-ptr: "10.251.96.119 duckduckgogg42xjoc72x3sjasowoarfbgcmvfimaftt6twagswzczad.onion"

#Security Agentcy
local-zone: "us-gov.amazonaws.com" always_null
local-zone: "us-gov-east-1.amazonaws.com" always_null
local-zone: "us-gov-east-2.amazonaws.com" always_null
local-zone: "us-gov-east-3.amazonaws.com" always_null
local-zone: "us-gov-east-4.amazonaws.com" always_null
local-zone: "us-gov-east-5.amazonaws.com" always_null
local-zone: "us-gov-west-1.amazonaws.com" always_null
local-zone: "us-gov-west-2.amazonaws.com" always_null
local-zone: "us-gov-west-3.amazonaws.com" always_null
local-zone: "us-gov-west-4.amazonaws.com" always_null
local-zone: "us-gov-west-5.amazonaws.com" always_null
local-zone: "us-gov-south-1.amazonaws.com" always_null
local-zone: "us-gov-south-2.amazonaws.com" always_null
local-zone: "us-gov-south-3.amazonaws.com" always_null
local-zone: "us-gov-south-4.amazonaws.com" always_null
local-zone: "us-gov-south-5.amazonaws.com" always_null
local-zone: "us-gov-north-1.amazonaws.com" always_null
local-zone: "us-gov-north-2.amazonaws.com" always_null
local-zone: "us-gov-north-3.amazonaws.com" always_null
local-zone: "us-gov-north-4.amazonaws.com" always_null
local-zone: "us-gov-north-5.amazonaws.com" always_null
local-zone: "cn-north-1.amazonaws.com.cn" always_null
local-zone: "cn-north-2.amazonaws.com.cn" always_null
local-zone: "cn-north-3.amazonaws.com.cn" always_null
local-zone: "cn-north-4.amazonaws.com.cn" always_null
local-zone: "cn-north-5.amazonaws.com.cn" always_null
local-zone: "cn-northwest-1.amazonaws.com.cn" always_null
local-zone: "cn-northwest-2.amazonaws.com.cn" always_null
local-zone: "cn-northwest-3.amazonaws.com.cn" always_null
local-zone: "cn-northwest-4.amazonaws.com.cn" always_null
local-zone: "cn-northwest-5.amazonaws.com.cn" always_null
local-zone: "cn-northeast-1.amazonaws.com.cn" always_null
local-zone: "cn-northeast-2.amazonaws.com.cn" always_null
local-zone: "cn-northeast-3.amazonaws.com.cn" always_null
local-zone: "cn-northeast-4.amazonaws.com.cn" always_null
local-zone: "cn-northeast-5.amazonaws.com.cn" always_null
local-zone: "cn-north-1.amazonaws.com.cn" always_null
local-zone: "cn-north-2.amazonaws.com.cn" always_null
local-zone: "cn-north-3.amazonaws.com.cn" always_null
local-zone: "cn-north-4.amazonaws.com.cn" always_null
local-zone: "cn-north-5.amazonaws.com.cn" always_null
local-zone: "cn-southwest-1.amazonaws.com.cn" always_null
local-zone: "cn-southwest-2.amazonaws.com.cn" always_null
local-zone: "cn-southwest-3.amazonaws.com.cn" always_null
local-zone: "cn-southwest-4.amazonaws.com.cn" always_null
local-zone: "cn-southwest-5.amazonaws.com.cn" always_null
local-zone: "cn-southeast-1.amazonaws.com.cn" always_null
local-zone: "cn-southeast-2.amazonaws.com.cn" always_null
local-zone: "cn-southeast-3.amazonaws.com.cn" always_null
local-zone: "cn-southeast-4.amazonaws.com.cn" always_null
local-zone: "cn-southeast-5.amazonaws.com.cn" always_null
local-zone: "us-gov.compute.amazonaws.com" always_null
local-zone: "us-gov-east-1.compute.amazonaws.com" always_null
local-zone: "us-gov-east-2.compute.amazonaws.com" always_null
local-zone: "us-gov-east-3.compute.amazonaws.com" always_null
local-zone: "us-gov-east-4.compute.amazonaws.com" always_null
local-zone: "us-gov-east-5.compute.amazonaws.com" always_null
local-zone: "us-gov-west-1.compute.amazonaws.com" always_null
local-zone: "us-gov-west-2.compute.amazonaws.com" always_null
local-zone: "us-gov-west-3.compute.amazonaws.com" always_null
local-zone: "us-gov-west-4.compute.amazonaws.com" always_null
local-zone: "us-gov-west-5.compute.amazonaws.com" always_null
local-zone: "us-gov-south-1.compute.amazonaws.com" always_null
local-zone: "us-gov-south-2.compute.amazonaws.com" always_null
local-zone: "us-gov-south-3.compute.amazonaws.com" always_null
local-zone: "us-gov-south-4.compute.amazonaws.com" always_null
local-zone: "us-gov-south-5.compute.amazonaws.com" always_null
local-zone: "us-gov-north-1.compute.amazonaws.com" always_null
local-zone: "us-gov-north-2.compute.amazonaws.com" always_null
local-zone: "us-gov-north-3.compute.amazonaws.com" always_null
local-zone: "us-gov-north-4.compute.amazonaws.com" always_null
local-zone: "us-gov-north-5.compute.amazonaws.com" always_null
local-zone: "cn-north-1.compute.amazonaws.com.cn" always_null
local-zone: "cn-north-2.compute.amazonaws.com.cn" always_null
local-zone: "cn-north-3.compute.amazonaws.com.cn" always_null
local-zone: "cn-north-4.compute.amazonaws.com.cn" always_null
local-zone: "cn-north-5.compute.amazonaws.com.cn" always_null
local-zone: "cn-northwest-1.compute.amazonaws.com.cn" always_null
local-zone: "cn-northwest-2.compute.amazonaws.com.cn" always_null
local-zone: "cn-northwest-3.compute.amazonaws.com.cn" always_null
local-zone: "cn-northwest-4.compute.amazonaws.com.cn" always_null
local-zone: "cn-northwest-5.compute.amazonaws.com.cn" always_null
local-zone: "cn-northeast-1.compute.amazonaws.com.cn" always_null
local-zone: "cn-northeast-2.compute.amazonaws.com.cn" always_null
local-zone: "cn-northeast-3.compute.amazonaws.com.cn" always_null
local-zone: "cn-northeast-4.compute.amazonaws.com.cn" always_null
local-zone: "cn-northeast-5.compute.amazonaws.com.cn" always_null
local-zone: "cn-north-1.compute.amazonaws.com.cn" always_null
local-zone: "cn-north-2.compute.amazonaws.com.cn" always_null
local-zone: "cn-north-3.compute.amazonaws.com.cn" always_null
local-zone: "cn-north-4.compute.amazonaws.com.cn" always_null
local-zone: "cn-north-5.compute.amazonaws.com.cn" always_null
local-zone: "cn-southwest-1.compute.amazonaws.com.cn" always_null
local-zone: "cn-southwest-2.compute.amazonaws.com.cn" always_null
local-zone: "cn-southwest-3.compute.amazonaws.com.cn" always_null
local-zone: "cn-southwest-4.compute.amazonaws.com.cn" always_null
local-zone: "cn-southwest-5.compute.amazonaws.com.cn" always_null
local-zone: "cn-southeast-1.compute.amazonaws.com.cn" always_null
local-zone: "cn-southeast-2.compute.amazonaws.com.cn" always_null
local-zone: "cn-southeast-3.compute.amazonaws.com.cn" always_null
local-zone: "cn-southeast-4.compute.amazonaws.com.cn" always_null
local-zone: "cn-southeast-5.compute.amazonaws.com.cn" always_null

local-zone: "fbi.gov" always_null
local-zone: "cia.gov" always_null
local-zone: "nsa.gov" always_null
local-zone: "dia.gov" always_null
local-zone: "bnd.de" always_null
local-zone: "bka.de" always_null
local-zone: "lka.de" always_null
local-zone: "mad.de" always_null
local-zone: "mil.de" always_null
local-zone: "cia.de" always_null
local-zone: "nsa.de" always_null
local-zone: "fbi.de" always_null
local-zone: "bka.de" always_null
local-zone: "lka.de" always_null
local-zone: "bnd.de" always_null
local-zone: "mad.de" always_null
local-zone: "bavsa.de" always_null
local-zone: "gov.de" always_null
local-zone: "goverment.de" always_null
local-zone: "bnd.at" always_null
local-zone: "bka.at" always_null
local-zone: "lka.at" always_null
local-zone: "mad.at" always_null
local-zone: "mil.at" always_null
local-zone: "cia.at" always_null
local-zone: "nsa.at" always_null
local-zone: "fbi.at" always_null
local-zone: "bka.at" always_null
local-zone: "lka.at" always_null
local-zone: "bnd.at" always_null
local-zone: "mad.at" always_null
local-zone: "cobra.at" always_null
local-zone: "bavsa.at" always_null
local-zone: "gov.at" always_null
local-zone: "bnd.ch" always_null
local-zone: "bka.ch" always_null
local-zone: "lka.ch" always_null
local-zone: "mad.ch" always_null
local-zone: "mil.ch" always_null
local-zone: "cia.ch" always_null
local-zone: "nsa.ch" always_null
local-zone: "fbi.ch" always_null
local-zone: "bka.ch" always_null
local-zone: "lka.ch" always_null
local-zone: "bnd.ch" always_null
local-zone: "mad.ch" always_null
local-zone: "bavsa.ch" always_null
local-zone: "gov.ch" always_null
local-zone: "goverment.ch" always_null
local-zone: "bnd.eu" always_null
local-zone: "bka.eu" always_null
local-zone: "lka.eu" always_null
local-zone: "mad.eu" always_null
local-zone: "mil.eu" always_null
local-zone: "cia.eu" always_null
local-zone: "nsa.eu" always_null
local-zone: "fbi.eu" always_null
local-zone: "bka.eu" always_null
local-zone: "lka.eu" always_null
local-zone: "bnd.eu" always_null
local-zone: "mad.eu" always_null
local-zone: "bavsa.eu" always_null
local-zone: "gov.eu" always_null
local-zone: "goverment.eu" always_null
local-zone: "mil.com" always_null
local-zone: "cia.com" always_null
local-zone: "nsa.com" always_null
local-zone: "fbi.com" always_null
local-zone: "bka.com" always_null
local-zone: "lka.com" always_null
local-zone: "bnd.com" always_null
local-zone: "mad.com" always_null
local-zone: "bavsa.com" always_null
local-zone: "bvs.com" always_null
local-zone: "gov.com" always_null
local-zone: "goverment" always_null
local-zone: "mil" always_null
local-zone: "cia" always_null
local-zone: "nsa" always_null
local-zone: "fbi" always_null
local-zone: "bka" always_null
local-zone: "lka" always_null
local-zone: "bnd" always_null
local-zone: "mad" always_null
local-zone: "bavsa" always_null
local-zone: "bvs" always_null
local-zone: "gov" always_null


#Whitelist

local-zone: "microsoftconnecttest.com" transparent
local-zone: "msftncsi.com" transparent
local-zone: "clients3.google.com" transparent
local-zone: "connectivitycheck.gstatic.com" transparent
local-zone: "detectportal.firefox.com" transparent
local-zone: "tplinkcloud.com" transparent
local-zone: "captive.apple.com" transparent

local-zone: "7tv.com" transparent
local-zone: "7tv.de" transparent
local-zone: "accuweather.com" transparent
local-zone: "accuweather.de" transparent
local-zone: "aio-control.com" transparent
local-zone: "aio-control.de" transparent
local-zone: "aio-controls.com" transparent
local-zone: "aio-controls.de" transparent
local-zone: "akamaihd.net" transparent
local-zone: "alexasounds.com" transparent
local-zone: "alice.de" transparent
local-zone: "alice.net" transparent
local-zone: "alice-dsl.de" transparent
local-zone: "alice-dsl.net" transparent
local-zone: "amazon.co.uk" transparent
local-zone: "amazon.com" transparent
local-zone: "amazonsilk.com" transparent
local-zone: "amazon.de" transparent
local-zone: "amazon.eu" transparent
local-zone: "amazonaws.co.uk" transparent
local-zone: "amazon" transparent
local-zone: "mlis.amazon.eu" transparent
local-zone: "spectrum.s3.amazonaws.com" transparent
local-zone: "amazonaws.com" transparent
local-zone: "amazonaws.de" transparent
local-zone: "a2z.com" transparent
local-zone: "images-amazon.com" transparent
local-zone: "andreas-stawinski.de" transparent
local-zone: "android.clients.google.com" transparent
local-zone: "antenne.de" transparent
local-zone: "api.amazonalexa.com" transparent
local-zone: "api.co.uk.amazonalexa.com" transparent
local-zone: "api.crittercism.com" transparent
local-zone: "api.eu.amazonalexa.com" transparent
local-zone: "amazonvideo.com" transparent
local-zone: "api-global.netflix.com" transparent
local-zone: "openwrt.org" transparent
local-zone: "raspbery.org" transparent
local-zone: "apple.com" transparent
local-zone: "mzstatic.com" transparent
local-zone: "apple.de" transparent
local-zone: "ard.de" transparent
local-zone: "ardmediathek.de" transparent
local-zone: "arte.de" transparent
local-zone: "avm.de" transparent
local-zone: "bing.de" transparent
local-zone: "br.de" transparent
local-zone: "br24.com" transparent
local-zone: "br-24.com" transparent
local-zone: "br24.de" transparent
local-zone: "br-24.de" transparent
local-zone: "cddbp.net" transparent
local-zone: "chip.de" transparent
local-zone: "chip.smarttv.cellular.de" transparent
local-zone: "cinepass.com" transparent
local-zone: "cinepass.de" transparent
local-zone: "cloud.mediola.com" transparent
local-zone: "cloudfront.net" transparent
local-zone: "cloudflare-dns.com" transparent
local-zone: "cloudflare.com" transparent
local-zone: "connectors.yonomi.co" transparent
local-zone: "connectors.yonomi.com" transparent
local-zone: "content.dhg.myharmony.com" transparent
local-zone: "ct.de" transparent
local-zone: "cyberandi.blog" transparent
local-zone: "cyberandi.com" transparent
local-zone: "cyberandi.de" transparent
local-zone: "cyberandi.eu" transparent
local-zone: "daserste.de" transparent
local-zone: "deutschewelle.com" transparent
local-zone: "deutschewelle.de" transparent
local-zone: "directions.com" transparent
local-zone: "directions.de" transparent
local-zone: "dnssec-or-not.com" transparent
local-zone: "dnssec.vs.uni-due.de" transparent
local-zone: "dw.com" transparent
local-zone: "dw.de" transparent
local-zone: "elasticbeanstalk.com" transparent
local-zone: "epg.corio.com" transparent
local-zone: "erf.de" transparent
local-zone: "erf1.de" transparent
local-zone: "erste.de" transparent
local-zone: "filmstarts.de" transparent
local-zone: "focus.de" transparent
local-zone: "fireoscaptiveportal.com" transparent
local-zone: "freestream.nmdn.net" transparent
local-zone: "fritz.box" transparent
local-zone: "flip.it" transparent
local-zone: "ftp.stawimedia.de" transparent
local-zone: "github.io" transparent
local-zone: "github.de" transparent
local-zone: "github.com" transparent
local-zone: "galileo.de" transparent
local-zone: "gallileo.com" transparent
local-zone: "geonames.org" transparent
local-zone: "getinvoked.com" transparent
local-zone: "ggpht.com" transparent
local-zone: "googleapis.com" transparent
local-zone: "google.com" transparent
local-zone: "googlevideo.com" transparent
local-zone: "gracenote.com" transparent
local-zone: "gvt1.com" transparent
local-zone: "harmonyremote.com" transparent
local-zone: "harmony-remote.com" transparent
local-zone: "harmonyremote.de" transparent
local-zone: "harmony-remote.de" transparent
local-zone: "hbbtv" transparent
local-zone: "heise.de" transparent
local-zone: "heise-online.de" transparent
local-zone: "heute.de" transparent
local-zone: "hinter.bibeltv.de" transparent
local-zone: "home.stawimedia.de" transparent
local-zone: "hotmail.com" transparent
local-zone: "hotmail.de" transparent
local-zone: "ichnaea.netflix.com" transparent
local-zone: "icloud.com" transparent
local-zone: "icloud.de" transparent
local-zone: "ifttt.com" transparent
local-zone: "ihealthlabs.com" transparent
local-zone: "imdb.com" transparent
local-zone: "imdb.de" transparent
local-zone: "invokedapps.com" transparent
local-zone: "invokedapps.org" transparent
local-zone: "ipleak.net" transparent
local-zone: "ix.nflxvideo.net" transparent
local-zone: "ix.nflxvideo.net" transparent
local-zone: "ism" transparent
local-zone: "it-business.com" transparent
local-zone: "it-business.de" transparent
local-zone: "itunes.com" transparent
local-zone: "ix.de" transparent
local-zone: "ix.nflxvideo.net" transparent
local-zone: "ix.nflxvideo.net" transparent
local-zone: "joyn.de" transparent
local-zone: "api.segment.io" transparent
local-zone: "seventv.com" transparent
local-zone: "route71.net" transparent
local-zone: "ak-t1p-vod-playout-prod.akamaized.net" transparent
local-zone: "prosieben-ctr.live.ott.irdeto.com" transparent
local-zone: "p7s1video.net" transparent
local-zone: "joyn.net" transparent
local-zone: "joyn.tv" transparent
local-zone: "joyn.com" transparent
local-zone: "kabeleins.de" transparent
local-zone: "laut.fm" transparent
local-zone: "live.com" transparent
local-zone: "live.de" transparent
local-zone: "llnwd.net" transparent
local-zone: "llnwd.net" transparent
local-zone: "logging.dhg.myharmony.com" transparent
local-zone: "m.media-amazon.com" transparent
local-zone: "m.tvinfo.de" transparent
local-zone: "macandi.de" transparent
local-zone: "mediola.com" transparent
local-zone: "mediola.de" transparent
local-zone: "members.harmonyremote.com" transparent
local-zone: "metafilegenerator.de" transparent
local-zone: "microsoft.com" transparent
local-zone: "microsoft.de" transparent
local-zone: "mobile.chip.de" transparent
local-zone: "myfritz.net" transparent
local-zone: "myharmony.com" transparent
local-zone: "myharmony.de" transparent
local-zone: "myharmony.net" transparent
local-zone: "myremotesetup.com" transparent
local-zone: "mytvscout.de" transparent
local-zone: "n24.de" transparent
local-zone: "push.prod.netflix.com" transparent
local-zone: "nccp.netflix.com" transparent
local-zone: "uiboot.netflix.com" transparent
local-zone: "secure.netflix.com" transparent
local-zone: "customerevents.netflix.com" transparent
local-zone: "netflix.com" transparent
local-zone: "netflix.de" transparent
local-zone: "nflximg.com" transparent
local-zone: "nflximg.net" transparent
local-zone: "nflxvideo.com" transparent
local-zone: "nflxvideo.de" transparent
local-zone: "nflxvideo.net" transparent
local-zone: "nflxso.net" transparent
local-zone: "nfximg.net" transparent
local-zone: "nflxso.com" transparent
local-zone: "nfximg.com" transparent
local-zone: "nflxso.de" transparent
local-zone: "nfximg.de" transparent
local-zone: "nodejs.org" transparent
local-zone: "no-ip.biz" transparent
local-zone: "nokia.com" transparent
local-zone: "nokia.de" transparent
local-zone: "npmjs.com" transparent
local-zone: "ntp.org" transparent
local-zone: "n-tv.de" transparent
local-zone: "o2.box" transparent
local-zone: "office.com" transparent
local-zone: "office.de" transparent
local-zone: "office365.com" transparent
local-zone: "office365.de" transparent
local-zone: "onlinewetter.com" transparent
local-zone: "onlinewetter.de" transparent
local-zone: "opendns.com" transparent
local-zone: "openstreetmap.com" transparent
local-zone: "openstreetmap.de" transparent
local-zone: "openstreetmap.org" transparent
local-zone: "outlook.com" transparent
local-zone: "outlook.de" transparent
local-zone: "outlook.live.com" transparent
local-zone: "pcwelt.de" transparent
local-zone: "pc-welt.de" transparent
local-zone: "philips.com" transparent
local-zone: "philips.de" transparent
local-zone: "philips.nl" transparent
local-zone: "phobos.apple.com" transparent
local-zone: "phobos.apple.com.edgesuite.net" transparent
local-zone: "photos.apple.de" transparent
local-zone: "photos.apple.com.edgesuite.net" transparent
local-zone: "pionieer.com" transparent
local-zone: "play.google.com" transparent
local-zone: "playstation.com" transparent
local-zone: "prosieben.de" transparent
local-zone: "ps3.com" transparent
local-zone: "pubsub.pubnub.com" transparent
local-zone: "pubnub.com" transparent
local-zone: "radio.de" transparent
local-zone: "radiogong.de" transparent
local-zone: "radiotime.com" transparent
local-zone: "remotes.aio-control.com" transparent
local-zone: "remotes.aio-control.de" transparent
local-zone: "remotes.aio-controls.com" transparent
local-zone: "remotes.aio-controls.de" transparent
local-zone: "remotesneo.aio-control.com" transparent
local-zone: "resolver1.opendns.com" transparent
local-zone: "resolver2.opendns.com" transparent
local-zone: "resolver3.opendns.com" transparent
local-zone: "resolver4.opendns.com" transparent
local-zone: "rtl.de" transparent
local-zone: "rtl2.de" transparent
local-zone: "s3-directional-w.amazonaws.com" transparent
local-zone: "samsung.com" transparent
local-zone: "sat1.de" transparent
local-zone: "script.ioam.de" transparent
local-zone: "shoutcast.com" transparent
local-zone: "sony.com" transparent
local-zone: "spn.com" transparent
local-zone: "startpage.com" transparent
local-zone: "startpage.de" transparent
local-zone: "startpage.nl" transparent
local-zone: "stawimedia.de" transparent
local-zone: "stawimedia.eu" transparent
local-zone: "stawimedia.local" transparent
local-zone: "stream.erf.de" transparent
local-zone: "streamfarm.net" transparent
local-zone: "sus.dhg.myharmony.com" transparent
local-zone: "svcs.myharmony.com" transparent
local-zone: "t3n.de" transparent
local-zone: "telegram.org" transparent
local-zone: "t.me" transparent
local-zone: "tagesschau.de" transparent
local-zone: "tagesschau24.de" transparent
local-zone: "time.nist.gov" transparent
local-zone: "time.windows.com" transparent
local-zone: "torproject.org" transparent
local-zone: "tumblr.com" transparent
local-zone: "tumblr.de" transparent
local-zone: "tumblr.org" transparent
local-zone: "tune_in.com" transparent
local-zone: "tune_in.de" transparent
local-zone: "tunein.com" transparent
local-zone: "tune-in.com" transparent
local-zone: "tunein.de" transparent
local-zone: "tune-in.de" transparent
local-zone: "tvnow.com" transparent
local-zone: "tvnow.de" transparent
local-zone: "twitter.de" transparent
local-zone: "twitter.com" transparent
local-zone: "t.co" transparent
local-zone: "tvtv.de" transparent
local-zone: "unifiedlayer.com" transparent
local-zone: "vevo.com" transparent
local-zone: "vevo.de" transparent
local-zone: "video.google.com" transparent
local-zone: "videobuster.com" transparent
local-zone: "videobuster.de" transparent
local-zone: "videociety.com" transparent
local-zone: "videociety.de" transparent
local-zone: "vimeo.com" transparent
local-zone: "vimeo.de" transparent
local-zone: "wbsapi.withings.net" transparent
local-zone: "waipu.tv" transparent
local-zone: "waipu.de" transparent
local-zone: "waipu.com" transparent
local-zone: "whatismyip.com" transparent
local-zone: "wpstr.tv" transparent
local-zone: "waipu.ch" transparent
local-zone: "weather.com" transparent
local-zone: "weather.de" transparent
local-zone: "welt.de" transparent
local-zone: "wetter.com" transparent
local-zone: "wetter.de" transparent
local-zone: "wetteronline.de" transparent
local-zone: "wetter-online.de" transparent
local-zone: "wikimedia.org" transparent
local-zone: "wikipedia.de" transparent
local-zone: "wikipedia.org" transparent
local-zone: "wikipedia.com" transparent
local-zone: "withings.com" transparent
local-zone: "withings.net" transparent
local-zone: "ws.withings.net" transparent
local-zone: "wunderlist.com" transparent
local-zone: "y2u.be" transparent
local-zone: "yelp.co.uk" transparent
local-zone: "yelp.com" transparent
local-zone: "yelp.de" transparent
local-zone: "yelp.org" transparent
local-zone: "yelpcdn.com" transparent
local-zone: "yonomi.co" transparent
local-zone: "yonomi.com" transparent
local-zone: "youtu.be" transparent
local-zone: "youtube.com" transparent
local-zone: "youtube-nocookie.com" transparent
local-zone: "ytimg.com" transparent
local-zone: "zattoo.ch" transparent
local-zone: "zattoo.co.uk" transparent
local-zone: "zattoo.com" transparent
local-zone: "zattoo.de" transparent
local-zone: "zattic.com" transparent
local-zone: "zahs.tv" transparent
local-zone: "zattoo.eu" transparent
local-zone: "zdf.de" transparent
local-zone: "zdf-cdn.live.cellular.de" transparent
local-zone: "dlive.com" transparent
local-zone: "dlive.tv" transparent
local-zone: "twitch.de" transparent
local-zone: "twitch.com" transparent
local-zone: "twitch.org" transparent
local-zone: "twitchcdn.net" transparent
local-zone: "ttvnw.net" transparent
local-zone: "jtvnw.net" transparent
local-zone: "twitch.tv" transparent
local-zone: "disneyplus.de" transparent
local-zone: "disney+.de" transparent
local-zone: "disneyplus.com" transparent
local-zone: "disney+.com" transparent
local-zone: "disneyplus.tv" transparent
local-zone: "bamgrid.com" transparent
local-zone: "bam.nr-data.net" transparent
local-zone: "cdn.registerdisney.go.com" transparent
local-zone: "cws.convia.com" transparent
local-zone: "d9.flashtalking.com" transparent
local-zone: "disney-portal.my.onetrust.com" transparent
local-zone: "disneyplus.bn5x.net" transparent
local-zone: "js-agent.newrelic.com" transparent
local-zone: "disney-plus.net" transparent
local-zone: "dssott.com" transparent
local-zone: "adobedtm.com" transparent
local-zone: "disney+.tv" transparent
local-zone: "pluto.de" transparent
local-zone: "pluto.com" transparent
local-zone: "pluto.tv" transparent
local-zone: "tvnow.de" transparent
local-zone: "tvnow.com" transparent
local-zone: "tvnow.tv" transparent
local-zone: "duckduck.go" transparent
local-zone: "duckduckgo.de" transparent
local-zone: "duckduckgo.com" transparent
local-zone: "fireoscaptiveportal.com" transparent
local-zone: "bitchute.com" transparent
local-zone: "bitchute.tv" transparent
local-zone: "instagram.de" transparent
local-zone: "instagram.com" transparent
local-zone: "pinterest.com" transparent
local-zone: "pinterest.de" transparent
local-zone: "pinterest.org" transparent
local-zone: "flickr.com" transparent
local-zone: "flickr.de" transparent
local-zone: "flickr.org" transparent
local-zone: "imdb.tv" transparent
local-zone: "imdb.com" transparent
local-zone: "imdb.de" transparent
local-zone: "imdb.org" transparent
local-zone: "you2.be" transparent
local-zone: "youtu.be" transparent
local-zone: "spotify.com" transparent
local-zone: "spotify.de" transparent
local-zone: "spotify.net" transparent
local-zone: "github.io" transparent
local-zone: "git.io" transparent
local-zone: "dlvr.it" transparent
local-zone: "www.bit.ly" transparent
local-zone: "bit.ly" transparent
local-zone: "ow.ly" transparent
local-zone: "tinyurl.com" transparent
local-zone: "buff.ly" transparent
local-zone: "trib.al" transparent
local-zone: "serienstream.sx" transparent
local-zone: "zdf.de" transparent 
local-zone: "zdfvodnone-vh.akamaihd.net" transparent 
local-zone: "ix.nflxvideo.net" transparent 
local-zone: "elasticbeanstalk.com" transparent
local-zone: "goo.gl" transparent
local-zone: "skype" transparent
local-zone: "youtube" transparent
local-zone: "office" transparent
local-zone: "startpage.de" transparent 
local-zone: "startpage.com" transparent 
local-zone: "torproject.org" transparent 
local-zone: "brave.com" transparent
local-zone: "duckduckgo.com" transparent
local-zone: "duckduck.go" transparent
local-zone: "wetter-online.de" transparent
local-zone: "wetter-online.com" transparent
local-zone: "snapcraft.io" transparent
local-zone: "easylist.to" transparent
local-zone: "secure.fanboy.co.nz" transparent
local-zone: "glm.io" transparent
local-zone: "heise.cloudimg.io" transparent
local-zone: "im.bestcheck.de" transparent
local-zone: "eum.instana.io" transparent
local-zone: "s.w-x.co" transparent
local-zone: "docker.io" transparent
local-zone: "bibelserver.com" transparent
local-zone: "bibleserver.com" transparent
local-zone: "bibelserver.de" transparent
local-zone: "bibleserver.de" transparent
local-zone: "erf.de" transparent
local-zone: "icf.ch" transparent
local-zone: "icf.de" transparent
local-zone: "icf.church" transparent

#Banking
local-zone: "deutschebank.de" transparent
local-zone: "banking" transparent
local-zone: "unicredit.de" transparent
local-zone: "hvb.de" transparent
local-zone: "unicredit.net" transparent
local-zone: "unicredit.it" transparent
local-zone: "hvb.net" transparent
local-zone: "hypovereinsbank.net" transparent
local-zone: "hypovereinsbank.de" transparent
local-zone: "comdirekt.de" transparent
local-zone: "comdirect.de" transparent
local-zone: "comdirect.net" transparent
local-zone: "postbank.de" transparent
local-zone: "satander.de" transparent
local-zone: "n26.de" transparent
local-zone: "deutschebank.de" transparent
local-zone: "reiba.de" transparent
local-zone: "sparkasse.de" transparent
local-zone: "sskm.de" transparent
local-zone: "commerzbank.de" transparent


# Counties Blocking
local-zone: "ac" always_null 
local-zone: "ad" always_null 
local-zone: "ae" always_null 
local-zone: "af" always_null 
local-zone: "ag" always_null 
local-zone: "ai" always_null
local-zone: "al" always_null 
local-zone: "am" always_null
local-zone: "an" always_null
local-zone: "ao" always_null 
local-zone: "aq" always_null
local-zone: "ar" always_null
local-zone: "as" always_null
local-zone: "au" always_null 
local-zone: "aw" always_null 
local-zone: "ax" always_null 
local-zone: "az" always_null 
local-zone: "ba" always_null 
local-zone: "bb" always_null
local-zone: "bd" always_null
local-zone: "bf" always_null
local-zone: "bh" always_null
local-zone: "bi" always_null
local-zone: "bj" always_null
local-zone: "bl" always_null 
local-zone: "bm" always_null 
local-zone: "bn" always_null
local-zone: "bo" always_null 
local-zone: "bq" always_null 
local-zone: "br" always_null
local-zone: "bs" always_null 
local-zone: "bt" always_null
local-zone: "bv" always_null
local-zone: "bw" always_null 
local-zone: "by" always_null
local-zone: "bz" always_null 
local-zone: "ca" always_null 
local-zone: "cc" always_null 
local-zone: "cd" always_null
local-zone: "cf" always_null 
local-zone: "cg" always_null
local-zone: "ci" always_null
local-zone: "ck" always_null 
local-zone: "cl" always_null
local-zone: "cm" always_null
local-zone: "cn" always_null 
local-zone: "co" always_null
local-zone: "cr" always_null 
local-zone: "cu" always_null 
local-zone: "cv" always_null 
local-zone: "cw" always_null
local-zone: "cx" always_null 
local-zone: "cy" always_null
local-zone: "cz" always_null 
local-zone: "dj" always_null 
local-zone: "dm" always_null 
local-zone: "do" always_null 
local-zone: "dz" always_null 
local-zone: "ec" always_null
local-zone: "ee" always_null 
local-zone: "eg" always_null
local-zone: "eh" always_null 
local-zone: "er" always_null 
local-zone: "es" always_null
local-zone: "et" always_null
local-zone: "fi" always_null 
local-zone: "fj" always_null
local-zone: "fk" always_null 
local-zone: "fm" always_null 
local-zone: "fo" always_null
local-zone: "ga" always_null
local-zone: "gd" always_null
local-zone: "ge" always_null
local-zone: "gf" always_null 
local-zone: "gg" always_null
local-zone: "gh" always_null
local-zone: "gi" always_null 
local-zone: "gl" always_null
local-zone: "gm" always_null
local-zone: "gn" always_null 
local-zone: "gp" always_null
local-zone: "gq" always_null 
local-zone: "gr" always_null
local-zone: "gs" always_null
local-zone: "gt" always_null 
local-zone: "gu" always_null
local-zone: "gw" always_null 
local-zone: "gy" always_null
local-zone: "hk" always_null 
local-zone: "hm" always_null 
local-zone: "hn" always_null
local-zone: "hr" always_null
local-zone: "ht" always_null
local-zone: "hu" always_null
local-zone: "id" always_null
local-zone: "ie" always_null 
local-zone: "il" always_null
local-zone: "im" always_null 
local-zone: "in" always_null
local-zone: "io" always_null 
local-zone: "iq" always_null 
local-zone: "is" always_null
local-zone: "it" always_null
local-zone: "je" always_null
local-zone: "jm" always_null 
local-zone: "jo" always_null
local-zone: "jp" always_null 
local-zone: "ke" always_null
local-zone: "kg" always_null 
local-zone: "kh" always_null
local-zone: "ki" always_null 
local-zone: "km" always_null
local-zone: "kn" always_null 
local-zone: "kp" always_null 
local-zone: "kr" always_null
local-zone: "kw" always_null
local-zone: "ky" always_null 
local-zone: "kz" always_null 
local-zone: "la" always_null
local-zone: "lb" always_null 
local-zone: "lc" always_null
local-zone: "lk" always_null 
local-zone: "lr" always_null
local-zone: "ls" always_null 
local-zone: "lv" always_null
local-zone: "ly" always_null 
local-zone: "ma" always_null
local-zone: "mc" always_null
local-zone: "md" always_null
local-zone: "me" always_null 
local-zone: "mf" always_null 
local-zone: "mg" always_null
local-zone: "mh" always_null 
local-zone: "mk" always_null 
local-zone: "ml" always_null
local-zone: "mm" always_null 
local-zone: "mn" always_null 
local-zone: "mo" always_null
local-zone: "mp" always_null 
local-zone: "mq" always_null
local-zone: "mr" always_null 
local-zone: "ms" always_null
local-zone: "mt" always_null
local-zone: "mu" always_null
local-zone: "mv" always_null
local-zone: "mw" always_null 
local-zone: "mx" always_null
local-zone: "my" always_null 
local-zone: "mz" always_null
local-zone: "na" always_null 
local-zone: "nc" always_null
local-zone: "ne" always_null 
local-zone: "nf" always_null
local-zone: "ng" always_null
local-zone: "ni" always_null 
local-zone: "no" always_null 
local-zone: "np" always_null
local-zone: "nr" always_null 
local-zone: "nu" always_null 
local-zone: "nz" always_null 
local-zone: "om" always_null 
local-zone: "pa" always_null
local-zone: "pe" always_null 
local-zone: "pf" always_null 
local-zone: "pg" always_null 
local-zone: "ph" always_null
local-zone: "pk" always_null 
local-zone: "pl" always_null
local-zone: "pm" always_null
local-zone: "pn" always_null 
local-zone: "pr" always_null
local-zone: "ps" always_null
local-zone: "pw" always_null 
local-zone: "py" always_null 
local-zone: "qa" always_null
local-zone: "re" always_null
local-zone: "ro" always_null 
local-zone: "rs" always_null 
local-zone: "ru" always_null 
local-zone: "rw" always_null 
local-zone: "sa" always_null
local-zone: "sb" always_null
local-zone: "sc" always_null 
local-zone: "sd" always_null
local-zone: "sg" always_null
local-zone: "sh" always_null 
local-zone: "si" always_null 
local-zone: "sj" always_null
local-zone: "sk" always_null 
local-zone: "sl" always_null
local-zone: "sm" always_null
local-zone: "sn" always_null 
local-zone: "so" always_null 
local-zone: "sr" always_null
local-zone: "ss" always_null 
local-zone: "st" always_null
local-zone: "su" always_null 
local-zone: "sv" always_null 
local-zone: "sx" always_null 
local-zone: "sy" always_null
local-zone: "sz" always_null
local-zone: "tc" always_null 
local-zone: "td" always_null 
local-zone: "tf" always_null
local-zone: "tg" always_null 
local-zone: "th" always_null
local-zone: "tj" always_null 
local-zone: "tk" always_null
local-zone: "tl" always_null
local-zone: "tm" always_null 
local-zone: "tn" always_null 
local-zone: "to" always_null
local-zone: "tp" always_null
local-zone: "tr" always_null 
local-zone: "tt" always_null 
local-zone: "tv" always_null
local-zone: "tw" always_null
local-zone: "tz" always_null 
local-zone: "ua" always_null
local-zone: "ug" always_null
local-zone: "um" always_null
local-zone: "us" always_null
local-zone: "uy" always_null 
local-zone: "uz" always_null
local-zone: "va" always_null 
local-zone: "vc" always_null 
local-zone: "ve" always_null
local-zone: "vg" always_null
local-zone: "vi" always_null 
local-zone: "vn" always_null 
local-zone: "vu" always_null 
local-zone: "wf" always_null
local-zone: "ws" always_null
local-zone: "ye" always_null
local-zone: "yt" always_null
local-zone: "za" always_null
local-zone: "zm" always_null
local-zone: "zw" always_null 

#porno
local-zone: "adult" always_null
local-zone: "sex" always_null
local-zone: "porn" always_null
local-zone: "porno" always_null
local-zone: "xx" always_null
local-zone: "xxx" always_null
local-zone: "xyz" always_null
local-zone: "cam" always_null
local-zone: "girl" always_null
local-zone: "girls" always_null
local-zone: "camera" always_null
local-zone: "dating" always_null
local-zone: "gay" always_null
local-zone: "lesbian" always_null
local-zone: "lesb" always_null
local-zone: "latino" always_null
local-zone: "asia" always_null
local-zone: "lgbt" always_null
local-zone: "love" always_null
local-zone: "pink" always_null
local-zone: "red" always_null
local-zone: "sexy" always_null
local-zone: "single" always_null
local-zone: "singles" always_null
local-zone: "tube" always_null
local-zone: "tunes" always_null
local-zone: "video" always_null
local-zone: "virgin" always_null
local-zone: "watch" always_null
local-zone: "webcam" always_null
local-zone: "live" always_null
local-zone: "6kea.com" always_null
local-zone: "6kea.de" always_null
local-zone: "7dak.com" always_null
local-zone: "7dak.de" always_null
local-zone: "abosgratis.at" always_null
local-zone: "abosgratis.ch" always_null
local-zone: "abosgratis.com" always_null
local-zone: "abosgratis.de" always_null
local-zone: "adult" always_null
local-zone: "allporntubes.net" always_null
local-zone: "allsexclips.com" always_null
local-zone: "anybunny.com" always_null
local-zone: "anybunny.de" always_null
local-zone: "anybunny.tv" always_null
local-zone: "anypornxxx.com" always_null
local-zone: "anypornxxx.de" always_null
local-zone: "anysex.cam" always_null
local-zone: "anysex.com" always_null
local-zone: "anysex.de" always_null
local-zone: "anysex.mobi" always_null
local-zone: "anysex.mobil" always_null
local-zone: "anysex.net" always_null
local-zone: "anysex.tv" always_null
local-zone: "anyxxx.com" always_null
local-zone: "anyxxx.pro" always_null
local-zone: "asia" always_null
local-zone: "avafuck.com" always_null
local-zone: "avafuck.de" always_null
local-zone: "beateuhse.com" always_null
local-zone: "beate-uhse.com" always_null
local-zone: "beate-uhse.de" always_null
local-zone: "bonga.com" always_null
local-zone: "bonga.de" always_null
local-zone: "bongacam.com" always_null
local-zone: "bongacam.de" always_null
local-zone: "bongacams.com" always_null
local-zone: "bongacams.de" always_null
local-zone: "bordell.com" always_null
local-zone: "bordell.de" always_null
local-zone: "borwap.com" always_null
local-zone: "borwap.de" always_null
local-zone: "borwap.pro" always_null
local-zone: "bpwhamburgorchardpark.org" always_null
local-zone: "bubbaporn.com" always_null
local-zone: "bubbaporn.de" always_null
local-zone: "bundesporno.com" always_null
local-zone: "bundesporno.net" always_null
local-zone: "burningangle.com" always_null
local-zone: "burningangle.de" always_null
local-zone: "cam" always_null
local-zone: "camera" always_null
local-zone: "centgebote.tv" always_null
local-zone: "chaturbate.com" always_null
local-zone: "cheglypigy.com" always_null
local-zone: "chumshot.com" always_null
local-zone: "chumshot.de" always_null
local-zone: "collectionofbestporn.com" always_null
local-zone: "cumlouder.com" always_null
local-zone: "cumlouder.de" always_null
local-zone: "cyberotic.com" always_null
local-zone: "cyberotic.de" always_null
local-zone: "cyberotic.mobi" always_null
local-zone: "date" always_null
local-zone: "datimg" always_null
local-zone: "dating" always_null
local-zone: "de.mediaplex.com" always_null
local-zone: "deutschepornos.xyz" always_null
local-zone: "deutschporno.com" always_null
local-zone: "deutschporno.de" always_null
local-zone: "deutschporno.net" always_null
local-zone: "deutschsexvideos.com" always_null
local-zone: "dinotube.com" always_null
local-zone: "dinotube.de" always_null
local-zone: "dirtypornvids.com" always_null
local-zone: "dirtypornvids.de" always_null
local-zone: "drivehotporn.com" always_null
local-zone: "drpornofilme.com" always_null
local-zone: "drpornofilme.de" always_null
local-zone: "eindeutscherporno.com" always_null
local-zone: "eindeutscherporno.de" always_null
local-zone: "einfachporno.com" always_null
local-zone: "einfachporno.de" always_null
local-zone: "elesbiansex.com" always_null
local-zone: "elesbiansex.de" always_null
local-zone: "emediate.eu" always_null
local-zone: "emohotties.com" always_null
local-zone: "endloseporno.com" always_null
local-zone: "erotica.com" always_null
local-zone: "eurotechwinterschooleindhoven.eu" always_null
local-zone: "fancy.com" always_null
local-zone: "fancy.de" always_null
local-zone: "fapdu.com" always_null
local-zone: "fapfapdesi.com" always_null
local-zone: "fap-porn.com" always_null
local-zone: "fap-porn.de" always_null
local-zone: "fapsilo.com" always_null
local-zone: "fapsilo.de" always_null
local-zone: "fatpornfuck.com" always_null
local-zone: "ficken.com" always_null
local-zone: "ficken.de" always_null
local-zone: "firstporno.com" always_null
local-zone: "firstporno.de" always_null
local-zone: "fotze.com" always_null
local-zone: "fotze.de" always_null
local-zone: "fotzen.com" always_null
local-zone: "fotzen.de" always_null
local-zone: "foxporns.com" always_null
local-zone: "foxporns.de" always_null
local-zone: "frauenporno.com" always_null
local-zone: "frauenporno.de" always_null
local-zone: "frauporno.com" always_null
local-zone: "frauporno.de" always_null
local-zone: "freeporn.com" always_null
local-zone: "freeporn.de" always_null
local-zone: "freeporncategories.com" always_null
local-zone: "freeporncategories.de" always_null
local-zone: "freepornmoves.com" always_null
local-zone: "free-porn-moves.com" always_null
local-zone: "freepornmoves.de" always_null
local-zone: "free-porn-moves.de" always_null
local-zone: "freepornmovs.com" always_null
local-zone: "free-porn-movs.com" always_null
local-zone: "freepornmovs.de" always_null
local-zone: "free-porn-movs.de" always_null
local-zone: "freepornomove.com" always_null
local-zone: "freepornomove.de" always_null
local-zone: "freepornomoves.com" always_null
local-zone: "free-porno-moves.com" always_null
local-zone: "freepornomoves.de" always_null
local-zone: "free-porno-moves.de" always_null
local-zone: "freexvideotube.com" always_null
local-zone: "freexvideotube.de" always_null
local-zone: "freexvideotubes.com" always_null
local-zone: "freexvideotubes.de" always_null
local-zone: "freierporno.com" always_null
local-zone: "freierporno.de" always_null
local-zone: "freierporno.video" always_null
local-zone: "fundorado.com" always_null
local-zone: "fundorado.de" always_null
local-zone: "gay" always_null
local-zone: "geilehure.com" always_null
local-zone: "geilehure.de" always_null
local-zone: "geilemaedchen.com" always_null
local-zone: "geiltube.com" always_null
local-zone: "german-porno-deutsch.com" always_null
local-zone: "girl" always_null
local-zone: "girls" always_null
local-zone: "girlsavenue.com" always_null
local-zone: "girlsavenue.de" always_null
local-zone: "google.desearch?q=chum" always_null
local-zone: "google.desearch?q=porn" always_null
local-zone: "google.desearch?q=sex" always_null
local-zone: "google.desearch?q=sprem" always_null
local-zone: "gratisporno.com" always_null
local-zone: "gratisporno.de" always_null
local-zone: "gratispornosfilm.com" always_null
local-zone: "gratispornox.com" always_null
local-zone: "gratispornox.de" always_null
local-zone: "guterporn.com" always_null
local-zone: "guterporn.de" always_null
local-zone: "hammerporno.com" always_null
local-zone: "hammerporno.de" always_null
local-zone: "hammerporno.xxx" always_null
local-zone: "hclips.com" always_null
local-zone: "hclubs.com" always_null
local-zone: "hellporno.com" always_null
local-zone: "hellporno.de" always_null
local-zone: "herzporno.com" always_null
local-zone: "herzporno.de" always_null
local-zone: "hierporno.com" always_null
local-zone: "hierporno.de" always_null
local-zone: "hiv" always_null
local-zone: "homemoviestube.com" always_null
local-zone: "homemoviestube.de" always_null
local-zone: "homepornking.com" always_null
local-zone: "homepornking.de" always_null
local-zone: "hotntubes.com" always_null
local-zone: "hotntubes.de" always_null
local-zone: "hotnupics.com" always_null
local-zone: "hotnupics.de" always_null
local-zone: "hot-sex-movie.com" always_null
local-zone: "hot-sex-movies.com" always_null
local-zone: "hustler.com" always_null
local-zone: "hustler.de" always_null
local-zone: "immerporno.com" always_null
local-zone: "immerporno.de" always_null
local-zone: "indecentvideos.com" always_null
local-zone: "indecentvideos.de" always_null
local-zone: "inthevip.com" always_null
local-zone: "inthevip.de" always_null
local-zone: "iporntv.com" always_null
local-zone: "iporntv.net" always_null
local-zone: "ixxx.com" always_null
local-zone: "ixxx.de" always_null
local-zone: "japbokep.com" always_null
local-zone: "japbokep.de" always_null
local-zone: "jjhouse.com" always_null
local-zone: "joyclub.at" always_null
local-zone: "joy-club.at" always_null
local-zone: "joyclub.ch" always_null
local-zone: "joy-club.ch" always_null
local-zone: "joyclub.com" always_null
local-zone: "joy-club.com" always_null
local-zone: "joyclub.de" always_null
local-zone: "joy-club.de" always_null
local-zone: "joyclub.net" always_null
local-zone: "joy-club.net" always_null
local-zone: "joyclub.nl" always_null
local-zone: "joy-club.nl" always_null
local-zone: "jungespornovideo.com" always_null
local-zone: "jungespornovideo.de" always_null
local-zone: "justporno.com" always_null
local-zone: "justporno.de" always_null
local-zone: "justporno.tv" always_null
local-zone: "latino" always_null
local-zone: "lesb" always_null
local-zone: "lesbian" always_null
local-zone: "lesbian.com" always_null
local-zone: "lesbian.de" always_null
local-zone: "lesbian1.com" always_null
local-zone: "lesbian1.de" always_null
local-zone: "lesbian2.com" always_null
local-zone: "lesbian2.de" always_null
local-zone: "lesbian3.com" always_null
local-zone: "lesbian3.de" always_null
local-zone: "lesbian4.com" always_null
local-zone: "lesbian4.de" always_null
local-zone: "lesbian5.com" always_null
local-zone: "lesbian5.de" always_null
local-zone: "lesbian6.com" always_null
local-zone: "lesbian6.de" always_null
local-zone: "lesbian7.com" always_null
local-zone: "lesbian7.de" always_null
local-zone: "lesbian8.com" always_null
local-zone: "lesbian8.de" always_null
local-zone: "lesbiankissing.com" always_null
local-zone: "lesbiankissing.de" always_null
local-zone: "lesbiankissing.net" always_null
local-zone: "lesbianlist.com" always_null
local-zone: "lesbianlist.de" always_null
local-zone: "lesbianmix.com" always_null
local-zone: "lesbianmix.de" always_null
local-zone: "lesbianpornbros.com" always_null
local-zone: "lesbianpornbros.de" always_null
local-zone: "lesbianpornbros.mobi" always_null
local-zone: "lesbianpornbros.mobil" always_null
local-zone: "lesbianpornbros.sex" always_null
local-zone: "lesbianpornbros.tv" always_null
local-zone: "lesbianpornbros.xxx" always_null
local-zone: "lesbianpornvideos.com" always_null
local-zone: "lesbianpornvideos.de" always_null
local-zone: "lesbiantube.club" always_null
local-zone: "lesbiantube.com" always_null
local-zone: "lesbiantube.de" always_null
local-zone: "lesbiantube.mobi" always_null
local-zone: "lesbiantubenow.com" always_null
local-zone: "lesbiantubenow.de" always_null
local-zone: "lesbiantubex.com" always_null
local-zone: "lesbiantubex.de" always_null
local-zone: "lesbiantubexx.com" always_null
local-zone: "lesbiantubexx.de" always_null
local-zone: "lesbiantubexxx.com" always_null
local-zone: "lesbiantubexxx.de" always_null
local-zone: "lesbpornvids.com" always_null
local-zone: "lesbpornvids.de" always_null
local-zone: "letmejerk.com" always_null
local-zone: "letmejerk.de" always_null
local-zone: "letmejerk.mobi" always_null
local-zone: "letmejerk.mobil" always_null
local-zone: "letmejerk.net" always_null
local-zone: "lgbt" always_null
local-zone: "liebelib.com" always_null
local-zone: "liebelib.de" always_null
local-zone: "liebelib.net" always_null
local-zone: "literotica.com" always_null
local-zone: "live" always_null
local-zone: "livejasmin.com" always_null
local-zone: "livejasmin.de" always_null
local-zone: "livestrip.com" always_null
local-zone: "live-strip.com" always_null
local-zone: "livestrip.de" always_null
local-zone: "live-strip.de" always_null
local-zone: "lockerdome.com" always_null
local-zone: "love" always_null
local-zone: "loverslesbian.com" always_null
local-zone: "loverslesbian.de" always_null
local-zone: "lupoporno.com" always_null
local-zone: "lustdays.com" always_null
local-zone: "lustparkplatz.com" always_null
local-zone: "matureguru.com" always_null
local-zone: "matureguru.de" always_null
local-zone: "megaporn.com" always_null
local-zone: "megaporn.de" always_null
local-zone: "megaporno.com" always_null
local-zone: "megaporno.de" always_null
local-zone: "megapornx.com" always_null
local-zone: "megapornx.de" always_null
local-zone: "milffox.com" always_null
local-zone: "milffox.de" always_null
local-zone: "moese.com" always_null
local-zone: "moese.de" always_null
local-zone: "möse" always_null
local-zone: "möse.com" always_null
local-zone: "möse.de" always_null
local-zone: "movie4k.to" always_null
local-zone: "mp3fiesta.com" always_null
local-zone: "mp3sugar.com" always_null
local-zone: "mp3va.com" always_null
local-zone: "msads.net" always_null
local-zone: "mvideoporno.com" always_null
local-zone: "mvideoporno.de" always_null
local-zone: "mvideoporno.xxx" always_null
local-zone: "mylesbianfuck.com" always_null
local-zone: "mylesbianfuck.de" always_null
local-zone: "mylesbiansex.com" always_null
local-zone: "mylesbiansex.de" always_null
local-zone: "mylesbiansex.mobi" always_null
local-zone: "mylesbiansex.mobil" always_null
local-zone: "mylesbiansex.net" always_null
local-zone: "mylesbiansex.tv" always_null
local-zone: "nesaporn.com" always_null
local-zone: "nesaporn.de" always_null
local-zone: "newsexfap.com" always_null
local-zone: "new-sex-fap.com" always_null
local-zone: "newsexfap.de" always_null
local-zone: "new-sex-fap.de" always_null
local-zone: "new-xmovie.com" always_null
local-zone: "new-xmovies.com" always_null
local-zone: "nudevista.com" always_null
local-zone: "nudevista.de" always_null
local-zone: "nudevista.tv" always_null
local-zone: "nursexfilme.com" always_null
local-zone: "nurxxx.com" always_null
local-zone: "nurxxx.de" always_null
local-zone: "nurxxx.mobi" always_null
local-zone: "onlinebordell.com" always_null
local-zone: "online-bordell.com" always_null
local-zone: "onlinebordell.de" always_null
local-zone: "online-bordell.de" always_null
local-zone: "onlinebordell.net" always_null
local-zone: "online-bordell.net" always_null
local-zone: "onlinepuff.com" always_null
local-zone: "online-puff.com" always_null
local-zone: "onlinepuff.de" always_null
local-zone: "online-puff.de" always_null
local-zone: "oyoh.com" always_null
local-zone: "oyoh.de" always_null
local-zone: "penis" always_null
local-zone: "penis.com" always_null
local-zone: "penis.de" always_null
local-zone: "perfectgirls.com" always_null
local-zone: "perfectgirls.de" always_null
local-zone: "perfectgirls.mobil" always_null
local-zone: "perfectgirls.net" always_null
local-zone: "perfectgirls.tv" always_null
local-zone: "perfektdamen.co" always_null
local-zone: "perfektdamen.com" always_null
local-zone: "perfektdamen.de" always_null
local-zone: "pink" always_null
local-zone: "porn" always_null
local-zone: "porn.com" always_null
local-zone: "porn.de" always_null
local-zone: "porn2000.biz" always_null
local-zone: "porn2000.com" always_null
local-zone: "porn2000.de" always_null
local-zone: "porn2000.org" always_null
local-zone: "porn2000.pro" always_null
local-zone: "porn2001.biz" always_null
local-zone: "porn2001.com" always_null
local-zone: "porn2001.de" always_null
local-zone: "porn2001.org" always_null
local-zone: "porn2001.pro" always_null
local-zone: "porn2002.biz" always_null
local-zone: "porn2002.com" always_null
local-zone: "porn2002.de" always_null
local-zone: "porn2002.org" always_null
local-zone: "porn2002.pro" always_null
local-zone: "porn2003.biz" always_null
local-zone: "porn2003.com" always_null
local-zone: "porn2003.de" always_null
local-zone: "porn2003.org" always_null
local-zone: "porn2003.pro" always_null
local-zone: "porn2010.biz" always_null
local-zone: "porn2010.com" always_null
local-zone: "porn2010.de" always_null
local-zone: "porn2010.org" always_null
local-zone: "porn2010.pro" always_null
local-zone: "porn2017.com" always_null
local-zone: "porn2017.de" always_null
local-zone: "porn2018.com" always_null
local-zone: "porn2018.de" always_null
local-zone: "porn2019.com" always_null
local-zone: "porn2019.de" always_null
local-zone: "porn2020.biz" always_null
local-zone: "porn2020.com" always_null
local-zone: "porn2020.de" always_null
local-zone: "porn2020.org" always_null
local-zone: "porn2020.pro" always_null
local-zone: "porn2021.biz" always_null
local-zone: "porn2021.com" always_null
local-zone: "porn2021.de" always_null
local-zone: "porn2021.org" always_null
local-zone: "porn2021.pro" always_null
local-zone: "porn2022.biz" always_null
local-zone: "porn2022.com" always_null
local-zone: "porn2022.de" always_null
local-zone: "porn2022.org" always_null
local-zone: "porn2022.pro" always_null
local-zone: "porn300.com" always_null
local-zone: "porn300.de" always_null
local-zone: "porn360.com" always_null
local-zone: "porn360.de" always_null
local-zone: "pornburst.com" always_null
local-zone: "porncana.com" always_null
local-zone: "porncana.de" always_null
local-zone: "porndig.com" always_null
local-zone: "porndig.de" always_null
local-zone: "porndoe.com" always_null
local-zone: "porndroids.com" always_null
local-zone: "porndroids.de" always_null
local-zone: "porndroids.mobi" always_null
local-zone: "porndroids.mobil" always_null
local-zone: "porndroids.net" always_null
local-zone: "porn-fap-video.com" always_null
local-zone: "porn-fap-videos.com" always_null
local-zone: "pornhub.com" always_null
local-zone: "pornhub.de" always_null
local-zone: "pornkai.com" always_null
local-zone: "pornkai.de" always_null
local-zone: "Porno" always_null
local-zone: "porno.com" always_null
local-zone: "porno.de" always_null
local-zone: "pornobrot.com" always_null
local-zone: "pornobrot.de" always_null
local-zone: "pornocarioca.com" always_null
local-zone: "pornocarioca.de" always_null
local-zone: "pornodiamant.com" always_null
local-zone: "pornodiamant.de" always_null
local-zone: "pornodiamant.xxx" always_null
local-zone: "pornodoe.com" always_null
local-zone: "pornodroids.com" always_null
local-zone: "pornodroids.de" always_null
local-zone: "pornoente.com" always_null
local-zone: "pornoente.de" always_null
local-zone: "pornoente.net" always_null
local-zone: "pornoente.tv" always_null
local-zone: "pornofi.com" always_null
local-zone: "pornofilme.com" always_null
local-zone: "pornofilme.de" always_null
local-zone: "pornofilmedeutsche.com" always_null
local-zone: "pornofilmedeutsche.de" always_null
local-zone: "pornogrund.com" always_null
local-zone: "pornogrund.de" always_null
local-zone: "pornogrund.mobi" always_null
local-zone: "pornogrund.mobil" always_null
local-zone: "pornogrund.net" always_null
local-zone: "pornohammer.com" always_null
local-zone: "pornohammer.de" always_null
local-zone: "porno-himmel.com" always_null
local-zone: "porno-himmel.de" always_null
local-zone: "porno-himmel.net" always_null
local-zone: "pornohirach.de" always_null
local-zone: "pornohirsch.com" always_null
local-zone: "pornohirsch.de" always_null
local-zone: "pornohirsch.net" always_null
local-zone: "pornohutdeutsch.com" always_null
local-zone: "pornohutdeutsch.de" always_null
local-zone: "pornohutdeutsch.net" always_null
local-zone: "pornojenny.com" always_null
local-zone: "pornojenny.de" always_null
local-zone: "pornojux.com" always_null
local-zone: "pornojux.de" always_null
local-zone: "pornoklinge.com" always_null
local-zone: "pornoklinge.de" always_null
local-zone: "pornokonig.com" always_null
local-zone: "pornoleeuw.com" always_null
local-zone: "pornoorzel.com" always_null
local-zone: "porno-porno.com" always_null
local-zone: "porno-porno.de" always_null
local-zone: "porno-porno.org" always_null
local-zone: "pornoraum.com" always_null
local-zone: "pornoraum.de" always_null
local-zone: "pornos-de.com" always_null
local-zone: "pornos-de.de" always_null
local-zone: "pornos-de.net" always_null
local-zone: "pornosdeutsch.com" always_null
local-zone: "pornosdeutsch.de" always_null
local-zone: "pornosdeutsch.org" always_null
local-zone: "pornos-kostenlos.tv" always_null
local-zone: "pornostunde.com" always_null
local-zone: "pornotoll.com" always_null
local-zone: "pornotoll.de" always_null
local-zone: "pornozeit.com" always_null
local-zone: "pornozeit.de" always_null
local-zone: "pornozeit.net" always_null
local-zone: "pornsexde.com" always_null
local-zone: "pornsexde.de" always_null
local-zone: "pornzog.com" always_null
local-zone: "pornzog.de" always_null
local-zone: "puff.com" always_null
local-zone: "puff.de" always_null
local-zone: "puff.net" always_null
local-zone: "puporn.com" always_null
local-zone: "puporn.de" always_null
local-zone: "purelust.com" always_null
local-zone: "pure-lust.com" always_null
local-zone: "purelust.de" always_null
local-zone: "pure-lust.de" always_null
local-zone: "purelust.mobi" always_null
local-zone: "pure-lust.mobi" always_null
local-zone: "purelust.mobil" always_null
local-zone: "pure-lust.mobil" always_null
local-zone: "purelust.tv" always_null
local-zone: "pure-lust.tv" always_null
local-zone: "purlust.com" always_null
local-zone: "pur-lust.com" always_null
local-zone: "purlust.de" always_null
local-zone: "pur-lust.de" always_null
local-zone: "purlust.mobi" always_null
local-zone: "pur-lust.mobi" always_null
local-zone: "purlust.mobil" always_null
local-zone: "pur-lust.mobil" always_null
local-zone: "purlust.tv" always_null
local-zone: "pur-lust.tv" always_null
local-zone: "pussyspace.com" always_null
local-zone: "pussyspace.de" always_null
local-zone: "qpornx.com" always_null
local-zone: "qpornx.de" always_null
local-zone: "realetykings.com" always_null
local-zone: "realetykings.de" always_null
local-zone: "realitykings.com" always_null
local-zone: "realitykings.de" always_null
local-zone: "red" always_null
local-zone: "redporn.com" always_null
local-zone: "redtube.com" always_null
local-zone: "redtube.de" always_null
local-zone: "redtube.mobil" always_null
local-zone: "redtube.net" always_null
local-zone: "redwap.com" always_null
local-zone: "redwap.de" always_null
local-zone: "redwap.me" always_null
local-zone: "redwap2.com" always_null
local-zone: "redwap2.de" always_null
local-zone: "redwarp.pro" always_null
local-zone: "repicsx.com" always_null
local-zone: "repicsx.de" always_null
local-zone: "rk.com" always_null
local-zone: "rk.de" always_null
local-zone: "roloflix.com" always_null
local-zone: "rotelaterne.com" always_null
local-zone: "rote-laterne.com" always_null
local-zone: "rotelaterne.de" always_null
local-zone: "rote-laterne.de" always_null
local-zone: "rote-laterne.net" always_null
local-zone: "sceneporn.com" always_null
local-zone: "scene-porn.com" always_null
local-zone: "sceneporn.de" always_null
local-zone: "scene-porn.de" always_null
local-zone: "schwanz" always_null
local-zone: "schwanz.com" always_null
local-zone: "schwanz.de" always_null
local-zone: "script.ioam.de" always_null
local-zone: "selbstbefriedigung.com" always_null
local-zone: "selbstbefriedigung.de" always_null
local-zone: "sex" always_null
local-zone: "sex.com" always_null
local-zone: "sex.de" always_null
local-zone: "sexbombe.com" always_null
local-zone: "sexbombe.de" always_null
local-zone: "sexbombo.com" always_null
local-zone: "sexbombo.de" always_null
local-zone: "sexhubhd.com" always_null
local-zone: "sexhubhd.de" always_null
local-zone: "sexhubhd.net" always_null
local-zone: "sexmotors.com" always_null
local-zone: "sexmotors.de" always_null
local-zone: "sexmotors.net" always_null
local-zone: "sexpics.com" always_null
local-zone: "sexpics.de" always_null
local-zone: "sex-pornotube.com" always_null
local-zone: "sex-pornotube.de" always_null
local-zone: "sexviptube.com" always_null
local-zone: "sexviptube.de" always_null
local-zone: "sexy" always_null
local-zone: "single" always_null
local-zone: "singles" always_null
local-zone: "softcorexxporn.de" always_null
local-zone: "softcorexxxporn.com" always_null
local-zone: "spankbang.com" always_null
local-zone: "spankbang.de" always_null
local-zone: "spermswap.com" always_null
local-zone: "spermswap.de" always_null
local-zone: "spermswap.us" always_null
local-zone: "starshows.com" always_null
local-zone: "starshows.de" always_null
local-zone: "stripchat.com" always_null
local-zone: "strip-chat.com" always_null
local-zone: "stripchat.de" always_null
local-zone: "strip-chat.de" always_null
local-zone: "sunporno.com" always_null
local-zone: "sunporno.de" always_null
local-zone: "susilive.com" always_null
local-zone: "susi-live.com" always_null
local-zone: "susilive.de" always_null
local-zone: "susi-live.de" always_null
local-zone: "susilive.tv" always_null
local-zone: "susi-live.tv" always_null
local-zone: "teenlesbianporn.com" always_null
local-zone: "teenlesbianporn.de" always_null
local-zone: "teenlesbianporn.mobil" always_null
local-zone: "teenlesbianporn.net" always_null
local-zone: "teenlesbianporn.sex" always_null
local-zone: "teenlesbianporn.tv" always_null
local-zone: "teenlesbianporn.xxx" always_null
local-zone: "tnaflix.com" always_null
local-zone: "tnaflix.de" always_null
local-zone: "toroporno.com" always_null
local-zone: "toys4you.com" always_null
local-zone: "toys4you.de" always_null
local-zone: "tropictube.com" always_null
local-zone: "tropictube.de" always_null
local-zone: "trylesbianporn.com" always_null
local-zone: "trylesbianporn.de" always_null
local-zone: "tube" always_null
local-zone: "tube188.com" always_null
local-zone: "tube188.de" always_null
local-zone: "tube3.com" always_null
local-zone: "tube3.de" always_null
local-zone: "tube6.com" always_null
local-zone: "tube6.de" always_null
local-zone: "tube8.com" always_null
local-zone: "tube8.de" always_null
local-zone: "tubehe.com" always_null
local-zone: "tubehe.de" always_null
local-zone: "tubelibre.com" always_null
local-zone: "tubepatrol.com" always_null
local-zone: "tubepatrol.de" always_null
local-zone: "tubepatrol.mobil" always_null
local-zone: "tubepatrol.net" always_null
local-zone: "tubepatrol.porn" always_null
local-zone: "tubepatrol.tv" always_null
local-zone: "tubepatrol.xxx" always_null
local-zone: "tubesafari.com" always_null
local-zone: "tubesafari.de" always_null
local-zone: "tubevintageporn.com" always_null
local-zone: "tubexmovie.com" always_null
local-zone: "tubexmovie.de" always_null
local-zone: "tubexmovies.com" always_null
local-zone: "tubexmovies.de" always_null
local-zone: "tubexxmovie.com" always_null
local-zone: "tubexxmovie.de" always_null
local-zone: "tubexxmovies.com" always_null
local-zone: "tubexxmovies.de" always_null
local-zone: "tubexxxmovie.com" always_null
local-zone: "tubexxxmovie.de" always_null
local-zone: "tubexxxmovies.com" always_null
local-zone: "tubexxxmovies.de" always_null
local-zone: "tunes" always_null
local-zone: "unup4y" always_null
local-zone: "urbandictionary.com" always_null
local-zone: "vagina" always_null
local-zone: "vagina.com" always_null
local-zone: "vagina.de" always_null
local-zone: "vagosex.com" always_null
local-zone: "vagosex.de" always_null
local-zone: "vagosex.xxx" always_null
local-zone: "video" always_null
local-zone: "virgin" always_null
local-zone: "vivatube.com" always_null
local-zone: "vivud.com" always_null
local-zone: "vivud.de" always_null
local-zone: "watch" always_null
local-zone: "watchmygf.com" always_null
local-zone: "watchmygf.de" always_null
local-zone: "watchmygf.me" always_null
local-zone: "watchmygf.mobi" always_null
local-zone: "watchmygf.mobil" always_null
local-zone: "webcam" always_null
local-zone: "whitexxxtube.com" always_null
local-zone: "wichsen.com" always_null
local-zone: "wichsen.de" always_null
local-zone: "wildesporno.com" always_null
local-zone: "wildlesbianmovies.com" always_null
local-zone: "wildlesbianmovies.de" always_null
local-zone: "wildlesbianmovies.mobil" always_null
local-zone: "wixen.com" always_null
local-zone: "wixen.de" always_null
local-zone: "wwwxxx.com" always_null
local-zone: "wwwxxx.de" always_null
local-zone: "wwwxxx.pro" always_null
local-zone: "xecce.com" always_null
local-zone: "xecce.de" always_null
local-zone: "xhamster.com" always_null
local-zone: "x-hamster.com" always_null
local-zone: "xhamster.de" always_null
local-zone: "x-hamster.de" always_null
local-zone: "xhamster2.com" always_null
local-zone: "xhamster2.de" always_null
local-zone: "xhamster3.com" always_null
local-zone: "xhamster3.de" always_null
local-zone: "xhamster4.com" always_null
local-zone: "xhamster4.de" always_null
local-zone: "xhamster5.com" always_null
local-zone: "xhamster5.de" always_null
local-zone: "xhamster6.com" always_null
local-zone: "xhamster6.de" always_null
local-zone: "xhamster7.com" always_null
local-zone: "xhamster7.de" always_null
local-zone: "xhamster8.com" always_null
local-zone: "xhamster8.de" always_null
local-zone: "xhamster9.com" always_null
local-zone: "xhamster9.de" always_null
local-zone: "xhamsterdeutsch.biz" always_null
local-zone: "xhofficial.com" always_null
local-zone: "xhofficial.de" always_null
local-zone: "xmoviesxvideo.com" always_null
local-zone: "xmoviesxvideo.de" always_null
local-zone: "xmoviesxvideos.com" always_null
local-zone: "xmoviesxvideos.de" always_null
local-zone: "xmoviexvideos.com" always_null
local-zone: "xmoviexvideos.de" always_null
local-zone: "xnxx.com" always_null
local-zone: "xnxx.de" always_null
local-zone: "xnxx.mobi" always_null
local-zone: "xnxx.mobil" always_null
local-zone: "xnxx.org" always_null
local-zone: "xnxx.tv" always_null
local-zone: "xnxx1.com" always_null
local-zone: "xnxx1.de" always_null
local-zone: "xnxx1.org" always_null
local-zone: "xnxx2.com" always_null
local-zone: "xnxx2.de" always_null
local-zone: "xnxx2.org" always_null
local-zone: "xnxx24.com" always_null
local-zone: "xnxx26.com" always_null
local-zone: "xnxx26.de" always_null
local-zone: "xnxx3.com" always_null
local-zone: "xnxx3.de" always_null
local-zone: "xnxx3.org" always_null
local-zone: "xnxx4.com" always_null
local-zone: "xnxx4.de" always_null
local-zone: "xnxx4.org" always_null
local-zone: "xnxx5.com" always_null
local-zone: "xnxx5.de" always_null
local-zone: "xnxx5.org" always_null
local-zone: "xnxx-free-videos.com" always_null
local-zone: "xnxx-free-videos.de" always_null
local-zone: "xnxx-pornos.com" always_null
local-zone: "xnxx-pornos.de" always_null
local-zone: "xnxx-sex-tube.com" always_null
local-zone: "xnxx-sex-tube.de" always_null
local-zone: "xsexpics.com" always_null
local-zone: "xsexpics.de" always_null
local-zone: "xvideos.com" always_null
local-zone: "xvideos.de" always_null
local-zone: "xvideosporno.blog" always_null
local-zone: "xvideosporno.blog.br" always_null
local-zone: "xvideosporno.blog.com" always_null
local-zone: "xvideosporno.blog.de" always_null
local-zone: "xvideosporno.com" always_null
local-zone: "xvideosporno.de" always_null
local-zone: "xvideos-xxx.com" always_null
local-zone: "xvideos-xxx.de" always_null
local-zone: "xvidzz.com" always_null
local-zone: "xvidzz.de" always_null
local-zone: "xvxxporn.com" always_null
local-zone: "xvxxporn.de" always_null
local-zone: "xvxxporno.com" always_null
local-zone: "xvxxporno.de" always_null
local-zone: "xx" always_null
local-zone: "xxx" always_null
local-zone: "xxx.com" always_null
local-zone: "xxx.de" always_null
local-zone: "xxx.org" always_null
local-zone: "xxx.pro" always_null
local-zone: "xxx1.com" always_null
local-zone: "xxx1.de" always_null
local-zone: "xxx1.org" always_null
local-zone: "xxx1.pro" always_null
local-zone: "xxx2.com" always_null
local-zone: "xxx2.de" always_null
local-zone: "xxx2.org" always_null
local-zone: "xxx2.pro" always_null
local-zone: "xxx3.com" always_null
local-zone: "xxx3.de" always_null
local-zone: "xxx3.org" always_null
local-zone: "xxx3.pro" always_null
local-zone: "xxx4.com" always_null
local-zone: "xxx4.de" always_null
local-zone: "xxx4.org" always_null
local-zone: "xxx4.pro" always_null
local-zone: "xxx5.com" always_null
local-zone: "xxx5.de" always_null
local-zone: "xxx5.org" always_null
local-zone: "xxx5.pro" always_null
local-zone: "xxxbule.com" always_null
local-zone: "xxxbule.de" always_null
local-zone: "xxx-fap.com" always_null
local-zone: "xxx-fap.de" always_null
local-zone: "xxxflare.com" always_null
local-zone: "xxxflare.de" always_null
local-zone: "xxx-free.com" always_null
local-zone: "xxx-free.de" always_null
local-zone: "xxx-free.info" always_null
local-zone: "xxxmovie.com" always_null
local-zone: "xxxmovie.de" always_null
local-zone: "xxxmovies.com" always_null
local-zone: "xxxmovies.de" always_null
local-zone: "xxxner.com" always_null
local-zone: "xxxpicz.com" always_null
local-zone: "xxxpicz.de" always_null
local-zone: "xxxporn.com" always_null
local-zone: "xxxporn.de" always_null
local-zone: "xxxporno.com" always_null
local-zone: "xxxporno.de" always_null
local-zone: "xxxrer.com" always_null
local-zone: "xxxs.stream" always_null
local-zone: "xyz" always_null
local-zone: "youjizz.com" always_null
local-zone: "youjizz.de" always_null
local-zone: "youjizz.sex" always_null
local-zone: "youporn.com" always_null
local-zone: "youporn.de" always_null
local-zone: "yourporn.com" always_null
local-zone: "yourporn.de" always_null
local-zone: "zuckerporno.com" always_null
local-zone: "zuckerporno.de" always_null
local-zone: "thumbzilla.de" always_null
local-zone: "thumbzilla.com" always_null
local-zone: "tumbzilla.de" always_null
local-zone: "tumbzilla.com" always_null
local-zone: "girlmassage.de" always_null
local-zone: "girlmassage.com" always_null
local-zone: "lesworship.com" always_null
local-zone: "lesworship.de" always_null
local-zone: "bigporn.com" always_null
local-zone: "bigporn.de" always_null
local-zone: "xxxvideohd.net" always_null
local-zone: "xxxvideohd.com" always_null
local-zone: "xxxvideohd.de" always_null
local-zone: "lesbenpornos.net" always_null
local-zone: "lesbenpornos.de" always_null
local-zone: "lesbenpornos.com" always_null
local-zone: "bombasstube.com" always_null
local-zone: "bombasstube.de" always_null
local-zone: "bombasstube.net" always_null
local-zone: "edelpornos.de" always_null
local-zone: "edelpornos.com" always_null
local-zone: "edelpornos.net" always_null
local-zone: "booklooker.de" always_null
local-zone: "booklooker.com" always_null
local-zone: "hdpornos.net" always_null
local-zone: "hdpornos.de" always_null
local-zone: "hdpornos.com" always_null
local-zone: "pornodavid.com" always_null
local-zone: "pornodavid.de" always_null
local-zone: "toiletten-fetisch.com" always_null
local-zone: "toiletten-fetisch.de" always_null
local-zone: "xxl-freeporn.com" always_null
local-zone: "xxl-freeporn.de" always_null
local-zone: "misex.net" always_null
local-zone: "misex.de" always_null
local-zone: "misex.com" always_null
local-zone: "pornoheit.com" always_null
local-zone: "pornoheit.de" always_null
local-zone: "pornoheit.net" always_null
local-zone: "ig-beat.de" always_null
local-zone: "ig-beat.com" always_null
local-zone: "geilemaedchen.com" always_null
local-zone: "geilemaedchen.de" always_null
local-zone: "oma-sex.biz" always_null
local-zone: "oma-sex.com" always_null
local-zone: "oma-sex.de" always_null
local-zone: "oma-sex.net" always_null
local-zone: "pornpics.de" always_null
local-zone: "pornpics.com" always_null
local-zone: "pornpics.net" always_null
local-zone: "dvd-fsk18.de" always_null
local-zone: "dvd-fsk18.com" always_null
local-zone: "bd-fsk18.de" always_null
local-zone: "bd-fsk18.com" always_null
local-zone: "blueray-fsk18.de" always_null
local-zone: "blueray-fsk18.com" always_null
local-zone: "blueraydisc-fsk18.de" always_null
local-zone: "blueraydisc-fsk18.com" always_null
local-zone: "xvideos1.de" always_null
local-zone: "xvideos1.com" always_null
local-zone: "xvideos2.de" always_null
local-zone: "xvideos2.com" always_null
local-zone: "xvideos3.de" always_null
local-zone: "xvideos3.com" always_null
local-zone: "xvideos4.de" always_null
local-zone: "xvideos4.com" always_null
local-zone: "xvideos5.de" always_null
local-zone: "xvideos5.com" always_null
local-zone: "goutube.net" always_null
local-zone: "goutube.de" always_null
local-zone: "goutube.com" always_null
local-zone: "pornofilme.xyz" always_null
local-zone: "pornofilme.de" always_null
local-zone: "pornofilme.com" always_null
local-zone: "de.pretty.porn" always_null
local-zone: "de.pretty.de" always_null
local-zone: "de.pretty.com" always_null
local-zone: "de.rajwap.xyz" always_null
local-zone: "de.rajwap.com" always_null
local-zone: "de.rajwap.de" always_null
local-zone: "geile-lesben.info" always_null
local-zone: "geile-lesben.de" always_null
local-zone: "geile-lesben.com" always_null
local-zone: "us-plates.de" always_null
local-zone: "us-plates.com" always_null
local-zone: "default-url.de" always_null
local-zone: "default-url.com" always_null
local-zone: "default-url.net" always_null
local-zone: "rioberlin.de" always_null
local-zone: "rioberlin.com" always_null
local-zone: "pestalozzischule-luebbecke.de" always_null
local-zone: "pestalozzischule-luebbecke.com" always_null
local-zone: "arthyredir.com" always_null
local-zone: "arthyredir.de" always_null
local-zone: "bavaria-mallorca.de" always_null
local-zone: "bavaria-mallorca.com" always_null
local-zone: "pornliebe.com" always_null
local-zone: "pornliebe.de" always_null
local-zone: "pornoliebe.com" always_null
local-zone: "pornoliebe.de" always_null
local-zone: "4porn.com" always_null
local-zone: "4porn.de" always_null
local-zone: "goncharova.info" always_null
local-zone: "goncharova.de" always_null
local-zone: "goncharova.com" always_null
local-zone: "duesseldorf-baeumt-sich-auf.de" always_null
local-zone: "duesseldorf-baeumt-sich-auf.com" always_null
local-zone: "halloween-in-hamburg.de" always_null
local-zone: "halloween-in-hamburg.com" always_null

#ad-ware
local-zone: "winners" always_null
local-zone: "walmart" always_null
local-zone: "vote" always_null
local-zone: "vegas" always_null
local-zone: "sale" always_null
local-zone: "qvc" always_null
local-zone: "promo" always_null
local-zone: "play" always_null
local-zone: "poker" always_null
local-zone: "coupons" always_null
local-zone: "coupon" always_null
local-zone: "win" always_null
local-zone: "deal" always_null
local-zone: "deals" always_null
local-zone: "spy" always_null
local-zone: "download" always_null
local-zone: "game" always_null
local-zone: "games" always_null
local-zone: "x.amica.de" always_null 
local-zone: "x.cinema.de" always_null 
local-zone: "x.fitforfun.de" always_null 
local-zone: "x.patientus.de" always_null 
local-zone: "x.tvspielfilm.de" always_null 
local-zone: "x.playboy.de" always_null 
local-zone: "x.bunte.de" always_null 
local-zone: "x.haus.de" always_null 
local-zone: "x.elle.de" always_null 
local-zone: "x.freundin.de" always_null 
local-zone: "x.mein-schoener-garten.de" always_null 
local-zone: "x.super-illu.de" always_null 
local-zone: "x.guter-rat.de" always_null 
local-zone: "x.holidaycheck" always_null 
local-zone: "x.jameda.de" always_null 
local-zone: "x.freizeitrevue.de" always_null 
local-zone: "x.lisa.de" always_null 
local-zone: "x.brandsyoulove.de" always_null 
local-zone: "x.burdastyle.de" always_null 
local-zone: "x.instyle.de" always_null 
local-zone: "x.computeruniverse.de" always_null 
local-zone: "x.cyberport.de" always_null 
local-zone: "x.daskochrezept.de" always_null 
local-zone: "x.mietwagen-check.de" always_null 
local-zone: "x.tvtoday.de" always_null 
local-zone: "x.zoover.de" always_null 
local-zone: "x.bestcheck.de" always_null 
local-zone: "x.netmoms.de" always_null 
local-zone: "x.finanzen100.de" always_null 
local-zone: "x.cardscout.de" always_null 
local-zone: "x.chip.de" always_null 
local-zone: "x.focus.de" always_null 
local-zone: "x.welt.de" always_null 
local-zone: "x.stern.de" always_null 
local-zone: "x.spiegel.de" always_null 
local-zone: "x.bild.de" always_null 
local-zone: "gutschein.amica.de" always_null 
local-zone: "gutschein.cinema.de" always_null 
local-zone: "gutschein.fitforfun.de" always_null 
local-zone: "gutschein.patientus.de" always_null 
local-zone: "gutschein.tvspielfilm.de" always_null 
local-zone: "gutschein.playboy.de" always_null 
local-zone: "gutschein.bunte.de" always_null 
local-zone: "gutschein.haus.de" always_null 
local-zone: "gutschein.elle.de" always_null 
local-zone: "gutschein.freundin.de" always_null 
local-zone: "gutschein.mein-schoener-garten.de" always_null 
local-zone: "gutschein.super-illu.de" always_null 
local-zone: "gutschein.guter-rat.de" always_null 
local-zone: "gutschein.holidaycheck" always_null 
local-zone: "gutschein.jameda.de" always_null 
local-zone: "gutschein.freizeitrevue.de" always_null 
local-zone: "gutschein.lisa.de" always_null 
local-zone: "gutschein.brandsyoulove.de" always_null 
local-zone: "gutschein.burdastyle.de" always_null 
local-zone: "gutschein.instyle.de" always_null 
local-zone: "gutschein.computeruniverse.de" always_null 
local-zone: "gutschein.cyberport.de" always_null 
local-zone: "gutschein.daskochrezept.de" always_null 
local-zone: "gutschein.mietwagen-check.de" always_null 
local-zone: "gutschein.tvtoday.de" always_null 
local-zone: "gutschein.zoover.de" always_null 
local-zone: "gutschein.bestcheck.de" always_null 
local-zone: "gutschein.netmoms.de" always_null 
local-zone: "gutschein.finanzen100.de" always_null 
local-zone: "gutschein.cardscout.de" always_null 
local-zone: "gutschein.chip.de" always_null 
local-zone: "gutschein.focus.de" always_null 
local-zone: "gutschein.welt.de" always_null 
local-zone: "gutschein.stern.de" always_null 
local-zone: "gutschein.spiegel.de" always_null 
local-zone: "gutschein.bild.de" always_null 
local-zone: "prospekte.amica.de" always_null 
local-zone: "prospekte.cinema.de" always_null 
local-zone: "prospekte.fitforfun.de" always_null 
local-zone: "prospekte.patientus.de" always_null 
local-zone: "prospekte.tvspielfilm.de" always_null 
local-zone: "prospekte.playboy.de" always_null 
local-zone: "prospekte.bunte.de" always_null 
local-zone: "prospekte.bunte.de" always_null 
local-zone: "prospekte.haus.de" always_null 
local-zone: "prospekte.elle.de" always_null 
local-zone: "prospekte.freundin.de" always_null 
local-zone: "prospekte.mein-schoener-garten.de" always_null 
local-zone: "prospekte.super-illu.de" always_null 
local-zone: "prospekte.guter-rat.de" always_null 
local-zone: "prospekte.holidaycheck" always_null 
local-zone: "prospekte.jameda.de" always_null 
local-zone: "prospekte.freizeitrevue.de" always_null 
local-zone: "prospekte.lisa.de" always_null 
local-zone: "prospekte.brandsyoulove.de" always_null 
local-zone: "prospekte.burdastyle.de" always_null 
local-zone: "prospekte.instyle.de" always_null 
local-zone: "prospekte.instyle.de" always_null 
local-zone: "prospekte.computeruniverse.de" always_null 
local-zone: "prospekte.cyberport.de" always_null 
local-zone: "prospekte.daskochrezept.de" always_null 
local-zone: "prospekte.mietwagen-check.de" always_null 
local-zone: "prospekte.tvtoday.de" always_null 
local-zone: "prospekte.zoover.de" always_null 
local-zone: "prospekte.bestcheck.de" always_null 
local-zone: "prospekte.netmoms.de" always_null 
local-zone: "prospekte.finanzen100.de" always_null 
local-zone: "prospekte.cardscout.de" always_null 
local-zone: "prospekte.chip.de" always_null 
local-zone: "prospekte.focus.de" always_null 
local-zone: "prospekte.welt.de" always_null 
local-zone: "prospekte.stern.de" always_null 
local-zone: "prospekte.spiegel.de" always_null 
local-zone: "prospekte.bild.de" always_null 
local-zone: "games.amica.de" always_null 
local-zone: "games.cinema.de" always_null 
local-zone: "games.fitforfun.de" always_null 
local-zone: "games.patientus.de" always_null 
local-zone: "games.tvspielfilm.de" always_null 
local-zone: "games.playboy.de" always_null 
local-zone: "games.bunte.de" always_null 
local-zone: "games.haus.de" always_null 
local-zone: "games.elle.de" always_null 
local-zone: "games.freundin.de" always_null 
local-zone: "games.mein-schoener-garten.de" always_null 
local-zone: "games.super-illu.de" always_null 
local-zone: "games.guter-rat.de" always_null 
local-zone: "games.holidaycheck" always_null 
local-zone: "games.jameda.de" always_null 
local-zone: "games.freizeitrevue.de" always_null 
local-zone: "games.lisa.de" always_null 
local-zone: "games.brandsyoulove.de" always_null 
local-zone: "games.burdastyle.de" always_null 
local-zone: "games.instyle.de" always_null 
local-zone: "games.computeruniverse.de" always_null 
local-zone: "games.cyberport.de" always_null 
local-zone: "games.daskochrezept.de" always_null 
local-zone: "games.mietwagen-check.de" always_null 
local-zone: "games.tvtoday.de" always_null 
local-zone: "games.zoover.de" always_null 
local-zone: "games.bestcheck.de" always_null 
local-zone: "games.netmoms.de" always_null 
local-zone: "games.finanzen100.de" always_null 
local-zone: "games.cardscout.de" always_null 
local-zone: "games.chip.de" always_null 
local-zone: "games.focus.de" always_null 
local-zone: "games.welt.de" always_null 
local-zone: "games.stern.de" always_null 
local-zone: "games.spiegel.de" always_null 
local-zone: "games.bild.de" always_null 
local-zone: "vergleich.amica.de" always_null 
local-zone: "vergleich.cinema.de" always_null 
local-zone: "vergleich.fitforfun.de" always_null 
local-zone: "vergleich.patientus.de" always_null 
local-zone: "vergleich.tvspielfilm.de" always_null 
local-zone: "vergleich.playboy.de" always_null 
local-zone: "vergleich.bunte.de" always_null 
local-zone: "vergleich.haus.de" always_null 
local-zone: "vergleich.elle.de" always_null 
local-zone: "vergleich.freundin.de" always_null 
local-zone: "vergleich.mein-schoener-garten.de" always_null 
local-zone: "vergleich.super-illu.de" always_null 
local-zone: "vergleich.guter-rat.de" always_null 
local-zone: "vergleich.holidaycheck" always_null 
local-zone: "vergleich.jameda.de" always_null 
local-zone: "vergleich.freizeitrevue.de" always_null 
local-zone: "vergleich.lisa.de" always_null 
local-zone: "vergleich.brandsyoulove.de" always_null 
local-zone: "vergleich.burdastyle.de" always_null 
local-zone: "vergleich.instyle.de" always_null 
local-zone: "vergleich.computeruniverse.de" always_null 
local-zone: "vergleich.cyberport.de" always_null 
local-zone: "vergleich.daskochrezept.de" always_null 
local-zone: "vergleich.mietwagen-check.de" always_null 
local-zone: "vergleich.tvtoday.de" always_null 
local-zone: "vergleich.zoover.de" always_null 
local-zone: "vergleich.bestcheck.de" always_null 
local-zone: "vergleich.netmoms.de" always_null 
local-zone: "vergleich.finanzen100.de" always_null 
local-zone: "vergleich.cardscout.de" always_null 
local-zone: "vergleich.chip.de" always_null 
local-zone: "vergleich.focus.de" always_null 
local-zone: "vergleich.welt.de" always_null 
local-zone: "vergleich.stern.de" always_null 
local-zone: "vergleich.spiegel.de" always_null 
local-zone: "vergleich.bild.de" always_null 
local-zone: "kuendigen.amica.de" always_null 
local-zone: "kuendigen.cinema.de" always_null 
local-zone: "kuendigen.fitforfun.de" always_null 
local-zone: "kuendigen.patientus.de" always_null 
local-zone: "kuendigen.tvspielfilm.de" always_null 
local-zone: "kuendigen.playboy.de" always_null 
local-zone: "kuendigen.bunte.de" always_null 
local-zone: "kuendigen.haus.de" always_null 
local-zone: "kuendigen.elle.de" always_null 
local-zone: "kuendigen.freundin.de" always_null 
local-zone: "kuendigen.mein-schoener-garten.de" always_null 
local-zone: "kuendigen.super-illu.de" always_null 
local-zone: "kuendigen.guter-rat.de" always_null 
local-zone: "kuendigen.holidaycheck" always_null 
local-zone: "kuendigen.jameda.de" always_null 
local-zone: "kuendigen.freizeitrevue.de" always_null 
local-zone: "kuendigen.lisa.de" always_null 
local-zone: "kuendigen.brandsyoulove.de" always_null 
local-zone: "kuendigen.burdastyle.de" always_null 
local-zone: "kuendigen.instyle.de" always_null 
local-zone: "kuendigen.computeruniverse.de" always_null 
local-zone: "kuendigen.cyberport.de" always_null 
local-zone: "kuendigen.daskochrezept.de" always_null 
local-zone: "kuendigen.mietwagen-check.de" always_null 
local-zone: "kuendigen.tvtoday.de" always_null 
local-zone: "kuendigen.zoover.de" always_null 
local-zone: "kuendigen.bestcheck.de" always_null 
local-zone: "kuendigen.netmoms.de" always_null 
local-zone: "kuendigen.finanzen100.de" always_null 
local-zone: "kuendigen.cardscout.de" always_null 
local-zone: "kuendigen.chip.de" always_null 
local-zone: "kuendigen.focus.de" always_null 
local-zone: "kuendigen.welt.de" always_null 
local-zone: "kuendigen.stern.de" always_null 
local-zone: "kuendigen.spiegel.de" always_null 
local-zone: "kuendigen.bild.de" always_null 
local-zone: "rechnerportal.amica.de" always_null 
local-zone: "rechnerportal.cinema.de" always_null 
local-zone: "rechnerportal.fitforfun.de" always_null 
local-zone: "rechnerportal.patientus.de" always_null 
local-zone: "rechnerportal.tvspielfilm.de" always_null 
local-zone: "rechnerportal.playboy.de" always_null 
local-zone: "rechnerportal.bunte.de" always_null 
local-zone: "rechnerportal.haus.de" always_null 
local-zone: "rechnerportal.elle.de" always_null 
local-zone: "rechnerportal.freundin.de" always_null 
local-zone: "rechnerportal.mein-schoener-garten.de" always_null 
local-zone: "rechnerportal.super-illu.de" always_null 
local-zone: "rechnerportal.guter-rat.de" always_null 
local-zone: "rechnerportal.holidaycheck" always_null 
local-zone: "rechnerportal.jameda.de" always_null 
local-zone: "rechnerportal.freizeitrevue.de" always_null 
local-zone: "rechnerportal.lisa.de" always_null 
local-zone: "rechnerportal.brandsyoulove.de" always_null 
local-zone: "rechnerportal.burdastyle.de" always_null 
local-zone: "rechnerportal.instyle.de" always_null 
local-zone: "rechnerportal.computeruniverse.de" always_null 
local-zone: "rechnerportal.cyberport.de" always_null 
local-zone: "rechnerportal.daskochrezept.de" always_null 
local-zone: "rechnerportal.mietwagen-check.de" always_null 
local-zone: "rechnerportal.tvtoday.de" always_null 
local-zone: "rechnerportal.zoover.de" always_null 
local-zone: "rechnerportal.bestcheck.de" always_null 
local-zone: "rechnerportal.netmoms.de" always_null 
local-zone: "rechnerportal.finanzen100.de" always_null 
local-zone: "rechnerportal.cardscout.de" always_null 
local-zone: "rechnerportal.chip.de" always_null 
local-zone: "rechnerportal.focus.de" always_null 
local-zone: "rechnerportal.welt.de" always_null 
local-zone: "rechnerportal.stern.de" always_null 
local-zone: "rechnerportal.spiegel.de" always_null 
local-zone: "rechnerportal.bild.de" always_null 
local-zone: "tarif.amica.de" always_null 
local-zone: "tarif.cinema.de" always_null 
local-zone: "tarif.fitforfun.de" always_null 
local-zone: "tarif.patientus.de" always_null 
local-zone: "tarif.tvspielfilm.de" always_null 
local-zone: "tarif.playboy.de" always_null 
local-zone: "tarif.bunte.de" always_null 
local-zone: "tarif.haus.de" always_null 
local-zone: "tarif.elle.de" always_null 
local-zone: "tarif.freundin.de" always_null 
local-zone: "tarif.mein-schoener-garten.de" always_null 
local-zone: "tarif.super-illu.de" always_null 
local-zone: "tarif.guter-rat.de" always_null 
local-zone: "tarif.holidaycheck" always_null 
local-zone: "tarif.jameda.de" always_null 
local-zone: "tarif.freizeitrevue.de" always_null 
local-zone: "tarif.lisa.de" always_null 
local-zone: "tarif.brandsyoulove.de" always_null 
local-zone: "tarif.burdastyle.de" always_null 
local-zone: "tarif.instyle.de" always_null 
local-zone: "tarif.computeruniverse.de" always_null 
local-zone: "tarif.cyberport.de" always_null 
local-zone: "tarif.daskochrezept.de" always_null 
local-zone: "tarif.mietwagen-check.de" always_null 
local-zone: "tarif.tvtoday.de" always_null 
local-zone: "tarif.zoover.de" always_null 
local-zone: "tarif.bestcheck.de" always_null 
local-zone: "tarif.netmoms.de" always_null 
local-zone: "tarif.finanzen100.de" always_null 
local-zone: "tarif.cardscout.de" always_null 
local-zone: "tarif.chip.de" always_null 
local-zone: "tarif.focus.de" always_null 
local-zone: "tarif.welt.de" always_null 
local-zone: "tarif.stern.de" always_null 
local-zone: "tarif.spiegel.de" always_null 
local-zone: "shop.amica.de" always_null 
local-zone: "shop.amica.de" always_null 
local-zone: "shop.cinema.de" always_null 
local-zone: "shop.fitforfun.de" always_null 
local-zone: "shop.patientus.de" always_null 
local-zone: "shop.tvspielfilm.de" always_null 
local-zone: "shop.playboy.de" always_null 
local-zone: "shop.bunte.de" always_null 
local-zone: "shop.haus.de" always_null 
local-zone: "shop.elle.de" always_null 
local-zone: "shop.freundin.de" always_null 
local-zone: "shop.mein-schoener-garten.de" always_null 
local-zone: "shop.super-illu.de" always_null 
local-zone: "shop.guter-rat.de" always_null 
local-zone: "shop.holidaycheck" always_null 
local-zone: "shop.jameda.de" always_null 
local-zone: "shop.freizeitrevue.de" always_null 
local-zone: "shop.lisa.de" always_null 
local-zone: "shop.brandsyoulove.de" always_null 
local-zone: "shop.burdastyle.de" always_null 
local-zone: "shop.instyle.de" always_null 
local-zone: "shop.computeruniverse.de" always_null 
local-zone: "shop.cyberport.de" always_null 
local-zone: "shop.daskochrezept.de" always_null 
local-zone: "shop.mietwagen-check.de" always_null 
local-zone: "shop.tvtoday.de" always_null 
local-zone: "shop.zoover.de" always_null 
local-zone: "shop.bestcheck.de" always_null 
local-zone: "shop.netmoms.de" always_null 
local-zone: "shop.finanzen100.de" always_null 
local-zone: "shop.cardscout.de" always_null 
local-zone: "shop.chip.de" always_null 
local-zone: "shop.focus.de" always_null 
local-zone: "shop.welt.de" always_null 
local-zone: "shop.stern.de" always_null 
local-zone: "shop.spiegel.de" always_null 
local-zone: "shop.bild.de" always_null 
local-zone: "deals.amica.de" always_null 
local-zone: "deals.cinema.de" always_null 
local-zone: "deals.fitforfun.de" always_null 
local-zone: "deals.patientus.de" always_null 
local-zone: "deals.tvspielfilm.de" always_null 
local-zone: "deals.playboy.de" always_null 
local-zone: "deals.bunte.de" always_null 
local-zone: "deals.haus.de" always_null 
local-zone: "deals.elle.de" always_null 
local-zone: "deals.freundin.de" always_null 
local-zone: "deals.mein-schoener-garten.de" always_null 
local-zone: "deals.super-illu.de" always_null 
local-zone: "deals.guter-rat.de" always_null 
local-zone: "deals.holidaycheck" always_null 
local-zone: "deals.jameda.de" always_null 
local-zone: "deals.freizeitrevue.de" always_null 
local-zone: "deals.lisa.de" always_null 
local-zone: "deals.brandsyoulove.de" always_null 
local-zone: "deals.burdastyle.de" always_null 
local-zone: "deals.instyle.de" always_null 
local-zone: "deals.computeruniverse.de" always_null 
local-zone: "deals.cyberport.de" always_null 
local-zone: "deals.daskochrezept.de" always_null 
local-zone: "deals.mietwagen-check.de" always_null 
local-zone: "deals.tvtoday.de" always_null 
local-zone: "deals.zoover.de" always_null 
local-zone: "deals.bestcheck.de" always_null 
local-zone: "deals.netmoms.de" always_null 
local-zone: "deals.finanzen100.de" always_null 
local-zone: "deals.cardscout.de" always_null 
local-zone: "deals.chip.de" always_null 
local-zone: "deals.focus.de" always_null 
local-zone: "deals.welt.de" always_null 
local-zone: "deals.stern.de" always_null 
local-zone: "deals.spiegel.de" always_null 
local-zone: "deals.bild.de" always_null 
local-zone: "shopping.amica.de" always_null 
local-zone: "shopping.cinema.de" always_null 
local-zone: "shopping.fitforfun.de" always_null 
local-zone: "shopping.patientus.de" always_null 
local-zone: "shopping.tvspielfilm.de" always_null 
local-zone: "shopping.playboy.de" always_null 
local-zone: "shopping.bunte.de" always_null 
local-zone: "shopping.haus.de" always_null 
local-zone: "shopping.elle.de" always_null 
local-zone: "shopping.freundin.de" always_null 
local-zone: "shopping.mein-schoener-garten.de" always_null 
local-zone: "shopping.super-illu.de" always_null 
local-zone: "shopping.guter-rat.de" always_null 
local-zone: "shopping.holidaycheck" always_null 
local-zone: "shopping.jameda.de" always_null 
local-zone: "shopping.freizeitrevue.de" always_null 
local-zone: "shopping.lisa.de" always_null 
local-zone: "shopping.brandsyoulove.de" always_null 
local-zone: "shopping.burdastyle.de" always_null 
local-zone: "shopping.instyle.de" always_null 
local-zone: "shopping.computeruniverse.de" always_null 
local-zone: "shopping.cyberport.de" always_null 
local-zone: "shopping.daskochrezept.de" always_null 
local-zone: "shopping.mietwagen-check.de" always_null 
local-zone: "shopping.tvtoday.de" always_null 
local-zone: "shopping.zoover.de" always_null 
local-zone: "shopping.bestcheck.de" always_null 
local-zone: "shopping.netmoms.de" always_null 
local-zone: "shopping.finanzen100.de" always_null 
local-zone: "shopping.cardscout.de" always_null 
local-zone: "shopping.chip.de" always_null 
local-zone: "shopping.focus.de" always_null 
local-zone: "shopping.welt.de" always_null 
local-zone: "shopping.stern.de" always_null 
local-zone: "shopping.spiegel.de" always_null 
local-zone: "shopping.bild.de" always_null 
local-zone: "service.amica.de" always_null 
local-zone: "service.cinema.de" always_null 
local-zone: "service.fitforfun.de" always_null 
local-zone: "service.patientus.de" always_null 
local-zone: "service.tvspielfilm.de" always_null 
local-zone: "service.playboy.de" always_null 
local-zone: "service.bunte.de" always_null 
local-zone: "service.haus.de" always_null 
local-zone: "service.elle.de" always_null 
local-zone: "service.freundin.de" always_null 
local-zone: "service.mein-schoener-garten.de" always_null 
local-zone: "service.super-illu.de" always_null 
local-zone: "service.guter-rat.de" always_null 
local-zone: "service.holidaycheck" always_null 
local-zone: "service.jameda.de" always_null 
local-zone: "service.freizeitrevue.de" always_null 
local-zone: "service.lisa.de" always_null 
local-zone: "service.brandsyoulove.de" always_null 
local-zone: "service.burdastyle.de" always_null 
local-zone: "service.instyle.de" always_null 
local-zone: "service.computeruniverse.de" always_null 
local-zone: "service.cyberport.de" always_null 
local-zone: "service.daskochrezept.de" always_null 
local-zone: "service.mietwagen-check.de" always_null 
local-zone: "service.tvtoday.de" always_null 
local-zone: "service.zoover.de" always_null 
local-zone: "service.bestcheck.de" always_null 
local-zone: "service.netmoms.de" always_null 
local-zone: "service.finanzen100.de" always_null 
local-zone: "service.cardscout.de" always_null 
local-zone: "service.chip.de" always_null 
local-zone: "service.focus.de" always_null 
local-zone: "service.welt.de" always_null 
local-zone: "service.stern.de" always_null 
local-zone: "service.spiegel.de" always_null 
local-zone: "service.bild.de" always_null 
local-zone: "gewinnspiel.amica.de" always_null 
local-zone: "gewinnspiel.cinema.de" always_null 
local-zone: "gewinnspiel.fitforfun.de" always_null 
local-zone: "gewinnspiel.patientus.de" always_null 
local-zone: "gewinnspiel.tvspielfilm.de" always_null 
local-zone: "gewinnspiel.playboy.de" always_null 
local-zone: "gewinnspiel.bunte.de" always_null 
local-zone: "gewinnspiel.haus.de" always_null 
local-zone: "gewinnspiel.elle.de" always_null 
local-zone: "gewinnspiel.freundin.de" always_null 
local-zone: "gewinnspiel.mein-schoener-garten.de" always_null 
local-zone: "gewinnspiel.super-illu.de" always_null 
local-zone: "gewinnspiel.guter-rat.de" always_null 
local-zone: "gewinnspiel.holidaycheck" always_null 
local-zone: "gewinnspiel.jameda.de" always_null 
local-zone: "gewinnspiel.freizeitrevue.de" always_null 
local-zone: "gewinnspiel.lisa.de" always_null 
local-zone: "gewinnspiel.brandsyoulove.de" always_null 
local-zone: "gewinnspiel.burdastyle.de" always_null 
local-zone: "gewinnspiel.instyle.de" always_null 
local-zone: "gewinnspiel.computeruniverse.de" always_null 
local-zone: "gewinnspiel.cyberport.de" always_null 
local-zone: "gewinnspiel.daskochrezept.de" always_null 
local-zone: "gewinnspiel.mietwagen-check.de" always_null 
local-zone: "gewinnspiel.tvtoday.de" always_null 
local-zone: "gewinnspiel.zoover.de" always_null 
local-zone: "gewinnspiel.bestcheck.de" always_null 
local-zone: "gewinnspiel.netmoms.de" always_null 
local-zone: "gewinnspiel.finanzen100.de" always_null 
local-zone: "gewinnspiel.cardscout.de" always_null 
local-zone: "gewinnspiel.chip.de" always_null 
local-zone: "gewinnspiel.focus.de" always_null 
local-zone: "gewinnspiel.welt.de" always_null 
local-zone: "gewinnspiel.stern.de" always_null 
local-zone: "gewinnspiel.spiegel.de" always_null 
local-zone: "gewinnspiel.bild.de" always_null
local-zone: "shoppingadvisor.amica.de" always_null 
local-zone: "shoppingadvisor.cinema.de" always_null 
local-zone: "shoppingadvisor.fitforfun.de" always_null 
local-zone: "shoppingadvisor.patientus.de" always_null 
local-zone: "shoppingadvisor.tvspielfilm.de" always_null 
local-zone: "shoppingadvisor.playboy.de" always_null 
local-zone: "shoppingadvisor.bunte.de" always_null 
local-zone: "shoppingadvisor.haus.de" always_null 
local-zone: "shoppingadvisor.elle.de" always_null 
local-zone: "shoppingadvisor.freundin.de" always_null 
local-zone: "shoppingadvisor.mein-schoener-garten.de" always_null 
local-zone: "shoppingadvisor.super-illu.de" always_null 
local-zone: "shoppingadvisor.guter-rat.de" always_null 
local-zone: "shoppingadvisor.holidaycheck" always_null 
local-zone: "shoppingadvisor.jameda.de" always_null 
local-zone: "shoppingadvisor.freizeitrevue.de" always_null 
local-zone: "shoppingadvisor.lisa.de" always_null 
local-zone: "shoppingadvisor.brandsyoulove.de" always_null 
local-zone: "shoppingadvisor.burdastyle.de" always_null 
local-zone: "shoppingadvisor.instyle.de" always_null 
local-zone: "shoppingadvisor.computeruniverse.de" always_null 
local-zone: "shoppingadvisor.cyberport.de" always_null 
local-zone: "shoppingadvisor.daskochrezept.de" always_null 
local-zone: "shoppingadvisor.mietwagen-check.de" always_null 
local-zone: "shoppingadvisor.tvtoday.de" always_null 
local-zone: "shoppingadvisor.zoover.de" always_null 
local-zone: "shoppingadvisor.bestcheck.de" always_null 
local-zone: "shoppingadvisor.netmoms.de" always_null 
local-zone: "shoppingadvisor.finanzen100.de" always_null 
local-zone: "shoppingadvisor.cardscout.de" always_null 
local-zone: "shoppingadvisor.chip.de" always_null 
local-zone: "shoppingadvisor.focus.de" always_null 
local-zone: "shoppingadvisor.welt.de" always_null 
local-zone: "shoppingadvisor.stern.de" always_null 
local-zone: "shoppingadvisor.spiegel.de" always_null 
local-zone: "shoppingadvisor.bild.de" always_null
local-zone: "article.amica.de" always_null 
local-zone: "article.cinema.de" always_null 
local-zone: "article.fitforfun.de" always_null 
local-zone: "article.patientus.de" always_null 
local-zone: "article.tvspielfilm.de" always_null 
local-zone: "article.playboy.de" always_null 
local-zone: "article.bunte.de" always_null 
local-zone: "article.haus.de" always_null 
local-zone: "article.elle.de" always_null 
local-zone: "article.freundin.de" always_null 
local-zone: "article.mein-schoener-garten.de" always_null 
local-zone: "article.super-illu.de" always_null 
local-zone: "article.guter-rat.de" always_null 
local-zone: "article.holidaycheck" always_null 
local-zone: "article.jameda.de" always_null 
local-zone: "article.freizeitrevue.de" always_null 
local-zone: "article.lisa.de" always_null 
local-zone: "article.brandsyoulove.de" always_null 
local-zone: "article.burdastyle.de" always_null 
local-zone: "article.instyle.de" always_null 
local-zone: "article.computeruniverse.de" always_null 
local-zone: "article.cyberport.de" always_null 
local-zone: "article.daskochrezept.de" always_null 
local-zone: "article.mietwagen-check.de" always_null 
local-zone: "article.tvtoday.de" always_null 
local-zone: "article.zoover.de" always_null 
local-zone: "article.bestcheck.de" always_null 
local-zone: "article.netmoms.de" always_null 
local-zone: "article.finanzen100.de" always_null 
local-zone: "article.cardscout.de" always_null 
local-zone: "article.chip.de" always_null 
local-zone: "article.focus.de" always_null 
local-zone: "article.welt.de" always_null 
local-zone: "article.stern.de" always_null 
local-zone: "article.spiegel.de" always_null 
local-zone: "article.bild.de" always_null
local-zone: "im-widget.amica.de" always_null 
local-zone: "im-widget.cinema.de" always_null 
local-zone: "im-widget.fitforfun.de" always_null 
local-zone: "im-widget.patientus.de" always_null 
local-zone: "im-widget.tvspielfilm.de" always_null 
local-zone: "im-widget.playboy.de" always_null 
local-zone: "im-widget.bunte.de" always_null 
local-zone: "im-widget.haus.de" always_null 
local-zone: "im-widget.elle.de" always_null 
local-zone: "im-widget.freundin.de" always_null 
local-zone: "im-widget.mein-schoener-garten.de" always_null 
local-zone: "im-widget.super-illu.de" always_null 
local-zone: "im-widget.guter-rat.de" always_null 
local-zone: "im-widget.holidaycheck" always_null 
local-zone: "im-widget.jameda.de" always_null 
local-zone: "im-widget.freizeitrevue.de" always_null 
local-zone: "im-widget.lisa.de" always_null 
local-zone: "im-widget.brandsyoulove.de" always_null 
local-zone: "im-widget.burdastyle.de" always_null 
local-zone: "im-widget.instyle.de" always_null 
local-zone: "im-widget.computeruniverse.de" always_null 
local-zone: "im-widget.cyberport.de" always_null 
local-zone: "im-widget.daskochrezept.de" always_null 
local-zone: "im-widget.mietwagen-check.de" always_null 
local-zone: "im-widget.tvtoday.de" always_null 
local-zone: "im-widget.zoover.de" always_null 
local-zone: "im-widget.bestcheck.de" always_null 
local-zone: "im-widget.netmoms.de" always_null 
local-zone: "im-widget.finanzen100.de" always_null 
local-zone: "im-widget.cardscout.de" always_null 
local-zone: "im-widget.chip.de" always_null 
local-zone: "im-widget.focus.de" always_null 
local-zone: "im-widget.welt.de" always_null 
local-zone: "im-widget.stern.de" always_null 
local-zone: "im-widget.spiegel.de" always_null 
local-zone: "im-widget.bild.de" always_null
local-zone: "widget.amica.de" always_null 
local-zone: "widget.cinema.de" always_null 
local-zone: "widget.fitforfun.de" always_null 
local-zone: "widget.patientus.de" always_null 
local-zone: "widget.tvspielfilm.de" always_null 
local-zone: "widget.playboy.de" always_null 
local-zone: "widget.bunte.de" always_null 
local-zone: "widget.haus.de" always_null 
local-zone: "widget.elle.de" always_null 
local-zone: "widget.freundin.de" always_null 
local-zone: "widget.mein-schoener-garten.de" always_null 
local-zone: "widget.super-illu.de" always_null 
local-zone: "widget.guter-rat.de" always_null 
local-zone: "widget.holidaycheck" always_null 
local-zone: "widget.jameda.de" always_null 
local-zone: "widget.freizeitrevue.de" always_null 
local-zone: "widget.lisa.de" always_null 
local-zone: "widget.brandsyoulove.de" always_null 
local-zone: "widget.burdastyle.de" always_null 
local-zone: "widget.instyle.de" always_null 
local-zone: "widget.computeruniverse.de" always_null 
local-zone: "widget.cyberport.de" always_null 
local-zone: "widget.daskochrezept.de" always_null 
local-zone: "widget.mietwagen-check.de" always_null 
local-zone: "widget.tvtoday.de" always_null 
local-zone: "widget.zoover.de" always_null 
local-zone: "widget.bestcheck.de" always_null 
local-zone: "widget.netmoms.de" always_null 
local-zone: "widget.finanzen100.de" always_null 
local-zone: "widget.cardscout.de" always_null 
local-zone: "widget.chip.de" always_null 
local-zone: "widget.focus.de" always_null 
local-zone: "widget.welt.de" always_null 
local-zone: "widget.stern.de" always_null 
local-zone: "widget.spiegel.de" always_null 
local-zone: "widget.bild.de" always_null

local-zone: "user-rating.burda-forward.de" always_null
local-zone: "d3ak46ifsn9mnh.cloudfront.net" always_null

local-zone: "101com.com" always_null 
local-zone: "101order.com" always_null 
local-zone: "1-1ads.com" always_null 
local-zone: "123freeavatars.com" always_null 
local-zone: "180hits.de" always_null 
local-zone: "180searchassistant.com" always_null 
local-zone: "1rx.io" always_null 
local-zone: "207.net" always_null 
local-zone: "247media.com" always_null 
local-zone: "24log.com" always_null 
local-zone: "24log.de" always_null 
local-zone: "24pm-affiliation.com" always_null 
local-zone: "2mdn.net" always_null 
local-zone: "2o7.net" always_null 
local-zone: "2znp09oa.com" always_null 
local-zone: "30ads.com" always_null 
local-zone: "3337723.com" always_null 
local-zone: "33across.com" always_null 
local-zone: "360yield.com" always_null 
local-zone: "3lift.com" always_null 
local-zone: "4affiliate.net" always_null 
local-zone: "4d5.net" always_null 
local-zone: "4info.com" always_null 
local-zone: "4jnzhl0d0.com" always_null 
local-zone: "50websads.com" always_null 
local-zone: "518ad.com" always_null 
local-zone: "51yes.com" always_null 
local-zone: "5ijo.01net.com" always_null 
local-zone: "5mcwl.pw" always_null 
local-zone: "6ldu6qa.com" always_null 
local-zone: "6sc.co" always_null 
local-zone: "777partner.com" always_null 
local-zone: "77tracking.com" always_null 
local-zone: "7bpeople.com" always_null 
local-zone: "7search.com" always_null 
local-zone: "80asehdb" always_null 
local-zone: "80aswg" always_null 
local-zone: "82o9v830.com" always_null 
local-zone: "a.aproductmsg.com" always_null 
local-zone: "a.consumer.net" always_null 
local-zone: "a.mktw.net" always_null 
local-zone: "a.muloqot.uz" always_null 
local-zone: "a.pub.network" always_null 
local-zone: "a.sakh.com" always_null 
local-zone: "a.ucoz.net" always_null 
local-zone: "a.ucoz.ru" always_null 
local-zone: "a.vartoken.com" always_null 
local-zone: "a.vfghd.com" always_null 
local-zone: "a.vfgtb.com" always_null 
local-zone: "a.xanga.com" always_null 
local-zone: "a135.wftv.com" always_null 
local-zone: "a5.overclockers.ua" always_null 
local-zone: "a8a8altrk.com" always_null 
local-zone: "aaddzz.com" always_null 
local-zone: "a-ads.com" always_null 
local-zone: "aa-metrics.beauty.hotpepper.jp" always_null 
local-zone: "aa-metrics.recruit-card.jp" always_null 
local-zone: "aa-metrics.trip-ai.jp" always_null 
local-zone: "aaxads.com" always_null 
local-zone: "aaxdetect.com" always_null 
local-zone: "aax-eu.amazon-adsystem.com" always_null 
local-zone: "aax-eu-dub.amazon.com" always_null 
local-zone: "abacho.net" always_null 
local-zone: "abackchain.com" always_null 
local-zone: "abandonedaction.com" always_null 
local-zone: "abc-ads.com" always_null 
local-zone: "aboardlevel.com" always_null 
local-zone: "aboutads.gr" always_null 
local-zone: "abruptroad.com" always_null 
local-zone: "absentstream.com" always_null 
local-zone: "absoluteclickscom.com" always_null 
local-zone: "absorbingband.com" always_null 
local-zone: "absurdwater.com" always_null 
local-zone: "abtasty.com" always_null 
local-zone: "abz.com" always_null 
local-zone: "ac.rnm.ca" always_null 
local-zone: "acbsearch.com" always_null 
local-zone: "acceptable.a-ads.com" always_null 
local-zone: "acid-adserver.click" always_null 
local-zone: "acridtwist.com" always_null 
local-zone: "actionsplash.com" always_null 
local-zone: "actonsoftware.com" always_null 
local-zone: "actualdeals.com" always_null 
local-zone: "actuallysheep.com" always_null 
local-zone: "actuallysnake.com" always_null 
local-zone: "acuityads.com" always_null 
local-zone: "acuityplatform.com" always_null 
local-zone: "ad.100.tbn.ru" always_null 
local-zone: "ad.71i.de" always_null 
local-zone: "ad.a8.net" always_null 
local-zone: "ad.a-ads.com" always_null 
local-zone: "ad.abcnews.com" always_null 
local-zone: "ad.abctv.com" always_null 
local-zone: "ad.aboutwebservices.com" always_null 
local-zone: "ad.abum.com" always_null 
local-zone: "ad.admitad.com" always_null 
local-zone: "ad.allboxing.ru" always_null 
local-zone: "ad.allstar.cz" always_null 
local-zone: "ad.altervista.org" always_null 
local-zone: "ad.amgdgt.com" always_null 
local-zone: "ad.anuntis.com" always_null 
local-zone: "ad.auditude.com" always_null 
local-zone: "ad.bitmedia.io" always_null 
local-zone: "ad.bizo.com" always_null 
local-zone: "ad.bnmla.com" always_null 
local-zone: "ad.bondage.com" always_null 
local-zone: "ad.caradisiac.com" always_null 
local-zone: "ad.centrum.cz" always_null 
local-zone: "ad.cgi.cz" always_null 
local-zone: "ad.choiceradio.com" always_null 
local-zone: "ad.clix.pt" always_null 
local-zone: "ad.cooks.com" always_null 
local-zone: "ad.digitallook.com" always_null 
local-zone: "ad.domainfactory.de" always_null 
local-zone: "ad.eurosport.com" always_null 
local-zone: "ad.exyws.org" always_null 
local-zone: "ad.flurry.com" always_null 
local-zone: "ad.foxnetworks.com" always_null 
local-zone: "ad.freecity.de" always_null 
local-zone: "ad.grafika.cz" always_null 
local-zone: "ad.gt" always_null 
local-zone: "ad.hbv.de" always_null 
local-zone: "ad.hodomobile.com" always_null 
local-zone: "ad.hyena.cz" always_null 
local-zone: "ad.iinfo.cz" always_null 
local-zone: "ad.ilove.ch" always_null 
local-zone: "ad.infoseek.com" always_null 
local-zone: "ad.intl.xiaomi.com" always_null 
local-zone: "ad.jacotei.com.br" always_null 
local-zone: "ad.jamba.net" always_null 
local-zone: "ad.jamster.co.uk" always_null 
local-zone: "ad.jetsoftware.com" always_null 
local-zone: "ad.keenspace.com" always_null 
local-zone: "ad.liveinternet.ru" always_null 
local-zone: "ad.lupa.cz" always_null 
local-zone: "ad.media-servers.net" always_null 
local-zone: "ad.mediastorm.hu" always_null 
local-zone: "ad.mg" always_null 
local-zone: "ad.mobstazinc.cn" always_null 
local-zone: "ad.musicmatch.com" always_null 
local-zone: "ad.myapple.pl" always_null 
local-zone: "ad.mynetreklam.com.streamprovider.net" always_null 
local-zone: "ad.nachtagenten.de" always_null 
local-zone: "ad.nozonedata.com" always_null 
local-zone: "ad.nttnavi.co.jp" always_null 
local-zone: "ad.nwt.cz" always_null 
local-zone: "ad.pandora.tv" always_null 
local-zone: "ad.period-calendar.com" always_null 
local-zone: "ad.preferances.com" always_null 
local-zone: "ad.profiwin.de" always_null 
local-zone: "ad.prv.pl" always_null 
local-zone: "ad.reunion.com" always_null 
local-zone: "ad.sensismediasmart.com.au" always_null 
local-zone: "ad.simflight.com" always_null 
local-zone: "ad.simgames.net" always_null 
local-zone: "ad.style" always_null 
local-zone: "ad.tapthislink.com" always_null 
local-zone: "ad.tbn.ru" always_null 
local-zone: "ad.technoratimedia.com" always_null 
local-zone: "ad.thewheelof.com" always_null 
local-zone: "ad.turn.com" always_null 
local-zone: "ad.tv2.no" always_null 
local-zone: "ad.universcine.com" always_null 
local-zone: "ad.usatoday.com" always_null 
local-zone: "ad.virtual-nights.com" always_null 
local-zone: "ad.wavu.hu" always_null 
local-zone: "ad.way.cz" always_null 
local-zone: "ad.weatherbug.com" always_null 
local-zone: "ad.wsod.com" always_null 
local-zone: "ad.wz.cz" always_null 
local-zone: "ad.xiaomi.com" always_null 
local-zone: "ad.xmovies8.si" always_null 
local-zone: "ad.xrea.com" always_null 
local-zone: "ad.yadro.ru" always_null 
local-zone: "ad.zanox.com" always_null 
local-zone: "ad0.bigmir.net" always_null 
local-zone: "ad01.mediacorpsingapore.com" always_null 
local-zone: "ad1.emule-project.org" always_null 
local-zone: "ad1.eventmanager.co.kr" always_null 
local-zone: "ad1.kde.cz" always_null 
local-zone: "ad1.pamedia.com.au" always_null 
local-zone: "ad1mat.de" always_null 
local-zone: "ad2.iinfo.cz" always_null 
local-zone: "ad2.lupa.cz" always_null 
local-zone: "ad2.netriota.hu" always_null 
local-zone: "ad2.nmm.de" always_null 
local-zone: "ad2.xrea.com" always_null 
local-zone: "ad2mat.de" always_null 
local-zone: "ad3.iinfo.cz" always_null 
local-zone: "ad3.pamedia.com.au" always_null 
local-zone: "ad3.xrea.com" always_null 
local-zone: "ad3mat.de" always_null 
local-zone: "ad4game.com" always_null 
local-zone: "ad4mat.com" always_null 
local-zone: "ad4mat.de" always_null 
local-zone: "ad4mat.net" always_null 
local-zone: "adabra.com" always_null 
local-zone: "adaction.de" always_null 
local-zone: "adadvisor.net" always_null 
local-zone: "adalliance.io" always_null 
local-zone: "adap.tv" always_null 
local-zone: "adapt.tv" always_null 
local-zone: "adaranth.com" always_null 
local-zone: "ad-balancer.at" always_null 
local-zone: "ad-balancer.net" always_null 
local-zone: "adbilty.me" always_null 
local-zone: "adblade.com" always_null 
local-zone: "adblade.org" always_null 
local-zone: "adblockanalytics.com" always_null 
local-zone: "adbooth.net" always_null 
local-zone: "adbot.com" always_null 
local-zone: "adbrite.com" always_null 
local-zone: "adbrn.com" always_null 
local-zone: "adbroker.de" always_null 
local-zone: "adbunker.com" always_null 
local-zone: "adbutler.com" always_null 
local-zone: "adbuyer.com" always_null 
local-zone: "adbuyer3.lycos.com" always_null 
local-zone: "adcampo.com" always_null 
local-zone: "adcannyads.com" always_null 
local-zone: "adcash.com" always_null 
local-zone: "adcast.deviantart.com" always_null 
local-zone: "adcell.de" always_null 
local-zone: "adcenter.net" always_null 
local-zone: "adcentriconline.com" always_null 
local-zone: "adclick.com" always_null 
local-zone: "adclick.de" always_null 
local-zone: "adclick.net" always_null 
local-zone: "adclient1.tucows.com" always_null 
local-zone: "adcolony.com" always_null 
local-zone: "adcomplete.com" always_null 
local-zone: "adconion.com" always_null 
local-zone: "adcontent.gamespy.com" always_null 
local-zone: "adcontrolsolutions.net" always_null 
local-zone: "ad-cupid.com" always_null 
local-zone: "adcycle.com" always_null 
local-zone: "add.newmedia.cz" always_null 
local-zone: "ad-delivery.net" always_null 
local-zone: "addfreestats.com" always_null 
local-zone: "addme.com" always_null 
local-zone: "adecn.com" always_null 
local-zone: "adeimptrck.com" always_null 
local-zone: "ademails.com" always_null 
local-zone: "adengage.com" always_null 
local-zone: "adetracking.com" always_null 
local-zone: "adexc.net" always_null 
local-zone: "adexchangegate.com" always_null 
local-zone: "adexchangeprediction.com" always_null 
local-zone: "adexpose.com" always_null 
local-zone: "adext.inkclub.com" always_null 
local-zone: "adf.ly" always_null 
local-zone: "adfarm.com" always_null 
local-zone: "adfarm.de" always_null 
local-zone: "adfarm.mediaplex.com" always_null 
local-zone: "adfarm.net" always_null 
local-zone: "adfarm1.com" always_null 
local-zone: "adfarm1.net" always_null 
local-zone: "adfarm2.com" always_null 
local-zone: "adfarm2.net" always_null 
local-zone: "adfarm3.com" always_null 
local-zone: "adfarm3.de" always_null 
local-zone: "adfarm3.net" always_null 
local-zone: "adfarm4.com" always_null 
local-zone: "adfarm4.de" always_null 
local-zone: "adfarm4.net" always_null 
local-zone: "adfarmonline.com" always_null 
local-zone: "adfarmonline.de" always_null 
local-zone: "adfarmonline.net" always_null 
local-zone: "adflight.com" always_null 
local-zone: "adforce.com" always_null 
local-zone: "adform.com" always_null 
local-zone: "adform.de" always_null 
local-zone: "adform.net" always_null 
local-zone: "adformdsp.net" always_null 
local-zone: "adfram.net" always_null 
local-zone: "adfram1.de" always_null 
local-zone: "adfram2.de" always_null 
local-zone: "adfrom.com" always_null 
local-zone: "adfrom.de" always_null 
local-zone: "adfrom.net" always_null 
local-zone: "adfs.senacrs.com.br" always_null 
local-zone: "adgardener.com" always_null 
local-zone: "adgoto.com" always_null 
local-zone: "adhaven.com" always_null 
local-zone: "adhese.be" always_null 
local-zone: "adhese.com" always_null 
local-zone: "adhigh.net" always_null 
local-zone: "adhoc4.net" always_null 
local-zone: "adhunter.media" always_null 
local-zone: "adidas-deutschland.com" always_null 
local-zone: "adimage.guardian.co.uk" always_null 
local-zone: "adimages.been.com" always_null 
local-zone: "adimages.carsoup.com" always_null 
local-zone: "adimages.go.com" always_null 
local-zone: "adimages.homestore.com" always_null 
local-zone: "adimages.omroepzeeland.nl" always_null 
local-zone: "adimages.sanomawsoy.fi" always_null 
local-zone: "adimg.com.com" always_null 
local-zone: "adimg.uimserv.net" always_null 
local-zone: "adimg1.chosun.com" always_null 
local-zone: "adimgs.sapo.pt" always_null 
local-zone: "adinjector.net" always_null 
local-zone: "adinterax.com" always_null 
local-zone: "adisfy.com" always_null 
local-zone: "adition.com" always_null 
local-zone: "adition.de" always_null 
local-zone: "adition.net" always_null 
local-zone: "adizio.com" always_null 
local-zone: "adjix.com" always_null 
local-zone: "ad-js.*" always_null 
local-zone: "ad-js.bild.de" always_null 
local-zone: "ad-js.chip.de" always_null 
local-zone: "ad-js.focus.de" always_null 
local-zone: "ad-js.welt.de" always_null 
local-zone: "adjug.com" always_null 
local-zone: "adjuggler.com" always_null 
local-zone: "adjuggler.yourdictionary.com" always_null 
local-zone: "adjustnetwork.com" always_null 
local-zone: "adk2.co" always_null 
local-zone: "adk2.com" always_null 
local-zone: "adland.ru" always_null 
local-zone: "adledge.com" always_null 
local-zone: "adlegend.com" always_null 
local-zone: "adlightning.com" always_null 
local-zone: "adlog.com.com" always_null 
local-zone: "adloox.com" always_null 
local-zone: "adlooxtracking.com" always_null 
local-zone: "adlure.net" always_null 
local-zone: "adm.fwmrm.net" always_null 
local-zone: "admagnet.net" always_null 
local-zone: "admailtiser.com" always_null 
local-zone: "adman.gr" always_null 
local-zone: "adman.otenet.gr" always_null 
local-zone: "admanagement.ch" always_null 
local-zone: "admanager.btopenworld.com" always_null 
local-zone: "admanager.carsoup.com" always_null 
local-zone: "admanmedia.com" always_null 
local-zone: "admantx.com" always_null 
local-zone: "admarketplace.net" always_null 
local-zone: "admarvel.com" always_null 
local-zone: "admaster.com.cn" always_null 
local-zone: "admatchly.com" always_null 
local-zone: "admax.nexage.com" always_null 
local-zone: "admedia.com" always_null 
local-zone: "admeld.com" always_null 
local-zone: "admeridianads.com" always_null 
local-zone: "admeta.com" always_null 
local-zone: "admex.com" always_null 
local-zone: "admidadsp.com" always_null 
local-zone: "adminder.com" always_null 
local-zone: "adminshop.com" always_null 
local-zone: "admix.in" always_null 
local-zone: "admixer.net" always_null 
local-zone: "admized.com" always_null 
local-zone: "admob.com" always_null 
local-zone: "admonitor.com" always_null 
local-zone: "admotion.com.ar" always_null 
local-zone: "adn.lrb.co.uk" always_null 
local-zone: "adnet.asahi.com" always_null 
local-zone: "adnet.biz" always_null 
local-zone: "adnet.de" always_null 
local-zone: "adnet.ru" always_null 
local-zone: "adnetinteractive.com" always_null 
local-zone: "adnetwork.net" always_null 
local-zone: "adnetworkperformance.com" always_null 
local-zone: "adnews.maddog2000.de" always_null 
local-zone: "adnium.com" always_null 
local-zone: "adnxs.com" always_null 
local-zone: "adocean.pl" always_null 
local-zone: "adonspot.com" always_null 
local-zone: "adoric-om.com" always_null 
local-zone: "adorigin.com" always_null 
local-zone: "adotmob.com" always_null 
local-zone: "ad-pay.de" always_null 
local-zone: "adpenguin.biz" always_null 
local-zone: "adpepper.dk" always_null 
local-zone: "adpepper.nl" always_null 
local-zone: "adperium.com" always_null 
local-zone: "adpia.vn" always_null 
local-zone: "adplus.co.id" always_null 
local-zone: "adplxmd.com" always_null 
local-zone: "adprofits.ru" always_null 
local-zone: "adrazzi.com" always_null 
local-zone: "adreactor.com" always_null 
local-zone: "adreclaim.com" always_null 
local-zone: "adrecover.com" always_null 
local-zone: "adrecreate.com" always_null 
local-zone: "adremedy.com" always_null 
local-zone: "adreporting.com" always_null 
local-zone: "adrevolver.com" always_null 
local-zone: "adriver.ru" always_null 
local-zone: "adrolays.de" always_null 
local-zone: "adrotate.de" always_null 
local-zone: "ad-rotator.com" always_null 
local-zone: "adrotic.girlonthenet.com" always_null 
local-zone: "adrta.com" always_null 
local-zone: "ads.365.mk" always_null 
local-zone: "ads.4tube.com" always_null 
local-zone: "ads.5ci.lt" always_null 
local-zone: "ads.5min.at" always_null 
local-zone: "ads.73dpi.com" always_null 
local-zone: "ads.aavv.com" always_null 
local-zone: "ads.abovetopsecret.com" always_null 
local-zone: "ads.aceweb.net" always_null 
local-zone: "ads.acpc.cat" always_null 
local-zone: "ads.acrosspf.com" always_null 
local-zone: "ads.activestate.com" always_null 
local-zone: "ads.ad-center.com" always_null 
local-zone: "ads.adfox.ru" always_null 
local-zone: "ads.administrator.de" always_null 
local-zone: "ads.adred.de" always_null 
local-zone: "ads.adstream.com.ro" always_null 
local-zone: "ads.adultfriendfinder.com" always_null 
local-zone: "ads.advance.net" always_null 
local-zone: "ads.adverline.com" always_null 
local-zone: "ads.affiliates.match.com" always_null 
local-zone: "ads.alive.com" always_null 
local-zone: "ads.alt.com" always_null 
local-zone: "ads.amdmb.com" always_null 
local-zone: "ads.amigos.com" always_null 
local-zone: "ads.annabac.com" always_null 
local-zone: "ads.aol.co.uk" always_null 
local-zone: "ads.apn.co.nz" always_null 
local-zone: "ads.appsgeyser.com" always_null 
local-zone: "ads.apteka254.ru" always_null 
local-zone: "ads.as4x.tmcs.net" always_null 
local-zone: "ads.as4x.tmcs.ticketmaster.com" always_null 
local-zone: "ads.asiafriendfinder.com" always_null 
local-zone: "ads.aspalliance.com" always_null 
local-zone: "ads.avazu.net" always_null 
local-zone: "ads.bb59.ru" always_null 
local-zone: "ads.belointeractive.com" always_null 
local-zone: "ads.betfair.com" always_null 
local-zone: "ads.bigchurch.com" always_null 
local-zone: "ads.bigfoot.com" always_null 
local-zone: "ads.bing.com" always_null 
local-zone: "ads.bittorrent.com" always_null 
local-zone: "ads.biz.tr" always_null 
local-zone: "ads.blog.com" always_null 
local-zone: "ads.bloomberg.com" always_null 
local-zone: "ads.bluemountain.com" always_null 
local-zone: "ads.boerding.com" always_null 
local-zone: "ads.bonniercorp.com" always_null 
local-zone: "ads.boylesports.com" always_null 
local-zone: "ads.brabys.com" always_null 
local-zone: "ads.brazzers.com" always_null 
local-zone: "ads.bumq.com" always_null 
local-zone: "ads.businessweek.com" always_null 
local-zone: "ads.canalblog.com" always_null 
local-zone: "ads.casinocity.com" always_null 
local-zone: "ads.casumoaffiliates.com" always_null 
local-zone: "ads.cbc.ca" always_null 
local-zone: "ads.cc" always_null 
local-zone: "ads.cc-dt.com" always_null 
local-zone: "ads.centraliprom.com" always_null 
local-zone: "ads.channel4.com" always_null 
local-zone: "ads.cheabit.com" always_null 
local-zone: "ads.citymagazine.si" always_null 
local-zone: "ads.clasificadox.com" always_null 
local-zone: "ads.clearchannel.com" always_null 
local-zone: "ads.co.com" always_null 
local-zone: "ads.colombiaonline.com" always_null 
local-zone: "ads.com.com" always_null 
local-zone: "ads.comeon.com" always_null 
local-zone: "ads.contactmusic.com" always_null 
local-zone: "ads.contentabc.com" always_null 
local-zone: "ads.contextweb.com" always_null 
local-zone: "ads.crakmedia.com" always_null 
local-zone: "ads.creative-serving.com" always_null 
local-zone: "ads.cybersales.cz" always_null 
local-zone: "ads.dada.it" always_null 
local-zone: "ads.dailycamera.com" always_null 
local-zone: "ads.datingyes.com" always_null 
local-zone: "ads.delfin.bg" always_null 
local-zone: "ads.deltha.hu" always_null 
local-zone: "ads.dennisnet.co.uk" always_null 
local-zone: "ads.desmoinesregister.com" always_null 
local-zone: "ads.detelefoongids.nl" always_null 
local-zone: "ads.deviantart.com" always_null 
local-zone: "ads.devmates.com" always_null 
local-zone: "ads.digital-digest.com" always_null 
local-zone: "ads.digitalmedianet.com" always_null 
local-zone: "ads.digitalpoint.com" always_null 
local-zone: "ads.directionsmag.com" always_null 
local-zone: "ads.domain.com" always_null 
local-zone: "ads.domeus.com" always_null 
local-zone: "ads.dtpnetwork.biz" always_null 
local-zone: "ads.eagletribune.com" always_null 
local-zone: "ads.easy-forex.com" always_null 
local-zone: "ads.economist.com" always_null 
local-zone: "ads.edbindex.dk" always_null 
local-zone: "ads.egrana.com.br" always_null 
local-zone: "ads.elcarado.com" always_null 
local-zone: "ads.electrocelt.com" always_null 
local-zone: "ads.elitetrader.com" always_null 
local-zone: "ads.emdee.ca" always_null 
local-zone: "ads.emirates.net.ae" always_null 
local-zone: "ads.epi.sk" always_null 
local-zone: "ads.epltalk.com" always_null 
local-zone: "ads.eu.msn.com" always_null 
local-zone: "ads.exactdrive.com" always_null 
local-zone: "ads.expat-blog.biz" always_null 
local-zone: "ads.fairfax.com.au" always_null 
local-zone: "ads.fastcomgroup.it" always_null 
local-zone: "ads.fasttrack-ignite.com" always_null 
local-zone: "ads.faxo.com" always_null 
local-zone: "ads.femmefab.nl" always_null 
local-zone: "ads.ferianc.com" always_null 
local-zone: "ads.filmup.com" always_null 
local-zone: "ads.financialcontent.com" always_null 
local-zone: "ads.flooble.com" always_null 
local-zone: "ads.fool.com" always_null 
local-zone: "ads.footymad.net" always_null 
local-zone: "ads.forbes.net" always_null 
local-zone: "ads.formit.cz" always_null 
local-zone: "ads.fortunecity.com" always_null 
local-zone: "ads.fotosidan.se" always_null 
local-zone: "ads.foxnetworks.com" always_null 
local-zone: "ads.freecity.de" always_null 
local-zone: "ads.friendfinder.com" always_null 
local-zone: "ads.gamecity.net" always_null 
local-zone: "ads.gamershell.com" always_null 
local-zone: "ads.gamespyid.com" always_null 
local-zone: "ads.gamigo.de" always_null 
local-zone: "ads.gaming1.com" always_null 
local-zone: "ads.gaming-universe.de" always_null 
local-zone: "ads.gawker.com" always_null 
local-zone: "ads.gaypoint.hu" always_null 
local-zone: "ads.geekswithblogs.net" always_null 
local-zone: "ads.getlucky.com" always_null 
local-zone: "ads.gld.dk" always_null 
local-zone: "ads.glispa.com" always_null 
local-zone: "ads.gmodules.com" always_null 
local-zone: "ads.goyk.com" always_null 
local-zone: "ads.gplusmedia.com" always_null 
local-zone: "ads.gradfinder.com" always_null 
local-zone: "ads.grindinggears.com" always_null 
local-zone: "ads.groupewin.fr" always_null 
local-zone: "ads.gsmexchange.com" always_null 
local-zone: "ads.gsm-exchange.com" always_null 
local-zone: "ads.guardian.co.uk" always_null 
local-zone: "ads.guardianunlimited.co.uk" always_null 
local-zone: "ads.guru3d.com" always_null 
local-zone: "ads.harpers.org" always_null 
local-zone: "ads.hbv.de" always_null 
local-zone: "ads.hearstmags.com" always_null 
local-zone: "ads.heartlight.org" always_null 
local-zone: "ads.heias.com" always_null 
local-zone: "ads.hollywood.com" always_null 
local-zone: "ads.horsehero.com" always_null 
local-zone: "ads.horyzon-media.com" always_null 
local-zone: "ads.ibest.com.br" always_null 
local-zone: "ads.ibryte.com" always_null 
local-zone: "ads.icq.com" always_null 
local-zone: "ads.ign.com" always_null 
local-zone: "ads.imagistica.com" always_null 
local-zone: "ads.img.co.za" always_null 
local-zone: "ads.imgur.com" always_null 
local-zone: "ads.independent.com.mt" always_null 
local-zone: "ads.infi.net" always_null 
local-zone: "ads.internic.co.il" always_null 
local-zone: "ads.ipowerweb.com" always_null 
local-zone: "ads.isoftmarketing.com" always_null 
local-zone: "ads.itv.com" always_null 
local-zone: "ads.iwon.com" always_null 
local-zone: "ads.jewishfriendfinder.com" always_null 
local-zone: "ads.jiwire.com" always_null 
local-zone: "ads.joaffs.com" always_null 
local-zone: "ads.jobsite.co.uk" always_null 
local-zone: "ads.jpost.com" always_null 
local-zone: "ads.junctionbox.com" always_null 
local-zone: "ads.justhungry.com" always_null 
local-zone: "ads.kabooaffiliates.com" always_null 
local-zone: "ads.kaktuz.net" always_null 
local-zone: "ads.kelbymediagroup.com" always_null 
local-zone: "ads.kinobox.cz" always_null 
local-zone: "ads.kinxxx.com" always_null 
local-zone: "ads.kompass.com" always_null 
local-zone: "ads.krawall.de" always_null 
local-zone: "ads.lapalingo.com" always_null 
local-zone: "ads.larryaffiliates.com" always_null 
local-zone: "ads.leovegas.com" always_null 
local-zone: "ads.lesbianpersonals.com" always_null 
local-zone: "ads.liberte.pl" always_null 
local-zone: "ads.lifethink.net" always_null 
local-zone: "ads.linkedin.com" always_null 
local-zone: "ads.livenation.com" always_null 
local-zone: "ads.lordlucky.com" always_null 
local-zone: "ads.ma7.tv" always_null 
local-zone: "ads.mail.bg" always_null 
local-zone: "ads.mariuana.it" always_null 
local-zone: "ads.massinfra.nl" always_null 
local-zone: "ads.mcafee.com" always_null 
local-zone: "ads.mediaodyssey.com" always_null 
local-zone: "ads.mediasmart.es" always_null 
local-zone: "ads.medienhaus.de" always_null 
local-zone: "ads.meetcelebs.com" always_null 
local-zone: "ads.metaplug.com" always_null 
local-zone: "ads.mgnetwork.com" always_null 
local-zone: "ads.miarroba.com" always_null 
local-zone: "ads.mic.com" always_null 
local-zone: "ads.mmania.com" always_null 
local-zone: "ads.mobilebet.com" always_null 
local-zone: "ads.mopub.com" always_null 
local-zone: "ads.motor-forum.nl" always_null 
local-zone: "ads.msn.com" always_null 
local-zone: "ads.multimania.lycos.fr" always_null 
local-zone: "ads.muslimehelfen.org" always_null 
local-zone: "ads.mvscoelho.com" always_null 
local-zone: "ads.myadv.org" always_null 
local-zone: "ads.nccwebs.com" always_null 
local-zone: "ads.ncm.com" always_null 
local-zone: "ads.ndtv1.com" always_null 
local-zone: "ads.networksolutions.com" always_null 
local-zone: "ads.newgrounds.com" always_null 
local-zone: "ads.newmedia.cz" always_null 
local-zone: "ads.newsint.co.uk" always_null 
local-zone: "ads.newsquest.co.uk" always_null 
local-zone: "ads.ninemsn.com.au" always_null 
local-zone: "ads.nj.com" always_null 
local-zone: "ads.nola.com" always_null 
local-zone: "ads.nordichardware.com" always_null 
local-zone: "ads.nordichardware.se" always_null 
local-zone: "ads.nyi.net" always_null 
local-zone: "ads.nytimes.com" always_null 
local-zone: "ads.nyx.cz" always_null 
local-zone: "ads.nzcity.co.nz" always_null 
local-zone: "ads.o2.pl" always_null 
local-zone: "ads.oddschecker.com" always_null 
local-zone: "ads.okcimg.com" always_null 
local-zone: "ads.ole.com" always_null 
local-zone: "ads.oneplace.com" always_null 
local-zone: "ads.opensubtitles.org" always_null 
local-zone: "ads.optusnet.com.au" always_null 
local-zone: "ads.outpersonals.com" always_null 
local-zone: "ads.oxyshop.cz" always_null 
local-zone: "ads.passion.com" always_null 
local-zone: "ads.pennet.com" always_null 
local-zone: "ads.pfl.ua" always_null 
local-zone: "ads.phpclasses.org" always_null 
local-zone: "ads.pinterest.com" always_null 
local-zone: "ads.planet.nl" always_null 
local-zone: "ads.pni.com" always_null 
local-zone: "ads.pof.com" always_null 
local-zone: "ads.powweb.com" always_null 
local-zone: "ads.ppvmedien.de" always_null 
local-zone: "ads.praguetv.cz" always_null 
local-zone: "ads.primissima.it" always_null 
local-zone: "ads.printscr.com" always_null 
local-zone: "ads.prisacom.com" always_null 
local-zone: "ads.privatemedia.co" always_null 
local-zone: "ads.program3.com" always_null 
local-zone: "ads.programattik.com" always_null 
local-zone: "ads.psd2html.com" always_null 
local-zone: "ads.pushplay.com" always_null 
local-zone: "ads.quoka.de" always_null 
local-zone: "ads.radialserver.com" always_null 
local-zone: "ads.radio1.lv" always_null 
local-zone: "ads.rcncdn.de" always_null 
local-zone: "ads.rcs.it" always_null 
local-zone: "ads.recoletos.es" always_null 
local-zone: "ads.rediff.com" always_null 
local-zone: "ads.redlightcenter.com" always_null 
local-zone: "ads.revjet.com" always_null 
local-zone: "ads.satyamonline.com" always_null 
local-zone: "ads.saymedia.com" always_null 
local-zone: "ads.schmoozecom.net" always_null 
local-zone: "ads.scifi.com" always_null 
local-zone: "ads.seniorfriendfinder.com" always_null 
local-zone: "ads.servebom.com" always_null 
local-zone: "ads.sexgratuit.tv" always_null 
local-zone: "ads.sexinyourcity.com" always_null 
local-zone: "ads.shizmoo.com" always_null 
local-zone: "ads.shopstyle.com" always_null 
local-zone: "ads.sift.co.uk" always_null 
local-zone: "ads.silverdisc.co.uk" always_null 
local-zone: "ads.simplyhired.com" always_null 
local-zone: "ads.sjon.info" always_null 
local-zone: "ads.smartclick.com" always_null 
local-zone: "ads.socapro.com" always_null 
local-zone: "ads.socialtheater.com" always_null 
local-zone: "ads.soft32.com" always_null 
local-zone: "ads.soweb.gr" always_null 
local-zone: "ads.space.com" always_null 
local-zone: "ads.stackoverflow.com" always_null 
local-zone: "ads.sun.com" always_null 
local-zone: "ads.suomiautomaatti.com" always_null 
local-zone: "ads.supplyframe.com" always_null 
local-zone: "ads.syscdn.de" always_null 
local-zone: "ads.tahono.com" always_null 
local-zone: "ads.themovienation.com" always_null 
local-zone: "ads.thestar.com" always_null 
local-zone: "ads.thrillsaffiliates.com" always_null 
local-zone: "ads.tiktok.com" always_null 
local-zone: "ads.tmcs.net" always_null 
local-zone: "ads.todoti.com.br" always_null 
local-zone: "ads.toplayaffiliates.com" always_null 
local-zone: "ads.totallyfreestuff.com" always_null 
local-zone: "ads.townhall.com" always_null 
local-zone: "ads.travelaudience.com" always_null 
local-zone: "ads.tremorhub.com" always_null 
local-zone: "ads.trinitymirror.co.uk" always_null 
local-zone: "ads.tripod.com" always_null 
local-zone: "ads.tripod.lycos.co.uk" always_null 
local-zone: "ads.tripod.lycos.de" always_null 
local-zone: "ads.tripod.lycos.es" always_null 
local-zone: "ads.tripod.lycos.it" always_null 
local-zone: "ads.tripod.lycos.nl" always_null 
local-zone: "ads.tso.dennisnet.co.uk" always_null 
local-zone: "ads.twitter.com" always_null 
local-zone: "ads.twojatv.info" always_null 
local-zone: "ads.uknetguide.co.uk" always_null 
local-zone: "ads.ultimate-guitar.com" always_null 
local-zone: "ads.uncrate.com" always_null 
local-zone: "ads.undertone.com" always_null 
local-zone: "ads.unison.bg" always_null 
local-zone: "ads.usatoday.com" always_null 
local-zone: "ads.uxs.at" always_null 
local-zone: "ads.verticalresponse.com" always_null 
local-zone: "ads.vgchartz.com" always_null 
local-zone: "ads.videosz.com" always_null 
local-zone: "ads.viksaffiliates.com" always_null 
local-zone: "ads.virtual-nights.com" always_null 
local-zone: "ads.virtuopolitan.com" always_null 
local-zone: "ads.v-lazer.com" always_null 
local-zone: "ads.vnumedia.com" always_null 
local-zone: "ads.walkiberia.com" always_null 
local-zone: "ads.waps.cn" always_null 
local-zone: "ads.wapx.cn" always_null 
local-zone: "ads.watson.ch" always_null 
local-zone: "ads.weather.ca" always_null 
local-zone: "ads.web.de" always_null 
local-zone: "ads.webinak.sk" always_null 
local-zone: "ads.webmasterpoint.org" always_null 
local-zone: "ads.websiteservices.com" always_null 
local-zone: "ads.whoishostingthis.com" always_null 
local-zone: "ads.wiezoekje.nl" always_null 
local-zone: "ads.wikia.nocookie.net" always_null 
local-zone: "ads.wineenthusiast.com" always_null 
local-zone: "ads.wwe.biz" always_null 
local-zone: "ads.xhamster.com" always_null 
local-zone: "ads.xtra.co.nz" always_null 
local-zone: "ads.yahoo.com" always_null 
local-zone: "ads.yap.yahoo.com" always_null 
local-zone: "ads.yimg.com" always_null 
local-zone: "ads.yldmgrimg.net" always_null 
local-zone: "ads.yourfreedvds.com" always_null 
local-zone: "ads.youtube.com" always_null 
local-zone: "ads.yumenetworks.com" always_null 
local-zone: "ads.zmarsa.com" always_null 
local-zone: "ads.ztod.com" always_null 
local-zone: "ads1.mediacapital.pt" always_null 
local-zone: "ads1.msn.com" always_null 
local-zone: "ads1.rne.com" always_null 
local-zone: "ads1.virtual-nights.com" always_null 
local-zone: "ads10.speedbit.com" always_null 
local-zone: "ads180.com" always_null 
local-zone: "ads1-adnow.com" always_null 
local-zone: "ads2.brazzers.com" always_null 
local-zone: "ads2.clearchannel.com" always_null 
local-zone: "ads2.contentabc.com" always_null 
local-zone: "ads2.femmefab.nl" always_null 
local-zone: "ads2.gamecity.net" always_null 
local-zone: "ads2.net-communities.co.uk" always_null 
local-zone: "ads2.oneplace.com" always_null 
local-zone: "ads2.opensubtitles.org" always_null 
local-zone: "ads2.rne.com" always_null 
local-zone: "ads2.techads.info" always_null 
local-zone: "ads2.virtual-nights.com" always_null 
local-zone: "ads2.webdrive.no" always_null 
local-zone: "ads2.xnet.cz" always_null 
local-zone: "ads2004.treiberupdate.de" always_null 
local-zone: "ads24h.net" always_null 
local-zone: "ads3.contentabc.com" always_null 
local-zone: "ads3.gamecity.net" always_null 
local-zone: "ads3.virtual-nights.com" always_null 
local-zone: "ads3-adnow.com" always_null 
local-zone: "ads4.clearchannel.com" always_null 
local-zone: "ads4.gamecity.net" always_null 
local-zone: "ads4.virtual-nights.com" always_null 
local-zone: "ads4homes.com" always_null 
local-zone: "ads5.virtual-nights.com" always_null 
local-zone: "ads6.gamecity.net" always_null 
local-zone: "ads7.gamecity.net" always_null 
local-zone: "adsafeprotected.com" always_null 
local-zone: "adsatt.abc.starwave.com" always_null 
local-zone: "adsatt.abcnews.starwave.com" always_null 
local-zone: "adsatt.espn.go.com" always_null 
local-zone: "adsatt.espn.starwave.com" always_null 
local-zone: "adsatt.go.starwave.com" always_null 
local-zone: "adsby.bidtheatre.com" always_null 
local-zone: "adsbydelema.com" always_null 
local-zone: "adscale.de" always_null 
local-zone: "adscholar.com" always_null 
local-zone: "adscience.nl" always_null 
local-zone: "ads-click.com" always_null 
local-zone: "adsco.re" always_null 
local-zone: "ad-score.com" always_null 
local-zone: "adscpm.com" always_null 
local-zone: "adsdaq.com" always_null 
local-zone: "ads-dev.pinterest.com" always_null 
local-zone: "adsend.de" always_null 
local-zone: "adsense.com" always_null 
local-zone: "adsense.de" always_null 
local-zone: "adsensecustomsearchads.com" always_null 
local-zone: "adserve.ams.rhythmxchange.com" always_null 
local-zone: "adserve.gkeurope.de" always_null 
local-zone: "adserve.io" always_null 
local-zone: "adserve.jbs.org" always_null 
local-zone: "adserver.71i.de" always_null 
local-zone: "adserver.adultfriendfinder.com" always_null 
local-zone: "adserver.adverty.com" always_null 
local-zone: "adserver.anawe.cz" always_null 
local-zone: "adserver.aol.fr" always_null 
local-zone: "adserver.ariase.org" always_null 
local-zone: "adserver.bdoce.cl" always_null 
local-zone: "adserver.betandwin.de" always_null 
local-zone: "adserver.bing.com" always_null 
local-zone: "adserver.bizedge.com" always_null 
local-zone: "adserver.bizhat.com" always_null 
local-zone: "adserver.break-even.it" always_null 
local-zone: "adserver.cams.com" always_null 
local-zone: "adserver.cdnstream.com" always_null 
local-zone: "adserver.com" always_null 
local-zone: "adserver.diariodosertao.com.br" always_null 
local-zone: "adserver.digitoday.com" always_null 
local-zone: "adserver.echdk.pl" always_null 
local-zone: "adserver.ekokatu.com" always_null 
local-zone: "adserver.freecity.de" always_null 
local-zone: "adserver.friendfinder.com" always_null 
local-zone: "ad-server.gulasidorna.se" always_null 
local-zone: "adserver.html.it" always_null 
local-zone: "adserver.hwupgrade.it" always_null 
local-zone: "adserver.ilango.de" always_null 
local-zone: "adserver.info7.mx" always_null 
local-zone: "adserver.irishwebmasterforum.com" always_null 
local-zone: "adserver.janes.com" always_null 
local-zone: "adserver.lecool.com" always_null 
local-zone: "adserver.libero.it" always_null 
local-zone: "adserver.madeby.ws" always_null 
local-zone: "adserver.mobi" always_null 
local-zone: "adserver.msmb.biz" always_null 
local-zone: "adserver.news.com.au" always_null 
local-zone: "adserver.nydailynews.com" always_null 
local-zone: "adserver.o2.pl" always_null 
local-zone: "adserver.oddschecker.com" always_null 
local-zone: "adserver.omroepzeeland.nl" always_null 
local-zone: "adserver.otthonom.hu" always_null 
local-zone: "adserver.pampa.com.br" always_null 
local-zone: "adserver.pl" always_null 
local-zone: "adserver.portugalmail.net" always_null 
local-zone: "adserver.pressboard.ca" always_null 
local-zone: "adserver.sanomawsoy.fi" always_null 
local-zone: "adserver.sciflicks.com" always_null 
local-zone: "adserver.scr.sk" always_null 
local-zone: "adserver.sharewareonline.com" always_null 
local-zone: "adserver.theonering.net" always_null 
local-zone: "adserver.trojaner-info.de" always_null 
local-zone: "adserver.twitpic.com" always_null 
local-zone: "adserver.virginmedia.com" always_null 
local-zone: "adserver.yahoo.com" always_null 
local-zone: "adserver01.de" always_null 
local-zone: "adserver1.backbeatmedia.com" always_null 
local-zone: "adserver1.mindshare.de" always_null 
local-zone: "adserver1-images.backbeatmedia.com" always_null 
local-zone: "adserver2.mindshare.de" always_null 
local-zone: "adserverplus.com" always_null 
local-zone: "adserverpub.com" always_null 
local-zone: "adserversolutions.com" always_null 
local-zone: "adserverxxl.de" always_null 
local-zone: "adservice.google.com" always_null 
local-zone: "adservice.google.com.mt" always_null 
local-zone: "adservices.google.com" always_null 
local-zone: "adserving.unibet.com" always_null 
local-zone: "adservingfront.com" always_null 
local-zone: "adsfac.eu" always_null 
local-zone: "adsfac.net" always_null 
local-zone: "adsfac.us" always_null 
local-zone: "adsfactor.net" always_null 
local-zone: "adsfeed.brabys.com" always_null 
local-zone: "ads-game-187f4.firebaseapp.com" always_null 
local-zone: "adshrink.it" always_null 
local-zone: "adside.com" always_null 
local-zone: "adsiduous.com" always_null 
local-zone: "adskeeper.co.uk" always_null 
local-zone: "ads-kesselhaus.com" always_null 
local-zone: "adsklick.de" always_null 
local-zone: "adskpak.com" always_null 
local-zone: "adsmart.com" always_null 
local-zone: "adsmart.net" always_null 
local-zone: "adsmogo.com" always_null 
local-zone: "adsnative.com" always_null 
local-zone: "adsoftware.com" always_null 
local-zone: "adsoldier.com" always_null 
local-zone: "adsolut.in" always_null 
local-zone: "ad-space.net" always_null 
local-zone: "adspeed.net" always_null 
local-zone: "adspirit.de" always_null 
local-zone: "adsponse.de" always_null 
local-zone: "adspsp.com" always_null 
local-zone: "adsroller.com" always_null 
local-zone: "adsrv.deviantart.com" always_null 
local-zone: "adsrv.eacdn.com" always_null 
local-zone: "adsrv.iol.co.za" always_null 
local-zone: "adsrv.moebelmarkt.tv" always_null 
local-zone: "adsrv.swidnica24.pl" always_null 
local-zone: "adsrv2.swidnica24.pl" always_null 
local-zone: "adsrvr.org" always_null 
local-zone: "adsrvus.com" always_null 
local-zone: "adstacks.in" always_null 
local-zone: "adstage.io" always_null 
local-zone: "adstanding.com" always_null 
local-zone: "adstat.4u.pl" always_null 
local-zone: "adstest.weather.com" always_null 
local-zone: "ads-trk.vidible.tv" always_null 
local-zone: "ads-twitter.com" always_null 
local-zone: "adsupply.com" always_null 
local-zone: "adswizz.com" always_null 
local-zone: "adsxyz.com" always_null 
local-zone: "adsymptotic.com" always_null 
local-zone: "adsynergy.com" always_null 
local-zone: "adsys.townnews.com" always_null 
local-zone: "adsystem.simplemachines.org" always_null 
local-zone: "adtech.com" always_null 
local-zone: "ad-tech.com" always_null 
local-zone: "adtech.de" always_null 
local-zone: "adtech-digital.ru" always_null 
local-zone: "adtechjp.com" always_null 
local-zone: "adtechus.com" always_null 
local-zone: "adtegrity.net" always_null 
local-zone: "adthis.com" always_null 
local-zone: "adthrive.com" always_null 
local-zone: "adthurst.com" always_null 
local-zone: "adtiger.de" always_null 
local-zone: "adtilt.com" always_null 
local-zone: "adtng.com" always_null 
local-zone: "adtology.com" always_null 
local-zone: "adtoma.com" always_null 
local-zone: "adtrace.org" always_null 
local-zone: "adtrade.net" always_null 
local-zone: "adtrak.net" always_null 
local-zone: "adtriplex.com" always_null 
local-zone: "adult" always_null 
local-zone: "adultadvertising.com" always_null 
local-zone: "ad-up.com" always_null 
local-zone: "adv.cooperhosting.net" always_null 
local-zone: "adv.donejty.pl" always_null 
local-zone: "adv.freeonline.it" always_null 
local-zone: "adv.hwupgrade.it" always_null 
local-zone: "adv.livedoor.com" always_null 
local-zone: "adv.mezon.ru" always_null 
local-zone: "adv.mpvc.it" always_null 
local-zone: "adv.nexthardware.com" always_null 
local-zone: "adv.webmd.com" always_null 
local-zone: "adv.wp.pl" always_null 
local-zone: "adv.yo.cz" always_null 
local-zone: "adv-adserver.com" always_null 
local-zone: "advangelists.com" always_null 
local-zone: "advariant.com" always_null 
local-zone: "adv-banner.libero.it" always_null 
local-zone: "adventory.com" always_null 
local-zone: "advert.bayarea.com" always_null 
local-zone: "advert.dyna.ultraweb.hu" always_null 
local-zone: "adverticum.com" always_null 
local-zone: "adverticum.net" always_null 
local-zone: "adverticus.de" always_null 
local-zone: "advertise.com" always_null 
local-zone: "advertiseireland.com" always_null 
local-zone: "advertisementafterthought.com" always_null 
local-zone: "advertiserurl.com" always_null 
local-zone: "advertising.com" always_null 
local-zone: "advertisingbanners.com" always_null 
local-zone: "advertisingbox.com" always_null 
local-zone: "advertmarket.com" always_null 
local-zone: "advertmedia.de" always_null 
local-zone: "advertpro.ya.com" always_null 
local-zone: "advertserve.com" always_null 
local-zone: "advertstream.com" always_null 
local-zone: "advertwizard.com" always_null 
local-zone: "advideo.uimserv.net" always_null 
local-zone: "adview.com" always_null 
local-zone: "advisormedia.cz" always_null 
local-zone: "adviva.net" always_null 
local-zone: "advnt.com" always_null 
local-zone: "advolution.com" always_null 
local-zone: "advolution.de" always_null 
local-zone: "adwebone.com" always_null 
local-zone: "adwhirl.com" always_null 
local-zone: "adwordsecommerce.com.br" always_null 
local-zone: "adworldnetwork.com" always_null 
local-zone: "adworx.at" always_null 
local-zone: "adworx.nl" always_null 
local-zone: "adx.allstar.cz" always_null 
local-zone: "adx.atnext.com" always_null 
local-zone: "adx.bild.de" always_null 
local-zone: "adx.chip.de" always_null 
local-zone: "adx.focus.de" always_null 
local-zone: "adx.gayboy.at" always_null 
local-zone: "adx.relaksit.ru" always_null 
local-zone: "adx.welt.de" always_null 
local-zone: "adxpansion.com" always_null 
local-zone: "adxpose.com" always_null 
local-zone: "adxvalue.com" always_null 
local-zone: "adyea.com" always_null 
local-zone: "adyoulike.com" always_null 
local-zone: "adz.rashflash.com" always_null 
local-zone: "adz2you.com" always_null 
local-zone: "adzbazar.com" always_null 
local-zone: "adzerk.net" always_null 
local-zone: "adzerk.s3.amazonaws.com" always_null 
local-zone: "adzestocp.com" always_null 
local-zone: "adzone.temp.co.za" always_null 
local-zone: "adzones.com" always_null 
local-zone: "aerserv.com" always_null 
local-zone: "af-ad.co.uk" always_null 
local-zone: "affec.tv" always_null 
local-zone: "affili.net" always_null 
local-zone: "affiliate.1800flowers.com" always_null 
local-zone: "affiliate.doubleyourdating.com" always_null 
local-zone: "affiliate.dtiserv.com" always_null 
local-zone: "affiliate.gamestop.com" always_null 
local-zone: "affiliate.mogs.com" always_null 
local-zone: "affiliate.offgamers.com" always_null 
local-zone: "affiliate.rusvpn.com" always_null 
local-zone: "affiliate.travelnow.com" always_null 
local-zone: "affiliate.treated.com" always_null 
local-zone: "affiliatefuture.com" always_null 
local-zone: "affiliates.allposters.com" always_null 
local-zone: "affiliates.babylon.com" always_null 
local-zone: "affiliates.digitalriver.com" always_null 
local-zone: "affiliates.globat.com" always_null 
local-zone: "affiliates.rozetka.com.ua" always_null 
local-zone: "affiliates.streamray.com" always_null 
local-zone: "affiliates.thinkhost.net" always_null 
local-zone: "affiliates.thrixxx.com" always_null 
local-zone: "affiliates.ultrahosting.com" always_null 
local-zone: "affiliatetracking.com" always_null 
local-zone: "affiliatetracking.net" always_null 
local-zone: "affiliatewindow.com" always_null 
local-zone: "affiliation-france.com" always_null 
local-zone: "affinity.com" always_null 
local-zone: "afftracking.justanswer.com" always_null 
local-zone: "agkn.com" always_null 
local-zone: "agof.de" always_null 
local-zone: "agreeablestew.com" always_null 
local-zone: "ahalogy.com" always_null 
local-zone: "aheadday.com" always_null 
local-zone: "ah-ha.com" always_null 
local-zone: "aim4media.com" always_null 
local-zone: "airmaxschuheoutlet.com" always_null 
local-zone: "airpush.com" always_null 
local-zone: "aistat.net" always_null 
local-zone: "ak0gsh40.com" always_null 
local-zone: "akamaized.net" always_null 
local-zone: "akku-laden.at" always_null 
local-zone: "aktrack.pubmatic.com" always_null 
local-zone: "aladel.net" always_null 
local-zone: "alchemist.go2cloud.org" always_null 
local-zone: "alclick.com" always_null 
local-zone: "alenty.com" always_null 
local-zone: "alert.com.mt" always_null 
local-zone: "alexametrics.com" always_null 
local-zone: "alexa-sitestats.s3.amazonaws.com" always_null 
local-zone: "algorix.co" always_null 
local-zone: "alipromo.com" always_null 
local-zone: "all4spy.com" always_null 
local-zone: "allosponsor.com" always_null 
local-zone: "aloofvest.com" always_null 
local-zone: "alphonso.tv" always_null 
local-zone: "als-svc.nytimes.com" always_null 
local-zone: "altrk.net" always_null 
local-zone: "amazingcounters.com" always_null 
local-zone: "amazon.dedp" always_null 
local-zone: "amazon-adsystem.com" always_null 
local-zone: "ambiguousquilt.com" always_null 
local-zone: "ambitiousagreement.com" always_null 
local-zone: "americash.com" always_null 
local-zone: "amplitude.com" always_null 
local-zone: "amung.us" always_null 
local-zone: "analdin.com" always_null 
local-zone: "analytics.adpost.org" always_null 
local-zone: "analytics.bitrix.info" always_null 
local-zone: "analytics.cloudron.io" always_null 
local-zone: "analytics.cohesionapps.com" always_null 
local-zone: "analytics.dnsfilter.com" always_null 
local-zone: "analytics.ext.go-tellm.com" always_null 
local-zone: "analytics.fkz.re" always_null 
local-zone: "analytics.google.com" always_null 
local-zone: "analytics.htmedia.in" always_null 
local-zone: "analytics.icons8.com" always_null 
local-zone: "analytics.inlinemanual.com" always_null 
local-zone: "analytics.jst.ai" always_null 
local-zone: "analytics.justuno.com" always_null 
local-zone: "analytics.live.com" always_null 
local-zone: "analytics.mailmunch.co" always_null 
local-zone: "analytics.myfinance.com" always_null 
local-zone: "analytics.mytvzion.pro" always_null 
local-zone: "analytics.ostr.io" always_null 
local-zone: "analytics.phando.com" always_null 
local-zone: "analytics.picsart.com" always_null 
local-zone: "analytics.poolshool.com" always_null 
local-zone: "analytics.posttv.com" always_null 
local-zone: "analytics.samdd.me" always_null 
local-zone: "analytics.siliconexpert.com" always_null 
local-zone: "analytics.swiggy.com" always_null 
local-zone: "analytics.xelondigital.com" always_null 
local-zone: "analytics.yahoo.com" always_null 
local-zone: "analyticsapi.happypancake.net" always_null 
local-zone: "analytics-production.hapyak.com" always_null 
local-zone: "aniview.com" always_null 
local-zone: "annonser.dagbladet.no" always_null 
local-zone: "annoyedairport.com" always_null 
local-zone: "anrdoezrs.net" always_null 
local-zone: "anstrex.com" always_null 
local-zone: "anuncios.edicaoms.com.br" always_null 
local-zone: "anxiousapples.com" always_null 
local-zone: "anycracks.com" always_null 
local-zone: "aos.prf.hnclick" always_null 
local-zone: "apathetictheory.com" always_null 
local-zone: "api.adrtx.net" always_null 
local-zone: "api.intensifier.de" always_null 
local-zone: "api.kameleoon.com" always_null 
local-zone: "apolloprogram.io" always_null 
local-zone: "app.pendo.io" always_null 
local-zone: "app-analytics.snapchat.com" always_null 
local-zone: "appboycdn.com" always_null 
local-zone: "appliedsemantics.com" always_null 
local-zone: "apps5.oingo.com" always_null 
local-zone: "appsflyer.com" always_null 
local-zone: "aps.hearstnp.com" always_null 
local-zone: "apsalar.com" always_null 
local-zone: "apture.com" always_null 
local-zone: "apu.samsungelectronics.com" always_null 
local-zone: "aquaticowl.com" always_null 
local-zone: "ar1nvz5.com" always_null 
local-zone: "aralego.com" always_null 
local-zone: "arc1.msn.com" always_null 
local-zone: "archswimming.com" always_null 
local-zone: "ard.xxxblackbook.com" always_null 
local-zone: "argyresthia.com" always_null 
local-zone: "aromamirror.com" always_null 
local-zone: "as.webmd.com" always_null 
local-zone: "as2.adserverhd.com" always_null 
local-zone: "aserv.motorsgate.com" always_null 
local-zone: "asewlfjqwlflkew.com" always_null 
local-zone: "assets1.exgfnetwork.com" always_null 
local-zone: "assoc-amazon.com" always_null 
local-zone: "aswpapius.com" always_null 
local-zone: "aswpsdkus.com" always_null 
local-zone: "at-adserver.alltop.com" always_null 
local-zone: "atdmt.com" always_null 
local-zone: "athena-ads.wikia.com" always_null 
local-zone: "ato.mx" always_null 
local-zone: "at-o.net" always_null 
local-zone: "attractiveafternoon.com" always_null 
local-zone: "attribution.report" always_null 
local-zone: "attributiontracker.com" always_null 
local-zone: "atwola.com" always_null 
local-zone: "auctionads.com" always_null 
local-zone: "auctionads.net" always_null 
local-zone: "audience.media" always_null 
local-zone: "audience2media.com" always_null 
local-zone: "audienceinsights.com" always_null 
local-zone: "audit.median.hu" always_null 
local-zone: "audit.webinform.hu" always_null 
local-zone: "augur.io" always_null 
local-zone: "auto-bannertausch.de" always_null 
local-zone: "automaticflock.com" always_null 
local-zone: "avazutracking.net" always_null 
local-zone: "avenuea.com" always_null 
local-zone: "avocet.io" always_null 
local-zone: "avpa.javalobby.org" always_null 
local-zone: "awakebird.com" always_null 
local-zone: "awempire.com" always_null 
local-zone: "awin1.com" always_null 
local-zone: "awzbijw.com" always_null 
local-zone: "axiomaticalley.com" always_null 
local-zone: "axonix.com" always_null 
local-zone: "aztracking.net" always_null 
local-zone: "b-1st.com" always_null 
local-zone: "ba.afl.rakuten.co.jp" always_null 
local-zone: "babs.tv2.dk" always_null 
local-zone: "backbeatmedia.com" always_null 
local-zone: "balloontexture.com" always_null 
local-zone: "banik.redigy.cz" always_null 
local-zone: "banner.ad.nu" always_null 
local-zone: "banner.ambercoastcasino.com" always_null 
local-zone: "banner.buempliz-online.ch" always_null 
local-zone: "banner.casino.net" always_null 
local-zone: "banner.casinodelrio.com" always_null 
local-zone: "banner.cotedazurpalace.com" always_null 
local-zone: "banner.coza.com" always_null 
local-zone: "banner.cz" always_null 
local-zone: "banner.easyspace.com" always_null 
local-zone: "banner.elisa.net" always_null 
local-zone: "banner.eurogrand.com" always_null 
local-zone: "banner.finzoom.ro" always_null 
local-zone: "banner.goldenpalace.com" always_null 
local-zone: "banner.icmedia.eu" always_null 
local-zone: "banner.img.co.za" always_null 
local-zone: "banner.inyourpocket.com" always_null 
local-zone: "banner.kiev.ua" always_null 
local-zone: "banner.linux.se" always_null 
local-zone: "banner.media-system.de" always_null 
local-zone: "banner.mindshare.de" always_null 
local-zone: "banner.nixnet.cz" always_null 
local-zone: "banner.noblepoker.com" always_null 
local-zone: "banner.northsky.com" always_null 
local-zone: "banner.orb.net" always_null 
local-zone: "banner.penguin.cz" always_null 
local-zone: "banner.rbc.ru" always_null 
local-zone: "banner.reinstil.de" always_null 
local-zone: "banner.relcom.ru" always_null 
local-zone: "banner.tanto.de" always_null 
local-zone: "banner.titan-dsl.de" always_null 
local-zone: "banner.t-online.de" always_null 
local-zone: "banner.vadian.net" always_null 
local-zone: "banner.webmersion.com" always_null 
local-zone: "banner10.zetasystem.dk" always_null 
local-zone: "bannerads.de" always_null 
local-zone: "bannerboxes.com" always_null 
local-zone: "bannerconnect.com" always_null 
local-zone: "bannerconnect.net" always_null 
local-zone: "banner-exchange-24.de" always_null 
local-zone: "bannergrabber.internet.gr" always_null 
local-zone: "bannerimage.com" always_null 
local-zone: "bannerlandia.com.ar" always_null 
local-zone: "bannermall.com" always_null 
local-zone: "bannermanager.bnr.bg" always_null 
local-zone: "bannermarkt.nl" always_null 
local-zone: "bannerpower.com" always_null 
local-zone: "banners.adultfriendfinder.com" always_null 
local-zone: "banners.amigos.com" always_null 
local-zone: "banners.asiafriendfinder.com" always_null 
local-zone: "banners.babylon-x.com" always_null 
local-zone: "banners.bol.com.br" always_null 
local-zone: "banners.cams.com" always_null 
local-zone: "banners.clubseventeen.com" always_null 
local-zone: "banners.czi.cz" always_null 
local-zone: "banners.dine.com" always_null 
local-zone: "banners.direction-x.com" always_null 
local-zone: "banners.friendfinder.com" always_null 
local-zone: "banners.getiton.com" always_null 
local-zone: "banners.golfasian.com" always_null 
local-zone: "banners.iq.pl" always_null 
local-zone: "banners.isoftmarketing.com" always_null 
local-zone: "banners.linkbuddies.com" always_null 
local-zone: "banners.passion.com" always_null 
local-zone: "banners.payserve.com" always_null 
local-zone: "banners.resultonline.com" always_null 
local-zone: "banners.sys-con.com" always_null 
local-zone: "banners.thomsonlocal.com" always_null 
local-zone: "banners.videosz.com" always_null 
local-zone: "banners.virtuagirlhd.com" always_null 
local-zone: "bannerserver.com" always_null 
local-zone: "bannersgomlm.com" always_null 
local-zone: "bannershotlink.perfectgonzo.com" always_null 
local-zone: "bannersng.yell.com" always_null 
local-zone: "bannerspace.com" always_null 
local-zone: "bannerswap.com" always_null 
local-zone: "bannertesting.com" always_null 
local-zone: "bannertrack.net" always_null 
local-zone: "bannery.cz" always_null 
local-zone: "bannieres.acces-contenu.com" always_null 
local-zone: "bannieres.wdmedia.net" always_null 
local-zone: "bans.bride.ru" always_null 
local-zone: "barbarousnerve.com" always_null 
local-zone: "barnesandnoble.bfast.com" always_null 
local-zone: "basebanner.com" always_null 
local-zone: "baskettexture.com" always_null 
local-zone: "bat.bing.com" always_null 
local-zone: "batbuilding.com" always_null 
local-zone: "bawdybeast.com" always_null 
local-zone: "baypops.com" always_null 
local-zone: "bbelements.com" always_null 
local-zone: "bbjacke.de" always_null 
local-zone: "bbn.img.com.ua" always_null 
local-zone: "beachfront.com" always_null 
local-zone: "beacon.gu-web.net" always_null 
local-zone: "beamincrease.com" always_null 
local-zone: "bebi.com" always_null 
local-zone: "beemray.com" always_null 
local-zone: "begun.ru" always_null 
local-zone: "behavioralengine.com" always_null 
local-zone: "belstat.com" always_null 
local-zone: "belstat.nl" always_null 
local-zone: "berp.com" always_null 
local-zone: "bestboundary.com" always_null 
local-zone: "bestcheck.de" always_null 
local-zone: "bestsearch.net" always_null 
local-zone: "bewilderedblade.com" always_null 
local-zone: "bfmio.com" always_null 
local-zone: "bg" always_null 
local-zone: "bhcumsc.com" always_null 
local-zone: "biallo.de" always_null 
local-zone: "bidbarrel.cbsnews.com" always_null 
local-zone: "bidclix.com" always_null 
local-zone: "bidclix.net" always_null 
local-zone: "bidr.io" always_null 
local-zone: "bidsopt.com" always_null 
local-zone: "bidswitch.net" always_null 
local-zone: "bidtellect.com" always_null 
local-zone: "bidvertiser.com" always_null 
local-zone: "big-bang-ads.com" always_null 
local-zone: "bigbangmedia.com" always_null 
local-zone: "bigclicks.com" always_null 
local-zone: "bigpoint.com" always_null 
local-zone: "bigreal.org" always_null 
local-zone: "bilano.de" always_null 
local-zone: "bild.ivwbox.de" always_null 
local-zone: "billalo.de" always_null 
local-zone: "billboard.cz" always_null 
local-zone: "billiger.decommonmodulesapi" always_null 
local-zone: "biohazard.xz.cz" always_null 
local-zone: "biosda.com" always_null 
local-zone: "bitmedianetwork.com" always_null 
local-zone: "bizad.nikkeibp.co.jp" always_null 
local-zone: "bizible.com" always_null 
local-zone: "bizographics.com" always_null 
local-zone: "bizrate.com" always_null 
local-zone: "bizzclick.com" always_null 
local-zone: "bkrtx.com" always_null 
local-zone: "blingbucks.com" always_null 
local-zone: "blis.com" always_null 
local-zone: "blockadblock.com" always_null 
local-zone: "blockthrough.com" always_null 
local-zone: "blogads.com" always_null 
local-zone: "blogcounter.de" always_null 
local-zone: "blogherads.com" always_null 
local-zone: "blogtoplist.se" always_null 
local-zone: "blogtopsites.com" always_null 
local-zone: "blueadvertise.com" always_null 
local-zone: "blueconic.com" always_null 
local-zone: "blueconic.net" always_null 
local-zone: "bluekai.com" always_null 
local-zone: "bluelithium.com" always_null 
local-zone: "bluewhaleweb.com" always_null 
local-zone: "blushingbeast.com" always_null 
local-zone: "blushingboundary.com" always_null 
local-zone: "bm.annonce.cz" always_null 
local-zone: "bn.bfast.com" always_null 
local-zone: "bnnrrv.qontentum.de" always_null 
local-zone: "bnrs.ilm.ee" always_null 
local-zone: "boffoadsapi.com" always_null 
local-zone: "boilingbeetle.com" always_null 
local-zone: "boilingumbrella.com" always_null 
local-zone: "bongacash.com" always_null 
local-zone: "boomads.com" always_null 
local-zone: "boomtrain.com" always_null 
local-zone: "boost-my-pr.de" always_null 
local-zone: "boredcrown.com" always_null 
local-zone: "boringcoat.com" always_null 
local-zone: "boudja.com" always_null 
local-zone: "bounceads.net" always_null 
local-zone: "bounceexchange.com" always_null 
local-zone: "bowie-cdn.fathomdns.com" always_null 
local-zone: "box.anchorfree.net" always_null 
local-zone: "bpath.com" always_null 
local-zone: "bpu.samsungelectronics.com" always_null 
local-zone: "bpwhamburgorchardpark.org" always_null 
local-zone: "braincash.com" always_null 
local-zone: "brand-display.com" always_null 
local-zone: "brandreachsys.com" always_null 
local-zone: "breaktime.com.tw" always_null 
local-zone: "brealtime.com" always_null 
local-zone: "bridgetrack.com" always_null 
local-zone: "brightcom.com" always_null 
local-zone: "brightinfo.com" always_null 
local-zone: "brightmountainmedia.com" always_null 
local-zone: "british-banners.com" always_null 
local-zone: "broadboundary.com" always_null 
local-zone: "broadcastbed.com" always_null 
local-zone: "broaddoor.com" always_null 
local-zone: "browser-http-intake.logs.datadoghq.com" always_null 
local-zone: "browser-http-intake.logs.datadoghq.eu" always_null 
local-zone: "bs.yandex.ru" always_null 
local-zone: "btez8.xyz" always_null 
local-zone: "btrll.com" always_null 
local-zone: "bttrack.com" always_null 
local-zone: "bu" always_null 
local-zone: "bucketbean.com" always_null 
local-zone: "bullseye.backbeatmedia.com" always_null 
local-zone: "businessbells.com" always_null 
local-zone: "bustlinganimal.com" always_null 
local-zone: "buysellads.com" always_null 
local-zone: "buzzonclick.com" always_null 
local-zone: "bwp.download.com" always_null 
local-zone: "by" always_null 
local-zone: "c.bigmir.net" always_null 
local-zone: "c1.nowlinux.com" always_null 
local-zone: "c1exchange.com" always_null 
local-zone: "calculatingcircle.com" always_null 
local-zone: "calculatingtoothbrush.com" always_null 
local-zone: "calculatorcamera.com" always_null 
local-zone: "callousbrake.com" always_null 
local-zone: "callrail.com" always_null 
local-zone: "calmcactus.com" always_null 
local-zone: "campaign.bharatmatrimony.com" always_null 
local-zone: "caniamedia.com" always_null 
local-zone: "cannads.urgrafix.com" always_null 
local-zone: "capablecows.com" always_null 
local-zone: "captainbicycle.com" always_null 
local-zone: "carambo.la" always_null 
local-zone: "carbonads.com" always_null 
local-zone: "carbonads.net" always_null 
local-zone: "casalemedia.com" always_null 
local-zone: "casalmedia.com" always_null 
local-zone: "cash4members.com" always_null 
local-zone: "cash4popup.de" always_null 
local-zone: "cashcrate.com" always_null 
local-zone: "cashengines.com" always_null 
local-zone: "cashfiesta.com" always_null 
local-zone: "cashpartner.com" always_null 
local-zone: "cashstaging.me" always_null 
local-zone: "casinopays.com" always_null 
local-zone: "casinorewards.com" always_null 
local-zone: "casinotraffic.com" always_null 
local-zone: "causecherry.com" always_null 
local-zone: "cbanners.virtuagirlhd.com" always_null 
local-zone: "cdn.bannerflow.com" always_null 
local-zone: "cdn.branch.io" always_null 
local-zone: "cdn.flashtalking.com" always_null 
local-zone: "cdn.freefarcy.com" always_null 
local-zone: "cdn.freshmarketer.com" always_null 
local-zone: "cdn.heapanalytics.com" always_null 
local-zone: "cdn.keywee.co" always_null 
local-zone: "cdn.onesignal.com" always_null 
local-zone: "cdn.segment.com" always_null 
local-zone: "cdn1.spiegel.deimages" always_null 
local-zone: "cecash.com" always_null 
local-zone: "cedato.com" always_null 
local-zone: "celtra.com" always_null 
local-zone: "centerpointmedia.com" always_null 
local-zone: "centgebote.tv" always_null 
local-zone: "ceskydomov.alias.ngs.modry.cz" always_null 
local-zone: "cetrk.com" always_null 
local-zone: "cgicounter.puretec.de" always_null 
local-zone: "chairscrack.com" always_null 
local-zone: "chameleon.ad" always_null 
local-zone: "channelintelligence.com" always_null 
local-zone: "chardwardse.club" always_null 
local-zone: "chart.dk" always_null 
local-zone: "chartbeat.com" always_null 
local-zone: "chartbeat.net" always_null 
local-zone: "chartboost.com" always_null 
local-zone: "checkm8.com" always_null 
local-zone: "checkstat.nl" always_null 
local-zone: "cheerfulrange.com" always_null 
local-zone: "chewcoat.com" always_null 
local-zone: "chickensstation.com" always_null 
local-zone: "chinsnakes.com" always_null 
local-zone: "chitika.net" always_null 
local-zone: "cision.com" always_null 
local-zone: "cityads.telus.net" always_null 
local-zone: "cj.com" always_null 
local-zone: "cjbmanagement.com" always_null 
local-zone: "cjlog.com" always_null 
local-zone: "cl0udh0st1ng.com" always_null 
local-zone: "claria.com" always_null 
local-zone: "clevernt.com" always_null 
local-zone: "click" always_null 
local-zone: "click.a-ads.com" always_null 
local-zone: "click.cartsguru.io" always_null 
local-zone: "click.email.bbc.com" always_null 
local-zone: "click.email.sonos.com" always_null 
local-zone: "click.fool.com" always_null 
local-zone: "click.kmindex.ru" always_null 
local-zone: "click.negociosdigitaisnapratica.com.br" always_null 
local-zone: "click.redditmail.com" always_null 
local-zone: "click.twcwigs.com" always_null 
local-zone: "click2freemoney.com" always_null 
local-zone: "clickability.com" always_null 
local-zone: "clickadz.com" always_null 
local-zone: "clickagents.com" always_null 
local-zone: "clickbank.com" always_null 
local-zone: "clickbooth.com" always_null 
local-zone: "clickboothlnk.com" always_null 
local-zone: "clickbrokers.com" always_null 
local-zone: "clickcompare.co.uk" always_null 
local-zone: "clickdensity.com" always_null 
local-zone: "clickedyclick.com" always_null 
local-zone: "clickfuse.com" always_null 
local-zone: "clickhereforcellphones.com" always_null 
local-zone: "clickhouse.com" always_null 
local-zone: "clickhype.com" always_null 
local-zone: "clicklink.jp" always_null 
local-zone: "clickmate.io" always_null 
local-zone: "clickonometrics.pl" always_null 
local-zone: "clicks.equantum.com" always_null 
local-zone: "clicks.mods.de" always_null 
local-zone: "clickserve.cc-dt.com" always_null 
local-zone: "clicktag.de" always_null 
local-zone: "clickthruserver.com" always_null 
local-zone: "clickthrutraffic.com" always_null 
local-zone: "clicktrace.info" always_null 
local-zone: "clicktrack.ziyu.net" always_null 
local-zone: "clicktracks.com" always_null 
local-zone: "clicktrade.com" always_null 
local-zone: "clickwith.bid" always_null 
local-zone: "clickxchange.com" always_null 
local-zone: "clickyab.com" always_null 
local-zone: "clickz.com" always_null 
local-zone: "clientmetrics-pa.googleapis.com" always_null 
local-zone: "clikerz.net" always_null 
local-zone: "cliksolution.com" always_null 
local-zone: "clixgalore.com" always_null 
local-zone: "clk1005.com" always_null 
local-zone: "clk1011.com" always_null 
local-zone: "clk1015.com" always_null 
local-zone: "clkrev.com" always_null 
local-zone: "clksite.com" always_null 
local-zone: "cloisteredhydrant.com" always_null 
local-zone: "cloudcoins.biz" always_null 
local-zone: "clrstm.com" always_null 
local-zone: "cluster.adultworld.com" always_null 
local-zone: "clustrmaps.com" always_null 
local-zone: "cmp.dmgmediaprivacy.co.uk" always_null 
local-zone: "cmvrclicks000.com" always_null 
local-zone: "cnomy.com" always_null 
local-zone: "cnt.spbland.ru" always_null 
local-zone: "cnt1.pocitadlo.cz" always_null 
local-zone: "cny.yoyo.org" always_null 
local-zone: "codeadnetwork.com" always_null 
local-zone: "code-server.biz" always_null 
local-zone: "cognitiv.ai" always_null 
local-zone: "cognitiveadscience.com" always_null 
local-zone: "coinhive.com" always_null 
local-zone: "coin-hive.com" always_null 
local-zone: "cointraffic.io" always_null 
local-zone: "colonize.com" always_null 
local-zone: "comclick.com" always_null 
local-zone: "comfortablecheese.com" always_null 
local-zone: "commindo-media-ressourcen.de" always_null 
local-zone: "commissionmonster.com" always_null 
local-zone: "commonswing.com" always_null 
local-zone: "compactbanner.com" always_null 
local-zone: "completecabbage.com" always_null 
local-zone: "complextoad.com" always_null 
local-zone: "comprabanner.it" always_null 
local-zone: "concernedcondition.com" always_null 
local-zone: "conductrics.com" always_null 
local-zone: "connatix.com" always_null 
local-zone: "connectad.io" always_null 
local-zone: "connextra.com" always_null 
local-zone: "consciouschairs.com" always_null 
local-zone: "consensad.com" always_null 
local-zone: "consensu.org" always_null 
local-zone: "contadores.miarroba.com" always_null 
local-zone: "contaxe.de" always_null 
local-zone: "content.acc-hd.de" always_null 
local-zone: "content.ad" always_null 
local-zone: "content22.online.citi.com" always_null 
local-zone: "contextweb.com" always_null 
local-zone: "converge-digital.com" always_null 
local-zone: "conversantmedia.com" always_null 
local-zone: "conversionbet.com" always_null 
local-zone: "conversionruler.com" always_null 
local-zone: "convertingtraffic.com" always_null 
local-zone: "convrse.media" always_null 
local-zone: "cookies.cmpnet.com" always_null 
local-zone: "coordinatedcub.com" always_null 
local-zone: "cootlogix.com" always_null 
local-zone: "copperchickens.com" always_null 
local-zone: "copycarpenter.com" always_null 
local-zone: "copyrightaccesscontrols.com" always_null 
local-zone: "coqnu.com" always_null 
local-zone: "coremetrics.com" always_null 
local-zone: "cormast.com" always_null 
local-zone: "cosmopolitads.com" always_null 
local-zone: "count.rin.ru" always_null 
local-zone: "count.west263.com" always_null 
local-zone: "counted.com" always_null 
local-zone: "counter.bloke.com" always_null 
local-zone: "counter.cnw.cz" always_null 
local-zone: "counter.cz" always_null 
local-zone: "counter.dreamhost.com" always_null 
local-zone: "counter.mirohost.net" always_null 
local-zone: "counter.mojgorod.ru" always_null 
local-zone: "counter.nowlinux.com" always_null 
local-zone: "counter.rambler.ru" always_null 
local-zone: "counter.search.bg" always_null 
local-zone: "counter.snackly.co" always_null 
local-zone: "counter.sparklit.com" always_null 
local-zone: "counter.yadro.ru" always_null 
local-zone: "counters.honesty.com" always_null 
local-zone: "counting.kmindex.ru" always_null 
local-zone: "coupling-media.de" always_null 
local-zone: "coxmt.com" always_null 
local-zone: "cp.abbp1.pw" always_null 
local-zone: "cpalead.com" always_null 
local-zone: "cpays.com" always_null 
local-zone: "cpmstar.com" always_null 
local-zone: "cpu.samsungelectronics.com" always_null 
local-zone: "cpx.to" always_null 
local-zone: "cpxinteractive.com" always_null 
local-zone: "cqcounter.com" always_null 
local-zone: "crabbychin.com" always_null 
local-zone: "crakmedia.com" always_null 
local-zone: "craktraffic.com" always_null 
local-zone: "crawlability.com" always_null 
local-zone: "crawlclocks.com" always_null 
local-zone: "crazyegg.com" always_null 
local-zone: "crazypopups.com" always_null 
local-zone: "creafi-online-media.com" always_null 
local-zone: "creatives.livejasmin.com" always_null 
local-zone: "criteo.com" always_null 
local-zone: "criteo.net" always_null 
local-zone: "critictruck.com" always_null 
local-zone: "croissed.info" always_null 
local-zone: "crowdgravity.com" always_null 
local-zone: "crsspxl.com" always_null 
local-zone: "crta.dailymail.co.uk" always_null 
local-zone: "crtv.mate1.com" always_null 
local-zone: "crwdcntrl.net" always_null 
local-zone: "crypto-loot.org" always_null 
local-zone: "cs" always_null 
local-zone: "ctnetwork.hu" always_null 
local-zone: "cubics.com" always_null 
local-zone: "cuii.info" always_null 
local-zone: "culturedcrayon.com" always_null 
local-zone: "cumbersomecloud.com" always_null 
local-zone: "cuponation.de" always_null 
local-zone: "curtaincows.com" always_null 
local-zone: "custom.plausible.io" always_null 
local-zone: "customad.cnn.com" always_null 
local-zone: "customers.kameleoon.com" always_null 
local-zone: "cutecushion.com" always_null 
local-zone: "cuteturkey.com" always_null 
local-zone: "cxense.com" always_null 
local-zone: "cyberbounty.com" always_null 
local-zone: "d.adroll.com" always_null 
local-zone: "d2cmedia.ca" always_null 
local-zone: "dabiaozhi.com" always_null 
local-zone: "dacdn.visualwebsiteoptimizer.com" always_null 
local-zone: "dakic-ia-300.com" always_null 
local-zone: "damdoor.com" always_null 
local-zone: "dancemistake.com" always_null 
local-zone: "dapper.net" always_null 
local-zone: "dashbida.com" always_null 
local-zone: "dashingdirt.com" always_null 
local-zone: "dashingsweater.com" always_null 
local-zone: "data.namesakeoscilloscopemarquis.com" always_null 
local-zone: "data8a8altrk.com" always_null 
local-zone: "dbbsrv.com" always_null 
local-zone: "dc-storm.com" always_null 
local-zone: "de.mediaplex.com" always_null 
local-zone: "de17a.com" always_null 
local-zone: "deadpantruck.com" always_null 
local-zone: "dealdotcom.com" always_null 
local-zone: "debonairway.com" always_null 
local-zone: "debtbusterloans.com" always_null 
local-zone: "decenterads.com" always_null 
local-zone: "decisivedrawer.com" always_null 
local-zone: "decisiveducks.com" always_null 
local-zone: "decknetwork.net" always_null 
local-zone: "decoycreation.com" always_null 
local-zone: "deepintent.com" always_null 
local-zone: "defectivesun.com" always_null 
local-zone: "delegatediscussion.com" always_null 
local-zone: "deloo.de" always_null 
local-zone: "deloplen.com" always_null 
local-zone: "deloton.com" always_null 
local-zone: "demandbase.com" always_null 
local-zone: "demdex.net" always_null 
local-zone: "deployads.com" always_null 
local-zone: "desertedbreath.com" always_null 
local-zone: "desertedrat.com" always_null 
local-zone: "detailedglue.com" always_null 
local-zone: "detailedgovernment.com" always_null 
local-zone: "detectdiscovery.com" always_null 
local-zone: "dev.visualwebsiteoptimizer.com" always_null 
local-zone: "dianomi.com" always_null 
local-zone: "didtheyreadit.com" always_null 
local-zone: "digital-ads.s3.amazonaws.com" always_null 
local-zone: "digitalmerkat.com" always_null 
local-zone: "directaclick.com" always_null 
local-zone: "direct-events-collector.spot.im" always_null 
local-zone: "directivepub.com" always_null 
local-zone: "directleads.com" always_null 
local-zone: "directorym.com" always_null 
local-zone: "directtrack.com" always_null 
local-zone: "direct-xxx-access.com" always_null 
local-zone: "discountclick.com" always_null 
local-zone: "discreetfield.com" always_null 
local-zone: "dispensablestranger.com" always_null 
local-zone: "displayadsmedia.com" always_null 
local-zone: "disqusads.com" always_null 
local-zone: "dist.belnk.com" always_null 
local-zone: "distillery.wistia.com" always_null 
local-zone: "districtm.ca" always_null 
local-zone: "districtm.io" always_null 
local-zone: "dk4ywix.com" always_null 
local-zone: "dmp.mall.tv" always_null 
local-zone: "dmtracker.com" always_null 
local-zone: "dmtracking.alibaba.com" always_null 
local-zone: "dmtracking2.alibaba.com" always_null 
local-zone: "dnsdelegation.io" always_null 
local-zone: "dntrax.com" always_null 
local-zone: "docksalmon.com" always_null 
local-zone: "dogcollarfavourbluff.com" always_null 
local-zone: "do-global.com" always_null 
local-zone: "domaining.in" always_null 
local-zone: "domainsponsor.com" always_null 
local-zone: "domainsteam.de" always_null 
local-zone: "domdex.com" always_null 
local-zone: "dotmetrics.net" always_null 
local-zone: "doubleclick.com" always_null 
local-zone: "doubleclick.de" always_null 
local-zone: "doubleclick.net" always_null 
local-zone: "doublepimp.com" always_null 
local-zone: "doubleverify.com" always_null 
local-zone: "doubtfulrainstorm.com" always_null 
local-zone: "downloadr.xyz" always_null 
local-zone: "download-service.de" always_null 
local-zone: "download-sofort.com" always_null 
local-zone: "dpbolvw.net" always_null 
local-zone: "dpu.samsungelectronics.com" always_null 
local-zone: "dq95d35.com" always_null 
local-zone: "drabsize.com" always_null 
local-zone: "dragzebra.com" always_null 
local-zone: "drumcash.com" always_null 
local-zone: "drydrum.com" always_null 
local-zone: "ds.serving-sys.com" always_null 
local-zone: "dsp.colpirio.com" always_null 
local-zone: "dsp.io" always_null 
local-zone: "dstillery.com" always_null 
local-zone: "dyntrk.com" always_null 
local-zone: "e.kde.cz" always_null 
local-zone: "eadexchange.com" always_null 
local-zone: "e-adimages.scrippsnetworks.com" always_null 
local-zone: "earthquakescarf.com" always_null 
local-zone: "earthycopy.com" always_null 
local-zone: "eas.almamedia.fi" always_null 
local-zone: "easycracks.net" always_null 
local-zone: "easyhits4u.com" always_null 
local-zone: "ebayadvertising.com" always_null 
local-zone: "ebuzzing.com" always_null 
local-zone: "ecircle-ag.com" always_null 
local-zone: "ecleneue.com" always_null 
local-zone: "eclick.vn" always_null 
local-zone: "eclkmpbn.com" always_null 
local-zone: "eclkspbn.com" always_null 
local-zone: "economicpizzas.com" always_null 
local-zone: "ecoupons.com" always_null 
local-zone: "edaa.eu" always_null 
local-zone: "efahrer.chip.de" always_null 
local-zone: "efahrer.de" always_null 
local-zone: "efahrer.fokus.de" always_null 
local-zone: "effectivemeasure.com" always_null 
local-zone: "effectivemeasure.net" always_null 
local-zone: "efficaciouscactus.com" always_null 
local-zone: "eiv.baidu.com" always_null 
local-zone: "ejyymghi.com" always_null 
local-zone: "elasticchange.com" always_null 
local-zone: "elderlyscissors.com" always_null 
local-zone: "elderlytown.com" always_null 
local-zone: "elephantqueue.com" always_null 
local-zone: "elitedollars.com" always_null 
local-zone: "elitetoplist.com" always_null 
local-zone: "elthamely.com" always_null 
local-zone: "e-m.fr" always_null 
local-zone: "emarketer.com" always_null 
local-zone: "emebo.com" always_null 
local-zone: "emebo.io" always_null 
local-zone: "emediate.eu" always_null 
local-zone: "emerse.com" always_null 
local-zone: "emetriq.de" always_null 
local-zone: "emjcd.com" always_null 
local-zone: "emltrk.com" always_null 
local-zone: "emodoinc.com" always_null 
local-zone: "emptyescort.com" always_null 
local-zone: "emxdigital.com" always_null 
local-zone: "en25.com" always_null 
local-zone: "encouragingwilderness.com" always_null 
local-zone: "endurableshop.com" always_null 
local-zone: "energeticladybug.com" always_null 
local-zone: "engage.dnsfilter.com" always_null 
local-zone: "engagebdr.com" always_null 
local-zone: "engine.espace.netavenir.com" always_null 
local-zone: "enginenetwork.com" always_null 
local-zone: "enormousearth.com" always_null 
local-zone: "enquisite.com" always_null 
local-zone: "ensighten.com" always_null 
local-zone: "entercasino.com" always_null 
local-zone: "enthusiasticdad.com" always_null 
local-zone: "entrecard.s3.amazonaws.com" always_null 
local-zone: "enviousthread.com" always_null 
local-zone: "e-planning.net" always_null 
local-zone: "epom.com" always_null 
local-zone: "epp.bih.net.ba" always_null 
local-zone: "eqads.com" always_null 
local-zone: "erne.co" always_null 
local-zone: "ero-advertising.com" always_null 
local-zone: "espn.com.ssl.sc.omtrdc.net" always_null 
local-zone: "estat.com" always_null 
local-zone: "esty.com" always_null 
local-zone: "et.nytimes.com" always_null 
local-zone: "etahub.com" always_null 
local-zone: "etargetnet.com" always_null 
local-zone: "etracker.com" always_null 
local-zone: "etracker.de" always_null 
local-zone: "eu1.madsone.com" always_null 
local-zone: "eu-adcenter.net" always_null 
local-zone: "eule1.pmu.fr" always_null 
local-zone: "eulerian.net" always_null 
local-zone: "eurekster.com" always_null 
local-zone: "euros4click.de" always_null 
local-zone: "eusta.de" always_null 
local-zone: "evadav.com" always_null 
local-zone: "evadavdsp.pro" always_null 
local-zone: "everestads.net" always_null 
local-zone: "everesttech.net" always_null 
local-zone: "evergage.com" always_null 
local-zone: "eversales.space" always_null 
local-zone: "evidon.com" always_null 
local-zone: "evyy.net" always_null 
local-zone: "ewebcounter.com" always_null 
local-zone: "exchangead.com" always_null 
local-zone: "exchangeclicksonline.com" always_null 
local-zone: "exchange-it.com" always_null 
local-zone: "exclusivebrass.com" always_null 
local-zone: "exelate.com" always_null 
local-zone: "exelator.com" always_null 
local-zone: "exit76.com" always_null 
local-zone: "exitexchange.com" always_null 
local-zone: "exitfuel.com" always_null 
local-zone: "exoclick.com" always_null 
local-zone: "exosrv.com" always_null 
local-zone: "experianmarketingservices.digital" always_null 
local-zone: "explorads.com" always_null 
local-zone: "exponea.com" always_null 
local-zone: "exponential.com" always_null 
local-zone: "express-submit.de" always_null 
local-zone: "extreme-dm.com" always_null 
local-zone: "extremetracking.com" always_null 
local-zone: "eyeblaster.com" always_null 
local-zone: "eyeota.net" always_null 
local-zone: "eyereturn.com" always_null 
local-zone: "eyeviewads.com" always_null 
local-zone: "eyewonder.com" always_null 
local-zone: "ezula.com" always_null 
local-zone: "f7ds.liberation.fr" always_null 
local-zone: "facilitategrandfather.com" always_null 
local-zone: "fadedprofit.com" always_null 
local-zone: "fadedsnow.com" always_null 
local-zone: "fallaciousfifth.com" always_null 
local-zone: "famousquarter.com" always_null 
local-zone: "fancy.com" always_null 
local-zone: "fancy.de" always_null 
local-zone: "fapdu.com" always_null 
local-zone: "fapmaps.com" always_null 
local-zone: "faracoon.com" always_null 
local-zone: "farethief.com" always_null 
local-zone: "farmergoldfish.com" always_null 
local-zone: "fascinatedfeather.com" always_null 
local-zone: "fastclick.com" always_null 
local-zone: "fastclick.com.edgesuite.net" always_null 
local-zone: "fastclick.net" always_null 
local-zone: "fastgetsoftware.com" always_null 
local-zone: "fastly-insights.com" always_null 
local-zone: "fast-redirecting.com" always_null 
local-zone: "faultycanvas.com" always_null 
local-zone: "faultyfowl.com" always_null 
local-zone: "fc.webmasterpro.de" always_null 
local-zone: "feathr.co" always_null 
local-zone: "feebleshock.com" always_null 
local-zone: "feedbackresearch.com" always_null 
local-zone: "feedjit.com" always_null 
local-zone: "feedmob.com" always_null 
local-zone: "ffxcam.fairfax.com.au" always_null 
local-zone: "fimserve.com" always_null 
local-zone: "findcommerce.com" always_null 
local-zone: "findepended.com" always_null 
local-zone: "findyourcasino.com" always_null 
local-zone: "fineoffer.net" always_null 
local-zone: "fingahvf.top" always_null 
local-zone: "first.nova.cz" always_null 
local-zone: "firstlightera.com" always_null 
local-zone: "fixel.ai" always_null 
local-zone: "flairadscpc.com" always_null 
local-zone: "flakyfeast.com" always_null 
local-zone: "flashtalking.com" always_null 
local-zone: "fleshlightcash.com" always_null 
local-zone: "flexbanner.com" always_null 
local-zone: "flimsycircle.com" always_null 
local-zone: "floodprincipal.com" always_null 
local-zone: "flowgo.com" always_null 
local-zone: "flurry.com" always_null 
local-zone: "fly-analytics.com" always_null 
local-zone: "focus.deajax" always_null 
local-zone: "foo.cosmocode.de" always_null 
local-zone: "foresee.com" always_null 
local-zone: "forex-affiliate.net" always_null 
local-zone: "forkcdn.com" always_null 
local-zone: "fourarithmetic.com" always_null 
local-zone: "fpctraffic.com" always_null 
local-zone: "fpctraffic2.com" always_null 
local-zone: "fpjs.io" always_null 
local-zone: "fqtag.com" always_null 
local-zone: "frailoffer.com" always_null 
local-zone: "franzis-sportswear.de" always_null 
local-zone: "freebanner.com" always_null 
local-zone: "free-banners.com" always_null 
local-zone: "free-counter.co.uk" always_null 
local-zone: "free-counters.co.uk" always_null 
local-zone: "freecounterstat.com" always_null 
local-zone: "freelogs.com" always_null 
local-zone: "freeonlineusers.com" always_null 
local-zone: "freepay.com" always_null 
local-zone: "freeskreen.com" always_null 
local-zone: "freestats.com" always_null 
local-zone: "freestats.tv" always_null 
local-zone: "freewebcounter.com" always_null 
local-zone: "freewheel.com" always_null 
local-zone: "freewheel.tv" always_null 
local-zone: "frightenedpotato.com" always_null 
local-zone: "frtyj.com" always_null 
local-zone: "frtyk.com" always_null 
local-zone: "fukc69xo.us" always_null 
local-zone: "fullstory.com" always_null 
local-zone: "functionalcrown.com" always_null 
local-zone: "funklicks.com" always_null 
local-zone: "fusionads.net" always_null 
local-zone: "fusionquest.com" always_null 
local-zone: "futuristicapparatus.com" always_null 
local-zone: "futuristicfairies.com" always_null 
local-zone: "fuzzybasketball.com" always_null 
local-zone: "fuzzyflavor.com" always_null 
local-zone: "fuzzyweather.com" always_null 
local-zone: "fxstyle.net" always_null 
local-zone: "g.msn.comAIPRIV" always_null 
local-zone: "g4u.me" always_null 
local-zone: "ga.clearbit.com" always_null 
local-zone: "ga87z2o.com" always_null 
local-zone: "gadsbee.com" always_null 
local-zone: "galaxien.com" always_null 
local-zone: "game-advertising-online.com" always_null 
local-zone: "gamehouse.com" always_null 
local-zone: "gamesites100.net" always_null 
local-zone: "gamesites200.com" always_null 
local-zone: "gammamaximum.com" always_null 
local-zone: "gearwom.de" always_null 
local-zone: "gekko.spiceworks.com" always_null 
local-zone: "gemini.yahoo.com" always_null 
local-zone: "geo.digitalpoint.com" always_null 
local-zone: "geobanner.adultfriendfinder.com" always_null 
local-zone: "georiot.com" always_null 
local-zone: "geovisite.com" always_null 
local-zone: "getclicky.com" always_null 
local-zone: "getintent.com" always_null 
local-zone: "getmyads.com" always_null 
local-zone: "giddycoat.com" always_null 
local-zone: "globalismedia.com" always_null 
local-zone: "globaltakeoff.net" always_null 
local-zone: "globus-inter.com" always_null 
local-zone: "glossysense.com" always_null 
local-zone: "gloyah.net" always_null 
local-zone: "gmads.net" always_null 
local-zone: "gml.email" always_null 
local-zone: "go2affise.com" always_null 
local-zone: "go-clicks.de" always_null 
local-zone: "goingplatinum.com" always_null 
local-zone: "goldstats.com" always_null 
local-zone: "go-mpulse.net" always_null 
local-zone: "gondolagnome.com" always_null 
local-zone: "google.comadsense" always_null 
local-zone: "google.comurl?q=*" always_null 
local-zone: "googleadservices.com" always_null 
local-zone: "googleanalytics.com" always_null 
local-zone: "google-analytics.com" always_null 
local-zone: "googlesyndication.com" always_null 
local-zone: "googletagmanager.com" always_null 
local-zone: "googletagservices.com" always_null 
local-zone: "go-rank.de" always_null 
local-zone: "gorgeousground.com" always_null 
local-zone: "gostats.com" always_null 
local-zone: "gothamads.com" always_null 
local-zone: "gotraffic.net" always_null 
local-zone: "gp.dejanews.com" always_null 
local-zone: "gracefulsock.com" always_null 
local-zone: "graizoah.com" always_null 
local-zone: "grandioseguide.com" always_null 
local-zone: "grapeshot.co.uk" always_null 
local-zone: "greetzebra.com" always_null 
local-zone: "greyinstrument.com" always_null 
local-zone: "greystripe.com" always_null 
local-zone: "grosshandel-angebote.de" always_null 
local-zone: "groundtruth.com" always_null 
local-zone: "gscontxt.net" always_null 
local-zone: "gtop100.com" always_null 
local-zone: "guardedschool.com" always_null 
local-zone: "gunggo.com" always_null 
local-zone: "guruads.de" always_null 
local-zone: "gutscheine.bild.de" always_null 
local-zone: "gutscheine.chip.de" always_null 
local-zone: "gutscheine.focus.de" always_null 
local-zone: "gutscheine.welt.de" always_null 
local-zone: "h0.t.hubspotemail.net" always_null 
local-zone: "h78xb.pw" always_null 
local-zone: "habitualhumor.com" always_null 
local-zone: "hackpalace.com" always_null 
local-zone: "hadskiz.com" always_null 
local-zone: "haltingbadge.com" always_null 
local-zone: "hammerhearing.com" always_null 
local-zone: "handyfield.com" always_null 
local-zone: "hardtofindmilk.com" always_null 
local-zone: "harrenmedia.com" always_null 
local-zone: "harrenmedianetwork.com" always_null 
local-zone: "havamedia.net" always_null 
local-zone: "hb.afl.rakuten.co.jp" always_null 
local-zone: "hbb.afl.rakuten.co.jp" always_null 
local-zone: "h-bid.com" always_null 
local-zone: "hdscout.com" always_null 
local-zone: "heap.com" always_null 
local-zone: "heias.com" always_null 
#local-zone: "heise.demediadaten" always_null 
#local-zone: "heise.demediadatenheise-online" always_null 
#local-zone: "heise.demediadatenonline" always_null 
local-zone: "hellobar.com" always_null 
local-zone: "hentaicounter.com" always_null 
local-zone: "herbalaffiliateprogram.com" always_null 
local-zone: "hexcan.com" always_null 
local-zone: "hexusads.fluent.ltd.uk" always_null 
local-zone: "heyos.com" always_null 
local-zone: "hfc195b.com" always_null 
local-zone: "hgads.com" always_null 
local-zone: "highfalutinroom.com" always_null 
local-zone: "hightrafficads.com" always_null 
local-zone: "hilariouszinc.com" always_null 
local-zone: "hilltopads.net" always_null 
local-zone: "histats.com" always_null 
local-zone: "historicalrequest.com" always_null 
local-zone: "hit.bg" always_null 
local-zone: "hit.ua" always_null 
local-zone: "hit.webcentre.lycos.co.uk" always_null 
local-zone: "hitbox.com" always_null 
local-zone: "hitcounters.miarroba.com" always_null 
local-zone: "hitfarm.com" always_null 
local-zone: "hitiz.com" always_null 
local-zone: "hitlist.ru" always_null 
local-zone: "hitlounge.com" always_null 
local-zone: "hitometer.com" always_null 
local-zone: "hit-parade.com" always_null 
local-zone: "hits.europuls.eu" always_null 
local-zone: "hits.informer.com" always_null 
local-zone: "hits.puls.lv" always_null 
local-zone: "hits.theguardian.com" always_null 
local-zone: "hits4me.com" always_null 
local-zone: "hits-i.iubenda.com" always_null 
local-zone: "hitslink.com" always_null 
local-zone: "hittail.com" always_null 
local-zone: "hlok.qertewrt.com" always_null 
local-zone: "hocgeese.com" always_null 
local-zone: "hollps.win" always_null 
local-zone: "homepageking.de" always_null 
local-zone: "honeygoldfish.com" always_null 
local-zone: "honorablehall.com" always_null 
local-zone: "honorableland.com" always_null 
local-zone: "hookupsonline.com" always_null 
local-zone: "hostedads.realitykings.com" always_null 
local-zone: "hotjar.com" always_null 
local-zone: "hotkeys.com" always_null 
local-zone: "hotlog.ru" always_null 
local-zone: "hotrank.com.tw" always_null 
local-zone: "hoverowl.com" always_null 
local-zone: "hsadspixel.net" always_null 
local-zone: "hs-analytics.net" always_null 
local-zone: "hs-banner.com" always_null 
local-zone: "hsrd.yahoo.com" always_null 
local-zone: "htlbid.com" always_null 
local-zone: "httpool.com" always_null 
local-zone: "hubadnetwork.com" always_null 
local-zone: "hueads.com" always_null 
local-zone: "hueadsortb.com" always_null 
local-zone: "hueadsxml.com" always_null 
local-zone: "hurricanedigitalmedia.com" always_null 
local-zone: "hurtteeth.com" always_null 
local-zone: "hydramedia.com" always_null 
local-zone: "hyperbanner.net" always_null 
local-zone: "hypertracker.com" always_null 
local-zone: "hyprmx.com" always_null 
local-zone: "hystericalhelp.com" always_null 
local-zone: "i1img.com" always_null 
local-zone: "i1media.no" always_null 
local-zone: "ia.iinfo.cz" always_null 
local-zone: "iad.anm.co.uk" always_null 
local-zone: "iadnet.com" always_null 
local-zone: "iasds01.com" always_null 
local-zone: "ibillboard.com" always_null 
local-zone: "i-clicks.net" always_null 
local-zone: "iconadserver.com" always_null 
local-zone: "iconpeak2trk.com" always_null 
local-zone: "icptrack.com" always_null 
local-zone: "id5-sync.com" always_null 
local-zone: "idealadvertising.net" always_null 
local-zone: "identads.com" always_null 
local-zone: "idevaffiliate.com" always_null 
local-zone: "idtargeting.com" always_null 
local-zone: "ientrymail.com" always_null 
local-zone: "iesnare.com" always_null 
local-zone: "ifa.tube8live.com" always_null 
local-zone: "i-i.lt" always_null 
local-zone: "ilbanner.com" always_null 
local-zone: "ilead.itrack.it" always_null 
local-zone: "illfatedsnail.com" always_null 
local-zone: "illustriousoatmeal.com" always_null 
local-zone: "imagecash.net" always_null 
local-zone: "images-pw.secureserver.net" always_null 
local-zone: "imarketservices.com" always_null 
local-zone: "img.prohardver.hu" always_null 
local-zone: "imgpromo.easyrencontre.com" always_null 
local-zone: "imgs.chip.de" always_null 
local-zone: "immensehoney.com" always_null 
local-zone: "imonitor.nethost.cz" always_null 
local-zone: "imonomy.com" always_null 
local-zone: "importedincrease.com" always_null 
local-zone: "impossibleexpansion.com" always_null 
local-zone: "imprese.cz" always_null 
local-zone: "impressionmedia.cz" always_null 
local-zone: "impressionmonster.com" always_null 
local-zone: "impressionz.co.uk" always_null 
local-zone: "improvedigital.com" always_null 
local-zone: "impulsehands.com" always_null 
local-zone: "imrworldwide.com" always_null 
local-zone: "inaccused.com" always_null 
local-zone: "incentaclick.com" always_null 
local-zone: "inclk.com" always_null 
local-zone: "incognitosearches.com" always_null 
local-zone: "incoming.telemetry.mozilla.org" always_null 
local-zone: "indexexchange.com" always_null 
local-zone: "indexstats.com" always_null 
local-zone: "indexww.com" always_null 
local-zone: "indieclick.com" always_null 
local-zone: "industrybrains.com" always_null 
local-zone: "inetlog.ru" always_null 
local-zone: "infinite-ads.com" always_null 
local-zone: "infinityads.com" always_null 
local-zone: "infolinks.com" always_null 
local-zone: "information.com" always_null 
local-zone: "inmobi.com" always_null 
local-zone: "inner-active.com" always_null 
local-zone: "innocentwax.com" always_null 
local-zone: "innovid.com" always_null 
local-zone: "inquisitiveinvention.com" always_null 
local-zone: "inringtone.com" always_null 
local-zone: "insgly.net" always_null 
local-zone: "insightexpress.com" always_null 
local-zone: "insightexpressai.com" always_null 
local-zone: "inskinad.com" always_null 
local-zone: "inspectlet.com" always_null 
local-zone: "install.365-stream.com" always_null 
local-zone: "instantmadness.com" always_null 
local-zone: "insticator.com" always_null 
local-zone: "instinctiveads.com" always_null 
local-zone: "instrumentsponge.com" always_null 
local-zone: "intelliads.com" always_null 
local-zone: "intelligent.com" always_null 
local-zone: "intellitext.de" always_null 
local-zone: "intellitxt.com" always_null 
local-zone: "intellitxt.de" always_null 
local-zone: "interactive.forthnet.gr" always_null 
local-zone: "intergi.com" always_null 
local-zone: "internetfuel.com" always_null 
local-zone: "interreklame.de" always_null 
local-zone: "intnotif.club" always_null 
local-zone: "inventionpassenger.com" always_null 
local-zone: "invitesugar.com" always_null 
local-zone: "ioam.de" always_null 
local-zone: "iomoio.com" always_null 
local-zone: "ip.ro" always_null 
local-zone: "ip193.cn" always_null 
local-zone: "iperceptions.com" always_null 
local-zone: "iporntv.com" always_null 
local-zone: "iporntv.net" always_null 
local-zone: "ipredictive.com" always_null 
local-zone: "ipro.com" always_null 
local-zone: "ipstack.com" always_null 
local-zone: "iqm.de" always_null 
local-zone: "irchan.com" always_null 
local-zone: "ireklama.cz" always_null 
local-zone: "is-tracking-pixel-api-prod.appspot.com" always_null 
local-zone: "itfarm.com" always_null 
local-zone: "itop.cz" always_null 
local-zone: "itsptp.com" always_null 
local-zone: "its-that-easy.com" always_null 
local-zone: "ivwbox.de" always_null 
local-zone: "ivw-online.de" always_null 
local-zone: "ivykiosk.com" always_null 
local-zone: "iyfnzgb.com" always_null 
local-zone: "j93557g.com" always_null 
local-zone: "jadeitite.com" always_null 
local-zone: "jads.co" always_null 
local-zone: "jaizouji.com" always_null 
local-zone: "jauchuwa.net" always_null 
local-zone: "jcount.com" always_null 
local-zone: "jdoqocy.com" always_null 
local-zone: "jinkads.de" always_null 
local-zone: "jjhouse.com" always_null 
local-zone: "joetec.net" always_null 
local-zone: "js.users.51.la" always_null 
local-zone: "js-agent.newrelic.com" always_null 
local-zone: "jsecoin.com" always_null 
local-zone: "jsrdn.com" always_null 
local-zone: "juicyads.com" always_null 
local-zone: "juicyads.me" always_null 
local-zone: "jumptap.com" always_null 
local-zone: "jungroup.com" always_null 
local-zone: "justicejudo.com" always_null 
local-zone: "justpremium.com" always_null 
local-zone: "justrelevant.com" always_null 
local-zone: "k.iinfo.cz" always_null 
local-zone: "kameleoon.eu" always_null 
local-zone: "kanoodle.com" always_null 
local-zone: "kargo.com" always_null 
local-zone: "karonty.com" always_null 
local-zone: "keygen.us" always_null 
local-zone: "keygenguru.com" always_null 
local-zone: "keygens.pro" always_null 
local-zone: "keymedia.hu" always_null 
local-zone: "kindads.com" always_null 
local-zone: "kinox.to" always_null 
local-zone: "kissmetrics.com" always_null 
local-zone: "klclick.com" always_null 
local-zone: "klclick1.com" always_null 
local-zone: "kleinanzaige.spiegel,de" always_null 
local-zone: "kleinanzeige.bild,de" always_null 
local-zone: "kleinanzeige.chip.de" always_null 
local-zone: "kleinanzeige.focus.de" always_null 
local-zone: "kleinanzeige.welt.de" always_null 
local-zone: "kliks.nl" always_null 
local-zone: "kliktrek.com" always_null 
local-zone: "klsdee.com" always_null 
local-zone: "kmpiframe.keepmeposted.com.mt" always_null 
local-zone: "knorex.com" always_null 
local-zone: "komoona.com" always_null 
local-zone: "kompasads.com" always_null 
local-zone: "kontera.com" always_null 
local-zone: "kost.tv" always_null 
local-zone: "kpu.samsungelectronics.com" always_null 
local-zone: "krxd.net" always_null 
local-zone: "kt5850pjz0.com" always_null 
local-zone: "ktu.sv2.biz" always_null 
local-zone: "ktxtr.com" always_null 
local-zone: "kubient.com" always_null 
local-zone: "l1.britannica.com" always_null 
local-zone: "l6b587txj1.com" always_null 
local-zone: "ladsreds.com" always_null 
local-zone: "ladsup.com" always_null 
local-zone: "lakequincy.com" always_null 
local-zone: "lameletters.com" always_null 
local-zone: "lanistaads.com" always_null 
local-zone: "larati.net" always_null 
local-zone: "laughablecopper.com" always_null 
local-zone: "laughcloth.com" always_null 
local-zone: "launchbit.com" always_null 
local-zone: "layer-ad.de" always_null 
local-zone: "layer-ads.de" always_null 
local-zone: "lbn.ru" always_null 
local-zone: "lead-analytics.nl" always_null 
local-zone: "leadboltads.net" always_null 
local-zone: "leadclick.com" always_null 
local-zone: "leadingedgecash.com" always_null 
local-zone: "leadplace.fr" always_null 
local-zone: "leady.com" always_null 
local-zone: "leadzupc.com" always_null 
local-zone: "leaplunchroom.com" always_null 
local-zone: "leedsads.com" always_null 
local-zone: "lemmatechnologies.com" always_null 
local-zone: "lettucelimit.com" always_null 
local-zone: "levelrate.de" always_null 
local-zone: "lfeeder.com" always_null 
local-zone: "lfstmedia.com" always_null 
local-zone: "li.alibris.com" always_null 
local-zone: "li.azstarnet.com" always_null 
local-zone: "li.dailycaller.com" always_null 
local-zone: "li.gatehousemedia.com" always_null 
local-zone: "li.gq.com" always_null 
local-zone: "li.hearstmags.com" always_null 
local-zone: "li.livingsocial.com" always_null 
local-zone: "li.mw.drhinternet.net" always_null 
local-zone: "li.onetravel.com" always_null 
local-zone: "li.patheos.com" always_null 
local-zone: "li.pmc.com" always_null 
local-zone: "li.purch.com" always_null 
local-zone: "li.realtor.com" always_null 
local-zone: "li.walmart.com" always_null 
local-zone: "li.ziffimages.com" always_null 
local-zone: "liadm.com" always_null 
local-zone: "lifeimpressions.net" always_null 
local-zone: "liftdna.com" always_null 
local-zone: "ligatus.com" always_null 
local-zone: "ligatus.de" always_null 
local-zone: "lightcast.leadscoringcenter.com" always_null 
local-zone: "lightcushion.com" always_null 
local-zone: "lightspeedcash.com" always_null 
local-zone: "lijit.com" always_null 
local-zone: "line.jzs001.cn" always_null 
local-zone: "link4ads.com" always_null 
local-zone: "linkadd.de" always_null 
local-zone: "link-booster.de" always_null 
local-zone: "linkbuddies.com" always_null 
local-zone: "linkexchange.com" always_null 
local-zone: "linkprice.com" always_null 
local-zone: "linkrain.com" always_null 
local-zone: "linkreferral.com" always_null 
local-zone: "linkshighway.com" always_null 
local-zone: "links-ranking.de" always_null 
local-zone: "linkstorms.com" always_null 
local-zone: "linkswaper.com" always_null 
local-zone: "linktarget.com" always_null 
local-zone: "liquidad.narrowcastmedia.com" always_null 
local-zone: "litix.io" always_null 
local-zone: "liveadexchanger.com" always_null 
local-zone: "liveintent.com" always_null 
local-zone: "liverail.com" always_null 
local-zone: "lizardslaugh.com" always_null 
local-zone: "lkqd.com" always_null 
local-zone: "lnks.gd" always_null 
local-zone: "loading321.com" always_null 
local-zone: "locked4.com" always_null 
local-zone: "lockerdome.com" always_null 
local-zone: "log.btopenworld.com" always_null 
local-zone: "log.logrocket.io" always_null 
local-zone: "log.pinterest.com" always_null 
local-zone: "log.videocampaign.co" always_null 
local-zone: "logger.snackly.co" always_null 
local-zone: "logs.roku.com" always_null 
local-zone: "logs.spilgames.com" always_null 
local-zone: "logsss.com" always_null 
local-zone: "logua.com" always_null 
local-zone: "longinglettuce.com" always_null 
local-zone: "look.djfiln.com" always_null 
local-zone: "look.ichlnk.com" always_null 
local-zone: "look.opskln.com" always_null 
local-zone: "look.udncoeln.com" always_null 
local-zone: "look.ufinkln.com" always_null 
local-zone: "loopme.com" always_null 
local-zone: "lop.com" always_null 
local-zone: "loudlunch.com" always_null 
local-zone: "lp3tdqle.com" always_null 
local-zone: "lucidmedia.com" always_null 
local-zone: "lucklayed.info" always_null 
local-zone: "lytics.io" always_null 
local-zone: "lzjl.com" always_null 
local-zone: "m.trb.com" always_null 
local-zone: "m1.webstats4u.com" always_null 
local-zone: "m2.ai" always_null 
local-zone: "m32.media" always_null 
local-zone: "m4n.nl" always_null 
local-zone: "m6r.eu" always_null 
local-zone: "macerkopf.dego" always_null 
local-zone: "mackeeperapp.mackeeper.com" always_null 
local-zone: "madbid.com" always_null 
local-zone: "madclient.uimserv.net" always_null 
local-zone: "madcpms.com" always_null 
local-zone: "madinad.com" always_null 
local-zone: "madisonavenue.com" always_null 
local-zone: "madvertise.de" always_null 
local-zone: "magicadz.co" always_null 
local-zone: "magnificentmist.com" always_null 
local-zone: "mail-ads.google.com" always_null 
local-zone: "mainstoreonline.com" always_null 
local-zone: "malaysia-online-bank-kasino.com" always_null 
local-zone: "manageadv.cblogs.eu" always_null 
local-zone: "marchex.com" always_null 
local-zone: "marinsm.com" always_null 
local-zone: "markedcrayon.com" always_null 
local-zone: "markedpail.com" always_null 
local-zone: "market-buster.com" always_null 
local-zone: "marketing.888.com" always_null 
local-zone: "marketing.hearstmagazines.nl" always_null 
local-zone: "marketing.net.brillen.de" always_null 
local-zone: "marketing.net.home24.de" always_null 
local-zone: "marketing.nyi.net" always_null 
local-zone: "marketing.osijek031.com" always_null 
local-zone: "marketingsolutions.yahoo.com" always_null 
local-zone: "marketo.com" always_null 
local-zone: "mas.sector.sk" always_null 
local-zone: "massivemark.com" always_null 
local-zone: "matchcraft.com" always_null 
local-zone: "materialmoon.com" always_null 
local-zone: "matheranalytics.com" always_null 
local-zone: "mathtag.com" always_null 
local-zone: "matomo.activate.cz" always_null 
local-zone: "matomo.hdweb.ru" always_null 
local-zone: "matomo.kmkb.ru" always_null 
local-zone: "mautic.com" always_null 
local-zone: "max.i12.de" always_null 
local-zone: "maximiser.net" always_null 
local-zone: "maximumcash.com" always_null 
local-zone: "maxonclick.com" always_null 
local-zone: "mbs.megaroticlive.com" always_null 
local-zone: "mcdlks.com" always_null 
local-zone: "me" always_null 
local-zone: "measure.office.com" always_null 
local-zone: "measuremap.com" always_null 
local-zone: "media.funpic.de" always_null 
local-zone: "media.net" always_null 
local-zone: "media01.eu" always_null 
local-zone: "media6degrees.com" always_null 
local-zone: "media-adrunner.mycomputer.com" always_null 
local-zone: "mediaarea.eu" always_null 
local-zone: "mediabridge.cc" always_null 
local-zone: "mediacharger.com" always_null 
local-zone: "mediageneral.com" always_null 
local-zone: "mediaiqdigital.com" always_null 
local-zone: "mediamath.com" always_null 
local-zone: "mediamgr.ugo.com" always_null 
local-zone: "mediaplazza.com" always_null 
local-zone: "mediaplex.com" always_null 
local-zone: "mediascale.de" always_null 
local-zone: "mediaserver.bwinpartypartners.it" always_null 
local-zone: "media-servers.net" always_null 
local-zone: "mediasmart.io" always_null 
local-zone: "mediatext.com" always_null 
local-zone: "mediavine.com" always_null 
local-zone: "mediavoice.com" always_null 
local-zone: "mediax.angloinfo.com" always_null 
local-zone: "mediaz.angloinfo.com" always_null 
local-zone: "medleyads.com" always_null 
local-zone: "medyanetads.com" always_null 
local-zone: "meetrics.net" always_null 
local-zone: "megacash.de" always_null 
local-zone: "mega-einkaufsquellen.de" always_null 
local-zone: "megapu.sh" always_null 
local-zone: "megastats.com" always_null 
local-zone: "megawerbung.de" always_null 
local-zone: "mellowads.com" always_null 
local-zone: "memorizeneck.com" always_null 
local-zone: "memorycobweb.com" always_null 
local-zone: "messagenovice.com" always_null 
local-zone: "metadsp.co.uk" always_null 
local-zone: "metaffiliation.com" always_null 
local-zone: "metanetwork.com" always_null 
local-zone: "methodcash.com" always_null 
local-zone: "metrics.api.drift.com" always_null 
local-zone: "metrics.cnn.com" always_null 
local-zone: "metrics.consumerreports.org" always_null 
local-zone: "metrics.ctv.ca" always_null 
local-zone: "metrics.foxnews.com" always_null 
local-zone: "metrics.getrockerbox.com" always_null 
local-zone: "metrics.gfycat.com" always_null 
local-zone: "metrics.govexec.com" always_null 
local-zone: "metrics-logger.spot.im" always_null 
local-zone: "metrilo.com" always_null 
local-zone: "mfadsrvr.com" always_null 
local-zone: "mg2connext.com" always_null 
local-zone: "mgid.com" always_null 
local-zone: "microim-widget.pl" always_null 
local-zone: "microticker.com" always_null 
local-zone: "militaryverse.com" always_null 
local-zone: "milotree.com" always_null 
local-zone: "minewhat.com" always_null 
local-zone: "minormeeting.com" always_null 
local-zone: "mintegral.com" always_null 
local-zone: "mixedreading.com" always_null 
local-zone: "mixpanel.com" always_null 
local-zone: "mkto-ab410147.com" always_null 
local-zone: "mktoresp.com" always_null 
local-zone: "ml314.com" always_null 
local-zone: "mlm.de" always_null 
local-zone: "mltrk.io" always_null 
local-zone: "mmismm.com" always_null 
local-zone: "mmstat.com" always_null 
local-zone: "mmtro.com" always_null 
local-zone: "moartraffic.com" always_null 
local-zone: "moat.com" always_null 
local-zone: "moatads.com" always_null 
local-zone: "moatpixel.com" always_null 
local-zone: "mobclix.com" always_null 
local-zone: "mobfox.com" always_null 
local-zone: "mobileanalytics.us-east-1.amazonaws.com" always_null 
local-zone: "mobilefuse.com" always_null 
local-zone: "mobileiconnect.com" always_null 
local-zone: "mobperads.net" always_null 
local-zone: "modernpricing.com" always_null 
local-zone: "modifyeyes.com" always_null 
local-zone: "moldyicicle.com" always_null 
local-zone: "mon.byteoversea.com" always_null 
local-zone: "monarchads.com" always_null 
local-zone: "monetate.net" always_null 
local-zone: "monetizer101.com" always_null 
local-zone: "moneyexpert.co.uk" always_null 
local-zone: "monsterpops.com" always_null 
local-zone: "mookie1.com" always_null 
local-zone: "mopub.com" always_null 
local-zone: "motionspots.com" always_null 
local-zone: "mouseflow.com" always_null 
local-zone: "mousestats.com" always_null 
local-zone: "movad.net" always_null 
local-zone: "movie4k.to" always_null 
local-zone: "mowfruit.com" always_null 
local-zone: "mp3fiesta.com" always_null 
local-zone: "mp3sugar.com" always_null 
local-zone: "mp3va.com" always_null 
local-zone: "mparticle.com" always_null 
local-zone: "mpstat.us" always_null 
local-zone: "mr-rank.de" always_null 
local-zone: "mrskincash.com" always_null 
local-zone: "msads.net" always_null 
local-zone: "mstrlytcs.com" always_null 
local-zone: "mtrcs.samba.tv" always_null 
local-zone: "mtree.com" always_null 
local-zone: "munchkin.marketo.net" always_null 
local-zone: "musiccounter.ru" always_null 
local-zone: "musicmp3.ru" always_null 
local-zone: "muwmedia.com" always_null 
local-zone: "mxptint.net" always_null 
local-zone: "myads.company" always_null 
local-zone: "myads.net" always_null 
local-zone: "myads.telkomsel.com" always_null 
local-zone: "myaffiliateprogram.com" always_null 
local-zone: "mybestmv.com" always_null 
local-zone: "mybetterdl.com" always_null 
local-zone: "mybloglog.com" always_null 
local-zone: "mybuys.com" always_null 
local-zone: "mycounter.ua" always_null 
local-zone: "mydas.mobi" always_null 
local-zone: "mylink-today.com" always_null 
local-zone: "mymoneymakingapp.com" always_null 
local-zone: "mypagerank.net" always_null 
local-zone: "mypagerank.ru" always_null 
local-zone: "mypass.de" always_null 
local-zone: "mypowermall.com" always_null 
local-zone: "mysafeads.com" always_null 
local-zone: "mystat.pl" always_null 
local-zone: "mystat-in.net" always_null 
local-zone: "mysteriousmonth.com" always_null 
local-zone: "mytop-in.net" always_null 
local-zone: "myvisualiq.net" always_null 
local-zone: "n69.com" always_null 
local-zone: "na.ads.yahoo.com" always_null 
local-zone: "naj.sk" always_null 
local-zone: "naradxb.com" always_null 
local-zone: "nastydollars.com" always_null 
local-zone: "nativeroll.tv" always_null 
local-zone: "naturalbid.com" always_null 
local-zone: "navegg.com" always_null 
local-zone: "navigator.io" always_null 
local-zone: "navrcholu.cz" always_null 
local-zone: "nbjmp.com" always_null 
local-zone: "ncaudienceexchange.com" always_null 
local-zone: "ndparking.com" always_null 
local-zone: "nedstatbasic.net" always_null 
local-zone: "neighborlywatch.com" always_null 
local-zone: "nend.net" always_null 
local-zone: "neocounter.neoworx-blog-tools.net" always_null 
local-zone: "nervoussummer.com" always_null 
local-zone: "netaffiliation.com" always_null 
local-zone: "netagent.cz" always_null 
local-zone: "netclickstats.com" always_null 
local-zone: "netcommunities.com" always_null 
local-zone: "netdirect.nl" always_null 
local-zone: "net-filter.com" always_null 
local-zone: "netincap.com" always_null 
local-zone: "netmng.com" always_null 
local-zone: "netpool.netbookia.net" always_null 
local-zone: "netshelter.net" always_null 
local-zone: "networkadvertising.org" always_null 
local-zone: "neudesicmediagroup.com" always_null 
local-zone: "newads.bangbros.com" always_null 
local-zone: "newbie.com" always_null 
local-zone: "newnet.qsrch.com" always_null 
local-zone: "newnudecash.com" always_null 
local-zone: "newopenx.detik.com" always_null 
local-zone: "newsadsppush.com" always_null 
local-zone: "newsletter-link.com" always_null 
local-zone: "newstarads.com" always_null 
local-zone: "newt1.adultadworld.com" always_null 
local-zone: "newt1.adultworld.com" always_null 
local-zone: "nexac.com" always_null 
local-zone: "nexage.com" always_null 
local-zone: "ng3.ads.warnerbros.com" always_null 
local-zone: "nhpfvdlbjg.com" always_null 
local-zone: "nitratory.com" always_null 
local-zone: "nitroclicks.com" always_null 
local-zone: "noiselessplough.com" always_null 
local-zone: "nondescriptcrowd.com" always_null 
local-zone: "nondescriptsmile.com" always_null 
local-zone: "nondescriptstocking.com" always_null 
local-zone: "novem.pl" always_null 
local-zone: "npttech.com" always_null 
local-zone: "nr-data.net" always_null 
local-zone: "ns1p.net" always_null 
local-zone: "ntv.io" always_null 
local-zone: "ntvk1.ru" always_null 
local-zone: "nuggad.net" always_null 
local-zone: "nuseek.com" always_null 
local-zone: "nuttyorganization.com" always_null 
local-zone: "nzaza.com" always_null 
local-zone: "o0bc.com" always_null 
local-zone: "o333o.com" always_null 
local-zone: "oafishobservation.com" always_null 
local-zone: "oas.benchmark.fr" always_null 
local-zone: "oas.repubblica.it" always_null 
local-zone: "oas.roanoke.com" always_null 
local-zone: "oas.toronto.com" always_null 
local-zone: "oas.uniontrib.com" always_null 
local-zone: "oas.villagevoice.com" always_null 
local-zone: "oascentral.chicagobusiness.com" always_null 
local-zone: "oascentral.fortunecity.com" always_null 
local-zone: "oascentral.register.com" always_null 
local-zone: "obscenesidewalk.com" always_null 
local-zone: "observantice.com" always_null 
local-zone: "oclasrv.com" always_null 
local-zone: "odbierz-bony.ovp.pl" always_null 
local-zone: "oewa.at" always_null 
local-zone: "offaces-butional.com" always_null 
local-zone: "offer.fyber.com" always_null 
local-zone: "offer.sponsorpay.com" always_null 
local-zone: "offerforge.com" always_null 
local-zone: "offermatica.com" always_null 
local-zone: "offerzone.click" always_null 
local-zone: "oglasi.posjetnica.com" always_null 
local-zone: "ogury.com" always_null 
local-zone: "oingo.com" always_null 
local-zone: "omnijay.com" always_null 
local-zone: "omniscientspark.com" always_null 
local-zone: "omniture.com" always_null 
local-zone: "omtrdc.net" always_null 
local-zone: "onaudience.com" always_null 
local-zone: "onclasrv.com" always_null 
local-zone: "onclickads.net" always_null 
local-zone: "oneandonlynetwork.com" always_null 
local-zone: "onenetworkdirect.com" always_null 
local-zone: "onestat.com" always_null 
local-zone: "onestatfree.com" always_null 
local-zone: "online.miarroba.com" always_null 
local-zone: "onlinecash.com" always_null 
local-zone: "onlinefilme.tv" always_null 
local-zone: "online-metrix.net" always_null 
local-zone: "onlinerewardcenter.com" always_null 
local-zone: "online-tests.de" always_null 
local-zone: "onlineticketexpress.com" always_null 
local-zone: "onscroll.com" always_null 
local-zone: "onthe.io" always_null 
local-zone: "opads.us" always_null 
local-zone: "open.oneplus.net" always_null 
local-zone: "openad.tf1.fr" always_null 
local-zone: "openad.travelnow.com" always_null 
local-zone: "openads.friendfinder.com" always_null 
local-zone: "openads.org" always_null 
local-zone: "openadsnetwork.com" always_null 
local-zone: "opentag-stats.qubit.com" always_null 
local-zone: "openx.actvtech.com" always_null 
local-zone: "openx.angelsgroup.org.uk" always_null 
local-zone: "openx.cairo360.com" always_null 
local-zone: "openx.kgmedia.eu" always_null 
local-zone: "openx.net" always_null 
local-zone: "openx.skinet.cz" always_null 
local-zone: "openx.smcaen.fr" always_null 
local-zone: "openx2.kytary.cz" always_null 
local-zone: "operationkettle.com" always_null 
local-zone: "opienetwork.com" always_null 
local-zone: "opmnstr.com" always_null 
local-zone: "optimallimit.com" always_null 
local-zone: "optimizely.com" always_null 
local-zone: "optimize-stats.voxmedia.com" always_null 
local-zone: "optimost.com" always_null 
local-zone: "optmd.com" always_null 
local-zone: "optmnstr.com" always_null 
local-zone: "optmstr.com" always_null 
local-zone: "optnmstr.com" always_null 
local-zone: "ota.cartrawler.com" always_null 
local-zone: "otto-images.developershed.com" always_null 
local-zone: "ouh3igaeb.com" always_null 
local-zone: "outbrain.com" always_null 
local-zone: "overconfidentfood.com" always_null 
local-zone: "overture.com" always_null 
local-zone: "owebanalytics.com" always_null 
local-zone: "owebmoney.ru" always_null 
local-zone: "owlsr.us" always_null 
local-zone: "owneriq.net" always_null 
local-zone: "ox1.shopcool.com.tw" always_null 
local-zone: "oxado.com" always_null 
local-zone: "oxcash.com" always_null 
local-zone: "oxen.hillcountrytexas.com" always_null 
local-zone: "p.nag.ru" always_null 
local-zone: "p2r14.com" always_null 
local-zone: "padsbrown.com" always_null 
local-zone: "padssup.com" always_null 
local-zone: "pagead.l.google.com" always_null 
local-zone: "pagefair.com" always_null 
local-zone: "pagefair.net" always_null 
local-zone: "pagerank4you.com" always_null 
local-zone: "pagerank-ranking.de" always_null 
local-zone: "pageranktop.com" always_null 
local-zone: "paleleaf.com" always_null 
local-zone: "panickycurtain.com" always_null 
local-zone: "paradoxfactor.com" always_null 
local-zone: "parchedangle.com" always_null 
local-zone: "parketsy.pro" always_null 
local-zone: "parsely.com" always_null 
local-zone: "parsimoniouspolice.com" always_null 
local-zone: "partner.pelikan.cz" always_null 
local-zone: "partnerad.l.google.com" always_null 
local-zone: "partner-ads.com" always_null 
local-zone: "partnerads.ysm.yahoo.com" always_null 
local-zone: "partnercash.de" always_null 
local-zone: "partnernet.amazon.de" always_null 
local-zone: "partners.priceline.com" always_null 
local-zone: "partners.webmasterplan.com" always_null 
local-zone: "passeura.com" always_null 
local-zone: "passion-4.net" always_null 
local-zone: "paycounter.com" always_null 
local-zone: "paypopup.com" always_null 
local-zone: "pbnet.ru" always_null 
local-zone: "pbterra.com" always_null 
local-zone: "pcash.imlive.com" always_null 
local-zone: "pctracking.net" always_null 
local-zone: "peep-auktion.de" always_null 
local-zone: "peer39.com" always_null 
local-zone: "pennyweb.com" always_null 
local-zone: "pepperjamnetwork.com" always_null 
local-zone: "perceivequarter.com" always_null 
local-zone: "percentmobile.com" always_null 
local-zone: "perfectaudience.com" always_null 
local-zone: "perfiliate.com" always_null 
local-zone: "performancerevenue.com" always_null 
local-zone: "performancerevenues.com" always_null 
local-zone: "performancing.com" always_null 
local-zone: "permutive.com" always_null 
local-zone: "personagraph.com" always_null 
local-zone: "petiteumbrella.com" always_null 
local-zone: "pgl.example.com" always_null 
local-zone: "pgl.example0101" always_null 
local-zone: "pgmediaserve.com" always_null 
local-zone: "pgpartner.com" always_null 
local-zone: "pheedo.com" always_null 
local-zone: "phoenix-adrunner.mycomputer.com" always_null 
local-zone: "photographpan.com" always_null 
local-zone: "phpadsnew.new.natuurpark.nl" always_null 
local-zone: "pi.pardot.com" always_null 
local-zone: "piano.io" always_null 
local-zone: "picadmedia.com" always_null 
local-zone: "piet2eix3l.com" always_null 
local-zone: "pietexture.com" always_null 
local-zone: "pilotaffiliate.com" always_null 
local-zone: "pimproll.com" always_null 
local-zone: "ping.ublock.org" always_null 
local-zone: "pipedream.wistia.com" always_null 
local-zone: "pippio.com" always_null 
local-zone: "piquantpigs.com" always_null 
local-zone: "pix.spot.im" always_null 
local-zone: "pixel.adsafeprotected.com" always_null 
local-zone: "pixel.bild.de" always_null 
local-zone: "pixel.condenastdigital.com" always_null 
local-zone: "pixel.digitru.st" always_null 
local-zone: "pixel.keywee.co" always_null 
local-zone: "pixel.mathtag.com" always_null 
local-zone: "pixel.mtrcs.samba.tv" always_null 
local-zone: "pixel.sojern.com" always_null 
local-zone: "pixel.watch" always_null 
local-zone: "pixel.yabidos.com" always_null 
local-zone: "pl" always_null 
local-zone: "placed.com" always_null 
local-zone: "play4traffic.com" always_null 
local-zone: "playhaven.com" always_null 
local-zone: "pleasantpump.com" always_null 
local-zone: "plista.com" always_null 
local-zone: "plotrabbit.com" always_null 
local-zone: "plugrush.com" always_null 
local-zone: "p-n.io" always_null 
local-zone: "pocketmath.com" always_null 
local-zone: "podtraff.com" always_null 
local-zone: "podtraft.com" always_null 
local-zone: "pointroll.com" always_null 
local-zone: "pokkt.com" always_null 
local-zone: "popads.net" always_null 
local-zone: "popcash.net" always_null 
local-zone: "popmyads.com" always_null 
local-zone: "popub.com" always_null 
local-zone: "popunder.ru" always_null 
local-zone: "popup.msn.com" always_null 
local-zone: "popup.taboola.com" always_null 
local-zone: "popupmoney.com" always_null 
local-zone: "popupnation.com" always_null 
local-zone: "popups.infostart.com" always_null 
local-zone: "popuptraffic.com" always_null 
local-zone: "porngraph.com" always_null 
local-zone: "porntrack.com" always_null 
local-zone: "possessivebucket.com" always_null 
local-zone: "possibleboats.com" always_null 
local-zone: "post.spmailtechno.com" always_null 
local-zone: "postback.iqm.com" always_null 
local-zone: "postrelease.com" always_null 
local-zone: "praddpro.de" always_null 
local-zone: "prchecker.info" always_null 
local-zone: "prebid.org" always_null 
local-zone: "predictad.com" always_null 
local-zone: "premium-offers.com" always_null 
local-zone: "presetrabbits.com" always_null 
local-zone: "previousplayground.com" always_null 
local-zone: "previouspotato.com" always_null 
local-zone: "primetime.net" always_null 
local-zone: "privatecash.com" always_null 
local-zone: "prmtracking.com" always_null 
local-zone: "pro-advertising.com" always_null 
local-zone: "prodtraff.com" always_null 
local-zone: "producecopy.com" always_null 
local-zone: "producer.getwisdom.io" always_null 
local-zone: "proext.com" always_null 
local-zone: "profero.com" always_null 
local-zone: "profi-kochrezepte.de" always_null 
local-zone: "profitrumour.com" always_null 
local-zone: "profiwin.de" always_null 
local-zone: "programattik.com" always_null 
local-zone: "projectwonderful.com" always_null 
local-zone: "pro-market.net" always_null 
local-zone: "promo.badoink.com" always_null 
local-zone: "promo.ulust.com" always_null 
local-zone: "promobenef.com" always_null 
local-zone: "promos.bwin.it" always_null 
local-zone: "promos.fling.com" always_null 
local-zone: "promote.pair.com" always_null 
local-zone: "promotions-884485.c.cdn77.org" always_null 
local-zone: "pronetadvertising.com" always_null 
local-zone: "proof-x.com" always_null 
local-zone: "propellerads.com" always_null 
local-zone: "propellerclick.com" always_null 
local-zone: "proper.io" always_null 
local-zone: "props.id" always_null 
local-zone: "prosper.on-line-casino.ca" always_null 
local-zone: "protectcrev.com" always_null 
local-zone: "protectsubrev.com" always_null 
local-zone: "proton-tm.com" always_null 
local-zone: "protraffic.com" always_null 
local-zone: "provexia.com" always_null 
local-zone: "prsaln.com" always_null 
local-zone: "prsitecheck.com" always_null 
local-zone: "pr-star.de" always_null 
local-zone: "ps7894.com" always_null 
local-zone: "pstmrk.it" always_null 
local-zone: "ptoushoa.com" always_null 
local-zone: "pub.chez.com" always_null 
local-zone: "pub.club-internet.fr" always_null 
local-zone: "pub.hardware.fr" always_null 
local-zone: "pub.network" always_null 
local-zone: "pub.realmedia.fr" always_null 
local-zone: "pubdirecte.com" always_null 
local-zone: "publicidad.elmundo.es" always_null 
local-zone: "publicidees.com" always_null 
local-zone: "pubmatic.com" always_null 
local-zone: "pubmine.com" always_null 
local-zone: "pubnative.net" always_null 
local-zone: "puffyloss.com" always_null 
local-zone: "puffypaste.com" always_null 
local-zone: "puffypull.com" always_null 
local-zone: "puffypurpose.com" always_null 
local-zone: "pushame.com" always_null 
local-zone: "pushance.com" always_null 
local-zone: "pushazer.com" always_null 
local-zone: "pushengage.com" always_null 
local-zone: "pushno.com" always_null 
local-zone: "pushtrack.co" always_null 
local-zone: "pushwhy.com" always_null 
local-zone: "px.ads.linkedin.com" always_null 
local-zone: "px.dynamicyield.com" always_null 
local-zone: "px.gfycat.com" always_null 
local-zone: "px.spiceworks.com" always_null 
local-zone: "pxl.iqm.com" always_null 
local-zone: "pymx5.com" always_null 
local-zone: "q.azcentral.com" always_null 
local-zone: "q1connect.com" always_null 
local-zone: "qcontentdelivery.info" always_null 
local-zone: "qctop.com" always_null 
local-zone: "qnsr.com" always_null 
local-zone: "qservz.com" always_null 
local-zone: "quacksquirrel.com" always_null 
local-zone: "quaintcan.com" always_null 
local-zone: "quantcast.com" always_null 
local-zone: "quantcount.com" always_null 
local-zone: "quantserve.com" always_null 
local-zone: "quantummetric.com" always_null 
local-zone: "quarterbean.com" always_null 
local-zone: "quarterserver.de" always_null 
local-zone: "questaffiliates.net" always_null 
local-zone: "quibids.com" always_null 
local-zone: "quicksandear.com" always_null 
local-zone: "quietknowledge.com" always_null 
local-zone: "quinst.com" always_null 
local-zone: "quisma.com" always_null 
local-zone: "quizzicalzephyr.com" always_null 
local-zone: "r.logrocket.io" always_null 
local-zone: "r.msn.com" always_null 
local-zone: "r.scoota.co" always_null 
local-zone: "radar.cedexis.com" always_null 
local-zone: "radarurl.com" always_null 
local-zone: "radiate.com" always_null 
local-zone: "rads.alfamedia.pl" always_null 
local-zone: "rads.realadmin.pl" always_null 
local-zone: "railwayrainstorm.com" always_null 
local-zone: "railwayreason.com" always_null 
local-zone: "rampidads.com" always_null 
local-zone: "rankchamp.de" always_null 
local-zone: "rankingchart.de" always_null 
local-zone: "ranking-charts.de" always_null 
local-zone: "ranking-hits.de" always_null 
local-zone: "ranking-links.de" always_null 
local-zone: "ranking-liste.de" always_null 
local-zone: "rankingscout.com" always_null 
local-zone: "rank-master.com" always_null 
local-zone: "rankyou.com" always_null 
local-zone: "rapidape.com" always_null 
local-zone: "rapidcounter.com" always_null 
local-zone: "rapidkittens.com" always_null 
local-zone: "raresummer.com" always_null 
local-zone: "rate.ru" always_null 
local-zone: "ratings.lycos.com" always_null 
local-zone: "rayjump.com" always_null 
local-zone: "reachjunction.com" always_null 
local-zone: "reactx.com" always_null 
local-zone: "readgoldfish.com" always_null 
local-zone: "readingguilt.com" always_null 
local-zone: "readingopera.com" always_null 
local-zone: "readserver.net" always_null 
local-zone: "readymoon.com" always_null 
local-zone: "realcastmedia.com" always_null 
local-zone: "realclever.com" always_null 
local-zone: "realclix.com" always_null 
local-zone: "realmedia-a800.d4p.net" always_null 
local-zone: "realsrv.com" always_null 
local-zone: "realtechnetwork.com" always_null 
local-zone: "realtracker.com" always_null 
local-zone: "rebelsubway.com" always_null 
local-zone: "receptiveink.com" always_null 
local-zone: "receptivereaction.com" always_null 
local-zone: "recoco.it" always_null 
local-zone: "record.affiliates.karjalakasino.com" always_null 
local-zone: "record.bonniergaming.com" always_null 
local-zone: "record.mrwin.com" always_null 
local-zone: "redirectingat.com" always_null 
local-zone: "re-directme.com" always_null 
local-zone: "redirectvoluum.com" always_null 
local-zone: "redshell.io" always_null 
local-zone: "reduxmedia.com" always_null 
local-zone: "referralware.com" always_null 
local-zone: "referrer.disqus.com" always_null 
local-zone: "reflectivereward.com" always_null 
local-zone: "reforge.in" always_null 
local-zone: "regnow.com" always_null 
local-zone: "regularplants.com" always_null 
local-zone: "reklam.rfsl.se" always_null 
local-zone: "reklama.mironet.cz" always_null 
local-zone: "reklama.reflektor.cz" always_null 
local-zone: "reklamcsere.hu" always_null 
local-zone: "reklamdsp.com" always_null 
local-zone: "reklame.unwired-i.net" always_null 
local-zone: "relevanz10.de" always_null 
local-zone: "relmaxtop.com" always_null 
local-zone: "remistrainew.club" always_null 
local-zone: "remox.com" always_null 
local-zone: "republika.onet.pl" always_null 
local-zone: "research.de.com" always_null 
local-zone: "resolutekey.com" always_null 
local-zone: "resonantbrush.com" always_null 
local-zone: "resonate.com" always_null 
local-zone: "responsiveads.com" always_null 
local-zone: "retargeter.com" always_null 
local-zone: "revcatch.com" always_null 
local-zone: "revcontent.com" always_null 
local-zone: "reveal.clearbit.com" always_null 
local-zone: "revenue.net" always_null 
local-zone: "revenuedirect.com" always_null 
local-zone: "revenuehits.com" always_null 
local-zone: "revive.docmatic.org" always_null 
local-zone: "revive.dubcnm.com" always_null 
local-zone: "revive.haskovo.net" always_null 
local-zone: "revive.netriota.hu" always_null 
local-zone: "revive.plays.bg" always_null 
local-zone: "revlift.io" always_null 
local-zone: "revprotect.com" always_null 
local-zone: "revsci.net" always_null 
local-zone: "revstats.com" always_null 
local-zone: "reyden-x.com" always_null 
local-zone: "rhombusads.com" always_null 
local-zone: "rhythmone.com" always_null 
local-zone: "richmails.com" always_null 
local-zone: "richmedia.yimg.com" always_null 
local-zone: "richstring.com" always_null 
local-zone: "richwebmaster.com" always_null 
local-zone: "rightstats.com" always_null 
local-zone: "rinconpx.net" always_null 
local-zone: "ringsrecord.com" always_null 
local-zone: "ritzykey.com" always_null 
local-zone: "rlcdn.com" always_null 
local-zone: "rle.ru" always_null 
local-zone: "rmads.msn.com" always_null 
local-zone: "rmedia.boston.com" always_null 
local-zone: "rmgserving.com" always_null 
local-zone: "ro" always_null 
local-zone: "roar.com" always_null 
local-zone: "robotreplay.com" always_null 
local-zone: "rockabox.co" always_null 
local-zone: "roia.biz" always_null 
local-zone: "rok.com.com" always_null 
local-zone: "roq.ad" always_null 
local-zone: "rose.ixbt.com" always_null 
local-zone: "rotabanner.com" always_null 
local-zone: "rotten.com" always_null 
local-zone: "rotten.de" always_null 
local-zone: "roughroll.com" always_null 
local-zone: "roxr.net" always_null 
local-zone: "royalgames.com" always_null 
local-zone: "rs" always_null 
local-zone: "rs6.net" always_null 
local-zone: "rta.dailymail.co.uk" always_null 
local-zone: "rtb.gumgum.com" always_null 
local-zone: "rtbadzesto.com" always_null 
local-zone: "rtbflairads.com" always_null 
local-zone: "rtbidhost.com" always_null 
local-zone: "rtbplatform.net" always_null 
local-zone: "rtbpop.com" always_null 
local-zone: "rtbpopd.com" always_null 
local-zone: "rtbsbengine.com" always_null 
local-zone: "rtbtradein.com" always_null 
local-zone: "rtmark.net" always_null 
local-zone: "rtpdn11.com" always_null 
local-zone: "rtxplatform.com" always_null 
local-zone: "ru" always_null 
local-zone: "ru4.com" always_null 
local-zone: "rubiconproject.com" always_null 
local-zone: "rum-http-intake.logs.datadoghq.com" always_null 
local-zone: "rum-http-intake.logs.datadoghq.eu" always_null 
local-zone: "runads.com" always_null 
local-zone: "rundsp.com" always_null 
local-zone: "ruthlessrobin.com" always_null 
local-zone: "s.adroll.com" always_null 
local-zone: "s1-adfly.com" always_null 
local-zone: "s20dh7e9dh.com" always_null 
local-zone: "s24hc8xzag.com" always_null 
local-zone: "s2d6.com" always_null 
local-zone: "sa.api.intl.miui.com" always_null 
local-zone: "sabio.us" always_null 
local-zone: "sageanalyst.net" always_null 
local-zone: "sail-horizon.com" always_null 
local-zone: "samsungacr.com" always_null 
local-zone: "samsungads.com" always_null 
local-zone: "saysidewalk.com" always_null 
local-zone: "sbx.pagesjaunes.fr" always_null 
local-zone: "scambiobanner.aruba.it" always_null 
local-zone: "sc-analytics.appspot.com" always_null 
local-zone: "scanscout.com" always_null 
local-zone: "scarcesign.com" always_null 
local-zone: "scatteredheat.com" always_null 
local-zone: "scintillatingscissors.com" always_null 
local-zone: "scintillatingspace.com" always_null 
local-zone: "scoobyads.com" always_null 
local-zone: "scopelight.com" always_null 
local-zone: "scorecardresearch.com" always_null 
local-zone: "scratch2cash.com" always_null 
local-zone: "screechingfurniture.com" always_null 
local-zone: "script.ioam.de" always_null 
local-zone: "scripte-monster.de" always_null 
local-zone: "scrubswim.com" always_null 
local-zone: "sdkfjxjertertry.com" always_null 
local-zone: "seadform.net" always_null 
local-zone: "searching-place.com" always_null 
local-zone: "searchmarketing.com" always_null 
local-zone: "searchramp.com" always_null 
local-zone: "secretivecub.com" always_null 
local-zone: "secretspiders.com" always_null 
local-zone: "secure.webconnect.net" always_null 
local-zone: "securedopen-bp.com" always_null 
local-zone: "securemetrics.apple.com" always_null 
local-zone: "sedoparking.com" always_null 
local-zone: "sedotracker.com" always_null 
local-zone: "segmetrics.io" always_null 
local-zone: "selectivesummer.com" always_null 
local-zone: "semasio.net" always_null 
local-zone: "sendmepixel.com" always_null 
local-zone: "sensismediasmart.com.au" always_null 
local-zone: "separatesilver.com" always_null 
local-zone: "serials.ws" always_null 
local-zone: "serienjunkies.org" always_null 
local-zone: "serienstream.to" always_null 
local-zone: "serv0.com" always_null 
local-zone: "servads.net" always_null 
local-zone: "servadsdisrupt.com" always_null 
local-zone: "servedbyadbutler.com" always_null 
local-zone: "servedby-buysellads.com" always_null 
local-zone: "servedbyopenx.com" always_null 
local-zone: "servethis.com" always_null 
local-zone: "service.urchin.com" always_null 
local-zone: "services.hearstmags.com" always_null 
local-zone: "servingmillions.com" always_null 
local-zone: "serving-sys.com" always_null 
local-zone: "sessioncam.com" always_null 
local-zone: "sexcounter.com" always_null 
local-zone: "sexinyourcity.com" always_null 
local-zone: "sexlist.com" always_null 
local-zone: "sextracker.com" always_null 
local-zone: "shakesea.com" always_null 
local-zone: "shakesuggestion.com" always_null 
local-zone: "shakytaste.com" always_null 
local-zone: "shallowsmile.com" always_null 
local-zone: "shareadspace.com" always_null 
local-zone: "shareasale.com" always_null 
local-zone: "sharethrough.com" always_null 
local-zone: "sharppatch.com" always_null 
local-zone: "sher.index.hu" always_null 
local-zone: "shermore.info" always_null 
local-zone: "shinystat.com" always_null 
local-zone: "shinystat.it" always_null 
local-zone: "shockinggrass.com" always_null 
local-zone: "shooshtime.com" always_null 
local-zone: "shoppingads.com" always_null 
local-zone: "sicksmash.com" always_null 
local-zone: "sidebar.angelfire.com" always_null 
local-zone: "silkysquirrel.com" always_null 
local-zone: "sillyscrew.com" always_null 
local-zone: "silvalliant.info" always_null 
local-zone: "silvermob.com" always_null 
local-zone: "simpleanalytics.io" always_null 
local-zone: "simplehitcounter.com" always_null 
local-zone: "simpli.fi" always_null 
local-zone: "sincerebuffalo.com" always_null 
local-zone: "sinoa.com" always_null 
local-zone: "sitedataprocessing.com" always_null 
local-zone: "siteimproveanalytics.com" always_null 
local-zone: "siteimproveanalytics.io" always_null 
local-zone: "siteintercept.qualtrics.com" always_null 
local-zone: "sitemeter.com" always_null 
local-zone: "sixscissors.com" always_null 
local-zone: "sixsigmatraffic.com" always_null 
local-zone: "sizesidewalk.com" always_null 
local-zone: "sizmek.com" always_null 
local-zone: "skimresources.com" always_null 
local-zone: "skylink.vn" always_null 
local-zone: "sleepcartoon.com" always_null 
local-zone: "slipperysack.com" always_null 
local-zone: "slopeaota.com" always_null 
local-zone: "smaato.com" always_null 
local-zone: "smallbeginner.com" always_null 
local-zone: "smart4ads.com" always_null 
local-zone: "smartadserver.com" always_null 
local-zone: "smartadserver.de" always_null 
local-zone: "smartadserver.net" always_null 
local-zone: "smartclip.net" always_null 
local-zone: "smartlook.com" always_null 
local-zone: "smartstream.tv" always_null 
local-zone: "smart-traffik.com" always_null 
local-zone: "smart-traffik.io" always_null 
local-zone: "smartyads.com" always_null 
local-zone: "smashsurprise.com" always_null 
local-zone: "smetrics.10daily.com.au" always_null 
local-zone: "smetrics.bestbuy.com" always_null 
local-zone: "smetrics.ctv.ca" always_null 
local-zone: "smetrics.foxnews.com" always_null 
local-zone: "smetrics.walgreens.com" always_null 
local-zone: "smetrics.washingtonpost.com" always_null 
local-zone: "smilingwaves.com" always_null 
local-zone: "smokerland.net" always_null 
local-zone: "smrtb.com" always_null 
local-zone: "snapads.com" always_null 
local-zone: "sneakystamp.com" always_null 
local-zone: "snoobi.com" always_null 
local-zone: "socialspark.com" always_null 
local-zone: "softclick.com.br" always_null 
local-zone: "sombersea.com" always_null 
local-zone: "sombersquirrel.com" always_null 
local-zone: "sombersurprise.com" always_null 
local-zone: "somniture.stuff.co.nz" always_null 
local-zone: "somoaudience.com" always_null 
local-zone: "sonobi.com" always_null 
local-zone: "sortable.com" always_null 
local-zone: "sourcepoint.vice.com" always_null 
local-zone: "sovrn.com" always_null 
local-zone: "spacash.com" always_null 
local-zone: "spaceleadster.com" always_null 
local-zone: "sparkstudios.com" always_null 
local-zone: "specially4u.net" always_null 
local-zone: "specificmedia.co.uk" always_null 
local-zone: "specificpop.com" always_null 
local-zone: "speedomizer.com" always_null 
local-zone: "speedshiftmedia.com" always_null 
local-zone: "spezialreporte.de" always_null 
local-zone: "spidersboats.com" always_null 
local-zone: "spiegel.deimages" always_null 
local-zone: "spiffymachine.com" always_null 
local-zone: "spinbox.techtracker.com" always_null 
local-zone: "spinbox.versiontracker.com" always_null 
local-zone: "spirebaboon.com" always_null 
local-zone: "sponsorads.de" always_null 
local-zone: "sponsorpro.de" always_null 
local-zone: "sponsors.thoughtsmedia.com" always_null 
local-zone: "sportsad.net" always_null 
local-zone: "spot.fitness.com" always_null 
local-zone: "spotscenered.info" always_null 
local-zone: "spotx.tv" always_null 
local-zone: "spotxchange.com" always_null 
local-zone: "springaftermath.com" always_null 
local-zone: "springserve.com" always_null 
local-zone: "spulse.net" always_null 
local-zone: "spurioussteam.com" always_null 
local-zone: "spykemediatrack.com" always_null 
local-zone: "spylog.com" always_null 
local-zone: "spywarelabs.com" always_null 
local-zone: "spywords.com" always_null 
local-zone: "squirrelhands.com" always_null 
local-zone: "srvmath.com" always_null 
local-zone: "srvtrck.com" always_null 
local-zone: "srwww1.com" always_null 
local-zone: "st.dynamicyield.com" always_null 
local-zone: "stackadapt.com" always_null 
local-zone: "stack-sonar.com" always_null 
local-zone: "stakingscrew.com" always_null 
local-zone: "stakingslope.com" always_null 
local-zone: "stalesummer.com" always_null 
local-zone: "standingnest.com" always_null 
local-zone: "starffa.com" always_null 
local-zone: "start.freeze.com" always_null 
local-zone: "startapp.com" always_null 
local-zone: "stat.cliche.se" always_null 
local-zone: "stat.dyna.ultraweb.hu" always_null 
local-zone: "stat.pl" always_null 
local-zone: "stat.webmedia.pl" always_null 
local-zone: "stat.xiaomi.com" always_null 
local-zone: "stat.zenon.net" always_null 
local-zone: "stat24.com" always_null 
local-zone: "stat24.meta.ua" always_null 
local-zone: "statcounter.com" always_null 
local-zone: "statdynamic.com" always_null 
local-zone: "static.a-ads.com" always_null 
local-zone: "static.fmpub.net" always_null 
local-zone: "static.itrack.it" always_null 
local-zone: "static.kameleoon.com" always_null 
local-zone: "staticads.btopenworld.com" always_null 
local-zone: "statistik-gallup.net" always_null 
local-zone: "statm.the-adult-company.com" always_null 
local-zone: "stats.blogger.com" always_null 
local-zone: "stats.hyperinzerce.cz" always_null 
local-zone: "stats.merriam-webster.com" always_null 
local-zone: "stats.mirrorfootball.co.uk" always_null 
local-zone: "stats.nextgen-email.com" always_null 
local-zone: "stats.olark.com" always_null 
local-zone: "stats.pusher.com" always_null 
local-zone: "stats.rdphv.net" always_null 
local-zone: "stats.self.com" always_null 
local-zone: "stats.townnews.com" always_null 
local-zone: "stats.unwired-i.net" always_null 
local-zone: "stats.wordpress.com" always_null 
local-zone: "stats.wp.com" always_null 
local-zone: "stats.x14.eu" always_null 
local-zone: "stats2.self.com" always_null 
local-zone: "stats4all.com" always_null 
local-zone: "statserv.net" always_null 
local-zone: "statsie.com" always_null 
local-zone: "stat-track.com" always_null 
local-zone: "statxpress.com" always_null 
local-zone: "steadfastsound.com" always_null 
local-zone: "steadfastsystem.com" always_null 
local-zone: "steelhouse.com" always_null 
local-zone: "steelhousemedia.com" always_null 
local-zone: "stepplane.com" always_null 
local-zone: "stickssheep.com" always_null 
local-zone: "stickyadstv.com" always_null 
local-zone: "stiffgame.com" always_null 
local-zone: "storesurprise.com" always_null 
local-zone: "storetail.io" always_null 
local-zone: "stormyachiever.com" always_null 
local-zone: "storygize.net" always_null 
local-zone: "stoveseashore.com" always_null 
local-zone: "straightnest.com" always_null 
local-zone: "stream.useriq.com" always_null 
local-zone: "stripedburst.com" always_null 
local-zone: "strivesidewalk.com" always_null 
local-zone: "structurerod.com" always_null 
local-zone: "stupendoussleet.com" always_null 
local-zone: "su" always_null 
local-zone: "subscribe.hearstmags.com" always_null 
local-zone: "succeedscene.com" always_null 
local-zone: "suddensidewalk.com" always_null 
local-zone: "sudoku.de" always_null 
local-zone: "sugarcurtain.com" always_null 
local-zone: "sugoicounter.com" always_null 
local-zone: "sulkybutter.com" always_null 
local-zone: "summerhamster.com" always_null 
local-zone: "summerobject.com" always_null 
local-zone: "sumo.com" always_null 
local-zone: "sumome.com" always_null 
local-zone: "superclix.de" always_null 
local-zone: "superficialsquare.com" always_null 
local-zone: "supersonicads.com" always_null 
local-zone: "superstats.com" always_null 
local-zone: "supertop.ru" always_null 
local-zone: "supertop100.com" always_null 
local-zone: "supertracking.net" always_null 
local-zone: "supply.colossusssp.com" always_null 
local-zone: "surfmusik-adserver.de" always_null 
local-zone: "surveygizmobeacon.s3.amazonaws.com" always_null 
local-zone: "sw88.espn.com" always_null 
local-zone: "swan-swan-goose.com" always_null 
local-zone: "swimslope.com" always_null 
local-zone: "swoggi.de" always_null 
local-zone: "swordfishdc.com" always_null 
local-zone: "swordgoose.com" always_null 
local-zone: "systemcdn.net" always_null 
local-zone: "t.bawafx.com" always_null 
local-zone: "t.eloqua.com" always_null 
local-zone: "t.firstpromoter.com" always_null 
local-zone: "t.insigit.com" always_null 
local-zone: "t.irtyd.com" always_null 
local-zone: "t.ktxtr.com" always_null 
local-zone: "taboola.com" always_null 
local-zone: "tag.links-analytics.com" always_null 
local-zone: "tagan.adlightning.com" always_null 
local-zone: "tagcommander.com" always_null 
local-zone: "tagger.opecloud.com" always_null 
local-zone: "tags.tiqcdn.com" always_null 
local-zone: "tagular.com" always_null 
local-zone: "tailsweep.com" always_null 
local-zone: "tailsweep.se" always_null 
local-zone: "takethatad.com" always_null 
local-zone: "takru.com" always_null 
local-zone: "talentedsteel.com" always_null 
local-zone: "tamgrt.com" always_null 
local-zone: "tangerinenet.biz" always_null 
local-zone: "tangibleteam.com" always_null 
local-zone: "tapad.com" always_null 
local-zone: "tapfiliate.com" always_null 
local-zone: "tapinfluence.com" always_null 
local-zone: "tapjoy.com" always_null 
local-zone: "tappx.com" always_null 
local-zone: "targad.de" always_null 
local-zone: "target.microsoft.com" always_null 
local-zone: "targeting.api.drift.com" always_null 
local-zone: "targeting.nzme.arcpublishing.com" always_null 
local-zone: "targeting.voxus.tv" always_null 
local-zone: "targetingnow.com" always_null 
local-zone: "targetnet.com" always_null 
local-zone: "targetpoint.com" always_null 
local-zone: "tastefulsongs.com" always_null 
local-zone: "tatsumi-sys.jp" always_null 
local-zone: "tawdryson.com" always_null 
local-zone: "tcads.net" always_null 
local-zone: "teads.tv" always_null 
local-zone: "tealeaf.com" always_null 
local-zone: "tealium.cbsnews.com" always_null 
local-zone: "tealium.com" always_null 
local-zone: "tealiumiq.com" always_null 
local-zone: "techclicks.net" always_null 
local-zone: "tedioustooth.com" always_null 
local-zone: "teenrevenue.com" always_null 
local-zone: "teenyvolcano.com" always_null 
local-zone: "teethfan.com" always_null 
local-zone: "telaria.com" always_null 
local-zone: "telemetry.dropbox.com" always_null 
local-zone: "telemetry.v.dropbox.com" always_null 
local-zone: "temelio.com" always_null 
local-zone: "tendertest.com" always_null 
local-zone: "tercept.com" always_null 
local-zone: "terriblethumb.com" always_null 
local-zone: "textad.sexsearch.com" always_null 
local-zone: "textads.biz" always_null 
local-zone: "text-link-ads.com" always_null 
local-zone: "textlinks.com" always_null 
local-zone: "tfag.de" always_null 
local-zone: "theadex.com" always_null 
local-zone: "theadhost.com" always_null 
local-zone: "thebugs.ws" always_null 
local-zone: "theclickads.com" always_null 
local-zone: "themoneytizer.com" always_null 
local-zone: "the-ozone-project.com" always_null 
local-zone: "therapistla.com" always_null 
local-zone: "thinkablerice.com" always_null 
local-zone: "thirdrespect.com" always_null 
local-zone: "thirstytwig.com" always_null 
local-zone: "thomastorch.com" always_null 
local-zone: "threechurch.com" always_null 
local-zone: "throattrees.com" always_null 
local-zone: "throtle.io" always_null 
local-zone: "thruport.com" always_null 
local-zone: "ti.domainforlite.com" always_null 
local-zone: "tia.timeinc.net" always_null 
local-zone: "ticketaunt.com" always_null 
local-zone: "ticklesign.com" always_null 
local-zone: "ticksel.com" always_null 
local-zone: "tidaltv.com" always_null 
local-zone: "tidint.pro" always_null 
local-zone: "tinybar.com" always_null 
local-zone: "tkbo.com" always_null 
local-zone: "tls.telemetry.swe.quicinc.com" always_null 
local-zone: "tlvmedia.com" always_null 
local-zone: "tnkexchange.com" always_null 
local-zone: "tns-counter.ru" always_null 
local-zone: "tntclix.co.uk" always_null 
local-zone: "toecircle.com" always_null 
local-zone: "toothbrushnote.com" always_null 
local-zone: "top.list.ru" always_null 
local-zone: "top.mail.ru" always_null 
local-zone: "top.proext.com" always_null 
local-zone: "top100.mafia.ru" always_null 
local-zone: "top100-images.rambler.ru" always_null 
local-zone: "top123.ro" always_null 
local-zone: "top20free.com" always_null 
local-zone: "top90.ro" always_null 
local-zone: "topbucks.com" always_null 
local-zone: "top-casting-termine.de" always_null 
local-zone: "topforall.com" always_null 
local-zone: "topgamesites.net" always_null 
local-zone: "toplist.cz" always_null 
local-zone: "toplist.pornhost.com" always_null 
local-zone: "toplista.mw.hu" always_null 
local-zone: "toplistcity.com" always_null 
local-zone: "topping.com.ua" always_null 
local-zone: "toprebates.com" always_null 
local-zone: "topsir.com" always_null 
local-zone: "topsite.lv" always_null 
local-zone: "top-site-list.com" always_null 
local-zone: "topsites.com.br" always_null 
local-zone: "topstats.com" always_null 
local-zone: "totemcash.com" always_null 
local-zone: "touchclarity.com" always_null 
local-zone: "touchclarity.natwest.com" always_null 
local-zone: "tour.brazzers.com" always_null 
local-zone: "track.addevent.com" always_null 
local-zone: "track.adform.net" always_null 
local-zone: "track.anchorfree.com" always_null 
local-zone: "track.contently.com" always_null 
local-zone: "track.effiliation.com" always_null 
local-zone: "track.flexlinks.com" always_null 
local-zone: "track.flexlinkspro.com" always_null 
local-zone: "track.freemmo2017.com" always_null 
local-zone: "track.game18click.com" always_null 
local-zone: "track.gawker.com" always_null 
local-zone: "track.hexcan.com" always_null 
local-zone: "track.mailerlite.com" always_null 
local-zone: "track.nuxues.com" always_null 
local-zone: "track.themaccleanup.info" always_null 
local-zone: "track.tkbo.com" always_null 
local-zone: "track.ultravpn.com" always_null 
local-zone: "track.undressingpics.work" always_null 
local-zone: "track.unear.net" always_null 
local-zone: "track.vcdc.com" always_null 
local-zone: "track.viewdeos.com" always_null 
local-zone: "track1.viewdeos.com" always_null 
local-zone: "trackalyzer.com" always_null 
local-zone: "trackedlink.net" always_null 
local-zone: "trackedweb.net" always_null 
local-zone: "tracker.bannerflow.com" always_null 
local-zone: "tracker.cdnbye.com" always_null 
local-zone: "tracker.comunidadmarriott.com" always_null 
local-zone: "tracker.icerocket.com" always_null 
local-zone: "tracker.mmdlv.it" always_null 
local-zone: "tracker.samplicio.us" always_null 
local-zone: "tracker.vgame.us" always_null 
local-zone: "tracker-pm2.spilleren.com" always_null 
local-zone: "tracking.1-a1502-bi.co.uk" always_null 
local-zone: "tracking.1-kv015-ap.co.uk" always_null 
local-zone: "tracking.21-a4652-bi.co.uk" always_null 
local-zone: "tracking.39-bb4a9-osm.co.uk" always_null 
local-zone: "tracking.42-01pr5-osm-secure.co.uk" always_null 
local-zone: "tracking.5-47737-bi.co.uk" always_null 
local-zone: "tracking.epicgames.com" always_null 
local-zone: "tracking.gajmp.com" always_null 
local-zone: "tracking.hyros.com" always_null 
local-zone: "tracking.ibxlink.com" always_null 
local-zone: "tracking.internetstores.de" always_null 
local-zone: "tracking.intl.miui.com" always_null 
local-zone: "tracking.jiffyworld.com" always_null 
local-zone: "tracking.lenddom.com" always_null 
local-zone: "tracking.markethero.io" always_null 
local-zone: "tracking.miui.com" always_null 
local-zone: "tracking.olx-st.com" always_null 
local-zone: "tracking.orixa-media.com" always_null 
local-zone: "tracking.publicidees.com" always_null 
local-zone: "tracking.thinkabt.com" always_null 
local-zone: "tracking01.walmart.com" always_null 
local-zone: "tracking101.com" always_null 
local-zone: "tracking22.com" always_null 
local-zone: "trackingfestival.com" always_null 
local-zone: "trackingsoft.com" always_null 
local-zone: "tracklink-tel.de" always_null 
local-zone: "trackmysales.com" always_null 
local-zone: "trackuhub.com" always_null 
local-zone: "tradeadexchange.com" always_null 
local-zone: "tradedoubler.com" always_null 
local-zone: "trading-rtbg.com" always_null 
local-zone: "traffic.focuusing.com" always_null 
local-zone: "traffic-exchange.com" always_null 
local-zone: "trafficfactory.biz" always_null 
local-zone: "trafficforce.com" always_null 
local-zone: "trafficholder.com" always_null 
local-zone: "traffichunt.com" always_null 
local-zone: "trafficjunky.net" always_null 
local-zone: "trafficleader.com" always_null 
local-zone: "traffic-redirecting.com" always_null 
local-zone: "trafficreps.com" always_null 
local-zone: "trafficrouter.io" always_null 
local-zone: "trafficshop.com" always_null 
local-zone: "trafficspaces.net" always_null 
local-zone: "trafficstrategies.com" always_null 
local-zone: "trafficswarm.com" always_null 
local-zone: "traffictrader.net" always_null 
local-zone: "trafficz.com" always_null 
local-zone: "traffiq.com" always_null 
local-zone: "trafic.ro" always_null 
local-zone: "traktrafficflow.com" always_null 
local-zone: "tranquilside.com" always_null 
local-zone: "travis.bosscasinos.com" always_null 
local-zone: "trck.a8.net" always_null 
local-zone: "trcking4wdm.de" always_null 
local-zone: "trcklion.com" always_null 
local-zone: "treasuredata.com" always_null 
local-zone: "trekdata.com" always_null 
local-zone: "tremendoustime.com" always_null 
local-zone: "tremorhub.com" always_null 
local-zone: "trendcounter.com" always_null 
local-zone: "trendmd.com" always_null 
local-zone: "tribalfusion.com" always_null 
local-zone: "trickycelery.com" always_null 
local-zone: "triplelift.com" always_null 
local-zone: "triptease.io" always_null 
local-zone: "trix.net" always_null 
local-zone: "trk.bee-data.com" always_null 
local-zone: "trk.techtarget.com" always_null 
local-zone: "trk42.net" always_null 
local-zone: "trkn.us" always_null 
local-zone: "trknths.com" always_null 
local-zone: "trmit.com" always_null 
local-zone: "truckstomatoes.com" always_null 
local-zone: "truehits.net" always_null 
local-zone: "truehits1.gits.net.th" always_null 
local-zone: "truehits2.gits.net.th" always_null 
local-zone: "trust.titanhq.com" always_null 
local-zone: "truste" always_null 
local-zone: "trusted.de" always_null 
local-zone: "trustx.org" always_null 
local-zone: "tsyndicate.com" always_null 
local-zone: "tsyndicate.net" always_null 
local-zone: "tubelibre.com" always_null 
local-zone: "tubemogul.com" always_null 
local-zone: "tubepatrol.net" always_null 
local-zone: "tubesafari.com" always_null 
local-zone: "turboadv.com" always_null 
local-zone: "turn.com" always_null 
local-zone: "tvmtracker.com" always_null 
local-zone: "twiago.com" always_null 
local-zone: "twittad.com" always_null 
local-zone: "twyn.com" always_null 
local-zone: "tynt.com" always_null 
local-zone: "typicalteeth.com" always_null 
local-zone: "tyroo.com" always_null 
local-zone: "uarating.com" always_null 
local-zone: "ucfunnel.com" always_null 
local-zone: "udkcrj.com" always_null 
local-zone: "udncoeln.com" always_null 
local-zone: "uib.ff.avast.com" always_null 
local-zone: "ukbanners.com" always_null 
local-zone: "ultimateclixx.com" always_null 
local-zone: "ultramercial.com" always_null 
local-zone: "ultraoranges.com" always_null 
local-zone: "unarmedindustry.com" always_null 
local-zone: "undertone.com" always_null 
local-zone: "unister-adserver.de" always_null 
local-zone: "unknowntray.com" always_null 
local-zone: "unless.com" always_null 
local-zone: "unrulymedia.com" always_null 
local-zone: "untd.com" always_null 
local-zone: "untidyquestion.com" always_null 
local-zone: "unup4y" always_null 
local-zone: "unusualtitle.com" always_null 
local-zone: "unwieldyhealth.com" always_null 
local-zone: "unwrittenspot.com" always_null 
local-zone: "upu.samsungelectronics.com" always_null 
local-zone: "urbandictionary.com" always_null 
local-zone: "urchin.com" always_null 
local-zone: "urlcash.net" always_null 
local-zone: "urldata.net" always_null 
local-zone: "us.a1.yimg.com" always_null 
local-zone: "userreplay.com" always_null 
local-zone: "userreplay.net" always_null 
local-zone: "utils.mediageneral.net" always_null 
local-zone: "utl-1.com" always_null 
local-zone: "uttermosthobbies.com" always_null 
local-zone: "uu.domainforlite.com" always_null 
local-zone: "uzk4umokyri3.com" always_null 
local-zone: "v1.cnzz.com" always_null 
local-zone: "v1adserver.com" always_null 
local-zone: "validclick.com" always_null 
local-zone: "valuead.com" always_null 
local-zone: "valueclick.com" always_null 
local-zone: "valueclickmedia.com" always_null 
local-zone: "valuecommerce.com" always_null 
local-zone: "valuesponsor.com" always_null 
local-zone: "vanfireworks.com" always_null 
local-zone: "variablefitness.com" always_null 
local-zone: "vcommission.com" always_null 
local-zone: "veille-referencement.com" always_null 
local-zone: "velismedia.com" always_null 
local-zone: "ventivmedia.com" always_null 
local-zone: "venturead.com" always_null 
local-zone: "verblife-3.co" always_null 
local-zone: "verblife-4.co" always_null 
local-zone: "verblife-5.co" always_null 
local-zone: "vericlick.com" always_null 
local-zone: "vertamedia.com" always_null 
local-zone: "verticalmass.com" always_null 
local-zone: "vervewireless.com" always_null 
local-zone: "vgwort.com" always_null 
local-zone: "vgwort.de" always_null 
local-zone: "vgwort.org" always_null 
local-zone: "vibrantmedia.com" always_null 
local-zone: "vidcpm.com" always_null 
local-zone: "videoadex.com" always_null 
local-zone: "videoamp.com" always_null 
local-zone: "videoegg.com" always_null 
local-zone: "videostats.kakao.com" always_null 
local-zone: "video-stats.video.google.com" always_null 
local-zone: "vidible.tv" always_null 
local-zone: "vidora.com" always_null 
local-zone: "view4cash.de" always_null 
local-zone: "viglink.com" always_null 
local-zone: "visiblemeasures.com" always_null 
local-zone: "visistat.com" always_null 
local-zone: "visit.webhosting.yahoo.com" always_null 
local-zone: "visitbox.de" always_null 
local-zone: "visitpath.com" always_null 
local-zone: "visual-pagerank.fr" always_null 
local-zone: "visualrevenue.com" always_null 
local-zone: "vivads.net" always_null 
local-zone: "vivatube.com" always_null 
local-zone: "vivime.net.fr" always_null 
local-zone: "vivtracking.com" always_null 
local-zone: "vmmpxl.com" always_null 
local-zone: "vodafone-affiliate.de" always_null 
local-zone: "voicefive.com" always_null 
local-zone: "voicevegetable.com" always_null 
local-zone: "voluum.com" always_null 
local-zone: "voluumtrk.com" always_null 
local-zone: "voluumtrk2.com" always_null 
local-zone: "volvelle.tech" always_null 
local-zone: "voodoo-ads.io" always_null 
local-zone: "vpon.com" always_null 
local-zone: "vrs.cz" always_null 
local-zone: "vrtzcontextualads.com" always_null 
local-zone: "vs.tucows.com" always_null 
local-zone: "vtracy.de" always_null 
local-zone: "vungle.com" always_null 
local-zone: "vwo.com" always_null 
local-zone: "vx.org.ua" always_null 
local-zone: "w55c.net" always_null 
local-zone: "wa.and.co.uk" always_null 
local-zone: "waardex.com" always_null 
local-zone: "warlog.ru" always_null 
local-zone: "warmafterthought.com" always_null 
local-zone: "waryfog.com" always_null 
local-zone: "wateryvan.com" always_null 
local-zone: "wdads.sx.atl.publicus.com" always_null 
local-zone: "wd-track.de" always_null 
local-zone: "wearbasin.com" always_null 
local-zone: "web.informer.com" always_null 
local-zone: "web2.deja.com" always_null 
local-zone: "webads.co.nz" always_null 
local-zone: "webads.nl" always_null 
local-zone: "webcash.nl" always_null 
local-zone: "webcontentassessor.com" always_null 
local-zone: "webcounter.cz" always_null 
local-zone: "webcounter.goweb.de" always_null 
local-zone: "webctrx.com" always_null 
local-zone: "webgains.com" always_null 
local-zone: "weborama.com" always_null 
local-zone: "weborama.fr" always_null 
local-zone: "webpower.com" always_null 
local-zone: "web-redirecting.com" always_null 
local-zone: "webreseau.com" always_null 
local-zone: "webseoanalytics.com" always_null 
local-zone: "websponsors.com" always_null 
local-zone: "webstat.channel4.com" always_null 
local-zone: "webstat.com" always_null 
local-zone: "web-stat.com" always_null 
local-zone: "webstat.net" always_null 
local-zone: "webstats4u.com" always_null 
local-zone: "webtracker.jp" always_null 
local-zone: "webtrackerplus.com" always_null 
local-zone: "webtracky.com" always_null 
local-zone: "webtraffic.se" always_null 
local-zone: "webtraxx.de" always_null 
local-zone: "webtrends.telegraph.co.uk" always_null 
local-zone: "webtrendslive.com" always_null 
local-zone: "webxcdn.com" always_null 
local-zone: "wellmadefrog.com" always_null 
local-zone: "werbung.meteoxpress.com" always_null 
local-zone: "wetrack.it" always_null 
local-zone: "whaleads.com" always_null 
local-zone: "wheredoyoucomefrom.ovh" always_null 
local-zone: "whirlwealth.com" always_null 
local-zone: "whiskyqueue.com" always_null 
local-zone: "whispa.com" always_null 
local-zone: "whisperingcrib.com" always_null 
local-zone: "whitexxxtube.com" always_null 
local-zone: "whoisonline.net" always_null 
local-zone: "wholesaletraffic.info" always_null 
local-zone: "widespace.com" always_null 
local-zone: "widget.privy.com" always_null 
local-zone: "widgetbucks.com" always_null 
local-zone: "wikia-ads.wikia.com" always_null 
local-zone: "win.iqm.com" always_null 
local-zone: "window.nixnet.cz" always_null 
local-zone: "wintricksbanner.googlepages.com" always_null 
local-zone: "wirecomic.com" always_null 
local-zone: "wisepops.com" always_null 
local-zone: "witch-counter.de" always_null 
local-zone: "wizaly.com" always_null 
local-zone: "wlmarketing.com" always_null 
local-zone: "womanear.com" always_null 
local-zone: "wonderlandads.com" always_null 
local-zone: "wondoads.de" always_null 
local-zone: "woopra.com" always_null 
local-zone: "worldwide-cash.net" always_null 
local-zone: "worldwidedigitalads.com" always_null 
local-zone: "worriednumber.com" always_null 
local-zone: "wpnrtnmrewunrtok.xyz" always_null 
local-zone: "wryfinger.com" always_null 
local-zone: "ws" always_null 
local-zone: "wt.bankmillennium.pl" always_null 
local-zone: "wt-eu02.net" always_null 
local-zone: "wtlive.com" always_null 
local-zone: "www.amazon.in" always_null 
local-zone: "www.dnps.com" always_null 
local-zone: "www.kaplanindex.com" always_null 
local-zone: "www.photo-ads.co.uk" always_null 
local-zone: "www8.glam.com" always_null 
local-zone: "www-banner.chat.ru" always_null 
local-zone: "www-google-analytics.l.google.com" always_null 
local-zone: "wwwpromoter.com" always_null 
local-zone: "x.bild.de" always_null 
local-zone: "x.chip.de" always_null 
local-zone: "x.fokus.de" always_null 
local-zone: "x.welt.de" always_null 
local-zone: "x6.yakiuchi.com" always_null 
local-zone: "xad.com" always_null 
local-zone: "xapads.com" always_null 
local-zone: "xchange.ro" always_null 
local-zone: "xertive.com" always_null 
local-zone: "xfreeservice.com" always_null 
local-zone: "xg4ken.com" always_null 
local-zone: "xiti.com" always_null 
local-zone: "xovq5nemr.com" always_null 
local-zone: "xplusone.com" always_null 
local-zone: "xponsor.com" always_null 
local-zone: "xpu.samsungelectronics.com" always_null 
local-zone: "xq1.net" always_null 
local-zone: "xtendmedia.com" always_null 
local-zone: "x-traceur.com" always_null 
local-zone: "xtracker.logimeter.com" always_null 
local-zone: "xtremetop100.com" always_null 
local-zone: "xxxcounter.com" always_null 
local-zone: "xxxmyself.com" always_null 
local-zone: "y.ibsys.com" always_null 
local-zone: "yab-adimages.s3.amazonaws.com" always_null 
local-zone: "yadro.ru" always_null 
local-zone: "yepads.com" always_null 
local-zone: "yesads.com" always_null 
local-zone: "yesadvertising.com" always_null 
local-zone: "yieldads.com" always_null 
local-zone: "yieldlab.net" always_null 
local-zone: "yieldmanager.com" always_null 
local-zone: "yieldmanager.net" always_null 
local-zone: "yieldmo.com" always_null 
local-zone: "yieldtraffic.com" always_null 
local-zone: "yldbt.com" always_null 
local-zone: "ymetrica1.com" always_null 
local-zone: "yoggrt.com" always_null 
local-zone: "ypu.samsungelectronics.com" always_null 
local-zone: "z3dmbpl6309s.com" always_null 
local-zone: "z5x.net" always_null 
local-zone: "zangocash.com" always_null 
local-zone: "zanox.com" always_null 
local-zone: "zanox-affiliate.de" always_null 
local-zone: "zantracker.com" always_null 
local-zone: "zarget.com" always_null 
local-zone: "zbwp6ghm.com" always_null 
local-zone: "zealousfield.com" always_null 
local-zone: "zedo.com" always_null 
local-zone: "zemanta.com" always_null 
local-zone: "zencudo.co.uk" always_null 
local-zone: "zenkreka.com" always_null 
local-zone: "zenra.com" always_null 
local-zone: "zenra.de" always_null 
local-zone: "zenzuu.com" always_null 
local-zone: "zeus.developershed.com" always_null 
local-zone: "zeusclicks.com" always_null 
local-zone: "zlp6s.pw" always_null 
local-zone: "zm232.com" always_null 
local-zone: "zmedia.com" always_null 
local-zone: "zpu.samsungelectronics.com" always_null 
local-zone: "zqtk.net" always_null 
local-zone: "zukxd6fkxqn.com" always_null 
local-zone: "zy16eoat1w.com" always_null 
local-zone: "zzhc.vnet.cn" always_null 
local-zone: "cmp.amica.de" always_null 
local-zone: "cmp.cinema.de" always_null 
local-zone: "cmp.fitforfun.de" always_null 
local-zone: "cmp.patientus.de" always_null 
local-zone: "cmp.tvspielfilm.de" always_null 
local-zone: "cmp.playboy.de" always_null 
local-zone: "cmp.bunte.de" always_null 
local-zone: "cmp.haus.de" always_null 
local-zone: "cmp.elle.de" always_null 
local-zone: "cmp.freundin.de" always_null 
local-zone: "cmp.mein-schoener-garten.de" always_null 
local-zone: "cmp.super-illu.de" always_null 
local-zone: "cmp.guter-rat.de" always_null 
local-zone: "cmp.holidaycheck" always_null 
local-zone: "cmp.jameda.de" always_null 
local-zone: "cmp.freizeitrevue.de" always_null 
local-zone: "cmp.lisa.de" always_null 
local-zone: "cmp.brandsyoulove.de" always_null 
local-zone: "cmp.burdastyle.de" always_null 
local-zone: "cmp.instyle.de" always_null 
local-zone: "cmp.computeruniverse.de" always_null 
local-zone: "cmp.cyberport.de" always_null 
local-zone: "cmp.daskochrezept.de" always_null 
local-zone: "cmp.mietwagen-check.de" always_null 
local-zone: "cmp.tvtoday.de" always_null 
local-zone: "cmp.zoover.de" always_null 
local-zone: "cmp.bestcheck.de" always_null 
local-zone: "cmp.netmoms.de" always_null 
local-zone: "cmp.finanzen100.de" always_null 
local-zone: "cmp.cardscout.de" always_null 
local-zone: "cmp.chip.de" always_null 
local-zone: "cmp.focus.de" always_null 
local-zone: "cmp.welt.de" always_null 
local-zone: "cmp.stern.de" always_null 
local-zone: "cmp.spiegel.de" always_null 
local-zone: "cmp.bild.de" always_null 
local-zone: "branded-story.amica.de" always_null 
local-zone: "branded-story.cinema.de" always_null 
local-zone: "branded-story.fitforfun.de" always_null 
local-zone: "branded-story.patientus.de" always_null 
local-zone: "branded-story.tvspielfilm.de" always_null 
local-zone: "branded-story.playboy.de" always_null 
local-zone: "branded-story.bunte.de" always_null 
local-zone: "branded-story.haus.de" always_null 
local-zone: "branded-story.elle.de" always_null 
local-zone: "branded-story.freundin.de" always_null 
local-zone: "branded-story.mein-schoener-garten.de" always_null 
local-zone: "branded-story.super-illu.de" always_null 
local-zone: "branded-story.guter-rat.de" always_null 
local-zone: "branded-story.holidaycheck" always_null 
local-zone: "branded-story.jameda.de" always_null 
local-zone: "branded-story.freizeitrevue.de" always_null 
local-zone: "branded-story.lisa.de" always_null 
local-zone: "branded-story.brandsyoulove.de" always_null 
local-zone: "branded-story.burdastyle.de" always_null 
local-zone: "branded-story.instyle.de" always_null 
local-zone: "branded-story.computeruniverse.de" always_null 
local-zone: "branded-story.cyberport.de" always_null 
local-zone: "branded-story.daskochrezept.de" always_null 
local-zone: "branded-story.mietwagen-check.de" always_null 
local-zone: "branded-story.tvtoday.de" always_null 
local-zone: "branded-story.zoover.de" always_null 
local-zone: "branded-story.bestcheck.de" always_null 
local-zone: "branded-story.netmoms.de" always_null 
local-zone: "branded-story.finanzen100.de" always_null 
local-zone: "branded-story.cardscout.de" always_null 
local-zone: "branded-story.chip.de" always_null 
local-zone: "branded-story.focus.de" always_null 
local-zone: "branded-story.welt.de" always_null 
local-zone: "branded-story.stern.de" always_null 
local-zone: "branded-story.spiegel.de" always_null 
local-zone: "branded-story.bild.de" always_null 
local-zone: "g.amica.de" always_null 
local-zone: "g.cinema.de" always_null 
local-zone: "g.fitforfun.de" always_null 
local-zone: "g.patientus.de" always_null 
local-zone: "g.tvspielfilm.de" always_null 
local-zone: "g.playboy.de" always_null 
local-zone: "g.bunte.de" always_null 
local-zone: "g.haus.de" always_null 
local-zone: "g.elle.de" always_null 
local-zone: "g.freundin.de" always_null 
local-zone: "g.mein-schoener-garten.de" always_null 
local-zone: "g.super-illu.de" always_null 
local-zone: "g.guter-rat.de" always_null 
local-zone: "g.holidaycheck" always_null 
local-zone: "g.jameda.de" always_null 
local-zone: "g.freizeitrevue.de" always_null 
local-zone: "g.lisa.de" always_null 
local-zone: "g.brandsyoulove.de" always_null 
local-zone: "g.burdastyle.de" always_null 
local-zone: "g.instyle.de" always_null 
local-zone: "g.computeruniverse.de" always_null 
local-zone: "g.cyberport.de" always_null 
local-zone: "g.daskochrezept.de" always_null 
local-zone: "g.mietwagen-check.de" always_null 
local-zone: "g.tvtoday.de" always_null 
local-zone: "g.zoover.de" always_null 
local-zone: "g.bestcheck.de" always_null 
local-zone: "g.netmoms.de" always_null 
local-zone: "g.finanzen100.de" always_null 
local-zone: "g.cardscout.de" always_null 
local-zone: "g.chip.de" always_null 
local-zone: "g.focus.de" always_null 
local-zone: "g.welt.de" always_null 
local-zone: "g.stern.de" always_null 
local-zone: "g.spiegel.de" always_null 
local-zone: "g.bild.de" always_null 
local-zone: "adtm.amica.de" always_null 
local-zone: "adtm.cinema.de" always_null 
local-zone: "adtm.fitforfun.de" always_null 
local-zone: "adtm.patientus.de" always_null 
local-zone: "adtm.tvspielfilm.de" always_null 
local-zone: "adtm.playboy.de" always_null 
local-zone: "adtm.bunte.de" always_null 
local-zone: "adtm.haus.de" always_null 
local-zone: "adtm.elle.de" always_null 
local-zone: "adtm.freundin.de" always_null 
local-zone: "adtm.mein-schoener-garten.de" always_null 
local-zone: "adtm.super-illu.de" always_null 
local-zone: "adtm.guter-rat.de" always_null 
local-zone: "adtm.holidaycheck" always_null 
local-zone: "adtm.jameda.de" always_null 
local-zone: "adtm.freizeitrevue.de" always_null 
local-zone: "adtm.lisa.de" always_null 
local-zone: "adtm.brandsyoulove.de" always_null 
local-zone: "adtm.burdastyle.de" always_null 
local-zone: "adtm.instyle.de" always_null 
local-zone: "adtm.computeruniverse.de" always_null 
local-zone: "adtm.cyberport.de" always_null 
local-zone: "adtm.daskochrezept.de" always_null 
local-zone: "adtm.mietwagen-check.de" always_null 
local-zone: "adtm.tvtoday.de" always_null 
local-zone: "adtm.zoover.de" always_null 
local-zone: "adtm.bestcheck.de" always_null 
local-zone: "adtm.netmoms.de" always_null 
local-zone: "adtm.finanzen100.de" always_null 
local-zone: "adtm.cardscout.de" always_null 
local-zone: "adtm.chip.de" always_null 
local-zone: "adtm.focus.de" always_null 
local-zone: "adtm.welt.de" always_null 
local-zone: "adtm.stern.de" always_null 
local-zone: "adtm.spiegel.de" always_null 
local-zone: "adtm.bild.de" always_null 
local-zone: "a.bf-tools.net" always_null
local-zone: "a.bf-ad.net" always_null

local-zone: "wt-safetag.com" always_null
local-zone: "googletagmanager.com" always_null
local-zone: "bf-ad.net" always_null
local-zone: "pf-ad.net" always_null
local-zone: "gstatic.com" always_null
local-zone: "chartbeat.com" always_null
local-zone: "ogp.me" always_null
local-zone: "1-1ads.com" always_null
local-zone: "101com.com" always_null
local-zone: "101order.com" always_null
local-zone: "123freeavatars.com" always_null
local-zone: "180hits.de" always_null
local-zone: "180searchassistant.com" always_null
local-zone: "1rx.io" always_null
local-zone: "207.net" always_null
local-zone: "247media.com" always_null
local-zone: "24log.com" always_null
local-zone: "24log.de" always_null
local-zone: "24pm-affiliation.com" always_null
local-zone: "2mdn.net" always_null
local-zone: "2o7.net" always_null
local-zone: "2znp09oa.com" always_null
local-zone: "30ads.com" always_null
local-zone: "3337723.com" always_null
local-zone: "33across.com" always_null
local-zone: "360yield.com" always_null
local-zone: "3lift.com" always_null
local-zone: "4affiliate.net" always_null
local-zone: "4d5.net" always_null
local-zone: "4info.com" always_null
local-zone: "4jnzhl0d0.com" always_null
local-zone: "50websads.com" always_null
local-zone: "518ad.com" always_null
local-zone: "5ijo.01net.com" always_null
local-zone: "5mcwl.pw" always_null
local-zone: "6ldu6qa.com" always_null
local-zone: "6sc.co" always_null
local-zone: "777partner.com" always_null
local-zone: "77tracking.com" always_null
local-zone: "7bpeople.com" always_null
local-zone: "7search.com" always_null
local-zone: "82o9v830.com" always_null
local-zone: "a-ads.com" always_null
local-zone: "a.aproductmsg.com" always_null
local-zone: "a.consumer.net" always_null
local-zone: "a.klaviyo.com" always_null
local-zone: "a.mktw.net" always_null
local-zone: "a.muloqot.uz" always_null
local-zone: "a.pub.network" always_null
local-zone: "a.sakh.com" always_null
local-zone: "a.ucoz.net" always_null
local-zone: "a.ucoz.ru" always_null
local-zone: "a.vartoken.com" always_null
local-zone: "a.vfghd.com" always_null
local-zone: "a.vfgtb.com" always_null
local-zone: "a.xanga.com" always_null
local-zone: "a135.wftv.com" always_null
local-zone: "a5.overclockers.ua" always_null
local-zone: "a8a8altrk.com" always_null
local-zone: "aa-metrics.beauty.hotpepper.jp" always_null
local-zone: "aa-metrics.recruit-card.jp" always_null
local-zone: "aa-metrics.trip-ai.jp" always_null
local-zone: "aaddzz.com" always_null
local-zone: "aax-eu-dub.amazon.com" always_null
local-zone: "aaxads.com" always_null
local-zone: "aaxdetect.com" always_null
local-zone: "abacho.net" always_null
local-zone: "abackchain.com" always_null
local-zone: "abandonedaction.com" always_null
local-zone: "abc-ads.com" always_null
local-zone: "ablink.comms.trainline.com" always_null
local-zone: "aboardlevel.com" always_null
local-zone: "aboutads.gr" always_null
local-zone: "abruptroad.com" always_null
local-zone: "absentstream.com" always_null
local-zone: "absoluteclickscom.com" always_null
local-zone: "absorbingband.com" always_null
local-zone: "abstractedauthority.com" always_null
local-zone: "absurdwater.com" always_null
local-zone: "abtasty.com" always_null
local-zone: "abz.com" always_null
local-zone: "ac.rnm.ca" always_null
local-zone: "acbsearch.com" always_null
local-zone: "acceptable.a-ads.com" always_null
local-zone: "acid-adserver.click" always_null
local-zone: "acridtwist.com" always_null
local-zone: "actionsplash.com" always_null
local-zone: "actonsoftware.com" always_null
local-zone: "actualdeals.com" always_null
local-zone: "actuallysheep.com" always_null
local-zone: "actuallysnake.com" always_null
local-zone: "acuityads.com" always_null
local-zone: "acuityplatform.com" always_null
local-zone: "ad-balancer.at" always_null
local-zone: "ad-balancer.net" always_null
local-zone: "ad-cupid.com" always_null
local-zone: "ad-delivery.net" always_null
local-zone: "ad-pay.de" always_null
local-zone: "ad-rotator.com" always_null
local-zone: "ad-score.com" always_null
local-zone: "ad-server.gulasidorna.se" always_null
local-zone: "ad-space.net" always_null
local-zone: "ad-tech.com" always_null
local-zone: "ad-up.com" always_null
local-zone: "ad.71i.de" always_null
local-zone: "ad.a-ads.com" always_null
local-zone: "ad.a8.net" always_null
local-zone: "ad.abcnews.com" always_null
local-zone: "ad.abctv.com" always_null
local-zone: "ad.aboutwebservices.com" always_null
local-zone: "ad.abum.com" always_null
local-zone: "ad.admitad.com" always_null
local-zone: "ad.allboxing.ru" always_null
local-zone: "ad.allstar.cz" always_null
local-zone: "ad.altervista.org" always_null
local-zone: "ad.amgdgt.com" always_null
local-zone: "ad.anuntis.com" always_null
local-zone: "ad.auditude.com" always_null
local-zone: "ad.bitmedia.io" always_null
local-zone: "ad.bizo.com" always_null
local-zone: "ad.bnmla.com" always_null
local-zone: "ad.bondage.com" always_null
local-zone: "ad.caradisiac.com" always_null
local-zone: "ad.centrum.cz" always_null
local-zone: "ad.cgi.cz" always_null
local-zone: "ad.choiceradio.com" always_null
local-zone: "ad.clix.pt" always_null
local-zone: "ad.cooks.com" always_null
local-zone: "ad.digitallook.com" always_null
local-zone: "ad.domainfactory.de" always_null
local-zone: "ad.eurosport.com" always_null
local-zone: "ad.exyws.org" always_null
local-zone: "ad.flurry.com" always_null
local-zone: "ad.foxnetworks.com" always_null
local-zone: "ad.grafika.cz" always_null
local-zone: "ad.gt" always_null
local-zone: "ad.hbv.de" always_null
local-zone: "ad.hodomobile.com" always_null
local-zone: "ad.hyena.cz" always_null
local-zone: "ad.iinfo.cz" always_null
local-zone: "ad.infoseek.com" always_null
local-zone: "ad.intl.xiaomi.com" always_null
local-zone: "ad.jacotei.com.br" always_null
local-zone: "ad.jetsoftware.com" always_null
local-zone: "ad.keenspace.com" always_null
local-zone: "ad.liveinternet.ru" always_null
local-zone: "ad.lupa.cz" always_null
local-zone: "ad.media-servers.net" always_null
local-zone: "ad.mediastorm.hu" always_null
local-zone: "ad.mg" always_null
local-zone: "ad.mobstazinc.cn" always_null
local-zone: "ad.musicmatch.com" always_null
local-zone: "ad.myapple.pl" always_null
local-zone: "ad.mynetreklam.com.streamprovider.net" always_null
local-zone: "ad.nachtagenten.de" always_null
local-zone: "ad.nozonedata.com" always_null
local-zone: "ad.nttnavi.co.jp" always_null
local-zone: "ad.nwt.cz" always_null
local-zone: "ad.pandora.tv" always_null
local-zone: "ad.period-calendar.com" always_null
local-zone: "ad.preferances.com" always_null
local-zone: "ad.profiwin.de" always_null
local-zone: "ad.prv.pl" always_null
local-zone: "ad.sensismediasmart.com.au" always_null
local-zone: "ad.simflight.com" always_null
local-zone: "ad.simgames.net" always_null
local-zone: "ad.style" always_null
local-zone: "ad.tapthislink.com" always_null
local-zone: "ad.technoratimedia.com" always_null
local-zone: "ad.turn.com" always_null
local-zone: "ad.tv2.no" always_null
local-zone: "ad.universcine.com" always_null
local-zone: "ad.usatoday.com" always_null
local-zone: "ad.virtual-nights.com" always_null
local-zone: "ad.wavu.hu" always_null
local-zone: "ad.weatherbug.com" always_null
local-zone: "ad.wsod.com" always_null
local-zone: "ad.wz.cz" always_null
local-zone: "ad.xiaomi.com" always_null
local-zone: "ad.xmovies8.si" always_null
local-zone: "ad.xrea.com" always_null
local-zone: "ad.yadro.ru" always_null
local-zone: "ad.zanox.com" always_null
local-zone: "ad.ztylez.com" always_null
local-zone: "ad0.bigmir.net" always_null
local-zone: "ad01.mediacorpsingapore.com" always_null
local-zone: "ad1.emule-project.org" always_null
local-zone: "ad1.eventmanager.co.kr" always_null
local-zone: "ad1.kde.cz" always_null
local-zone: "ad1.pamedia.com.au" always_null
local-zone: "ad2.iinfo.cz" always_null
local-zone: "ad2.lupa.cz" always_null
local-zone: "ad2.netriota.hu" always_null
local-zone: "ad2.nmm.de" always_null
local-zone: "ad2.xrea.com" always_null
local-zone: "ad3.iinfo.cz" always_null
local-zone: "ad3.pamedia.com.au" always_null
local-zone: "ad3.xrea.com" always_null
local-zone: "ad4game.com" always_null
local-zone: "ad4mat.com" always_null
local-zone: "ad4mat.de" always_null
local-zone: "ad4mat.net" always_null
local-zone: "adabra.com" always_null
local-zone: "adaction.de" always_null
local-zone: "adadvisor.net" always_null
local-zone: "adalliance.io" always_null
local-zone: "adap.tv" always_null
local-zone: "adapt.tv" always_null
local-zone: "adaranth.com" always_null
local-zone: "adbilty.me" always_null
local-zone: "adblade.com" always_null
local-zone: "adblade.org" always_null
local-zone: "adblockanalytics.com" always_null
local-zone: "adbooth.net" always_null
local-zone: "adbot.com" always_null
local-zone: "adbrite.com" always_null
local-zone: "adbrn.com" always_null
local-zone: "adbroker.de" always_null
local-zone: "adbunker.com" always_null
local-zone: "adbutler.com" always_null
local-zone: "adbuyer.com" always_null
local-zone: "adbuyer3.lycos.com" always_null
local-zone: "adcampo.com" always_null
local-zone: "adcannyads.com" always_null
local-zone: "adcash.com" always_null
local-zone: "adcast.deviantart.com" always_null
local-zone: "adcell.de" always_null
local-zone: "adcenter.net" always_null
local-zone: "adcentriconline.com" always_null
local-zone: "adclick.com" always_null
local-zone: "adclient1.tucows.com" always_null
local-zone: "adcolony.com" always_null
local-zone: "adcomplete.com" always_null
local-zone: "adconion.com" always_null
local-zone: "adcontent.gamespy.com" always_null
local-zone: "adcontrolsolutions.net" always_null
local-zone: "adcycle.com" always_null
local-zone: "add.newmedia.cz" always_null
local-zone: "addfreestats.com" always_null
local-zone: "addme.com" always_null
local-zone: "adecn.com" always_null
local-zone: "adeimptrck.com" always_null
local-zone: "ademails.com" always_null
local-zone: "adengage.com" always_null
local-zone: "adetracking.com" always_null
local-zone: "adexc.net" always_null
local-zone: "adexchangegate.com" always_null
local-zone: "adexchangeprediction.com" always_null
local-zone: "adexpose.com" always_null
local-zone: "adext.inkclub.com" always_null
local-zone: "adf.ly" always_null
local-zone: "adflight.com" always_null
local-zone: "adforce.com" always_null
local-zone: "adform.com" always_null
local-zone: "adform.net" always_null
local-zone: "adformdsp.net" always_null
local-zone: "adfs.senacrs.com.br" always_null
local-zone: "adgardener.com" always_null
local-zone: "adgoto.com" always_null
local-zone: "adhaven.com" always_null
local-zone: "adhese.be" always_null
local-zone: "adhese.com" always_null
local-zone: "adhigh.net" always_null
local-zone: "adhoc4.net" always_null
local-zone: "adhunter.media" always_null
local-zone: "adimage.guardian.co.uk" always_null
local-zone: "adimages.been.com" always_null
local-zone: "adimages.carsoup.com" always_null
local-zone: "adimages.go.com" always_null
local-zone: "adimages.homestore.com" always_null
local-zone: "adimages.omroepzeeland.nl" always_null
local-zone: "adimages.sanomawsoy.fi" always_null
local-zone: "adimg.com.com" always_null
local-zone: "adimg.uimserv.net" always_null
local-zone: "adimg1.chosun.com" always_null
local-zone: "adimgs.sapo.pt" always_null
local-zone: "adingo.jp" always_null
local-zone: "adinjector.net" always_null
local-zone: "adinterax.com" always_null
local-zone: "adisfy.com" always_null
local-zone: "adition.com" always_null
local-zone: "adition.de" always_null
local-zone: "adition.net" always_null
local-zone: "adizio.com" always_null
local-zone: "adjix.com" always_null
local-zone: "adjug.com" always_null
local-zone: "adjuggler.com" always_null
local-zone: "adjuggler.yourdictionary.com" always_null
local-zone: "adjust.com" always_null
local-zone: "adjustnetwork.com" always_null
local-zone: "adk2.co" always_null
local-zone: "adk2.com" always_null
local-zone: "adland.ru" always_null
local-zone: "adledge.com" always_null
local-zone: "adlegend.com" always_null
local-zone: "adlightning.com" always_null
local-zone: "adlog.com.com" always_null
local-zone: "adloox.com" always_null
local-zone: "adlooxtracking.com" always_null
local-zone: "adlure.net" always_null
local-zone: "adm.fwmrm.net" always_null
local-zone: "admagnet.net" always_null
local-zone: "admailtiser.com" always_null
local-zone: "adman.gr" always_null
local-zone: "adman.otenet.gr" always_null
local-zone: "admanagement.ch" always_null
local-zone: "admanager.btopenworld.com" always_null
local-zone: "admanager.carsoup.com" always_null
local-zone: "admanmedia.com" always_null
local-zone: "admantx.com" always_null
local-zone: "admarketplace.net" always_null
local-zone: "admarvel.com" always_null
local-zone: "admaster.com.cn" always_null
local-zone: "admatchly.com" always_null
local-zone: "admax.nexage.com" always_null
local-zone: "admedia.com" always_null
local-zone: "admeld.com" always_null
local-zone: "admeridianads.com" always_null
local-zone: "admeta.com" always_null
local-zone: "admex.com" always_null
local-zone: "admidadsp.com" always_null
local-zone: "adminder.com" always_null
local-zone: "adminshop.com" always_null
local-zone: "admix.in" always_null
local-zone: "admixer.net" always_null
local-zone: "admized.com" always_null
local-zone: "admob.com" always_null
local-zone: "admonitor.com" always_null
local-zone: "admotion.com.ar" always_null
local-zone: "adn.lrb.co.uk" always_null
local-zone: "adnet.asahi.com" always_null
local-zone: "adnet.biz" always_null
local-zone: "adnet.de" always_null
local-zone: "adnet.ru" always_null
local-zone: "adnetinteractive.com" always_null
local-zone: "adnetwork.net" always_null
local-zone: "adnetworkperformance.com" always_null
local-zone: "adnews.maddog2000.de" always_null
local-zone: "adnium.com" always_null
local-zone: "adnxs-simple.com" always_null
local-zone: "adnxs.com" always_null
local-zone: "adocean.pl" always_null
local-zone: "adonspot.com" always_null
local-zone: "adoptum.net" always_null
local-zone: "adoric-om.com" always_null
local-zone: "adorigin.com" always_null
local-zone: "adotmob.com" always_null
local-zone: "adpenguin.biz" always_null
local-zone: "adpepper.dk" always_null
local-zone: "adpepper.nl" always_null
local-zone: "adperium.com" always_null
local-zone: "adpia.vn" always_null
local-zone: "adplus.co.id" always_null
local-zone: "adplxmd.com" always_null
local-zone: "adprofits.ru" always_null
local-zone: "adpushup.com" always_null
local-zone: "adrazzi.com" always_null
local-zone: "adreactor.com" always_null
local-zone: "adreclaim.com" always_null
local-zone: "adrecover.com" always_null
local-zone: "adrecreate.com" always_null
local-zone: "adremedy.com" always_null
local-zone: "adreporting.com" always_null
local-zone: "adrevolver.com" always_null
local-zone: "adriver.ru" always_null
local-zone: "adrolays.de" always_null
local-zone: "adrotate.de" always_null
local-zone: "adrotic.girlonthenet.com" always_null
local-zone: "adrta.com" always_null
local-zone: "ads-click.com" always_null
local-zone: "ads-dev.pinterest.com" always_null
local-zone: "ads-game-187f4.firebaseapp.com" always_null
local-zone: "ads-kesselhaus.com" always_null
local-zone: "ads-trk.vidible.tv" always_null
local-zone: "ads-twitter.com" always_null
local-zone: "ads.365.mk" always_null
local-zone: "ads.4tube.com" always_null
local-zone: "ads.5ci.lt" always_null
local-zone: "ads.5min.at" always_null
local-zone: "ads.73dpi.com" always_null
local-zone: "ads.a-snag-smartmoney.fyi" always_null
local-zone: "ads.aavv.com" always_null
local-zone: "ads.abovetopsecret.com" always_null
local-zone: "ads.aceweb.net" always_null
local-zone: "ads.acpc.cat" always_null
local-zone: "ads.acrosspf.com" always_null
local-zone: "ads.activestate.com" always_null
local-zone: "ads.ad-center.com" always_null
local-zone: "ads.adfox.ru" always_null
local-zone: "ads.administrator.de" always_null
local-zone: "ads.adred.de" always_null
local-zone: "ads.adstream.com.ro" always_null
local-zone: "ads.adultfriendfinder.com" always_null
local-zone: "ads.advance.net" always_null
local-zone: "ads.adverline.com" always_null
local-zone: "ads.affiliates.match.com" always_null
local-zone: "ads.alive.com" always_null
local-zone: "ads.alt.com" always_null
local-zone: "ads.amdmb.com" always_null
local-zone: "ads.amigos.com" always_null
local-zone: "ads.annabac.com" always_null
local-zone: "ads.aol.co.uk" always_null
local-zone: "ads.apn.co.nz" always_null
local-zone: "ads.appsgeyser.com" always_null
local-zone: "ads.apteka254.ru" always_null
local-zone: "ads.as4x.tmcs.net" always_null
local-zone: "ads.as4x.tmcs.ticketmaster.com" always_null
local-zone: "ads.asiafriendfinder.com" always_null
local-zone: "ads.aspalliance.com" always_null
local-zone: "ads.avazu.net" always_null
local-zone: "ads.bb59.ru" always_null
local-zone: "ads.belointeractive.com" always_null
local-zone: "ads.betfair.com" always_null
local-zone: "ads.bigchurch.com" always_null
local-zone: "ads.bigfoot.com" always_null
local-zone: "ads.bing.com" always_null
local-zone: "ads.bittorrent.com" always_null
local-zone: "ads.blog.com" always_null
local-zone: "ads.bloomberg.com" always_null
local-zone: "ads.bluemountain.com" always_null
local-zone: "ads.boerding.com" always_null
local-zone: "ads.boylesports.com" always_null
local-zone: "ads.brabys.com" always_null
local-zone: "ads.brazzers.com" always_null
local-zone: "ads.bumq.com" always_null
local-zone: "ads.businessweek.com" always_null
local-zone: "ads.canalblog.com" always_null
local-zone: "ads.casinocity.com" always_null
local-zone: "ads.casumoaffiliates.com" always_null
local-zone: "ads.cbc.ca" always_null
local-zone: "ads.cc" always_null
local-zone: "ads.cc-dt.com" always_null
local-zone: "ads.centraliprom.com" always_null
local-zone: "ads.channel4.com" always_null
local-zone: "ads.cheabit.com" always_null
local-zone: "ads.citymagazine.si" always_null
local-zone: "ads.clasificadox.com" always_null
local-zone: "ads.co.com" always_null
local-zone: "ads.colombiaonline.com" always_null
local-zone: "ads.com.com" always_null
local-zone: "ads.comeon.com" always_null
local-zone: "ads.contactmusic.com" always_null
local-zone: "ads.contentabc.com" always_null
local-zone: "ads.contextweb.com" always_null
local-zone: "ads.crakmedia.com" always_null
local-zone: "ads.creative-serving.com" always_null
local-zone: "ads.cybersales.cz" always_null
local-zone: "ads.dada.it" always_null
local-zone: "ads.dailycamera.com" always_null
local-zone: "ads.datingyes.com" always_null
local-zone: "ads.delfin.bg" always_null
local-zone: "ads.deltha.hu" always_null
local-zone: "ads.dennisnet.co.uk" always_null
local-zone: "ads.desmoinesregister.com" always_null
local-zone: "ads.detelefoongids.nl" always_null
local-zone: "ads.deviantart.com" always_null
local-zone: "ads.devmates.com" always_null
local-zone: "ads.digital-digest.com" always_null
local-zone: "ads.digitalmedianet.com" always_null
local-zone: "ads.digitalpoint.com" always_null
local-zone: "ads.directionsmag.com" always_null
local-zone: "ads.doit.com.cn" always_null
local-zone: "ads.domeus.com" always_null
local-zone: "ads.dtpnetwork.biz" always_null
local-zone: "ads.eagletribune.com" always_null
local-zone: "ads.easy-forex.com" always_null
local-zone: "ads.economist.com" always_null
local-zone: "ads.edbindex.dk" always_null
local-zone: "ads.egrana.com.br" always_null
local-zone: "ads.elcarado.com" always_null
local-zone: "ads.electrocelt.com" always_null
local-zone: "ads.elitetrader.com" always_null
local-zone: "ads.emdee.ca" always_null
local-zone: "ads.emirates.net.ae" always_null
local-zone: "ads.epi.sk" always_null
local-zone: "ads.epltalk.com" always_null
local-zone: "ads.eu.msn.com" always_null
local-zone: "ads.exactdrive.com" always_null
local-zone: "ads.expat-blog.biz" always_null
local-zone: "ads.fairfax.com.au" always_null
local-zone: "ads.fastcomgroup.it" always_null
local-zone: "ads.fasttrack-ignite.com" always_null
local-zone: "ads.faxo.com" always_null
local-zone: "ads.femmefab.nl" always_null
local-zone: "ads.ferianc.com" always_null
local-zone: "ads.filmup.com" always_null
local-zone: "ads.financialcontent.com" always_null
local-zone: "ads.flooble.com" always_null
local-zone: "ads.fool.com" always_null
local-zone: "ads.footymad.net" always_null
local-zone: "ads.forbes.net" always_null
local-zone: "ads.formit.cz" always_null
local-zone: "ads.fortunecity.com" always_null
local-zone: "ads.fotosidan.se" always_null
local-zone: "ads.foxnetworks.com" always_null
local-zone: "ads.friendfinder.com" always_null
local-zone: "ads.gamecity.net" always_null
local-zone: "ads.gamershell.com" always_null
local-zone: "ads.gamespyid.com" always_null
local-zone: "ads.gamigo.de" always_null
local-zone: "ads.gaming-universe.de" always_null
local-zone: "ads.gaming1.com" always_null
local-zone: "ads.gaypoint.hu" always_null
local-zone: "ads.getlucky.com" always_null
local-zone: "ads.gld.dk" always_null
local-zone: "ads.gmodules.com" always_null
local-zone: "ads.goyk.com" always_null
local-zone: "ads.gplusmedia.com" always_null
local-zone: "ads.gradfinder.com" always_null
local-zone: "ads.grindinggears.com" always_null
local-zone: "ads.groupewin.fr" always_null
local-zone: "ads.gsm-exchange.com" always_null
local-zone: "ads.gsmexchange.com" always_null
local-zone: "ads.guardian.co.uk" always_null
local-zone: "ads.guardianunlimited.co.uk" always_null
local-zone: "ads.guru3d.com" always_null
local-zone: "ads.harpers.org" always_null
local-zone: "ads.hbv.de" always_null
local-zone: "ads.hearstmags.com" always_null
local-zone: "ads.heartlight.org" always_null
local-zone: "ads.heias.com" always_null
local-zone: "ads.hollywood.com" always_null
local-zone: "ads.horsehero.com" always_null
local-zone: "ads.horyzon-media.com" always_null
local-zone: "ads.hsoub.com" always_null
local-zone: "ads.ibest.com.br" always_null
local-zone: "ads.ibryte.com" always_null
local-zone: "ads.icq.com" always_null
local-zone: "ads.ign.com" always_null
local-zone: "ads.imagistica.com" always_null
local-zone: "ads.img.co.za" always_null
local-zone: "ads.imgur.com" always_null
local-zone: "ads.independent.com.mt" always_null
local-zone: "ads.infi.net" always_null
local-zone: "ads.internic.co.il" always_null
local-zone: "ads.ipowerweb.com" always_null
local-zone: "ads.isoftmarketing.com" always_null
local-zone: "ads.itv.com" always_null
local-zone: "ads.iwon.com" always_null
local-zone: "ads.jewishfriendfinder.com" always_null
local-zone: "ads.jiwire.com" always_null
local-zone: "ads.joaffs.com" always_null
local-zone: "ads.jobsite.co.uk" always_null
local-zone: "ads.jpost.com" always_null
local-zone: "ads.junctionbox.com" always_null
local-zone: "ads.justhungry.com" always_null
local-zone: "ads.kabooaffiliates.com" always_null
local-zone: "ads.kaktuz.net" always_null
local-zone: "ads.kelbymediagroup.com" always_null
local-zone: "ads.kinobox.cz" always_null
local-zone: "ads.kinxxx.com" always_null
local-zone: "ads.kompass.com" always_null
local-zone: "ads.krawall.de" always_null
local-zone: "ads.lapalingo.com" always_null
local-zone: "ads.leovegas.com" always_null
local-zone: "ads.lesbianpersonals.com" always_null
local-zone: "ads.liberte.pl" always_null
local-zone: "ads.lifethink.net" always_null
local-zone: "ads.linkedin.com" always_null
local-zone: "ads.livenation.com" always_null
local-zone: "ads.lordlucky.com" always_null
local-zone: "ads.ma7.tv" always_null
local-zone: "ads.mail.bg" always_null
local-zone: "ads.mariuana.it" always_null
local-zone: "ads.massinfra.nl" always_null
local-zone: "ads.mcafee.com" always_null
local-zone: "ads.mediaodyssey.com" always_null
local-zone: "ads.mediasmart.es" always_null
local-zone: "ads.medienhaus.de" always_null
local-zone: "ads.meetcelebs.com" always_null
local-zone: "ads.mgnetwork.com" always_null
local-zone: "ads.miarroba.com" always_null
local-zone: "ads.mic.com" always_null
local-zone: "ads.mmania.com" always_null
local-zone: "ads.mobilebet.com" always_null
local-zone: "ads.mopub.com" always_null
local-zone: "ads.motor-forum.nl" always_null
local-zone: "ads.msn.com" always_null
local-zone: "ads.multimania.lycos.fr" always_null
local-zone: "ads.muslimehelfen.org" always_null
local-zone: "ads.mvscoelho.com" always_null
local-zone: "ads.myadv.org" always_null
local-zone: "ads.nccwebs.com" always_null
local-zone: "ads.ncm.com" always_null
local-zone: "ads.ndtv1.com" always_null
local-zone: "ads.networksolutions.com" always_null
local-zone: "ads.newgrounds.com" always_null
local-zone: "ads.newmedia.cz" always_null
local-zone: "ads.newsint.co.uk" always_null
local-zone: "ads.newsquest.co.uk" always_null
local-zone: "ads.ninemsn.com.au" always_null
local-zone: "ads.nj.com" always_null
local-zone: "ads.nola.com" always_null
local-zone: "ads.nordichardware.com" always_null
local-zone: "ads.nordichardware.se" always_null
local-zone: "ads.nyi.net" always_null
local-zone: "ads.nytimes.com" always_null
local-zone: "ads.nyx.cz" always_null
local-zone: "ads.nzcity.co.nz" always_null
local-zone: "ads.o2.pl" always_null
local-zone: "ads.oddschecker.com" always_null
local-zone: "ads.okcimg.com" always_null
local-zone: "ads.ole.com" always_null
local-zone: "ads.oneplace.com" always_null
local-zone: "ads.opensubtitles.org" always_null
local-zone: "ads.optusnet.com.au" always_null
local-zone: "ads.outpersonals.com" always_null
local-zone: "ads.oxyshop.cz" always_null
local-zone: "ads.passion.com" always_null
local-zone: "ads.paymonex.net" always_null
local-zone: "ads.pennet.com" always_null
local-zone: "ads.pexi.nl" always_null
local-zone: "ads.pfl.ua" always_null
local-zone: "ads.phpclasses.org" always_null
local-zone: "ads.pinterest.com" always_null
local-zone: "ads.planet.nl" always_null
local-zone: "ads.pni.com" always_null
local-zone: "ads.pof.com" always_null
local-zone: "ads.powweb.com" always_null
local-zone: "ads.ppvmedien.de" always_null
local-zone: "ads.praguetv.cz" always_null
local-zone: "ads.primissima.it" always_null
local-zone: "ads.printscr.com" always_null
local-zone: "ads.prisacom.com" always_null
local-zone: "ads.privatemedia.co" always_null
local-zone: "ads.program3.com" always_null
local-zone: "ads.programattik.com" always_null
local-zone: "ads.psd2html.com" always_null
local-zone: "ads.pushplay.com" always_null
local-zone: "ads.quasaraffiliates.com" always_null
local-zone: "ads.quoka.de" always_null
local-zone: "ads.radialserver.com" always_null
local-zone: "ads.radio1.lv" always_null
local-zone: "ads.rcncdn.de" always_null
local-zone: "ads.rcs.it" always_null
local-zone: "ads.recoletos.es" always_null
local-zone: "ads.rediff.com" always_null
local-zone: "ads.redlightcenter.com" always_null
local-zone: "ads.revjet.com" always_null
local-zone: "ads.saymedia.com" always_null
local-zone: "ads.schmoozecom.net" always_null
local-zone: "ads.scifi.com" always_null
local-zone: "ads.seniorfriendfinder.com" always_null
local-zone: "ads.servebom.com" always_null
local-zone: "ads.sexgratuit.tv" always_null
local-zone: "ads.sexinyourcity.com" always_null
local-zone: "ads.shizmoo.com" always_null
local-zone: "ads.shopstyle.com" always_null
local-zone: "ads.sift.co.uk" always_null
local-zone: "ads.silverdisc.co.uk" always_null
local-zone: "ads.simplyhired.com" always_null
local-zone: "ads.sjon.info" always_null
local-zone: "ads.smartclick.com" always_null
local-zone: "ads.socapro.com" always_null
local-zone: "ads.socialtheater.com" always_null
local-zone: "ads.soft32.com" always_null
local-zone: "ads.soweb.gr" always_null
local-zone: "ads.space.com" always_null
local-zone: "ads.stackoverflow.com" always_null
local-zone: "ads.sun.com" always_null
local-zone: "ads.suomiautomaatti.com" always_null
local-zone: "ads.supplyframe.com" always_null
local-zone: "ads.syscdn.de" always_null
local-zone: "ads.tahono.com" always_null
local-zone: "ads.themovienation.com" always_null
local-zone: "ads.thestar.com" always_null
local-zone: "ads.thrillsaffiliates.com" always_null
local-zone: "ads.tiktok.com" always_null
local-zone: "ads.tmcs.net" always_null
local-zone: "ads.todoti.com.br" always_null
local-zone: "ads.toplayaffiliates.com" always_null
local-zone: "ads.totallyfreestuff.com" always_null
local-zone: "ads.townhall.com" always_null
local-zone: "ads.travelaudience.com" always_null
local-zone: "ads.tremorhub.com" always_null
local-zone: "ads.trinitymirror.co.uk" always_null
local-zone: "ads.tripod.com" always_null
local-zone: "ads.tripod.lycos.co.uk" always_null
local-zone: "ads.tripod.lycos.de" always_null
local-zone: "ads.tripod.lycos.es" always_null
local-zone: "ads.tripod.lycos.it" always_null
local-zone: "ads.tripod.lycos.nl" always_null
local-zone: "ads.tso.dennisnet.co.uk" always_null
local-zone: "ads.twitter.com" always_null
local-zone: "ads.twojatv.info" always_null
local-zone: "ads.uknetguide.co.uk" always_null
local-zone: "ads.ultimate-guitar.com" always_null
local-zone: "ads.uncrate.com" always_null
local-zone: "ads.undertone.com" always_null
local-zone: "ads.unison.bg" always_null
local-zone: "ads.usatoday.com" always_null
local-zone: "ads.uxs.at" always_null
local-zone: "ads.v-lazer.com" always_null
local-zone: "ads.verticalresponse.com" always_null
local-zone: "ads.vgchartz.com" always_null
local-zone: "ads.videosz.com" always_null
local-zone: "ads.virtual-nights.com" always_null
local-zone: "ads.virtuopolitan.com" always_null
local-zone: "ads.vnumedia.com" always_null
local-zone: "ads.walkiberia.com" always_null
local-zone: "ads.waps.cn" always_null
local-zone: "ads.wapx.cn" always_null
local-zone: "ads.watson.ch" always_null
local-zone: "ads.weather.ca" always_null
local-zone: "ads.web.de" always_null
local-zone: "ads.webinak.sk" always_null
local-zone: "ads.webmasterpoint.org" always_null
local-zone: "ads.websiteservices.com" always_null
local-zone: "ads.whoishostingthis.com" always_null
local-zone: "ads.wiezoekje.nl" always_null
local-zone: "ads.wikia.nocookie.net" always_null
local-zone: "ads.wineenthusiast.com" always_null
local-zone: "ads.wwe.biz" always_null
local-zone: "ads.xhamster.com" always_null
local-zone: "ads.xtra.co.nz" always_null
local-zone: "ads.yahoo.com" always_null
local-zone: "ads.yap.yahoo.com" always_null
local-zone: "ads.yimg.com" always_null
local-zone: "ads.yldmgrimg.net" always_null
local-zone: "ads.yourfreedvds.com" always_null
local-zone: "ads.youtube.com" always_null
local-zone: "ads.yumenetworks.com" always_null
local-zone: "ads.zmarsa.com" always_null
local-zone: "ads1-adnow.com" always_null
local-zone: "ads1.mediacapital.pt" always_null
local-zone: "ads1.msn.com" always_null
local-zone: "ads1.rne.com" always_null
local-zone: "ads1.virtual-nights.com" always_null
local-zone: "ads10.speedbit.com" always_null
local-zone: "ads180.com" always_null
local-zone: "ads2.brazzers.com" always_null
local-zone: "ads2.clearchannel.com" always_null
local-zone: "ads2.contentabc.com" always_null
local-zone: "ads2.femmefab.nl" always_null
local-zone: "ads2.gamecity.net" always_null
local-zone: "ads2.hsoub.com" always_null
local-zone: "ads2.net-communities.co.uk" always_null
local-zone: "ads2.oneplace.com" always_null
local-zone: "ads2.rne.com" always_null
local-zone: "ads2.techads.info" always_null
local-zone: "ads2.virtual-nights.com" always_null
local-zone: "ads2.webdrive.no" always_null
local-zone: "ads2.xnet.cz" always_null
local-zone: "ads2004.treiberupdate.de" always_null
local-zone: "ads24h.net" always_null
local-zone: "ads3-adnow.com" always_null
local-zone: "ads3.contentabc.com" always_null
local-zone: "ads3.gamecity.net" always_null
local-zone: "ads3.virtual-nights.com" always_null
local-zone: "ads4.gamecity.net" always_null
local-zone: "ads4.virtual-nights.com" always_null
local-zone: "ads4homes.com" always_null
local-zone: "ads5.virtual-nights.com" always_null
local-zone: "ads6.gamecity.net" always_null
local-zone: "ads7.gamecity.net" always_null
local-zone: "adsafeprotected.com" always_null
local-zone: "adsatt.abc.starwave.com" always_null
local-zone: "adsatt.abcnews.starwave.com" always_null
local-zone: "adsatt.espn.go.com" always_null
local-zone: "adsatt.espn.starwave.com" always_null
local-zone: "adsatt.go.starwave.com" always_null
local-zone: "adsby.bidtheatre.com" always_null
local-zone: "adsbydelema.com" always_null
local-zone: "adscale.de" always_null
local-zone: "adscholar.com" always_null
local-zone: "adscience.nl" always_null
local-zone: "adsco.re" always_null
local-zone: "adscpm.com" always_null
local-zone: "adsdaq.com" always_null
local-zone: "adsdk.yandex.ru" always_null
local-zone: "adsend.de" always_null
local-zone: "adsensecustomsearchads.com" always_null
local-zone: "adserve.ams.rhythmxchange.com" always_null
local-zone: "adserve.gkeurope.de" always_null
local-zone: "adserve.io" always_null
local-zone: "adserve.jbs.org" always_null
local-zone: "adserver.71i.de" always_null
local-zone: "adserver.adultfriendfinder.com" always_null
local-zone: "adserver.adverty.com" always_null
local-zone: "adserver.anawe.cz" always_null
local-zone: "adserver.aol.fr" always_null
local-zone: "adserver.ariase.org" always_null
local-zone: "adserver.bdoce.cl" always_null
local-zone: "adserver.betandwin.de" always_null
local-zone: "adserver.bing.com" always_null
local-zone: "adserver.bizedge.com" always_null
local-zone: "adserver.bizhat.com" always_null
local-zone: "adserver.break-even.it" always_null
local-zone: "adserver.cams.com" always_null
local-zone: "adserver.cdnstream.com" always_null
local-zone: "adserver.com" always_null
local-zone: "adserver.diariodosertao.com.br" always_null
local-zone: "adserver.digitoday.com" always_null
local-zone: "adserver.echdk.pl" always_null
local-zone: "adserver.ekokatu.com" always_null
local-zone: "adserver.friendfinder.com" always_null
local-zone: "adserver.generationiron.com" always_null
local-zone: "adserver.gilligan.tech" always_null
local-zone: "adserver.html.it" always_null
local-zone: "adserver.hwupgrade.it" always_null
local-zone: "adserver.ilango.de" always_null
local-zone: "adserver.info7.mx" always_null
local-zone: "adserver.irishwebmasterforum.com" always_null
local-zone: "adserver.janes.com" always_null
local-zone: "adserver.lecool.com" always_null
local-zone: "adserver.libero.it" always_null
local-zone: "adserver.mobi" always_null
local-zone: "adserver.msmb.biz" always_null
local-zone: "adserver.news.com.au" always_null
local-zone: "adserver.nydailynews.com" always_null
local-zone: "adserver.o2.pl" always_null
local-zone: "adserver.oddschecker.com" always_null
local-zone: "adserver.omroepzeeland.nl" always_null
local-zone: "adserver.otthonom.hu" always_null
local-zone: "adserver.pampa.com.br" always_null
local-zone: "adserver.pl" always_null
local-zone: "adserver.portugalmail.net" always_null
local-zone: "adserver.pressboard.ca" always_null
local-zone: "adserver.sanomawsoy.fi" always_null
local-zone: "adserver.sciflicks.com" always_null
local-zone: "adserver.scr.sk" always_null
local-zone: "adserver.smgfiles.com" always_null
local-zone: "adserver.theonering.net" always_null
local-zone: "adserver.trojaner-info.de" always_null
local-zone: "adserver.tupolska.com" always_null
local-zone: "adserver.twitpic.com" always_null
local-zone: "adserver.virginmedia.com" always_null
local-zone: "adserver.yahoo.com" always_null
local-zone: "adserver01.de" always_null
local-zone: "adserver1-images.backbeatmedia.com" always_null
local-zone: "adserver1.backbeatmedia.com" always_null
local-zone: "adserver1.mindshare.de" always_null
local-zone: "adserver2.mindshare.de" always_null
local-zone: "adserverplus.com" always_null
local-zone: "adserverpub.com" always_null
local-zone: "adserversolutions.com" always_null
local-zone: "adserverxxl.de" always_null
local-zone: "adservetx.media.net" always_null
local-zone: "adservice.google.com" always_null
local-zone: "adservice.google.com.mt" always_null
local-zone: "adserving.unibet.com" always_null
local-zone: "adservingfront.com" always_null
local-zone: "adservrs.com" always_null
local-zone: "adservrs.com.edgekey.net" always_null
local-zone: "adsfac.eu" always_null
local-zone: "adsfac.net" always_null
local-zone: "adsfac.us" always_null
local-zone: "adsfactor.net" always_null
local-zone: "adsfeed.brabys.com" always_null
local-zone: "adshrink.it" always_null
local-zone: "adside.com" always_null
local-zone: "adsiduous.com" always_null
local-zone: "adskeeper.co.uk" always_null
local-zone: "adsklick.de" always_null
local-zone: "adskpak.com" always_null
local-zone: "adsmart.com" always_null
local-zone: "adsmart.net" always_null
local-zone: "adsmogo.com" always_null
local-zone: "adsnative.com" always_null
local-zone: "adsoftware.com" always_null
local-zone: "adsoldier.com" always_null
local-zone: "adsolut.in" always_null
local-zone: "adspeed.net" always_null
local-zone: "adspirit.de" always_null
local-zone: "adsponse.de" always_null
local-zone: "adspsp.com" always_null
local-zone: "adsroller.com" always_null
local-zone: "adsrv.deviantart.com" always_null
local-zone: "adsrv.eacdn.com" always_null
local-zone: "adsrv.iol.co.za" always_null
local-zone: "adsrv.kobi.tv" always_null
local-zone: "adsrv.moebelmarkt.tv" always_null
local-zone: "adsrv2.swidnica24.pl" always_null
local-zone: "adsrvr.org" always_null
local-zone: "adsrvus.com" always_null
local-zone: "adstacks.in" always_null
local-zone: "adstage.io" always_null
local-zone: "adstanding.com" always_null
local-zone: "adstat.4u.pl" always_null
local-zone: "adstest.weather.com" always_null
local-zone: "adsupply.com" always_null
local-zone: "adswizz.com" always_null
local-zone: "adsxyz.com" always_null
local-zone: "adsymptotic.com" always_null
local-zone: "adsynergy.com" always_null
local-zone: "adsys.townnews.com" always_null
local-zone: "adsystem.simplemachines.org" always_null
local-zone: "adtech-digital.ru" always_null
local-zone: "adtech.com" always_null
local-zone: "adtech.de" always_null
local-zone: "adtechjp.com" always_null
local-zone: "adtechus.com" always_null
local-zone: "adtegrity.net" always_null
local-zone: "adthis.com" always_null
local-zone: "adthrive.com" always_null
local-zone: "adthurst.com" always_null
local-zone: "adtiger.de" always_null
local-zone: "adtilt.com" always_null
local-zone: "adtng.com" always_null
local-zone: "adtology.com" always_null
local-zone: "adtoma.com" always_null
local-zone: "adtrace.org" always_null
local-zone: "adtraction.com" always_null
local-zone: "adtrade.net" always_null
local-zone: "adtriplex.com" always_null
local-zone: "adultadvertising.com" always_null
local-zone: "adv-adserver.com" always_null
local-zone: "adv-banner.libero.it" always_null
local-zone: "adv.cooperhosting.net" always_null
local-zone: "adv.donejty.pl" always_null
local-zone: "adv.freeonline.it" always_null
local-zone: "adv.hwupgrade.it" always_null
local-zone: "adv.livedoor.com" always_null
local-zone: "adv.mpvc.it" always_null
local-zone: "adv.neverbuy.com" always_null
local-zone: "adv.nexthardware.com" always_null
local-zone: "adv.webmd.com" always_null
local-zone: "adv.wp.pl" always_null
local-zone: "adv.yo.cz" always_null
local-zone: "advangelists.com" always_null
local-zone: "advariant.com" always_null
local-zone: "adventory.com" always_null
local-zone: "advert.bayarea.com" always_null
local-zone: "advert.dyna.ultraweb.hu" always_null
local-zone: "adverticum.com" always_null
local-zone: "adverticum.net" always_null
local-zone: "adverticus.de" always_null
local-zone: "advertise.com" always_null
local-zone: "advertiseireland.com" always_null
local-zone: "advertisementafterthought.com" always_null
local-zone: "advertiserurl.com" always_null
local-zone: "advertising.com" always_null
local-zone: "advertisingbanners.com" always_null
local-zone: "advertisingbox.com" always_null
local-zone: "advertmarket.com" always_null
local-zone: "advertmedia.de" always_null
local-zone: "advertpro.ya.com" always_null
local-zone: "advertserve.com" always_null
local-zone: "advertstream.com" always_null
local-zone: "advertwizard.com" always_null
local-zone: "advideo.uimserv.net" always_null
local-zone: "adview.com" always_null
local-zone: "advisormedia.cz" always_null
local-zone: "adviva.net" always_null
local-zone: "advnt.com" always_null
local-zone: "adwebone.com" always_null
local-zone: "adwhirl.com" always_null
local-zone: "adwordsecommerce.com.br" always_null
local-zone: "adworldnetwork.com" always_null
local-zone: "adworx.at" always_null
local-zone: "adworx.nl" always_null
local-zone: "adx.allstar.cz" always_null
local-zone: "adx.atnext.com" always_null
local-zone: "adx.gayboy.at" always_null
local-zone: "adx.relaksit.ru" always_null
local-zone: "adxpansion.com" always_null
local-zone: "adxpose.com" always_null
local-zone: "adxvalue.com" always_null
local-zone: "adyea.com" always_null
local-zone: "adyoulike.com" always_null
local-zone: "adz.rashflash.com" always_null
local-zone: "adz2you.com" always_null
local-zone: "adzbazar.com" always_null
local-zone: "adzerk.net" always_null
local-zone: "adzerk.s3.amazonaws.com" always_null
local-zone: "adzestocp.com" always_null
local-zone: "adzone.temp.co.za" always_null
local-zone: "adzones.com" always_null
local-zone: "adzrevads.com" always_null
local-zone: "aerserv.com" always_null
local-zone: "af-ad.co.uk" always_null
local-zone: "affec.tv" always_null
local-zone: "affili.net" always_null
local-zone: "affiliate.1800flowers.com" always_null
local-zone: "affiliate.doubleyourdating.com" always_null
local-zone: "affiliate.dtiserv.com" always_null
local-zone: "affiliate.gamestop.com" always_null
local-zone: "affiliate.mogs.com" always_null
local-zone: "affiliate.offgamers.com" always_null
local-zone: "affiliate.rusvpn.com" always_null
local-zone: "affiliate.travelnow.com" always_null
local-zone: "affiliate.treated.com" always_null
local-zone: "affiliatefuture.com" always_null
local-zone: "affiliates.allposters.com" always_null
local-zone: "affiliates.babylon.com" always_null
local-zone: "affiliates.digitalriver.com" always_null
local-zone: "affiliates.globat.com" always_null
local-zone: "affiliates.rozetka.com.ua" always_null
local-zone: "affiliates.streamray.com" always_null
local-zone: "affiliates.thinkhost.net" always_null
local-zone: "affiliates.thrixxx.com" always_null
local-zone: "affiliates.ultrahosting.com" always_null
local-zone: "affiliatetracking.com" always_null
local-zone: "affiliatetracking.net" always_null
local-zone: "affiliatewindow.com" always_null
local-zone: "affiliation-france.com" always_null
local-zone: "afftracking.justanswer.com" always_null
local-zone: "agkn.com" always_null
local-zone: "agreeablestew.com" always_null
local-zone: "ah-ha.com" always_null
local-zone: "ahalogy.com" always_null
local-zone: "aheadday.com" always_null
local-zone: "aim4media.com" always_null
local-zone: "airpush.com" always_null
local-zone: "aistat.net" always_null
local-zone: "ak0gsh40.com" always_null
local-zone: "aktrack.pubmatic.com" always_null
local-zone: "alchemist.go2cloud.org" always_null
local-zone: "alclick.com" always_null
local-zone: "alenty.com" always_null
local-zone: "alertafterthought.com" always_null
local-zone: "alexa-sitestats.s3.amazonaws.com" always_null
local-zone: "alexametrics.com" always_null
local-zone: "algorix.co" always_null
local-zone: "alipromo.com" always_null
local-zone: "all4spy.com" always_null
local-zone: "allosponsor.com" always_null
local-zone: "aloofmetal.com" always_null
local-zone: "aloofvest.com" always_null
local-zone: "alphonso.tv" always_null
local-zone: "als-svc.nytimes.com" always_null
local-zone: "amazingcounters.com" always_null
local-zone: "amazon-adsystem.com" always_null
local-zone: "ambiguousquilt.com" always_null
local-zone: "ambitiousagreement.com" always_null
local-zone: "americash.com" always_null
local-zone: "amplitude.com" always_null
local-zone: "amung.us" always_null
local-zone: "analytics-production.hapyak.com" always_null
local-zone: "analytics.adpost.org" always_null
local-zone: "analytics.algoepico.net" always_null
local-zone: "analytics.bitrix.info" always_null
local-zone: "analytics.cloudron.io" always_null
local-zone: "analytics.cohesionapps.com" always_null
local-zone: "analytics.dnsfilter.com" always_null
local-zone: "analytics.emarketer.com" always_null
local-zone: "analytics.ext.go-tellm.com" always_null
local-zone: "analytics.fkz.re" always_null
local-zone: "analytics.google.com" always_null
local-zone: "analytics.htmedia.in" always_null
local-zone: "analytics.icons8.com" always_null
local-zone: "analytics.inlinemanual.com" always_null
local-zone: "analytics.jst.ai" always_null
local-zone: "analytics.justuno.com" always_null
local-zone: "analytics.live.com" always_null
local-zone: "analytics.mailmunch.co" always_null
local-zone: "analytics.mobile.yandex.net" always_null
local-zone: "analytics.myfinance.com" always_null
local-zone: "analytics.mytvzion.pro" always_null
local-zone: "analytics.ostr.io" always_null
local-zone: "analytics.phando.com" always_null
local-zone: "analytics.picsart.com" always_null
local-zone: "analytics.pinterest.com" always_null
local-zone: "analytics.pointdrive.linkedin.com" always_null
local-zone: "analytics.poolshool.com" always_null
local-zone: "analytics.posttv.com" always_null
local-zone: "analytics.samdd.me" always_null
local-zone: "analytics.siliconexpert.com" always_null
local-zone: "analytics.swiggy.com" always_null
local-zone: "analytics.xelondigital.com" always_null
local-zone: "analytics.yahoo.com" always_null
local-zone: "analyticsapi.happypancake.net" always_null
local-zone: "analytik.xyz" always_null
local-zone: "ancientact.com" always_null
local-zone: "aniview.com" always_null
local-zone: "annonser.dagbladet.no" always_null
local-zone: "annoyedairport.com" always_null
local-zone: "annoyingacoustics.com" always_null
local-zone: "anrdoezrs.net" always_null
local-zone: "anstrex.com" always_null
local-zone: "anuncios.edicaoms.com.br" always_null
local-zone: "anxiousapples.com" always_null
local-zone: "apathetictheory.com" always_null
local-zone: "api.amplitude.com" always_null
local-zone: "api.intensifier.de" always_null
local-zone: "api.kameleoon.com" always_null
local-zone: "api.rudderlabs.com" always_null
local-zone: "apolloprogram.io" always_null
local-zone: "app-analytics.snapchat.com" always_null
local-zone: "app.pendo.io" always_null
local-zone: "appboycdn.com" always_null
local-zone: "appsflyer.com" always_null
local-zone: "aps.hearstnp.com" always_null
local-zone: "apsalar.com" always_null
local-zone: "apture.com" always_null
local-zone: "apu.samsungelectronics.com" always_null
local-zone: "aquaticowl.com" always_null
local-zone: "ar1nvz5.com" always_null
local-zone: "aralego.com" always_null
local-zone: "arc1.msn.com" always_null
local-zone: "archswimming.com" always_null
local-zone: "ard.xxxblackbook.com" always_null
local-zone: "argyresthia.com" always_null
local-zone: "aromamirror.com" always_null
local-zone: "artisany.net" always_null
local-zone: "as.webmd.com" always_null
local-zone: "as2.adserverhd.com" always_null
local-zone: "aserv.motorsgate.com" always_null
local-zone: "asewlfjqwlflkew.com" always_null
local-zone: "assets1.exgfnetwork.com" always_null
local-zone: "assoc-amazon.com" always_null
local-zone: "aswpapius.com" always_null
local-zone: "aswpsdkus.com" always_null
local-zone: "at-adserver.alltop.com" always_null
local-zone: "at-o.net" always_null
local-zone: "atdmt.com" always_null
local-zone: "athena-ads.wikia.com" always_null
local-zone: "ato.mx" always_null
local-zone: "attractiveafternoon.com" always_null
local-zone: "attribution.report" always_null
local-zone: "attributiontracker.com" always_null
local-zone: "atwola.com" always_null
local-zone: "auctionads.com" always_null
local-zone: "auctionads.net" always_null
local-zone: "audience.media" always_null
local-zone: "audience2media.com" always_null
local-zone: "audienceinsights.com" always_null
local-zone: "audit.median.hu" always_null
local-zone: "audit.webinform.hu" always_null
local-zone: "augur.io" always_null
local-zone: "auto-bannertausch.de" always_null
local-zone: "automaticflock.com" always_null
local-zone: "avazutracking.net" always_null
local-zone: "avenuea.com" always_null
local-zone: "avocet.io" always_null
local-zone: "avpa.javalobby.org" always_null
local-zone: "awakebird.com" always_null
local-zone: "awempire.com" always_null
local-zone: "awesomeagreement.com" always_null
local-zone: "awin1.com" always_null
local-zone: "awstrack.me" always_null
local-zone: "awzbijw.com" always_null
local-zone: "axiomaticalley.com" always_null
local-zone: "axonix.com" always_null
local-zone: "ay.delivery" always_null
local-zone: "aztracking.net" always_null
local-zone: "b-s.tercept.com" always_null
local-zone: "ba.afl.rakuten.co.jp" always_null
local-zone: "backbeatmedia.com" always_null
local-zone: "balloontexture.com" always_null
local-zone: "banik.redigy.cz" always_null
local-zone: "banner-exchange-24.de" always_null
local-zone: "banner.ad.nu" always_null
local-zone: "banner.ambercoastcasino.com" always_null
local-zone: "banner.buempliz-online.ch" always_null
local-zone: "banner.casino.net" always_null
local-zone: "banner.casinodelrio.com" always_null
local-zone: "banner.cotedazurpalace.com" always_null
local-zone: "banner.coza.com" always_null
local-zone: "banner.cz" always_null
local-zone: "banner.easyspace.com" always_null
local-zone: "banner.elisa.net" always_null
local-zone: "banner.eurogrand.com" always_null
local-zone: "banner.finzoom.ro" always_null
local-zone: "banner.goldenpalace.com" always_null
local-zone: "banner.icmedia.eu" always_null
local-zone: "banner.img.co.za" always_null
local-zone: "banner.interich.com" always_null
local-zone: "banner.inyourpocket.com" always_null
local-zone: "banner.linux.se" always_null
local-zone: "banner.media-system.de" always_null
local-zone: "banner.mindshare.de" always_null
local-zone: "banner.nixnet.cz" always_null
local-zone: "banner.noblepoker.com" always_null
local-zone: "banner.northsky.com" always_null
local-zone: "banner.orb.net" always_null
local-zone: "banner.penguin.cz" always_null
local-zone: "banner.rbc.ru" always_null
local-zone: "banner.reinstil.de" always_null
local-zone: "banner.relcom.ru" always_null
local-zone: "banner.tanto.de" always_null
local-zone: "banner.titan-dsl.de" always_null
local-zone: "banner.vadian.net" always_null
local-zone: "banner.webmersion.com" always_null
local-zone: "banner10.zetasystem.dk" always_null
local-zone: "bannerads.de" always_null
local-zone: "bannerboxes.com" always_null
local-zone: "bannerconnect.com" always_null
local-zone: "bannerconnect.net" always_null
local-zone: "bannergrabber.internet.gr" always_null
local-zone: "bannerimage.com" always_null
local-zone: "bannerlandia.com.ar" always_null
local-zone: "bannermall.com" always_null
local-zone: "bannermanager.bnr.bg" always_null
local-zone: "bannermarkt.nl" always_null
local-zone: "bannerpower.com" always_null
local-zone: "banners.adultfriendfinder.com" always_null
local-zone: "banners.amigos.com" always_null
local-zone: "banners.asiafriendfinder.com" always_null
local-zone: "banners.babylon-x.com" always_null
local-zone: "banners.bol.com.br" always_null
local-zone: "banners.cams.com" always_null
local-zone: "banners.clubseventeen.com" always_null
local-zone: "banners.czi.cz" always_null
local-zone: "banners.dine.com" always_null
local-zone: "banners.direction-x.com" always_null
local-zone: "banners.freett.com" always_null
local-zone: "banners.friendfinder.com" always_null
local-zone: "banners.getiton.com" always_null
local-zone: "banners.iq.pl" always_null
local-zone: "banners.isoftmarketing.com" always_null
local-zone: "banners.linkbuddies.com" always_null
local-zone: "banners.passion.com" always_null
local-zone: "banners.payserve.com" always_null
local-zone: "banners.resultonline.com" always_null
local-zone: "banners.sys-con.com" always_null
local-zone: "banners.thomsonlocal.com" always_null
local-zone: "banners.videosz.com" always_null
local-zone: "banners.virtuagirlhd.com" always_null
local-zone: "bannerserver.com" always_null
local-zone: "bannersgomlm.com" always_null
local-zone: "bannershotlink.perfectgonzo.com" always_null
local-zone: "bannersng.yell.com" always_null
local-zone: "bannerspace.com" always_null
local-zone: "bannerswap.com" always_null
local-zone: "bannertesting.com" always_null
local-zone: "bannertrack.net" always_null
local-zone: "bannery.cz" always_null
local-zone: "bannieres.acces-contenu.com" always_null
local-zone: "bannieres.wdmedia.net" always_null
local-zone: "bans.bride.ru" always_null
local-zone: "barbarousnerve.com" always_null
local-zone: "baremetrics.com" always_null
local-zone: "barnesandnoble.bfast.com" always_null
local-zone: "basebanner.com" always_null
local-zone: "baskettexture.com" always_null
local-zone: "bat.bing.com" always_null
local-zone: "batbuilding.com" always_null
local-zone: "bawdybeast.com" always_null
local-zone: "baypops.com" always_null
local-zone: "bbelements.com" always_null
local-zone: "bbn.img.com.ua" always_null
local-zone: "beachfront.com" always_null
local-zone: "beacon.gu-web.net" always_null
local-zone: "beamincrease.com" always_null
local-zone: "bebi.com" always_null
local-zone: "beemray.com" always_null
local-zone: "begun.ru" always_null
local-zone: "behavioralengine.com" always_null
local-zone: "belstat.com" always_null
local-zone: "belstat.nl" always_null
local-zone: "benfly.net" always_null
local-zone: "berp.com" always_null
local-zone: "bestboundary.com" always_null
local-zone: "bestsearch.net" always_null
local-zone: "bewilderedblade.com" always_null
local-zone: "bfmio.com" always_null
local-zone: "bhcumsc.com" always_null
local-zone: "bidbarrel.cbsnews.com" always_null
local-zone: "bidclix.com" always_null
local-zone: "bidclix.net" always_null
local-zone: "bidr.io" always_null
local-zone: "bidsopt.com" always_null
local-zone: "bidswitch.net" always_null
local-zone: "bidtellect.com" always_null
local-zone: "bidvertiser.com" always_null
local-zone: "big-bang-ads.com" always_null
local-zone: "bigbangmedia.com" always_null
local-zone: "bigclicks.com" always_null
local-zone: "bigreal.org" always_null
local-zone: "billboard.cz" always_null
local-zone: "biosda.com" always_null
local-zone: "bitmedianetwork.com" always_null
local-zone: "bizad.nikkeibp.co.jp" always_null
local-zone: "bizible.com" always_null
local-zone: "bizographics.com" always_null
local-zone: "bizrate.com" always_null
local-zone: "bizzclick.com" always_null
local-zone: "bkrtx.com" always_null
local-zone: "blingbucks.com" always_null
local-zone: "blis.com" always_null
local-zone: "blockadblock.com" always_null
local-zone: "blockthrough.com" always_null
local-zone: "blogads.com" always_null
local-zone: "blogcounter.de" always_null
local-zone: "blogherads.com" always_null
local-zone: "blogtoplist.se" always_null
local-zone: "blogtopsites.com" always_null
local-zone: "blueadvertise.com" always_null
local-zone: "blueconic.com" always_null
local-zone: "blueconic.net" always_null
local-zone: "bluekai.com" always_null
local-zone: "bluelithium.com" always_null
local-zone: "bluewhaleweb.com" always_null
local-zone: "blushingbeast.com" always_null
local-zone: "blushingboundary.com" always_null
local-zone: "bm.annonce.cz" always_null
local-zone: "bn.bfast.com" always_null
local-zone: "bnnrrv.qontentum.de" always_null
local-zone: "bnrs.ilm.ee" always_null
local-zone: "boffoadsapi.com" always_null
local-zone: "boilingbeetle.com" always_null
local-zone: "boilingumbrella.com" always_null
local-zone: "bongacash.com" always_null
local-zone: "boomads.com" always_null
local-zone: "boomtrain.com" always_null
local-zone: "boost-my-pr.de" always_null
local-zone: "boredcrown.com" always_null
local-zone: "boringcoat.com" always_null
local-zone: "boudja.com" always_null
local-zone: "bounceads.net" always_null
local-zone: "bounceexchange.com" always_null
local-zone: "bowie-cdn.fathomdns.com" always_null
local-zone: "box.anchorfree.net" always_null
local-zone: "bpath.com" always_null
local-zone: "bpu.samsungelectronics.com" always_null
local-zone: "braincash.com" always_null
local-zone: "brand-display.com" always_null
local-zone: "brandreachsys.com" always_null
local-zone: "breakableinsurance.com" always_null
local-zone: "breaktime.com.tw" always_null
local-zone: "brealtime.com" always_null
local-zone: "bridgetrack.com" always_null
local-zone: "brightcom.com" always_null
local-zone: "brightinfo.com" always_null
local-zone: "brightmountainmedia.com" always_null
local-zone: "british-banners.com" always_null
local-zone: "broadboundary.com" always_null
local-zone: "broadcastbed.com" always_null
local-zone: "broaddoor.com" always_null
local-zone: "broadstreetads.com" always_null
local-zone: "browser-http-intake.logs.datadoghq.com" always_null
local-zone: "browser-http-intake.logs.datadoghq.eu" always_null
local-zone: "bs.yandex.ru" always_null
local-zone: "btez8.xyz" always_null
local-zone: "btrll.com" always_null
local-zone: "bttrack.com" always_null
local-zone: "bucketbean.com" always_null
local-zone: "bullseye.backbeatmedia.com" always_null
local-zone: "businessbells.com" always_null
local-zone: "bustlinganimal.com" always_null
local-zone: "buysellads.com" always_null
local-zone: "buzzonclick.com" always_null
local-zone: "bwp.download.com" always_null
local-zone: "c.bigmir.net" always_null
local-zone: "c1exchange.com" always_null
local-zone: "calculatingcircle.com" always_null
local-zone: "calculatingtoothbrush.com" always_null
local-zone: "calculatorcamera.com" always_null
local-zone: "callousbrake.com" always_null
local-zone: "callrail.com" always_null
local-zone: "calmcactus.com" always_null
local-zone: "campaign.bharatmatrimony.com" always_null
local-zone: "caniamedia.com" always_null
local-zone: "cannads.urgrafix.com" always_null
local-zone: "capablecows.com" always_null
local-zone: "captainbicycle.com" always_null
local-zone: "carambo.la" always_null
local-zone: "carbonads.com" always_null
local-zone: "carbonads.net" always_null
local-zone: "caringcast.com" always_null
local-zone: "casalemedia.com" always_null
local-zone: "casalmedia.com" always_null
local-zone: "cash4members.com" always_null
local-zone: "cash4popup.de" always_null
local-zone: "cashcrate.com" always_null
local-zone: "cashengines.com" always_null
local-zone: "cashfiesta.com" always_null
local-zone: "cashpartner.com" always_null
local-zone: "cashstaging.me" always_null
local-zone: "casinopays.com" always_null
local-zone: "casinorewards.com" always_null
local-zone: "casinotraffic.com" always_null
local-zone: "causecherry.com" always_null
local-zone: "cbanners.virtuagirlhd.com" always_null
local-zone: "cdn.bannerflow.com" always_null
local-zone: "cdn.branch.io" always_null
local-zone: "cdn.freefarcy.com" always_null
local-zone: "cdn.freshmarketer.com" always_null
local-zone: "cdn.heapanalytics.com" always_null
local-zone: "cdn.keywee.co" always_null
local-zone: "cdn.onesignal.com" always_null
local-zone: "cdn.panelbear.com" always_null
local-zone: "cdn.segment.com" always_null
local-zone: "cdnondemand.org" always_null
local-zone: "cedato.com" always_null
local-zone: "celtra.com" always_null
local-zone: "centerpointmedia.com" always_null
local-zone: "ceskydomov.alias.ngs.modry.cz" always_null
local-zone: "cetrk.com" always_null
local-zone: "cgicounter.puretec.de" always_null
local-zone: "chairscrack.com" always_null
local-zone: "chameleon.ad" always_null
local-zone: "channelintelligence.com" always_null
local-zone: "chart.dk" always_null
local-zone: "chartbeat.net" always_null
local-zone: "chartboost.com" always_null
local-zone: "checkm8.com" always_null
local-zone: "checkstat.nl" always_null
local-zone: "cheerfulrange.com" always_null
local-zone: "chewcoat.com" always_null
local-zone: "chickensstation.com" always_null
local-zone: "chinsnakes.com" always_null
local-zone: "chitika.net" always_null
local-zone: "cision.com" always_null
local-zone: "citrusad.net" always_null
local-zone: "cityads.telus.net" always_null
local-zone: "cj.com" always_null
local-zone: "cjbmanagement.com" always_null
local-zone: "cjlog.com" always_null
local-zone: "cl0udh0st1ng.com" always_null
local-zone: "claria.com" always_null
local-zone: "clevernt.com" always_null
local-zone: "cliand.com" always_null
local-zone: "click.a-ads.com" always_null
local-zone: "click.airmalta-mail.com" always_null
local-zone: "click.bkdpt.com" always_null
local-zone: "click.cartsguru.io" always_null
local-zone: "click.email.bbc.com" always_null
local-zone: "click.email.sonos.com" always_null
local-zone: "click.fool.com" always_null
local-zone: "click.kmindex.ru" always_null
local-zone: "click.negociosdigitaisnapratica.com.br" always_null
local-zone: "click.redditmail.com" always_null
local-zone: "click.twcwigs.com" always_null
local-zone: "click2freemoney.com" always_null
local-zone: "clickability.com" always_null
local-zone: "clickadz.com" always_null
local-zone: "clickagents.com" always_null
local-zone: "clickbank.com" always_null
local-zone: "clickbooth.com" always_null
local-zone: "clickboothlnk.com" always_null
local-zone: "clickbrokers.com" always_null
local-zone: "clickcompare.co.uk" always_null
local-zone: "clickdensity.com" always_null
local-zone: "clickedyclick.com" always_null
local-zone: "clickfuse.com" always_null
local-zone: "clickhereforcellphones.com" always_null
local-zone: "clickhype.com" always_null
local-zone: "clicklink.jp" always_null
local-zone: "clickmate.io" always_null
local-zone: "clickonometrics.pl" always_null
local-zone: "clicks.equantum.com" always_null
local-zone: "clicks.mods.de" always_null
local-zone: "clickserve.cc-dt.com" always_null
local-zone: "clicktag.de" always_null
local-zone: "clickthruserver.com" always_null
local-zone: "clickthrutraffic.com" always_null
local-zone: "clicktrace.info" always_null
local-zone: "clicktrack.ziyu.net" always_null
local-zone: "clicktracks.com" always_null
local-zone: "clicktrade.com" always_null
local-zone: "clickwith.bid" always_null
local-zone: "clickxchange.com" always_null
local-zone: "clickyab.com" always_null
local-zone: "clickz.com" always_null
local-zone: "clientgear.com" always_null
local-zone: "clientmetrics-pa.googleapis.com" always_null
local-zone: "clikerz.net" always_null
local-zone: "cliksolution.com" always_null
local-zone: "clixgalore.com" always_null
local-zone: "clk1005.com" always_null
local-zone: "clk1011.com" always_null
local-zone: "clk1015.com" always_null
local-zone: "clkrev.com" always_null
local-zone: "clksite.com" always_null
local-zone: "clktrx.com" always_null
local-zone: "cloisteredhydrant.com" always_null
local-zone: "closedcows.com" always_null
local-zone: "cloudcoins.biz" always_null
local-zone: "cloudflareinsights.com" always_null
local-zone: "clrstm.com" always_null
local-zone: "cluster.adultworld.com" always_null
local-zone: "clustrmaps.com" always_null
local-zone: "cmp.dmgmediaprivacy.co.uk" always_null
local-zone: "cmvrclicks000.com" always_null
local-zone: "cnomy.com" always_null
local-zone: "cnt.spbland.ru" always_null
local-zone: "cnt1.pocitadlo.cz" always_null
local-zone: "cny.yoyo.org" always_null
local-zone: "codeadnetwork.com" always_null
local-zone: "cognitiv.ai" always_null
local-zone: "coin-hive.com" always_null
local-zone: "coinhive.com" always_null
local-zone: "cointraffic.io" always_null
local-zone: "collector-dev.cdp-dev.cnn.com" always_null
local-zone: "collector.cdp.cnn.com" always_null
local-zone: "colonize.com" always_null
local-zone: "comclick.com" always_null
local-zone: "comfortablecheese.com" always_null
local-zone: "commindo-media-ressourcen.de" always_null
local-zone: "commissionmonster.com" always_null
local-zone: "commonswing.com" always_null
local-zone: "communications.melitaltd.com" always_null
local-zone: "compactbanner.com" always_null
local-zone: "completecabbage.com" always_null
local-zone: "complextoad.com" always_null
local-zone: "comprabanner.it" always_null
local-zone: "concernedcondition.com" always_null
local-zone: "conditionchange.com" always_null
local-zone: "conductrics.com" always_null
local-zone: "connatix.com" always_null
local-zone: "connectad.io" always_null
local-zone: "connextra.com" always_null
local-zone: "consciouschairs.com" always_null
local-zone: "consciouscheese.com" always_null
local-zone: "consensad.com" always_null
local-zone: "consensu.org" always_null
local-zone: "contadores.miarroba.com" always_null
local-zone: "contaxe.de" always_null
local-zone: "content.acc-hd.de" always_null
local-zone: "content.ad" always_null
local-zone: "content22.online.citi.com" always_null
local-zone: "contextweb.com" always_null
local-zone: "converge-digital.com" always_null
local-zone: "conversantmedia.com" always_null
local-zone: "conversionbet.com" always_null
local-zone: "conversionruler.com" always_null
local-zone: "convertingtraffic.com" always_null
local-zone: "convrse.media" always_null
local-zone: "cookies.cmpnet.com" always_null
local-zone: "coordinatedcub.com" always_null
local-zone: "cootlogix.com" always_null
local-zone: "copperchickens.com" always_null
local-zone: "copycarpenter.com" always_null
local-zone: "copyrightaccesscontrols.com" always_null
local-zone: "coremetrics.com" always_null
local-zone: "cormast.com" always_null
local-zone: "cosmopolitads.com" always_null
local-zone: "count.rin.ru" always_null
local-zone: "count.west263.com" always_null
local-zone: "counted.com" always_null
local-zone: "counter.bloke.com" always_null
local-zone: "counter.cnw.cz" always_null
local-zone: "counter.cz" always_null
local-zone: "counter.dreamhost.com" always_null
local-zone: "counter.mirohost.net" always_null
local-zone: "counter.mojgorod.ru" always_null
local-zone: "counter.rambler.ru" always_null
local-zone: "counter.search.bg" always_null
local-zone: "counter.snackly.co" always_null
local-zone: "counter.sparklit.com" always_null
local-zone: "counter.yadro.ru" always_null
local-zone: "counters.honesty.com" always_null
local-zone: "counting.kmindex.ru" always_null
local-zone: "coupling-media.de" always_null
local-zone: "coxmt.com" always_null
local-zone: "cp.abbp1.pw" always_null
local-zone: "cpalead.com" always_null
local-zone: "cpays.com" always_null
local-zone: "cpmstar.com" always_null
local-zone: "cpu.samsungelectronics.com" always_null
local-zone: "cpx-traffic.com" always_null
local-zone: "cpx.to" always_null
local-zone: "cpxinteractive.com" always_null
local-zone: "cqcounter.com" always_null
local-zone: "crabbychin.com" always_null
local-zone: "crakmedia.com" always_null
local-zone: "craktraffic.com" always_null
local-zone: "crashlytics.com" always_null
local-zone: "crashlyticsreports-pa.googleapis.com" always_null
local-zone: "cratecamera.com" always_null
local-zone: "crawlability.com" always_null
local-zone: "crawlclocks.com" always_null
local-zone: "crazyegg.com" always_null
local-zone: "crazypopups.com" always_null
local-zone: "creafi-online-media.com" always_null
local-zone: "creatives.livejasmin.com" always_null
local-zone: "criteo.com" always_null
local-zone: "criteo.net" always_null
local-zone: "critictruck.com" always_null
local-zone: "croissed.info" always_null
local-zone: "crowdgravity.com" always_null
local-zone: "crsspxl.com" always_null
local-zone: "crta.dailymail.co.uk" always_null
local-zone: "crtv.mate1.com" always_null
local-zone: "crwdcntrl.net" always_null
local-zone: "crypto-loot.org" always_null
local-zone: "ctnetwork.hu" always_null
local-zone: "cubics.com" always_null
local-zone: "culturedcrayon.com" always_null
local-zone: "cumbersomecloud.com" always_null
local-zone: "curtaincows.com" always_null
local-zone: "custom.plausible.io" always_null
local-zone: "customad.cnn.com" always_null
local-zone: "customers.kameleoon.com" always_null
local-zone: "cutechin.com" always_null
local-zone: "cutecushion.com" always_null
local-zone: "cuteturkey.com" always_null
local-zone: "cxense.com" always_null
local-zone: "cyberbounty.com" always_null
local-zone: "cyrasi.com" always_null
local-zone: "d.adroll.com" always_null
local-zone: "d2cmedia.ca" always_null
local-zone: "dabiaozhi.com" always_null
local-zone: "dacdn.visualwebsiteoptimizer.com" always_null
local-zone: "dacdn.vwo.com" always_null
local-zone: "dakic-ia-300.com" always_null
local-zone: "damageddistance.com" always_null
local-zone: "damdoor.com" always_null
local-zone: "dancemistake.com" always_null
local-zone: "dapper.net" always_null
local-zone: "dapperfloor.com" always_null
local-zone: "dashbida.com" always_null
local-zone: "dashingdirt.com" always_null
local-zone: "dashingsweater.com" always_null
local-zone: "data.namesakeoscilloscopemarquis.com" always_null
local-zone: "data8a8altrk.com" always_null
local-zone: "dbbsrv.com" always_null
local-zone: "dc-storm.com" always_null
local-zone: "de17a.com" always_null
local-zone: "deadpantruck.com" always_null
local-zone: "dealdotcom.com" always_null
local-zone: "debonairway.com" always_null
local-zone: "debtbusterloans.com" always_null
local-zone: "decenterads.com" always_null
local-zone: "decisivedrawer.com" always_null
local-zone: "decisiveducks.com" always_null
local-zone: "decknetwork.net" always_null
local-zone: "decoycreation.com" always_null
local-zone: "deepintent.com" always_null
local-zone: "defectivesun.com" always_null
local-zone: "delegatediscussion.com" always_null
local-zone: "deloo.de" always_null
local-zone: "deloplen.com" always_null
local-zone: "deloton.com" always_null
local-zone: "demandbase.com" always_null
local-zone: "demdex.net" always_null
local-zone: "denety.com" always_null
local-zone: "deployads.com" always_null
local-zone: "desertedbreath.com" always_null
local-zone: "desertedrat.com" always_null
local-zone: "detailedglue.com" always_null
local-zone: "detailedgovernment.com" always_null
local-zone: "detectdiscovery.com" always_null
local-zone: "dev.visualwebsiteoptimizer.com" always_null
local-zone: "dianomi.com" always_null
local-zone: "didtheyreadit.com" always_null
local-zone: "digital-ads.s3.amazonaws.com" always_null
local-zone: "digitalmerkat.com" always_null
local-zone: "direct-events-collector.spot.im" always_null
local-zone: "direct-xxx-access.com" always_null
local-zone: "directaclick.com" always_null
local-zone: "directivepub.com" always_null
local-zone: "directleads.com" always_null
local-zone: "directorym.com" always_null
local-zone: "directtrack.com" always_null
local-zone: "discountclick.com" always_null
local-zone: "discreetfield.com" always_null
local-zone: "dispensablestranger.com" always_null
local-zone: "disqusads.com" always_null
local-zone: "dist.belnk.com" always_null
local-zone: "distillery.wistia.com" always_null
local-zone: "districtm.ca" always_null
local-zone: "districtm.io" always_null
local-zone: "dk4ywix.com" always_null
local-zone: "dmp.mall.tv" always_null
local-zone: "dmtracker.com" always_null
local-zone: "dmtracking.alibaba.com" always_null
local-zone: "dmtracking2.alibaba.com" always_null
local-zone: "dnsdelegation.io" always_null
local-zone: "do-global.com" always_null
local-zone: "dockdigestion.com" always_null
local-zone: "docksalmon.com" always_null
local-zone: "dogcollarfavourbluff.com" always_null
local-zone: "domaining.in" always_null
local-zone: "domainsponsor.com" always_null
local-zone: "domainsteam.de" always_null
local-zone: "domdex.com" always_null
local-zone: "dotmetrics.net" always_null
local-zone: "doubleclick.com" always_null
local-zone: "doubleclick.de" always_null
local-zone: "doubleclick.net" always_null
local-zone: "doublepimp.com" always_null
local-zone: "doubleverify.com" always_null
local-zone: "doubtfulrainstorm.com" always_null
local-zone: "downloadr.xyz" always_null
local-zone: "dpbolvw.net" always_null
local-zone: "dpgawov.com" always_null
local-zone: "dpu.samsungelectronics.com" always_null
local-zone: "dq95d35.com" always_null
local-zone: "drabsize.com" always_null
local-zone: "dragzebra.com" always_null
local-zone: "drumcash.com" always_null
local-zone: "drydrum.com" always_null
local-zone: "dsp.colpirio.com" always_null
local-zone: "dsp.io" always_null
local-zone: "dstillery.com" always_null
local-zone: "dyntrk.com" always_null
local-zone: "e-adimages.scrippsnetworks.com" always_null
local-zone: "e-m.fr" always_null
local-zone: "e-planning.net" always_null
local-zone: "e.kde.cz" always_null
local-zone: "e37364.dscd.akamaiedge.net" always_null
local-zone: "eadexchange.com" always_null
local-zone: "eaesie.com" always_null
local-zone: "earthquakescarf.com" always_null
local-zone: "earthycopy.com" always_null
local-zone: "eas.almamedia.fi" always_null
local-zone: "easyhits4u.com" always_null
local-zone: "ebayadvertising.com" always_null
local-zone: "ebuzzing.com" always_null
local-zone: "ecircle-ag.com" always_null
local-zone: "ecleneue.com" always_null
local-zone: "eclick.vn" always_null
local-zone: "eclkmpbn.com" always_null
local-zone: "eclkspbn.com" always_null
local-zone: "economicpizzas.com" always_null
local-zone: "ecoupons.com" always_null
local-zone: "edaa.eu" always_null
local-zone: "effectivemeasure.com" always_null
local-zone: "effectivemeasure.net" always_null
local-zone: "efficaciouscactus.com" always_null
local-zone: "eiv.baidu.com" always_null
local-zone: "ejyymghi.com" always_null
local-zone: "elasticchange.com" always_null
local-zone: "elderlyscissors.com" always_null
local-zone: "elderlytown.com" always_null
local-zone: "elephantqueue.com" always_null
local-zone: "elitedollars.com" always_null
local-zone: "elitetoplist.com" always_null
local-zone: "elthamely.com" always_null
local-zone: "em1.yoursantander.co.uk" always_null
local-zone: "emanog.com" always_null
local-zone: "emebo.com" always_null
local-zone: "emebo.io" always_null
local-zone: "emerse.com" always_null
local-zone: "emetriq.de" always_null
local-zone: "emjcd.com" always_null
local-zone: "emltrk.com" always_null
local-zone: "emodoinc.com" always_null
local-zone: "emptyescort.com" always_null
local-zone: "emxdigital.com" always_null
local-zone: "encouragingwilderness.com" always_null
local-zone: "endurableshop.com" always_null
local-zone: "energeticladybug.com" always_null
local-zone: "engage.dnsfilter.com" always_null
local-zone: "engage.webshrinker.com" always_null
local-zone: "engage.windows.com" always_null
local-zone: "engagebdr.com" always_null
local-zone: "engine.espace.netavenir.com" always_null
local-zone: "enginenetwork.com" always_null
local-zone: "enormousearth.com" always_null
local-zone: "enquisite.com" always_null
local-zone: "ensighten.com" always_null
local-zone: "entercasino.com" always_null
local-zone: "enthusiasticdad.com" always_null
local-zone: "entrecard.s3.amazonaws.com" always_null
local-zone: "enviousthread.com" always_null
local-zone: "epom.com" always_null
local-zone: "epp.bih.net.ba" always_null
local-zone: "eqads.com" always_null
local-zone: "erne.co" always_null
local-zone: "ero-advertising.com" always_null
local-zone: "espn.com.ssl.sc.omtrdc.net" always_null
local-zone: "estat.com" always_null
local-zone: "esty.com" always_null
local-zone: "et.nytimes.com" always_null
local-zone: "etahub.com" always_null
local-zone: "etargetnet.com" always_null
local-zone: "etioh.com" always_null
local-zone: "etracker.com" always_null
local-zone: "etracker.de" always_null
local-zone: "eu-adcenter.net" always_null
local-zone: "eu1.madsone.com" always_null
local-zone: "eule1.pmu.fr" always_null
local-zone: "eulerian.net" always_null
local-zone: "eurekster.com" always_null
local-zone: "euros4click.de" always_null
local-zone: "eusta.de" always_null
local-zone: "evadav.com" always_null
local-zone: "evadavdsp.pro" always_null
local-zone: "events-eu.freshsuccess.com" always_null
local-zone: "events-us.freshsuccess.com" always_null
local-zone: "everestads.net" always_null
local-zone: "everesttech.net" always_null
local-zone: "evergage.com" always_null
local-zone: "eversales.space" always_null
local-zone: "evyy.net" always_null
local-zone: "exanae.com" always_null
local-zone: "exchange-it.com" always_null
local-zone: "exchangead.com" always_null
local-zone: "exchangeclicksonline.com" always_null
local-zone: "exclusivebrass.com" always_null
local-zone: "exelate.com" always_null
local-zone: "exelator.com" always_null
local-zone: "exit76.com" always_null
local-zone: "exitexchange.com" always_null
local-zone: "exitfuel.com" always_null
local-zone: "exoclick.com" always_null
local-zone: "exosrv.com" always_null
local-zone: "experianmarketingservices.digital" always_null
local-zone: "explorads.com" always_null
local-zone: "exponea.com" always_null
local-zone: "exponential.com" always_null
local-zone: "express-submit.de" always_null
local-zone: "extreme-dm.com" always_null
local-zone: "extremetracking.com" always_null
local-zone: "eyeblaster.com" always_null
local-zone: "eyeota.net" always_null
local-zone: "eyereturn.com" always_null
local-zone: "eyeviewads.com" always_null
local-zone: "eyewonder.com" always_null
local-zone: "ezula.com" always_null
local-zone: "f7ds.liberation.fr" always_null
local-zone: "fabric.io" always_null
local-zone: "facilitategrandfather.com" always_null
local-zone: "fadedprofit.com" always_null
local-zone: "fadedsnow.com" always_null
local-zone: "fallaciousfifth.com" always_null
local-zone: "famousquarter.com" always_null
local-zone: "faracoon.com" always_null
local-zone: "farethief.com" always_null
local-zone: "farmergoldfish.com" always_null
local-zone: "fascinatedfeather.com" always_null
local-zone: "fast-always_nulling.com" always_null
local-zone: "fastclick.com" always_null
local-zone: "fastclick.com.edgesuite.net" always_null
local-zone: "fastclick.net" always_null
local-zone: "fastly-insights.com" always_null
local-zone: "faultycanvas.com" always_null
local-zone: "faultyfowl.com" always_null
local-zone: "fc.webmasterpro.de" always_null
local-zone: "feathr.co" always_null
local-zone: "feebleshock.com" always_null
local-zone: "feedbackresearch.com" always_null
local-zone: "feedjit.com" always_null
local-zone: "feedmob.com" always_null
local-zone: "ffxcam.fairfax.com.au" always_null
local-zone: "fimserve.com" always_null
local-zone: "findcommerce.com" always_null
local-zone: "findepended.com" always_null
local-zone: "findyourcasino.com" always_null
local-zone: "fineoffer.net" always_null
local-zone: "fingahvf.top" always_null
local-zone: "first.nova.cz" always_null
local-zone: "firstlightera.com" always_null
local-zone: "fixel.ai" always_null
local-zone: "flairadscpc.com" always_null
local-zone: "flakyfeast.com" always_null
local-zone: "flashtalking.com" always_null
local-zone: "fleshlightcash.com" always_null
local-zone: "flexbanner.com" always_null
local-zone: "flimsycircle.com" always_null
local-zone: "floodprincipal.com" always_null
local-zone: "flowgo.com" always_null
local-zone: "flurry.com" always_null
local-zone: "fly-analytics.com" always_null
local-zone: "folawn.com" always_null
local-zone: "foo.cosmocode.de" always_null
local-zone: "foresee.com" always_null
local-zone: "forex-affiliate.net" always_null
local-zone: "forkcdn.com" always_null
local-zone: "fourarithmetic.com" always_null
local-zone: "fpctraffic.com" always_null
local-zone: "fpctraffic2.com" always_null
local-zone: "fpjs.io" always_null
local-zone: "fqtag.com" always_null
local-zone: "frailoffer.com" always_null
local-zone: "franklybundlecarver.com" always_null
local-zone: "free-banners.com" always_null
local-zone: "free-counter.co.uk" always_null
local-zone: "free-counters.co.uk" always_null
local-zone: "freebanner.com" always_null
local-zone: "freecounterstat.com" always_null
local-zone: "freelogs.com" always_null
local-zone: "freeonlineusers.com" always_null
local-zone: "freepay.com" always_null
local-zone: "freeskreen.com" always_null
local-zone: "freestats.com" always_null
local-zone: "freestats.tv" always_null
local-zone: "freewebcounter.com" always_null
local-zone: "freewheel.com" always_null
local-zone: "freewheel.tv" always_null
local-zone: "frightenedpotato.com" always_null
local-zone: "frtyj.com" always_null
local-zone: "frtyk.com" always_null
local-zone: "fullstory.com" always_null
local-zone: "functionalcrown.com" always_null
local-zone: "funklicks.com" always_null
local-zone: "fusionads.net" always_null
local-zone: "fusionquest.com" always_null
local-zone: "futuristicapparatus.com" always_null
local-zone: "futuristicfairies.com" always_null
local-zone: "fuzzybasketball.com" always_null
local-zone: "fuzzyflavor.com" always_null
local-zone: "fuzzyweather.com" always_null
local-zone: "fxstyle.net" always_null
local-zone: "ga.clearbit.com" always_null
local-zone: "ga87z2o.com" always_null
local-zone: "gadsbee.com" always_null
local-zone: "galaxien.com" always_null
local-zone: "game-advertising-online.com" always_null
local-zone: "gamehouse.com" always_null
local-zone: "gamesites100.net" always_null
local-zone: "gamesites200.com" always_null
local-zone: "gammamaximum.com" always_null
local-zone: "gaug.es" always_null
local-zone: "gearwom.de" always_null
local-zone: "gekko.spiceworks.com" always_null
local-zone: "geo.digitalpoint.com" always_null
local-zone: "geobanner.adultfriendfinder.com" always_null
local-zone: "georiot.com" always_null
local-zone: "geovisite.com" always_null
local-zone: "getclicky.com" always_null
local-zone: "getintent.com" always_null
local-zone: "getmyads.com" always_null
local-zone: "giddycoat.com" always_null
local-zone: "globalismedia.com" always_null
local-zone: "globaltakeoff.net" always_null
local-zone: "globus-inter.com" always_null
local-zone: "glossysense.com" always_null
local-zone: "gloyah.net" always_null
local-zone: "gmads.net" always_null
local-zone: "gml.email" always_null
local-zone: "go-clicks.de" always_null
local-zone: "go-mpulse.net" always_null
local-zone: "go-rank.de" always_null
local-zone: "go2affise.com" always_null
local-zone: "goingplatinum.com" always_null
local-zone: "goldstats.com" always_null
local-zone: "gondolagnome.com" always_null
local-zone: "google-analytics.com" always_null
local-zone: "googleadservices.com" always_null
local-zone: "googleanalytics.com" always_null
local-zone: "googlesyndication.com" always_null
local-zone: "googletagservices.com" always_null
local-zone: "gorgeousground.com" always_null
local-zone: "gostats.com" always_null
local-zone: "gothamads.com" always_null
local-zone: "gotraffic.net" always_null
local-zone: "gp.dejanews.com" always_null
local-zone: "gracefulsock.com" always_null
local-zone: "graizoah.com" always_null
local-zone: "grandioseguide.com" always_null
local-zone: "grapeshot.co.uk" always_null
local-zone: "greetzebra.com" always_null
local-zone: "greyinstrument.com" always_null
local-zone: "greystripe.com" always_null
local-zone: "groundtruth.com" always_null
local-zone: "gscontxt.net" always_null
local-zone: "gtop100.com" always_null
local-zone: "guardedschool.com" always_null
local-zone: "gunggo.com" always_null
local-zone: "h-bid.com" always_null
local-zone: "h0.t.hubspotemail.net" always_null
local-zone: "h78xb.pw" always_null
local-zone: "habitualhumor.com" always_null
local-zone: "hadskiz.com" always_null
local-zone: "haltingbadge.com" always_null
local-zone: "hammerhearing.com" always_null
local-zone: "handyfield.com" always_null
local-zone: "hardtofindmilk.com" always_null
local-zone: "harrenmedia.com" always_null
local-zone: "harrenmedianetwork.com" always_null
local-zone: "havamedia.net" always_null
local-zone: "hb.afl.rakuten.co.jp" always_null
local-zone: "hb.vntsm.com" always_null
local-zone: "hbb.afl.rakuten.co.jp" always_null
local-zone: "hdscout.com" always_null
local-zone: "heap.com" always_null
local-zone: "heias.com" always_null
local-zone: "hellobar.com" always_null
local-zone: "hentaicounter.com" always_null
local-zone: "herbalaffiliateprogram.com" always_null
local-zone: "hexcan.com" always_null
local-zone: "hexusads.fluent.ltd.uk" always_null
local-zone: "heyos.com" always_null
local-zone: "hf5rbejvpwds.com" always_null
local-zone: "hfc195b.com" always_null
local-zone: "hgads.com" always_null
local-zone: "highfalutinroom.com" always_null
local-zone: "hightrafficads.com" always_null
local-zone: "hilariouszinc.com" always_null
local-zone: "hilltopads.net" always_null
local-zone: "histats.com" always_null
local-zone: "historicalrequest.com" always_null
local-zone: "hit-parade.com" always_null
local-zone: "hit.bg" always_null
local-zone: "hit.ua" always_null
local-zone: "hit.webcentre.lycos.co.uk" always_null
local-zone: "hitbox.com" always_null
local-zone: "hitcounters.miarroba.com" always_null
local-zone: "hitfarm.com" always_null
local-zone: "hitiz.com" always_null
local-zone: "hitlist.ru" always_null
local-zone: "hitlounge.com" always_null
local-zone: "hitometer.com" always_null
local-zone: "hits-i.iubenda.com" always_null
local-zone: "hits.europuls.eu" always_null
local-zone: "hits.informer.com" always_null
local-zone: "hits.puls.lv" always_null
local-zone: "hits.theguardian.com" always_null
local-zone: "hits4me.com" always_null
local-zone: "hitslink.com" always_null
local-zone: "hittail.com" always_null
local-zone: "hlok.qertewrt.com" always_null
local-zone: "hocgeese.com" always_null
local-zone: "homelycrown.com" always_null
local-zone: "homepageking.de" always_null
local-zone: "honeygoldfish.com" always_null
local-zone: "honorablehall.com" always_null
local-zone: "honorableland.com" always_null
local-zone: "hostedads.realitykings.com" always_null
local-zone: "hotjar.com" always_null
local-zone: "hotkeys.com" always_null
local-zone: "hotlog.ru" always_null
local-zone: "hotrank.com.tw" always_null
local-zone: "hoverowl.com" always_null
local-zone: "hs-analytics.net" always_null
local-zone: "hs-banner.com" always_null
local-zone: "hsadspixel.net" always_null
local-zone: "hsn.uqhv.net" always_null
local-zone: "htlbid.com" always_null
local-zone: "httpool.com" always_null
local-zone: "hubadnetwork.com" always_null
local-zone: "hueads.com" always_null
local-zone: "hueadsortb.com" always_null
local-zone: "hueadsxml.com" always_null
local-zone: "huezzcjskf.site" always_null
local-zone: "hurricanedigitalmedia.com" always_null
local-zone: "hurtteeth.com" always_null
local-zone: "hydramedia.com" always_null
local-zone: "hyperbanner.net" always_null
local-zone: "hypertracker.com" always_null
local-zone: "hyprmx.com" always_null
local-zone: "hystericalcloth.com" always_null
local-zone: "hystericalhelp.com" always_null
local-zone: "i-clicks.net" always_null
local-zone: "i-i.lt" always_null
local-zone: "i1img.com" always_null
local-zone: "i1media.no" always_null
local-zone: "ia.iinfo.cz" always_null
local-zone: "iad.anm.co.uk" always_null
local-zone: "iadnet.com" always_null
local-zone: "iasds01.com" always_null
local-zone: "ibillboard.com" always_null
local-zone: "iconpeak2trk.com" always_null
local-zone: "icptrack.com" always_null
local-zone: "id5-sync.com" always_null
local-zone: "idealadvertising.net" always_null
local-zone: "idevaffiliate.com" always_null
local-zone: "idtargeting.com" always_null
local-zone: "ientrymail.com" always_null
local-zone: "iesnare.com" always_null
local-zone: "ifa.tube8live.com" always_null
local-zone: "ihogaetw.com" always_null
local-zone: "ilbanner.com" always_null
local-zone: "ilead.itrack.it" always_null
local-zone: "illfatedsnail.com" always_null
local-zone: "illustriousoatmeal.com" always_null
local-zone: "imagecash.net" always_null
local-zone: "images-pw.secureserver.net" always_null
local-zone: "imarketservices.com" always_null
local-zone: "imembe.com" always_null
local-zone: "img.prohardver.hu" always_null
local-zone: "imgpromo.easyrencontre.com" always_null
local-zone: "immensehoney.com" always_null
local-zone: "imonitor.nethost.cz" always_null
local-zone: "imonomy.com" always_null
local-zone: "importedincrease.com" always_null
local-zone: "impossibleexpansion.com" always_null
local-zone: "imprese.cz" always_null
local-zone: "impressionmedia.cz" always_null
local-zone: "impressionmonster.com" always_null
local-zone: "impressionz.co.uk" always_null
local-zone: "improvedigital.com" always_null
local-zone: "impulsehands.com" always_null
local-zone: "imrworldwide.com" always_null
local-zone: "incentaclick.com" always_null
local-zone: "inclk.com" always_null
local-zone: "incognitosearches.com" always_null
local-zone: "incoming.telemetry.mozilla.org" always_null
local-zone: "indexexchange.com" always_null
local-zone: "indexstats.com" always_null
local-zone: "indexww.com" always_null
local-zone: "indieclick.com" always_null
local-zone: "industrybrains.com" always_null
local-zone: "inetlog.ru" always_null
local-zone: "infinite-ads.com" always_null
local-zone: "infinityads.com" always_null
local-zone: "infolinks.com" always_null
local-zone: "information.com" always_null
local-zone: "inmobi.com" always_null
local-zone: "inner-active.com" always_null
local-zone: "innocentwax.com" always_null
local-zone: "innovid.com" always_null
local-zone: "inquisitiveinvention.com" always_null
local-zone: "inringtone.com" always_null
local-zone: "insgly.net" always_null
local-zone: "insightexpress.com" always_null
local-zone: "insightexpressai.com" always_null
local-zone: "inskinad.com" always_null
local-zone: "inspectlet.com" always_null
local-zone: "install.365-stream.com" always_null
local-zone: "instantmadness.com" always_null
local-zone: "insticator.com" always_null
local-zone: "instinctiveads.com" always_null
local-zone: "instrumentsponge.com" always_null
local-zone: "intelliads.com" always_null
local-zone: "intelligenceadx.com" always_null
local-zone: "intellitxt.com" always_null
local-zone: "intentsify.io" always_null
local-zone: "interactive.forthnet.gr" always_null
local-zone: "intergi.com" always_null
local-zone: "internetfuel.com" always_null
local-zone: "interreklame.de" always_null
local-zone: "intnotif.club" always_null
local-zone: "inventionpassenger.com" always_null
local-zone: "invitesugar.com" always_null
local-zone: "ioam.de" always_null
local-zone: "ip.ro" always_null
local-zone: "ip193.cn" always_null
local-zone: "iperceptions.com" always_null
local-zone: "ipredictive.com" always_null
local-zone: "ipstack.com" always_null
local-zone: "irchan.com" always_null
local-zone: "ireklama.cz" always_null
local-zone: "is-tracking-pixel-api-prod.appspot.com" always_null
local-zone: "itfarm.com" always_null
local-zone: "itop.cz" always_null
local-zone: "its-that-easy.com" always_null
local-zone: "itsptp.com" always_null
local-zone: "ivwbox.de" always_null
local-zone: "ivykiosk.com" always_null
local-zone: "iyfnzgb.com" always_null
local-zone: "j93557g.com" always_null
local-zone: "jadeitite.com" always_null
local-zone: "jads.co" always_null
local-zone: "jaizouji.com" always_null
local-zone: "jauchuwa.net" always_null
local-zone: "jcount.com" always_null
local-zone: "jdoqocy.com" always_null
local-zone: "jinkads.de" always_null
local-zone: "joetec.net" always_null
local-zone: "js-agent.newrelic.com" always_null
local-zone: "js.users.51.la" always_null
local-zone: "jsecoin.com" always_null
local-zone: "jsrdn.com" always_null
local-zone: "juicyads.com" always_null
local-zone: "juicyads.me" always_null
local-zone: "jumptap.com" always_null
local-zone: "jungroup.com" always_null
local-zone: "justicejudo.com" always_null
local-zone: "justpremium.com" always_null
local-zone: "justrelevant.com" always_null
local-zone: "k.iinfo.cz" always_null
local-zone: "kameleoon.eu" always_null
local-zone: "kanoodle.com" always_null
local-zone: "kargo.com" always_null
local-zone: "karonty.com" always_null
local-zone: "kesmatic.com" always_null
local-zone: "keymedia.hu" always_null
local-zone: "kindads.com" always_null
local-zone: "kissmetrics.com" always_null
local-zone: "klclick.com" always_null
local-zone: "klclick1.com" always_null
local-zone: "kliks.nl" always_null
local-zone: "klsdee.com" always_null
local-zone: "kmpiframe.keepmeposted.com.mt" always_null
local-zone: "knorex.com" always_null
local-zone: "komoona.com" always_null
local-zone: "kompasads.com" always_null
local-zone: "kontera.com" always_null
local-zone: "kost.tv" always_null
local-zone: "kpu.samsungelectronics.com" always_null
local-zone: "krxd.net" always_null
local-zone: "kt5850pjz0.com" always_null
local-zone: "ktu.sv2.biz" always_null
local-zone: "kubient.com" always_null
local-zone: "l1.britannica.com" always_null
local-zone: "l6b587txj1.com" always_null
local-zone: "lakequincy.com" always_null
local-zone: "lameletters.com" always_null
local-zone: "lanistaads.com" always_null
local-zone: "larati.net" always_null
local-zone: "laughablecopper.com" always_null
local-zone: "laughcloth.com" always_null
local-zone: "launchbit.com" always_null
local-zone: "layer-ad.de" always_null
local-zone: "layer-ads.de" always_null
local-zone: "lbn.ru" always_null
local-zone: "lead-analytics.nl" always_null
local-zone: "leadboltads.net" always_null
local-zone: "leadclick.com" always_null
local-zone: "leadingedgecash.com" always_null
local-zone: "leadplace.fr" always_null
local-zone: "leady.com" always_null
local-zone: "leadzupc.com" always_null
local-zone: "leaplunchroom.com" always_null
local-zone: "lemmatechnologies.com" always_null
local-zone: "lettucelimit.com" always_null
local-zone: "levelrate.de" always_null
local-zone: "lever-analytics.com" always_null
local-zone: "lfeeder.com" always_null
local-zone: "lfstmedia.com" always_null
local-zone: "li.alibris.com" always_null
local-zone: "li.azstarnet.com" always_null
local-zone: "li.dailycaller.com" always_null
local-zone: "li.gatehousemedia.com" always_null
local-zone: "li.gq.com" always_null
local-zone: "li.hearstmags.com" always_null
local-zone: "li.livingsocial.com" always_null
local-zone: "li.mw.drhinternet.net" always_null
local-zone: "li.onetravel.com" always_null
local-zone: "li.patheos.com" always_null
local-zone: "li.pmc.com" always_null
local-zone: "li.purch.com" always_null
local-zone: "li.realtor.com" always_null
local-zone: "li.walmart.com" always_null
local-zone: "li.ziffimages.com" always_null
local-zone: "liadm.com" always_null
local-zone: "lifeimpressions.net" always_null
local-zone: "liftdna.com" always_null
local-zone: "ligatus.com" always_null
local-zone: "ligatus.de" always_null
local-zone: "lightcast.leadscoringcenter.com" always_null
local-zone: "lightcushion.com" always_null
local-zone: "lightspeedcash.com" always_null
local-zone: "lijit.com" always_null
local-zone: "link-booster.de" always_null
local-zone: "link4ads.com" always_null
local-zone: "linkadd.de" always_null
local-zone: "linkbuddies.com" always_null
local-zone: "linkexchange.com" always_null
local-zone: "linkprice.com" always_null
local-zone: "linkrain.com" always_null
local-zone: "linkreferral.com" always_null
local-zone: "links-ranking.de" always_null
local-zone: "linkshighway.com" always_null
local-zone: "linkstorms.com" always_null
local-zone: "linkswaper.com" always_null
local-zone: "linktarget.com" always_null
local-zone: "liquidad.narrowcastmedia.com" always_null
local-zone: "litix.io" always_null
local-zone: "liveadexchanger.com" always_null
local-zone: "liveintent.com" always_null
local-zone: "livelylaugh.com" always_null
local-zone: "liverail.com" always_null
local-zone: "lizardslaugh.com" always_null
local-zone: "lkqd.com" always_null
local-zone: "lnks.gd" always_null
local-zone: "loading321.com" always_null
local-zone: "locked4.com" always_null
local-zone: "lockerdome.com" always_null
local-zone: "locpub.com" always_null
local-zone: "log.btopenworld.com" always_null
local-zone: "log.logrocket.io" always_null
local-zone: "log.pinterest.com" always_null
local-zone: "log.videocampaign.co" always_null
local-zone: "logger.snackly.co" always_null
local-zone: "logs.roku.com" always_null
local-zone: "logs.spilgames.com" always_null
local-zone: "logsss.com" always_null
local-zone: "logua.com" always_null
local-zone: "longinglettuce.com" always_null
local-zone: "look.djfiln.com" always_null
local-zone: "look.ichlnk.com" always_null
local-zone: "look.opskln.com" always_null
local-zone: "look.udncoeln.com" always_null
local-zone: "look.ufinkln.com" always_null
local-zone: "loopme.com" always_null
local-zone: "lop.com" always_null
local-zone: "loudlunch.com" always_null
local-zone: "lp3tdqle.com" always_null
local-zone: "lucidmedia.com" always_null
local-zone: "lucklayed.info" always_null
local-zone: "luckyorange.com" always_null
local-zone: "lytics.io" always_null
local-zone: "lzjl.com" always_null
local-zone: "m.trb.com" always_null
local-zone: "m1.webstats4u.com" always_null
local-zone: "m2.ai" always_null
local-zone: "m32.media" always_null
local-zone: "m4n.nl" always_null
local-zone: "m6r.eu" always_null
local-zone: "mackeeperapp.mackeeper.com" always_null
local-zone: "madclient.uimserv.net" always_null
local-zone: "madcpms.com" always_null
local-zone: "madinad.com" always_null
local-zone: "madisonavenue.com" always_null
local-zone: "madvertise.de" always_null
local-zone: "magicadz.co" always_null
local-zone: "magnificentmist.com" always_null
local-zone: "mail-ads.google.com" always_null
local-zone: "manageadv.cblogs.eu" always_null
local-zone: "marchex.com" always_null
local-zone: "marinsm.com" always_null
local-zone: "markedcrayon.com" always_null
local-zone: "markedpail.com" always_null
local-zone: "market-buster.com" always_null
local-zone: "marketing.888.com" always_null
local-zone: "marketing.hearstmagazines.nl" always_null
local-zone: "marketing.net.brillen.de" always_null
local-zone: "marketing.net.home24.de" always_null
local-zone: "marketing.nyi.net" always_null
local-zone: "marketing.osijek031.com" always_null
local-zone: "marketingsolutions.yahoo.com" always_null
local-zone: "marketo.com" always_null
local-zone: "mas.sector.sk" always_null
local-zone: "massivemark.com" always_null
local-zone: "matchcraft.com" always_null
local-zone: "materialmoon.com" always_null
local-zone: "matheranalytics.com" always_null
local-zone: "mathtag.com" always_null
local-zone: "matomo.activate.cz" always_null
local-zone: "matomo.gals24.ru" always_null
local-zone: "matomo.hdweb.ru" always_null
local-zone: "matomo.kmkb.ru" always_null
local-zone: "matomo.zwetok.ru" always_null
local-zone: "mautic.com" always_null
local-zone: "max.i12.de" always_null
local-zone: "maximiser.net" always_null
local-zone: "maximumcash.com" always_null
local-zone: "maxonclick.com" always_null
local-zone: "mbs.megaroticlive.com" always_null
local-zone: "mcdlks.com" always_null
local-zone: "measure.office.com" always_null
local-zone: "measuremap.com" always_null
local-zone: "media-adrunner.mycomputer.com" always_null
local-zone: "media-servers.net" always_null
local-zone: "media.funpic.de" always_null
local-zone: "media.net" always_null
local-zone: "media01.eu" always_null
local-zone: "media6degrees.com" always_null
local-zone: "mediaarea.eu" always_null
local-zone: "mediabridge.cc" always_null
local-zone: "mediacharger.com" always_null
local-zone: "mediageneral.com" always_null
local-zone: "mediaiqdigital.com" always_null
local-zone: "mediamath.com" always_null
local-zone: "mediamgr.ugo.com" always_null
local-zone: "mediaplazza.com" always_null
local-zone: "mediaplex.com" always_null
local-zone: "mediascale.de" always_null
local-zone: "mediaserver.bwinpartypartners.it" always_null
local-zone: "mediasmart.io" always_null
local-zone: "mediatext.com" always_null
local-zone: "mediavine.com" always_null
local-zone: "mediavoice.com" always_null
local-zone: "mediax.angloinfo.com" always_null
local-zone: "mediaz.angloinfo.com" always_null
local-zone: "medleyads.com" always_null
local-zone: "medyanetads.com" always_null
local-zone: "meetrics.net" always_null
local-zone: "megacash.de" always_null
local-zone: "megapu.sh" always_null
local-zone: "megastats.com" always_null
local-zone: "megawerbung.de" always_null
local-zone: "mellowads.com" always_null
local-zone: "memorizeneck.com" always_null
local-zone: "memorycobweb.com" always_null
local-zone: "messagenovice.com" always_null
local-zone: "metadsp.co.uk" always_null
local-zone: "metaffiliation.com" always_null
local-zone: "metanetwork.com" always_null
local-zone: "methodcash.com" always_null
local-zone: "metrics-logger.spot.im" always_null
local-zone: "metrics.api.drift.com" always_null
local-zone: "metrics.cnn.com" always_null
local-zone: "metrics.consumerreports.org" always_null
local-zone: "metrics.ctv.ca" always_null
local-zone: "metrics.foxnews.com" always_null
local-zone: "metrics.getrockerbox.com" always_null
local-zone: "metrics.gfycat.com" always_null
local-zone: "metrics.govexec.com" always_null
local-zone: "metrics.icloud.com" always_null
local-zone: "metrics.mzstatic.com" always_null
local-zone: "metrilo.com" always_null
local-zone: "mfadsrvr.com" always_null
local-zone: "mg2connext.com" always_null
local-zone: "mgid.com" always_null
local-zone: "microstatic.pl" always_null
local-zone: "microticker.com" always_null
local-zone: "militaryverse.com" always_null
local-zone: "milotree.com" always_null
local-zone: "minewhat.com" always_null
local-zone: "minormeeting.com" always_null
local-zone: "mintegral.com" always_null
local-zone: "mixedreading.com" always_null
local-zone: "mixpanel.com" always_null
local-zone: "mkto-ab410147.com" always_null
local-zone: "mktoresp.com" always_null
local-zone: "ml314.com" always_null
local-zone: "mlm.de" always_null
local-zone: "mltrk.io" always_null
local-zone: "mmismm.com" always_null
local-zone: "mmstat.com" always_null
local-zone: "mmtro.com" always_null
local-zone: "moartraffic.com" always_null
local-zone: "moat.com" always_null
local-zone: "moatads.com" always_null
local-zone: "moatpixel.com" always_null
local-zone: "mobclix.com" always_null
local-zone: "mobfox.com" always_null
local-zone: "mobileanalytics.us-east-1.amazonaws.com" always_null
local-zone: "mobilefuse.com" always_null
local-zone: "mobperads.net" always_null
local-zone: "modernpricing.com" always_null
local-zone: "modifyeyes.com" always_null
local-zone: "moldyicicle.com" always_null
local-zone: "mon.byteoversea.com" always_null
local-zone: "monarchads.com" always_null
local-zone: "monetate.net" always_null
local-zone: "monetizer101.com" always_null
local-zone: "moneyexpert.co.uk" always_null
local-zone: "monsterpops.com" always_null
local-zone: "mookie1.com" always_null
local-zone: "mopub.com" always_null
local-zone: "motionspots.com" always_null
local-zone: "mouseflow.com" always_null
local-zone: "mousestats.com" always_null
local-zone: "movad.net" always_null
local-zone: "mowfruit.com" always_null
local-zone: "mparticle.com" always_null
local-zone: "mpstat.us" always_null
local-zone: "mr-rank.de" always_null
local-zone: "mrskincash.com" always_null
local-zone: "mstrlytcs.com" always_null
local-zone: "mtrcs.samba.tv" always_null
local-zone: "mtree.com" always_null
local-zone: "munchkin.marketo.net" always_null
local-zone: "mundanepollution.com" always_null
local-zone: "musiccounter.ru" always_null
local-zone: "muwmedia.com" always_null
local-zone: "mxptint.net" always_null
local-zone: "myads.company" always_null
local-zone: "myads.net" always_null
local-zone: "myads.telkomsel.com" always_null
local-zone: "myaffiliateprogram.com" always_null
local-zone: "mybestmv.com" always_null
local-zone: "mybetterdl.com" always_null
local-zone: "mybloglog.com" always_null
local-zone: "mybuys.com" always_null
local-zone: "mycounter.ua" always_null
local-zone: "mydas.mobi" always_null
local-zone: "mylink-today.com" always_null
local-zone: "mypagerank.net" always_null
local-zone: "mypagerank.ru" always_null
local-zone: "mypowermall.com" always_null
local-zone: "mysafeads.com" always_null
local-zone: "mystat-in.net" always_null
local-zone: "mystat.pl" always_null
local-zone: "mysteriousmonth.com" always_null
local-zone: "mytop-in.net" always_null
local-zone: "mytrackingservers.com" always_null
local-zone: "myvisualiq.net" always_null
local-zone: "n69.com" always_null
local-zone: "naj.sk" always_null
local-zone: "nappyattack.com" always_null
local-zone: "naradxb.com" always_null
local-zone: "nastydollars.com" always_null
local-zone: "nativeroll.tv" always_null
local-zone: "naturalbid.com" always_null
local-zone: "navegg.com" always_null
local-zone: "navigator.io" always_null
local-zone: "navrcholu.cz" always_null
local-zone: "ncaudienceexchange.com" always_null
local-zone: "ndparking.com" always_null
local-zone: "nedstatbasic.net" always_null
local-zone: "neighborlywatch.com" always_null
local-zone: "nend.net" always_null
local-zone: "neocounter.neoworx-blog-tools.net" always_null
local-zone: "nervoussummer.com" always_null
local-zone: "net-filter.com" always_null
local-zone: "netaffiliation.com" always_null
local-zone: "netagent.cz" always_null
local-zone: "netclickstats.com" always_null
local-zone: "netcommunities.com" always_null
local-zone: "netdirect.nl" always_null
local-zone: "netincap.com" always_null
local-zone: "netmng.com" always_null
local-zone: "netpool.netbookia.net" always_null
local-zone: "netshelter.net" always_null
local-zone: "neudesicmediagroup.com" always_null
local-zone: "newads.bangbros.com" always_null
local-zone: "newbie.com" always_null
local-zone: "newnet.qsrch.com" always_null
local-zone: "newnudecash.com" always_null
local-zone: "newopenx.detik.com" always_null
local-zone: "newsadsppush.com" always_null
local-zone: "newsletter-link.com" always_null
local-zone: "newstarads.com" always_null
local-zone: "newt1.adultadworld.com" always_null
local-zone: "newt1.adultworld.com" always_null
local-zone: "nexac.com" always_null
local-zone: "nexage.com" always_null
local-zone: "ng3.ads.warnerbros.com" always_null
local-zone: "nhpfvdlbjg.com" always_null
local-zone: "nitratory.com" always_null
local-zone: "nitroclicks.com" always_null
local-zone: "noiselessplough.com" always_null
local-zone: "nondescriptcrowd.com" always_null
local-zone: "nondescriptnote.com" always_null
local-zone: "nondescriptsmile.com" always_null
local-zone: "nondescriptstocking.com" always_null
local-zone: "novem.pl" always_null
local-zone: "npttech.com" always_null
local-zone: "nr-data.net" always_null
local-zone: "ns1p.net" always_null
local-zone: "ntv.io" always_null
local-zone: "ntvk1.ru" always_null
local-zone: "nuggad.net" always_null
local-zone: "nuseek.com" always_null
local-zone: "nuttyorganization.com" always_null
local-zone: "nzaza.com" always_null
local-zone: "o0bc.com" always_null
local-zone: "o333o.com" always_null
local-zone: "oafishobservation.com" always_null
local-zone: "oas.benchmark.fr" always_null
local-zone: "oas.repubblica.it" always_null
local-zone: "oas.roanoke.com" always_null
local-zone: "oas.toronto.com" always_null
local-zone: "oas.uniontrib.com" always_null
local-zone: "oas.villagevoice.com" always_null
local-zone: "oascentral.chicagobusiness.com" always_null
local-zone: "oascentral.fortunecity.com" always_null
local-zone: "oascentral.register.com" always_null
local-zone: "obscenesidewalk.com" always_null
local-zone: "observantice.com" always_null
local-zone: "oclasrv.com" always_null
local-zone: "odbierz-bony.ovp.pl" always_null
local-zone: "oewa.at" always_null
local-zone: "offaces-butional.com" always_null
local-zone: "offer.fyber.com" always_null
local-zone: "offer.sponsorpay.com" always_null
local-zone: "offerforge.com" always_null
local-zone: "offermatica.com" always_null
local-zone: "offshoreanglehost.com" always_null
local-zone: "oglasi.posjetnica.com" always_null
local-zone: "ogury.com" always_null
local-zone: "ojrq.net" always_null
local-zone: "omnijay.com" always_null
local-zone: "omniscientspark.com" always_null
local-zone: "omniture.com" always_null
local-zone: "omtrdc.net" always_null
local-zone: "onaudience.com" always_null
local-zone: "onclasrv.com" always_null
local-zone: "onclickads.net" always_null
local-zone: "onctus.com" always_null
local-zone: "oneandonlynetwork.com" always_null
local-zone: "onenag.com" always_null
local-zone: "onenetworkdirect.com" always_null
local-zone: "onestat.com" always_null
local-zone: "onestatfree.com" always_null
local-zone: "online-metrix.net" always_null
local-zone: "online.miarroba.com" always_null
local-zone: "onlinecash.com" always_null
local-zone: "onlinecashmethod.com" always_null
local-zone: "onlinerewardcenter.com" always_null
local-zone: "onscroll.com" always_null
local-zone: "onthe.io" always_null
local-zone: "opads.us" always_null
local-zone: "open.oneplus.net" always_null
local-zone: "openad.tf1.fr" always_null
local-zone: "openad.travelnow.com" always_null
local-zone: "openads.friendfinder.com" always_null
local-zone: "openads.org" always_null
local-zone: "openadsnetwork.com" always_null
local-zone: "opentag-stats.qubit.com" always_null
local-zone: "openx.actvtech.com" always_null
local-zone: "openx.angelsgroup.org.uk" always_null
local-zone: "openx.cairo360.com" always_null
local-zone: "openx.kgmedia.eu" always_null
local-zone: "openx.net" always_null
local-zone: "openx.skinet.cz" always_null
local-zone: "openx.smcaen.fr" always_null
local-zone: "openx2.kytary.cz" always_null
local-zone: "operationkettle.com" always_null
local-zone: "opienetwork.com" always_null
local-zone: "opmnstr.com" always_null
local-zone: "optimallimit.com" always_null
local-zone: "optimize-stats.voxmedia.com" always_null
local-zone: "optimizely.com" always_null
local-zone: "optimost.com" always_null
local-zone: "optmd.com" always_null
local-zone: "optmnstr.com" always_null
local-zone: "optmstr.com" always_null
local-zone: "optnmstr.com" always_null
local-zone: "ota.cartrawler.com" always_null
local-zone: "otto-images.developershed.com" always_null
local-zone: "outbrain.com" always_null
local-zone: "overconfidentfood.com" always_null
local-zone: "overture.com" always_null
local-zone: "owebanalytics.com" always_null
local-zone: "owebmoney.ru" always_null
local-zone: "owlsr.us" always_null
local-zone: "owneriq.net" always_null
local-zone: "ox1.shopcool.com.tw" always_null
local-zone: "oxado.com" always_null
local-zone: "oxcash.com" always_null
local-zone: "oxen.hillcountrytexas.com" always_null
local-zone: "p-n.io" always_null
local-zone: "p.nag.ru" always_null
local-zone: "p2r14.com" always_null
local-zone: "padsbrown.com" always_null
local-zone: "pagead.l.google.com" always_null
local-zone: "pagefair.com" always_null
local-zone: "pagefair.net" always_null
local-zone: "pagerank-ranking.de" always_null
local-zone: "pagerank4you.com" always_null
local-zone: "pageranktop.com" always_null
local-zone: "paleleaf.com" always_null
local-zone: "panickycurtain.com" always_null
local-zone: "panickypancake.com" always_null
local-zone: "paradoxfactor.com" always_null
local-zone: "parchedangle.com" always_null
local-zone: "parchedsofa.com" always_null
local-zone: "parketsy.pro" always_null
local-zone: "parsely.com" always_null
local-zone: "parsimoniouspolice.com" always_null
local-zone: "partner-ads.com" always_null
local-zone: "partner.pelikan.cz" always_null
local-zone: "partnerad.l.google.com" always_null
local-zone: "partnerads.ysm.yahoo.com" always_null
local-zone: "partnercash.de" always_null
local-zone: "partners.priceline.com" always_null
local-zone: "passeura.com" always_null
local-zone: "paxtro.com" always_null
local-zone: "paycounter.com" always_null
local-zone: "paypopup.com" always_null
local-zone: "pbnet.ru" always_null
local-zone: "pbterra.com" always_null
local-zone: "pcash.imlive.com" always_null
local-zone: "pctracking.net" always_null
local-zone: "peep-auktion.de" always_null
local-zone: "peer39.com" always_null
local-zone: "pennyweb.com" always_null
local-zone: "pepperjamnetwork.com" always_null
local-zone: "perceivequarter.com" always_null
local-zone: "percentmobile.com" always_null
local-zone: "perfectaudience.com" always_null
local-zone: "perfiliate.com" always_null
local-zone: "performancerevenue.com" always_null
local-zone: "performancerevenues.com" always_null
local-zone: "performancing.com" always_null
local-zone: "permutive.com" always_null
local-zone: "personagraph.com" always_null
local-zone: "petiteumbrella.com" always_null
local-zone: "pgl.example.com" always_null
local-zone: "pgl.example0101" always_null
local-zone: "pgmediaserve.com" always_null
local-zone: "pgpartner.com" always_null
local-zone: "pheedo.com" always_null
local-zone: "phoenix-adrunner.mycomputer.com" always_null
local-zone: "photographpan.com" always_null
local-zone: "phpadsnew.new.natuurpark.nl" always_null
local-zone: "piano.io" always_null
local-zone: "picadmedia.com" always_null
local-zone: "piet2eix3l.com" always_null
local-zone: "pietexture.com" always_null
local-zone: "pilotaffiliate.com" always_null
local-zone: "pimproll.com" always_null
local-zone: "ping.ublock.org" always_null
local-zone: "pipedream.wistia.com" always_null
local-zone: "pippio.com" always_null
local-zone: "piquantpigs.com" always_null
local-zone: "pix.spot.im" always_null
local-zone: "pixel.adsafeprotected.com" always_null
local-zone: "pixel.condenastdigital.com" always_null
local-zone: "pixel.digitru.st" always_null
local-zone: "pixel.keywee.co" always_null
local-zone: "pixel.mtrcs.samba.tv" always_null
local-zone: "pixel.sojern.com" always_null
local-zone: "pixel.watch" always_null
local-zone: "pixel.yabidos.com" always_null
local-zone: "placed.com" always_null
local-zone: "plardi.com" always_null
local-zone: "plausibleio.workers.dev" always_null
local-zone: "play4traffic.com" always_null
local-zone: "playhaven.com" always_null
local-zone: "pleasantpump.com" always_null
local-zone: "plista.com" always_null
local-zone: "plotrabbit.com" always_null
local-zone: "ployea.com" always_null
local-zone: "pluckypocket.com" always_null
local-zone: "plugrush.com" always_null
local-zone: "pocketmath.com" always_null
local-zone: "pointroll.com" always_null
local-zone: "pokkt.com" always_null
local-zone: "popads.net" always_null
local-zone: "popcash.net" always_null
local-zone: "popmyads.com" always_null
local-zone: "popub.com" always_null
local-zone: "popunder.ru" always_null
local-zone: "popunhot1.blogspot.com" always_null
local-zone: "popup.msn.com" always_null
local-zone: "popupmoney.com" always_null
local-zone: "popupnation.com" always_null
local-zone: "popuptraffic.com" always_null
local-zone: "porngraph.com" always_null
local-zone: "porntrack.com" always_null
local-zone: "possessivebucket.com" always_null
local-zone: "possibleboats.com" always_null
local-zone: "post.spmailtechno.com" always_null
local-zone: "postback.iqm.com" always_null
local-zone: "postrelease.com" always_null
local-zone: "pr-star.de" always_null
local-zone: "praddpro.de" always_null
local-zone: "prchecker.info" always_null
local-zone: "prebid.org" always_null
local-zone: "predictad.com" always_null
local-zone: "premium-offers.com" always_null
local-zone: "presetrabbits.com" always_null
local-zone: "previousplayground.com" always_null
local-zone: "previouspotato.com" always_null
local-zone: "priefy.com" always_null
local-zone: "primetime.net" always_null
local-zone: "privatecash.com" always_null
local-zone: "prmtracking.com" always_null
local-zone: "pro-advertising.com" always_null
local-zone: "pro-market.net" always_null
local-zone: "producecopy.com" always_null
local-zone: "producer.getwisdom.io" always_null
local-zone: "proext.com" always_null
local-zone: "profero.com" always_null
local-zone: "profitrumour.com" always_null
local-zone: "programattik.com" always_null
local-zone: "projectwonderful.com" always_null
local-zone: "promo.badoink.com" always_null
local-zone: "promo.ulust.com" always_null
local-zone: "promobenef.com" always_null
local-zone: "promos.bwin.it" always_null
local-zone: "promos.fling.com" always_null
local-zone: "promote.pair.com" always_null
local-zone: "promotions-884485.c.cdn77.org" always_null
local-zone: "pronetadvertising.com" always_null
local-zone: "proof-x.com" always_null
local-zone: "propellerads.com" always_null
local-zone: "propellerclick.com" always_null
local-zone: "proper.io" always_null
local-zone: "props.id" always_null
local-zone: "prosper.on-line-casino.ca" always_null
local-zone: "protectcrev.com" always_null
local-zone: "protectsubrev.com" always_null
local-zone: "proton-tm.com" always_null
local-zone: "protraffic.com" always_null
local-zone: "provexia.com" always_null
local-zone: "prsaln.com" always_null
local-zone: "prsitecheck.com" always_null
local-zone: "prudencewiserelapse.com" always_null
local-zone: "pstmrk.it" always_null
local-zone: "ptoushoa.com" always_null
local-zone: "pub.chez.com" always_null
local-zone: "pub.club-internet.fr" always_null
local-zone: "pub.hardware.fr" always_null
local-zone: "pub.network" always_null
local-zone: "pub.realmedia.fr" always_null
local-zone: "pubdirecte.com" always_null
local-zone: "publicidad.elmundo.es" always_null
local-zone: "publicidees.com" always_null
local-zone: "pubmatic.com" always_null
local-zone: "pubmine.com" always_null
local-zone: "pubnative.net" always_null
local-zone: "pubwes.com" always_null
local-zone: "puffyloss.com" always_null
local-zone: "puffypaste.com" always_null
local-zone: "puffypull.com" always_null
local-zone: "puffypurpose.com" always_null
local-zone: "pushame.com" always_null
local-zone: "pushance.com" always_null
local-zone: "pushazer.com" always_null
local-zone: "pushengage.com" always_null
local-zone: "pushno.com" always_null
local-zone: "pushtrack.co" always_null
local-zone: "pushwhy.com" always_null
local-zone: "px.ads.linkedin.com" always_null
local-zone: "px.dynamicyield.com" always_null
local-zone: "px.gfycat.com" always_null
local-zone: "px.spiceworks.com" always_null
local-zone: "pxf.io" always_null
local-zone: "pxl.iqm.com" always_null
local-zone: "pymx5.com" always_null
local-zone: "q.azcentral.com" always_null
local-zone: "q1connect.com" always_null
local-zone: "qctop.com" always_null
local-zone: "qnsr.com" always_null
local-zone: "quacksquirrel.com" always_null
local-zone: "quaintcan.com" always_null
local-zone: "quantcast.com" always_null
local-zone: "quantcount.com" always_null
local-zone: "quantserve.com" always_null
local-zone: "quantummetric.com" always_null
local-zone: "quarterbean.com" always_null
local-zone: "quarterserver.de" always_null
local-zone: "questaffiliates.net" always_null
local-zone: "quickkoala.io" always_null
local-zone: "quicksandear.com" always_null
local-zone: "quietknowledge.com" always_null
local-zone: "quinst.com" always_null
local-zone: "quisma.com" always_null
local-zone: "quizzicalzephyr.com" always_null
local-zone: "r.logrocket.io" always_null
local-zone: "r.msn.com" always_null
local-zone: "r.scoota.co" always_null
local-zone: "r.sibmail.havasit.com" always_null
local-zone: "r1.visualwebsiteoptimizer.com" always_null
local-zone: "r2.visualwebsiteoptimizer.com" always_null
local-zone: "r3.visualwebsiteoptimizer.com" always_null
local-zone: "radar.cedexis.com" always_null
local-zone: "radarurl.com" always_null
local-zone: "radiate.com" always_null
local-zone: "rads.alfamedia.pl" always_null
local-zone: "rads.realadmin.pl" always_null
local-zone: "railwayrainstorm.com" always_null
local-zone: "railwayreason.com" always_null
local-zone: "rampidads.com" always_null
local-zone: "rank-master.com" always_null
local-zone: "rankchamp.de" always_null
local-zone: "ranking-charts.de" always_null
local-zone: "ranking-hits.de" always_null
local-zone: "ranking-links.de" always_null
local-zone: "ranking-liste.de" always_null
local-zone: "rankingchart.de" always_null
local-zone: "rankingscout.com" always_null
local-zone: "rankyou.com" always_null
local-zone: "rapidcounter.com" always_null
local-zone: "rapidkittens.com" always_null
local-zone: "raresummer.com" always_null
local-zone: "rate.ru" always_null
local-zone: "ratings.lycos.com" always_null
local-zone: "rayjump.com" always_null
local-zone: "re-directme.com" always_null
local-zone: "reachjunction.com" always_null
local-zone: "reactx.com" always_null
local-zone: "readgoldfish.com" always_null
local-zone: "readingguilt.com" always_null
local-zone: "readingopera.com" always_null
local-zone: "readserver.net" always_null
local-zone: "readymoon.com" always_null
local-zone: "realcastmedia.com" always_null
local-zone: "realclever.com" always_null
local-zone: "realclix.com" always_null
local-zone: "realmedia-a800.d4p.net" always_null
local-zone: "realsrv.com" always_null
local-zone: "realtechnetwork.com" always_null
local-zone: "realtracker.com" always_null
local-zone: "rebelsubway.com" always_null
local-zone: "rec5.visualwebsiteoptimizer.com" always_null
local-zone: "receptiveink.com" always_null
local-zone: "receptivereaction.com" always_null
local-zone: "recoco.it" always_null
local-zone: "reconditerake.com" always_null
local-zone: "record.affiliates.karjalakasino.com" always_null
local-zone: "record.bonniergaming.com" always_null
local-zone: "record.mrwin.com" always_null
local-zone: "always_nullingat.com" always_null
local-zone: "always_nullvoluum.com" always_null
local-zone: "redshell.io" always_null
local-zone: "reduxmedia.com" always_null
local-zone: "referralware.com" always_null
local-zone: "referrer.disqus.com" always_null
local-zone: "reflectivereward.com" always_null
local-zone: "reforge.in" always_null
local-zone: "regnow.com" always_null
local-zone: "regularplants.com" always_null
local-zone: "reklam.rfsl.se" always_null
local-zone: "reklama.mironet.cz" always_null
local-zone: "reklamcsere.hu" always_null
local-zone: "reklamdsp.com" always_null
local-zone: "relevanz10.de" always_null
local-zone: "relmaxtop.com" always_null
local-zone: "remox.com" always_null
local-zone: "republika.onet.pl" always_null
local-zone: "resalag.com" always_null
local-zone: "research.de.com" always_null
local-zone: "resolutekey.com" always_null
local-zone: "resonantbrush.com" always_null
local-zone: "resonate.com" always_null
local-zone: "responsiveads.com" always_null
local-zone: "retargeter.com" always_null
local-zone: "revcatch.com" always_null
local-zone: "revcontent.com" always_null
local-zone: "reveal.clearbit.com" always_null
local-zone: "revenuedirect.com" always_null
local-zone: "revenuehits.com" always_null
local-zone: "revive.docmatic.org" always_null
local-zone: "revive.dubcnm.com" always_null
local-zone: "revive.haskovo.net" always_null
local-zone: "revive.netriota.hu" always_null
local-zone: "revive.plays.bg" always_null
local-zone: "revlift.io" always_null
local-zone: "revprotect.com" always_null
local-zone: "revsci.net" always_null
local-zone: "revstats.com" always_null
local-zone: "reyden-x.com" always_null
local-zone: "rhombusads.com" always_null
local-zone: "rhythmone.com" always_null
local-zone: "richmails.com" always_null
local-zone: "richmedia.yimg.com" always_null
local-zone: "richstring.com" always_null
local-zone: "rightstats.com" always_null
local-zone: "rinconpx.net" always_null
local-zone: "ringsrecord.com" always_null
local-zone: "ritzykey.com" always_null
local-zone: "rlcdn.com" always_null
local-zone: "rle.ru" always_null
local-zone: "rmads.msn.com" always_null
local-zone: "rmedia.boston.com" always_null
local-zone: "rmgserving.com" always_null
local-zone: "roar.com" always_null
local-zone: "robotreplay.com" always_null
local-zone: "rockabox.co" always_null
local-zone: "roia.biz" always_null
local-zone: "rok.com.com" always_null
local-zone: "roq.ad" always_null
local-zone: "rose.ixbt.com" always_null
local-zone: "rotabanner.com" always_null
local-zone: "roughroll.com" always_null
local-zone: "roxr.net" always_null
local-zone: "rs6.net" always_null
local-zone: "rta.dailymail.co.uk" always_null
local-zone: "rtb.gumgum.com" always_null
local-zone: "rtbadzesto.com" always_null
local-zone: "rtbflairads.com" always_null
local-zone: "rtbidhost.com" always_null
local-zone: "rtbplatform.net" always_null
local-zone: "rtbpop.com" always_null
local-zone: "rtbpopd.com" always_null
local-zone: "rtbtradein.com" always_null
local-zone: "rtmark.net" always_null
local-zone: "rtpdn11.com" always_null
local-zone: "rtxplatform.com" always_null
local-zone: "ru4.com" always_null
local-zone: "rubiconproject.com" always_null
local-zone: "rum-http-intake.logs.datadoghq.com" always_null
local-zone: "rum-http-intake.logs.datadoghq.eu" always_null
local-zone: "runads.com" always_null
local-zone: "rundsp.com" always_null
local-zone: "ruthlessrobin.com" always_null
local-zone: "s.adroll.com" always_null
local-zone: "s1-adfly.com" always_null
local-zone: "s20dh7e9dh.com" always_null
local-zone: "s2d6.com" always_null
local-zone: "s2strk.info" always_null
local-zone: "sa.api.intl.miui.com" always_null
local-zone: "sabio.us" always_null
local-zone: "sageanalyst.net" always_null
local-zone: "sail-horizon.com" always_null
local-zone: "samsungacr.com" always_null
local-zone: "samsungads.com" always_null
local-zone: "sanity-dataplane.rudderstack.com" always_null
local-zone: "saysidewalk.com" always_null
local-zone: "sbx.pagesjaunes.fr" always_null
local-zone: "sc-analytics.appspot.com" always_null
local-zone: "scambiobanner.aruba.it" always_null
local-zone: "scanscout.com" always_null
local-zone: "scarcesign.com" always_null
local-zone: "scatteredheat.com" always_null
local-zone: "scintillatingscissors.com" always_null
local-zone: "scintillatingsilver.com" always_null
local-zone: "scintillatingspace.com" always_null
local-zone: "scoobyads.com" always_null
local-zone: "scopelight.com" always_null
local-zone: "scorecardresearch.com" always_null
local-zone: "scratch2cash.com" always_null
local-zone: "screechingfurniture.com" always_null
local-zone: "screechingstove.com" always_null
local-zone: "scripte-monster.de" always_null
local-zone: "scrubswim.com" always_null
local-zone: "sdkfjxjertertry.com" always_null
local-zone: "seadform.net" always_null
local-zone: "searching-place.com" always_null
local-zone: "searchmarketing.com" always_null
local-zone: "searchramp.com" always_null
local-zone: "secretivecub.com" always_null
local-zone: "secretspiders.com" always_null
local-zone: "secure.webconnect.net" always_null
local-zone: "securedopen-bp.com" always_null
local-zone: "securemetrics.apple.com" always_null
local-zone: "sedoparking.com" always_null
local-zone: "sedotracker.com" always_null
local-zone: "segmetrics.io" always_null
local-zone: "selectivesummer.com" always_null
local-zone: "semasio.net" always_null
local-zone: "sendmepixel.com" always_null
local-zone: "sensismediasmart.com.au" always_null
local-zone: "separatesilver.com" always_null
local-zone: "serv0.com" always_null
local-zone: "servads.net" always_null
local-zone: "servadsdisrupt.com" always_null
local-zone: "serve.tercept.com" always_null
local-zone: "servedby-buysellads.com" always_null
local-zone: "servedbyadbutler.com" always_null
local-zone: "servedbyopenx.com" always_null
local-zone: "servethis.com" always_null
local-zone: "services.hearstmags.com" always_null
local-zone: "serving-sys.com" always_null
local-zone: "sessioncam.com" always_null
local-zone: "sexcounter.com" always_null
local-zone: "sexinyourcity.com" always_null
local-zone: "sexlist.com" always_null
local-zone: "sextracker.com" always_null
local-zone: "shakegoldfish.com" always_null
local-zone: "shakesea.com" always_null
local-zone: "shakesuggestion.com" always_null
local-zone: "shakytaste.com" always_null
local-zone: "shallowsmile.com" always_null
local-zone: "shareadspace.com" always_null
local-zone: "shareasale.com" always_null
local-zone: "sharethrough.com" always_null
local-zone: "sharppatch.com" always_null
local-zone: "sher.index.hu" always_null
local-zone: "shermore.info" always_null
local-zone: "shinystat.com" always_null
local-zone: "shinystat.it" always_null
local-zone: "shockinggrass.com" always_null
local-zone: "shoppingads.com" always_null
local-zone: "shrillspoon.com" always_null
local-zone: "sicksmash.com" always_null
local-zone: "sidebar.angelfire.com" always_null
local-zone: "signalayer.com" always_null
local-zone: "silkysquirrel.com" always_null
local-zone: "sillyscrew.com" always_null
local-zone: "silvalliant.info" always_null
local-zone: "silvermob.com" always_null
local-zone: "simpleanalytics.io" always_null
local-zone: "simplehitcounter.com" always_null
local-zone: "simpli.fi" always_null
local-zone: "sincerebuffalo.com" always_null
local-zone: "sinoa.com" always_null
local-zone: "sitedataprocessing.com" always_null
local-zone: "siteimproveanalytics.com" always_null
local-zone: "siteimproveanalytics.io" always_null
local-zone: "siteintercept.qualtrics.com" always_null
local-zone: "sitemeter.com" always_null
local-zone: "sixscissors.com" always_null
local-zone: "sixsigmatraffic.com" always_null
local-zone: "sizesidewalk.com" always_null
local-zone: "sizmek.com" always_null
local-zone: "skimresources.com" always_null
local-zone: "skylink.vn" always_null
local-zone: "sleepcartoon.com" always_null
local-zone: "slipperysack.com" always_null
local-zone: "slopeaota.com" always_null
local-zone: "sluxur.com" always_null
local-zone: "smaato.com" always_null
local-zone: "smallbeginner.com" always_null
local-zone: "smart-traffik.com" always_null
local-zone: "smart-traffik.io" always_null
local-zone: "smart4ads.com" always_null
local-zone: "smartadserver.com" always_null
local-zone: "smartclip.net" always_null
local-zone: "smartlook.com" always_null
local-zone: "smartstream.tv" always_null
local-zone: "smartyads.com" always_null
local-zone: "smashsurprise.com" always_null
local-zone: "smetrics.10daily.com.au" always_null
local-zone: "smetrics.bestbuy.com" always_null
local-zone: "smetrics.ctv.ca" always_null
local-zone: "smetrics.fedex.com" always_null
local-zone: "smetrics.foxnews.com" always_null
local-zone: "smetrics.walgreens.com" always_null
local-zone: "smetrics.washingtonpost.com" always_null
local-zone: "smilingwaves.com" always_null
local-zone: "smoggysnakes.com" always_null
local-zone: "smrtb.com" always_null
local-zone: "snapads.com" always_null
local-zone: "snoobi.com" always_null
local-zone: "socialspark.com" always_null
local-zone: "softclick.com.br" always_null
local-zone: "soggysponge.com" always_null
local-zone: "sombersea.com" always_null
local-zone: "sombersquirrel.com" always_null
local-zone: "sombersurprise.com" always_null
local-zone: "somniture.stuff.co.nz" always_null
local-zone: "somoaudience.com" always_null
local-zone: "sonobi.com" always_null
local-zone: "sortable.com" always_null
local-zone: "sourcepoint.vice.com" always_null
local-zone: "sovrn.com" always_null
local-zone: "spacash.com" always_null
local-zone: "spaceleadster.com" always_null
local-zone: "spannersalesman.com" always_null
local-zone: "sparklingshelf.com" always_null
local-zone: "sparkstudios.com" always_null
local-zone: "specially4u.net" always_null
local-zone: "specificmedia.co.uk" always_null
local-zone: "specificpop.com" always_null
local-zone: "speedomizer.com" always_null
local-zone: "speedshiftmedia.com" always_null
local-zone: "speop.com" always_null
local-zone: "spezialreporte.de" always_null
local-zone: "spidersboats.com" always_null
local-zone: "spiffymachine.com" always_null
local-zone: "spinbox.techtracker.com" always_null
local-zone: "spinbox.versiontracker.com" always_null
local-zone: "spirebaboon.com" always_null
local-zone: "sponsorads.de" always_null
local-zone: "sponsorpro.de" always_null
local-zone: "sponsors.thoughtsmedia.com" always_null
local-zone: "spookysleet.com" always_null
local-zone: "sportsad.net" always_null
local-zone: "spot.fitness.com" always_null
local-zone: "spotlessstamp.com" always_null
local-zone: "spotscenered.info" always_null
local-zone: "spotx.tv" always_null
local-zone: "spotxchange.com" always_null
local-zone: "springaftermath.com" always_null
local-zone: "springserve.com" always_null
local-zone: "spulse.net" always_null
local-zone: "spurioussteam.com" always_null
local-zone: "spykemediatrack.com" always_null
local-zone: "spylog.com" always_null
local-zone: "spywarelabs.com" always_null
local-zone: "spywords.com" always_null
local-zone: "squirrelhands.com" always_null
local-zone: "srvmath.com" always_null
local-zone: "srvtrck.com" always_null
local-zone: "srwww1.com" always_null
local-zone: "st.dynamicyield.com" always_null
local-zone: "stack-sonar.com" always_null
local-zone: "stackadapt.com" always_null
local-zone: "stakingscrew.com" always_null
local-zone: "stakingslope.com" always_null
local-zone: "stalesummer.com" always_null
local-zone: "standingnest.com" always_null
local-zone: "starffa.com" always_null
local-zone: "start.freeze.com" always_null
local-zone: "startapp.com" always_null
local-zone: "stat-track.com" always_null
local-zone: "stat.cliche.se" always_null
local-zone: "stat.dyna.ultraweb.hu" always_null
local-zone: "stat.pl" always_null
local-zone: "stat.webmedia.pl" always_null
local-zone: "stat.xiaomi.com" always_null
local-zone: "stat.zenon.net" always_null
local-zone: "stat24.com" always_null
local-zone: "stat24.meta.ua" always_null
local-zone: "statcounter.com" always_null
local-zone: "statdynamic.com" always_null
local-zone: "static.a-ads.com" always_null
local-zone: "static.fmpub.net" always_null
local-zone: "static.itrack.it" always_null
local-zone: "static.kameleoon.com" always_null
local-zone: "staticads.btopenworld.com" always_null
local-zone: "statistik-gallup.net" always_null
local-zone: "statm.the-adult-company.com" always_null
local-zone: "stats.blogger.com" always_null
local-zone: "stats.hyperinzerce.cz" always_null
local-zone: "stats.merriam-webster.com" always_null
local-zone: "stats.mirrorfootball.co.uk" always_null
local-zone: "stats.nextgen-email.com" always_null
local-zone: "stats.olark.com" always_null
local-zone: "stats.pusher.com" always_null
local-zone: "stats.rdphv.net" always_null
local-zone: "stats.self.com" always_null
local-zone: "stats.stb-ottow.de" always_null
local-zone: "stats.townnews.com" always_null
local-zone: "stats.wordpress.com" always_null
local-zone: "stats.wp.com" always_null
local-zone: "stats.x14.eu" always_null
local-zone: "stats2.self.com" always_null
local-zone: "stats4all.com" always_null
local-zone: "statserv.net" always_null
local-zone: "statsie.com" always_null
local-zone: "statxpress.com" always_null
local-zone: "steadfastsound.com" always_null
local-zone: "steadfastsystem.com" always_null
local-zone: "steelhouse.com" always_null
local-zone: "steelhousemedia.com" always_null
local-zone: "stepplane.com" always_null
local-zone: "stickssheep.com" always_null
local-zone: "stickyadstv.com" always_null
local-zone: "stiffgame.com" always_null
local-zone: "storesurprise.com" always_null
local-zone: "storetail.io" always_null
local-zone: "stormyachiever.com" always_null
local-zone: "storygize.net" always_null
local-zone: "stoveseashore.com" always_null
local-zone: "straightnest.com" always_null
local-zone: "stream.useriq.com" always_null
local-zone: "stripedburst.com" always_null
local-zone: "strivesidewalk.com" always_null
local-zone: "structurerod.com" always_null
local-zone: "stupendoussleet.com" always_null
local-zone: "stupendoussnow.com" always_null
local-zone: "subscribe.hearstmags.com" always_null
local-zone: "succeedscene.com" always_null
local-zone: "suddensidewalk.com" always_null
local-zone: "sugarcurtain.com" always_null
local-zone: "sugoicounter.com" always_null
local-zone: "sulkybutter.com" always_null
local-zone: "sulkycook.com" always_null
local-zone: "summerhamster.com" always_null
local-zone: "summerobject.com" always_null
local-zone: "sumo.com" always_null
local-zone: "sumome.com" always_null
local-zone: "superclix.de" always_null
local-zone: "superficialsquare.com" always_null
local-zone: "supersonicads.com" always_null
local-zone: "superstats.com" always_null
local-zone: "supertop.ru" always_null
local-zone: "supertop100.com" always_null
local-zone: "supertracking.net" always_null
local-zone: "supply.colossusssp.com" always_null
local-zone: "surfmusik-adserver.de" always_null
local-zone: "suried.com" always_null
local-zone: "surveygizmobeacon.s3.amazonaws.com" always_null
local-zone: "sw88.espn.com" always_null
local-zone: "swan-swan-goose.com" always_null
local-zone: "swimslope.com" always_null
local-zone: "swordfishdc.com" always_null
local-zone: "swordgoose.com" always_null
local-zone: "t.appsflyer.com" always_null
local-zone: "t.bawafx.com" always_null
local-zone: "t.eloqua.com" always_null
local-zone: "t.en25.com" always_null
local-zone: "t.firstpromoter.com" always_null
local-zone: "t.insigit.com" always_null
local-zone: "t.irtyd.com" always_null
local-zone: "t.salesmatemail.com" always_null
local-zone: "taboola.com" always_null
local-zone: "tag.links-analytics.com" always_null
local-zone: "tagan.adlightning.com" always_null
local-zone: "tagcommander.com" always_null
local-zone: "tagger.opecloud.com" always_null
local-zone: "tags.tiqcdn.com" always_null
local-zone: "tagular.com" always_null
local-zone: "tailsweep.com" always_null
local-zone: "tailsweep.se" always_null
local-zone: "takethatad.com" always_null
local-zone: "takru.com" always_null
local-zone: "talentedsteel.com" always_null
local-zone: "tamgrt.com" always_null
local-zone: "tangerinenet.biz" always_null
local-zone: "tangibleteam.com" always_null
local-zone: "tapad.com" always_null
local-zone: "tapfiliate.com" always_null
local-zone: "tapinfluence.com" always_null
local-zone: "tapjoy.com" always_null
local-zone: "tappx.com" always_null
local-zone: "targad.de" always_null
local-zone: "target.microsoft.com" always_null
local-zone: "targeting.api.drift.com" always_null
local-zone: "targeting.nzme.arcpublishing.com" always_null
local-zone: "targeting.voxus.tv" always_null
local-zone: "targetingnow.com" always_null
local-zone: "targetnet.com" always_null
local-zone: "targetpoint.com" always_null
local-zone: "tastefulsongs.com" always_null
local-zone: "tatsumi-sys.jp" always_null
local-zone: "tawdryson.com" always_null
local-zone: "tcads.net" always_null
local-zone: "teads.tv" always_null
local-zone: "tealeaf.com" always_null
local-zone: "tealium.cbsnews.com" always_null
local-zone: "tealium.com" always_null
local-zone: "tealiumiq.com" always_null
local-zone: "techclicks.net" always_null
local-zone: "tedioustooth.com" always_null
local-zone: "teenrevenue.com" always_null
local-zone: "teenyvolcano.com" always_null
local-zone: "teethfan.com" always_null
local-zone: "telaria.com" always_null
local-zone: "telemetrics.klaviyo.com" always_null
local-zone: "telemetry.dropbox.com" always_null
local-zone: "telemetry.v.dropbox.com" always_null
local-zone: "temelio.com" always_null
local-zone: "tendertest.com" always_null
local-zone: "terriblethumb.com" always_null
local-zone: "text-link-ads.com" always_null
local-zone: "textad.sexsearch.com" always_null
local-zone: "textads.biz" always_null
local-zone: "textlinks.com" always_null
local-zone: "tfag.de" always_null
local-zone: "the-ozone-project.com" always_null
local-zone: "theadex.com" always_null
local-zone: "theadhost.com" always_null
local-zone: "thebugs.ws" always_null
local-zone: "theclickads.com" always_null
local-zone: "themoneytizer.com" always_null
local-zone: "therapistla.com" always_null
local-zone: "thinkablerice.com" always_null
local-zone: "thirdparty.bnc.lt" always_null
local-zone: "thirdrespect.com" always_null
local-zone: "thirstytwig.com" always_null
local-zone: "thomastorch.com" always_null
local-zone: "threechurch.com" always_null
local-zone: "throattrees.com" always_null
local-zone: "throtle.io" always_null
local-zone: "thruport.com" always_null
local-zone: "ti.domainforlite.com" always_null
local-zone: "tia.timeinc.net" always_null
local-zone: "ticketaunt.com" always_null
local-zone: "ticklesign.com" always_null
local-zone: "ticksel.com" always_null
local-zone: "tics.techdirt.com" always_null
local-zone: "tidaltv.com" always_null
local-zone: "tidint.pro" always_null
local-zone: "tinybar.com" always_null
local-zone: "tinytendency.com" always_null
local-zone: "tiresomethunder.com" always_null
local-zone: "tkbo.com" always_null
local-zone: "tls.telemetry.swe.quicinc.com" always_null
local-zone: "tlvmedia.com" always_null
local-zone: "tm.br.de" always_null
local-zone: "tnkexchange.com" always_null
local-zone: "tns-counter.ru" always_null
local-zone: "tntclix.co.uk" always_null
local-zone: "toecircle.com" always_null
local-zone: "toothbrushnote.com" always_null
local-zone: "top-casting-termine.de" always_null
local-zone: "top-site-list.com" always_null
local-zone: "top.list.ru" always_null
local-zone: "top.mail.ru" always_null
local-zone: "top.proext.com" always_null
local-zone: "top100-images.rambler.ru" always_null
local-zone: "top100.mafia.ru" always_null
local-zone: "top123.ro" always_null
local-zone: "top20free.com" always_null
local-zone: "top90.ro" always_null
local-zone: "topbucks.com" always_null
local-zone: "topforall.com" always_null
local-zone: "topgamesites.net" always_null
local-zone: "toplist.cz" always_null
local-zone: "toplist.pornhost.com" always_null
local-zone: "toplista.mw.hu" always_null
local-zone: "toplistcity.com" always_null
local-zone: "topping.com.ua" always_null
local-zone: "toprebates.com" always_null
local-zone: "topsir.com" always_null
local-zone: "topsite.lv" always_null
local-zone: "topsites.com.br" always_null
local-zone: "topstats.com" always_null
local-zone: "totemcash.com" always_null
local-zone: "touchclarity.com" always_null
local-zone: "touchclarity.natwest.com" always_null
local-zone: "tour.brazzers.com" always_null
local-zone: "track.addevent.com" always_null
local-zone: "track.adform.net" always_null
local-zone: "track.anchorfree.com" always_null
local-zone: "track.contently.com" always_null
local-zone: "track.effiliation.com" always_null
local-zone: "track.flexlinks.com" always_null
local-zone: "track.flexlinkspro.com" always_null
local-zone: "track.freemmo2017.com" always_null
local-zone: "track.game18click.com" always_null
local-zone: "track.hexcan.com" always_null
local-zone: "track.mailerlite.com" always_null
local-zone: "track.software-codes.com" always_null
local-zone: "track.themaccleanup.info" always_null
local-zone: "track.tkbo.com" always_null
local-zone: "track.ultravpn.com" always_null
local-zone: "track.unear.net" always_null
local-zone: "track.vcdc.com" always_null
local-zone: "track.viewdeos.com" always_null
local-zone: "track1.viewdeos.com" always_null
local-zone: "trackalyzer.com" always_null
local-zone: "trackedlink.net" always_null
local-zone: "trackedweb.net" always_null
local-zone: "tracker-pm2.spilleren.com" always_null
local-zone: "tracker.bannerflow.com" always_null
local-zone: "tracker.cdnbye.com" always_null
local-zone: "tracker.comunidadmarriott.com" always_null
local-zone: "tracker.icerocket.com" always_null
local-zone: "tracker.mmdlv.it" always_null
local-zone: "tracker.samplicio.us" always_null
local-zone: "tracker.vgame.us" always_null
local-zone: "tracking.1-a1502-bi.co.uk" always_null
local-zone: "tracking.1-kv015-ap.co.uk" always_null
local-zone: "tracking.21-a4652-bi.co.uk" always_null
local-zone: "tracking.39-bb4a9-osm.co.uk" always_null
local-zone: "tracking.42-01pr5-osm-secure.co.uk" always_null
local-zone: "tracking.5-47737-bi.co.uk" always_null
local-zone: "tracking.emilyclarkconsulting.com" always_null
local-zone: "tracking.epicgames.com" always_null
local-zone: "tracking.gajmp.com" always_null
local-zone: "tracking.hyros.com" always_null
local-zone: "tracking.ibxlink.com" always_null
local-zone: "tracking.internetstores.de" always_null
local-zone: "tracking.intl.miui.com" always_null
local-zone: "tracking.jiffyworld.com" always_null
local-zone: "tracking.markethero.io" always_null
local-zone: "tracking.miui.com" always_null
local-zone: "tracking.olx-st.com" always_null
local-zone: "tracking.orixa-media.com" always_null
local-zone: "tracking.publicidees.com" always_null
local-zone: "tracking.theoceanac.online" always_null
local-zone: "tracking.thinkabt.com" always_null
local-zone: "tracking01.walmart.com" always_null
local-zone: "tracking101.com" always_null
local-zone: "tracking22.com" always_null
local-zone: "trackingfestival.com" always_null
local-zone: "trackingsoft.com" always_null
local-zone: "tracklink-tel.de" always_null
local-zone: "trackmysales.com" always_null
local-zone: "trackuhub.com" always_null
local-zone: "tradeadexchange.com" always_null
local-zone: "tradedoubler.com" always_null
local-zone: "trading-rtbg.com" always_null
local-zone: "traffic-exchange.com" always_null
local-zone: "traffic-always_nulling.com" always_null
local-zone: "traffic.focuusing.com" always_null
local-zone: "trafficfactory.biz" always_null
local-zone: "trafficforce.com" always_null
local-zone: "trafficholder.com" always_null
local-zone: "traffichunt.com" always_null
local-zone: "trafficjunky.net" always_null
local-zone: "trafficleader.com" always_null
local-zone: "trafficrouter.io" always_null
local-zone: "trafficshop.com" always_null
local-zone: "trafficspaces.net" always_null
local-zone: "trafficstrategies.com" always_null
local-zone: "trafficswarm.com" always_null
local-zone: "trafficz.com" always_null
local-zone: "traffiq.com" always_null
local-zone: "trafic.ro" always_null
local-zone: "traktrafficflow.com" always_null
local-zone: "tranquilside.com" always_null
local-zone: "travis.bosscasinos.com" always_null
local-zone: "trck.a8.net" always_null
local-zone: "trcked.me" always_null
local-zone: "trcking4wdm.de" always_null
local-zone: "trcklion.com" always_null
local-zone: "treasuredata.com" always_null
local-zone: "trekdata.com" always_null
local-zone: "tremendoustime.com" always_null
local-zone: "tremorhub.com" always_null
local-zone: "trendcounter.com" always_null
local-zone: "trendmd.com" always_null
local-zone: "tribalfusion.com" always_null
local-zone: "trickycelery.com" always_null
local-zone: "triplelift.com" always_null
local-zone: "triptease.io" always_null
local-zone: "trk.bc.shutterfly.com" always_null
local-zone: "trk.bee-data.com" always_null
local-zone: "trk.enemy-adult-scared-there.xyz" always_null
local-zone: "trk.pinterest.com" always_null
local-zone: "trk.techtarget.com" always_null
local-zone: "trk42.net" always_null
local-zone: "trkn.us" always_null
local-zone: "trknths.com" always_null
local-zone: "trmit.com" always_null
local-zone: "truckstomatoes.com" always_null
local-zone: "truehits.net" always_null
local-zone: "truehits1.gits.net.th" always_null
local-zone: "truehits2.gits.net.th" always_null
local-zone: "trust.titanhq.com" always_null
local-zone: "trustx.org" always_null
local-zone: "tsuam.com" always_null
local-zone: "tsyndicate.com" always_null
local-zone: "tsyndicate.net" always_null
local-zone: "tubemogul.com" always_null
local-zone: "turboadv.com" always_null
local-zone: "turn.com" always_null
local-zone: "tvmtracker.com" always_null
local-zone: "twittad.com" always_null
local-zone: "twyn.com" always_null
local-zone: "tynt.com" always_null
local-zone: "typicalteeth.com" always_null
local-zone: "tyroo.com" always_null
local-zone: "uarating.com" always_null
local-zone: "ucfunnel.com" always_null
local-zone: "udkcrj.com" always_null
local-zone: "udncoeln.com" always_null
local-zone: "uib.ff.avast.com" always_null
local-zone: "ukbanners.com" always_null
local-zone: "ukoffzeh.com" always_null
local-zone: "ultimateclixx.com" always_null
local-zone: "ultramercial.com" always_null
local-zone: "ultraoranges.com" always_null
local-zone: "unarmedindustry.com" always_null
local-zone: "undertone.com" always_null
local-zone: "unknowntray.com" always_null
local-zone: "unless.com" always_null
local-zone: "unrulymedia.com" always_null
local-zone: "untd.com" always_null
local-zone: "untidyquestion.com" always_null
local-zone: "unusualtitle.com" always_null
local-zone: "unwieldyhealth.com" always_null
local-zone: "unwrittenspot.com" always_null
local-zone: "upu.samsungelectronics.com" always_null
local-zone: "uramog.com" always_null
local-zone: "urlcash.net" always_null
local-zone: "urldata.net" always_null
local-zone: "us.a1.yimg.com" always_null
local-zone: "user-shield-check.com" always_null
local-zone: "userreplay.com" always_null
local-zone: "userreplay.net" always_null
local-zone: "usherprayer.com" always_null
local-zone: "usingirritatecordial.com" always_null
local-zone: "utenod.com" always_null
local-zone: "utils.mediageneral.net" always_null
local-zone: "utl-1.com" always_null
local-zone: "uttermosthobbies.com" always_null
local-zone: "uu.domainforlite.com" always_null
local-zone: "v1.cnzz.com" always_null
local-zone: "v1adserver.com" always_null
local-zone: "valerie.forbes.com" always_null
local-zone: "validclick.com" always_null
local-zone: "valuead.com" always_null
local-zone: "valueclick.com" always_null
local-zone: "valueclickmedia.com" always_null
local-zone: "valuecommerce.com" always_null
local-zone: "vanfireworks.com" always_null
local-zone: "variablefitness.com" always_null
local-zone: "vcommission.com" always_null
local-zone: "veille-referencement.com" always_null
local-zone: "velismedia.com" always_null
local-zone: "venetrigni.com" always_null
local-zone: "ventivmedia.com" always_null
local-zone: "venturead.com" always_null
local-zone: "verblife-3.co" always_null
local-zone: "verblife-4.co" always_null
local-zone: "verblife-5.co" always_null
local-zone: "vericlick.com" always_null
local-zone: "vertamedia.com" always_null
local-zone: "verticalmass.com" always_null
local-zone: "vervewireless.com" always_null
local-zone: "vibrantmedia.com" always_null
local-zone: "vidcpm.com" always_null
local-zone: "video-stats.video.google.com" always_null
local-zone: "videoadex.com" always_null
local-zone: "videoamp.com" always_null
local-zone: "videoegg.com" always_null
local-zone: "videostats.kakao.com" always_null
local-zone: "vidible.tv" always_null
local-zone: "vidora.com" always_null
local-zone: "view4cash.de" always_null
local-zone: "viglink.com" always_null
local-zone: "visiblemeasures.com" always_null
local-zone: "visistat.com" always_null
local-zone: "visit.webhosting.yahoo.com" always_null
local-zone: "visitbox.de" always_null
local-zone: "visitpath.com" always_null
local-zone: "visual-pagerank.fr" always_null
local-zone: "visualrevenue.com" always_null
local-zone: "vivads.net" always_null
local-zone: "vivtracking.com" always_null
local-zone: "vmmpxl.com" always_null
local-zone: "voicefive.com" always_null
local-zone: "voicevegetable.com" always_null
local-zone: "voluum.com" always_null
local-zone: "voluumtrk2.com" always_null
local-zone: "volvelle.tech" always_null
local-zone: "voodoo-ads.io" always_null
local-zone: "vpon.com" always_null
local-zone: "vrs.cz" always_null
local-zone: "vrtzcontextualads.com" always_null
local-zone: "vs.tucows.com" always_null
local-zone: "vtracy.de" always_null
local-zone: "vungle.com" always_null
local-zone: "w55c.net" always_null
local-zone: "wa.and.co.uk" always_null
local-zone: "waardex.com" always_null
local-zone: "warlog.ru" always_null
local-zone: "warmafterthought.com" always_null
local-zone: "waryfog.com" always_null
local-zone: "wateryvan.com" always_null
local-zone: "wd-track.de" always_null
local-zone: "wdads.sx.atl.publicus.com" always_null
local-zone: "wdfl.co" always_null
local-zone: "wearbasin.com" always_null
local-zone: "web-always_nulling.com" always_null
local-zone: "web-stat.com" always_null
local-zone: "web.informer.com" always_null
local-zone: "web2.deja.com" always_null
local-zone: "webads.co.nz" always_null
local-zone: "webads.nl" always_null
local-zone: "webcash.nl" always_null
local-zone: "webcontentassessor.com" always_null
local-zone: "webcounter.cz" always_null
local-zone: "webcounter.goweb.de" always_null
local-zone: "webgains.com" always_null
local-zone: "weborama.com" always_null
local-zone: "weborama.fr" always_null
local-zone: "webpower.com" always_null
local-zone: "webreseau.com" always_null
local-zone: "webseoanalytics.com" always_null
local-zone: "websponsors.com" always_null
local-zone: "webstat.channel4.com" always_null
local-zone: "webstat.com" always_null
local-zone: "webstat.net" always_null
local-zone: "webstats.one" always_null
local-zone: "webstats4u.com" always_null
local-zone: "webtracker.jp" always_null
local-zone: "webtrackerplus.com" always_null
local-zone: "webtracky.com" always_null
local-zone: "webtraffic.se" always_null
local-zone: "webtraxx.de" always_null
local-zone: "webtrends.telegraph.co.uk" always_null
local-zone: "webtrendslive.com" always_null
local-zone: "webxcdn.com" always_null
local-zone: "wellmadefrog.com" always_null
local-zone: "werbung.meteoxpress.com" always_null
local-zone: "wetrack.it" always_null
local-zone: "whaleads.com" always_null
local-zone: "wheredoyoucomefrom.ovh" always_null
local-zone: "whirlwealth.com" always_null
local-zone: "whiskyqueue.com" always_null
local-zone: "whispa.com" always_null
local-zone: "whisperingcrib.com" always_null
local-zone: "whisperingflesh.com" always_null
local-zone: "whoisonline.net" always_null
local-zone: "widespace.com" always_null
local-zone: "widget.privy.com" always_null
local-zone: "widgetbucks.com" always_null
local-zone: "wikia-ads.wikia.com" always_null
local-zone: "win.iqm.com" always_null
local-zone: "window.nixnet.cz" always_null
local-zone: "wintricksbanner.googlepages.com" always_null
local-zone: "wirecomic.com" always_null
local-zone: "wirelesseuropebalmy.com" always_null
local-zone: "wisepops.com" always_null
local-zone: "witch-counter.de" always_null
local-zone: "wizaly.com" always_null
local-zone: "wlmarketing.com" always_null
local-zone: "womanear.com" always_null
local-zone: "wonderlandads.com" always_null
local-zone: "wondoads.de" always_null
local-zone: "woopra.com" always_null
local-zone: "worldwide-cash.net" always_null
local-zone: "worldwidedigitalads.com" always_null
local-zone: "worriednumber.com" always_null
local-zone: "wpnrtnmrewunrtok.xyz" always_null
local-zone: "wryfinger.com" always_null
local-zone: "wt-eu02.net" always_null
local-zone: "wt.bankmillennium.pl" always_null
local-zone: "wtlive.com" always_null
local-zone: "www-banner.chat.ru" always_null
local-zone: "www-google-analytics.l.google.com" always_null
local-zone: "www.dnps.com" always_null
local-zone: "www.kaplanindex.com" always_null
local-zone: "www.photo-ads.co.uk" always_null
local-zone: "www8.glam.com" always_null
local-zone: "wwwpromoter.com" always_null
local-zone: "x-traceur.com" always_null
local-zone: "x6.yakiuchi.com" always_null
local-zone: "xad.com" always_null
local-zone: "xapads.com" always_null
local-zone: "xchange.ro" always_null
local-zone: "xertive.com" always_null
local-zone: "xfreeservice.com" always_null
local-zone: "xg4ken.com" always_null
local-zone: "xiti.com" always_null
local-zone: "xovq5nemr.com" always_null
local-zone: "xplusone.com" always_null
local-zone: "xponsor.com" always_null
local-zone: "xpu.samsungelectronics.com" always_null
local-zone: "xq1.net" always_null
local-zone: "xtendmedia.com" always_null
local-zone: "xtracker.logimeter.com" always_null
local-zone: "xtremetop100.com" always_null
local-zone: "xxxcounter.com" always_null
local-zone: "xxxmyself.com" always_null
local-zone: "y.ibsys.com" always_null
local-zone: "yab-adimages.s3.amazonaws.com" always_null
local-zone: "yadro.ru" always_null
local-zone: "yepads.com" always_null
local-zone: "yesads.com" always_null
local-zone: "yesadvertising.com" always_null
local-zone: "yieldads.com" always_null
local-zone: "yieldlab.net" always_null
local-zone: "yieldmanager.com" always_null
local-zone: "yieldmanager.net" always_null
local-zone: "yieldmo.com" always_null
local-zone: "yieldoptimizer.com" always_null
local-zone: "yieldtraffic.com" always_null
local-zone: "yldbt.com" always_null
local-zone: "ymetrica1.com" always_null
local-zone: "yoggrt.com" always_null
local-zone: "yogyn.com" always_null
local-zone: "youradexchange.com" always_null
local-zone: "ypu.samsungelectronics.com" always_null
local-zone: "z3dmbpl6309s.com" always_null
local-zone: "zangocash.com" always_null
local-zone: "zanox-affiliate.de" always_null
local-zone: "zanox.com" always_null
local-zone: "zantracker.com" always_null
local-zone: "zarget.com" always_null
local-zone: "zbwp6ghm.com" always_null
local-zone: "zealousfield.com" always_null
local-zone: "zedo.com" always_null
local-zone: "zemanta.com" always_null
local-zone: "zencudo.co.uk" always_null
local-zone: "zenkreka.com" always_null
local-zone: "zenzuu.com" always_null
local-zone: "zeus.developershed.com" always_null
local-zone: "zeusclicks.com" always_null
local-zone: "zion-telemetry.api.cnn.io" always_null
local-zone: "zlp6s.pw" always_null
local-zone: "zm232.com" always_null
local-zone: "zmedia.com" always_null
local-zone: "zpu.samsungelectronics.com" always_null
local-zone: "zqtk.net" always_null
local-zone: "zukxd6fkxqn.com" always_null
local-zone: "zy16eoat1w.com" always_null
local-zone: "zzhc.vnet.cn" always_null
local-zone: "pvn.mediamarkt.de" always_null
local-zone: "pvn.saturn.de" always_null
local-zone: "pvn.mediamarkt.at" always_null
local-zone: "pvn.saturn.at" always_null
local-zone: "pvn.mediamarkt.ch" always_null
local-zone: "pvn.saturn.ch" always_null
local-zone: "communicationads.net" always_null
local-zone: "imasdk.googleapis.com" always_null
local-zone: "script.ioam.de" always_null
local-zone: "dl8.me" always_null
local-zone: "responder.wt.heise.de" always_null
local-zone: "upscore.com" always_null
local-zone: "cmp.heise.de" always_null
local-zone: "cdn.permutive.com" always_null
local-zone: "twin-iq.kickfire.com" always_null

EOF

echo '########################################################'
echo '#                                                      #'
echo '#                 CyberSecurity-Box                    #'
echo '#                                                      #'
echo '# local Privacy for Voice-Assistent Smart-TV SmartHome #'
echo '#                                                      #'
echo '#                 Unbound Blocklist                    #'
echo '#                                                      #'
echo '########################################################'
echo 

mkdir /etc/unbound/unbound.conf.d >/dev/null
curl -o /etc/unbound/root.hints https://www.internic.net/domain/named.cache  >/dev/null
curl -sS -L "http://pgl.yoyo.org/adservers/serverlist.php?hostformat=unbound&showintro=0&mimetype=plaintext" > /etc/unbound/unbound.conf.d/unbound_ad_servers

uci set unbound.@unbound[0]=unbound
uci set unbound.@unbound[0].enabled='1'
#uci set unbound.@unbound[0].include='/etc/unbound/unbound.conf.d/unbound_ad_servers'
uci set unbound.@unbound[0].tls_cert_bundle='/var/lib/unbound/ca-certificates.crt'
uci set unbound.@unbound[0].auto_trust_anchor_file='/var/lib/unbound/root.key'
uci set unbound.@unbound[0].root_hints='/var/lib/unbound/root.hints'
uci set unbound.@unbound[0].add_extra_dns='0'
uci set unbound.@unbound[0].add_local_fqdn='1'
uci set unbound.@unbound[0].add_wan_fqdn='0'
uci set unbound.@unbound[0].dhcp_link='dnsmasq'
uci set unbound.@unbound[0].dhcp4_slaac6='0'
uci set unbound.@unbound[0].do_ip4='yes'
uci set unbound.@unbound[0].do_ip6='yes'
uci set unbound.@unbound[0].do_tcp='yes'
uci set unbound.@unbound[0].do_udp='yes'
uci set unbound.@unbound[0].dns64='0'
uci set unbound.@unbound[0].do_not_query_localhost='no'
uci set unbound.@unbound[0].domain=$LOCAL_DOMAIN
uci set unbound.@unbound[0].domain_type='static'
uci set unbound.@unbound[0].edns_size='1280'
uci set unbound.@unbound[0].edns_buffer_size='1472'
uci set unbound.@unbound[0].extended_stats='0'
uci set unbound.@unbound[0].hide_binddata='1'
uci set unbound.@unbound[0].interface_auto='1'
uci set unbound.@unbound[0].listen_port=$DNS_UNBOUND_port
uci set unbound.@unbound[0].localservice='1'
uci set unbound.@unbound[0].manual_conf='0'
uci set unbound.@unbound[0].num_threads='1'
uci set unbound.@unbound[0].protocol='default'
#uci set unbound.@unbound[0].query_minimize='0'
uci set unbound.@unbound[0].query_minimize='1'
uci set unbound.@unbound[0].query_min_strict='1'
uci set unbound.@unbound[0].rate_limit='0'
uci set unbound.@unbound[0].rebind_localhost='0'
uci set unbound.@unbound[0].rebind_protection='1'
#uci set unbound.@unbound[0].recursion='default'
#uci set unbound.@unbound[0].resource='default'
uci set unbound.@unbound[0].recursion='passiv'
uci set unbound.@unbound[0].resource='medium'
uci set unbound.@unbound[0].root_age='9'
uci set unbound.@unbound[0].ttl_min='300'
uci set unbound.@unbound[0].ttl_max='86400'
uci set unbound.@unbound[0].cache_min_ttl='300'
uci set unbound.@unbound[0].cache_max_ttl='86400'
uci set unbound.@unbound[0].cache_size='10000'
#uci set unbound.@unbound[0].unbound_control='0'
uci set unbound.@unbound[0].unbound_control='2'
uci set unbound.@unbound[0].prefetch='yes'
uci set unbound.@unbound[0].prefetch_key='yes'
uci set unbound.@unbound[0].validator='1'
uci set unbound.@unbound[0].validator_ntp='1'
uci set unbound.@unbound[0].verbosity='0'
uci set unbound.@unbound[0].hide_identity='yes'
uci set unbound.@unbound[0].hide_version='yes'
uci set unbound.@unbound[0].harden_glue='yes'
uci set unbound.@unbound[0].harden_dnssec_stripped='yes'
uci set unbound.@unbound[0].harden_large_queries='yes'
uci set unbound.@unbound[0].harden_short_bufsize='yes'
uci set unbound.@unbound[0].harden_below_nxdomain='yes'
uci set unbound.@unbound[0].use_caps_for_id='yes'
uci set unbound.@unbound[0].so_reuseport='yes'
uci set unbound.@unbound[0].msg_cache_slabs='2'
uci set unbound.@unbound[0].rrset_cache_slabs='2'
uci set unbound.@unbound[0].infra_cache_slabs='2'
uci set unbound.@unbound[0].key_cache_slabs='2'
uci set unbound.@unbound[0].qname_minimisation='yes'
uci set unbound.@unbound[0].qname_minimisation_strict='yes'
uci set unbound.@unbound[0].rrset_roundrobin='yes'
uci set unbound.@unbound[0].serve_expired='yes'
uci set unbound.@unbound[0].so_rcvbuf='1m'
uci set unbound.@unbound[0].protocol='ip4_only'
uci add_list unbound.@unbound[0].private_address='192.168.0.0/16'
uci add_list unbound.@unbound[0].private_address='169.254.0.0/16'
uci add_list unbound.@unbound[0].private_address='172.16.0.0/12'
uci add_list unbound.@unbound[0].private_address='10.0.0.0/8'
uci add_list unbound.@unbound[0].private_address='fd00::/8'
uci add_list unbound.@unbound[0].private_address='fe80::/10'
uci add_list unbound.@unbound[0].access_control='0.0.0.0/0 refuse'
uci add_list unbound.@unbound[0].access_control='::0/0 refuse'
uci add_list unbound.@unbound[0].access_control='127.0.0.1 allow'
uci add_list unbound.@unbound[0].access_control='::1 allow'
uci add_list unbound.@unbound[0].access_control=$SERVER_net' allow'
uci add_list unbound.@unbound[0].access_control=$CONTROL_net' allow'
uci add_list unbound.@unbound[0].access_control=$HCONTROL_net' allow'
uci add_list unbound.@unbound[0].access_control=$INET_net' allow'
uci add_list unbound.@unbound[0].trigger_interface='CONTROL'
uci add_list unbound.@unbound[0].trigger_interface='HCONTROL'
uci add_list unbound.@unbound[0].trigger_interface='INET_CLIENTS'
uci add_list unbound.@unbound[0].trigger_interface='SERVER'
uci add_list unbound.@unbound[0].trigger_interface='VOICE'
uci add_list unbound.@unbound[0].trigger_interface='ENTERTAIN'
uci add_list unbound.@unbound[0].trigger_interface='CMOVIE'
uci add_list unbound.@unbound[0].trigger_interface='GUEST'
uci add_list unbound.@unbound[0].trigger_interface='wan6'
uci set unbound.@unbound[0].domain_insecure='dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion'
uci add_list unbound.@unbound[0].domain_insecure=$INET_domain
uci add_list unbound.@unbound[0].domain_insecure=$SERVER_domain
uci add_list unbound.@unbound[0].domain_insecure=$HCONTROL_domain
uci add_list unbound.@unbound[0].domain_insecure=$CONTROL_domain
uci add_list unbound.@unbound[0].domain_insecure=$VOICE_domain
uci add_list unbound.@unbound[0].domain_insecure=$GUEST_domain
uci add_list unbound.@unbound[0].domain_insecure=$ENTERTAIN_domain
uci add_list unbound.@unbound[0].domain_insecure=$CMOVIE_domain
uci add_list unbound.@unbound[0].domain_insecure='onion'
uci add_list unbound.@unbound[0].domain_insecure='exit'
uci add_list unbound.@unbound[0].private_domain=$INET_domain
uci add_list unbound.@unbound[0].private_domain=$SERVER_domain
uci add_list unbound.@unbound[0].private_domain=$HCONTROL_domain
uci add_list unbound.@unbound[0].private_domain=$CONTROL_domain
uci add_list unbound.@unbound[0].private_domain=$VOICE_domain
uci add_list unbound.@unbound[0].private_domain=$GUEST_domain
uci add_list unbound.@unbound[0].private_domain=$ENTERTAIN_domain
uci add_list unbound.@unbound[0].private_domain=$CMOVIE_domain
uci add_list unbound.@unbound[0].private_domain='onion'
uci add_list unbound.@unbound[0].private_domain='exit'

uci add_list unbound.@unbound[0].outgoing_port_permit=$SDNS_port
uci add_list unbound.@unbound[0].outgoing_port_permit=$TOR_SOCKS_port
#uci add_list unbound.@unbound[0].outgoing_port_permit='9150'
uci add_list unbound.@unbound[0].outgoing_port_permit=$DNS_TOR_port
#uci add_list unbound.@unbound[0].outgoing_port_permit='9153'
#uci add_list unbound.@unbound[0].outgoing_port_permit='10240-65335'
uci add unbound zone
uci set unbound.@zone[-1].name='onion'
uci set unbound.@zone[-1].zone_type='forward_zone'
uci set unbound.@zone[-1].forward_addr='127.0.0.1 @'$DNS_TOR_port
uci add unbound zone
uci set unbound.@zone[-1].name='exit'
uci set unbound.@zone[-1].zone_type='forward_zone'
uci set unbound.@zone[-1].forward_addr='127.0.0.1 @'$DNS_TOR_port
uci add unbound zone
uci set unbound.@zone[-1].name='.'
uci set unbound.@zone[-1].zone_type='forward_zone'
uci set unbound.@zone[-1].fallback='0'
uci set unbound.@zone[-1].tls_upstream='1'
uci set unbound.@zone[-1].tls_index='dns.cloudflair'
uci set unbound.@zone[-1].forward_tls_upstream='yes'
uci set unbound.@zone[-1].forward_addr='dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion @'$DNS_TOR_port

uci commit unbound && reload_config  >/dev/null
/etc/init.d/unbound start  >/dev/null
echo
echo '########################################################'
echo '#                                                      #'
echo '#                 CyberSecurity-Box                    #'
echo '#                                                      #'
echo '# local Privacy for Voice-Assistent Smart-TV SmartHome #'
echo '#                                                      #'
echo '#   Unbound lokal DNS-Resolver with lokal root-files   #'
echo '#                                                      #'
echo '########################################################'
echo 
echo
uci -q delete dhcp >/dev/null
uci delete dhcp.BlacklistSERVER >/dev/null
uci delete dhcp.BlacklistHCONTROL >/dev/null
uci delete dhcp.BlacklistCONTROL >/dev/null
uci delete dhcp.BlacklistINET >/dev/null
uci delete dhcp.WhitelistVOICE >/dev/null
uci delete dhcp.WhitelistENTERTAIN >/dev/null
uci delete dhcp.WhitelistGUEST >/dev/null
uci delete dhcp.WhitelistCMOVIE >/dev/null
uci delete dhcp.SERVER >/dev/null
uci delete dhcp.HCONTROL >/dev/null
uci delete dhcp.CONTROL >/dev/null
uci delete dhcp.INET >/dev/null
uci delete dhcp.VOICE >/dev/null
uci delete dhcp.ENTERTAIN >/dev/null
uci delete dhcp.GUEST >/dev/null
uci delete dhcp.CMOVIE >/dev/null
uci delete dhcp.Blacklist>/dev/null
uci delete dhcp.Whitelist >/dev/null
uci delete dhcp.lan >/dev/null
uci delete dhcp.@dnsmasq[-1] >/dev/null
uci delete dhcp.@dnsmasq[-1] >/dev/null
uci delete dhcp.@dnsmasq[-1] >/dev/null
uci delete dhcp.@dnsmasq[-1] >/dev/null
uci delete dhcp.@dnsmasq[-1] >/dev/null
uci delete dhcp.@dnsmasq[-1] >/dev/null
uci commit dhcp >/dev/null
uci set dhcp.Blacklist=dnsmasq
uci set dhcp.Blacklist.domainneeded='1'
uci set dhcp.Blacklist.localise_queries='1'
uci set dhcp.Blacklist.rebind_protection='1'
uci set dhcp.Blacklist.rebind_localhost='1'
uci set dhcp.Blacklist.filterwin2k='1'
uci set dhcp.Blacklist.local='/'$INET_domain'/'
uci set dhcp.Blacklist.expandhosts='1'
uci set dhcp.Blacklist.authoritative='1'
uci set dhcp.Blacklist.readethers='1'
uci set dhcp.Blacklist.leasefile='/tmp/dhcp.blacklist.leases'
uci set dhcp.Blacklist.resolvfile='/tmp/resolv.blacklist.conf.auto'
uci set dhcp.Blacklist.localservice='1'
uci set dhcp.Blacklist.cachesize='1'
uci set dhcp.Blacklist.confdir='/etc/dnsmasq.d/Blacklist/'
uci set dhcp.Blacklist.boguspriv='1'
uci set dhcp.Blacklist.logqueries='0'
uci set dhcp.Blacklist.logfacility='/var/log/dnsmasq.blacklist.log'
uci add_list dhcp.Blacklist.notinterface='br-VOICE'
uci add_list dhcp.Blacklist.notinterface='br-GUEST'
uci add_list dhcp.Blacklist.notinterface='br-ENTERTAIN'
uci add_list dhcp.Blacklist.notinterface='br-CMOVIE'
uci set dhcp.Blacklist.interface='br-INET'
uci add_list dhcp.Blacklist.interface='br-HCONTROL'
uci add_list dhcp.Blacklist.interface='br-CONTROL'
uci add_list dhcp.Blacklist.interface='br-SERVER'
uci set dhcp.Blacklist.domain=$INET_domain

uci set dhcp.Whitelist=dnsmasq
uci set dhcp.Whitelist.domainneeded='1'
uci set dhcp.Whitelist.localise_queries='1'
uci set dhcp.Whitelist.rebind_protection='1'
uci set dhcp.Whitelist.rebind_localhost='1'
uci set dhcp.Whitelist.filterwin2k='1'
uci set dhcp.Whitelist.local='/'$VOICE_domain'/'
uci set dhcp.Whitelist.expandhosts='1'
uci set dhcp.Whitelist.authoritative='1'
uci set dhcp.Whitelist.readethers='1'
uci set dhcp.Whitelist.leasefile='/tmp/dhcp.whitelist.leases'
uci set dhcp.Whitelist.resolvfile='/tmp/resolv.whitelist.conf.auto'
uci set dhcp.Whitelist.localservice='1'
uci set dhcp.Whitelist.cachesize='1'
uci set dhcp.Whitelist.confdir='/etc/dnsmasq.d/Whitelist/'
uci set dhcp.Whitelist.boguspriv='1'
uci set dhcp.Whitelist.logqueries='0'
uci set dhcp.Whitelist.logfacility='/var/log/dnsmasq.whitelist.log'
uci set dhcp.Whitelist.interface='br-VOICE' 
uci add_list dhcp.Whitelist.interface='br-GUEST'
uci add_list dhcp.Whitelist.interface='br-ENTERTAIN'
uci add_list dhcp.Whitelist.interface='br-CMOVIE'
uci set dhcp.Whitelist.notinterface='br-INET'
uci add_list dhcp.Whitelist.notinterface='br-HCONTROL'
uci add_list dhcp.Whitelist.notinterface='br-CONTROL'
uci add_list dhcp.Whitelist.notinterface='br-SERVER'
uci set dhcp.Whitelist.domain=$VOICE_domain

uci set dhcp.lan=dhcp
uci set dhcp.lan.interface='lan'
uci set dhcp.lan.start='1'
uci set dhcp.lan.limit='250'
uci set dhcp.lan.leasetime='24h'
uci set dhcp.lan.dhcpv6='server'
uci set dhcp.lan.ra='server'

uci set dhcp.wan=dhcp
uci set dhcp.wan.interface='wan'
uci set dhcp.wan.ignore='1'

uci set dhcp.SERVER=dhcp
uci set dhcp.SERVER.start='1'
uci set dhcp.SERVER.limit='250'
uci set dhcp.SERVER.interface='SERVER'
uci set dhcp.SERVER.leasetime='24h'
uci set dhcp.SERVER.dhcpv6='server'
uci set dhcp.SERVER.domain=$SERVER_domain
uci set dhcp.SERVER.local='/'$SERVER_domain'/'
uci add_list dhcp.SERVER.dhcp_option='6,'$SERVER_ip 
uci add_list dhcp.SERVER.dhcp_option='3,'$SERVER_ip
uci add_list dhcp.SERVER.dhcp_option='42,'$INET_GW 
uci add_list dhcp.SERVER.dhcp_option='15,'$SERVER_domain
uci set dhcp.SERVER.server=$SERVER_ip'#'$DNS_UNBOUND_port

uci set dhcp.CONTROL=dhcp
uci set dhcp.CONTROL.start='1'
uci set dhcp.CONTROL.limit='250'
uci set dhcp.CONTROL.interface='CONTROL'
uci set dhcp.CONTROL.leasetime='24h'
uci set dhcp.CONTROL.dhcpv6='server'
uci set dhcp.CONTROL.domain=$CONTROL_domain
uci set dhcp.CONTROL.local='/'$CONTROL_domain'/'
uci add_list dhcp.CONTROL.dhcp_option='3,'$CONTROL_ip
uci add_list dhcp.CONTROL.dhcp_option='6,'$CONTROL_ip
uci add_list dhcp.CONTROL.dhcp_option='42,'$INET_GW 
uci add_list dhcp.CONTROL.dhcp_option='15,'$CONTROL_domain
uci set dhcp.CONTROL.server=$CONTROL_ip'#'$DNS_UNBOUND_port

uci set dhcp.HCONTROL=dhcp
uci set dhcp.HCONTROL.start='1'
uci set dhcp.HCONTROL.limit='250'
uci set dhcp.HCONTROL.interface='HCONTROL'
uci set dhcp.HCONTROL.leasetime='24h'
uci set dhcp.HCONTROL.dhcpv6='server'
uci set dhcp.HCONTROL.domain=$HCONTROL_domain
uci set dhcp.HCONTROL.local='/'$HCONTROL_domain'/'
uci add_list dhcp.HCONTROL.dhcp_option='6,'$HCONTROL_ip 
uci add_list dhcp.HCONTROL.dhcp_option='3,'$HCONTROL_ip
uci add_list dhcp.HCONTROL.dhcp_option='42,'$INET_GW 
uci add_list dhcp.HCONTROL.dhcp_option='15,'$HCONTROL_domain
uci set dhcp.HCONTROL.server=$HCONTROL_ip'#'$DNS_UNBOUND_port

uci set dhcp.INET=dhcp
uci set dhcp.INET.start='1'
uci set dhcp.INET.limit='250'
uci set dhcp.INET.interface='INET'
uci set dhcp.INET.leasetime='24h'
uci set dhcp.INET.dhcpv6='server'
uci set dhcp.INET.domain=$INET_domain
uci set dhcp.INET.local='/'$INET_domain'/'
uci add_list dhcp.INET.dhcp_option='6,'$INET_ip 
uci add_list dhcp.INET.dhcp_option='3,'$INET_ip
uci add_list dhcp.INET.dhcp_option='42,'$INET_GW 
uci add_list dhcp.INET.dhcp_option='15,'$INET_domain
uci set dhcp.INET.server=$INET_ip'#'$DNS_UNBOUND_port

uci set dhcp.ENTERTAIN=dhcp
uci set dhcp.ENTERTAIN.start='1'
uci set dhcp.ENTERTAIN.limit='250'
uci set dhcp.ENTERTAIN.interface='ENTERTAIN'
uci set dhcp.ENTERTAIN.leasetime='24h'
uci set dhcp.ENTERTAIN.dhcpv6='server'
uci set dhcp.ENTERTAIN.domain=$ENTERTAIN_domain
uci set dhcp.ENTERTAIN.local='/'$ENTERTAIN_domain'/'
uci add_list dhcp.ENTERTAIN.dhcp_option='6,'$ENTERTAIN_ip 
uci add_list dhcp.ENTERTAIN.dhcp_option='3,'$ENTERTAIN_ip
uci add_list dhcp.ENTERTAIN.dhcp_option='42,'$INET_GW 
uci add_list dhcp.ENTERTAIN.dhcp_option='15,'$ENTERTAIN_domain
uci set dhcp.ENTERTAIN.server=$ENTERTAIN_ip'#'$DNS_UNBOUND_port

uci set dhcp.VOICE=dhcp
uci set dhcp.VOICE.start='1'
uci set dhcp.VOICE.limit='250'
uci set dhcp.VOICE.interface='VOICE'
uci set dhcp.VOICE.leasetime='24h'
uci set dhcp.VOICE.dhcpv6='server'
uci set dhcp.VOICE.domain=$VOICE_domain
uci set dhcp.VOICE.local='/'$VOICE_domain'/'
uci add_list dhcp.VOICE.dhcp_option='6,'$VOICE_ip 
uci add_list dhcp.VOICE.dhcp_option='3,'$VOICE_ip
uci add_list dhcp.VOICE.dhcp_option='42,'$INET_GW 
uci add_list dhcp.VOICE.dhcp_option='15,'$VOICE_domain
uci set dhcp.VOICE.server=$VOICE_ip'#'$DNS_UNBOUND_port

uci set dhcp.GUEST=dhcp
uci set dhcp.GUEST.start='100'
uci set dhcp.GUEST.limit='150'
uci set dhcp.GUEST.interface='GUEST'
uci set dhcp.GUEST.leasetime='24h'
uci set dhcp.GUEST.dhcpv6='server'
uci set dhcp.GUEST.domain=$GUEST_domain
uci set dhcp.GUEST.local='/'$GUEST_domain'/'
uci add_list dhcp.GUEST.dhcp_option='6,'$GUEST_ip 
uci add_list dhcp.GUEST.dhcp_option='3,'$GUEST_ip
uci add_list dhcp.GUEST.dhcp_option='42,'$INET_GW 
uci add_list dhcp.GUEST.dhcp_option='15,'$GUEST_domain
uci set dhcp.GUEST.server=$GUEST_ip'#'$DNS_UNBOUND_port
uci commit && reload_config

uci set dhcp.CMOVIE=dhcp
uci set dhcp.CMOVIE.start='100'
uci set dhcp.CMOVIE.limit='150'
uci set dhcp.CMOVIE.interface='CMOVIE'
uci set dhcp.CMOVIE.leasetime='24h'
uci set dhcp.CMOVIE.dhcpv6='server'
uci set dhcp.CMOVIE.domain=$CMOVIE_domain
uci set dhcp.CMOVIE.local='/'$CMOVIE_domain'/'
uci add_list dhcp.CMOVIE.dhcp_option='6,'$CMOVIE_ip 
uci add_list dhcp.CMOVIE.dhcp_option='3,'$CMOVIE_ip
uci add_list dhcp.CMOVIE.dhcp_option='42,'$INET_GW 
uci add_list dhcp.CMOVIE.dhcp_option='15,'$CMOVIE_domain
uci set dhcp.CMOVIE.server=$CMOVIE_ip'#'$DNS_UNBOUND_port
uci commit && reload_config


mkdir /etc/dnsmasq.d  >/dev/null
mkdir /etc/dnsmasq.d/Blacklist >/dev/null
mkdir /etc/dnsmasq.d/Whitelist >/dev/null
mkdir /etc/dnsmasq.d/BlockAll >/dev/null
mkdir /etc/dnsmasq.d/AllowAll >/dev/null

uci commit dhcp && reload_config >/dev/null

#/etc/init.d/dnsmasq restart >/dev/null

uci set network.wan.peerdns='0'
uci set network.wan.dns='127.0.0.1'
uci set network.wan6.peerdns='0'
uci set network.wan6.dns='0::1'
uci commit && reload_config >/dev/null

#uci set dhcp.@dnsmasq[-1].dnssec=1
#uci set dhcp.@dnsmasq[-1].dnsseccheckunsigned=1
#uci commit && reload_config >/dev/null

uci set dhcp.wan=dhcp
uci set dhcp.wan.interface='wan'
uci set dhcp.wan.ignore='1'

mkdir /etc/dnsmasq.d  >/dev/null
mkdir /etc/dnsmasq.d/Blacklist >/dev/null
mkdir /etc/dnsmasq.d/Whitelist >/dev/null
mkdir /etc/dnsmasq.d/BlockAll >/dev/null
mkdir /etc/dnsmasq.d/AllowAll >/dev/null

uci commit dhcp && reload_config >/dev/null

/etc/init.d/dnsmasq restart >/dev/null
cp /usr/share/dnsmasq/trust-anchors.conf /etc/ >/dev/null


clear
echo '########################################################'
echo '#                                                      #'
echo '#                 CyberSecurity-Box                    #'
echo '#                                                      #'
echo '#                   DHCP Settings                      #'
echo '#                                                      #'
echo '########################################################'
echo
echo
echo 'Your Config is:'
echo
echo 'Client-WiFi SSID:     '$INET_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$INET_net
echo
echo 'Smarthome-WiFi SSID:  '$HCONTROL_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$HCONTROL_net
echo
echo 'Voice-Assistent SSID: '$VOICE_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$VOICE_net
echo
echo 'Smart-TV/-DVD SSID:   '$ENTERTAIN_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$ENTERTAIN_net
echo
echo 'Server-WiFi SSID:     '$SERVER_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$SERVER_net
echo
echo 'IR/BT-Control SSID:   '$CONTROL_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$CONTROL_net
echo
echo 'Guests SSID is:       '$GUEST_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$GUEST_net
echo
echo
echo
echo 'IP-Address:           '$ACCESS_SERVER
echo 'Gateway:              '$INET_GW
echo 'Domain:               '$LOCAL_DOMAIN
echo
echo 'GUI-Access:           https://'$INET_ip':8443'
echo 'User:                 '$USERNAME
echo 'Password:             password'
echo
echo 'Please wait until Reboot ....'

# Configure Black and Whitelsit
cat << EOF > /etc/dnsmasq.d/Blacklist/z_all_allow
server=/dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion/127.0.0.1
server=/#/127.0.0.1#$(echo $DNS_UNBOUND_port)
EOF

cat << EOF > /etc/dnsmasq.d/AllowAll/all_allow
server=/#/127.0.0.1#$(echo $DNS_UNBOUND_port)
EOF

cat << EOF > /etc/dnsmasq.d/BlockAll/block_all
address=/#/
EOF

cat << EOF > /etc/dnsmasq.d/Blacklist/agency
address=/us-gov.amazonaws.com/
address=/us-gov-east-1.amazonaws.com/
address=/us-gov-east-2.amazonaws.com/
address=/us-gov-east-3.amazonaws.com/
address=/us-gov-east-4.amazonaws.com/
address=/us-gov-east-5.amazonaws.com/
address=/us-gov-west-1.amazonaws.com/
address=/us-gov-west-2.amazonaws.com/
address=/us-gov-west-3.amazonaws.com/
address=/us-gov-west-4.amazonaws.com/
address=/us-gov-west-5.amazonaws.com/
address=/us-gov-south-1.amazonaws.com/
address=/us-gov-south-2.amazonaws.com/
address=/us-gov-south-3.amazonaws.com/
address=/us-gov-south-4.amazonaws.com/
address=/us-gov-south-5.amazonaws.com/
address=/us-gov-north-1.amazonaws.com/
address=/us-gov-north-2.amazonaws.com/
address=/us-gov-north-3.amazonaws.com/
address=/us-gov-north-4.amazonaws.com/
address=/us-gov-north-5.amazonaws.com/
address=/cn-north-1.amazonaws.com.cn/
address=/cn-north-2.amazonaws.com.cn/
address=/cn-north-3.amazonaws.com.cn/
address=/cn-north-4.amazonaws.com.cn/
address=/cn-north-5.amazonaws.com.cn/
address=/cn-northwest-1.amazonaws.com.cn/
address=/cn-northwest-2.amazonaws.com.cn/
address=/cn-northwest-3.amazonaws.com.cn/
address=/cn-northwest-4.amazonaws.com.cn/
address=/cn-northwest-5.amazonaws.com.cn/
address=/cn-northeast-1.amazonaws.com.cn/
address=/cn-northeast-2.amazonaws.com.cn/
address=/cn-northeast-3.amazonaws.com.cn/
address=/cn-northeast-4.amazonaws.com.cn/
address=/cn-northeast-5.amazonaws.com.cn/
address=/cn-north-1.amazonaws.com.cn/
address=/cn-north-2.amazonaws.com.cn/
address=/cn-north-3.amazonaws.com.cn/
address=/cn-north-4.amazonaws.com.cn/
address=/cn-north-5.amazonaws.com.cn/
address=/cn-southwest-1.amazonaws.com.cn/
address=/cn-southwest-2.amazonaws.com.cn/
address=/cn-southwest-3.amazonaws.com.cn/
address=/cn-southwest-4.amazonaws.com.cn/
address=/cn-southwest-5.amazonaws.com.cn/
address=/cn-southeast-1.amazonaws.com.cn/
address=/cn-southeast-2.amazonaws.com.cn/
address=/cn-southeast-3.amazonaws.com.cn/
address=/cn-southeast-4.amazonaws.com.cn/
address=/cn-southeast-5.amazonaws.com.cn/
address=/us-gov.compute.amazonaws.com/
address=/us-gov-east-1.compute.amazonaws.com/
address=/us-gov-east-2.compute.amazonaws.com/
address=/us-gov-east-3.compute.amazonaws.com/
address=/us-gov-east-4.compute.amazonaws.com/
address=/us-gov-east-5.compute.amazonaws.com/
address=/us-gov-west-1.compute.amazonaws.com/
address=/us-gov-west-2.compute.amazonaws.com/
address=/us-gov-west-3.compute.amazonaws.com/
address=/us-gov-west-4.compute.amazonaws.com/
address=/us-gov-west-5.compute.amazonaws.com/
address=/us-gov-south-1.compute.amazonaws.com/
address=/us-gov-south-2.compute.amazonaws.com/
address=/us-gov-south-3.compute.amazonaws.com/
address=/us-gov-south-4.compute.amazonaws.com/
address=/us-gov-south-5.compute.amazonaws.com/
address=/us-gov-north-1.compute.amazonaws.com/
address=/us-gov-north-2.compute.amazonaws.com/
address=/us-gov-north-3.compute.amazonaws.com/
address=/us-gov-north-4.compute.amazonaws.com/
address=/us-gov-north-5.compute.amazonaws.com/
address=/cn-north-1.compute.amazonaws.com.cn/
address=/cn-north-2.compute.amazonaws.com.cn/
address=/cn-north-3.compute.amazonaws.com.cn/
address=/cn-north-4.compute.amazonaws.com.cn/
address=/cn-north-5.compute.amazonaws.com.cn/
address=/cn-northwest-1.compute.amazonaws.com.cn/
address=/cn-northwest-2.compute.amazonaws.com.cn/
address=/cn-northwest-3.compute.amazonaws.com.cn/
address=/cn-northwest-4.compute.amazonaws.com.cn/
address=/cn-northwest-5.compute.amazonaws.com.cn/
address=/cn-northeast-1.compute.amazonaws.com.cn/
address=/cn-northeast-2.compute.amazonaws.com.cn/
address=/cn-northeast-3.compute.amazonaws.com.cn/
address=/cn-northeast-4.compute.amazonaws.com.cn/
address=/cn-northeast-5.compute.amazonaws.com.cn/
address=/cn-north-1.compute.amazonaws.com.cn/
address=/cn-north-2.compute.amazonaws.com.cn/
address=/cn-north-3.compute.amazonaws.com.cn/
address=/cn-north-4.compute.amazonaws.com.cn/
address=/cn-north-5.compute.amazonaws.com.cn/
address=/cn-southwest-1.compute.amazonaws.com.cn/
address=/cn-southwest-2.compute.amazonaws.com.cn/
address=/cn-southwest-3.compute.amazonaws.com.cn/
address=/cn-southwest-4.compute.amazonaws.com.cn/
address=/cn-southwest-5.compute.amazonaws.com.cn/
address=/cn-southeast-1.compute.amazonaws.com.cn/
address=/cn-southeast-2.compute.amazonaws.com.cn/
address=/cn-southeast-3.compute.amazonaws.com.cn/
address=/cn-southeast-4.compute.amazonaws.com.cn/
address=/cn-southeast-5.compute.amazonaws.com.cn/

address=/fbi.gov/
address=/cia.gov/
address=/nsa.gov/
address=/dia.gov/
address=/bnd.de/
address=/bka.de/
address=/lka.de/
address=/mad.de/
address=/mil.de/
address=/cia.de/
address=/nsa.de/
address=/fbi.de/
address=/bka.de/
address=/lka.de/
address=/bnd.de/
address=/mad.de/
address=/bavsa.de/
address=/gov.de/
address=/goverment.de/
address=/bnd.at/
address=/bka.at/
address=/lka.at/
address=/mad.at/
address=/mil.at/
address=/cia.at/
address=/nsa.at/
address=/fbi.at/
address=/bka.at/
address=/lka.at/
address=/bnd.at/
address=/mad.at/
address=/cobra.at/
address=/bavsa.at/
address=/gov.at/
address=/bnd.ch/
address=/bka.ch/
address=/lka.ch/
address=/mad.ch/
address=/mil.ch/
address=/cia.ch/
address=/nsa.ch/
address=/fbi.ch/
address=/bka.ch/
address=/lka.ch/
address=/bnd.ch/
address=/mad.ch/
address=/bavsa.ch/
address=/gov.ch/
address=/goverment.ch/
address=/bnd.eu/
address=/bka.eu/
address=/lka.eu/
address=/mad.eu/
address=/mil.eu/
address=/cia.eu/
address=/nsa.eu/
address=/fbi.eu/
address=/bka.eu/
address=/lka.eu/
address=/bnd.eu/
address=/mad.eu/
address=/bavsa.eu/
address=/gov.eu/
address=/goverment.eu/
address=/mil.com/
address=/cia.com/
address=/nsa.com/
address=/fbi.com/
address=/bka.com/
address=/lka.com/
address=/bnd.com/
address=/mad.com/
address=/bavsa.com/
address=/bvs.com/
address=/gov.com/
address=/goverment/
address=/mil/
address=/cia/
address=/nsa/
address=/fbi/
address=/bka/
address=/lka/
address=/bnd/
address=/mad/
address=/bavsa/
address=/bvs/
address=/gov/
EOF

cat << EOF > /etc/dnsmasq.d/Whitelist/z_block_all
address=/#/
EOF

cat << EOF > /etc/dnsmasq.d/Blacklist/contrys
address=/.ac/
address=/.ad/
address=/.ae/
address=/.af/
address=/.ag/
address=/.ai/
address=/.al/
address=/.am/
address=/.an/
address=/.ao/
address=/.aq/
address=/.ar/
address=/.as/
address=/.au/
address=/.aw/
address=/.ax/
address=/.az/
address=/.ba/
address=/.bb/
address=/.bd/
address=/.bf/
address=/.bg/
address=/.bh/
address=/.bi/
address=/.bj/
address=/.bl/
address=/.bm/
address=/.bn/
address=/.bo/
address=/.bq/
address=/.br/
address=/.bs/
address=/.bt/
address=/.bv/
address=/.bw/
address=/.by/
address=/.bz/
address=/.cc/
address=/.cd/
address=/.cf/
address=/.cg/
address=/.ci/
address=/.ck/
address=/.cl/
address=/.cm/
address=/.cn/
address=/.co/
address=/.cr/
address=/.cu/
address=/.cv/
address=/.cw/
address=/.cx/
address=/.cy/
address=/.cz/
address=/.dj/
address=/.dm/
address=/.do/
address=/.dz/
address=/.ec/
address=/.ee/
address=/.eg/
address=/.eh/
address=/.er/
address=/.es/
address=/.et/
address=/.fi/
address=/.fj/
address=/.fk/
address=/.fm/
address=/.fo/
address=/.fr/
address=/.ga/
address=/.gb/
address=/.gd/
address=/.ge/
address=/.gf/
address=/.gg/
address=/.gh/
address=/.gi/
address=/.gl/
address=/.gm/
address=/.gn/
address=/.gp/
address=/.gq/
address=/.gr/
address=/.gs/
address=/.gt/
address=/.gu/
address=/.gw/
address=/.gy/
address=/.hk/
address=/.hm/
address=/.hn/
address=/.hr/
address=/.ht/
address=/.hu/
address=/.id/
address=/.ie/
address=/.il/
address=/.im/
address=/.in/
address=/.io/
address=/.iq/
address=/.ir/
address=/.is/
address=/.it/
address=/.je/
address=/.jm/
address=/.jo/
address=/.ke/
address=/.kg/
address=/.kh/
address=/.ki/
address=/.km/
address=/.kn/
address=/.kp/
address=/.kr/
address=/.kw/
address=/.ky/
address=/.kz/
address=/.la/
address=/.lb/
address=/.lc/
address=/.lk/
address=/.lr/
address=/.ls/
address=/.lt/
address=/.lu/
address=/.lv/
address=/.ly/
address=/.ma/
address=/.mc/
address=/.md/
address=/.me/
address=/.mf/
address=/.mg/
address=/.mh/
address=/.mk/
address=/.ml/
address=/.mm/
address=/.mn/
address=/.mo/
address=/.mp/
address=/.mq/
address=/.mr/
address=/.ms/
address=/.mt/
address=/.mu/
address=/.mv/
address=/.mw/
address=/.mx/
address=/.my/
address=/.mz/
address=/.na/
address=/.nc/
address=/.ne/
address=/.nf/
address=/.ng/
address=/.ni/
address=/.no/
address=/.np/
address=/.nr/
address=/.nu/
address=/.nz/
address=/.om/
address=/.pa/
address=/.pe/
address=/.pf/
address=/.pg/
address=/.ph/
address=/.pk/
address=/.pl/
address=/.pm/
address=/.pn/
address=/.pr/
address=/.ps/
address=/.pt/
address=/.pw/
address=/.py/
address=/.qa/
address=/.re/
address=/.ro/
address=/.rs/
address=/.ru/
address=/.rw/
address=/.sa/
address=/.sb/
address=/.sc/
address=/.sd/
address=/.se/
address=/.sg/
address=/.sh/
address=/.si/
address=/.sj/
address=/.sk/
address=/.sl/
address=/.sm/
address=/.sn/
address=/.so/
address=/.sr/
address=/.ss/
address=/.st/
address=/.su/
address=/.sv/
address=/.sx/
address=/.sy/
address=/.sz/
address=/.tc/
address=/.td/
address=/.tf/
address=/.tg/
address=/.th/
address=/.tj/
address=/.tk/
address=/.tl/
address=/.tm/
address=/.tn/
address=/.to/
address=/.tp/
address=/.tr/
address=/.tt/
address=/.tz/
address=/.ua/
address=/.ug/
address=/.um/
address=/.uy/
address=/.uz/
address=/.va/
address=/.vc/
address=/.ve/
address=/.vg/
address=/.vi/
address=/.vn/
address=/.vu/
address=/.wf/
address=/.ws/
address=/.ye/
address=/.yt/
address=/.za/
address=/.zm/
address=/.zw/
EOF

cat << EOF > /etc/dnsmasq.d/Blacklist/ads
address=/1.f.ix.de/
address=/101com.com/
address=/101order.com/
address=/1-1ads.com/
address=/123freeavatars.com/
address=/180hits.de/
address=/180searchassistant.com/
address=/1rx.io/
address=/207.net/
address=/247media.com/
address=/24log.com/
address=/24log.de/
address=/24pm-affiliation.com/
address=/2mdn.net/
address=/2o7.net/
address=/2znp09oa.com/
address=/30ads.com/
address=/3337723.com/
address=/33across.com/
address=/360yield.com/
address=/3lift.com/
address=/4affiliate.net/
address=/4d5.net/
address=/4info.com/
address=/4jnzhl0d0.com/
address=/50websads.com/
address=/518ad.com/
address=/51yes.com/
address=/5ijo.01net.com/
address=/5mcwl.pw/
address=/6ldu6qa.com/
address=/6sc.co/
address=/777partner.com/
address=/77tracking.com/
address=/7bpeople.com/
address=/7search.com/
address=/80asehdb/
address=/80aswg/
address=/82o9v830.com/
address=/a.aproductmsg.com/
address=/a.consumer.net/
address=/a.mktw.net/
address=/a.muloqot.uz/
address=/a.pub.network/
address=/a.sakh.com/
address=/a.ucoz.net/
address=/a.ucoz.ru/
address=/a.vartoken.com/
address=/a.vfghd.com/
address=/a.vfgtb.com/
address=/a.xanga.com/
address=/a135.wftv.com/
address=/a5.overclockers.ua/
address=/a8a8altrk.com/
address=/aaddzz.com/
address=/a-ads.com/
address=/aa-metrics.beauty.hotpepper.jp/
address=/aa-metrics.recruit-card.jp/
address=/aa-metrics.trip-ai.jp/
address=/aaxads.com/
address=/aaxdetect.com/
address=/aax-eu.amazon-adsystem.com/
address=/aax-eu-dub.amazon.com/
address=/abacho.net/
address=/abackchain.com/
address=/abandonedaction.com/
address=/abc-ads.com/
address=/aboardlevel.com/
address=/aboutads.gr/
address=/abruptroad.com/
address=/absentstream.com/
address=/absoluteclickscom.com/
address=/absorbingband.com/
address=/absurdwater.com/
address=/abtasty.com/
address=/abz.com/
address=/ac.rnm.ca/
address=/acbsearch.com/
address=/acceptable.a-ads.com/
address=/acid-adserver.click/
address=/acridtwist.com/
address=/actionsplash.com/
address=/actonsoftware.com/
address=/actualdeals.com/
address=/actuallysheep.com/
address=/actuallysnake.com/
address=/acuityads.com/
address=/acuityplatform.com/
address=/ad.100.tbn.ru/
address=/ad.71i.de/
address=/ad.a8.net/
address=/ad.a-ads.com/
address=/ad.abcnews.com/
address=/ad.abctv.com/
address=/ad.aboutwebservices.com/
address=/ad.abum.com/
address=/ad.admitad.com/
address=/ad.allboxing.ru/
address=/ad.allstar.cz/
address=/ad.altervista.org/
address=/ad.amgdgt.com/
address=/ad.anuntis.com/
address=/ad.auditude.com/
address=/ad.bitmedia.io/
address=/ad.bizo.com/
address=/ad.bnmla.com/
address=/ad.bondage.com/
address=/ad.caradisiac.com/
address=/ad.centrum.cz/
address=/ad.cgi.cz/
address=/ad.choiceradio.com/
address=/ad.clix.pt/
address=/ad.cooks.com/
address=/ad.digitallook.com/
address=/ad.domainfactory.de/
address=/ad.eurosport.com/
address=/ad.exyws.org/
address=/ad.flurry.com/
address=/ad.foxnetworks.com/
address=/ad.freecity.de/
address=/ad.grafika.cz/
address=/ad.gt/
address=/ad.hbv.de/
address=/ad.hodomobile.com/
address=/ad.hyena.cz/
address=/ad.iinfo.cz/
address=/ad.ilove.ch/
address=/ad.infoseek.com/
address=/ad.intl.xiaomi.com/
address=/ad.jacotei.com.br/
address=/ad.jamba.net/
address=/ad.jamster.co.uk/
address=/ad.jetsoftware.com/
address=/ad.keenspace.com/
address=/ad.liveinternet.ru/
address=/ad.lupa.cz/
address=/ad.media-servers.net/
address=/ad.mediastorm.hu/
address=/ad.mg/
address=/ad.mobstazinc.cn/
address=/ad.musicmatch.com/
address=/ad.myapple.pl/
address=/ad.mynetreklam.com.streamprovider.net/
address=/ad.nachtagenten.de/
address=/ad.nozonedata.com/
address=/ad.nttnavi.co.jp/
address=/ad.nwt.cz/
address=/ad.pandora.tv/
address=/ad.period-calendar.com/
address=/ad.preferances.com/
address=/ad.profiwin.de/
address=/ad.prv.pl/
address=/ad.reunion.com/
address=/ad.sensismediasmart.com.au/
address=/ad.simflight.com/
address=/ad.simgames.net/
address=/ad.style/
address=/ad.tapthislink.com/
address=/ad.tbn.ru/
address=/ad.technoratimedia.com/
address=/ad.thewheelof.com/
address=/ad.turn.com/
address=/ad.tv2.no/
address=/ad.universcine.com/
address=/ad.usatoday.com/
address=/ad.virtual-nights.com/
address=/ad.wavu.hu/
address=/ad.way.cz/
address=/ad.weatherbug.com/
address=/ad.wsod.com/
address=/ad.wz.cz/
address=/ad.xiaomi.com/
address=/ad.xmovies8.si/
address=/ad.xrea.com/
address=/ad.yadro.ru/
address=/ad.zanox.com/
address=/ad0.bigmir.net/
address=/ad01.mediacorpsingapore.com/
address=/ad1.emule-project.org/
address=/ad1.eventmanager.co.kr/
address=/ad1.kde.cz/
address=/ad1.pamedia.com.au/
address=/ad1mat.de/
address=/ad2.iinfo.cz/
address=/ad2.lupa.cz/
address=/ad2.netriota.hu/
address=/ad2.nmm.de/
address=/ad2.xrea.com/
address=/ad2mat.de/
address=/ad3.iinfo.cz/
address=/ad3.pamedia.com.au/
address=/ad3.xrea.com/
address=/ad3mat.de/
address=/ad4game.com/
address=/ad4mat.com/
address=/ad4mat.de/
address=/ad4mat.net/
address=/adabra.com/
address=/adaction.de/
address=/adadvisor.net/
address=/adalliance.io/
address=/adap.tv/
address=/adapt.tv/
address=/adaranth.com/
address=/ad-balancer.at/
address=/ad-balancer.net/
address=/adbilty.me/
address=/adblade.com/
address=/adblade.org/
address=/adblockanalytics.com/
address=/adbooth.net/
address=/adbot.com/
address=/adbrite.com/
address=/adbrn.com/
address=/adbroker.de/
address=/adbunker.com/
address=/adbutler.com/
address=/adbuyer.com/
address=/adbuyer3.lycos.com/
address=/adcampo.com/
address=/adcannyads.com/
address=/adcash.com/
address=/adcast.deviantart.com/
address=/adcell.de/
address=/adcenter.net/
address=/adcentriconline.com/
address=/adclick.com/
address=/adclick.de/
address=/adclick.net/
address=/adclient1.tucows.com/
address=/adcolony.com/
address=/adcomplete.com/
address=/adconion.com/
address=/adcontent.gamespy.com/
address=/adcontrolsolutions.net/
address=/ad-cupid.com/
address=/adcycle.com/
address=/add.newmedia.cz/
address=/ad-delivery.net/
address=/addfreestats.com/
address=/addme.com/
address=/adecn.com/
address=/adeimptrck.com/
address=/ademails.com/
address=/adengage.com/
address=/adetracking.com/
address=/adexc.net/
address=/adexchangegate.com/
address=/adexchangeprediction.com/
address=/adexpose.com/
address=/adext.inkclub.com/
address=/adf.ly/
address=/adfarm.com/
address=/adfarm.de/
address=/adfarm.mediaplex.com/
address=/adfarm.net/
address=/adfarm1.com/
address=/adfarm1.net/
address=/adfarm2.com/
address=/adfarm2.net/
address=/adfarm3.com/
address=/adfarm3.de/
address=/adfarm3.net/
address=/adfarm4.com/
address=/adfarm4.de/
address=/adfarm4.net/
address=/adfarmonline.com/
address=/adfarmonline.de/
address=/adfarmonline.net/
address=/adflight.com/
address=/adforce.com/
address=/adform.com/
address=/adform.de/
address=/adform.net/
address=/adformdsp.net/
address=/adfram.net/
address=/adfram1.de/
address=/adfram2.de/
address=/adfrom.com/
address=/adfrom.de/
address=/adfrom.net/
address=/adfs.senacrs.com.br/
address=/adgardener.com/
address=/adgoto.com/
address=/adhaven.com/
address=/adhese.be/
address=/adhese.com/
address=/adhigh.net/
address=/adhoc4.net/
address=/adhunter.media/
address=/adidas-deutschland.com/
address=/adimage.guardian.co.uk/
address=/adimages.been.com/
address=/adimages.carsoup.com/
address=/adimages.go.com/
address=/adimages.homestore.com/
address=/adimages.omroepzeeland.nl/
address=/adimages.sanomawsoy.fi/
address=/adimg.com.com/
address=/adimg.uimserv.net/
address=/adimg1.chosun.com/
address=/adimgs.sapo.pt/
address=/adinjector.net/
address=/adinterax.com/
address=/adisfy.com/
address=/adition.com/
address=/adition.de/
address=/adition.net/
address=/adizio.com/
address=/adjix.com/
address=/ad-js.*/
address=/ad-js.bild.de/
address=/ad-js.chip.de/
address=/ad-js.focus.de/
address=/ad-js.welt.de/
address=/adjug.com/
address=/adjuggler.com/
address=/adjuggler.yourdictionary.com/
address=/adjustnetwork.com/
address=/adk2.co/
address=/adk2.com/
address=/adland.ru/
address=/adledge.com/
address=/adlegend.com/
address=/adlightning.com/
address=/adlog.com.com/
address=/adloox.com/
address=/adlooxtracking.com/
address=/adlure.net/
address=/adm.fwmrm.net/
address=/admagnet.net/
address=/admailtiser.com/
address=/adman.gr/
address=/adman.otenet.gr/
address=/admanagement.ch/
address=/admanager.btopenworld.com/
address=/admanager.carsoup.com/
address=/admanmedia.com/
address=/admantx.com/
address=/admarketplace.net/
address=/admarvel.com/
address=/admaster.com.cn/
address=/admatchly.com/
address=/admax.nexage.com/
address=/admedia.com/
address=/admeld.com/
address=/admeridianads.com/
address=/admeta.com/
address=/admex.com/
address=/admidadsp.com/
address=/adminder.com/
address=/adminshop.com/
address=/admix.in/
address=/admixer.net/
address=/admized.com/
address=/admob.com/
address=/admonitor.com/
address=/admotion.com.ar/
address=/adn.lrb.co.uk/
address=/adnet.asahi.com/
address=/adnet.biz/
address=/adnet.de/
address=/adnet.ru/
address=/adnetinteractive.com/
address=/adnetwork.net/
address=/adnetworkperformance.com/
address=/adnews.maddog2000.de/
address=/adnium.com/
address=/adnxs.com/
address=/adocean.pl/
address=/adonspot.com/
address=/adoric-om.com/
address=/adorigin.com/
address=/adotmob.com/
address=/ad-pay.de/
address=/adpenguin.biz/
address=/adpepper.dk/
address=/adpepper.nl/
address=/adperium.com/
address=/adpia.vn/
address=/adplus.co.id/
address=/adplxmd.com/
address=/adprofits.ru/
address=/adrazzi.com/
address=/adreactor.com/
address=/adreclaim.com/
address=/adrecover.com/
address=/adrecreate.com/
address=/adremedy.com/
address=/adreporting.com/
address=/adrevolver.com/
address=/adriver.ru/
address=/adrolays.de/
address=/adrotate.de/
address=/ad-rotator.com/
address=/adrotic.girlonthenet.com/
address=/adrta.com/
address=/ads.365.mk/
address=/ads.4tube.com/
address=/ads.5ci.lt/
address=/ads.5min.at/
address=/ads.73dpi.com/
address=/ads.aavv.com/
address=/ads.abovetopsecret.com/
address=/ads.aceweb.net/
address=/ads.acpc.cat/
address=/ads.acrosspf.com/
address=/ads.activestate.com/
address=/ads.ad-center.com/
address=/ads.adfox.ru/
address=/ads.administrator.de/
address=/ads.adred.de/
address=/ads.adstream.com.ro/
address=/ads.adultfriendfinder.com/
address=/ads.advance.net/
address=/ads.adverline.com/
address=/ads.affiliates.match.com/
address=/ads.alive.com/
address=/ads.alt.com/
address=/ads.amdmb.com/
address=/ads.amigos.com/
address=/ads.annabac.com/
address=/ads.aol.co.uk/
address=/ads.apn.co.nz/
address=/ads.appsgeyser.com/
address=/ads.apteka254.ru/
address=/ads.as4x.tmcs.net/
address=/ads.as4x.tmcs.ticketmaster.com/
address=/ads.asiafriendfinder.com/
address=/ads.aspalliance.com/
address=/ads.avazu.net/
address=/ads.bb59.ru/
address=/ads.belointeractive.com/
address=/ads.betfair.com/
address=/ads.bigchurch.com/
address=/ads.bigfoot.com/
address=/ads.bing.com/
address=/ads.bittorrent.com/
address=/ads.biz.tr/
address=/ads.blog.com/
address=/ads.bloomberg.com/
address=/ads.bluemountain.com/
address=/ads.boerding.com/
address=/ads.bonniercorp.com/
address=/ads.boylesports.com/
address=/ads.brabys.com/
address=/ads.brazzers.com/
address=/ads.bumq.com/
address=/ads.businessweek.com/
address=/ads.canalblog.com/
address=/ads.casinocity.com/
address=/ads.casumoaffiliates.com/
address=/ads.cbc.ca/
address=/ads.cc/
address=/ads.cc-dt.com/
address=/ads.centraliprom.com/
address=/ads.channel4.com/
address=/ads.cheabit.com/
address=/ads.citymagazine.si/
address=/ads.clasificadox.com/
address=/ads.clearchannel.com/
address=/ads.co.com/
address=/ads.colombiaonline.com/
address=/ads.com.com/
address=/ads.comeon.com/
address=/ads.contactmusic.com/
address=/ads.contentabc.com/
address=/ads.contextweb.com/
address=/ads.crakmedia.com/
address=/ads.creative-serving.com/
address=/ads.cybersales.cz/
address=/ads.dada.it/
address=/ads.dailycamera.com/
address=/ads.datingyes.com/
address=/ads.delfin.bg/
address=/ads.deltha.hu/
address=/ads.dennisnet.co.uk/
address=/ads.desmoinesregister.com/
address=/ads.detelefoongids.nl/
address=/ads.deviantart.com/
address=/ads.devmates.com/
address=/ads.digital-digest.com/
address=/ads.digitalmedianet.com/
address=/ads.digitalpoint.com/
address=/ads.directionsmag.com/
address=/ads.domain.com/
address=/ads.domeus.com/
address=/ads.dtpnetwork.biz/
address=/ads.eagletribune.com/
address=/ads.easy-forex.com/
address=/ads.economist.com/
address=/ads.edbindex.dk/
address=/ads.egrana.com.br/
address=/ads.elcarado.com/
address=/ads.electrocelt.com/
address=/ads.elitetrader.com/
address=/ads.emdee.ca/
address=/ads.emirates.net.ae/
address=/ads.epi.sk/
address=/ads.epltalk.com/
address=/ads.eu.msn.com/
address=/ads.exactdrive.com/
address=/ads.expat-blog.biz/
address=/ads.fairfax.com.au/
address=/ads.fastcomgroup.it/
address=/ads.fasttrack-ignite.com/
address=/ads.faxo.com/
address=/ads.femmefab.nl/
address=/ads.ferianc.com/
address=/ads.filmup.com/
address=/ads.financialcontent.com/
address=/ads.flooble.com/
address=/ads.fool.com/
address=/ads.footymad.net/
address=/ads.forbes.net/
address=/ads.formit.cz/
address=/ads.fortunecity.com/
address=/ads.fotosidan.se/
address=/ads.foxnetworks.com/
address=/ads.freecity.de/
address=/ads.friendfinder.com/
address=/ads.gamecity.net/
address=/ads.gamershell.com/
address=/ads.gamespyid.com/
address=/ads.gamigo.de/
address=/ads.gaming1.com/
address=/ads.gaming-universe.de/
address=/ads.gawker.com/
address=/ads.gaypoint.hu/
address=/ads.geekswithblogs.net/
address=/ads.getlucky.com/
address=/ads.gld.dk/
address=/ads.glispa.com/
address=/ads.gmodules.com/
address=/ads.goyk.com/
address=/ads.gplusmedia.com/
address=/ads.gradfinder.com/
address=/ads.grindinggears.com/
address=/ads.groupewin.fr/
address=/ads.gsmexchange.com/
address=/ads.gsm-exchange.com/
address=/ads.guardian.co.uk/
address=/ads.guardianunlimited.co.uk/
address=/ads.guru3d.com/
address=/ads.harpers.org/
address=/ads.hbv.de/
address=/ads.hearstmags.com/
address=/ads.heartlight.org/
address=/ads.heias.com/
address=/ads.hollywood.com/
address=/ads.horsehero.com/
address=/ads.horyzon-media.com/
address=/ads.ibest.com.br/
address=/ads.ibryte.com/
address=/ads.icq.com/
address=/ads.ign.com/
address=/ads.imagistica.com/
address=/ads.img.co.za/
address=/ads.imgur.com/
address=/ads.independent.com.mt/
address=/ads.infi.net/
address=/ads.internic.co.il/
address=/ads.ipowerweb.com/
address=/ads.isoftmarketing.com/
address=/ads.itv.com/
address=/ads.iwon.com/
address=/ads.jewishfriendfinder.com/
address=/ads.jiwire.com/
address=/ads.joaffs.com/
address=/ads.jobsite.co.uk/
address=/ads.jpost.com/
address=/ads.junctionbox.com/
address=/ads.justhungry.com/
address=/ads.kabooaffiliates.com/
address=/ads.kaktuz.net/
address=/ads.kelbymediagroup.com/
address=/ads.kinobox.cz/
address=/ads.kinxxx.com/
address=/ads.kompass.com/
address=/ads.krawall.de/
address=/ads.lapalingo.com/
address=/ads.larryaffiliates.com/
address=/ads.leovegas.com/
address=/ads.lesbianpersonals.com/
address=/ads.liberte.pl/
address=/ads.lifethink.net/
address=/ads.linkedin.com/
address=/ads.livenation.com/
address=/ads.lordlucky.com/
address=/ads.ma7.tv/
address=/ads.mail.bg/
address=/ads.mariuana.it/
address=/ads.massinfra.nl/
address=/ads.mcafee.com/
address=/ads.mediaodyssey.com/
address=/ads.mediasmart.es/
address=/ads.medienhaus.de/
address=/ads.meetcelebs.com/
address=/ads.metaplug.com/
address=/ads.mgnetwork.com/
address=/ads.miarroba.com/
address=/ads.mic.com/
address=/ads.mmania.com/
address=/ads.mobilebet.com/
address=/ads.mopub.com/
address=/ads.motor-forum.nl/
address=/ads.msn.com/
address=/ads.multimania.lycos.fr/
address=/ads.muslimehelfen.org/
address=/ads.mvscoelho.com/
address=/ads.myadv.org/
address=/ads.nccwebs.com/
address=/ads.ncm.com/
address=/ads.ndtv1.com/
address=/ads.networksolutions.com/
address=/ads.newgrounds.com/
address=/ads.newmedia.cz/
address=/ads.newsint.co.uk/
address=/ads.newsquest.co.uk/
address=/ads.ninemsn.com.au/
address=/ads.nj.com/
address=/ads.nola.com/
address=/ads.nordichardware.com/
address=/ads.nordichardware.se/
address=/ads.nyi.net/
address=/ads.nytimes.com/
address=/ads.nyx.cz/
address=/ads.nzcity.co.nz/
address=/ads.o2.pl/
address=/ads.oddschecker.com/
address=/ads.okcimg.com/
address=/ads.ole.com/
address=/ads.oneplace.com/
address=/ads.opensubtitles.org/
address=/ads.optusnet.com.au/
address=/ads.outpersonals.com/
address=/ads.oxyshop.cz/
address=/ads.passion.com/
address=/ads.pennet.com/
address=/ads.pfl.ua/
address=/ads.phpclasses.org/
address=/ads.pinterest.com/
address=/ads.planet.nl/
address=/ads.pni.com/
address=/ads.pof.com/
address=/ads.powweb.com/
address=/ads.ppvmedien.de/
address=/ads.praguetv.cz/
address=/ads.primissima.it/
address=/ads.printscr.com/
address=/ads.prisacom.com/
address=/ads.privatemedia.co/
address=/ads.program3.com/
address=/ads.programattik.com/
address=/ads.psd2html.com/
address=/ads.pushplay.com/
address=/ads.quoka.de/
address=/ads.radialserver.com/
address=/ads.radio1.lv/
address=/ads.rcncdn.de/
address=/ads.rcs.it/
address=/ads.recoletos.es/
address=/ads.rediff.com/
address=/ads.redlightcenter.com/
address=/ads.revjet.com/
address=/ads.satyamonline.com/
address=/ads.saymedia.com/
address=/ads.schmoozecom.net/
address=/ads.scifi.com/
address=/ads.seniorfriendfinder.com/
address=/ads.servebom.com/
address=/ads.sexgratuit.tv/
address=/ads.sexinyourcity.com/
address=/ads.shizmoo.com/
address=/ads.shopstyle.com/
address=/ads.sift.co.uk/
address=/ads.silverdisc.co.uk/
address=/ads.simplyhired.com/
address=/ads.sjon.info/
address=/ads.smartclick.com/
address=/ads.socapro.com/
address=/ads.socialtheater.com/
address=/ads.soft32.com/
address=/ads.soweb.gr/
address=/ads.space.com/
address=/ads.stackoverflow.com/
address=/ads.sun.com/
address=/ads.suomiautomaatti.com/
address=/ads.supplyframe.com/
address=/ads.syscdn.de/
address=/ads.tahono.com/
address=/ads.themovienation.com/
address=/ads.thestar.com/
address=/ads.thrillsaffiliates.com/
address=/ads.tiktok.com/
address=/ads.tmcs.net/
address=/ads.todoti.com.br/
address=/ads.toplayaffiliates.com/
address=/ads.totallyfreestuff.com/
address=/ads.townhall.com/
address=/ads.travelaudience.com/
address=/ads.tremorhub.com/
address=/ads.trinitymirror.co.uk/
address=/ads.tripod.com/
address=/ads.tripod.lycos.co.uk/
address=/ads.tripod.lycos.de/
address=/ads.tripod.lycos.es/
address=/ads.tripod.lycos.it/
address=/ads.tripod.lycos.nl/
address=/ads.tso.dennisnet.co.uk/
address=/ads.twitter.com/
address=/ads.twojatv.info/
address=/ads.uknetguide.co.uk/
address=/ads.ultimate-guitar.com/
address=/ads.uncrate.com/
address=/ads.undertone.com/
address=/ads.unison.bg/
address=/ads.usatoday.com/
address=/ads.uxs.at/
address=/ads.verticalresponse.com/
address=/ads.vgchartz.com/
address=/ads.videosz.com/
address=/ads.viksaffiliates.com/
address=/ads.virtual-nights.com/
address=/ads.virtuopolitan.com/
address=/ads.v-lazer.com/
address=/ads.vnumedia.com/
address=/ads.walkiberia.com/
address=/ads.waps.cn/
address=/ads.wapx.cn/
address=/ads.watson.ch/
address=/ads.weather.ca/
address=/ads.web.de/
address=/ads.webinak.sk/
address=/ads.webmasterpoint.org/
address=/ads.websiteservices.com/
address=/ads.whoishostingthis.com/
address=/ads.wiezoekje.nl/
address=/ads.wikia.nocookie.net/
address=/ads.wineenthusiast.com/
address=/ads.wwe.biz/
address=/ads.xhamster.com/
address=/ads.xtra.co.nz/
address=/ads.yahoo.com/
address=/ads.yap.yahoo.com/
address=/ads.yimg.com/
address=/ads.yldmgrimg.net/
address=/ads.yourfreedvds.com/
address=/ads.youtube.com/
address=/ads.yumenetworks.com/
address=/ads.zmarsa.com/
address=/ads.ztod.com/
address=/ads1.mediacapital.pt/
address=/ads1.msn.com/
address=/ads1.rne.com/
address=/ads1.virtual-nights.com/
address=/ads10.speedbit.com/
address=/ads180.com/
address=/ads1-adnow.com/
address=/ads2.brazzers.com/
address=/ads2.clearchannel.com/
address=/ads2.contentabc.com/
address=/ads2.femmefab.nl/
address=/ads2.gamecity.net/
address=/ads2.net-communities.co.uk/
address=/ads2.oneplace.com/
address=/ads2.opensubtitles.org/
address=/ads2.rne.com/
address=/ads2.techads.info/
address=/ads2.virtual-nights.com/
address=/ads2.webdrive.no/
address=/ads2.xnet.cz/
address=/ads2004.treiberupdate.de/
address=/ads24h.net/
address=/ads3.contentabc.com/
address=/ads3.gamecity.net/
address=/ads3.virtual-nights.com/
address=/ads3-adnow.com/
address=/ads4.clearchannel.com/
address=/ads4.gamecity.net/
address=/ads4.virtual-nights.com/
address=/ads4homes.com/
address=/ads5.virtual-nights.com/
address=/ads6.gamecity.net/
address=/ads7.gamecity.net/
address=/adsafeprotected.com/
address=/adsatt.abc.starwave.com/
address=/adsatt.abcnews.starwave.com/
address=/adsatt.espn.go.com/
address=/adsatt.espn.starwave.com/
address=/adsatt.go.starwave.com/
address=/adsby.bidtheatre.com/
address=/adsbydelema.com/
address=/adscale.de/
address=/adscholar.com/
address=/adscience.nl/
address=/ads-click.com/
address=/adsco.re/
address=/ad-score.com/
address=/adscpm.com/
address=/adsdaq.com/
address=/ads-dev.pinterest.com/
address=/adsend.de/
address=/adsense.com/
address=/adsense.de/
address=/adsensecustomsearchads.com/
address=/adserve.ams.rhythmxchange.com/
address=/adserve.gkeurope.de/
address=/adserve.io/
address=/adserve.jbs.org/
address=/adserver.71i.de/
address=/adserver.adultfriendfinder.com/
address=/adserver.adverty.com/
address=/adserver.anawe.cz/
address=/adserver.aol.fr/
address=/adserver.ariase.org/
address=/adserver.bdoce.cl/
address=/adserver.betandwin.de/
address=/adserver.bing.com/
address=/adserver.bizedge.com/
address=/adserver.bizhat.com/
address=/adserver.break-even.it/
address=/adserver.cams.com/
address=/adserver.cdnstream.com/
address=/adserver.com/
address=/adserver.diariodosertao.com.br/
address=/adserver.digitoday.com/
address=/adserver.echdk.pl/
address=/adserver.ekokatu.com/
address=/adserver.freecity.de/
address=/adserver.friendfinder.com/
address=/ad-server.gulasidorna.se/
address=/adserver.html.it/
address=/adserver.hwupgrade.it/
address=/adserver.ilango.de/
address=/adserver.info7.mx/
address=/adserver.irishwebmasterforum.com/
address=/adserver.janes.com/
address=/adserver.lecool.com/
address=/adserver.libero.it/
address=/adserver.madeby.ws/
address=/adserver.mobi/
address=/adserver.msmb.biz/
address=/adserver.news.com.au/
address=/adserver.nydailynews.com/
address=/adserver.o2.pl/
address=/adserver.oddschecker.com/
address=/adserver.omroepzeeland.nl/
address=/adserver.otthonom.hu/
address=/adserver.pampa.com.br/
address=/adserver.pl/
address=/adserver.portugalmail.net/
address=/adserver.pressboard.ca/
address=/adserver.sanomawsoy.fi/
address=/adserver.sciflicks.com/
address=/adserver.scr.sk/
address=/adserver.sharewareonline.com/
address=/adserver.theonering.net/
address=/adserver.trojaner-info.de/
address=/adserver.twitpic.com/
address=/adserver.virginmedia.com/
address=/adserver.yahoo.com/
address=/adserver01.de/
address=/adserver1.backbeatmedia.com/
address=/adserver1.mindshare.de/
address=/adserver1-images.backbeatmedia.com/
address=/adserver2.mindshare.de/
address=/adserverplus.com/
address=/adserverpub.com/
address=/adserversolutions.com/
address=/adserverxxl.de/
address=/adservice.google.com/
address=/adservice.google.com.mt/
address=/adservices.google.com/
address=/adserving.unibet.com/
address=/adservingfront.com/
address=/adsfac.eu/
address=/adsfac.net/
address=/adsfac.us/
address=/adsfactor.net/
address=/adsfeed.brabys.com/
address=/ads-game-187f4.firebaseapp.com/
address=/adshrink.it/
address=/adside.com/
address=/adsiduous.com/
address=/adskeeper.co.uk/
address=/ads-kesselhaus.com/
address=/adsklick.de/
address=/adskpak.com/
address=/adsmart.com/
address=/adsmart.net/
address=/adsmogo.com/
address=/adsnative.com/
address=/adsoftware.com/
address=/adsoldier.com/
address=/adsolut.in/
address=/ad-space.net/
address=/adspeed.net/
address=/adspirit.de/
address=/adsponse.de/
address=/adspsp.com/
address=/adsroller.com/
address=/adsrv.deviantart.com/
address=/adsrv.eacdn.com/
address=/adsrv.iol.co.za/
address=/adsrv.moebelmarkt.tv/
address=/adsrv.swidnica24.pl/
address=/adsrv2.swidnica24.pl/
address=/adsrvr.org/
address=/adsrvus.com/
address=/adstacks.in/
address=/adstage.io/
address=/adstanding.com/
address=/adstat.4u.pl/
address=/adstest.weather.com/
address=/ads-trk.vidible.tv/
address=/ads-twitter.com/
address=/adsupply.com/
address=/adswizz.com/
address=/adsxyz.com/
address=/adsymptotic.com/
address=/adsynergy.com/
address=/adsys.townnews.com/
address=/adsystem.simplemachines.org/
address=/adtech.com/
address=/ad-tech.com/
address=/adtech.de/
address=/adtech-digital.ru/
address=/adtechjp.com/
address=/adtechus.com/
address=/adtegrity.net/
address=/adthis.com/
address=/adthrive.com/
address=/adthurst.com/
address=/adtiger.de/
address=/adtilt.com/
address=/adtng.com/
address=/adtology.com/
address=/adtoma.com/
address=/adtrace.org/
address=/adtrade.net/
address=/adtrak.net/
address=/adtriplex.com/
address=/adult/
address=/adultadvertising.com/
address=/ad-up.com/
address=/adv.cooperhosting.net/
address=/adv.donejty.pl/
address=/adv.freeonline.it/
address=/adv.hwupgrade.it/
address=/adv.livedoor.com/
address=/adv.mezon.ru/
address=/adv.mpvc.it/
address=/adv.nexthardware.com/
address=/adv.webmd.com/
address=/adv.wp.pl/
address=/adv.yo.cz/
address=/adv-adserver.com/
address=/advangelists.com/
address=/advariant.com/
address=/adv-banner.libero.it/
address=/adventory.com/
address=/advert.bayarea.com/
address=/advert.dyna.ultraweb.hu/
address=/adverticum.com/
address=/adverticum.net/
address=/adverticus.de/
address=/advertise.com/
address=/advertiseireland.com/
address=/advertisementafterthought.com/
address=/advertiserurl.com/
address=/advertising.com/
address=/advertisingbanners.com/
address=/advertisingbox.com/
address=/advertmarket.com/
address=/advertmedia.de/
address=/advertpro.ya.com/
address=/advertserve.com/
address=/advertstream.com/
address=/advertwizard.com/
address=/advideo.uimserv.net/
address=/adview.com/
address=/advisormedia.cz/
address=/adviva.net/
address=/advnt.com/
address=/advolution.com/
address=/advolution.de/
address=/adwebone.com/
address=/adwhirl.com/
address=/adwordsecommerce.com.br/
address=/adworldnetwork.com/
address=/adworx.at/
address=/adworx.nl/
address=/adx.allstar.cz/
address=/adx.atnext.com/
address=/adx.bild.de/
address=/adx.chip.de/
address=/adx.focus.de/
address=/adx.gayboy.at/
address=/adx.relaksit.ru/
address=/adx.welt.de/
address=/adxpansion.com/
address=/adxpose.com/
address=/adxvalue.com/
address=/adyea.com/
address=/adyoulike.com/
address=/adz.rashflash.com/
address=/adz2you.com/
address=/adzbazar.com/
address=/adzerk.net/
address=/adzerk.s3.amazonaws.com/
address=/adzestocp.com/
address=/adzone.temp.co.za/
address=/adzones.com/
address=/aerserv.com/
address=/af-ad.co.uk/
address=/affec.tv/
address=/affili.net/
address=/affiliate.1800flowers.com/
address=/affiliate.doubleyourdating.com/
address=/affiliate.dtiserv.com/
address=/affiliate.gamestop.com/
address=/affiliate.mogs.com/
address=/affiliate.offgamers.com/
address=/affiliate.rusvpn.com/
address=/affiliate.travelnow.com/
address=/affiliate.treated.com/
address=/affiliatefuture.com/
address=/affiliates.allposters.com/
address=/affiliates.babylon.com/
address=/affiliates.digitalriver.com/
address=/affiliates.globat.com/
address=/affiliates.rozetka.com.ua/
address=/affiliates.streamray.com/
address=/affiliates.thinkhost.net/
address=/affiliates.thrixxx.com/
address=/affiliates.ultrahosting.com/
address=/affiliatetracking.com/
address=/affiliatetracking.net/
address=/affiliatewindow.com/
address=/affiliation-france.com/
address=/affinity.com/
address=/afftracking.justanswer.com/
address=/agkn.com/
address=/agof.de/
address=/agreeablestew.com/
address=/ahalogy.com/
address=/aheadday.com/
address=/ah-ha.com/
address=/aim4media.com/
address=/airmaxschuheoutlet.com/
address=/airpush.com/
address=/aistat.net/
address=/ak0gsh40.com/
address=/akamaized.net/
address=/akku-laden.at/
address=/aktrack.pubmatic.com/
address=/aladel.net/
address=/alchemist.go2cloud.org/
address=/alclick.com/
address=/alenty.com/
address=/alert.com.mt/
address=/alexametrics.com/
address=/alexa-sitestats.s3.amazonaws.com/
address=/algorix.co/
address=/alipromo.com/
address=/all4spy.com/
address=/allosponsor.com/
address=/aloofvest.com/
address=/alphonso.tv/
address=/als-svc.nytimes.com/
address=/altrk.net/
address=/amazingcounters.com/
address=/amazon.dedp/
address=/amazon-adsystem.com/
address=/ambiguousquilt.com/
address=/ambitiousagreement.com/
address=/americash.com/
address=/amplitude.com/
address=/amung.us/
address=/analdin.com/
address=/analytics.adpost.org/
address=/analytics.bitrix.info/
address=/analytics.cloudron.io/
address=/analytics.cohesionapps.com/
address=/analytics.dnsfilter.com/
address=/analytics.ext.go-tellm.com/
address=/analytics.fkz.re/
address=/analytics.google.com/
address=/analytics.htmedia.in/
address=/analytics.icons8.com/
address=/analytics.inlinemanual.com/
address=/analytics.jst.ai/
address=/analytics.justuno.com/
address=/analytics.live.com/
address=/analytics.mailmunch.co/
address=/analytics.myfinance.com/
address=/analytics.mytvzion.pro/
address=/analytics.ostr.io/
address=/analytics.phando.com/
address=/analytics.picsart.com/
address=/analytics.poolshool.com/
address=/analytics.posttv.com/
address=/analytics.samdd.me/
address=/analytics.siliconexpert.com/
address=/analytics.swiggy.com/
address=/analytics.xelondigital.com/
address=/analytics.yahoo.com/
address=/analyticsapi.happypancake.net/
address=/analytics-production.hapyak.com/
address=/aniview.com/
address=/annonser.dagbladet.no/
address=/annoyedairport.com/
address=/anrdoezrs.net/
address=/anstrex.com/
address=/anuncios.edicaoms.com.br/
address=/anxiousapples.com/
address=/anycracks.com/
address=/aos.prf.hnclick/
address=/apathetictheory.com/
address=/api.adrtx.net/
address=/api.intensifier.de/
address=/api.kameleoon.com/
address=/apolloprogram.io/
address=/app.pendo.io/
address=/app-analytics.snapchat.com/
address=/appboycdn.com/
address=/appliedsemantics.com/
address=/apps5.oingo.com/
address=/appsflyer.com/
address=/aps.hearstnp.com/
address=/apsalar.com/
address=/apture.com/
address=/apu.samsungelectronics.com/
address=/aquaticowl.com/
address=/ar1nvz5.com/
address=/aralego.com/
address=/arc1.msn.com/
address=/archswimming.com/
address=/ard.xxxblackbook.com/
address=/argyresthia.com/
address=/aromamirror.com/
address=/as.webmd.com/
address=/as2.adserverhd.com/
address=/aserv.motorsgate.com/
address=/asewlfjqwlflkew.com/
address=/assets1.exgfnetwork.com/
address=/assoc-amazon.com/
address=/aswpapius.com/
address=/aswpsdkus.com/
address=/at-adserver.alltop.com/
address=/atdmt.com/
address=/athena-ads.wikia.com/
address=/ato.mx/
address=/at-o.net/
address=/attractiveafternoon.com/
address=/attribution.report/
address=/attributiontracker.com/
address=/atwola.com/
address=/auctionads.com/
address=/auctionads.net/
address=/audience.media/
address=/audience2media.com/
address=/audienceinsights.com/
address=/audit.median.hu/
address=/audit.webinform.hu/
address=/augur.io/
address=/auto-bannertausch.de/
address=/automaticflock.com/
address=/avazutracking.net/
address=/avenuea.com/
address=/avocet.io/
address=/avpa.javalobby.org/
address=/awakebird.com/
address=/awempire.com/
address=/awin1.com/
address=/awzbijw.com/
address=/axiomaticalley.com/
address=/axonix.com/
address=/aztracking.net/
address=/b-1st.com/
address=/ba.afl.rakuten.co.jp/
address=/babs.tv2.dk/
address=/backbeatmedia.com/
address=/balloontexture.com/
address=/banik.redigy.cz/
address=/banner.ad.nu/
address=/banner.ambercoastcasino.com/
address=/banner.buempliz-online.ch/
address=/banner.casino.net/
address=/banner.casinodelrio.com/
address=/banner.cotedazurpalace.com/
address=/banner.coza.com/
address=/banner.cz/
address=/banner.easyspace.com/
address=/banner.elisa.net/
address=/banner.eurogrand.com/
address=/banner.finzoom.ro/
address=/banner.goldenpalace.com/
address=/banner.icmedia.eu/
address=/banner.img.co.za/
address=/banner.inyourpocket.com/
address=/banner.kiev.ua/
address=/banner.linux.se/
address=/banner.media-system.de/
address=/banner.mindshare.de/
address=/banner.nixnet.cz/
address=/banner.noblepoker.com/
address=/banner.northsky.com/
address=/banner.orb.net/
address=/banner.penguin.cz/
address=/banner.rbc.ru/
address=/banner.reinstil.de/
address=/banner.relcom.ru/
address=/banner.tanto.de/
address=/banner.titan-dsl.de/
address=/banner.t-online.de/
address=/banner.vadian.net/
address=/banner.webmersion.com/
address=/banner10.zetasystem.dk/
address=/bannerads.de/
address=/bannerboxes.com/
address=/bannerconnect.com/
address=/bannerconnect.net/
address=/banner-exchange-24.de/
address=/bannergrabber.internet.gr/
address=/bannerimage.com/
address=/bannerlandia.com.ar/
address=/bannermall.com/
address=/bannermanager.bnr.bg/
address=/bannermarkt.nl/
address=/bannerpower.com/
address=/banners.adultfriendfinder.com/
address=/banners.amigos.com/
address=/banners.asiafriendfinder.com/
address=/banners.babylon-x.com/
address=/banners.bol.com.br/
address=/banners.cams.com/
address=/banners.clubseventeen.com/
address=/banners.czi.cz/
address=/banners.dine.com/
address=/banners.direction-x.com/
address=/banners.friendfinder.com/
address=/banners.getiton.com/
address=/banners.golfasian.com/
address=/banners.iq.pl/
address=/banners.isoftmarketing.com/
address=/banners.linkbuddies.com/
address=/banners.passion.com/
address=/banners.payserve.com/
address=/banners.resultonline.com/
address=/banners.sys-con.com/
address=/banners.thomsonlocal.com/
address=/banners.videosz.com/
address=/banners.virtuagirlhd.com/
address=/bannerserver.com/
address=/bannersgomlm.com/
address=/bannershotlink.perfectgonzo.com/
address=/bannersng.yell.com/
address=/bannerspace.com/
address=/bannerswap.com/
address=/bannertesting.com/
address=/bannertrack.net/
address=/bannery.cz/
address=/bannieres.acces-contenu.com/
address=/bannieres.wdmedia.net/
address=/bans.bride.ru/
address=/barbarousnerve.com/
address=/barnesandnoble.bfast.com/
address=/basebanner.com/
address=/baskettexture.com/
address=/bat.bing.com/
address=/batbuilding.com/
address=/bawdybeast.com/
address=/baypops.com/
address=/bbelements.com/
address=/bbjacke.de/
address=/bbn.img.com.ua/
address=/beachfront.com/
address=/beacon.gu-web.net/
address=/beamincrease.com/
address=/bebi.com/
address=/beemray.com/
address=/begun.ru/
address=/behavioralengine.com/
address=/belstat.com/
address=/belstat.nl/
address=/berp.com/
address=/bestboundary.com/
address=/bestcheck.de/
address=/bestsearch.net/
address=/bewilderedblade.com/
address=/bfmio.com/
address=/bg/
address=/bhcumsc.com/
address=/biallo.de/
address=/bidbarrel.cbsnews.com/
address=/bidclix.com/
address=/bidclix.net/
address=/bidr.io/
address=/bidsopt.com/
address=/bidswitch.net/
address=/bidtellect.com/
address=/bidvertiser.com/
address=/big-bang-ads.com/
address=/bigbangmedia.com/
address=/bigclicks.com/
address=/bigpoint.com/
address=/bigreal.org/
address=/bilano.de/
address=/bild.ivwbox.de/
address=/billalo.de/
address=/billboard.cz/
address=/billiger.decommonmodulesapi/
address=/biohazard.xz.cz/
address=/biosda.com/
address=/bitmedianetwork.com/
address=/bizad.nikkeibp.co.jp/
address=/bizible.com/
address=/bizographics.com/
address=/bizrate.com/
address=/bizzclick.com/
address=/bkrtx.com/
address=/blingbucks.com/
address=/blis.com/
address=/blockadblock.com/
address=/blockthrough.com/
address=/blogads.com/
address=/blogcounter.de/
address=/blogherads.com/
address=/blogtoplist.se/
address=/blogtopsites.com/
address=/blueadvertise.com/
address=/blueconic.com/
address=/blueconic.net/
address=/bluekai.com/
address=/bluelithium.com/
address=/bluewhaleweb.com/
address=/blushingbeast.com/
address=/blushingboundary.com/
address=/bm.annonce.cz/
address=/bn.bfast.com/
address=/bnnrrv.qontentum.de/
address=/bnrs.ilm.ee/
address=/boffoadsapi.com/
address=/boilingbeetle.com/
address=/boilingumbrella.com/
address=/bongacash.com/
address=/boomads.com/
address=/boomtrain.com/
address=/boost-my-pr.de/
address=/boredcrown.com/
address=/boringcoat.com/
address=/boudja.com/
address=/bounceads.net/
address=/bounceexchange.com/
address=/bowie-cdn.fathomdns.com/
address=/box.anchorfree.net/
address=/bpath.com/
address=/bpu.samsungelectronics.com/
address=/bpwhamburgorchardpark.org/
address=/braincash.com/
address=/brand-display.com/
address=/brandreachsys.com/
address=/breaktime.com.tw/
address=/brealtime.com/
address=/bridgetrack.com/
address=/brightcom.com/
address=/brightinfo.com/
address=/brightmountainmedia.com/
address=/british-banners.com/
address=/broadboundary.com/
address=/broadcastbed.com/
address=/broaddoor.com/
address=/browser-http-intake.logs.datadoghq.com/
address=/browser-http-intake.logs.datadoghq.eu/
address=/bs.yandex.ru/
address=/btez8.xyz/
address=/btrll.com/
address=/bttrack.com/
address=/bu/
address=/bucketbean.com/
address=/bullseye.backbeatmedia.com/
address=/businessbells.com/
address=/bustlinganimal.com/
address=/buysellads.com/
address=/buzzonclick.com/
address=/bwp.download.com/
address=/by/
address=/c.bigmir.net/
address=/c1.nowlinux.com/
address=/c1exchange.com/
address=/calculatingcircle.com/
address=/calculatingtoothbrush.com/
address=/calculatorcamera.com/
address=/callousbrake.com/
address=/callrail.com/
address=/calmcactus.com/
address=/campaign.bharatmatrimony.com/
address=/caniamedia.com/
address=/cannads.urgrafix.com/
address=/capablecows.com/
address=/captainbicycle.com/
address=/carambo.la/
address=/carbonads.com/
address=/carbonads.net/
address=/casalemedia.com/
address=/casalmedia.com/
address=/cash4members.com/
address=/cash4popup.de/
address=/cashcrate.com/
address=/cashengines.com/
address=/cashfiesta.com/
address=/cashpartner.com/
address=/cashstaging.me/
address=/casinopays.com/
address=/casinorewards.com/
address=/casinotraffic.com/
address=/causecherry.com/
address=/cbanners.virtuagirlhd.com/
address=/cdn.bannerflow.com/
address=/cdn.branch.io/
address=/cdn.flashtalking.com/
address=/cdn.freefarcy.com/
address=/cdn.freshmarketer.com/
address=/cdn.heapanalytics.com/
address=/cdn.keywee.co/
address=/cdn.onesignal.com/
address=/cdn.segment.com/
address=/cdn1.spiegel.deimages/
address=/cecash.com/
address=/cedato.com/
address=/celtra.com/
address=/centerpointmedia.com/
address=/centgebote.tv/
address=/ceskydomov.alias.ngs.modry.cz/
address=/cetrk.com/
address=/cgicounter.puretec.de/
address=/chairscrack.com/
address=/chameleon.ad/
address=/channelintelligence.com/
address=/chardwardse.club/
address=/chart.dk/
address=/chartbeat.com/
address=/chartbeat.net/
address=/chartboost.com/
address=/checkm8.com/
address=/checkstat.nl/
address=/cheerfulrange.com/
address=/chewcoat.com/
address=/chickensstation.com/
address=/chinsnakes.com/
address=/chitika.net/
address=/cision.com/
address=/cityads.telus.net/
address=/cj.com/
address=/cjbmanagement.com/
address=/cjlog.com/
address=/cl0udh0st1ng.com/
address=/claria.com/
address=/clevernt.com/
address=/click/
address=/click.a-ads.com/
address=/click.cartsguru.io/
address=/click.email.bbc.com/
address=/click.email.sonos.com/
address=/click.fool.com/
address=/click.kmindex.ru/
address=/click.negociosdigitaisnapratica.com.br/
address=/click.redditmail.com/
address=/click.twcwigs.com/
address=/click2freemoney.com/
address=/clickability.com/
address=/clickadz.com/
address=/clickagents.com/
address=/clickbank.com/
address=/clickbooth.com/
address=/clickboothlnk.com/
address=/clickbrokers.com/
address=/clickcompare.co.uk/
address=/clickdensity.com/
address=/clickedyclick.com/
address=/clickfuse.com/
address=/clickhereforcellphones.com/
address=/clickhouse.com/
address=/clickhype.com/
address=/clicklink.jp/
address=/clickmate.io/
address=/clickonometrics.pl/
address=/clicks.equantum.com/
address=/clicks.mods.de/
address=/clickserve.cc-dt.com/
address=/clicktag.de/
address=/clickthruserver.com/
address=/clickthrutraffic.com/
address=/clicktrace.info/
address=/clicktrack.ziyu.net/
address=/clicktracks.com/
address=/clicktrade.com/
address=/clickwith.bid/
address=/clickxchange.com/
address=/clickyab.com/
address=/clickz.com/
address=/clientmetrics-pa.googleapis.com/
address=/clikerz.net/
address=/cliksolution.com/
address=/clixgalore.com/
address=/clk1005.com/
address=/clk1011.com/
address=/clk1015.com/
address=/clkrev.com/
address=/clksite.com/
address=/cloisteredhydrant.com/
address=/cloudcoins.biz/
address=/clrstm.com/
address=/cluster.adultworld.com/
address=/clustrmaps.com/
address=/cmp.dmgmediaprivacy.co.uk/
address=/cmvrclicks000.com/
address=/cnomy.com/
address=/cnt.spbland.ru/
address=/cnt1.pocitadlo.cz/
address=/cny.yoyo.org/
address=/codeadnetwork.com/
address=/code-server.biz/
address=/cognitiv.ai/
address=/cognitiveadscience.com/
address=/coinhive.com/
address=/coin-hive.com/
address=/cointraffic.io/
address=/colonize.com/
address=/comclick.com/
address=/comfortablecheese.com/
address=/commindo-media-ressourcen.de/
address=/commissionmonster.com/
address=/commonswing.com/
address=/compactbanner.com/
address=/completecabbage.com/
address=/complextoad.com/
address=/comprabanner.it/
address=/concernedcondition.com/
address=/conductrics.com/
address=/connatix.com/
address=/connectad.io/
address=/connextra.com/
address=/consciouschairs.com/
address=/consensad.com/
address=/consensu.org/
address=/contadores.miarroba.com/
address=/contaxe.de/
address=/content.acc-hd.de/
address=/content.ad/
address=/content22.online.citi.com/
address=/contextweb.com/
address=/converge-digital.com/
address=/conversantmedia.com/
address=/conversionbet.com/
address=/conversionruler.com/
address=/convertingtraffic.com/
address=/convrse.media/
address=/cookies.cmpnet.com/
address=/coordinatedcub.com/
address=/cootlogix.com/
address=/copperchickens.com/
address=/copycarpenter.com/
address=/copyrightaccesscontrols.com/
address=/coqnu.com/
address=/coremetrics.com/
address=/cormast.com/
address=/cosmopolitads.com/
address=/count.rin.ru/
address=/count.west263.com/
address=/counted.com/
address=/counter.bloke.com/
address=/counter.cnw.cz/
address=/counter.cz/
address=/counter.dreamhost.com/
address=/counter.mirohost.net/
address=/counter.mojgorod.ru/
address=/counter.nowlinux.com/
address=/counter.rambler.ru/
address=/counter.search.bg/
address=/counter.snackly.co/
address=/counter.sparklit.com/
address=/counter.yadro.ru/
address=/counters.honesty.com/
address=/counting.kmindex.ru/
address=/coupling-media.de/
address=/coxmt.com/
address=/cp.abbp1.pw/
address=/cpalead.com/
address=/cpays.com/
address=/cpmstar.com/
address=/cpu.samsungelectronics.com/
address=/cpx.to/
address=/cpxinteractive.com/
address=/cqcounter.com/
address=/crabbychin.com/
address=/crakmedia.com/
address=/craktraffic.com/
address=/crawlability.com/
address=/crawlclocks.com/
address=/crazyegg.com/
address=/crazypopups.com/
address=/creafi-online-media.com/
address=/creatives.livejasmin.com/
address=/criteo.com/
address=/criteo.net/
address=/critictruck.com/
address=/croissed.info/
address=/crowdgravity.com/
address=/crsspxl.com/
address=/crta.dailymail.co.uk/
address=/crtv.mate1.com/
address=/crwdcntrl.net/
address=/crypto-loot.org/
address=/cs/
address=/ctnetwork.hu/
address=/cubics.com/
address=/cuii.info/
address=/culturedcrayon.com/
address=/cumbersomecloud.com/
address=/cuponation.de/
address=/curtaincows.com/
address=/custom.plausible.io/
address=/customad.cnn.com/
address=/customers.kameleoon.com/
address=/cutecushion.com/
address=/cuteturkey.com/
address=/cxense.com/
address=/cyberbounty.com/
address=/d.adroll.com/
address=/d2cmedia.ca/
address=/dabiaozhi.com/
address=/dacdn.visualwebsiteoptimizer.com/
address=/dakic-ia-300.com/
address=/damdoor.com/
address=/dancemistake.com/
address=/dapper.net/
address=/dashbida.com/
address=/dashingdirt.com/
address=/dashingsweater.com/
address=/data.namesakeoscilloscopemarquis.com/
address=/data8a8altrk.com/
address=/dbbsrv.com/
address=/dc-storm.com/
address=/de.mediaplex.com/
address=/de17a.com/
address=/deadpantruck.com/
address=/dealdotcom.com/
address=/debonairway.com/
address=/debtbusterloans.com/
address=/decenterads.com/
address=/decisivedrawer.com/
address=/decisiveducks.com/
address=/decknetwork.net/
address=/decoycreation.com/
address=/deepintent.com/
address=/defectivesun.com/
address=/delegatediscussion.com/
address=/deloo.de/
address=/deloplen.com/
address=/deloton.com/
address=/demandbase.com/
address=/demdex.net/
address=/deployads.com/
address=/desertedbreath.com/
address=/desertedrat.com/
address=/detailedglue.com/
address=/detailedgovernment.com/
address=/detectdiscovery.com/
address=/dev.visualwebsiteoptimizer.com/
address=/dianomi.com/
address=/didtheyreadit.com/
address=/digital-ads.s3.amazonaws.com/
address=/digitalmerkat.com/
address=/directaclick.com/
address=/direct-events-collector.spot.im/
address=/directivepub.com/
address=/directleads.com/
address=/directorym.com/
address=/directtrack.com/
address=/direct-xxx-access.com/
address=/discountclick.com/
address=/discreetfield.com/
address=/dispensablestranger.com/
address=/displayadsmedia.com/
address=/disqusads.com/
address=/dist.belnk.com/
address=/distillery.wistia.com/
address=/districtm.ca/
address=/districtm.io/
address=/dk4ywix.com/
address=/dmp.mall.tv/
address=/dmtracker.com/
address=/dmtracking.alibaba.com/
address=/dmtracking2.alibaba.com/
address=/dnsdelegation.io/
address=/dntrax.com/
address=/docksalmon.com/
address=/dogcollarfavourbluff.com/
address=/do-global.com/
address=/domaining.in/
address=/domainsponsor.com/
address=/domainsteam.de/
address=/domdex.com/
address=/dotmetrics.net/
address=/doubleclick.com/
address=/doubleclick.de/
address=/doubleclick.net/
address=/doublepimp.com/
address=/doubleverify.com/
address=/doubtfulrainstorm.com/
address=/downloadr.xyz/
address=/download-service.de/
address=/download-sofort.com/
address=/dpbolvw.net/
address=/dpu.samsungelectronics.com/
address=/dq95d35.com/
address=/drabsize.com/
address=/dragzebra.com/
address=/drumcash.com/
address=/drydrum.com/
address=/ds.serving-sys.com/
address=/dsp.colpirio.com/
address=/dsp.io/
address=/dstillery.com/
address=/dyntrk.com/
address=/e.kde.cz/
address=/eadexchange.com/
address=/e-adimages.scrippsnetworks.com/
address=/earthquakescarf.com/
address=/earthycopy.com/
address=/eas.almamedia.fi/
address=/easycracks.net/
address=/easyhits4u.com/
address=/ebayadvertising.com/
address=/ebuzzing.com/
address=/ecircle-ag.com/
address=/ecleneue.com/
address=/eclick.vn/
address=/eclkmpbn.com/
address=/eclkspbn.com/
address=/economicpizzas.com/
address=/ecoupons.com/
address=/edaa.eu/
address=/emetriq.com/
address=/emetriq.de/
address=/xplosion.de/
address=/xplosion.com/
address=/efahrer.chip.de/
address=/efahrer.de/
address=/efahrer.fokus.de/
address=/effectivemeasure.com/
address=/effectivemeasure.net/
address=/efficaciouscactus.com/
address=/eiv.baidu.com/
address=/ejyymghi.com/
address=/elasticchange.com/
address=/elderlyscissors.com/
address=/elderlytown.com/
address=/elephantqueue.com/
address=/elitedollars.com/
address=/elitetoplist.com/
address=/elthamely.com/
address=/e-m.fr/
address=/emarketer.com/
address=/emebo.com/
address=/emebo.io/
address=/emediate.eu/
address=/emerse.com/
address=/emetriq.de/
address=/emjcd.com/
address=/emltrk.com/
address=/emodoinc.com/
address=/emptyescort.com/
address=/emxdigital.com/
address=/en25.com/
address=/encouragingwilderness.com/
address=/endurableshop.com/
address=/energeticladybug.com/
address=/engage.dnsfilter.com/
address=/engagebdr.com/
address=/engine.espace.netavenir.com/
address=/enginenetwork.com/
address=/enormousearth.com/
address=/enquisite.com/
address=/ensighten.com/
address=/entercasino.com/
address=/enthusiasticdad.com/
address=/entrecard.s3.amazonaws.com/
address=/enviousthread.com/
address=/e-planning.net/
address=/epom.com/
address=/epp.bih.net.ba/
address=/eqads.com/
address=/erne.co/
address=/ero-advertising.com/
address=/espn.com.ssl.sc.omtrdc.net/
address=/estat.com/
address=/esty.com/
address=/et.nytimes.com/
address=/etahub.com/
address=/etargetnet.com/
address=/etracker.com/
address=/etracker.de/
address=/eu1.madsone.com/
address=/eu-adcenter.net/
address=/eule1.pmu.fr/
address=/eulerian.net/
address=/eurekster.com/
address=/euros4click.de/
address=/eusta.de/
address=/evadav.com/
address=/evadavdsp.pro/
address=/everestads.net/
address=/everesttech.net/
address=/evergage.com/
address=/eversales.space/
address=/evidon.com/
address=/evyy.net/
address=/ewebcounter.com/
address=/exchangead.com/
address=/exchangeclicksonline.com/
address=/exchange-it.com/
address=/exclusivebrass.com/
address=/exelate.com/
address=/exelator.com/
address=/exit76.com/
address=/exitexchange.com/
address=/exitfuel.com/
address=/exoclick.com/
address=/exosrv.com/
address=/experianmarketingservices.digital/
address=/explorads.com/
address=/exponea.com/
address=/exponential.com/
address=/express-submit.de/
address=/extreme-dm.com/
address=/extremetracking.com/
address=/eyeblaster.com/
address=/eyeota.net/
address=/eyereturn.com/
address=/eyeviewads.com/
address=/eyewonder.com/
address=/ezula.com/
address=/f7ds.liberation.fr/
address=/facilitategrandfather.com/
address=/fadedprofit.com/
address=/fadedsnow.com/
address=/fallaciousfifth.com/
address=/famousquarter.com/
address=/fancy.com/
address=/fancy.de/
address=/fapdu.com/
address=/fapmaps.com/
address=/faracoon.com/
address=/farethief.com/
address=/farmergoldfish.com/
address=/fascinatedfeather.com/
address=/fastclick.com/
address=/fastclick.com.edgesuite.net/
address=/fastclick.net/
address=/fastgetsoftware.com/
address=/fastly-insights.com/
address=/fast-redirecting.com/
address=/faultycanvas.com/
address=/faultyfowl.com/
address=/fc.webmasterpro.de/
address=/feathr.co/
address=/feebleshock.com/
address=/feedbackresearch.com/
address=/feedjit.com/
address=/feedmob.com/
address=/ffxcam.fairfax.com.au/
address=/fimserve.com/
address=/findcommerce.com/
address=/findepended.com/
address=/findyourcasino.com/
address=/fineoffer.net/
address=/fingahvf.top/
address=/first.nova.cz/
address=/firstlightera.com/
address=/fixel.ai/
address=/flairadscpc.com/
address=/flakyfeast.com/
address=/flashtalking.com/
address=/fleshlightcash.com/
address=/flexbanner.com/
address=/flimsycircle.com/
address=/floodprincipal.com/
address=/flowgo.com/
address=/flurry.com/
address=/fly-analytics.com/
address=/focus.deajax/
address=/foo.cosmocode.de/
address=/foresee.com/
address=/forex-affiliate.net/
address=/forkcdn.com/
address=/fourarithmetic.com/
address=/fpctraffic.com/
address=/fpctraffic2.com/
address=/fpjs.io/
address=/fqtag.com/
address=/frailoffer.com/
address=/franzis-sportswear.de/
address=/freebanner.com/
address=/free-banners.com/
address=/free-counter.co.uk/
address=/free-counters.co.uk/
address=/freecounterstat.com/
address=/freelogs.com/
address=/freeonlineusers.com/
address=/freepay.com/
address=/freeskreen.com/
address=/freestats.com/
address=/freestats.tv/
address=/freewebcounter.com/
address=/freewheel.com/
address=/freewheel.tv/
address=/frightenedpotato.com/
address=/frtyj.com/
address=/frtyk.com/
address=/fukc69xo.us/
address=/fullstory.com/
address=/functionalcrown.com/
address=/funklicks.com/
address=/fusionads.net/
address=/fusionquest.com/
address=/futuristicapparatus.com/
address=/futuristicfairies.com/
address=/fuzzybasketball.com/
address=/fuzzyflavor.com/
address=/fuzzyweather.com/
address=/fxstyle.net/
address=/g.msn.comAIPRIV/
address=/g4u.me/
address=/ga.clearbit.com/
address=/ga87z2o.com/
address=/gadsbee.com/
address=/galaxien.com/
address=/game-advertising-online.com/
address=/gamehouse.com/
address=/gamesites100.net/
address=/gamesites200.com/
address=/gammamaximum.com/
address=/gearwom.de/
address=/gekko.spiceworks.com/
address=/gemini.yahoo.com/
address=/geo.digitalpoint.com/
address=/geobanner.adultfriendfinder.com/
address=/georiot.com/
address=/geovisite.com/
address=/getclicky.com/
address=/getintent.com/
address=/getmyads.com/
address=/giddycoat.com/
address=/globalismedia.com/
address=/globaltakeoff.net/
address=/globus-inter.com/
address=/glossysense.com/
address=/gloyah.net/
address=/gmads.net/
address=/gml.email/
address=/go2affise.com/
address=/go-clicks.de/
address=/goingplatinum.com/
address=/goldstats.com/
address=/go-mpulse.net/
address=/gondolagnome.com/
address=/google.comadsense/
address=/google.comurl?q=*/
address=/googleadservices.com/
address=/googleanalytics.com/
address=/google-analytics.com/
address=/googlesyndication.com/
address=/googletagmanager.com/
address=/googletagservices.com/
address=/go-rank.de/
address=/gorgeousground.com/
address=/gostats.com/
address=/gothamads.com/
address=/gotraffic.net/
address=/gp.dejanews.com/
address=/gracefulsock.com/
address=/graizoah.com/
address=/grandioseguide.com/
address=/grapeshot.co.uk/
address=/greetzebra.com/
address=/greyinstrument.com/
address=/greystripe.com/
address=/grosshandel-angebote.de/
address=/groundtruth.com/
address=/gscontxt.net/
address=/gtop100.com/
address=/guardedschool.com/
address=/gunggo.com/
address=/guruads.de/
address=/gutscheine.bild.de/
address=/gutscheine.chip.de/
address=/gutscheine.focus.de/
address=/gutscheine.welt.de/
address=/h0.t.hubspotemail.net/
address=/h78xb.pw/
address=/habitualhumor.com/
address=/hackpalace.com/
address=/hadskiz.com/
address=/haltingbadge.com/
address=/hammerhearing.com/
address=/handyfield.com/
address=/hardtofindmilk.com/
address=/harrenmedia.com/
address=/harrenmedianetwork.com/
address=/havamedia.net/
address=/hb.afl.rakuten.co.jp/
address=/hbb.afl.rakuten.co.jp/
address=/h-bid.com/
address=/hdscout.com/
address=/heap.com/
address=/heias.com/
address=/heise.demediadaten/
address=/heise.demediadatenheise-online/
address=/heise.demediadatenonline/
address=/hellobar.com/
address=/hentaicounter.com/
address=/herbalaffiliateprogram.com/
address=/hexcan.com/
address=/hexusads.fluent.ltd.uk/
address=/heyos.com/
address=/hfc195b.com/
address=/hgads.com/
address=/highfalutinroom.com/
address=/hightrafficads.com/
address=/hilariouszinc.com/
address=/hilltopads.net/
address=/histats.com/
address=/historicalrequest.com/
address=/hit.bg/
address=/hit.ua/
address=/hit.webcentre.lycos.co.uk/
address=/hitbox.com/
address=/hitcounters.miarroba.com/
address=/hitfarm.com/
address=/hitiz.com/
address=/hitlist.ru/
address=/hitlounge.com/
address=/hitometer.com/
address=/hit-parade.com/
address=/hits.europuls.eu/
address=/hits.informer.com/
address=/hits.puls.lv/
address=/hits.theguardian.com/
address=/hits4me.com/
address=/hits-i.iubenda.com/
address=/hitslink.com/
address=/hittail.com/
address=/hlok.qertewrt.com/
address=/hocgeese.com/
address=/hollps.win/
address=/homepageking.de/
address=/honeygoldfish.com/
address=/honorablehall.com/
address=/honorableland.com/
address=/hookupsonline.com/
address=/hostedads.realitykings.com/
address=/hotjar.com/
address=/hotkeys.com/
address=/hotlog.ru/
address=/hotrank.com.tw/
address=/hoverowl.com/
address=/hsadspixel.net/
address=/hs-analytics.net/
address=/hs-banner.com/
address=/hsrd.yahoo.com/
address=/htlbid.com/
address=/httpool.com/
address=/hubadnetwork.com/
address=/hueads.com/
address=/hueadsortb.com/
address=/hueadsxml.com/
address=/hurricanedigitalmedia.com/
address=/hurtteeth.com/
address=/hydramedia.com/
address=/hyperbanner.net/
address=/hypertracker.com/
address=/hyprmx.com/
address=/hystericalhelp.com/
address=/i1img.com/
address=/i1media.no/
address=/ia.iinfo.cz/
address=/iad.anm.co.uk/
address=/iadnet.com/
address=/iasds01.com/
address=/ibillboard.com/
address=/i-clicks.net/
address=/iconadserver.com/
address=/iconpeak2trk.com/
address=/icptrack.com/
address=/id5-sync.com/
address=/idealadvertising.net/
address=/identads.com/
address=/idevaffiliate.com/
address=/idtargeting.com/
address=/ientrymail.com/
address=/iesnare.com/
address=/ifa.tube8live.com/
address=/i-i.lt/
address=/ilbanner.com/
address=/ilead.itrack.it/
address=/illfatedsnail.com/
address=/illustriousoatmeal.com/
address=/imagecash.net/
address=/images-pw.secureserver.net/
address=/imarketservices.com/
address=/img.prohardver.hu/
address=/imgpromo.easyrencontre.com/
address=/imgs.chip.de/
address=/immensehoney.com/
address=/imonitor.nethost.cz/
address=/imonomy.com/
address=/importedincrease.com/
address=/impossibleexpansion.com/
address=/imprese.cz/
address=/impressionmedia.cz/
address=/impressionmonster.com/
address=/impressionz.co.uk/
address=/improvedigital.com/
address=/impulsehands.com/
address=/imrworldwide.com/
address=/inaccused.com/
address=/incentaclick.com/
address=/inclk.com/
address=/incognitosearches.com/
address=/incoming.telemetry.mozilla.org/
address=/indexexchange.com/
address=/indexstats.com/
address=/indexww.com/
address=/indieclick.com/
address=/industrybrains.com/
address=/inetlog.ru/
address=/infinite-ads.com/
address=/infinityads.com/
address=/infolinks.com/
address=/information.com/
address=/inmobi.com/
address=/inner-active.com/
address=/innocentwax.com/
address=/innovid.com/
address=/inquisitiveinvention.com/
address=/inringtone.com/
address=/insgly.net/
address=/insightexpress.com/
address=/insightexpressai.com/
address=/inskinad.com/
address=/inspectlet.com/
address=/install.365-stream.com/
address=/instantmadness.com/
address=/insticator.com/
address=/instinctiveads.com/
address=/instrumentsponge.com/
address=/intelliads.com/
address=/intelligent.com/
address=/intellitext.de/
address=/intellitxt.com/
address=/intellitxt.de/
address=/interactive.forthnet.gr/
address=/intergi.com/
address=/internetfuel.com/
address=/interreklame.de/
address=/intnotif.club/
address=/inventionpassenger.com/
address=/invitesugar.com/
address=/ioam.de/
address=/iomoio.com/
address=/ip.ro/
address=/ip193.cn/
address=/iperceptions.com/
address=/iporntv.com/
address=/iporntv.net/
address=/ipredictive.com/
address=/ipro.com/
address=/ipstack.com/
address=/iqm.de/
address=/irchan.com/
address=/ireklama.cz/
address=/is-tracking-pixel-api-prod.appspot.com/
address=/itfarm.com/
address=/itop.cz/
address=/itsptp.com/
address=/its-that-easy.com/
address=/ivwbox.de/
address=/ivw-online.de/
address=/ivykiosk.com/
address=/iyfnzgb.com/
address=/j93557g.com/
address=/jadeitite.com/
address=/jads.co/
address=/jaizouji.com/
address=/jauchuwa.net/
address=/jcount.com/
address=/jdoqocy.com/
address=/jinkads.de/
address=/jjhouse.com/
address=/joetec.net/
address=/js.users.51.la/
address=/js-agent.newrelic.com/
address=/jsecoin.com/
address=/jsrdn.com/
address=/juicyads.com/
address=/juicyads.me/
address=/jumptap.com/
address=/jungroup.com/
address=/justicejudo.com/
address=/justpremium.com/
address=/justrelevant.com/
address=/k.iinfo.cz/
address=/kameleoon.eu/
address=/kanoodle.com/
address=/kargo.com/
address=/karonty.com/
address=/keygen.us/
address=/keygenguru.com/
address=/keygens.pro/
address=/keymedia.hu/
address=/kindads.com/
address=/kinox.to/
address=/kissmetrics.com/
address=/klclick.com/
address=/klclick1.com/
address=/kleinanzaige.spiegel,de/
address=/kleinanzeige.bild,de/
address=/kleinanzeige.chip.de/
address=/kleinanzeige.focus.de/
address=/kleinanzeige.welt.de/
address=/kliks.nl/
address=/kliktrek.com/
address=/klsdee.com/
address=/kmpiframe.keepmeposted.com.mt/
address=/knorex.com/
address=/komoona.com/
address=/kompasads.com/
address=/kontera.com/
address=/kost.tv/
address=/kpu.samsungelectronics.com/
address=/krxd.net/
address=/kt5850pjz0.com/
address=/ktu.sv2.biz/
address=/ktxtr.com/
address=/kubient.com/
address=/l1.britannica.com/
address=/l6b587txj1.com/
address=/ladsreds.com/
address=/ladsup.com/
address=/lakequincy.com/
address=/lameletters.com/
address=/lanistaads.com/
address=/larati.net/
address=/laughablecopper.com/
address=/laughcloth.com/
address=/launchbit.com/
address=/layer-ad.de/
address=/layer-ads.de/
address=/lbn.ru/
address=/lead-analytics.nl/
address=/leadboltads.net/
address=/leadclick.com/
address=/leadingedgecash.com/
address=/leadplace.fr/
address=/leady.com/
address=/leadzupc.com/
address=/leaplunchroom.com/
address=/leedsads.com/
address=/lemmatechnologies.com/
address=/lettucelimit.com/
address=/levelrate.de/
address=/lfeeder.com/
address=/lfstmedia.com/
address=/li.alibris.com/
address=/li.azstarnet.com/
address=/li.dailycaller.com/
address=/li.gatehousemedia.com/
address=/li.gq.com/
address=/li.hearstmags.com/
address=/li.livingsocial.com/
address=/li.mw.drhinternet.net/
address=/li.onetravel.com/
address=/li.patheos.com/
address=/li.pmc.com/
address=/li.purch.com/
address=/li.realtor.com/
address=/li.walmart.com/
address=/li.ziffimages.com/
address=/liadm.com/
address=/lifeimpressions.net/
address=/liftdna.com/
address=/ligatus.com/
address=/ligatus.de/
address=/lightcast.leadscoringcenter.com/
address=/lightcushion.com/
address=/lightspeedcash.com/
address=/lijit.com/
address=/line.jzs001.cn/
address=/link4ads.com/
address=/linkadd.de/
address=/link-booster.de/
address=/linkbuddies.com/
address=/linkexchange.com/
address=/linkprice.com/
address=/linkrain.com/
address=/linkreferral.com/
address=/linkshighway.com/
address=/links-ranking.de/
address=/linkstorms.com/
address=/linkswaper.com/
address=/linktarget.com/
address=/liquidad.narrowcastmedia.com/
address=/litix.io/
address=/liveadexchanger.com/
address=/liveintent.com/
address=/liverail.com/
address=/lizardslaugh.com/
address=/lkqd.com/
address=/lnks.gd/
address=/loading321.com/
address=/locked4.com/
address=/lockerdome.com/
address=/log.btopenworld.com/
address=/log.logrocket.io/
address=/log.pinterest.com/
address=/log.videocampaign.co/
address=/logger.snackly.co/
address=/logs.roku.com/
address=/logs.spilgames.com/
address=/logsss.com/
address=/logua.com/
address=/longinglettuce.com/
address=/look.djfiln.com/
address=/look.ichlnk.com/
address=/look.opskln.com/
address=/look.udncoeln.com/
address=/look.ufinkln.com/
address=/loopme.com/
address=/lop.com/
address=/loudlunch.com/
address=/lp3tdqle.com/
address=/lucidmedia.com/
address=/lucklayed.info/
address=/lytics.io/
address=/lzjl.com/
address=/m.trb.com/
address=/m\\303\\266se/
address=/m\\303\\266se.com/
address=/m\\303\\266se.de/
address=/m1.webstats4u.com/
address=/m2.ai/
address=/m32.media/
address=/m4n.nl/
address=/m6r.eu/
address=/macerkopf.dego/
address=/mackeeperapp.mackeeper.com/
address=/madbid.com/
address=/madclient.uimserv.net/
address=/madcpms.com/
address=/madinad.com/
address=/madisonavenue.com/
address=/madvertise.de/
address=/magicadz.co/
address=/magnificentmist.com/
address=/mail-ads.google.com/
address=/mainstoreonline.com/
address=/malaysia-online-bank-kasino.com/
address=/manageadv.cblogs.eu/
address=/marchex.com/
address=/marinsm.com/
address=/markedcrayon.com/
address=/markedpail.com/
address=/market-buster.com/
address=/marketing.888.com/
address=/marketing.hearstmagazines.nl/
address=/marketing.net.brillen.de/
address=/marketing.net.home24.de/
address=/marketing.nyi.net/
address=/marketing.osijek031.com/
address=/marketingsolutions.yahoo.com/
address=/marketo.com/
address=/mas.sector.sk/
address=/massivemark.com/
address=/matchcraft.com/
address=/materialmoon.com/
address=/matheranalytics.com/
address=/mathtag.com/
address=/matomo.activate.cz/
address=/matomo.hdweb.ru/
address=/matomo.kmkb.ru/
address=/mautic.com/
address=/max.i12.de/
address=/maximiser.net/
address=/maximumcash.com/
address=/maxonclick.com/
address=/mbs.megaroticlive.com/
address=/mcdlks.com/
address=/me/
address=/measure.office.com/
address=/measuremap.com/
address=/media.funpic.de/
address=/media.net/
address=/media01.eu/
address=/media6degrees.com/
address=/media-adrunner.mycomputer.com/
address=/mediaarea.eu/
address=/mediabridge.cc/
address=/mediacharger.com/
address=/mediageneral.com/
address=/mediaiqdigital.com/
address=/mediamath.com/
address=/mediamgr.ugo.com/
address=/mediaplazza.com/
address=/mediaplex.com/
address=/mediascale.de/
address=/mediaserver.bwinpartypartners.it/
address=/media-servers.net/
address=/mediasmart.io/
address=/mediatext.com/
address=/mediavine.com/
address=/mediavoice.com/
address=/mediax.angloinfo.com/
address=/mediaz.angloinfo.com/
address=/medleyads.com/
address=/medyanetads.com/
address=/meetrics.net/
address=/megacash.de/
address=/mega-einkaufsquellen.de/
address=/megapu.sh/
address=/megastats.com/
address=/megawerbung.de/
address=/mellowads.com/
address=/memorizeneck.com/
address=/memorycobweb.com/
address=/messagenovice.com/
address=/metadsp.co.uk/
address=/metaffiliation.com/
address=/metanetwork.com/
address=/methodcash.com/
address=/metrics.api.drift.com/
address=/metrics.cnn.com/
address=/metrics.consumerreports.org/
address=/metrics.ctv.ca/
address=/metrics.foxnews.com/
address=/metrics.getrockerbox.com/
address=/metrics.gfycat.com/
address=/metrics.govexec.com/
address=/metrics-logger.spot.im/
address=/metrilo.com/
address=/mfadsrvr.com/
address=/mg2connext.com/
address=/mgid.com/
address=/microstatic.pl/
address=/microticker.com/
address=/militaryverse.com/
address=/milotree.com/
address=/minewhat.com/
address=/minormeeting.com/
address=/mintegral.com/
address=/mixedreading.com/
address=/mixpanel.com/
address=/mkto-ab410147.com/
address=/mktoresp.com/
address=/ml314.com/
address=/mlm.de/
address=/mltrk.io/
address=/mmismm.com/
address=/mmstat.com/
address=/mmtro.com/
address=/moartraffic.com/
address=/moat.com/
address=/moatads.com/
address=/moatpixel.com/
address=/mobclix.com/
address=/mobfox.com/
address=/mobileanalytics.us-east-1.amazonaws.com/
address=/mobilefuse.com/
address=/mobileiconnect.com/
address=/mobperads.net/
address=/modernpricing.com/
address=/modifyeyes.com/
address=/moldyicicle.com/
address=/mon.byteoversea.com/
address=/monarchads.com/
address=/monetate.net/
address=/monetizer101.com/
address=/moneyexpert.co.uk/
address=/monsterpops.com/
address=/mookie1.com/
address=/mopub.com/
address=/motionspots.com/
address=/mouseflow.com/
address=/mousestats.com/
address=/movad.net/
address=/movie4k.to/
address=/mowfruit.com/
address=/mp3fiesta.com/
address=/mp3sugar.com/
address=/mp3va.com/
address=/mparticle.com/
address=/mpstat.us/
address=/mr-rank.de/
address=/mrskincash.com/
address=/msads.net/
address=/mstrlytcs.com/
address=/mtrcs.samba.tv/
address=/mtree.com/
address=/munchkin.marketo.net/
address=/musiccounter.ru/
address=/musicmp3.ru/
address=/muwmedia.com/
address=/mxptint.net/
address=/myads.company/
address=/myads.net/
address=/myads.telkomsel.com/
address=/myaffiliateprogram.com/
address=/mybestmv.com/
address=/mybetterdl.com/
address=/mybloglog.com/
address=/mybuys.com/
address=/mycounter.ua/
address=/mydas.mobi/
address=/mylink-today.com/
address=/mymoneymakingapp.com/
address=/mypagerank.net/
address=/mypagerank.ru/
address=/mypass.de/
address=/mypowermall.com/
address=/mysafeads.com/
address=/mystat.pl/
address=/mystat-in.net/
address=/mysteriousmonth.com/
address=/mytop-in.net/
address=/myvisualiq.net/
address=/n69.com/
address=/na.ads.yahoo.com/
address=/naj.sk/
address=/naradxb.com/
address=/nastydollars.com/
address=/nativeroll.tv/
address=/naturalbid.com/
address=/navegg.com/
address=/navigator.io/
address=/navrcholu.cz/
address=/nbjmp.com/
address=/ncaudienceexchange.com/
address=/ndparking.com/
address=/nedstatbasic.net/
address=/neighborlywatch.com/
address=/nend.net/
address=/neocounter.neoworx-blog-tools.net/
address=/nervoussummer.com/
address=/netaffiliation.com/
address=/netagent.cz/
address=/netclickstats.com/
address=/netcommunities.com/
address=/netdirect.nl/
address=/net-filter.com/
address=/netincap.com/
address=/netmng.com/
address=/netpool.netbookia.net/
address=/netshelter.net/
address=/networkadvertising.org/
address=/neudesicmediagroup.com/
address=/newads.bangbros.com/
address=/newbie.com/
address=/newnet.qsrch.com/
address=/newnudecash.com/
address=/newopenx.detik.com/
address=/newsadsppush.com/
address=/newsletter-link.com/
address=/newstarads.com/
address=/newt1.adultadworld.com/
address=/newt1.adultworld.com/
address=/nexac.com/
address=/nexage.com/
address=/ng3.ads.warnerbros.com/
address=/nhpfvdlbjg.com/
address=/nitratory.com/
address=/nitroclicks.com/
address=/noiselessplough.com/
address=/nondescriptcrowd.com/
address=/nondescriptsmile.com/
address=/nondescriptstocking.com/
address=/novem.pl/
address=/npttech.com/
address=/nr-data.net/
address=/ns1p.net/
address=/ntv.io/
address=/ntvk1.ru/
address=/nuggad.net/
address=/nuseek.com/
address=/nuttyorganization.com/
address=/nzaza.com/
address=/o0bc.com/
address=/o333o.com/
address=/oafishobservation.com/
address=/oas.benchmark.fr/
address=/oas.repubblica.it/
address=/oas.roanoke.com/
address=/oas.toronto.com/
address=/oas.uniontrib.com/
address=/oas.villagevoice.com/
address=/oascentral.chicagobusiness.com/
address=/oascentral.fortunecity.com/
address=/oascentral.register.com/
address=/obscenesidewalk.com/
address=/observantice.com/
address=/oclasrv.com/
address=/odbierz-bony.ovp.pl/
address=/oewa.at/
address=/offaces-butional.com/
address=/offer.fyber.com/
address=/offer.sponsorpay.com/
address=/offerforge.com/
address=/offermatica.com/
address=/offerzone.click/
address=/oglasi.posjetnica.com/
address=/ogury.com/
address=/oingo.com/
address=/omnijay.com/
address=/omniscientspark.com/
address=/omniture.com/
address=/omtrdc.net/
address=/onaudience.com/
address=/onclasrv.com/
address=/onclickads.net/
address=/oneandonlynetwork.com/
address=/onenetworkdirect.com/
address=/onestat.com/
address=/onestatfree.com/
address=/online.miarroba.com/
address=/onlinecash.com/
address=/onlinefilme.tv/
address=/online-metrix.net/
address=/onlinerewardcenter.com/
address=/online-tests.de/
address=/onlineticketexpress.com/
address=/onscroll.com/
address=/onthe.io/
address=/opads.us/
address=/open.oneplus.net/
address=/openad.tf1.fr/
address=/openad.travelnow.com/
address=/openads.friendfinder.com/
address=/openads.org/
address=/openadsnetwork.com/
address=/opentag-stats.qubit.com/
address=/openx.actvtech.com/
address=/openx.angelsgroup.org.uk/
address=/openx.cairo360.com/
address=/openx.kgmedia.eu/
address=/openx.net/
address=/openx.skinet.cz/
address=/openx.smcaen.fr/
address=/openx2.kytary.cz/
address=/operationkettle.com/
address=/opienetwork.com/
address=/opmnstr.com/
address=/optimallimit.com/
address=/optimizely.com/
address=/optimize-stats.voxmedia.com/
address=/optimost.com/
address=/optmd.com/
address=/optmnstr.com/
address=/optmstr.com/
address=/optnmstr.com/
address=/ota.cartrawler.com/
address=/otto-images.developershed.com/
address=/ouh3igaeb.com/
address=/outbrain.com/
address=/overconfidentfood.com/
address=/overture.com/
address=/owebanalytics.com/
address=/owebmoney.ru/
address=/owlsr.us/
address=/owneriq.net/
address=/ox1.shopcool.com.tw/
address=/oxado.com/
address=/oxcash.com/
address=/oxen.hillcountrytexas.com/
address=/p.nag.ru/
address=/p2r14.com/
address=/padsbrown.com/
address=/padssup.com/
address=/pagead.l.google.com/
address=/pagefair.com/
address=/pagefair.net/
address=/pagerank4you.com/
address=/pagerank-ranking.de/
address=/pageranktop.com/
address=/paleleaf.com/
address=/panickycurtain.com/
address=/paradoxfactor.com/
address=/parchedangle.com/
address=/parketsy.pro/
address=/parsely.com/
address=/parsimoniouspolice.com/
address=/partner.pelikan.cz/
address=/partnerad.l.google.com/
address=/partner-ads.com/
address=/partnerads.ysm.yahoo.com/
address=/partnercash.de/
address=/partnernet.amazon.de/
address=/partners.priceline.com/
address=/partners.webmasterplan.com/
address=/passeura.com/
address=/passion-4.net/
address=/paycounter.com/
address=/paypopup.com/
address=/pbnet.ru/
address=/pbterra.com/
address=/pcash.imlive.com/
address=/pctracking.net/
address=/peep-auktion.de/
address=/peer39.com/
address=/pennyweb.com/
address=/pepperjamnetwork.com/
address=/perceivequarter.com/
address=/percentmobile.com/
address=/perfectaudience.com/
address=/perfiliate.com/
address=/performancerevenue.com/
address=/performancerevenues.com/
address=/performancing.com/
address=/permutive.com/
address=/personagraph.com/
address=/petiteumbrella.com/
address=/pgl.example.com/
address=/pgl.example0101/
address=/pgmediaserve.com/
address=/pgpartner.com/
address=/pheedo.com/
address=/phoenix-adrunner.mycomputer.com/
address=/photographpan.com/
address=/phpadsnew.new.natuurpark.nl/
address=/pi.pardot.com/
address=/piano.io/
address=/picadmedia.com/
address=/piet2eix3l.com/
address=/pietexture.com/
address=/pilotaffiliate.com/
address=/pimproll.com/
address=/ping.ublock.org/
address=/pipedream.wistia.com/
address=/pippio.com/
address=/piquantpigs.com/
address=/pix.spot.im/
address=/pixel.adsafeprotected.com/
address=/pixel.bild.de/
address=/pixel.condenastdigital.com/
address=/pixel.digitru.st/
address=/pixel.keywee.co/
address=/pixel.mathtag.com/
address=/pixel.mtrcs.samba.tv/
address=/pixel.sojern.com/
address=/pixel.watch/
address=/pixel.yabidos.com/
address=/pl/
address=/placed.com/
address=/play4traffic.com/
address=/playhaven.com/
address=/pleasantpump.com/
address=/plista.com/
address=/plotrabbit.com/
address=/plugrush.com/
address=/p-n.io/
address=/pocketmath.com/
address=/podtraff.com/
address=/podtraft.com/
address=/pointroll.com/
address=/pokkt.com/
address=/popads.net/
address=/popcash.net/
address=/popmyads.com/
address=/popub.com/
address=/popunder.ru/
address=/popup.msn.com/
address=/popup.taboola.com/
address=/popupmoney.com/
address=/popupnation.com/
address=/popups.infostart.com/
address=/popuptraffic.com/
address=/porngraph.com/
address=/porntrack.com/
address=/possessivebucket.com/
address=/possibleboats.com/
address=/post.spmailtechno.com/
address=/postback.iqm.com/
address=/postrelease.com/
address=/praddpro.de/
address=/prchecker.info/
address=/prebid.org/
address=/predictad.com/
address=/premium-offers.com/
address=/presetrabbits.com/
address=/previousplayground.com/
address=/previouspotato.com/
address=/primetime.net/
address=/privatecash.com/
address=/prmtracking.com/
address=/pro-advertising.com/
address=/prodtraff.com/
address=/producecopy.com/
address=/producer.getwisdom.io/
address=/proext.com/
address=/profero.com/
address=/profi-kochrezepte.de/
address=/profitrumour.com/
address=/profiwin.de/
address=/programattik.com/
address=/projectwonderful.com/
address=/pro-market.net/
address=/promo.badoink.com/
address=/promo.ulust.com/
address=/promobenef.com/
address=/promos.bwin.it/
address=/promos.fling.com/
address=/promote.pair.com/
address=/promotions-884485.c.cdn77.org/
address=/pronetadvertising.com/
address=/proof-x.com/
address=/propellerads.com/
address=/propellerclick.com/
address=/proper.io/
address=/props.id/
address=/prosper.on-line-casino.ca/
address=/protectcrev.com/
address=/protectsubrev.com/
address=/proton-tm.com/
address=/protraffic.com/
address=/provexia.com/
address=/prsaln.com/
address=/prsitecheck.com/
address=/pr-star.de/
address=/ps7894.com/
address=/pstmrk.it/
address=/ptoushoa.com/
address=/pub.chez.com/
address=/pub.club-internet.fr/
address=/pub.hardware.fr/
address=/pub.network/
address=/pub.realmedia.fr/
address=/pubdirecte.com/
address=/publicidad.elmundo.es/
address=/publicidees.com/
address=/pubmatic.com/
address=/pubmine.com/
address=/pubnative.net/
address=/puffyloss.com/
address=/puffypaste.com/
address=/puffypull.com/
address=/puffypurpose.com/
address=/pushame.com/
address=/pushance.com/
address=/pushazer.com/
address=/pushengage.com/
address=/pushno.com/
address=/pushtrack.co/
address=/pushwhy.com/
address=/px.ads.linkedin.com/
address=/px.dynamicyield.com/
address=/px.gfycat.com/
address=/px.spiceworks.com/
address=/pxl.iqm.com/
address=/pymx5.com/
address=/q.azcentral.com/
address=/q1connect.com/
address=/qcontentdelivery.info/
address=/qctop.com/
address=/qnsr.com/
address=/qservz.com/
address=/quacksquirrel.com/
address=/quaintcan.com/
address=/quantcast.com/
address=/quantcount.com/
address=/quantserve.com/
address=/quantummetric.com/
address=/quarterbean.com/
address=/quarterserver.de/
address=/questaffiliates.net/
address=/quibids.com/
address=/quicksandear.com/
address=/quietknowledge.com/
address=/quinst.com/
address=/quisma.com/
address=/quizzicalzephyr.com/
address=/r.logrocket.io/
address=/r.msn.com/
address=/r.scoota.co/
address=/radar.cedexis.com/
address=/radarurl.com/
address=/radiate.com/
address=/rads.alfamedia.pl/
address=/rads.realadmin.pl/
address=/railwayrainstorm.com/
address=/railwayreason.com/
address=/rampidads.com/
address=/rankchamp.de/
address=/rankingchart.de/
address=/ranking-charts.de/
address=/ranking-hits.de/
address=/ranking-links.de/
address=/ranking-liste.de/
address=/rankingscout.com/
address=/rank-master.com/
address=/rankyou.com/
address=/rapidape.com/
address=/rapidcounter.com/
address=/rapidkittens.com/
address=/raresummer.com/
address=/rate.ru/
address=/ratings.lycos.com/
address=/rayjump.com/
address=/reachjunction.com/
address=/reactx.com/
address=/readgoldfish.com/
address=/readingguilt.com/
address=/readingopera.com/
address=/readserver.net/
address=/readymoon.com/
address=/realcastmedia.com/
address=/realclever.com/
address=/realclix.com/
address=/realmedia-a800.d4p.net/
address=/realsrv.com/
address=/realtechnetwork.com/
address=/realtracker.com/
address=/rebelsubway.com/
address=/receptiveink.com/
address=/receptivereaction.com/
address=/recoco.it/
address=/record.affiliates.karjalakasino.com/
address=/record.bonniergaming.com/
address=/record.mrwin.com/
address=/redirectingat.com/
address=/re-directme.com/
address=/redirectvoluum.com/
address=/redshell.io/
address=/reduxmedia.com/
address=/referralware.com/
address=/referrer.disqus.com/
address=/reflectivereward.com/
address=/reforge.in/
address=/regnow.com/
address=/regularplants.com/
address=/reklam.rfsl.se/
address=/reklama.mironet.cz/
address=/reklama.reflektor.cz/
address=/reklamcsere.hu/
address=/reklamdsp.com/
address=/reklame.unwired-i.net/
address=/relevanz10.de/
address=/relmaxtop.com/
address=/remistrainew.club/
address=/remox.com/
address=/republika.onet.pl/
address=/research.de.com/
address=/resolutekey.com/
address=/resonantbrush.com/
address=/resonate.com/
address=/responsiveads.com/
address=/retargeter.com/
address=/revcatch.com/
address=/revcontent.com/
address=/reveal.clearbit.com/
address=/revenue.net/
address=/revenuedirect.com/
address=/revenuehits.com/
address=/revive.docmatic.org/
address=/revive.dubcnm.com/
address=/revive.haskovo.net/
address=/revive.netriota.hu/
address=/revive.plays.bg/
address=/revlift.io/
address=/revprotect.com/
address=/revsci.net/
address=/revstats.com/
address=/reyden-x.com/
address=/rhombusads.com/
address=/rhythmone.com/
address=/richmails.com/
address=/richmedia.yimg.com/
address=/richstring.com/
address=/richwebmaster.com/
address=/rightstats.com/
address=/rinconpx.net/
address=/ringsrecord.com/
address=/ritzykey.com/
address=/rlcdn.com/
address=/rle.ru/
address=/rmads.msn.com/
address=/rmedia.boston.com/
address=/rmgserving.com/
address=/ro/
address=/roar.com/
address=/robotreplay.com/
address=/rockabox.co/
address=/roia.biz/
address=/rok.com.com/
address=/roq.ad/
address=/rose.ixbt.com/
address=/rotabanner.com/
address=/rotten.com/
address=/rotten.de/
address=/roughroll.com/
address=/roxr.net/
address=/royalgames.com/
address=/rs/
address=/rs6.net/
address=/rta.dailymail.co.uk/
address=/rtb.gumgum.com/
address=/rtbadzesto.com/
address=/rtbflairads.com/
address=/rtbidhost.com/
address=/rtbplatform.net/
address=/rtbpop.com/
address=/rtbpopd.com/
address=/rtbsbengine.com/
address=/rtbtradein.com/
address=/rtmark.net/
address=/rtpdn11.com/
address=/rtxplatform.com/
address=/ru/
address=/ru4.com/
address=/rubiconproject.com/
address=/rum-http-intake.logs.datadoghq.com/
address=/rum-http-intake.logs.datadoghq.eu/
address=/runads.com/
address=/rundsp.com/
address=/ruthlessrobin.com/
address=/s.adroll.com/
address=/s1-adfly.com/
address=/s20dh7e9dh.com/
address=/s24hc8xzag.com/
address=/s2d6.com/
address=/sa.api.intl.miui.com/
address=/sabio.us/
address=/sageanalyst.net/
address=/sail-horizon.com/
address=/samsungacr.com/
address=/samsungads.com/
address=/saysidewalk.com/
address=/sbx.pagesjaunes.fr/
address=/scambiobanner.aruba.it/
address=/sc-analytics.appspot.com/
address=/scanscout.com/
address=/scarcesign.com/
address=/scatteredheat.com/
address=/scintillatingscissors.com/
address=/scintillatingspace.com/
address=/scoobyads.com/
address=/scopelight.com/
address=/scorecardresearch.com/
address=/scratch2cash.com/
address=/screechingfurniture.com/
address=/script.ioam.de/
address=/scripte-monster.de/
address=/scrubswim.com/
address=/sdkfjxjertertry.com/
address=/seadform.net/
address=/searching-place.com/
address=/searchmarketing.com/
address=/searchramp.com/
address=/secretivecub.com/
address=/secretspiders.com/
address=/secure.webconnect.net/
address=/securedopen-bp.com/
address=/securemetrics.apple.com/
address=/sedoparking.com/
address=/sedotracker.com/
address=/segmetrics.io/
address=/selectivesummer.com/
address=/semasio.net/
address=/sendmepixel.com/
address=/sensismediasmart.com.au/
address=/separatesilver.com/
address=/serials.ws/
address=/serienjunkies.org/
address=/serienstream.to/
address=/serv0.com/
address=/servads.net/
address=/servadsdisrupt.com/
address=/servedbyadbutler.com/
address=/servedby-buysellads.com/
address=/servedbyopenx.com/
address=/servethis.com/
address=/service.urchin.com/
address=/services.hearstmags.com/
address=/servingmillions.com/
address=/serving-sys.com/
address=/sessioncam.com/
address=/sexcounter.com/
address=/sexinyourcity.com/
address=/sexlist.com/
address=/sextracker.com/
address=/shakesea.com/
address=/shakesuggestion.com/
address=/shakytaste.com/
address=/shallowsmile.com/
address=/shareadspace.com/
address=/shareasale.com/
address=/sharethrough.com/
address=/sharppatch.com/
address=/sher.index.hu/
address=/shermore.info/
address=/shinystat.com/
address=/shinystat.it/
address=/shockinggrass.com/
address=/shooshtime.com/
address=/shoppingads.com/
address=/sicksmash.com/
address=/sidebar.angelfire.com/
address=/silkysquirrel.com/
address=/sillyscrew.com/
address=/silvalliant.info/
address=/silvermob.com/
address=/simpleanalytics.io/
address=/simplehitcounter.com/
address=/simpli.fi/
address=/sincerebuffalo.com/
address=/sinoa.com/
address=/sitedataprocessing.com/
address=/siteimproveanalytics.com/
address=/siteimproveanalytics.io/
address=/siteintercept.qualtrics.com/
address=/sitemeter.com/
address=/sixscissors.com/
address=/sixsigmatraffic.com/
address=/sizesidewalk.com/
address=/sizmek.com/
address=/skimresources.com/
address=/skylink.vn/
address=/sleepcartoon.com/
address=/slipperysack.com/
address=/slopeaota.com/
address=/smaato.com/
address=/smallbeginner.com/
address=/smart4ads.com/
address=/smartadserver.com/
address=/smartadserver.de/
address=/smartadserver.net/
address=/smartclip.net/
address=/smartlook.com/
address=/smartstream.tv/
address=/smart-traffik.com/
address=/smart-traffik.io/
address=/smartyads.com/
address=/smashsurprise.com/
address=/smetrics.10daily.com.au/
address=/smetrics.bestbuy.com/
address=/smetrics.ctv.ca/
address=/smetrics.foxnews.com/
address=/smetrics.walgreens.com/
address=/smetrics.washingtonpost.com/
address=/smilingwaves.com/
address=/smokerland.net/
address=/smrtb.com/
address=/snapads.com/
address=/sneakystamp.com/
address=/snoobi.com/
address=/socialspark.com/
address=/softclick.com.br/
address=/sombersea.com/
address=/sombersquirrel.com/
address=/sombersurprise.com/
address=/somniture.stuff.co.nz/
address=/somoaudience.com/
address=/sonobi.com/
address=/sortable.com/
address=/sourcepoint.vice.com/
address=/sovrn.com/
address=/spacash.com/
address=/spaceleadster.com/
address=/sparkstudios.com/
address=/specially4u.net/
address=/specificmedia.co.uk/
address=/specificpop.com/
address=/speedomizer.com/
address=/speedshiftmedia.com/
address=/spezialreporte.de/
address=/spidersboats.com/
address=/spiegel.deimages/
address=/spiffymachine.com/
address=/spinbox.techtracker.com/
address=/spinbox.versiontracker.com/
address=/spirebaboon.com/
address=/sponsorads.de/
address=/sponsorpro.de/
address=/sponsors.thoughtsmedia.com/
address=/sportsad.net/
address=/spot.fitness.com/
address=/spotscenered.info/
address=/spotx.tv/
address=/spotxchange.com/
address=/springaftermath.com/
address=/springserve.com/
address=/spulse.net/
address=/spurioussteam.com/
address=/spykemediatrack.com/
address=/spylog.com/
address=/spywarelabs.com/
address=/spywords.com/
address=/squirrelhands.com/
address=/srvmath.com/
address=/srvtrck.com/
address=/srwww1.com/
address=/st.dynamicyield.com/
address=/stackadapt.com/
address=/stack-sonar.com/
address=/stakingscrew.com/
address=/stakingslope.com/
address=/stalesummer.com/
address=/standingnest.com/
address=/starffa.com/
address=/start.freeze.com/
address=/startapp.com/
address=/stat.cliche.se/
address=/stat.dyna.ultraweb.hu/
address=/stat.pl/
address=/stat.webmedia.pl/
address=/stat.xiaomi.com/
address=/stat.zenon.net/
address=/stat24.com/
address=/stat24.meta.ua/
address=/statcounter.com/
address=/statdynamic.com/
address=/static.a-ads.com/
address=/static.fmpub.net/
address=/static.itrack.it/
address=/static.kameleoon.com/
address=/staticads.btopenworld.com/
address=/statistik-gallup.net/
address=/statm.the-adult-company.com/
address=/stats.blogger.com/
address=/stats.hyperinzerce.cz/
address=/stats.merriam-webster.com/
address=/stats.mirrorfootball.co.uk/
address=/stats.nextgen-email.com/
address=/stats.olark.com/
address=/stats.pusher.com/
address=/stats.rdphv.net/
address=/stats.self.com/
address=/stats.townnews.com/
address=/stats.unwired-i.net/
address=/stats.wordpress.com/
address=/stats.wp.com/
address=/stats.x14.eu/
address=/stats2.self.com/
address=/stats4all.com/
address=/statserv.net/
address=/statsie.com/
address=/stat-track.com/
address=/statxpress.com/
address=/steadfastsound.com/
address=/steadfastsystem.com/
address=/steelhouse.com/
address=/steelhousemedia.com/
address=/stepplane.com/
address=/stickssheep.com/
address=/stickyadstv.com/
address=/stiffgame.com/
address=/storesurprise.com/
address=/storetail.io/
address=/stormyachiever.com/
address=/storygize.net/
address=/stoveseashore.com/
address=/straightnest.com/
address=/stream.useriq.com/
address=/stripedburst.com/
address=/strivesidewalk.com/
address=/structurerod.com/
address=/stupendoussleet.com/
address=/su/
address=/subscribe.hearstmags.com/
address=/succeedscene.com/
address=/suddensidewalk.com/
address=/sudoku.de/
address=/sugarcurtain.com/
address=/sugoicounter.com/
address=/sulkybutter.com/
address=/summerhamster.com/
address=/summerobject.com/
address=/sumo.com/
address=/sumome.com/
address=/superclix.de/
address=/superficialsquare.com/
address=/supersonicads.com/
address=/superstats.com/
address=/supertop.ru/
address=/supertop100.com/
address=/supertracking.net/
address=/supply.colossusssp.com/
address=/surfmusik-adserver.de/
address=/surveygizmobeacon.s3.amazonaws.com/
address=/sw88.espn.com/
address=/swan-swan-goose.com/
address=/swimslope.com/
address=/swoggi.de/
address=/swordfishdc.com/
address=/swordgoose.com/
address=/systemcdn.net/
address=/t.bawafx.com/
address=/t.eloqua.com/
address=/t.firstpromoter.com/
address=/t.insigit.com/
address=/t.irtyd.com/
address=/t.ktxtr.com/
address=/taboola.com/
address=/tag.links-analytics.com/
address=/tagan.adlightning.com/
address=/tagcommander.com/
address=/tagger.opecloud.com/
address=/tags.tiqcdn.com/
address=/tagular.com/
address=/tailsweep.com/
address=/tailsweep.se/
address=/takethatad.com/
address=/takru.com/
address=/talentedsteel.com/
address=/tamgrt.com/
address=/tangerinenet.biz/
address=/tangibleteam.com/
address=/tapad.com/
address=/tapfiliate.com/
address=/tapinfluence.com/
address=/tapjoy.com/
address=/tappx.com/
address=/targad.de/
address=/target.microsoft.com/
address=/targeting.api.drift.com/
address=/targeting.nzme.arcpublishing.com/
address=/targeting.voxus.tv/
address=/targetingnow.com/
address=/targetnet.com/
address=/targetpoint.com/
address=/tastefulsongs.com/
address=/tatsumi-sys.jp/
address=/tawdryson.com/
address=/tcads.net/
address=/teads.tv/
address=/tealeaf.com/
address=/tealium.cbsnews.com/
address=/tealium.com/
address=/tealiumiq.com/
address=/techclicks.net/
address=/tedioustooth.com/
address=/teenrevenue.com/
address=/teenyvolcano.com/
address=/teethfan.com/
address=/telaria.com/
address=/telemetry.dropbox.com/
address=/telemetry.v.dropbox.com/
address=/temelio.com/
address=/tendertest.com/
address=/tercept.com/
address=/terriblethumb.com/
address=/textad.sexsearch.com/
address=/textads.biz/
address=/text-link-ads.com/
address=/textlinks.com/
address=/tfag.de/
address=/theadex.com/
address=/theadhost.com/
address=/thebugs.ws/
address=/theclickads.com/
address=/themoneytizer.com/
address=/the-ozone-project.com/
address=/therapistla.com/
address=/thinkablerice.com/
address=/thirdrespect.com/
address=/thirstytwig.com/
address=/thomastorch.com/
address=/threechurch.com/
address=/throattrees.com/
address=/throtle.io/
address=/thruport.com/
address=/ti.domainforlite.com/
address=/tia.timeinc.net/
address=/ticketaunt.com/
address=/ticklesign.com/
address=/ticksel.com/
address=/tidaltv.com/
address=/tidint.pro/
address=/tinybar.com/
address=/tkbo.com/
address=/tls.telemetry.swe.quicinc.com/
address=/tlvmedia.com/
address=/tnkexchange.com/
address=/tns-counter.ru/
address=/tntclix.co.uk/
address=/toecircle.com/
address=/toothbrushnote.com/
address=/top.list.ru/
address=/top.mail.ru/
address=/top.proext.com/
address=/top100.mafia.ru/
address=/top100-images.rambler.ru/
address=/top123.ro/
address=/top20free.com/
address=/top90.ro/
address=/topbucks.com/
address=/top-casting-termine.de/
address=/topforall.com/
address=/topgamesites.net/
address=/toplist.cz/
address=/toplist.pornhost.com/
address=/toplista.mw.hu/
address=/toplistcity.com/
address=/topping.com.ua/
address=/toprebates.com/
address=/topsir.com/
address=/topsite.lv/
address=/top-site-list.com/
address=/topsites.com.br/
address=/topstats.com/
address=/totemcash.com/
address=/touchclarity.com/
address=/touchclarity.natwest.com/
address=/tour.brazzers.com/
address=/track.addevent.com/
address=/track.adform.net/
address=/track.anchorfree.com/
address=/track.contently.com/
address=/track.effiliation.com/
address=/track.flexlinks.com/
address=/track.flexlinkspro.com/
address=/track.freemmo2017.com/
address=/track.game18click.com/
address=/track.gawker.com/
address=/track.hexcan.com/
address=/track.mailerlite.com/
address=/track.nuxues.com/
address=/track.themaccleanup.info/
address=/track.tkbo.com/
address=/track.ultravpn.com/
address=/track.undressingpics.work/
address=/track.unear.net/
address=/track.vcdc.com/
address=/track.viewdeos.com/
address=/track1.viewdeos.com/
address=/trackalyzer.com/
address=/trackedlink.net/
address=/trackedweb.net/
address=/tracker.bannerflow.com/
address=/tracker.cdnbye.com/
address=/tracker.comunidadmarriott.com/
address=/tracker.icerocket.com/
address=/tracker.mmdlv.it/
address=/tracker.samplicio.us/
address=/tracker.vgame.us/
address=/tracker-pm2.spilleren.com/
address=/tracking.1-a1502-bi.co.uk/
address=/tracking.1-kv015-ap.co.uk/
address=/tracking.21-a4652-bi.co.uk/
address=/tracking.39-bb4a9-osm.co.uk/
address=/tracking.42-01pr5-osm-secure.co.uk/
address=/tracking.5-47737-bi.co.uk/
address=/tracking.epicgames.com/
address=/tracking.gajmp.com/
address=/tracking.hyros.com/
address=/tracking.ibxlink.com/
address=/tracking.internetstores.de/
address=/tracking.intl.miui.com/
address=/tracking.jiffyworld.com/
address=/tracking.lenddom.com/
address=/tracking.markethero.io/
address=/tracking.miui.com/
address=/tracking.olx-st.com/
address=/tracking.orixa-media.com/
address=/tracking.publicidees.com/
address=/tracking.thinkabt.com/
address=/tracking01.walmart.com/
address=/tracking101.com/
address=/tracking22.com/
address=/trackingfestival.com/
address=/trackingsoft.com/
address=/tracklink-tel.de/
address=/trackmysales.com/
address=/trackuhub.com/
address=/tradeadexchange.com/
address=/tradedoubler.com/
address=/trading-rtbg.com/
address=/traffic.focuusing.com/
address=/traffic-exchange.com/
address=/trafficfactory.biz/
address=/trafficforce.com/
address=/trafficholder.com/
address=/traffichunt.com/
address=/trafficjunky.net/
address=/trafficleader.com/
address=/traffic-redirecting.com/
address=/trafficreps.com/
address=/trafficrouter.io/
address=/trafficshop.com/
address=/trafficspaces.net/
address=/trafficstrategies.com/
address=/trafficswarm.com/
address=/traffictrader.net/
address=/trafficz.com/
address=/traffiq.com/
address=/trafic.ro/
address=/traktrafficflow.com/
address=/tranquilside.com/
address=/travis.bosscasinos.com/
address=/trck.a8.net/
address=/trcking4wdm.de/
address=/trcklion.com/
address=/treasuredata.com/
address=/trekdata.com/
address=/tremendoustime.com/
address=/tremorhub.com/
address=/trendcounter.com/
address=/trendmd.com/
address=/tribalfusion.com/
address=/trickycelery.com/
address=/triplelift.com/
address=/triptease.io/
address=/trix.net/
address=/trk.bee-data.com/
address=/trk.techtarget.com/
address=/trk42.net/
address=/trkn.us/
address=/trknths.com/
address=/trmit.com/
address=/truckstomatoes.com/
address=/truehits.net/
address=/truehits1.gits.net.th/
address=/truehits2.gits.net.th/
address=/trust.titanhq.com/
address=/truste/
address=/trusted.de/
address=/trustx.org/
address=/tsyndicate.com/
address=/tsyndicate.net/
address=/tubelibre.com/
address=/tubemogul.com/
address=/tubepatrol.net/
address=/tubesafari.com/
address=/turboadv.com/
address=/turn.com/
address=/tvmtracker.com/
address=/twiago.com/
address=/twittad.com/
address=/twyn.com/
address=/tynt.com/
address=/typicalteeth.com/
address=/tyroo.com/
address=/uarating.com/
address=/ucfunnel.com/
address=/udkcrj.com/
address=/udncoeln.com/
address=/uib.ff.avast.com/
address=/ukbanners.com/
address=/ultimateclixx.com/
address=/ultramercial.com/
address=/ultraoranges.com/
address=/unarmedindustry.com/
address=/undertone.com/
address=/unister-adserver.de/
address=/unknowntray.com/
address=/unless.com/
address=/unrulymedia.com/
address=/untd.com/
address=/untidyquestion.com/
address=/unup4y/
address=/unusualtitle.com/
address=/unwieldyhealth.com/
address=/unwrittenspot.com/
address=/upu.samsungelectronics.com/
address=/urbandictionary.com/
address=/urchin.com/
address=/urlcash.net/
address=/urldata.net/
address=/us.a1.yimg.com/
address=/userreplay.com/
address=/userreplay.net/
address=/utils.mediageneral.net/
address=/utl-1.com/
address=/uttermosthobbies.com/
address=/uu.domainforlite.com/
address=/uzk4umokyri3.com/
address=/v1.cnzz.com/
address=/v1adserver.com/
address=/validclick.com/
address=/valuead.com/
address=/valueclick.com/
address=/valueclickmedia.com/
address=/valuecommerce.com/
address=/valuesponsor.com/
address=/vanfireworks.com/
address=/variablefitness.com/
address=/vcommission.com/
address=/veille-referencement.com/
address=/velismedia.com/
address=/ventivmedia.com/
address=/venturead.com/
address=/verblife-3.co/
address=/verblife-4.co/
address=/verblife-5.co/
address=/vericlick.com/
address=/vertamedia.com/
address=/verticalmass.com/
address=/vervewireless.com/
address=/vgwort.com/
address=/vgwort.de/
address=/vgwort.org/
address=/vibrantmedia.com/
address=/vidcpm.com/
address=/videoadex.com/
address=/videoamp.com/
address=/videoegg.com/
address=/videostats.kakao.com/
address=/video-stats.video.google.com/
address=/vidible.tv/
address=/vidora.com/
address=/view4cash.de/
address=/viglink.com/
address=/visiblemeasures.com/
address=/visistat.com/
address=/visit.webhosting.yahoo.com/
address=/visitbox.de/
address=/visitpath.com/
address=/visual-pagerank.fr/
address=/visualrevenue.com/
address=/vivads.net/
address=/vivatube.com/
address=/vivime.net.fr/
address=/vivtracking.com/
address=/vmmpxl.com/
address=/vodafone-affiliate.de/
address=/voicefive.com/
address=/voicevegetable.com/
address=/voluum.com/
address=/voluumtrk.com/
address=/voluumtrk2.com/
address=/volvelle.tech/
address=/voodoo-ads.io/
address=/vpon.com/
address=/vrs.cz/
address=/vrtzcontextualads.com/
address=/vs.tucows.com/
address=/vtracy.de/
address=/vungle.com/
address=/vwo.com/
address=/vx.org.ua/
address=/w55c.net/
address=/wa.and.co.uk/
address=/waardex.com/
address=/warlog.ru/
address=/warmafterthought.com/
address=/waryfog.com/
address=/wateryvan.com/
address=/wdads.sx.atl.publicus.com/
address=/wd-track.de/
address=/wearbasin.com/
address=/web.informer.com/
address=/web2.deja.com/
address=/webads.co.nz/
address=/webads.nl/
address=/webcash.nl/
address=/webcontentassessor.com/
address=/webcounter.cz/
address=/webcounter.goweb.de/
address=/webctrx.com/
address=/webgains.com/
address=/weborama.com/
address=/weborama.fr/
address=/webpower.com/
address=/web-redirecting.com/
address=/webreseau.com/
address=/webseoanalytics.com/
address=/websponsors.com/
address=/webstat.channel4.com/
address=/webstat.com/
address=/web-stat.com/
address=/webstat.net/
address=/webstats4u.com/
address=/webtracker.jp/
address=/webtrackerplus.com/
address=/webtracky.com/
address=/webtraffic.se/
address=/webtraxx.de/
address=/webtrends.telegraph.co.uk/
address=/webtrendslive.com/
address=/webxcdn.com/
address=/wellmadefrog.com/
address=/werbung.meteoxpress.com/
address=/wetrack.it/
address=/whaleads.com/
address=/wheredoyoucomefrom.ovh/
address=/whirlwealth.com/
address=/whiskyqueue.com/
address=/whispa.com/
address=/whisperingcrib.com/
address=/whitexxxtube.com/
address=/whoisonline.net/
address=/wholesaletraffic.info/
address=/widespace.com/
address=/widget.privy.com/
address=/widgetbucks.com/
address=/wikia-ads.wikia.com/
address=/win.iqm.com/
address=/window.nixnet.cz/
address=/wintricksbanner.googlepages.com/
address=/wirecomic.com/
address=/wisepops.com/
address=/witch-counter.de/
address=/wizaly.com/
address=/wlmarketing.com/
address=/womanear.com/
address=/wonderlandads.com/
address=/wondoads.de/
address=/woopra.com/
address=/worldwide-cash.net/
address=/worldwidedigitalads.com/
address=/worriednumber.com/
address=/wpnrtnmrewunrtok.xyz/
address=/wryfinger.com/
address=/ws/
address=/wt.bankmillennium.pl/
address=/wt-eu02.net/
address=/wtlive.com/
address=/www.amazon.in/
address=/www.dnps.com/
address=/www.kaplanindex.com/
address=/www.photo-ads.co.uk/
address=/www8.glam.com/
address=/www-banner.chat.ru/
address=/www-google-analytics.l.google.com/
address=/wwwpromoter.com/
address=/x.bild.de/
address=/x.chip.de/
address=/x.fokus.de/
address=/x.welt.de/
address=/x6.yakiuchi.com/
address=/xad.com/
address=/xapads.com/
address=/xchange.ro/
address=/xertive.com/
address=/xfreeservice.com/
address=/xg4ken.com/
address=/xiti.com/
address=/xovq5nemr.com/
address=/xplusone.com/
address=/xponsor.com/
address=/xpu.samsungelectronics.com/
address=/xq1.net/
address=/xtendmedia.com/
address=/x-traceur.com/
address=/xtracker.logimeter.com/
address=/xtremetop100.com/
address=/xxxcounter.com/
address=/xxxmyself.com/
address=/y.ibsys.com/
address=/yab-adimages.s3.amazonaws.com/
address=/yadro.ru/
address=/yepads.com/
address=/yesads.com/
address=/yesadvertising.com/
address=/yieldads.com/
address=/yieldlab.net/
address=/yieldmanager.com/
address=/yieldmanager.net/
address=/yieldmo.com/
address=/yieldtraffic.com/
address=/yldbt.com/
address=/ymetrica1.com/
address=/yoggrt.com/
address=/ypu.samsungelectronics.com/
address=/z3dmbpl6309s.com/
address=/z5x.net/
address=/zangocash.com/
address=/zanox.com/
address=/zanox-affiliate.de/
address=/zantracker.com/
address=/zarget.com/
address=/zbwp6ghm.com/
address=/zealousfield.com/
address=/zedo.com/
address=/zemanta.com/
address=/zencudo.co.uk/
address=/zenkreka.com/
address=/zenra.com/
address=/zenra.de/
address=/zenzuu.com/
address=/zeus.developershed.com/
address=/zeusclicks.com/
address=/zlp6s.pw/
address=/zm232.com/
address=/zmedia.com/
address=/zpu.samsungelectronics.com/
address=/zqtk.net/
address=/zukxd6fkxqn.com/
address=/zy16eoat1w.com/
address=/zzhc.vnet.cn/
address=/gewinnspiel.focus.de/
address=/gewinnspiel.chip.de/
address=/gewinnspiel.bild.de/
address=/gewinnspiel.stern.de/
address=/gewinnspiel.welt.de/
address=/service.focus.de/
address=/service.chip.de/
address=/service.bild.de/
address=/service.stern.de/
address=/service.welt.de/
address=/shopping.focus.de/
address=/shopping.chip.de/
address=/shopping.bild.de/
address=/shopping.stern.de/
address=/shopping.welt.de/
address=/deals.focus.de/
address=/deals.chip.de/
address=/deals.bild.de/
address=/deals.stern.de/
address=/deals.welt.de/
address=/shop.focus.de/
address=/shop.chip.de/
address=/shop.bild.de/
address=/shop.stern.de/
address=/shop.welt.de/
address=/tarif.focus.de/
address=/tarif.chip.de/
address=/tarif.bild.de/
address=/tarif.stern.de/
address=/tarif.welt.de/
address=/kuendigen.focus.de/
address=/kuendigen.chip.de/
address=/kuendigen.bild.de/
address=/kuendigen.stern.de/
address=/kuendigen.welt.de/
address=/rechnerportal.focus.de/
address=/rechnerportal.chip.de/
address=/rechnerportal.bild.de/
address=/rechnerportal.stern.de/
address=/rechnerportal.welt.de/
address=/vergleich.focus.de/
address=/vergleich.chip.de/
address=/vergleich.bild.de/
address=/vergleich.stern.de/
address=/vergleich.welt.de/
address=/games.focus.de/
address=/games.chip.de/
address=/games.bild.de/
address=/games.stern.de/
address=/games.welt.de/
address=/prospekte.focus.de/
address=/prospekte.chip.de/
address=/prospekte.bild.de/
address=/prospekte.stern.de/
address=/prospekte.welt.de/
address=/x.focus.de/
address=/x.chip.de/
address=/x.bild.de/
address=/x.stern.de/
address=/x.welt.de/
address=/amazon-adsystem.com/
address=/amazon-adsystem.eu/
address=/amazon-adsystem.de/
address=/amazon-adsystem.co.uk/
address=/amazon-adsystem.net/
address=/investor-praemien.de/
address=/glomex.com/
address=/smartredirect.de/
address=/smartredirect.com/
address=/criteo.net/
address=/criteo.com/
address=/criteo.de/
address=/permutive.com/
address=/permutive.de/
address=/bf-ad.net/
address=/bf-tools.net/
address=/somniture.chip.de/
address=/somniture.focus.de/
address=/somniture.bild.de/
address=/somniture.stern.de/
address=/somniture.welt.de/
address=/somniture.spiegel.de/
address=/adtm.chip.de/
address=/adtm.focus.de/

address=/apester.com/
address=/apester.de/
address=/.bing/
address=/.bingo/
address=/.ads/
address=/.pocker/
address=/.promo/
address=/.qvcs/
address=/.sale/
address=/.vegas/
EOF

cat << EOF > /etc/dnsmasq.d/Blacklist/porn
address=/sex.com/
address=/sex.net/
address=/sex.de/
address=/porn.com/
address=/porn.net/
address=/porn.de/
address=/porno.de/
address=/porno.com/
address=/porno.net/
address=/inthevip.com/
address=/inthevip.net/
address=/inthevip.de/
address=/intellitxt.com/
address=/intellitxt.net/
address=/intellitxt.de/
address=/outbrain.com/
address=/outbrain.net/
address=/outbrain.de/
address=/efahrer\.[a-z]*\.com/
address=/efahrer\.*[a-z]*\.de/
address=/efahrer.chip.de/
address=/efahrer.de/
address=/allporntubes.net/
address=/allsexclips.com/
address=/beateuhse.com/
address=/beate-uhse.com/
address=/beate-uhse.de/
address=/bordell.com/
address=/bordell.de/
address=/bpwhamburgorchardpark.org/
address=/bundesporno.com/
address=/bundesporno.net/
address=/burningangle.com/
address=/burningangle.de/
address=/burningangles.com/
address=/burningangles.de/
address=/centgebote.tv/
address=/chaturbate.com/
address=/chumshot.com/
address=/chumshot.de/
address=/collectionofbestporn.com/
address=/cyberotic.com/
address=/cyberotic.de/
address=/cyberotic.mobi/
address=/de.mediaplex.com/
address=/deutschepornos.xyz/
address=/deutschsexvideos.com/
address=/einfachporno.com/
address=/einfachporno.de/
address=/emediate.eu/
address=/emohotties.com/
address=/endloseporno.com/
address=/erotica.com/
address=/fancy.com/
address=/fancy.de/
address=/fapdu.com/
address=/fatpornfuck.com/
address=/ficken.com/
address=/ficken.de/
address=/firstporno.com/
address=/firstporno.de/
address=/fotze.com/
address=/fotze.de/
address=/fotzen.com/
address=/fotzen.de/
address=/freeporn.com/
address=/freeporn.de/
address=/geilemaedchen.com/
address=/geiltube.com/
address=/german-porno-deutsch.com/
address=/girlsavenue.com/
address=/girlsavenue.de/
address=/girldorado.com/
address=/girldorado.de/
address=/girldorado.net/
address=/girldorado.tv/
address=/girldorado.org/
address=/gratispornosfilm.com/
address=/guterporn.com/
address=/guterporn.de/
address=/hclips.com/
address=/hellporno.com/
address=/hellporno.de/
address=/hotntubes.com/
address=/hotntubes.de/
address=/hustler.com/
address=/hustler.de/
address=/iporntv.com/
address=/iporntv.net/
address=/jjhouse.com/
address=/justporno.com/
address=/justporno.de/
address=/justporno.tv/
address=/literotica.com/
address=/livejasmin.com/
address=/livejasmin.de/
address=/lockerdome.com/
address=/lupoporno.com/
address=/lustdays.com/
address=/lustparkplatz.com/
address=/moese.com/
address=/moese.de/
address=/movie4k.to/
address=/mp3fiesta.com/
address=/mp3sugar.com/
address=/mp3va.com/
address=/msads.net/
address=/nudevista.com/
address=/nudevista.tv/
address=/nursexfilme.com/
address=/penis.com/
address=/penis.de/
address=/prno.de/
address=/prno.com/
address=/porn.de/
address=/porn.com/
address=/pornburst.com/
address=/porndoe.com/
address=/pornhub.com/
address=/pornhub.de/
address=/pornodoe.com/
address=/pornoente.com/
address=/pornoente.de/
address=/pornoente.net/
address=/pornofi.com/
address=/porno-himmel.net/
address=/pornohirsch.com/
address=/pornokonig.com/
address=/pornoleeuw.com/
address=/pornoorzel.com/
address=/pornos-kostenlos.tv/
address=/pornostunde.com/
address=/puff.com/
address=/puff.de/
address=/pussyspace.com/
address=/realetykings.com/
address=/realetykings.de/
address=/realitykings.com/
address=/realitykings.de/
address=/redporn.com/
address=/redtube.com/
address=/redtube.de/
address=/rk.com/
address=/rk.de/
address=/schwanz.com/
address=/schwanz.de/
address=/script.ioam.de/
address=/selbstbefriedigung.com/
address=/selbstbefriedigung.de/
address=/sexhubhd.com/
address=/sexhubhd.de/
address=/sexhubhd.net/
address=/spermswap.com/
address=/spermswap.de/
address=/spermswap.us/
address=/starshows.de/
address=/starshows.com/
address=/starshows.org/
address=/toroporno.com/
address=/toys4you.com/
address=/toys4you.de/
address=/tubelibre.com/
address=/tubepatrol.net/
address=/tubesafari.com/
address=/tubevintageporn.com/
address=/urbandictionary.com/
address=/vagina.com/
address=/vagina.de/
address=/vivatube.com/
address=/whitexxxtube.com/
address=/wichsen.com/
address=/wichsen.de/
address=/wildesporno.com/
address=/wixen.com/
address=/wixen.de/
address=/xhamster.com/
address=/xhamster.de/
address=/xhamsterdeutsch.biz/
address=/youporn.com/
address=/youporn.de/
address=/yourporn.com/
address=/yourporn.de/
address=/xvideo.de/
address=/xvideo.com/
address=/xvideos.de/
address=/xvideos.com/
address=/xnxx.com/
address=/xnxx.de/
address=/fundorado.de/
address=/fundorado.com/
address=/starshows.de/
address=/starshows.com/
address=/youjizz.com/
address=/youjizz.de/
address=/tube8.com/
address=/tube8.de/
address=/bestandfree.com/
address=/bestandfree.de/
address=/sexgirls.de/
address=/sexstories.de/
address=/sexstorys.de/
address=/sexstrories.com/
address=/sexstorys.com/
address=/sexstories.net/
address=/sexstorys.net/
address=/anysex.com/
address=/anysex.de/
address=/apornostories.com/
address=/apornstories.de/
address=/apornostories.de/
address=/apornstories.com/
address=/apornstory.com/
address=/apornstory.de/
address=/emogirlsfuck.com/
address=/emogirlfuck.com/
address=/emogirlsfuck.de/
address=/emogirlfuck.de/
address=/emogirls.com/
address=/emogirl.com/
address=/emogirls.de/
address=/emogirl.de/
address=/bongacams.com/
address=/bongacams.de/
address=/bongacam.com/
address=/bongacam.de/
address=/bongaporn.com/
address=/bongaporn.de/
address=/bongaporno.com/
address=/bongaporno.de/
address=/bongasex.de/
address=/bongasex.com/
address=/tubesplash.com/
address=/tubesplash.de/
address=/txxx.com/
address=/txxx.de/
address=/.porn/
address=/.porno/
address=/.xxx/
address=/.sex/
address=/.adult/
address=/.girl/
address=/.girls/
address=/.dating/
address=/.gay/
address=/.pink/
address=/.sexy/
address=/.tube/
address=/.xyz/
EOF

cat << EOF > /etc/dnsmasq.d/Blacklist/white
server=/dns4torpnlfs2ifuz2s2yf3fc7rdmsbhm6rw75euj35pac6ap25zgqad.onion/127.0.0.1#9053

server=/microsoftconnecttest.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/msftncsi.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/clients3.google.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/connectivitycheck.gstatic.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/detectportal.firefox.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tplinkcloud.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/captive.apple.com/127.0.0.1#$(echo $DNS_UNBOUND_port)

server=/3sat.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/7tv.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/7tv.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/accuweather.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/accuweather.comde/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/aio-control.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/aio-control.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/aio-controls.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/aio-controls.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/akamaihd.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/alexasounds.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/alice.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/alice.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/alice-dsl.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/alice-dsl.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/amazon.co.uk/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/amazon.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/amazonsilk.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/amazon.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/amazon.eu/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/amazonaws.co.uk/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/.amazon/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/mlis.amazon.eu/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/spectrum.s3.amazonaws.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/amazonaws.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/amazonaws.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/a2z.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/images-amazon.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/andreas-stawinski.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/android.clients.google.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/antenne.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/api.amazonalexa.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/api.co.uk.amazonalexa.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/api.crittercism.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/api.eu.amazonalexa.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/amazonvideo.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/api-global.netflix.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/openwrt.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/raspbery.org/127.0.0.1#$(echo $DNS_UNBOUND_port)


server=/apple.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/mzstatic.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/apple.de/127.0.0.1#$(echo $DNS_UNBOUND_port)

server=/ard.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ardmediathek.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/arte.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/avm.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/bing.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/br.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/br24.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/br-24.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/br24.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/br-24.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/cddbp.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/chip.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/chip.smarttv.cellular.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/cinepass.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/cinepass.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/cloud.mediola.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/cloudfront.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/cloudflare-dns.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/cloudflare.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/connectors.yonomi.co/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/connectors.yonomi.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/content.dhg.myharmony.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ct.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/cyberandi.blog/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/cyberandi.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/cyberandi.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/cyberandi.eu/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/daserste.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/deutschewelle.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/deutschewelle.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/directions.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/directions.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/dnssec-or-not.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/dnssec.vs.uni-due.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/dw.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/dw.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/elasticbeanstalk.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/elasticbeanstalk.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/epg.corio.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/erf.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/erf1.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/erste.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/filmstarts.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/focus.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/fireoscaptiveportal.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/freestream.nmdn.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/fritz.box/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/flip.it/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ftp.stawimedia.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/github.io/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/github.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/github.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/galileo.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/gallileo.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/geonames.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/getinvoked.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ggpht.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/googleapis.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/google.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/googlevideo.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/gracenote.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/gvt1.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/harmonyremote.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/harmony-remote.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/harmonyremote.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/harmony-remote.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/hbbtv.*/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/heise.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/heise-online.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/heute.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/hinter.bibeltv.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/home.stawimedia.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/hotmail.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/hotmail.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ichnaea.netflix.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/icloud.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/icloud.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ifttt.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ihealthlabs.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/imdb.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/imdb.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/invokedapps.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/invokedapps.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ipleak.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ipv4_*.*.*.fra*.ix.nflxvideo.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ipv6_*.*.*.fra*.ix.nflxvideo.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ism/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/it-business.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/it-business.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/itunes.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ix.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ix.nflxvideo.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ix.nflxvideo.net/127.0.0.1#$(echo $DNS_UNBOUND_port)

server=/joyn.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/api.segment.io/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/seventv.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/route71.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ak-t1p-vod-playout-prod.akamaized.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/prosieben-ctr.live.ott.irdeto.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/p7s1video.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/joyn.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/joyn.tv/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/joyn.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/kabeleins.de/127.0.0.1#$(echo $DNS_UNBOUND_port)

server=/laut.fm/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/live.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/live.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/llnwd.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/llnwd.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/logging.dhg.myharmony.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/m.media-amazon.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/m.tvinfo.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/macandi.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/mediola.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/mediola.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/members.harmonyremote.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/metafilegenerator.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/microsoft.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/microsoft.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/mobile.chip.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/myfritz.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/myharmony.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/myharmony.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/myharmony.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/myremotesetup.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/mytvscout.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/n24.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/push.prod.netflix.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nccp.netflix.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/uiboot.netflix.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/secure.netflix.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/customerevents.netflix.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/netflix.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/netflix.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nflximg.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nflximg.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nflxvideo.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nflxvideo.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nflxvideo.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nflxso.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nfximg.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nflxso.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nfximg.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nflxso.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nfximg.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nodejs.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/no-ip.biz/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nokia.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/nokia.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/npmjs.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ntp.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/n-tv.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/o2.box/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/office.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/office.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/office365.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/office365.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/onlinewetter.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/onlinewetter.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/opendns.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/openstreetmap.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/openstreetmap.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/openstreetmap.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/outlook.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/outlook.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/outlook.live.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/pcwelt.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/pc-welt.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/philips.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/philips.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/philips.nl/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/phobos.apple.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/phobos.apple.com.edgesuite.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/photos.apple.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/photos.apple.com.edgesuite.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/pionieer.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/play.google.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/playstation.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/prosieben.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ps3.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/pubsub.pubnub.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/pubnub.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/radio.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/radiogong.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/radiotime.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/remotes.aio-control.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/remotes.aio-control.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/remotes.aio-controls.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/remotes.aio-controls.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/remotesneo.aio-control.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/resolver1.opendns.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/resolver2.opendns.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/resolver3.opendns.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/resolver4.opendns.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/rtl.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/rtl2.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/s3-directional-w.amazonaws.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/samsung.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/sat1.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/script.ioam.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/shoutcast.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/sony.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/spn.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/startpage.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/startpage.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/startpage.nl/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/stawimedia.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/stawimedia.eu/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/stawimedia.local/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/stream.erf.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/streamfarm.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/sus.dhg.myharmony.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/svcs.myharmony.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/t3n.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/telegram.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/t.me/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tagesschau.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tagesschau24.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/time.nist.gov/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/time.windows.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/torproject.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tumblr.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tumblr.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tumblr.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tune_in.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tune_in.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tunein.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tune-in.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tunein.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tune-in.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tvnow.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tvnow.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/twitter.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/twitter.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/t.co/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tvtv.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/unifiedlayer.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/vevo.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/vevo.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/video.google.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/videobuster.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/videobuster.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/videociety.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/videociety.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/vimeo.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/vimeo.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/wbsapi.withings.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/waipu.tv/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/waipu.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/waipu.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/whatismyip.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/wpstr.tv/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/waipu.ch/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/weather.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/weather.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/welt.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/wetter.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/wetter.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/wetteronline.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/wetter-online.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/wikimedia.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/wikipedia.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/wikipedia.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/wikipedia.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/withings.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/withings.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ws.withings.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/wunderlist.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/y2u.be/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/yelp.co.uk/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/yelp.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/yelp.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/yelp.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/yelpcdn.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/yonomi.co/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/yonomi.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/youtu.be/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/youtube.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/youtube-nocookie.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ytimg.com/127.0.0.1#$(echo $DNS_UNBOUND_port)

server=/zattoo.ch/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/zattoo.co.uk/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/zattoo.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/zattoo.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/zattic.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/zahs.tv/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/zattoo.eu/127.0.0.1#$(echo $DNS_UNBOUND_port)

server=/zdf.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/zdf-cdn.live.cellular.de/127.0.0.1#$(echo $DNS_UNBOUND_port)

server=/dlive.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/dlive.tv/127.0.0.1#$(echo $DNS_UNBOUND_port)

server=/twitch.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/twitch.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/twitch.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/twitchcdn.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ttvnw.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/jtvnw.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/twitch.tv/127.0.0.1#$(echo $DNS_UNBOUND_port)

server=/disneyplus.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/disney+.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/disneyplus.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/disney+.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/disneyplus.tv/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/bamgrid.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/bam.nr-data.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/cdn.registerdisney.go.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/cws.convia.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/d9.flashtalking.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/disney-portal.my.onetrust.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/disneyplus.bn5x.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/js-agent.newrelic.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/disney-plus.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/dssott.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/adobedtm.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/disney+.tv/127.0.0.1#$(echo $DNS_UNBOUND_port)

server=/pluto.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/pluto.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/pluto.tv/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tvnow.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tvnow.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tvnow.tv/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/duckduck.go/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/duckduckgo.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/duckduckgo.com/127.0.0.1#$(echo $DNS_UNBOUND_port)

server=/fireoscaptiveportal.com/127.0.0.1#$(echo $DNS_UNBOUND_port)

server=/bitchute.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/bitchute.tv/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/instagram.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/instagram.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/pinterest.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/pinterest.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/pinterest.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/flickr.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/flickr.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/flickr.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/imdb.tv/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/imdb.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/imdb.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/imdb.org/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/you2.be/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/youtu.be/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/spotify.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/spotify.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/spotify.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/www.bit.ly/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/bit.ly/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/ow.ly/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/tinyurl.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/buff.ly/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/trib.al/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/serienstream.sx/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/goo.gl/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/duckduckgo.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/duckduck.go/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/wetter-online.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/wetter-online.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/snapcraft.io/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/easylist.to/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/secure.fanboy.co.nz/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/glm.io/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/heise.cloudimg.io/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/im.bestcheck.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/eum.instana.io/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/s.w-x.co/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/docker.io/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/bibelserver.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/bibelserver.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/bibleserver.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/bibleserver.com/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/erf.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/icf.ch/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/icf.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/icf.church/127.0.0.1#$(echo $DNS_UNBOUND_port)

server=/.skype/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/.youtube/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/.office/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/.exit/127.0.0.1#9053
server=/.onion/127.0.0.1#9053
EOF

cat << EOF > /etc/dnsmasq.d/Blacklist/banking

server=/.banking/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/unicredit.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/hvb.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/unicredit.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/hvb.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/hypovereinsbak.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/hypovereinsbank.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/comdirekt.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/comdirect.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/comdirect.net/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/postbank.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/satander.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/n26.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/deutschebank.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/reiba.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/sparkasse.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/sskm.de/127.0.0.1#$(echo $DNS_UNBOUND_port)
server=/commerzbank.de/127.0.0.1#$(echo $DNS_UNBOUND_port)

EOF


cp /etc/dnsmasq.d/Blacklist/ads /etc/dnsmasq.d/Whitelist/ads >/dev/null
cp /etc/dnsmasq.d/Blacklist/agency /etc/dnsmasq.d/Whitelist/agency >/dev/null
cp /etc/dnsmasq.d/Blacklist/banking /etc/dnsmasq.d/Whitelist/banking >/dev/null
cp /etc/dnsmasq.d/Blacklist/contrys /etc/dnsmasq.d/Whitelist/contrys >/dev/null
cp /etc/dnsmasq.d/Blacklist/porn /etc/dnsmasq.d/Whitelist/porn >/dev/null
cp /etc/dnsmasq.d/Blacklist/white /etc/dnsmasq.d/Whitelist/white >/dev/null

/etc/init.d/dnsmasq restart >/dev/null

echo
echo
clear
echo '########################################################'
echo '#                                                      #'
echo '#                 CyberSecurity-Box                    #'
echo '#                                                      #'
echo '# local Privacy for Voice-Assistent Smart-TV SmartHome #'
echo '#                                                      #'
echo '#                AD- and Porn-Filter installed         #'
echo '#                                                      #'
echo '########################################################'
echo
echo 'Your Config is:'
echo
echo 'Client-WiFi SSID:     '$INET_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$INET_net
echo
echo 'Smarthome-WiFi SSID:  '$HCONTROL_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$HCONTROL_net
echo
echo 'Voice-Assistent SSID: '$VOICE_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$VOICE_net
echo
echo 'Smart-TV/-DVD SSID:   '$ENTERTAIN_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$ENTERTAIN_net
echo
echo 'Server-WiFi SSID:     '$SERVER_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$SERVER_net
echo
echo 'IR/BT-Control SSID:   '$CONTROL_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$CONTROL_net
echo
echo 'Guests SSID is:       '$GUEST_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$GUEST_net
echo
echo
echo
echo 'IP-Address:           '$ACCESS_SERVER
echo 'Gateway:              '$INET_GW
echo 'Domain:               '$LOCAL_DOMAIN
echo
echo 'GUI-Access:           https://'$INET_ip':8443'
echo 'User:                 '$USERNAME
echo 'Password:             password'
echo
echo 'Please wait until Reboot ....'


uci set firewall.@zone[0]=zone
uci set firewall.@zone[0].name="REPEATER"
uci set firewall.@zone[0].input="ACCEPT"
uci set firewall.@zone[0].network="REPEATER"
uci set firewall.@zone[0].output="ACCEPT"
uci set firewall.@zone[0].forward="ACCEPT"
#uci set firewall.@zone[-1].log="1"
uci commit firewall >/dev/null
uci add firewall forwarding >/dev/null
uci set firewall.@forwarding[-1]=forwarding
uci set firewall.@forwarding[-1].dest="wan"
uci set firewall.@forwarding[-1].src="REPEATER"
uci commit firewall && reload_config >/dev/null

uci add firewall zone >/dev/null
uci set firewall.@zone[-1]=zone
uci set firewall.@zone[-1].name="CONTROL"
uci set firewall.@zone[-1].input="ACCEPT"
uci set firewall.@zone[-1].forward="ACCEPT"
uci set firewall.@zone[-1].network="CONTROL"
uci set firewall.@zone[-1].output="ACCEPT"
#uci set firewall.@zone[-1].log="1"
uci commit firewall >/dev/null
uci add firewall forwarding >/dev/null
uci set firewall.@forwarding[-1]=forwarding
uci set firewall.@forwarding[-1].dest="wan"
uci set firewall.@forwarding[-1].src="CONTROL"
uci commit firewall && reload_config >/dev/null

uci add firewall zone >/dev/null
uci set firewall.@zone[-1]=zone
uci set firewall.@zone[-1].name="HCONTROL"
uci set firewall.@zone[-1].input="ACCEPT"
uci set firewall.@zone[-1].forward="ACCEPT"
uci set firewall.@zone[-1].network="HCONTROL"
uci set firewall.@zone[-1].output="ACCEPT"
#uci set firewall.@zone[-1].log="1"
uci commit firewall >/dev/null
uci add firewall forwarding >/dev/null
uci set firewall.@forwarding[-1]=forwarding
uci set firewall.@forwarding[-1].dest="wan"
uci set firewall.@forwarding[-1].src="HCONTROL"
uci commit firewall && reload_config >/dev/null

uci add firewall zone >/dev/null
uci set firewall.@zone[-1]=zone
uci set firewall.@zone[-1].name="SERVER"
uci set firewall.@zone[-1].input="ACCEPT"
uci set firewall.@zone[-1].forward="ACCEPT"
uci set firewall.@zone[-1].network="SERVER"
uci set firewall.@zone[-1].output="ACCEPT"
#uci set firewall.@zone[-1].log="1"
uci commit firewall >/dev/null
uci add firewall forwarding >/dev/null
uci set firewall.@forwarding[-1]=forwarding
uci set firewall.@forwarding[-1].dest="wan"
uci set firewall.@forwarding[-1].src="SERVER"
uci commit firewall && reload_config >/dev/null

uci add firewall zone >/dev/null
uci set firewall.@zone[-1]=zone
uci set firewall.@zone[-1].name="INET"
uci set firewall.@zone[-1].input="ACCEPT"
uci set firewall.@zone[-1].forward="ACCEPT"
uci set firewall.@zone[-1].network="INET"
uci set firewall.@zone[-1].output="ACCEPT"
#uci set firewall.@zone[-1].log="1"
uci commit firewall >/dev/null
uci add firewall forwarding >/dev/null
uci set firewall.@forwarding[-1]=forwarding
uci set firewall.@forwarding[-1].dest="wan"
uci set firewall.@forwarding[-1].src="INET"
uci commit firewall && reload_config >/dev/null

uci add firewall zone >/dev/null
uci set firewall.@zone[-1]=zone
uci set firewall.@zone[-1].name="GUEST"
uci set firewall.@zone[-1].input="ACCEPT"
uci set firewall.@zone[-1].forward="ACCEPT"
uci set firewall.@zone[-1].network="GUEST"
uci set firewall.@zone[-1].output="ACCEPT"
#uci set firewall.@zone[-1].log="1"
uci commit firewall >/dev/null
uci add firewall forwarding >/dev/null
uci set firewall.@forwarding[-1]=forwarding
uci set firewall.@forwarding[-1].dest="wan"
uci set firewall.@forwarding[-1].src="GUEST"
uci commit firewall && reload_config >/dev/null

uci add firewall zone >/dev/null
uci set firewall.@zone[-1]=zone
uci set firewall.@zone[-1].name="CMOVIE"
uci set firewall.@zone[-1].input="ACCEPT"
uci set firewall.@zone[-1].forward="ACCEPT"
uci set firewall.@zone[-1].network="CMOVIE"
uci set firewall.@zone[-1].output="ACCEPT"
#uci set firewall.@zone[-1].log="1"
uci commit firewall >/dev/null
uci add firewall forwarding >/dev/null
uci set firewall.@forwarding[-1]=forwarding
uci set firewall.@forwarding[-1].dest="wan"
uci set firewall.@forwarding[-1].src="CMOVIE"
uci commit firewall && reload_config >/dev/null

uci add firewall zone >/dev/null
uci set firewall.@zone[-1]=zone
uci set firewall.@zone[-1].name="VOICE"
uci set firewall.@zone[-1].input="ACCEPT"
uci set firewall.@zone[-1].forward="ACCEPT"
uci set firewall.@zone[-1].network="VOICE"
uci set firewall.@zone[-1].output="ACCEPT"
#uci set firewall.@zone[-1].log="1"
uci commit firewall >/dev/null
uci add firewall forwarding >/dev/null
uci set firewall.@forwarding[-1]=forwarding
uci set firewall.@forwarding[-1].dest="wan"
uci set firewall.@forwarding[-1].src="VOICE"
uci commit firewall && reload_config >/dev/null

uci add firewall zone >/dev/null
uci set firewall.@zone[-1]=zone
uci set firewall.@zone[-1].name="ENTERTAIN"
uci set firewall.@zone[-1].input="ACCEPT"
uci set firewall.@zone[-1].forward="ACCEPT"
uci set firewall.@zone[-1].network="ENTERTAIN"
uci set firewall.@zone[-1].output="ACCEPT"
#uci set firewall.@zone[-1].log="1"
uci commit firewall >/dev/null
uci add firewall forwarding >/dev/null
uci set firewall.@forwarding[-1]=forwarding
uci set firewall.@forwarding[-1].dest="wan"
uci set firewall.@forwarding[-1].src="ENTERTAIN"
uci commit firewall && reload_config >/dev/null

# Intercept SSH, HTTP and HTTPS traffic
uci -q delete firewall.ssh_int >/dev/null
uci set firewall.ssh_int="redirect"
uci set firewall.ssh_int.name="Intercept_SSH"
uci set firewall.ssh_int.src="INET"
uci set firewall.ssh_int.src_dport="$SSH_port"
uci set firewall.ssh_int.proto="tcp"
uci set firewall.ssh_int.target="DNAT"

uci -q delete firewall.http_int >/dev/null
uci set firewall.http_int="redirect"
uci set firewall.http_int.name="Intercept_HTTP"
uci set firewall.http_int.src="INET"
uci set firewall.http_int.src_dport="$ACCESS_HTTP_port"
uci set firewall.http_int.proto="tcp"
uci set firewall.http_int.target="DNAT"

uci -q delete firewall.https_int
uci set firewall.https_int="redirect"
uci set firewall.https_int.name="Intercept_HTTPS"
uci set firewall.https_int.src="INET"
uci set firewall.https_int.src_dport="$ACCESS_HTTPS_port"
uci set firewall.https_int.proto="tcp"
uci set firewall.https_int.target="DNAT"

uci commit firewall && reload_config >/dev/null

# Intercept DNS and TCP traffic

uci -q delete firewall.tcp_onion_int > /dev/null uci set firewall.tcp_onion_int="redirect"
uci set firewall.tcp_onion_int.name="Intercept_Onion_Domain"
uci set firewall.tcp_onion_int.src_dport=$TOR_TRANS_port
uci set firewall.tcp_onion_int.dest_port=$TOR_TRANS_port
uci set firewall.tcp_onion_int.proto="tcp"
uci set firewall.tcp_onion_int.target="DNAT"
uci set firewall.tcp_onion_int.src="INET"
uci set firewall.tcp_onion_int.src_dip="10.192.0.0./10"
uci set firewall.tcp_onion_int.extra="--syn"

uci -q delete firewall.tcp_onionSocks_int > /dev/null 
uci set firewall.tcp_onionSocks_int="redirect"
uci set firewall.tcp_onionSocks_int.name='Intercept_Onion_Domain'
uci set firewall.tcp_onionSocks_int.src='INET'
uci set firewall.tcp_onionSocks_int.src_dport=$TOR_SOCKS2_port
uci set firewall.tcp_onionSocks_int.dest_port=$TOR_SOCKS2_port
uci set firewall.tcp_onionSocks_int.src_dip='10.192.0.0/10'
uci set firewall.tcp_onionSocks_int.proto='tcp'
uci set firewall.tcp_onionSocks_int.target='DNAT'
uci set firewall.tcp_onionSocks_int.extra='--syn'

uci -q delete firewall.tcp_onionSocks1_int > /dev/null 
uci set firewall.tcp_onionSocks1_int=redirect
uci set firewall.tcp_onionSocks1_int.name='Intercept_Onion1_Domain'
uci set firewall.tcp_onionSocks1_int.src='INET'
uci set firewall.tcp_onionSocks1_int.dest_port=$TOR_SOCKS_port
uci set firewall.tcp_onionSocks1_int.src_dport=$TOR_SOCKS_port
uci set firewall.tcp_onionSocks1_int.proto='tcp'
uci set firewall.tcp_onionSocks1_int.target='DNAT'
uci set firewall.tcp_onionSocks1_int.extra='--syn'

uci -q delete firewall.tcp_tor2_int > /dev/null 
uci set firewall.tcp_tor2_int=redirect
uci set firewall.tcp_tor2_int.src_dip='!192.168.0.0/16'
uci set firewall.tcp_tor2_int.proto='tcp'
uci set firewall.tcp_tor2_int.target='DNAT'
uci set firewall.tcp_tor2_int.dest_port=$TOR_TRANS_port
uci set firewall.tcp_tor2_int.src='INET'
uci set firewall.tcp_tor2_int.src_dport=$HTTPS_port
uci set firewall.tcp_tor2_int.extra='--syn'
uci set firewall.tcp_tor2_int.name='Intercept https tor'

uci -q delete firewall.tcp_tor3_int > /dev/null 
uci set firewall.tcp_tor3_int=redirect
uci set firewall.tcp_tor3_int.src_dip='!192.168.0.0/16'
uci set firewall.tcp_tor3_int.proto='tcp'
uci set firewall.tcp_tor3_int.target='DNAT'
uci set firewall.tcp_tor3_int.dest_port=$TOR_TRANS_port
uci set firewall.tcp_tor3_int.src='INET'
uci set firewall.tcp_tor3_int.name='Intercept http tor'
uci set firewall.tcp_tor3_int.src_dport=$HTTP_port
uci set firewall.tcp_tor3_int.extra='--syn'

uci -q delete firewall.omada > /dev/null
uci set firewall.omada=redirect
uci set firewall.omada.dest_port=$CONTROLER_port
uci set firewall.omada.name='Network_omada'
uci set firewall.omada.src_dport=$CONTROLER_port
uci set firewall.omada.target='DNAT'
uci set firewall.omada.dest_ip='192.168.71.175'
uci set firewall.omada.dest='HCONTROL'
uci set firewall.omada.src='INET'
uci set firewall.omada.extra='--syn'

uci -q delete firewall.homematic > /dev/null
uci set firewall.homematic=redirect
uci set firewall.homematic.dest_port='80'
uci set firewall.homematic.target='DNAT'
uci set firewall.homematic.src='INET'
uci set firewall.homematic.dest_ip='192.168.70.52'
uci set firewall.homematic.dest='CONTROL'
uci set firewall.homematic.proto='tcp'
uci set firewall.homematic.name='Homematic ccu'
uci set firewall.homematic.src_dip='192.168.70.52/32'
uci set firewall.homematic.src_dport='8080'
uci set firewall.homematic.extra='--syn'

uci -q delete firewall.homematic1 > /dev/null
uci set firewall.homematic1=redirect
uci set firewall.homematic1.dest_port='443'
uci set firewall.homematic1.target='DNAT'
uci set firewall.homematic1.src='INET'
uci set firewall.homematic1.dest_ip='192.168.70.52'
uci set firewall.homematic1.dest='CONTROL'
uci set firewall.homematic1.proto='tcp'
uci set firewall.homematic1.name='Homematic ccu'
uci set firewall.homematic1.src_dip='192.168.70.52/32'
uci set firewall.homematic1.src_dport='4443'
uci set firewall.homematic1.extra='--syn'

#-----------------------------------------------------------------------------


uci set firewall.DNS_Cloudflare=rule
uci set firewall.DNS_Cloudflare.dest_port="$all_DNS_port"
uci set firewall.DNS_Cloudflare.src="*"
uci set firewall.DNS_Cloudflare.name="Allow_Cloudflare_local_DNS"
uci set firewall.DNS_Cloudflare.dest="*"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare1_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare2_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare3_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare4_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare5_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare6_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare7_SVR" 
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare8_SVR" 
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare9_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare10_SVR" 
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare11_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare12_SVR"  
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare13_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare14_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare15_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare16_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare17_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare18_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare19_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare20_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare21_SVR" 
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare22_SVR"
uci add_list firewall.DNS_Cloudflare.dest_ip="$DNS_Cloudflare23_SVR" 
uci set firewall.DNS_Cloudflare.enabled="0" 
uci set firewall.DNS_Cloudflare.proto="tcp udp"
uci set firewall.DNS_Cloudflare.target="ACCEPT"
uci commit && reload_config >/dev/null


#WebClient (Port)
#21, 22, 25, 53, 80, 110, 123, 443, 853, 5353, 9030, 9040, 9049, 9050, 9053, 9060, 50275, 54715, 54789, 51465, 56343, 56534, 57687, 60870
uci set firewall.WebClient=rule
uci set firewall.WebClient.dest_port="$WebClient_port"
uci set firewall.WebClient.src="*"
uci set firewall.WebClient.name="Allow_WebClient"
uci set firewall.WebClient.enabled="0"
uci set firewall.WebClient.dest="wan"
uci set firewall.WebClient.target="ACCEPT"


#Office_Client (Port)
# 21 22 23 25 53 67 80 110 123 139 138 137 443 445 515 548 631 853 2049 5353 9030 9040 9049 9050 9053 9060 9100 50275 54715 54789 51465 56343 56534 57687 60870
uci set firewall.OfficeClient=rule
uci set firewall.OfficeClient.src='INET'
uci set firewall.OfficeClient.name='Allow_OfficeClient'
uci set firewall.OfficeClient.dest='SERVER'
uci set firewall.OfficeClient.proto='udp tcp'
uci set firewall.OfficeClient.target='ACCEPT'
uci set firewall.OfficeClient.dest_port="$OfficeClient_port"
#1-20 24 26-52 54-66 68-79 81-109 111-122 124-136 140-442 444 446-514 516-547 549-630 632-852 854-2048 2050-5352 5354-8442 8444-9029 9031-9039 9041-9048 9051 9052 9054-9059 9061-9099 9101-40442 40446-50274 50276-51464 51465-54714 54716-54788 54790-56342 56344-56533 56535-57686 57688-60869 60871-65535'

uci set firewall.OfficeWebClient=rule
uci set firewall.OfficeWebClient.src='INET'
uci set firewall.OfficeWebClient.name='Allow_OfficeClient_WEB'
uci set firewall.OfficeWebClient.dest='wan'
uci set firewall.OfficeWebClient.proto='udp tcp'
uci set firewall.OfficeWebClient.target='ACCEPT'
uci set firewall.OfficeWebClient.dest_port="$OfficeWebClient_port"

#Alexa (Port)
#"67:68 8080 40317 49317 33434 123 54838 55443 46053 1000:10000 50000:65000 16000:26000"
#udp 4070 5353 40317 49317 33434 50000:60000 3478:3481
uci set firewall.Amazon_Alexa=rule
uci set firewall.Amazon_Alexa.name='Allow_AmazonAlexa'
uci set firewall.Amazon_Alexa.proto='tcp'
uci set firewall.Amazon_Alexa.dest='wan'
uci set firewall.Amazon_Alexa.target='ACCEPT'
uci set firewall.Amazon_Alexa.src='VOICE'
uci set firewall.Amazon_Alexa.dest_port="$Amazon_Alexa_port"
uci set firewall.Amazon_Alexa_UDP=rule
uci set firewall.Amazon_Alexa_UDP.name='Allow_AmazonAlexa_UDP'
uci set firewall.Amazon_Alexa_UDP.proto='udp'
uci set firewall.Amazon_Alexa_UDP.dest='wan'
uci set firewall.Amazon_Alexa_UDP.target='ACCEPT'
uci set firewall.Amazon_Alexa_UDP.src='VOICE'
uci set firewall.Amazon_Alexa_UDP.dest_port="$Amazon_Alexa_UDP_port"

#Google Assistent (Port)
#uci set firewall.Google_assistent=rule

#Telnet (Port)
#23
uci set firewall.TELNET=rule
uci set firewall.TELNET.dest_port="$TELNET_port"
uci set firewall.TELNET.src="*"
uci set firewall.TELNET.name="Allow_Telnet"
uci set firewall.TELNET.enabled="0"
uci set firewall.TELNET.dest="wan"
uci set firewall.TELNET.target="ACCEPT"


#SSH (Port)
#22
uci set firewall.SSH=rule
uci set firewall.SSH.dest_port="$SSH_port"
uci set firewall.SSH.src="*"
uci set firewall.SSH.name="Allow_SSH"
uci set firewall.SSH.dest="wan"
uci set firewall.SSH.enabled="0"
uci set firewall.SSH.dest="wan"
uci set firewall.SSH.target="ACCEPT"


#NTP
#123
uci set firewall.NTP=rule
uci set firewall.NTP.dest_port="$NTP_port"
uci set firewall.NTP.src="*"
uci set firewall.NTP.name="Allow_NTP"
uci set firewall.NTP.enabled="0"
uci set firewall.NTP.dest="wan"
uci set firewall.NTP.target="ACCEPT"

#smtp
#"25 465 587"
uci set firewall.SMTP=rule
uci set firewall.SMTP.dest_port="$SMTP_port"
uci set firewall.SMTP.src="*"
uci set firewall.SMTP.name="Allow_SMTP"
uci set firewall.SMTP.enabled="0"
uci set firewall.SMTP.dest="wan"
uci set firewall.SMTP.target="ACCEPT"


#POP3 Port
#POP3_PORT="110 995"
uci set firewall.POP3=rule
uci set firewall.POP3.dest_port="$POP3_port"
uci set firewall.POP3.src="*"
uci set firewall.POP3.name="Allow_POP3"
uci set firewall.POP3.enabled="0"
uci set firewall.POP3.dest="wan"
uci set firewall.POP3.target="ACCEPT"


#IMAP4 Port
#IMAP_PORT="143 993 626"
uci set firewall.IMAP4=rule
uci set firewall.IMAP4.dest_port="$IMAP_port"
uci set firewall.IMAP4.src="*"
uci set firewall.IMAP4.name="Allow_IMAP4"
uci set firewall.IMAP4.enabled="0"
uci set firewall.IMAP4.dest="wan"
uci set firewall.IMAP4.target="ACCEPT"


#KERBEROS
#"88 749"
uci set firewall.KERBEROS=rule
uci set firewall.KERBEROS.dest_port="$KERBEROS_port"
uci set firewall.KERBEROS.src="*"
uci set firewall.KERBEROS.name="Allow_KERBEROS"
uci set firewall.KERBEROS.enabled="0"
uci set firewall.KERBEROS.dest="wan"
uci set firewall.KERBEROS.proto="tcp"
uci set firewall.KERBEROS.target="ACCEPT"


#Password_Server
#"106"
uci set firewall.PASSWDSRV=rule
uci set firewall.PASSWDSRV.dest_port="$PASSWDSRV_port"
uci set firewall.PASSWDSRV.src="*"
uci set firewall.PASSWDSRV.name="Allow_PASWD_SRV"
uci set firewall.PASSWDSRV.enabled="0"
uci set firewall.PASSWDSRV.dest="wan"
uci set firewall.PASSWDSRV.proto="tcp"
uci set firewall.PASSWDSRV.target="ACCEPT"

#LDAP
#"389 636"
uci set firewall.LDAP=rule
uci set firewall.LDAP.dest_port="$LDAP_port"
uci set firewall.LDAP.src="*"
uci set firewall.LDAP.name="Allow_LDAP"
uci set firewall.LDAP.enabled="0"
uci set firewall.LDAP.dest="wan"
uci set firewall.LDAP.proto="tcp"
uci set firewall.LDAP.target="ACCEPT"


#RPC
#"111"
uci set firewall.RPC=rule
uci set firewall.RPC.dest_port="$RPC_port"
uci set firewall.RPC.src="*"
uci set firewall.RPC.name="Allow_RPC"
uci set firewall.RPC.enabled="0"
uci set firewall.RPC.dest="wan"
uci set firewall.RPC.proto="tcp"
uci set firewall.RPC.target="ACCEPT"

#NNTP
#"119"
uci set firewall.NNTP=rule
uci set firewall.NNTP.dest_port="$NNTP_port"
uci set firewall.NNTP.src="*"
uci set firewall.NNTP.name="Allow_NNTP"
uci set firewall.NNTP.enabled="0"
uci set firewall.NNTP.dest="wan"
uci set firewall.NNTP.proto="tcp"
uci set firewall.NNTP.target="ACCEPT"

#Real Time Streaming Protocol (RTSP)
#"554"
uci set firewall.RTSP=rule
uci set firewall.RTSP.dest_port="$RTSP_port"
uci set firewall.RTSP.src="*"
uci set firewall.RTSP.name="Allow_RTSP"
uci set firewall.RTSP.enabled="0"
uci set firewall.RTSP.dest="wan"
uci set firewall.RTSP.target="ACCEPT"


#PiHole Port
#PIHOLE_PORT="81"
#PIHOLE_FTL_PORT="4711"
uci set firewall.PIHOLE=rule
uci set firewall.PIHOLE.dest_port="$all_PIHOLE_port"
uci set firewall.PIHOLE.src="*"
uci set firewall.PIHOLE.name="Allow_PiHole"
uci set firewall.PIHOLE.enabled="0"
uci set firewall.PIHOLE.dest="wan"
uci set firewall.PIHOLE.target="ACCEPT"

#Privoxy Port
#PRIVOXY_PORT="8188"
uci set firewall.PRIVOXY=rule
uci set firewall.PRIVOXY.dest_port="$PRIVOXY_port"
uci set firewall.PRIVOXY.src="*"
uci set firewall.PRIVOXY.name="Allow_PRIVOXY"
uci set firewall.PRIVOXY.enabled="0"
uci set firewall.PRIVOXY.dest="wan"
uci set firewall.PRIVOXY.target="ACCEPT"


#NTOPNG Port
#NTOPNG_PORT="3000"
uci set firewall.NTOPNG=rule
uci set firewall.NTOPNG.dest_port="$NTOPNG_port"
uci set firewall.NTOPNG.src="*"
uci set firewall.NTOPNG.name="Allow_NTOPNG"
uci set firewall.NTOPNG.enabled="0"
uci set firewall.NTOPNG.dest="wan"
uci set firewall.NTOPNG.target="ACCEPT"


#SDNS ports
#DNS_PORT="853"
uci set firewall.SDNS=rule
uci set firewall.SDNS.dest_port="$SDNS_port"
uci set firewall.SDNS.src="*"
uci set firewall.SDNS.name="Allow_SDNS"
uci set firewall.SDNS.enabled="0"
uci set firewall.SDNS.dest="wan"
uci set firewall.SDNS.target="ACCEPT"


#UBOUND_DNS
uci set firewall.UNBOUND=rule
uci set firewall.UNBOUND.dest_port="$DNS_UNBOUND_port"
uci set firewall.UNBOUND.src="*"
uci set firewall.UNBOUND.name="Allow_UNBOUND"
uci set firewall.UNBOUND.enabled="0"
uci set firewall.UNBOUND.dest="wan"
uci set firewall.UNBOUND.target="ACCEPT"


#STUBBY_DNS
uci set firewall.STUBBY=rule
uci set firewall.STUBBY.dest_port="$DNS_STUBBY_port"
uci set firewall.STUBBY.src="*"
uci set firewall.STUBBY.name="Allow_STUBBY"
uci set firewall.STUBBY.enabled="0"
uci set firewall.STUBBY.dest="wan"
uci set firewall.STUBBY.target="ACCEPT"


#DNS_CRYPT
uci set firewall.DNS_CRYPT=rule
uci set firewall.DNS_CRYPT.dest_port="$DNS_CRYPT_port"
uci set firewall.DNS_CRYPT.src="*"
uci set firewall.DNS_CRYPT.name="Allow_DNS_CRYPT"
uci set firewall.DNS_CRYPT.enabled="0"
uci set firewall.DNS_CRYPT.dest="wan"
uci set firewall.DNS_CRYPT.target="ACCEPT"


#TOR_DNS
uci set firewall.TOR_DNS=rule
uci set firewall.TOR_DNS.dest_port="$DNS_TOR_port"
uci set firewall.TOR_DNS.src="*"
uci set firewall.TOR_DNS.name="Allow_TOR_DNS"
uci set firewall.TOR_DNS.enabled="0"
uci set firewall.TOR_DNS.dest="wan"
uci set firewall.TOR_DNS.target="ACCEPT"


#Bittorrent (Ports)
#6881-6999
uci set firewall.BITTORENT=rule
uci set firewall.BITTORENT.dest_port="$Bittorrent_port"
uci set firewall.BITTORENT.src="*"
uci set firewall.BITTORENT.name="Allow_BITTORENT"
uci set firewall.BITTORENT.enabled="0"
uci set firewall.BITTORENT.dest="wan"
uci set firewall.BITTORENT.target="ACCEPT"


#eMule (Ports)
#4662, 4672
uci set firewall.eMule=rule
uci set firewall.eMule.dest_port="$eMule_port"
uci set firewall.eMule.src="*"
uci set firewall.eMule.name="Allow_eMule"
uci set firewall.eMule.enabled="0"
uci set firewall.eMule.dest="wan"
uci set firewall.eMule.target="ACCEPT"

#RemoteAccess (Ports)
#40443-40446
uci set firewall.RemoteAccess=rule
uci set firewall.RemoteAccess.dest_port="$Acces_http_port"
uci set firewall.RemoteAccess.src="*"
uci set firewall.RemoteAccess.name="Allow_RemoteAccess"
uci set firewall.RemoteAccess.enabled="0"
uci set firewall.RemoteAccess.dest="wan"
uci set firewall.RemoteAccess.target="ACCEPT"

#FTP-Server  (Ports)
#20-21
uci set firewall.FTP_Server=rule
uci set firewall.FTP_Server.dest_port="$FTP_port"
uci set firewall.FTP_Server.src="*"
uci set firewall.FTP_Server.name="Allow_FTP"
uci set firewall.FTP_Server.enabled="0"
uci set firewall.FTP_Server.dest="wan"
uci set firewall.FTP_Server.target="ACCEPT"


#Hohe Ziel (Ports)
#TCP 
#10000-33433, 33435-40316, 40318-49316, 49318-54837, 54839-65535
uci set firewall.EXT_HEIGHT_PORT=rule
uci set firewall.EXT_HEIGHT_PORT.dest_port="$EXT_HEIGHT_PORT_port"
uci set firewall.EXT_HEIGHT_PORT.src="*"
uci set firewall.EXT_HEIGHT_PORT.name="Allow_EXT_HEIGHT_PORT"
uci set firewall.EXT_HEIGHT_PORT.proto="tcp"
uci set firewall.EXT_HEIGHT_PORT.dest="wan"
uci set firewall.EXT_HEIGHT_PORT.target="ACCEPT"
uci set firewall.EXT_HEIGHT_PORT.enabled="0"


#UDP
#9000-33433, 33435-40316, 40318-49316, 49318-65535
uci set firewall.EXT_HEIGHT_PORT_UDP=rule
uci set firewall.EXT_HEIGHT_PORT_UDP.dest_port="$EXT_HEIGHT_PORT_UDP_port"
uci set firewall.EXT_HEIGHT_PORT_UDP.src="*"
uci set firewall.EXT_HEIGHT_PORT_UDP.name="Allow_EXT_HEIGHT_PORT_UDP"
uci set firewall.EXT_HEIGHT_PORT_UDP.proto="udp"
uci set firewall.EXT_HEIGHT_PORT_UDP.dest="wan"
uci set firewall.EXT_HEIGHT_PORT_UDP.target="ACCEPT"
uci set firewall.EXT_HEIGHT_PORT_UDP.enabled="0"


#HTTP_s (Ports)
#80, 443, 8080
uci set firewall.HTTP_s=rule
uci set firewall.HTTP_s.dest_port="$HTTP_s_port"
uci set firewall.HTTP_s.src="*"
uci set firewall.HTTP_s.name="Allow_HTTP_s"
uci set firewall.HTTP_s.enabled="0"
uci set firewall.HTTP_s.dest="wan"
uci set firewall.HTTP_s.target="ACCEPT"


#MSRDP _ Alexa Call (Ports)
#3389
uci set firewall.MSRDP_AlexaCall=rule
uci set firewall.MSRDP_AlexaCall.dest_port="$MSRDP_AlexaCall_port"
uci set firewall.MSRDP_AlexaCall.src="*"
uci set firewall.MSRDP_AlexaCall.name="Allow_MSRDP_AlexaCall"
uci set firewall.MSRDP_AlexaCall.enabled="0"
uci set firewall.MSRDP_AlexaCall.dest="wan"
uci set firewall.MSRDP_AlexaCall.target="ACCEPT"


#Skype
#tcp "38562 1000:10000 50000:65000 16000:26000"
#udp "38562 3478:3481 50000:60000"
uci set firewall.SKYPE=rule
uci set firewall.SKYPE.dest_port="$Skype_port"
uci set firewall.SKYPE.src="*"
uci set firewall.SKYPE.name="Allow_Skype"
uci set firewall.SKYPE.proto="tcp"
uci set firewall.SKYPE.enabled="0"
uci set firewall.SKYPE.dest="wan"
uci set firewall.SKYPE.target="ACCEPT"

uci set firewall.SKYPE_UDP=rule
uci set firewall.SKYPE_UDP.dest_port="$Skype_udp_port"
uci set firewall.SKYPE_UDP.src="*"
uci set firewall.SKYPE_UDP.name="Allow_Skype_UDP"
uci set firewall.SKYPE_UDP.proto="udp"
uci set firewall.SKYPE_UDP.enabled="0"
uci set firewall.SKYPE_UDP.dest="wan"
uci set firewall.SKYPE_UDP.target="ACCEPT"


#Torrc (Ports)
#9030, 9040, 9049, 9050, 9053, 9060
uci set firewall.TORRC=rule
uci set firewall.TORRC.dest_port="$TORRC_port"
uci set firewall.TORRC.src="*"
uci set firewall.TORRC.name="Allow_Torrc"
uci set firewall.TORRC.enabled="0"
uci set firewall.TORRC.dest="wan"
uci set firewall.TORRC.target="ACCEPT"



#AVM Mesh
#TCP
#50842
uci set firewall.AVM_Mesh=rule
uci set firewall.AVM_Mesh.dest_port="$AVM_Mesh_port"
uci set firewall.AVM_Mesh.proto="tcp udp"
uci set firewall.AVM_Mesh.src="*"
uci set firewall.AVM_Mesh.enabled="0"
uci set firewall.AVM_Mesh.name="Allow_AVM_Mesh"
uci set firewall.AVM_Mesh.dest="wan"
uci set firewall.AVM_Mesh.target="ACCEPT"


#FRITZ!Box 
#8183
uci set firewall.AVM=rule
uci set firewall.AVM.dest_port="$AVM_port"
uci set firewall.AVM.src="*"
uci set firewall.AVM.name="Allow_AVM"
uci set firewall.AVM.enabled="0"
uci set firewall.AVM.dest="wan"
uci set firewall.AVM.target="ACCEPT"

#Telefonie (SOP, RTP, RTCP)
#7077-7097
uci set firewall.Telephonie=rule
uci set firewall.Telephonie.dest_port="$SIP_RTP_RTCP_port"
uci set firewall.Telephonie.src="*"
uci set firewall.Telephonie.name="Allow_Telephonie_SIP_RTP_RTCP"
uci set firewall.Telephonie.enabled="0"
uci set firewall.Telephonie.dest="wan"
uci set firewall.Telephonie.target="ACCEPT"


#Telefonie (SIP)
#5060
uci set firewall.SIP=rule
uci set firewall.SIP.dest_port="$SIP_port"
uci set firewall.SIP.src="*"
uci set firewall.SIP.name="Allow_SIP_Telephonie"
uci set firewall.SIP.enabled="0"
uci set firewall.SIP.dest="wan"
uci set firewall.SIP.target="ACCEPT"

#Link Local Multicast Name Resolution (LLMNR)
#5357
uci set firewall.LLMNR=rule
uci set firewall.LLMNR.dest_port="$LLMNR_port"
uci set firewall.LLMNR.src="*"
uci set firewall.LLMNR.name="Allow_LLMNR"
uci set firewall.LLMNR.enabled="0"
uci set firewall.LLMNR.dest="wan"
uci set firewall.LLMNR.target="ACCEPT"

#Multicast Domain Name Service (mDNS)
#5353
uci set firewall.mDNS=rule
uci set firewall.mDNS.dest_port="$mDNS_port"
uci set firewall.mDNS.src="*"
uci set firewall.mDNS.name="Allow_mDNS"
uci set firewall.mDNS.enabled="0"
uci set firewall.mDNS.dest="wan"
uci set firewall.mDNS.target="ACCEPT"

#Port Control Protocol (PCP)
#5351
uci set firewall.PCP=rule
uci set firewall.PCP.dest_port="$PCP_port"
uci set firewall.PCP.src="*"
uci set firewall.PCP.name="Allow_PCP"
uci set firewall.PCP.enabled="0"
uci set firewall.PCP.dest="wan"
uci set firewall.PCP.target="ACCEPT"

#Web Services Dynamic Discovery (WS-Discovery)
#UDP
#3702
uci set firewall.WS_Discovery=rule
uci set firewall.WS_Discovery.dest_port="$WS_Discovery_port"
uci set firewall.WS_Discovery.proto="udp tcp"
uci set firewall.WS_Discovery.src="*"
uci set firewall.WS_Discovery.enabled="0"
uci set firewall.WS_Discovery.name="Allow_WS_Discovery"
uci set firewall.WS_Discovery.dest="wan"
uci set firewall.WS_Discovery.target="ACCEPT"

#Simple Service Discovery Protocol (SSDP)
#UDP
#1900
uci set firewall.SSDP=rule
uci set firewall.SSDP.dest_port="$SSDP_port"
uci set firewall.SSDP.proto="udp"
uci set firewall.SSDP.src="*"
uci set firewall.SSDP.enabled="0"
uci set firewall.SSDP.name="Allow_SSDP"
uci set firewall.SSDP.dest="wan"
uci set firewall.SSDP.target="ACCEPT"

#WINS
#UDP
#137
uci set firewall.WINS=rule
uci set firewall.WINS.dest_port="$WINS_port"
uci set firewall.WINS.proto="udp"
uci set firewall.WINS.src="*"
uci set firewall.WINS.enabled="0"
uci set firewall.WINS.name="Allow_WINS"
uci set firewall.WINS.dest="wan"
uci set firewall.WINS.target="ACCEPT"


#NetBIOS
#UDP
#138
uci set firewall.NetBIOS=rule
uci set firewall.NetBIOS.dest_port="$NetBIOS_port"
uci set firewall.NetBIOS.proto="udp"
uci set firewall.NetBIOS.src="*"
uci set firewall.NetBIOS.enabled="0"
uci set firewall.NetBIOS.name="Allow_NetBIOS"
uci set firewall.NetBIOS.dest="wan"
uci set firewall.NetBIOS.target="ACCEPT"


#Syslog
#UDP
#514
uci set firewall.Syslog=rule
uci set firewall.Syslog.dest_port="$Syslog_port"
uci set firewall.Syslog.proto="udp"
uci set firewall.Syslog.src="*"
uci set firewall.Syslog.enabled="0"
uci set firewall.Syslog.name="Allow_Syslog"
uci set firewall.Syslog.dest="wan"
uci set firewall.Syslog.target="ACCEPT"


#Open Directory Proxy (ODProxy)
#TCP
#625
uci set firewall.ODProxy=rule
uci set firewall.ODProxy.dest_port="$ODProxy_port"
uci set firewall.ODProxy.proto="tcp"
uci set firewall.ODProxy.src="*"
uci set firewall.ODProxy.enabled="0"
uci set firewall.ODProxy.name="Allow_SSDP"
uci set firewall.ODProxy.dest="wan"
uci set firewall.ODProxy.target="ACCEPT"


#Unbekannt
#1012
 
#VPN (IPSec IKE)
#UDP
#4500
uci set firewall.VPN=rule
uci set firewall.VPN.dest_port="$VPN_port"
uci set firewall.VPN.src="*"
uci set firewall.VPN.name="Allow_VPN"
uci set firewall.VPN.enabled="0"
uci set firewall.VPN.dest="wan"
uci set firewall.VPN.target="ACCEPT"

#SMB_CISC-Freigabe
#445, 139, 138, 137
uci set firewall.SMB=rule
uci set firewall.SMB.dest_port="$SMB_port"
uci set firewall.SMB.src="*"
uci set firewall.SMB.name="Allow_SMB_Share"
uci set firewall.SMB.enabled="0"
uci set firewall.SMB.dest="wan"
uci set firewall.SMB.target="ACCEPT"

#AFP-Freigabe
#548
uci set firewall.AFP=rule
uci set firewall.AFP.dest_port="$AFP_port"
uci set firewall.AFP.src="*"
uci set firewall.AFP.proto="tcp"
uci set firewall.AFP.name="Allow_AFP_Share"
uci set firewall.AFP.enabled="0"
uci set firewall.AFP.dest="wan"
uci set firewall.AFP.target="ACCEPT"

#NFS
#"2049"
uci set firewall.NFS=rule
uci set firewall.NFS.dest_port="$NFS_port"
uci set firewall.NFS.src="*"
uci set firewall.NFS.name="Allow_NFS_SHARE"
uci set firewall.NFS.enabled="0"
uci set firewall.NFS.dest="wan"
uci set firewall.NFS.proto="tcp"
uci set firewall.NFS.target="ACCEPT"

#NTP
#UDP
#123
uci set firewall.NTP=rule
uci set firewall.NTP.dest_port="$NTP_port"
uci set firewall.NTP.proto="udp"
uci set firewall.NTP.src="*"
uci set firewall.NTP.enabled="0"
uci set firewall.NTP.name="Allow_NTP"
uci set firewall.NTP.dest="wan"
uci set firewall.NTP.target="ACCEPT"

#Printer_LPR_IPP
#"9100 515 631"
uci set firewall.PRINTER=rule
uci set firewall.PRINTER.dest_port="$Printer_port"
uci set firewall.PRINTER.src="*"
uci set firewall.PRINTER.name="Allow_Printer_LPR"
uci set firewall.PRINTER.enabled="0"
uci set firewall.PRINTER.dest="wan"
uci set firewall.PRINTER.proto="tcp"
uci set firewall.PRINTER.target="ACCEPT"


#DHCP
#UDP
#67
uci set firewall.DHCP=rule
uci set firewall.DHCP.dest_port="$DHCP_port"
uci set firewall.DHCP.proto="udp"
uci set firewall.DHCP.name="Allow_DHCP"
uci set firewall.DHCP.src="*"
uci set firewall.DHCP.dest="wan"
uci set firewall.DHCP.target="ACCEPT"
uci set firewall.DHCP.enabled="0"


#UPNP
#49000
uci set firewall.UPNP=rule
uci set firewall.UPNP.dest_port="$UPMP_port"
uci set firewall.UPNP.src="*"
uci set firewall.UPNP.name="Allow_UPNP"
uci set firewall.UPNP.dest="wan"
uci set firewall.UPNP.target="ACCEPT"
uci set firewall.UPNP.enabled="0"


#-----------------------------------------------------------------------------

uci set firewall.Block_DNS_Cloudflare=rule
uci set firewall.Block_DNS_Cloudflare.dest_port="$all_DNS_port"
uci set firewall.Block_DNS_Cloudflare.src="*"
uci set firewall.Block_DNS_Cloudflare.name="Block_Cloudflare_local_DNS"
uci set firewall.Block_DNS_Cloudflare.dest="*"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare1_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare2_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare3_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare4_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare5_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare6_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare7_SVR" 
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare8_SVR" 
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare9_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare10_SVR" 
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare11_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare12_SVR"  
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare13_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare14_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare15_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare16_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare17_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare18_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare19_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare20_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare21_SVR" 
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare22_SVR"
uci add_list firewall.Block_DNS_Cloudflare.dest_ip="$DNS_Cloudflare23_SVR" 
uci set firewall.Block_DNS_Cloudflare.enabled="0" 
uci set firewall.Block_DNS_Cloudflare.proto="tcp udp"
uci set firewall.Block_DNS_Cloudflare.target="REJECT"
uci commit && reload_config >/dev/null



#WebClient (Port)
#21, 22, 25, 53, 80, 110, 123, 443, 853, 5353, 9030, 9040, 9049, 9050, 9053, 9060, 50275, 54715, 54789, 51465, 56343, 56534, 57687, 60870
uci set firewall.Block_WebClient=rule
uci set firewall.Block_WebClient.dest_port="$WebClient_port"
uci set firewall.Block_WebClient.src="*"
uci set firewall.Block_WebClient.name="Block_WebClient"
uci set firewall.Block_WebClient.enabled="0"
uci set firewall.Block_WebClient.dest="wan"
uci set firewall.Block_WebClient.target="REJECT"


#Office_Client (Port)
# 21 22 23 25 53 67 80 110 123 139 138 137 443 445 515 548 631 853 2049 5353 9030 9040 9049 9050 9053 9060 9100 50275 54715 54789 51465 56343 56534 57687 60870
uci set firewall.Block_OfficeClient=rule
uci set firewall.Block_OfficeClient.src='INET'
uci set firewall.Block_OfficeClient.name='Block_OfficeClient'
uci set firewall.Block_OfficeClient.dest='SERVER'
uci set firewall.Block_OfficeClient.proto='udp tcp'
uci set firewall.Block_OfficeClient.target='REJECT'
uci set firewall.Block_OfficeClient.dest_port="$OfficeClient_port"
#1-20 24 26-52 54-66 68-79 81-109 111-122 124-136 140-442 444 446-514 516-547 549-630 632-852 854-2048 2050-5352 5354-8442 8444-9029 9031-9039 9041-9048 9051 9052 9054-9059 9061-9099 9101-40442 40446-50274 50276-51464 51465-54714 54716-54788 54790-56342 56344-56533 56535-57686 57688-60869 60871-65535'
uci set firewall.Block_OfficeClient.enabled='0'

uci set firewall.Block_OfficeWebClient=rule
uci set firewall.Block_OfficeWebClient.src='INET'
uci set firewall.Block_OfficeWebClient.name='Block_OfficeClient_WEB'
uci set firewall.Block_OfficeWebClient.dest='wan'
uci set firewall.Block_OfficeWebClient.proto='udp tcp'
uci set firewall.Block_OfficeWebClient.target='REJECT'
uci set firewall.Block_OfficeWebClient.dest_port="$OfficeWebClient_port"
uci set firewall.Block_OfficeWebClient.enabled='0'

#Alexa (Port)
#"67:68 8080 40317 49317 33434 123 54838 55443 46053 1000:10000 50000:65000 16000:26000"
#udp 4070 5353 40317 49317 33434 50000:60000 3478:3481
uci set firewall.Block_Amazon_Alexa=rule
uci set firewall.Block_Amazon_Alexa.name='Block_AmazonAlexa'
uci set firewall.Block_Amazon_Alexa.proto='tcp'
uci set firewall.Block_Amazon_Alexa.dest='wan'
uci set firewall.Block_Amazon_Alexa.target='REJECT'
uci set firewall.Block_Amazon_Alexa.src='VOICE'
uci set firewall.Block_Amazon_Alexa.dest_port="$Amazon_Alexa_port"
uci set firewall.Block_Amazon_Alexa.enabled='0'
uci set firewall.Block_Amazon_Alexa_UDP=rule
uci set firewall.Block_Amazon_Alexa_UDP.name='Block_AmazonAlexa_UDP'
uci set firewall.Block_Amazon_Alexa_UDP.proto='udp'
uci set firewall.Block_Amazon_Alexa_UDP.dest='wan'
uci set firewall.Block_Amazon_Alexa_UDP.target='REJECT'
uci set firewall.Block_Amazon_Alexa_UDP.src='VOICE'
uci set firewall.Block_Amazon_Alexa_UDP.dest_port="$Amazon_Alexa_UDP_port"
uci set firewall.Block_Amazon_Alexa_UDP.enabled='0'

#Google Assistent (Port)
#uci set firewall.Block_Google_assistent=rule

#Telnet (Port)
#23
uci set firewall.Block_TELNET=rule
uci set firewall.Block_TELNET.dest_port="$TELNET_port"
uci set firewall.Block_TELNET.src="*"
uci set firewall.Block_TELNET.name="Block_Telnet"
uci set firewall.Block_TELNET.enabled="0"
uci set firewall.Block_TELNET.dest="wan"
uci set firewall.Block_TELNET.target="REJECT"


#SSH (Port)
#22
uci set firewall.Block_SSH=rule
uci set firewall.Block_SSH.dest_port="$SSH_port"
uci set firewall.Block_SSH.src="*"
uci set firewall.Block_SSH.name="Block_SSH"
uci set firewall.Block_SSH.dest="wan"
uci set firewall.Block_SSH.enabled="0"
uci set firewall.Block_SSH.dest="wan"
uci set firewall.Block_SSH.target="REJECT"


#NTP
#123
uci set firewall.Block_NTP=rule
uci set firewall.Block_NTP.dest_port="$NTP_port"
uci set firewall.Block_NTP.src="*"
uci set firewall.Block_NTP.name="Block_NTP"
uci set firewall.Block_NTP.enabled="0"
uci set firewall.Block_NTP.dest="wan"
uci set firewall.Block_NTP.target="REJECT"

#smtp
#"25 465 587"
uci set firewall.Block_SMTP=rule
uci set firewall.Block_SMTP.dest_port="$SMTP_port"
uci set firewall.Block_SMTP.src="*"
uci set firewall.Block_SMTP.name="Block_SMTP"
uci set firewall.Block_SMTP.enabled="0"
uci set firewall.Block_SMTP.dest="wan"
uci set firewall.Block_SMTP.target="REJECT"


#POP3 Port
#POP3_PORT="110 995"
uci set firewall.Block_POP3=rule
uci set firewall.Block_POP3.dest_port="$POP3_port"
uci set firewall.Block_POP3.src="*"
uci set firewall.Block_POP3.name="Block_POP3"
uci set firewall.Block_POP3.enabled="0"
uci set firewall.Block_POP3.dest="wan"
uci set firewall.Block_POP3.target="REJECT"


#IMAP4 Port
#IMAP_PORT="143 993 626"
uci set firewall.Block_IMAP4=rule
uci set firewall.Block_IMAP4.dest_port="$IMAP_port"
uci set firewall.Block_IMAP4.src="*"
uci set firewall.Block_IMAP4.name="Block_IMAP4"
uci set firewall.Block_IMAP4.enabled="0"
uci set firewall.Block_IMAP4.dest="wan"
uci set firewall.Block_IMAP4.target="REJECT"


#KERBEROS
#"88 749"
uci set firewall.Block_KERBEROS=rule
uci set firewall.Block_KERBEROS.dest_port="$KERBEROS_port"
uci set firewall.Block_KERBEROS.src="*"
uci set firewall.Block_KERBEROS.name="Block_KERBEROS"
uci set firewall.Block_KERBEROS.enabled="0"
uci set firewall.Block_KERBEROS.dest="wan"
uci set firewall.Block_KERBEROS.proto="tcp"
uci set firewall.Block_KERBEROS.target="REJECT"


#Password_Server
#"106"
uci set firewall.Block_PASSWDSRV=rule
uci set firewall.Block_PASSWDSRV.dest_port="$PASSWDSRV_port"
uci set firewall.Block_PASSWDSRV.src="*"
uci set firewall.Block_PASSWDSRV.name="Block_PASWD_SRV"
uci set firewall.Block_PASSWDSRV.enabled="0"
uci set firewall.Block_PASSWDSRV.dest="wan"
uci set firewall.Block_PASSWDSRV.proto="tcp"
uci set firewall.Block_PASSWDSRV.target="REJECT"

#LDAP
#"389 636"
uci set firewall.Block_LDAP=rule
uci set firewall.Block_LDAP.dest_port="$LDAP_port"
uci set firewall.Block_LDAP.src="*"
uci set firewall.Block_LDAP.name="Block_LDAP"
uci set firewall.Block_LDAP.enabled="0"
uci set firewall.Block_LDAP.dest="wan"
uci set firewall.Block_LDAP.proto="tcp"
uci set firewall.Block_LDAP.target="REJECT"


#RPC
#"111"
uci set firewall.Block_RPC=rule
uci set firewall.Block_RPC.dest_port="$RPC_port"
uci set firewall.Block_RPC.src="*"
uci set firewall.Block_RPC.name="Block_RPC"
uci set firewall.Block_RPC.enabled="0"
uci set firewall.Block_RPC.dest="wan"
uci set firewall.Block_RPC.proto="tcp"
uci set firewall.Block_RPC.target="REJECT"

#NNTP
#"119"
uci set firewall.Block_NNTP=rule
uci set firewall.Block_NNTP.dest_port="$NNTP_port"
uci set firewall.Block_NNTP.src="*"
uci set firewall.Block_NNTP.name="Block_NNTP"
uci set firewall.Block_NNTP.enabled="0"
uci set firewall.Block_NNTP.dest="wan"
uci set firewall.Block_NNTP.proto="tcp"
uci set firewall.Block_NNTP.target="REJECT"

#Real Time Streaming Protocol (RTSP)
#"554"
uci set firewall.Block_RTSP=rule
uci set firewall.Block_RTSP.dest_port="$RTSP_port"
uci set firewall.Block_RTSP.src="*"
uci set firewall.Block_RTSP.name="Block_RTSP"
uci set firewall.Block_RTSP.enabled="0"
uci set firewall.Block_RTSP.dest="wan"
uci set firewall.Block_RTSP.target="REJECT"


#PiHole Port
#PIHOLE_PORT="81"
#PIHOLE_FTL_PORT="4711"
uci set firewall.Block_PIHOLE=rule
uci set firewall.Block_PIHOLE.dest_port="$all_PIHOLE_port"
uci set firewall.Block_PIHOLE.src="*"
uci set firewall.Block_PIHOLE.name="Block_PiHole"
uci set firewall.Block_PIHOLE.enabled="0"
uci set firewall.Block_PIHOLE.dest="wan"
uci set firewall.Block_PIHOLE.target="REJECT"

#Privoxy Port
#PRIVOXY_PORT="8188"
uci set firewall.Block_PRIVOXY=rule
uci set firewall.Block_PRIVOXY.dest_port="$PRIVOXY_port"
uci set firewall.Block_PRIVOXY.src="*"
uci set firewall.Block_PRIVOXY.name="Block_PRIVOXY"
uci set firewall.Block_PRIVOXY.enabled="0"
uci set firewall.Block_PRIVOXY.dest="wan"
uci set firewall.Block_PRIVOXY.target="REJECT"


#NTOPNG Port
#NTOPNG_PORT="3000"
uci set firewall.Block_NTOPNG=rule
uci set firewall.Block_NTOPNG.dest_port="$NTOPNG_port"
uci set firewall.Block_NTOPNG.src="*"
uci set firewall.Block_NTOPNG.name="Block_NTOPNG"
uci set firewall.Block_NTOPNG.enabled="0"
uci set firewall.Block_NTOPNG.dest="wan"
uci set firewall.Block_NTOPNG.target="REJECT"


#SDNS ports
#DNS_PORT="853"
uci set firewall.Block_SDNS=rule
uci set firewall.Block_SDNS.dest_port="$SDNS_port"
uci set firewall.Block_SDNS.src="*"
uci set firewall.Block_SDNS.name="Block_SDNS"
uci set firewall.Block_SDNS.enabled="0"
uci set firewall.Block_SDNS.dest="wan"
uci set firewall.Block_SDNS.target="REJECT"


#UBOUND_DNS
uci set firewall.Block_UNBOUND=rule
uci set firewall.Block_UNBOUND.dest_port="$DNS_UNBOUND_port"
uci set firewall.Block_UNBOUND.src="*"
uci set firewall.Block_UNBOUND.name="Block_UNBOUND"
uci set firewall.Block_UNBOUND.enabled="0"
uci set firewall.Block_UNBOUND.dest="wan"
uci set firewall.Block_UNBOUND.target="REJECT"


#STUBBY_DNS
uci set firewall.Block_STUBBY=rule
uci set firewall.Block_STUBBY.dest_port="$DNS_STUBBY_port"
uci set firewall.Block_STUBBY.src="*"
uci set firewall.Block_STUBBY.name="Block_STUBBY"
uci set firewall.Block_STUBBY.enabled="0"
uci set firewall.Block_STUBBY.dest="wan"
uci set firewall.Block_STUBBY.target="REJECT"


#DNS_CRYPT
uci set firewall.Block_DNS_CRYPT=rule
uci set firewall.Block_DNS_CRYPT.dest_port="$DNS_CRYPT_port"
uci set firewall.Block_DNS_CRYPT.src="*"
uci set firewall.Block_DNS_CRYPT.name="Block_DNS_CRYPT"
uci set firewall.Block_DNS_CRYPT.enabled="0"
uci set firewall.Block_DNS_CRYPT.dest="wan"
uci set firewall.Block_DNS_CRYPT.target="REJECT"


#TOR_DNS
uci set firewall.Block_TOR_DNS=rule
uci set firewall.Block_TOR_DNS.dest_port="$DNS_TOR_port"
uci set firewall.Block_TOR_DNS.src="*"
uci set firewall.Block_TOR_DNS.name="Block_TOR_DNS"
uci set firewall.Block_TOR_DNS.enabled="0"
uci set firewall.Block_TOR_DNS.dest="wan"
uci set firewall.Block_TOR_DNS.target="REJECT"


#Bittorrent (Ports)
#6881-6999
uci set firewall.Block_BITTORENT=rule
uci set firewall.Block_BITTORENT.dest_port="$Bittorrent_port"
uci set firewall.Block_BITTORENT.src="*"
uci set firewall.Block_BITTORENT.name="Block_BITTORENT"
uci set firewall.Block_BITTORENT.enabled="0"
uci set firewall.Block_BITTORENT.dest="wan"
uci set firewall.Block_BITTORENT.target="REJECT"


#eMule (Ports)
#4662, 4672
uci set firewall.Block_eMule=rule
uci set firewall.Block_eMule.dest_port="$eMule_port"
uci set firewall.Block_eMule.src="*"
uci set firewall.Block_eMule.name="Block_eMule"
uci set firewall.Block_eMule.enabled="0"
uci set firewall.Block_eMule.dest="wan"
uci set firewall.Block_eMule.target="REJECT"

#RemoteAccess (Ports)
#40443-40446
uci set firewall.Block_RemoteAccess=rule
uci set firewall.Block_RemoteAccess.dest_port="$Acces_http_port"
uci set firewall.Block_RemoteAccess.src="*"
uci set firewall.Block_RemoteAccess.name="Block_RemoteAccess"
uci set firewall.Block_RemoteAccess.enabled="0"
uci set firewall.Block_RemoteAccess.dest="wan"
uci set firewall.Block_RemoteAccess.target="REJECT"

#FTP-Server  (Ports)
#20-21
uci set firewall.Block_FTP_Server=rule
uci set firewall.Block_FTP_Server.dest_port="$FTP_port"
uci set firewall.Block_FTP_Server.src="*"
uci set firewall.Block_FTP_Server.name="Block_FTP"
uci set firewall.Block_FTP_Server.enabled="0"
uci set firewall.Block_FTP_Server.dest="wan"
uci set firewall.Block_FTP_Server.target="REJECT"


#Hohe Ziel (Ports)
#TCP 
#10000-33433, 33435-40316, 40318-49316, 49318-54837, 54839-65535
uci set firewall.Block_EXT_HEIGHT_PORT=rule
uci set firewall.Block_EXT_HEIGHT_PORT.dest_port="$EXT_HEIGHT_PORT_port"
uci set firewall.Block_EXT_HEIGHT_PORT.src="*"
uci set firewall.Block_EXT_HEIGHT_PORT.name="Block_EXT_HEIGHT_PORT"
uci set firewall.Block_EXT_HEIGHT_PORT.proto="tcp"
uci set firewall.Block_EXT_HEIGHT_PORT.dest="wan"
uci set firewall.Block_EXT_HEIGHT_PORT.target="REJECT"
uci set firewall.Block_EXT_HEIGHT_PORT.enabled="0"


#UDP
#9000-33433, 33435-40316, 40318-49316, 49318-65535
uci set firewall.Block_EXT_HEIGHT_PORT_UDP=rule
uci set firewall.Block_EXT_HEIGHT_PORT_UDP.dest_port="$EXT_HEIGHT_PORT_UDP_port"
uci set firewall.Block_EXT_HEIGHT_PORT_UDP.src="*"
uci set firewall.Block_EXT_HEIGHT_PORT_UDP.name="Block_EXT_HEIGHT_PORT_UDP"
uci set firewall.Block_EXT_HEIGHT_PORT_UDP.proto="udp"
uci set firewall.Block_EXT_HEIGHT_PORT_UDP.dest="wan"
uci set firewall.Block_EXT_HEIGHT_PORT_UDP.target="REJECT"
uci set firewall.Block_EXT_HEIGHT_PORT_UDP.enabled="0"


#HTTP_s (Ports)
#80, 443, 8080
uci set firewall.Block_HTTP_s=rule
uci set firewall.Block_HTTP_s.dest_port="$HTTP_s_port"
uci set firewall.Block_HTTP_s.src="*"
uci set firewall.Block_HTTP_s.name="Block_HTTP_s"
uci set firewall.Block_HTTP_s.enabled="0"
uci set firewall.Block_HTTP_s.dest="wan"
uci set firewall.Block_HTTP_s.target="REJECT"


#MSRDP _ Alexa Call (Ports)
#3389
uci set firewall.Block_MSRDP_AlexaCall=rule
uci set firewall.Block_MSRDP_AlexaCall.dest_port="$MSRDP_AlexaCall_port"
uci set firewall.Block_MSRDP_AlexaCall.src="*"
uci set firewall.Block_MSRDP_AlexaCall.name="Block_MSRDP_AlexaCall"
uci set firewall.Block_MSRDP_AlexaCall.enabled="0"
uci set firewall.Block_MSRDP_AlexaCall.dest="wan"
uci set firewall.Block_MSRDP_AlexaCall.target="REJECT"


#Skype
#tcp "38562 1000:10000 50000:65000 16000:26000"
#udp "38562 3478:3481 50000:60000"
uci set firewall.Block_SKYPE=rule
uci set firewall.Block_SKYPE.dest_port="$Skype_port"
uci set firewall.Block_SKYPE.src="*"
uci set firewall.Block_SKYPE.name="Block_Skype"
uci set firewall.Block_SKYPE.proto="tcp"
uci set firewall.Block_SKYPE.enabled="0"
uci set firewall.Block_SKYPE.dest="wan"
uci set firewall.Block_SKYPE.target="REJECT"

uci set firewall.Block_SKYPE_UDP=rule
uci set firewall.Block_SKYPE_UDP.dest_port="$Skype_udp_port"
uci set firewall.Block_SKYPE_UDP.src="*"
uci set firewall.Block_SKYPE_UDP.name="Block_Skype_UDP"
uci set firewall.Block_SKYPE_UDP.proto="udp"
uci set firewall.Block_SKYPE_UDP.enabled="0"
uci set firewall.Block_SKYPE_UDP.dest="wan"
uci set firewall.Block_SKYPE_UDP.target="REJECT"


#Torrc (Ports)
#9030, 9040, 9049, 9050, 9053, 9060
uci set firewall.Block_TORRC=rule
uci set firewall.Block_TORRC.dest_port="$TORRC_port"
uci set firewall.Block_TORRC.src="*"
uci set firewall.Block_TORRC.name="Block_Torrc"
uci set firewall.Block_TORRC.enabled="0"
uci set firewall.Block_TORRC.dest="wan"
uci set firewall.Block_TORRC.target="REJECT"



#AVM Mesh
#TCP
#50842
uci set firewall.Block_AVM_Mesh=rule
uci set firewall.Block_AVM_Mesh.dest_port="$AVM_Mesh_port"
uci set firewall.Block_AVM_Mesh.proto="tcp udp"
uci set firewall.Block_AVM_Mesh.src="*"
uci set firewall.Block_AVM_Mesh.enabled="0"
uci set firewall.Block_AVM_Mesh.name="Block_AVM_Mesh"
uci set firewall.Block_AVM_Mesh.dest="wan"
uci set firewall.Block_AVM_Mesh.target="REJECT"


#FRITZ!Box 
#8183
uci set firewall.Block_AVM=rule
uci set firewall.Block_AVM.dest_port="$AVM_port"
uci set firewall.Block_AVM.src="*"
uci set firewall.Block_AVM.name="Block_AVM"
uci set firewall.Block_AVM.enabled="0"
uci set firewall.Block_AVM.dest="wan"
uci set firewall.Block_AVM.target="REJECT"

#Telefonie (SOP, RTP, RTCP)
#7077-7097
uci set firewall.Block_Telephonie=rule
uci set firewall.Block_Telephonie.dest_port="$SIP_RTP_RTCP_port"
uci set firewall.Block_Telephonie.src="*"
uci set firewall.Block_Telephonie.name="Block_Telephonie_SIP_RTP_RTCP"
uci set firewall.Block_Telephonie.enabled="0"
uci set firewall.Block_Telephonie.dest="wan"
uci set firewall.Block_Telephonie.target="REJECT"


#Telefonie (SIP)
#5060
uci set firewall.Block_SIP=rule
uci set firewall.Block_SIP.dest_port="$SIP_port"
uci set firewall.Block_SIP.src="*"
uci set firewall.Block_SIP.name="Block_SIP_Telephonie"
uci set firewall.Block_SIP.enabled="0"
uci set firewall.Block_SIP.dest="wan"
uci set firewall.Block_SIP.target="REJECT"

#Link Local Multicast Name Resolution (LLMNR)
#5357
uci set firewall.Block_LLMNR=rule
uci set firewall.Block_LLMNR.dest_port="$LLMNR_port"
uci set firewall.Block_LLMNR.src="*"
uci set firewall.Block_LLMNR.name="Block_LLMNR"
uci set firewall.Block_LLMNR.enabled="0"
uci set firewall.Block_LLMNR.dest="wan"
uci set firewall.Block_LLMNR.target="REJECT"

#Multicast Domain Name Service (mDNS)
#5353
uci set firewall.Block_mDNS=rule
uci set firewall.Block_mDNS.dest_port="$mDNS_port"
uci set firewall.Block_mDNS.src="*"
uci set firewall.Block_mDNS.name="Block_mDNS"
uci set firewall.Block_mDNS.enabled="0"
uci set firewall.Block_mDNS.dest="wan"
uci set firewall.Block_mDNS.target="REJECT"

#Port Control Protocol (PCP)
#5351
uci set firewall.Block_PCP=rule
uci set firewall.Block_PCP.dest_port="$PCP_port"
uci set firewall.Block_PCP.src="*"
uci set firewall.Block_PCP.name="Block_PCP"
uci set firewall.Block_PCP.enabled="0"
uci set firewall.Block_PCP.dest="wan"
uci set firewall.Block_PCP.target="REJECT"

#Web Services Dynamic Discovery (WS-Discovery)
#UDP
#3702
uci set firewall.Block_WS_Discovery=rule
uci set firewall.Block_WS_Discovery.dest_port="$WS_Discovery_port"
uci set firewall.Block_WS_Discovery.proto="udp tcp"
uci set firewall.Block_WS_Discovery.src="*"
uci set firewall.Block_WS_Discovery.enabled="0"
uci set firewall.Block_WS_Discovery.name="Block_WS_Discovery"
uci set firewall.Block_WS_Discovery.dest="wan"
uci set firewall.Block_WS_Discovery.target="REJECT"

#Simple Service Discovery Protocol (SSDP)
#UDP
#1900
uci set firewall.Block_SSDP=rule
uci set firewall.Block_SSDP.dest_port="$SSDP_port"
uci set firewall.Block_SSDP.proto="udp"
uci set firewall.Block_SSDP.src="*"
uci set firewall.Block_SSDP.enabled="0"
uci set firewall.Block_SSDP.name="Block_SSDP"
uci set firewall.Block_SSDP.dest="wan"
uci set firewall.Block_SSDP.target="REJECT"

#WINS
#UDP
#137
uci set firewall.Block_WINS=rule
uci set firewall.Block_WINS.dest_port="$WINS_port"
uci set firewall.Block_WINS.proto="udp"
uci set firewall.Block_WINS.src="*"
uci set firewall.Block_WINS.enabled="0"
uci set firewall.Block_WINS.name="Block_WINS"
uci set firewall.Block_WINS.dest="wan"
uci set firewall.Block_WINS.target="REJECT"


#NetBIOS
#UDP
#138
uci set firewall.Block_NetBIOS=rule
uci set firewall.Block_NetBIOS.dest_port="$NetBIOS_port"
uci set firewall.Block_NetBIOS.proto="udp"
uci set firewall.Block_NetBIOS.src="*"
uci set firewall.Block_NetBIOS.enabled="0"
uci set firewall.Block_NetBIOS.name="Block_NetBIOS"
uci set firewall.Block_NetBIOS.dest="wan"
uci set firewall.Block_NetBIOS.target="REJECT"


#Syslog
#UDP
#514
uci set firewall.Block_Syslog=rule
uci set firewall.Block_Syslog.dest_port="$Syslog_port"
uci set firewall.Block_Syslog.proto="udp"
uci set firewall.Block_Syslog.src="*"
uci set firewall.Block_Syslog.enabled="0"
uci set firewall.Block_Syslog.name="Block_Syslog"
uci set firewall.Block_Syslog.dest="wan"
uci set firewall.Block_Syslog.target="REJECT"


#Open Directory Proxy (ODProxy)
#TCP
#625
uci set firewall.Block_ODProxy=rule
uci set firewall.Block_ODProxy.dest_port="$ODProxy_port"
uci set firewall.Block_ODProxy.proto="tcp"
uci set firewall.Block_ODProxy.src="*"
uci set firewall.Block_ODProxy.enabled="0"
uci set firewall.Block_ODProxy.name="Block_SSDP"
uci set firewall.Block_ODProxy.dest="wan"
uci set firewall.Block_ODProxy.target="REJECT"


#Unbekannt
#1012
 
#VPN (IPSec IKE)
#UDP
#4500
uci set firewall.Block_VPN=rule
uci set firewall.Block_VPN.dest_port="$VPN_port"
uci set firewall.Block_VPN.src="*"
uci set firewall.Block_VPN.name="Block_VPN"
uci set firewall.Block_VPN.enabled="0"
uci set firewall.Block_VPN.dest="wan"
uci set firewall.Block_VPN.target="REJECT"

#SMB_CISC-Freigabe
#445, 139, 138, 137
uci set firewall.Block_SMB=rule
uci set firewall.Block_SMB.dest_port="$SMB_port"
uci set firewall.Block_SMB.src="*"
uci set firewall.Block_SMB.name="Block_SMB_Share"
uci set firewall.Block_SMB.enabled="0"
uci set firewall.Block_SMB.dest="wan"
uci set firewall.Block_SMB.target="REJECT"

#AFP-Freigabe
#548
uci set firewall.Block_AFP=rule
uci set firewall.Block_AFP.dest_port="$AFP_port"
uci set firewall.Block_AFP.src="*"
uci set firewall.Block_AFP.proto="tcp"
uci set firewall.Block_AFP.name="Block_AFP_Share"
uci set firewall.Block_AFP.enabled="0"
uci set firewall.Block_AFP.dest="wan"
uci set firewall.Block_AFP.target="REJECT"

#NFS
#"2049"
uci set firewall.Block_NFS=rule
uci set firewall.Block_NFS.dest_port="$NFS_port"
uci set firewall.Block_NFS.src="*"
uci set firewall.Block_NFS.name="Block_NFS_SHARE"
uci set firewall.Block_NFS.enabled="0"
uci set firewall.Block_NFS.dest="wan"
uci set firewall.Block_NFS.proto="tcp"
uci set firewall.Block_NFS.target="REJECT"

#NTP
#UDP
#123
uci set firewall.Block_NTP=rule
uci set firewall.Block_NTP.dest_port="$NTP_port"
uci set firewall.Block_NTP.proto="udp"
uci set firewall.Block_NTP.src="*"
uci set firewall.Block_NTP.enabled="0"
uci set firewall.Block_NTP.name="Block_NTP"
uci set firewall.Block_NTP.dest="wan"
uci set firewall.Block_NTP.target="REJECT"

#Printer_LPR_IPP
#"9100 515 631"
uci set firewall.Block_PRINTER=rule
uci set firewall.Block_PRINTER.dest_port="$Printer_port"
uci set firewall.Block_PRINTER.src="*"
uci set firewall.Block_PRINTER.name="Block_Printer_LPR"
uci set firewall.Block_PRINTER.enabled="0"
uci set firewall.Block_PRINTER.dest="wan"
uci set firewall.Block_PRINTER.proto="tcp"
uci set firewall.Block_PRINTER.target="REJECT"


#DHCP
#UDP
#67
uci set firewall.Block_DHCP=rule
uci set firewall.Block_DHCP.dest_port="$DHCP_port"
uci set firewall.Block_DHCP.proto="udp"
uci set firewall.Block_DHCP.name="Block_DHCP"
uci set firewall.Block_DHCP.src="*"
uci set firewall.Block_DHCP.dest="wan"
uci set firewall.Block_DHCP.target="REJECT"
uci set firewall.Block_DHCP.enabled="0"


#UPNP
#49000
uci set firewall.Block_UPNP=rule
uci set firewall.Block_UPNP.dest_port="$UPMP_port"
uci set firewall.Block_UPNP.src="*"
uci set firewall.Block_UPNP.name="Block_UPNP"
uci set firewall.Block_UPNP.dest="wan"
uci set firewall.Block_UPNP.target="REJECT"
uci set firewall.Block_UPNP.enabled="0"


#-----------------------------------------------------------------------------


uci set firewall.Allow_only_DNS_Cloudflare=rule
uci set firewall.Allow_only_DNS_Cloudflare.dest_port="$all_DNS_port"
uci set firewall.Allow_only_DNS_Cloudflare.src="*"
uci set firewall.Allow_only_DNS_Cloudflare.name="Allow_only_Cloudflare_local_DNS"
uci set firewall.Allow_only_DNS_Cloudflare.dest="*"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare1_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare2_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare3_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare4_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare5_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare6_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare7_SVR" 
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare8_SVR" 
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare9_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare10_SVR" 
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare11_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare12_SVR"  
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare13_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare14_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare15_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare16_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare17_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare18_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare19_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare20_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare21_SVR" 
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare22_SVR"
uci add_list firewall.Allow_only_DNS_Cloudflare.dest_ip="!$DNS_Cloudflare23_SVR" 
uci set firewall.Allow_only_DNS_Cloudflare.enabled="0" 
uci set firewall.Allow_only_DNS_Cloudflare.proto="tcp udp"
uci set firewall.Allow_only_DNS_Cloudflare.target="REJECT"
uci commit && reload_config >/dev/null



#WebClient (Port)
#21, 22, 25, 53, 80, 110, 123, 443, 853, 5353, 9030, 9040, 9049, 9050, 9053, 9060, 50275, 54715, 54789, 51465, 56343, 56534, 57687, 60870
uci set firewall.Allow_only_WebClient=rule
uci set firewall.Allow_only_WebClient.dest_port="$all_other_WebClient_port"
uci set firewall.Allow_only_WebClient.src="*"
uci set firewall.Allow_only_WebClient.name="Allow_only_WebClient"
uci set firewall.Allow_only_WebClient.enabled="0"
uci set firewall.Allow_only_WebClient.dest="wan"
uci set firewall.Allow_only_WebClient.target="REJECT"


#Office_Client (Port)
# 21 22 23 25 53 67 80 110 123 139 138 137 443 445 515 548 631 853 2049 5353 9030 9040 9049 9050 9053 9060 9100 50275 54715 54789 51465 56343 56534 57687 60870
uci set firewall.Allow_only_OfficeClient=rule
uci set firewall.Allow_only_OfficeClient.src='INET'
uci set firewall.Allow_only_OfficeClient.name='Allow_only_OfficeClient'
uci set firewall.Allow_only_OfficeClient.dest='SERVER'
uci set firewall.Allow_only_OfficeClient.proto='udp tcp'
uci set firewall.Allow_only_OfficeClient.target='REJECT'
uci set firewall.Allow_only_OfficeClient.dest_port="$all_other_OfficeClient_port"
#1-20 24 26-52 54-66 68-79 81-109 111-122 124-136 140-442 444 446-514 516-547 549-630 632-852 854-2048 2050-5352 5354-8442 8444-9029 9031-9039 9041-9048 9051 9052 9054-9059 9061-9099 9101-40442 40446-50274 50276-51464 51465-54714 54716-54788 54790-56342 56344-56533 56535-57686 57688-60869 60871-65535'
uci set firewall.Allow_only_OfficeClient.enabled='1'

uci set firewall.Allow_only_OfficeWebClient=rule
uci set firewall.Allow_only_OfficeWebClient.src='INET'
uci set firewall.Allow_only_OfficeWebClient.name='Allow_only_OfficeClient_WEB'
uci set firewall.Allow_only_OfficeWebClient.dest='wan'
uci set firewall.Allow_only_OfficeWebClient.proto='udp tcp'
uci set firewall.Allow_only_OfficeWebClient.target='REJECT'
uci set firewall.Allow_only_OfficeWebClient.dest_port="$all_other_OfficeWebClient_port"
uci set firewall.Allow_only_OfficeWebClient.enabled='1'

#Alexa (Port)
#"67:68 8080 40317 49317 33434 123 54838 55443 46053 1000:10000 50000:65000 16000:26000"
#udp 4070 5353 40317 49317 33434 50000:60000 3478:3481
uci set firewall.Allow_only_Amazon_Alexa=rule
uci set firewall.Allow_only_Amazon_Alexa.name='Allow_only_AmazonAlexa'
uci set firewall.Allow_only_Amazon_Alexa.proto='tcp'
uci set firewall.Allow_only_Amazon_Alexa.dest='wan'
uci set firewall.Allow_only_Amazon_Alexa.target='REJECT'
uci set firewall.Allow_only_Amazon_Alexa.src='VOICE'
uci set firewall.Allow_only_Amazon_Alexa.dest_port="$all_other_Amazon_Alexa_port"
uci set firewall.Allow_only_Amazon_Alexa.enabled='1'

uci set firewall.Allow_only_Amazon_Alexa_UDP=rule
uci set firewall.Allow_only_Amazon_Alexa_UDP.name='Allow_only_AmazonAlexa_UDP'
uci set firewall.Allow_only_Amazon_Alexa_UDP.proto='udp'
uci set firewall.Allow_only_Amazon_Alexa_UDP.dest='wan'
uci set firewall.Allow_only_Amazon_Alexa_UDP.target='REJECT'
uci set firewall.Allow_only_Amazon_Alexa_UDP.src='VOICE'
uci set firewall.Allow_only_Amazon_Alexa_UDP.dest_port="$all_other_Amazon_Alexa_UDP_port"
uci set firewall.Allow_only_Amazon_Alexa_UDP.enabled='1'

#Google Assistent (Port)
#uci set firewall.Allow_only_Google_assistent=rule

#Telnet (Port)
#23
uci set firewall.Allow_only_TELNET=rule
uci set firewall.Allow_only_TELNET.dest_port="$all_other_TELNET_port"
uci set firewall.Allow_only_TELNET.src="*"
uci set firewall.Allow_only_TELNET.name="Allow_only_Telnet"
uci set firewall.Allow_only_TELNET.enabled="0"
uci set firewall.Allow_only_TELNET.dest="wan"
uci set firewall.Allow_only_TELNET.target="REJECT"


#SSH (Port)
#22
uci set firewall.Allow_only_SSH=rule
uci set firewall.Allow_only_SSH.dest_port="$all_other_SSH_port"
uci set firewall.Allow_only_SSH.src="*"
uci set firewall.Allow_only_SSH.name="Allow_only_SSH"
uci set firewall.Allow_only_SSH.dest="wan"
uci set firewall.Allow_only_SSH.enabled="0"
uci set firewall.Allow_only_SSH.dest="wan"
uci set firewall.Allow_only_SSH.target="REJECT"


#NTP
#123
uci set firewall.Allow_only_NTP=rule
uci set firewall.Allow_only_NTP.dest_port="$all_other_NTP_port"
uci set firewall.Allow_only_NTP.src="*"
uci set firewall.Allow_only_NTP.name="Allow_only_NTP"
uci set firewall.Allow_only_NTP.enabled="0"
uci set firewall.Allow_only_NTP.dest="wan"
uci set firewall.Allow_only_NTP.target="REJECT"

#smtp
#"25 465 587"
uci set firewall.Allow_only_SMTP=rule
uci set firewall.Allow_only_SMTP.dest_port="$all_other_SMTP_port"
uci set firewall.Allow_only_SMTP.src="*"
uci set firewall.Allow_only_SMTP.name="Allow_only_SMTP"
uci set firewall.Allow_only_SMTP.enabled="0"
uci set firewall.Allow_only_SMTP.dest="wan"
uci set firewall.Allow_only_SMTP.target="REJECT"


#POP3 Port
#POP3_PORT="110 995"
uci set firewall.Allow_only_POP3=rule
uci set firewall.Allow_only_POP3.dest_port="$all_other_POP3_port"
uci set firewall.Allow_only_POP3.src="*"
uci set firewall.Allow_only_POP3.name="Allow_only_POP3"
uci set firewall.Allow_only_POP3.enabled="0"
uci set firewall.Allow_only_POP3.dest="wan"
uci set firewall.Allow_only_POP3.target="REJECT"


#IMAP4 Port
#IMAP_PORT="143 993 626"
uci set firewall.Allow_only_IMAP4=rule
uci set firewall.Allow_only_IMAP4.dest_port="$all_other_IMAP_port"
uci set firewall.Allow_only_IMAP4.src="*"
uci set firewall.Allow_only_IMAP4.name="Allow_only_IMAP4"
uci set firewall.Allow_only_IMAP4.enabled="0"
uci set firewall.Allow_only_IMAP4.dest="wan"
uci set firewall.Allow_only_IMAP4.target="REJECT"


#KERBEROS
#"88 749"
uci set firewall.Allow_only_KERBEROS=rule
uci set firewall.Allow_only_KERBEROS.dest_port="$all_other_KERBEROS_port"
uci set firewall.Allow_only_KERBEROS.src="*"
uci set firewall.Allow_only_KERBEROS.name="Allow_only_KERBEROS"
uci set firewall.Allow_only_KERBEROS.enabled="0"
uci set firewall.Allow_only_KERBEROS.dest="wan"
uci set firewall.Allow_only_KERBEROS.proto="tcp"
uci set firewall.Allow_only_KERBEROS.target="REJECT"


#Password_Server
#"106"
uci set firewall.Allow_only_PASSWDSRV=rule
uci set firewall.Allow_only_PASSWDSRV.dest_port="$all_other_PASSWDSRV_port"
uci set firewall.Allow_only_PASSWDSRV.src="*"
uci set firewall.Allow_only_PASSWDSRV.name="Allow_only_PASWD_SRV"
uci set firewall.Allow_only_PASSWDSRV.enabled="0"
uci set firewall.Allow_only_PASSWDSRV.dest="wan"
uci set firewall.Allow_only_PASSWDSRV.proto="tcp"
uci set firewall.Allow_only_PASSWDSRV.target="REJECT"

#LDAP
#"389 636"
uci set firewall.Allow_only_LDAP=rule
uci set firewall.Allow_only_LDAP.dest_port="$all_other_LDAP_port"
uci set firewall.Allow_only_LDAP.src="*"
uci set firewall.Allow_only_LDAP.name="Allow_only_LDAP"
uci set firewall.Allow_only_LDAP.enabled="0"
uci set firewall.Allow_only_LDAP.dest="wan"
uci set firewall.Allow_only_LDAP.proto="tcp"
uci set firewall.Allow_only_LDAP.target="REJECT"


#RPC
#"111"
uci set firewall.Allow_only_RPC=rule
uci set firewall.Allow_only_RPC.dest_port="$all_other_RPC_port"
uci set firewall.Allow_only_RPC.src="*"
uci set firewall.Allow_only_RPC.name="Allow_only_RPC"
uci set firewall.Allow_only_RPC.enabled="0"
uci set firewall.Allow_only_RPC.dest="wan"
uci set firewall.Allow_only_RPC.proto="tcp"
uci set firewall.Allow_only_RPC.target="REJECT"

#NNTP
#"119"
uci set firewall.Allow_only_NNTP=rule
uci set firewall.Allow_only_NNTP.dest_port="$all_other_NNTP_port"
uci set firewall.Allow_only_NNTP.src="*"
uci set firewall.Allow_only_NNTP.name="Allow_only_NNTP"
uci set firewall.Allow_only_NNTP.enabled="0"
uci set firewall.Allow_only_NNTP.dest="wan"
uci set firewall.Allow_only_NNTP.proto="tcp"
uci set firewall.Allow_only_NNTP.target="REJECT"

#Real Time Streaming Protocol (RTSP)
#"554"
uci set firewall.Allow_only_RTSP=rule
uci set firewall.Allow_only_RTSP.dest_port="$all_other_RTSP_port"
uci set firewall.Allow_only_RTSP.src="*"
uci set firewall.Allow_only_RTSP.name="Allow_only_RTSP"
uci set firewall.Allow_only_RTSP.enabled="0"
uci set firewall.Allow_only_RTSP.dest="wan"
uci set firewall.Allow_only_RTSP.target="REJECT"


#PiHole Port
#PIHOLE_PORT="81"
#PIHOLE_FTL_PORT="4711"
uci set firewall.Allow_only_PIHOLE=rule
uci set firewall.Allow_only_PIHOLE.dest_port="$all_other_all_PIHOLE_port"
uci set firewall.Allow_only_PIHOLE.src="*"
uci set firewall.Allow_only_PIHOLE.name="Allow_only_PiHole"
uci set firewall.Allow_only_PIHOLE.enabled="0"
uci set firewall.Allow_only_PIHOLE.dest="wan"
uci set firewall.Allow_only_PIHOLE.target="REJECT"

#Privoxy Port
#PRIVOXY_PORT="8188"
uci set firewall.Allow_only_PRIVOXY=rule
uci set firewall.Allow_only_PRIVOXY.dest_port="$all_other_PRIVOXY_port"
uci set firewall.Allow_only_PRIVOXY.src="*"
uci set firewall.Allow_only_PRIVOXY.name="Allow_only_PRIVOXY"
uci set firewall.Allow_only_PRIVOXY.enabled="0"
uci set firewall.Allow_only_PRIVOXY.dest="wan"
uci set firewall.Allow_only_PRIVOXY.target="REJECT"


#NTOPNG Port
#NTOPNG_PORT="3000"
uci set firewall.Allow_only_NTOPNG=rule
uci set firewall.Allow_only_NTOPNG.dest_port="$all_other_NTOPNG_port"
uci set firewall.Allow_only_NTOPNG.src="*"
uci set firewall.Allow_only_NTOPNG.name="Allow_only_NTOPNG"
uci set firewall.Allow_only_NTOPNG.enabled="0"
uci set firewall.Allow_only_NTOPNG.dest="wan"
uci set firewall.Allow_only_NTOPNG.target="REJECT"


#SDNS ports
#DNS_PORT="853"
uci set firewall.Allow_only_SDNS=rule
uci set firewall.Allow_only_SDNS.dest_port="$all_other_SDNS_port"
uci set firewall.Allow_only_SDNS.src="*"
uci set firewall.Allow_only_SDNS.name="Allow_only_SDNS"
uci set firewall.Allow_only_SDNS.enabled="0"
uci set firewall.Allow_only_SDNS.dest="wan"
uci set firewall.Allow_only_SDNS.target="REJECT"


#UBOUND_DNS
uci set firewall.Allow_only_UNBOUND=rule
uci set firewall.Allow_only_UNBOUND.dest_port="$all_other_DNS_UNBOUND_port"
uci set firewall.Allow_only_UNBOUND.src="*"
uci set firewall.Allow_only_UNBOUND.name="Allow_only_UNBOUND"
uci set firewall.Allow_only_UNBOUND.enabled="0"
uci set firewall.Allow_only_UNBOUND.dest="wan"
uci set firewall.Allow_only_UNBOUND.target="REJECT"


#STUBBY_DNS
uci set firewall.Allow_only_STUBBY=rule
uci set firewall.Allow_only_STUBBY.dest_port="$all_other_DNS_STUBBY_port"
uci set firewall.Allow_only_STUBBY.src="*"
uci set firewall.Allow_only_STUBBY.name="Allow_only_STUBBY"
uci set firewall.Allow_only_STUBBY.enabled="0"
uci set firewall.Allow_only_STUBBY.dest="wan"
uci set firewall.Allow_only_STUBBY.target="REJECT"


#DNS_CRYPT
uci set firewall.Allow_only_DNS_CRYPT=rule
uci set firewall.Allow_only_DNS_CRYPT.dest_port="$all_other_DNS_CRYPT_port"
uci set firewall.Allow_only_DNS_CRYPT.src="*"
uci set firewall.Allow_only_DNS_CRYPT.name="Allow_only_DNS_CRYPT"
uci set firewall.Allow_only_DNS_CRYPT.enabled="0"
uci set firewall.Allow_only_DNS_CRYPT.dest="wan"
uci set firewall.Allow_only_DNS_CRYPT.target="REJECT"


#TOR_DNS
uci set firewall.Allow_only_TOR_DNS=rule
uci set firewall.Allow_only_TOR_DNS.dest_port="$all_other_DNS_TOR_port"
uci set firewall.Allow_only_TOR_DNS.src="*"
uci set firewall.Allow_only_TOR_DNS.name="Allow_only_TOR_DNS"
uci set firewall.Allow_only_TOR_DNS.enabled="0"
uci set firewall.Allow_only_TOR_DNS.dest="wan"
uci set firewall.Allow_only_TOR_DNS.target="REJECT"


#Bittorrent (Ports)
#6881-6999
uci set firewall.Allow_only_BITTORENT=rule
uci set firewall.Allow_only_BITTORENT.dest_port="$all_other_Bittorrent_port"
uci set firewall.Allow_only_BITTORENT.src="*"
uci set firewall.Allow_only_BITTORENT.name="Allow_only_BITTORENT"
uci set firewall.Allow_only_BITTORENT.enabled="0"
uci set firewall.Allow_only_BITTORENT.dest="wan"
uci set firewall.Allow_only_BITTORENT.target="REJECT"


#eMule (Ports)
#4662, 4672
uci set firewall.Allow_only_eMule=rule
uci set firewall.Allow_only_eMule.dest_port="$all_other_eMule_port"
uci set firewall.Allow_only_eMule.src="*"
uci set firewall.Allow_only_eMule.name="Allow_only_eMule"
uci set firewall.Allow_only_eMule.enabled="0"
uci set firewall.Allow_only_eMule.dest="wan"
uci set firewall.Allow_only_eMule.target="REJECT"

#RemoteAccess (Ports)
#40443-40446
uci set firewall.Allow_only_RemoteAccess=rule
uci set firewall.Allow_only_RemoteAccess.dest_port="$all_other_Acces_http_port"
uci set firewall.Allow_only_RemoteAccess.src="*"
uci set firewall.Allow_only_RemoteAccess.name="Allow_only_RemoteAccess"
uci set firewall.Allow_only_RemoteAccess.enabled="0"
uci set firewall.Allow_only_RemoteAccess.dest="wan"
uci set firewall.Allow_only_RemoteAccess.target="REJECT"

#FTP-Server  (Ports)
#20-21
uci set firewall.Allow_only_FTP_Server=rule
uci set firewall.Allow_only_FTP_Server.dest_port="$all_other_FTP_port"
uci set firewall.Allow_only_FTP_Server.src="*"
uci set firewall.Allow_only_FTP_Server.name="Allow_only_FTP"
uci set firewall.Allow_only_FTP_Server.enabled="0"
uci set firewall.Allow_only_FTP_Server.dest="wan"
uci set firewall.Allow_only_FTP_Server.target="REJECT"


#Hohe Ziel (Ports)
#TCP 
#10000-33433, 33435-40316, 40318-49316, 49318-54837, 54839-65535
uci set firewall.Allow_only_EXT_HEIGHT_PORT=rule
uci set firewall.Allow_only_EXT_HEIGHT_PORT.dest_port="$all_other_EXT_HEIGHT_PORT_port"
uci set firewall.Allow_only_EXT_HEIGHT_PORT.src="*"
uci set firewall.Allow_only_EXT_HEIGHT_PORT.name="Allow_only_EXT_HEIGHT_PORT"
uci set firewall.Allow_only_EXT_HEIGHT_PORT.proto="tcp"
uci set firewall.Allow_only_EXT_HEIGHT_PORT.dest="wan"
uci set firewall.Allow_only_EXT_HEIGHT_PORT.target="REJECT"
uci set firewall.Allow_only_EXT_HEIGHT_PORT.enabled="0"


#UDP
#9000-33433, 33435-40316, 40318-49316, 49318-65535
uci set firewall.Allow_only_EXT_HEIGHT_PORT_UDP=rule
uci set firewall.Allow_only_EXT_HEIGHT_PORT_UDP.dest_port="$all_other_EXT_HEIGHT_PORT_UDP_port"
uci set firewall.Allow_only_EXT_HEIGHT_PORT_UDP.src="*"
uci set firewall.Allow_only_EXT_HEIGHT_PORT_UDP.name="Allow_only_EXT_HEIGHT_PORT_UDP"
uci set firewall.Allow_only_EXT_HEIGHT_PORT_UDP.proto="udp"
uci set firewall.Allow_only_EXT_HEIGHT_PORT_UDP.dest="wan"
uci set firewall.Allow_only_EXT_HEIGHT_PORT_UDP.target="REJECT"
uci set firewall.Allow_only_EXT_HEIGHT_PORT_UDP.enabled="0"


#HTTP_s (Ports)
#80, 443, 8080
uci set firewall.Allow_only_HTTP_s=rule
uci set firewall.Allow_only_HTTP_s.dest_port="$all_other_HTTP_s_port"
uci set firewall.Allow_only_HTTP_s.src="*"
uci set firewall.Allow_only_HTTP_s.name="Allow_only_HTTP_s"
uci set firewall.Allow_only_HTTP_s.enabled="0"
uci set firewall.Allow_only_HTTP_s.dest="wan"
uci set firewall.Allow_only_HTTP_s.target="REJECT"


#MSRDP _ Alexa Call (Ports)
#3389
uci set firewall.Allow_only_MSRDP_AlexaCall=rule
uci set firewall.Allow_only_MSRDP_AlexaCall.dest_port="$all_other_MSRDP_AlexaCall_port"
uci set firewall.Allow_only_MSRDP_AlexaCall.src="*"
uci set firewall.Allow_only_MSRDP_AlexaCall.name="Allow_only_MSRDP_AlexaCall"
uci set firewall.Allow_only_MSRDP_AlexaCall.enabled="0"
uci set firewall.Allow_only_MSRDP_AlexaCall.dest="wan"
uci set firewall.Allow_only_MSRDP_AlexaCall.target="REJECT"


#Skype
#tcp "38562 1000:10000 50000:65000 16000:26000"
#udp "38562 3478:3481 50000:60000"
uci set firewall.Allow_only_SKYPE=rule
uci set firewall.Allow_only_SKYPE.dest_port="$all_other_Skype_port"
uci set firewall.Allow_only_SKYPE.src="*"
uci set firewall.Allow_only_SKYPE.name="Allow_only_Skype"
uci set firewall.Allow_only_SKYPE.proto="tcp"
uci set firewall.Allow_only_SKYPE.enabled="0"
uci set firewall.Allow_only_SKYPE.dest="wan"
uci set firewall.Allow_only_SKYPE.target="REJECT"

uci set firewall.Allow_only_SKYPE_UDP=rule
uci set firewall.Allow_only_SKYPE_UDP.dest_port="$all_other_Skype_udp_port"
uci set firewall.Allow_only_SKYPE_UDP.src="*"
uci set firewall.Allow_only_SKYPE_UDP.name="Allow_only_Skype_UDP"
uci set firewall.Allow_only_SKYPE_UDP.proto="udp"
uci set firewall.Allow_only_SKYPE_UDP.enabled="0"
uci set firewall.Allow_only_SKYPE_UDP.dest="wan"
uci set firewall.Allow_only_SKYPE_UDP.target="REJECT"


#Torrc (Ports)
#9030, 9040, 9049, 9050, 9053, 9060
uci set firewall.Allow_only_TORRC=rule
uci set firewall.Allow_only_TORRC.dest_port="$all_other_TORRC_port"
uci set firewall.Allow_only_TORRC.src="*"
uci set firewall.Allow_only_TORRC.name="Allow_only_Torrc"
uci set firewall.Allow_only_TORRC.enabled="0"
uci set firewall.Allow_only_TORRC.dest="wan"
uci set firewall.Allow_only_TORRC.target="REJECT"



#AVM Mesh
#TCP
#50842
uci set firewall.Allow_only_AVM_Mesh=rule
uci set firewall.Allow_only_AVM_Mesh.dest_port="$all_other_AVM_Mesh_port"
uci set firewall.Allow_only_AVM_Mesh.proto="tcp udp"
uci set firewall.Allow_only_AVM_Mesh.src="*"
uci set firewall.Allow_only_AVM_Mesh.enabled="0"
uci set firewall.Allow_only_AVM_Mesh.name="Allow_only_AVM_Mesh"
uci set firewall.Allow_only_AVM_Mesh.dest="wan"
uci set firewall.Allow_only_AVM_Mesh.target="REJECT"


#FRITZ!Box 
#8183
uci set firewall.Allow_only_AVM=rule
uci set firewall.Allow_only_AVM.dest_port="$all_other_AVM_port"
uci set firewall.Allow_only_AVM.src="*"
uci set firewall.Allow_only_AVM.name="Allow_only_AVM"
uci set firewall.Allow_only_AVM.enabled="0"
uci set firewall.Allow_only_AVM.dest="wan"
uci set firewall.Allow_only_AVM.target="REJECT"

#Telefonie (SOP, RTP, RTCP)
#7077-7097
uci set firewall.Allow_only_Telephonie=rule
uci set firewall.Allow_only_Telephonie.dest_port="$all_other_SIP_RTP_RTCP_port"
uci set firewall.Allow_only_Telephonie.src="*"
uci set firewall.Allow_only_Telephonie.name="Allow_only_Telephonie_SIP_RTP_RTCP"
uci set firewall.Allow_only_Telephonie.enabled="0"
uci set firewall.Allow_only_Telephonie.dest="wan"
uci set firewall.Allow_only_Telephonie.target="REJECT"


#Telefonie (SIP)
#5060
uci set firewall.Allow_only_SIP=rule
uci set firewall.Allow_only_SIP.dest_port="$all_other_SIP_port"
uci set firewall.Allow_only_SIP.src="*"
uci set firewall.Allow_only_SIP.name="Allow_only_SIP_Telephonie"
uci set firewall.Allow_only_SIP.enabled="0"
uci set firewall.Allow_only_SIP.dest="wan"
uci set firewall.Allow_only_SIP.target="REJECT"

#Link Local Multicast Name Resolution (LLMNR)
#5357
uci set firewall.Allow_only_LLMNR=rule
uci set firewall.Allow_only_LLMNR.dest_port="$all_other_LLMNR_port"
uci set firewall.Allow_only_LLMNR.src="*"
uci set firewall.Allow_only_LLMNR.name="Allow_only_LLMNR"
uci set firewall.Allow_only_LLMNR.enabled="0"
uci set firewall.Allow_only_LLMNR.dest="wan"
uci set firewall.Allow_only_LLMNR.target="REJECT"

#Multicast Domain Name Service (mDNS)
#5353
uci set firewall.Allow_only_mDNS=rule
uci set firewall.Allow_only_mDNS.dest_port="$all_other_mDNS_port"
uci set firewall.Allow_only_mDNS.src="*"
uci set firewall.Allow_only_mDNS.name="Allow_only_mDNS"
uci set firewall.Allow_only_mDNS.enabled="0"
uci set firewall.Allow_only_mDNS.dest="wan"
uci set firewall.Allow_only_mDNS.target="REJECT"

#Port Control Protocol (PCP)
#5351
uci set firewall.Allow_only_PCP=rule
uci set firewall.Allow_only_PCP.dest_port="$all_other_PCP_port"
uci set firewall.Allow_only_PCP.src="*"
uci set firewall.Allow_only_PCP.name="Allow_only_PCP"
uci set firewall.Allow_only_PCP.enabled="0"
uci set firewall.Allow_only_PCP.dest="wan"
uci set firewall.Allow_only_PCP.target="REJECT"

#Web Services Dynamic Discovery (WS-Discovery)
#UDP
#3702
uci set firewall.Allow_only_WS_Discovery=rule
uci set firewall.Allow_only_WS_Discovery.dest_port="$all_other_WS_Discovery_port"
uci set firewall.Allow_only_WS_Discovery.proto="udp tcp"
uci set firewall.Allow_only_WS_Discovery.src="*"
uci set firewall.Allow_only_WS_Discovery.enabled="0"
uci set firewall.Allow_only_WS_Discovery.name="Allow_only_WS_Discovery"
uci set firewall.Allow_only_WS_Discovery.dest="wan"
uci set firewall.Allow_only_WS_Discovery.target="REJECT"

#Simple Service Discovery Protocol (SSDP)
#UDP
#1900
uci set firewall.Allow_only_SSDP=rule
uci set firewall.Allow_only_SSDP.dest_port="$all_other_SSDP_port"
uci set firewall.Allow_only_SSDP.proto="udp"
uci set firewall.Allow_only_SSDP.src="*"
uci set firewall.Allow_only_SSDP.enabled="0"
uci set firewall.Allow_only_SSDP.name="Allow_only_SSDP"
uci set firewall.Allow_only_SSDP.dest="wan"
uci set firewall.Allow_only_SSDP.target="REJECT"

#WINS
#UDP
#137
uci set firewall.Allow_only_WINS=rule
uci set firewall.Allow_only_WINS.dest_port="$all_other_WINS_port"
uci set firewall.Allow_only_WINS.proto="udp"
uci set firewall.Allow_only_WINS.src="*"
uci set firewall.Allow_only_WINS.enabled="0"
uci set firewall.Allow_only_WINS.name="Allow_only_WINS"
uci set firewall.Allow_only_WINS.dest="wan"
uci set firewall.Allow_only_WINS.target="REJECT"


#NetBIOS
#UDP
#138
uci set firewall.Allow_only_NetBIOS=rule
uci set firewall.Allow_only_NetBIOS.dest_port="$all_other_NetBIOS_port"
uci set firewall.Allow_only_NetBIOS.proto="udp"
uci set firewall.Allow_only_NetBIOS.src="*"
uci set firewall.Allow_only_NetBIOS.enabled="0"
uci set firewall.Allow_only_NetBIOS.name="Allow_only_NetBIOS"
uci set firewall.Allow_only_NetBIOS.dest="wan"
uci set firewall.Allow_only_NetBIOS.target="REJECT"


#Syslog
#UDP
#514
uci set firewall.Allow_only_Syslog=rule
uci set firewall.Allow_only_Syslog.dest_port="$all_other_Syslog_port"
uci set firewall.Allow_only_Syslog.proto="udp"
uci set firewall.Allow_only_Syslog.src="*"
uci set firewall.Allow_only_Syslog.enabled="0"
uci set firewall.Allow_only_Syslog.name="Allow_only_Syslog"
uci set firewall.Allow_only_Syslog.dest="wan"
uci set firewall.Allow_only_Syslog.target="REJECT"


#Open Directory Proxy (ODProxy)
#TCP
#625
uci set firewall.Allow_only_ODProxy=rule
uci set firewall.Allow_only_ODProxy.dest_port="$all_other_ODProxy_port"
uci set firewall.Allow_only_ODProxy.proto="tcp"
uci set firewall.Allow_only_ODProxy.src="*"
uci set firewall.Allow_only_ODProxy.enabled="0"
uci set firewall.Allow_only_ODProxy.name="Allow_only_SSDP"
uci set firewall.Allow_only_ODProxy.dest="wan"
uci set firewall.Allow_only_ODProxy.target="REJECT"


#Unbekannt
#1012
 
#VPN (IPSec IKE)
#UDP
#4500
uci set firewall.Allow_only_VPN=rule
uci set firewall.Allow_only_VPN.dest_port="$all_other_VPN_port"
uci set firewall.Allow_only_VPN.src="*"
uci set firewall.Allow_only_VPN.name="Allow_only_VPN"
uci set firewall.Allow_only_VPN.enabled="0"
uci set firewall.Allow_only_VPN.dest="wan"
uci set firewall.Allow_only_VPN.target="REJECT"

#SMB_CISC-Freigabe
#445, 139, 138, 137
uci set firewall.Allow_only_SMB=rule
uci set firewall.Allow_only_SMB.dest_port="$all_other_SMB_port"
uci set firewall.Allow_only_SMB.src="*"
uci set firewall.Allow_only_SMB.name="Allow_only_SMB_Share"
uci set firewall.Allow_only_SMB.enabled="0"
uci set firewall.Allow_only_SMB.dest="wan"
uci set firewall.Allow_only_SMB.target="REJECT"

#AFP-Freigabe
#548
uci set firewall.Allow_only_AFP=rule
uci set firewall.Allow_only_AFP.dest_port="$all_other_AFP_port"
uci set firewall.Allow_only_AFP.src="*"
uci set firewall.Allow_only_AFP.proto="tcp"
uci set firewall.Allow_only_AFP.name="Allow_only_AFP_Share"
uci set firewall.Allow_only_AFP.enabled="0"
uci set firewall.Allow_only_AFP.dest="wan"
uci set firewall.Allow_only_AFP.target="REJECT"

#NFS
#"2049"
uci set firewall.Allow_only_NFS=rule
uci set firewall.Allow_only_NFS.dest_port="$all_other_NFS_port"
uci set firewall.Allow_only_NFS.src="*"
uci set firewall.Allow_only_NFS.name="Allow_only_NFS_SHARE"
uci set firewall.Allow_only_NFS.enabled="0"
uci set firewall.Allow_only_NFS.dest="wan"
uci set firewall.Allow_only_NFS.proto="tcp"
uci set firewall.Allow_only_NFS.target="REJECT"

#NTP
#UDP
#123
uci set firewall.Allow_only_NTP=rule
uci set firewall.Allow_only_NTP.dest_port="$all_other_NTP_port"
uci set firewall.Allow_only_NTP.proto="udp"
uci set firewall.Allow_only_NTP.src="*"
uci set firewall.Allow_only_NTP.enabled="0"
uci set firewall.Allow_only_NTP.name="Allow_only_NTP"
uci set firewall.Allow_only_NTP.dest="wan"
uci set firewall.Allow_only_NTP.target="REJECT"

#Printer_LPR_IPP
#"9100 515 631"
uci set firewall.Allow_only_PRINTER=rule
uci set firewall.Allow_only_PRINTER.dest_port="$all_other_Printer_port"
uci set firewall.Allow_only_PRINTER.src="*"
uci set firewall.Allow_only_PRINTER.name="Allow_only_Printer_LPR"
uci set firewall.Allow_only_PRINTER.enabled="0"
uci set firewall.Allow_only_PRINTER.dest="wan"
uci set firewall.Allow_only_PRINTER.proto="tcp"
uci set firewall.Allow_only_PRINTER.target="REJECT"


#DHCP
#UDP
#67
uci set firewall.Allow_only_DHCP=rule
uci set firewall.Allow_only_DHCP.dest_port="$all_other_DHCP_port"
uci set firewall.Allow_only_DHCP.proto="udp"
uci set firewall.Allow_only_DHCP.name="Allow_only_DHCP"
uci set firewall.Allow_only_DHCP.src="*"
uci set firewall.Allow_only_DHCP.dest="wan"
uci set firewall.Allow_only_DHCP.target="REJECT"
uci set firewall.Allow_only_DHCP.enabled="0"


#UPNP
#49000
uci set firewall.Allow_only_UPNP=rule
uci set firewall.Allow_only_UPNP.dest_port="$all_other_UPMP_port"
uci set firewall.Allow_only_UPNP.src="*"
uci set firewall.Allow_only_UPNP.name="Allow_only_UPNP"
uci set firewall.Allow_only_UPNP.dest="wan"
uci set firewall.Allow_only_UPNP.target="REJECT"
uci set firewall.Allow_only_UPNP.enabled="0"


uci set firewall.Allow_Only_WebClient1=rule
uci set firewall.Allow_Only_WebClient1.src='CONTROL'
uci set firewall.Allow_Only_WebClient1.dest='wan'
uci set firewall.Allow_Only_WebClient1.name='Allow_only_WebClient_CONTROL'
uci set firewall.Allow_Only_WebClient1.target='REJECT'
uci set firewall.Allow_Only_WebClient1.dest_port="$all_other_OfficeWebClient_port"


uci set firewall.Allow_Only_WebClient2=rule
uci set firewall.Allow_Only_WebClient2.src='HCONTROL'
uci set firewall.Allow_Only_WebClient2.dest='wan'
uci set firewall.Allow_Only_WebClient2.name='Allow_only_WebClient_HCONTROL'
uci set firewall.Allow_Only_WebClient2.target='REJECT'
uci set firewall.Allow_Only_WebClient2.dest_port="$all_other_OfficeWebClient_port"

uci set firewall.Allow_Only_WebClient3=rule
uci set firewall.Allow_Only_WebClient3.src='SERVER'
uci set firewall.Allow_Only_WebClient3.dest='wan'
uci set firewall.Allow_Only_WebClient3.name='Allow_only_WebClient_SERVER'
uci set firewall.Allow_Only_WebClient3.target='REJECT'
uci set firewall.Allow_Only_WebClient3.dest_port="$all_other_OfficeWebClient_port"


uci set firewall.Allow_Only_WebClient4=rule
uci set firewall.Allow_Only_WebClient4.src='GUEST'
uci set firewall.Allow_Only_WebClient4.dest='wan'
uci set firewall.Allow_Only_WebClient4.name='Allow_only_WebClient_GUEST'
uci set firewall.Allow_Only_WebClient4.target='REJECT'
uci set firewall.Allow_Only_WebClient4.dest_port="$all_other_OfficeWebClient_port"


uci set firewall.Allow_Only_WebClient5=rule
uci set firewall.Allow_Only_WebClient5.src='ENTERTAIN'
uci set firewall.Allow_Only_WebClient5.dest='wan'
uci set firewall.Allow_Only_WebClient5.name='Allow_only_WebClient_ENTERTAIN'
uci set firewall.Allow_Only_WebClient5.target='REJECT'
uci set firewall.Allow_Only_WebClient5.dest_port="$all_other_OfficeWebClient_port"


#Hohe Ziel (Ports)
#TCP 
#10000-33433, 33435-40316, 40318-49316, 49318-54837, 54839-65535
uci set firewall.Block_all_other_EXT_HEIGHT_PORT=rule
uci set firewall.Block_all_other_EXT_HEIGHT_PORT.dest_port="$all_other_EXT_HEIGHT_PORT_port"
uci set firewall.Block_all_other_EXT_HEIGHT_PORT.src="*"
uci set firewall.Block_all_other_EXT_HEIGHT_PORT.name="Block_all_other_EXT_HEIGHT_PORT"
uci set firewall.Block_all_other_EXT_HEIGHT_PORT.proto="tcp"
uci set firewall.Block_all_other_EXT_HEIGHT_PORT.dest="wan"
uci set firewall.Block_all_other_EXT_HEIGHT_PORT.target="REJECT"
uci set firewall.Block_all_other_EXT_HEIGHT_PORT.enabled="0"


#UDP
#9000-33433, 33435-40316, 40318-49316, 49318-65535
uci set firewall.Block_all_other_EXT_HEIGHT_PORT_UDP=rule
uci set firewall.Block_all_other_EXT_HEIGHT_PORT_UDP.dest_port="$all_other_EXT_HEIGHT_PORT_UDP_port"
uci set firewall.Block_all_other_EXT_HEIGHT_PORT_UDP.src="*"
uci set firewall.Block_all_other_EXT_HEIGHT_PORT_UDP.name="Block_all_other_EXT_HEIGHT_PORT_UDP"
uci set firewall.Block_all_other_EXT_HEIGHT_PORT_UDP.proto="udp"
uci set firewall.Block_all_other_EXT_HEIGHT_PORT_UDP.dest="wan"
uci set firewall.Block_all_other_EXT_HEIGHT_PORT_UDP.target="REJECT"
uci set firewall.Block_all_other_EXT_HEIGHT_PORT_UDP.enabled="0"



#Sonstige Protokolle
#ESP, GRE, ICMP, igmp
uci set firewall.otherProt=rule
uci set firewall.otherProt.proto="$all_other_porto"
uci set firewall.otherProt.src="*"
uci set firewall.otherProt.name="Block_all_Other_Protocolls"
uci set firewall.otherProt.dest="wan"
uci set firewall.otherProt.target="REJECT"
uci set firewall.otherProt.enabled="1"

uci set firewall.blockIncoming=rule
uci set firewall.blockIncoming.proto="$all_proto"
uci set firewall.blockIncoming.src="wan"
uci set firewall.blockIncoming.name="Block_Incoming"
uci set firewall.blockIncoming.dest="*"
uci set firewall.blockIncoming.target="REJECT"
uci set firewall.blockIncoming.enabled="1"



# Configure IP sets
uci -q delete firewall.filter
uci set firewall.filter="ipset"
uci set firewall.filter.name="filter"
uci set firewall.filter.family="ipv4"
uci set firewall.filter.storage="hash"
uci set firewall.filter.match="ip"

uci -q delete firewall.filter6
uci set firewall.filter6="ipset"
uci set firewall.filter6.name="filter6"
uci set firewall.filter6.family="ipv6"
uci set firewall.filter6.storage="hash"
uci set firewall.filter6.match="ip"
 
# Filter LAN client traffic with IP sets
uci -q delete firewall.filter_fwd
uci set firewall.filter_fwd="rule"
uci set firewall.filter_fwd.name="Filter_IPset_DNS_Forward"
uci set firewall.filter_fwd.src="INET"
uci set firewall.filter_fwd.dest="wan"
uci set firewall.filter_fwd.ipset="filter dest"
uci set firewall.filter_fwd.family="ipv4"
uci set firewall.filter_fwd.proto="all"
uci set firewall.filter_fwd.target="ACCEPT"

uci -q delete firewall.filter6_fwd
uci set firewall.filter6_fwd="rule"
uci set firewall.filter6_fwd.name="Filter_IPset_DNS_Forward"
uci set firewall.filter6_fwd.src="INET"
uci set firewall.filter6_fwd.dest="wan"
uci set firewall.filter6_fwd.ipset="filter6 dest"
uci set firewall.filter6_fwd.family="ipv6"
uci set firewall.filter6_fwd.proto="all"
uci set firewall.filter6_fwd.target="ACCEPT"


uci commit firewall && reload_config >/dev/null
/etc/init.d/firewall restart >/dev/null

clear
echo '########################################################'
echo '#                                                      #'
echo '#                 CyberSecurity-Box                    #'
echo '#                                                      #'
echo '########################################################'
echo
echo 'Your Config is:'
echo
echo 'Client-WiFi SSID:     '$INET_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$INET_net
echo
echo 'Smarthome-WiFi SSID:  '$HCONTROL_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$HCONTROL_net
echo
echo 'Voice-Assistent SSID: '$VOICE_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$VOICE_net
echo
echo 'Smart-TV/-DVD SSID:   '$ENTERTAIN_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$ENTERTAIN_net
echo
echo 'Server-WiFi SSID:     '$SERVER_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$SERVER_net
echo
echo 'IR/BT-Control SSID:   '$CONTROL_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$CONTROL_net
echo
echo 'Guests SSID is:       '$GUEST_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$GUEST_net
echo
echo
echo
echo 'IP-Address:           '$ACCESS_SERVER
echo 'Gateway:              '$INET_GW
echo 'Domain:               '$LOCAL_DOMAIN
echo
echo 'GUI-Access:           https://'$INET_ip':8443'
echo 'User:                 '$USERNAME
echo 'Password:             password'
echo
echo 'Please wait until Reboot ....'

cat << "EOF" > /etc/firewall.nat6 
iptables-save -t nat \
| sed -e "/\s[DS]NAT\s/d;/\sMASQUERADE$/d;/\s--match-set\s\S*/s//\06/" \
| ip6tables-restore -T nat
EOF
uci -q delete firewall.nat6 >/dev/null
uci set firewall.nat6="include" >/dev/null
uci set firewall.nat6.path="/etc/firewall.nat6" >/dev/null
uci set firewall.nat6.reload="1" >/dev/null
 
# Disable LAN to WAN forwarding
uci rename firewall.@forwarding[0]="INET_INTERNET" >/dev/null
uci set firewall.INET_INTERNET.enabled="0" >/dev/null
uci commit firewall >/dev/null
/etc/init.d/firewall restart >/dev/null
 
# Configure ipset-dns
uci set ipset-dns.@ipset-dns[0].ipset="filter" >/dev/null
uci set ipset-dns.@ipset-dns[0].ipset6="filter6" >/dev/null
uci commit ipset-dns >/dev/null
/etc/init.d/ipset-dns restart >/dev/null
 
# Resolve race conditions for ipset-dns
cat << "EOF" > /etc/firewall.ipsetdns 
/etc/init.d/ipset-dns restart 
EOF 
cat << "EOF" >> /etc/sysupgrade.conf
/etc/firewall.ipsetdns
EOF
uci -q delete firewall.ipsetdns >/dev/null
uci set firewall.ipsetdns="include" >/dev/null
uci set firewall.ipsetdns.path="/etc/firewall.ipsetdns" >/dev/null
uci set firewall.ipsetdns.reload="1" >/dev/null
uci commit firewall >/dev/null

/etc/init.d/firewall restart >/dev/null
/etc/init.d/dnsmasq restart >/dev/null
/etc/init.d/network restart >/dev/null
clear

#mkdir -p /mnt/sda1
#mount /dev/sda1 /mnt/sda1
#mkdir -p /tmp/cproot
#mount --bind / /tmp/cproot
#tar -C /tmp/cproot -cvf - . | tar -C /mnt/sda1 -x
#umount /tmp/cproot

#block detect | uci import fstab
#uci set fstab.@swap[0].enabled='1'
#uci set fstab.@global[0].anon_mount='1'

#uci set fstab.@mount[0].enabled='1'
#uci set fstab.@mount[0].options='rw,sync'

#uci set fstab.@mount[1].enabled='1'
#uci set fstab.@mount[1].options='rw,sync'
#uci set fstab.@mount[1].target='/home'

#uci set fstab.@mount[0].target='/'
#uci set fstab.@mount[0].is_rootfs='1'

#uci commit fstab
#/etc/init.d/fstab boot


clear
echo '########################################################'
echo '#                                                      #'
echo '#                 CyberSecurity-Box                    #'
echo '#                                                      #'
echo '########################################################'
echo
echo 'Firewall-Rules activated and it will reboot now.'
echo
echo 'Your Config is:'
echo
echo 'Client-WiFi SSID:     '$INET_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$INET_net
echo
echo 'Smarthome-WiFi SSID:  '$HCONTROL_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$HCONTROL_net
echo
echo 'Voice-Assistent SSID: '$VOICE_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$VOICE_net
echo
echo 'Smart-TV/-DVD SSID:   '$ENTERTAIN_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$ENTERTAIN_net
echo
echo 'Server-WiFi SSID:     '$SERVER_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$SERVER_net
echo
echo 'IR/BT-Control SSID:   '$CONTROL_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$CONTROL_net
echo
echo 'Guests SSID is:       '$GUEST_ssid
echo 'Key:                  '$WIFI_PASS
echo 'IP:                   '$GUEST_net
echo
echo
echo
echo 'IP-Address:           '$ACCESS_SERVER
echo 'Gateway:              '$INET_GW
echo 'Domain:               '$LOCAL_DOMAIN
echo
echo 'GUI-Access:           https://'$INET_ip':8443'
echo 'User:                 '$USERNAME
echo 'Password:             password'
echo
echo 'Please wait until Reboot ....'
echo
echo
echo 'Enter to continue'
reboot 
