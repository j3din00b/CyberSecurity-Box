<head>
<meta name="google-site-verification" content="puDJPKt82mah02UkmE5ThtOtTU-B1gTDxL5i85x9wSI" />
</head>
<img src="/CyberSecurityBox.jpg" alt="Logo" width="300px"> </img>
<h1>CyberSecurity-Box</h1>
<h4>(inkl. Ad Blocker, <img src="https://github.com/CyberAndi/CyberSecurity-Box/blob/CyberAndi-Pi-Hole-5/unbound_logo.png" style="max-width: 100%; vertical-align: middle; background-color: rgba(230,230,230,0.7); padding: 0.15em 0.25em; height:1em" height="14px"> (DNS), <img src="https://github.com/CyberAndi/CyberSecurity-Box/blob/CyberAndi-Pi-Hole-5/tor-logo%402x.png" style="max-width: 100%;  padding: 0em; height:1em" height="14px"> or optional <img src="https://github.com/CyberAndi/CyberSecurity-Box/blob/CyberAndi-Pi-Hole-5/pihole.png" style="max-width: 100%;  padding: 0em; height:1em" height="14px"> Pi-Hole (incl. DB) and ntopng) </h4>

<h4><a href="https://github.com/CyberAndi/CyberSecurity-Box/wiki/Deutsch"><img src="https://github.com/CyberAndi/CyberSecurity-Box/blob/CyberAndi-Pi-Hole-5/de.gif" style="width:20px;  padding: 0em; height:1em" height="14px">&nbsp; F&uuml;r Deutsch / For German</a></h4>
<p>
  First load the <b><a href="https://brave.com/download/" target="_blank"><img src="/brave-logo-sans-text.svg" style="max-width: 100%; vertical-align: middle; padding: 0em; height:1em" height="14px"></img> Brave-Browser</a></b> from the <a href="https://brave.com/" target="_blank">Brave-Website</a>.<br><br>
For the Raspberry-Pi Installation goto <b><a href="#raspi">Alternative 2</a></b>.	
<ol><h3><li>Alternative 1 - Installation on <img src="/openWRT.png" style="max-width: 100%; vertical-align: middle; padding: 0em; height:1em" height="20px"></img>-Router( <img src="/AVM_logo.png" style="max-width: 100%; vertical-align: middle; padding: 0.15em 0.25em; height:1em; background-color: rgba(230,230,230,0.7);" height="20px" alt="AVM"></img> Fritz!Box, <img src="/tplink-logo-white.svg" style="max-width: 100%; vertical-align: middle; padding: 0em; height:1em" height="20px" alt="tp-link"></img>, <img src="/ASUS_logo.png" style="max-width: 100%; vertical-align: middle; padding: 0em; height:1em" height="20px" alt="ASUS"></img> etc.)</h3>
  Go on <a href="https://openwrt.org/" target="_blank"><img src="/openWRT.png" style="max-width: 100%; vertical-align: middle; padding: 0em; height:1em" height="20px"></img>-Page</a> and download the <b><a href="https://firmware-selector.openwrt.org/" target="_blank">Firmware</a></b> for your Router. Please click before on <code>Customize installed packages and/or first boot script</code> and delete all items then insert <br><br>  
  <pre><code>ath10k-board-qca4019 ath10k-firmware-qca4019-ct base-files busybox ca-bundle dnsmasq-full dropbear firewall4 fstools kmod-ath10k-ct kmod-gpio-button-hotplug kmod-leds-gpio kmod-nft-offload kmod-usb-dwc3 kmod-usb-dwc3-qcom kmod-usb3 libc libgcc libustream-mbedtls logd mtd netifd nftables odhcp6c odhcpd-ipv6only opkg ppp ppp-mod-pppoe procd procd-seccomp procd-ujail uboot-envtools uci uclient-fetch urandom-seed urngd wpad-basic-mbedtls fritz-tffs fritz-caldata luci stubby tor tor-geoip unbound-daemon unbound-anchor unbound-control-setup unbound-host unbound-checkconf luci-app-unbound tc luci-app-qos luci-app-nft-qos nft-qos kmod-nls-cp437 kmod-nls-iso8859-1 nano wget curl openssh-sftp-server getdns drill bind-dig ca-certificates acme luci-app-acme</code></pre>
  into the field <code>Installed Packages</code>.<br><br>
  <img src="/Firmware_Config.png" alt="select_packages" width="50%"> </img><br><br>
  And in the field <code>Script to run on first boot (uci-defaults)</code> insert.<br><br>
  <pre><code>cat << EOF > /etc/rc.local
	if [ ! -f /root/openWRT23_install.sh ]
		then
			wget https://github.com/CyberAndi/CyberSecurity-Box/raw/CyberAndi-Pi-Hole-5/openWRT23_install.sh -P /root/ && sh /root/openWRT23_install.sh
		else
			rm /root/*.sh
	fi
	if [ ! -f /root/run ] 
		then
			echo $(date) > /root/run
			exit 0
	fi
	cat << EOF > /etc/rc.local
	EOF
EOF
exit 0   
</code></pre>
  Then press <code>Request Build</code>.<br><br>
  <img src="/Request_build.png" alt="select_packages" width="50%"> </img>.<br><br>
  Afterwards generate the File with <code>Kernel</code> and download it.<br><br>
  <img src="/generate_firmware.png" alt="select_packages" width="50%"> </img>
  <br><br>
  After flushing use SSH or Putty for Installation and type the following code.<br><br>
  <pre><code>ssh [ip-address of OpenWRT]</code></pre>
  User: <i><b>root</b></i>
  <br>
  Password: <i><b></b></i><br><br>
  Change the Password with<br><br>
  <pre><code>passwd
[newpassword]
[newpassword]</code></pre>
  Don´t forget to note the <i><b>newpassword</b></i>. Now go to the <a href="#afterreboot">Network-Overview </a>.
<br><br><details>
  <summary>If you didn´t insert the <code>Script to run on first boot (uci-defaults)</code> then download the Installscript.  (For more Informations open here). </summary> It starts automatically.
Else skip this Part and go to <a href="#afterreboot">Network-Overview </a>.<br><br>
  for OpenWRT Version 23.x.xx<br><br>
  <pre><code>wget https://github.com/CyberAndi/CyberSecurity-Box/raw/CyberAndi-Pi-Hole-5/openWRT23_install.sh && sh openWRT23_install.sh</code></pre>
  <br>
  for OpenWRT Version 22.x.xx<br><br>
  <pre><code>wget https://github.com/CyberAndi/CyberSecurity-Box/raw/CyberAndi-Pi-Hole-5/openWRT22_install.sh && sh openWRT22_install.sh</code></pre>
  <br>
  for OpenWRT Version 21.x.xx<br><br>
  <pre><code>wget https://github.com/CyberAndi/CyberSecurity-Box/raw/CyberAndi-Pi-Hole-5/openWRT21_install.sh && sh openWRT21_install.sh</code></pre>
  <br>
  for OpenWRT Version 19.x.xx<br><br>
  <pre><code>wget https://github.com/CyberAndi/CyberSecurity-Box/raw/CyberAndi-Pi-Hole-5/openWRT19_install.sh && sh openWRT19_install.sh</code></pre>
  <br> Now it will appear some Questions about your Network and your Devices.  <b>Note: All Values needed !!</b>.
 <p><p>
  <img src="https://user-images.githubusercontent.com/46010442/127338090-c8fa4a0c-c2ec-4e62-938e-9c5b6320bd41.jpg" width="50%"></img>
  </code>
  </details>
</li>
<h3><li id="afterreboot">
   After the reboot you will have following Networks:</h3>
    <ul>
    <li><b>REPEATER</b> for internal Communication between Router and Repeater for all of this Networks</li>
      <li><b>VOICE</b> for Amazon Alexa, Google Assistent or other Voice Assistent-Systems</li>
  <li><b>CONTROL</b> for IR/RF-Controlling like Logitech Harmony, Broadlink etc. </li> 
    <li><b>HCONTROL</b> for Homeautomation or Smarthome (Heating, Cooling, Dor-, Window-Contacts, Power-Switches etc.)</li>
    <li><b>ENTERTAIN</b> for TVs, PlayStation, X-Box, Mediaplayer, DVD-Player and BlueRay-Player etc.</li>
    <li><b>DMZ</b> for NAS, Network Storage, PLEX-Server, UPNP/DLNA-Servers, Database-Servers, Mail-Server and Web-Server etc.</li>
    <li><b>INET</b> for Clients with .onion and Tor-Network Access</li>
    <li><b>GUEST</b> for your Guests only</li>
  </ul><br>
  All of this have the WiFi-Password/-Key: <i><b>Cyber,Sec9ox</b></i><br><br>
  For each of this separated Networks you will have a <b>VLAN</b> on the Switch-/Output-Ethernet-Ports of the Router between <b>VLAN_ID 101</b> and <b>VLAN_ID 106</b>.<p></p>
  You will find the Screenshots <a href="https://github.com/CyberAndi/CyberSecurity-Box/blob/CyberAndi-Pi-Hole-5/README.md#screenshots">here</a>. 
  </li>
  
  <h3> <li id="raspi">Alternative 2 - Installation CyberSecurity-Box ( <img src="/RaspBerry.png" style="max-width: 100%; vertical-align: middle; padding: 0em; height:1em" height="20px"></img>RaspPi)</li></h3>
  You need a Raspberry Pi and a SD-Card with 8 GByte or more.
  Use a blank <b><a href="https://www.raspberrypi.org/downloads/raspbian/" target="_blank">Raspbian-SD-Card-Image</a></b> or 
  <b>CyberSecurityBox_2.img</b> is the Pi-Hole, UnBound and torrc with a ready-to-use Image.
  <br>Install one of this with <b><a href="https://www.balena.io/etcher/" target="_blank">balenaEtcher</a></b> on a SD-Card. <br>Insert the SD-Card in the RasPi. And use SSH or Putty for Installation and type the following code.<br><br>
  <pre><code>ssh [ip-address of RasPi]</code></pre>
  User: <i><b>pi</b></i>
  <br>
  Password: <i><b>raspberry</b></i><br><br>
  Change the Password with<br><br>
  <pre><code>passwd
[newpassword]
[newpassword]</code></pre>
  Don´t forget to note the <i><b>newpassword</b></i>.<br>
  <br>
  <pre><code>sudo su
apt-get update
apt-get upgrade -y</code></pre>
  <ul>
    <li>
<h4>Type for Installation</h4>
     <pre><code>apt-get install tor unbound privoxy ntopng postfix iptables-persistent netfilter-persistent -y
curl -sSL https://install.pi-hole.net | bash</code></pre>
     and follow the messages on the screen.<br>
    </li>
    <li>
    <h4>The <a href="https://github.com/CyberAndi/CyberSecurity-Box/blob/CyberAndi-Pi-Hole-5/pi-hole-teleporter_2020-06-07_09-38-48.tar.gz" target="_blank">pi-hole-teleporter_2020-06-07_09-38-48.tar.gz</a></h4>
      Is the newest Version with <b>PiHole 5.0 and DataBase Support</b>. It includes the Porn-, Ad- and Tracking-Blocking.
    </li>
    <li>
    <h4>The <a href="https://github.com/CyberAndi/CyberSecurity-Box/raw/master/pi-hole-teleporter_CyberSecurity_Box_without_Porn.tar.gz" target="_blank">pi-hole-teleporter_CyberSecurity_Box_without_Porn.tar.gz</a></h4> inludes White- and Blacklist (Advertisement and Maleware). <b> Until Pi-Hole 4 and smaller</b></li>
    <li>
    <h4>The <a href="https://github.com/CyberAndi/CyberSecurity-Box/raw/master/pi-hole-teleporter_CyberSecurity_Box_without_Porn.tar.gz" target="_blank">pi-hole-teleporter_CyberSecurity_Box_2018-12-20_.tar.gz</a></h4> inludes White- and Blacklist (Advertisement, Maleware, Tracking and Porn).<b> Until Pi-Hole 4 and smaller</b></li>
    <li>
    <h4>The Pi-Hole 4 <a href="https://github.com/CyberAndi/CyberSecurity-Box/raw/master/regex.list" target="_blank">regex.list</a></h4> includes Blacklist (Advertisment, Maleware, Tracking and Porn) with over 40% blocking rate.<br> In pi-hole-teleporter_2020-06-07_09-38-48.tar.gz is this included for Pi-Hole5.
  <pre><code>service pihole-FTL stop
service unbound stop
service privoxy stop
service tor stop
curl -sSL --compressed https://github.com/CyberAndi/CyberSecurity-Box/raw/Version2/whitelist_Alexa_Google_Home_Smarthome.txt > whitelist.txt
curl -sSL --compressed https://github.com/CyberAndi/CyberSecurity-Box/raw/Version2/tor/torrc > torrc
curl -sSL --compressed https://github.com/CyberAndi/CyberSecurity-Box/raw/Version2/unbound/root.hints > root.hints
curl -sSL --compressed https://github.com/CyberAndi/CyberSecurity-Box/raw/Version2/unbound/unbound.conf > unbound.conf
curl -sSL --compressed https://github.com/CyberAndi/CyberSecurity-Box/raw/Version2/unbound/unbound.conf.d/test.conf > unbound_tor_pihole.conf
curl -sSL --compressed https://github.com/CyberAndi/CyberSecurity-Box/raw/Version2/unbound.sh > unbound.sh
curl -sSL --compressed https://github.com/CyberAndi/CyberSecurity-Box/raw/Version2/privoxy/config > config
curl -sSL --compressed https://github.com/CyberAndi/CyberSecurity-Box/raw/Version2/boxed-bg.jpg > boxed-bg.jpg
curl -sSL --compressed https://github.com/CyberAndi/CyberSecurity-Box/raw/Version2/boxed-bg.png > boxed-bg.png
curl -sSL --compressed https://github.com/CyberAndi/CyberSecurity-Box/raw/Version2/blockingpage.css > blockingpage.css
curl -sSL --compressed https://github.com/CyberAndi/CyberSecurity-Box/raw/Version2/AdminLTE.min.css > AdminLTE.min.css
curl -sSL --compressed https://github.com/CyberAndi/CyberSecurity-Box/raw/Version2/skin-blue.min.css > skin-blue.min.css
<br>
cp whitelist.txt /etc/pihole/whitelist.txt
cp root.hints /etc/unbound/root.hints
cp unbound.conf /etc/unbound/unbound.conf
cp unbound.sh /etc/cron.weekly
cp unbound_tor_pihole.conf /etc/unbound/unbound.conf.d/unbound_tor_pihole.conf -r -v
cp config /etc/privoxy/config
cp boxed-bg.jpg /var/www/html/admin/img/boxed-bg.jpg
cp *.css /var/www/html/admin/style/vendor/
cp blockingpage.css /var/www/html/pihole/
<br>
service tor start
service privoxy start
service unbound start
service pihole-FTL start</code></pre>
   </li>
  </ul>
  
  <h3><li>Alternative 2 optional - Pi_Hole Configuration of the AVM FRITZ!Box with Presets for Security and Port-List</h3>
<h4>This <a href="https://github.com/CyberAndi/CyberSecurity-Box/blob/master/CyberSecurityBox.zip" target="_blank">zip-File</a></h4> includes a AVM FRITZ!Box-Export-File for FRITZ OS 6.80 and above. It includes Firewall-Rules for Amazon Alexa/Echo, Google Assistens, NAS, MS-Servers etc.<br>
  <img src="Schema.PNG" width="450px"></img>
  </li>
</ol></p>
<p>
For more Information in german visit <a href="https://cyberandi.tumblr.com/Smarthome" target="_blank">https://cyberandi.tumblr.com/Smarthome</a>
</p>
<hr>
&copy; CyberAndi 2019-2024 

email: cyberandi@outlook.de<br>
https://cyberandi.tumblr.com
</hr>
<p>
<hr></hr>
<p>
<p>
<h3>Screenshots</h3>
<p>
<img src="https://user-images.githubusercontent.com/46010442/127338090-c8fa4a0c-c2ec-4e62-938e-9c5b6320bd41.jpg" alt="Set Parameters" width="50%"></img>
<p>
  <img src="https://user-images.githubusercontent.com/46010442/133788783-9ef6d6c9-4428-4bb1-9971-ddb40f524e4b.png" alt="Login Page" width=50%"></img>
 <p>
 <img src="https://user-images.githubusercontent.com/46010442/133788864-be55d84f-47d3-44b9-9134-31b903ff1938.png" alt="Overview" width=50%"></img>
 <p>
 <img src="https://user-images.githubusercontent.com/46010442/133788889-e6e42258-6f8d-4d8b-a3f3-2d557e490531.png" alt="Overview 2" width=50%"></img>
<p>
 <img src="https://user-images.githubusercontent.com/46010442/133786871-56b38494-6326-4194-8e37-1f62a4b30d9d.png" width=50%"></img>
<p>
 <img src="https://user-images.githubusercontent.com/46010442/133786876-76f2cf7d-5fe4-4a64-81a5-66d1333a52ec.png" width=50%"></img>
 <p>
 <img src="https://user-images.githubusercontent.com/46010442/133786879-ebaed5be-1853-48c2-b3fa-dc22966e454f.png" width=50%"></img>
 <p>
 <img src="https://user-images.githubusercontent.com/46010442/133790948-5b2b2d82-c296-4484-831b-9527ed791ba9.png" width=50%> </img>
  <p>
 <img src="https://user-images.githubusercontent.com/46010442/133790213-459364b2-5120-491f-8db4-7b009f8ed46b.png" width=50%"></img>
 <p> 
<img src="https://user-images.githubusercontent.com/46010442/133786886-1caf75ce-e220-40d3-adcb-980bf081a8a9.png" width=50%"></img>
<p>
<img src="https://user-images.githubusercontent.com/46010442/133786890-071828fc-80dd-4ce6-ab08-15ce47c9f000.png" width=50%"></img>
<p>
<img src="https://user-images.githubusercontent.com/46010442/133786902-e4167664-97dc-4a85-a491-0698f349a572.png" width=50%"></img>
<p> 
<img src="https://user-images.githubusercontent.com/46010442/133786905-74f2d27a-8813-46a1-b4f9-bd415abbe14a.png" width=50%"></img>
<p>
<img src="https://github.com/CyberAndi/CyberSecurity-Box/assets/46010442/d3fcdc8a-b8f0-4531-bca4-b7e9831a020b.png" width=50%></img>
<p>
<img src="https://github.com/CyberAndi/CyberSecurity-Box/assets/46010442/282b4391-3a9e-4efe-8b8a-73efd6b22dc0.png" width=50%></img>
<p>
<img src="https://github.com/CyberAndi/CyberSecurity-Box/assets/46010442/5b502b53-1cea-4024-afc5-3847ac6cccca.png" width=50%></img>
<p>
<img src="https://github.com/CyberAndi/CyberSecurity-Box/assets/46010442/3906e52e-3e02-47ae-9b61-ecb9e498955b.png" width=50%></img>

***
&copy; CyberAndi 2019-2023 

email: cyberandi@outlook.de<br>
https://cyberandi.tumblr.com
