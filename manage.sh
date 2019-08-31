#!/bin/bash
cd /root || exit
green=$(tput setaf 2)
reset=$(tput sgr0)
if [[ $EUID -ne 0 ]]; then
    whiptail --title "ERROR" --msgbox "This script must be run as root" 8 78
    exit
else
	os=$(whiptail --title "What do you want to do?" --menu "Choose an option" 16 100 9 \
	"1)" "Start" \
	"2)" "Stop" \
	"3)" "Modify session amount" \
	"4)" "Change session token" \
	"5)" "Remove" 3>&2 2>&1 1>&3
	)
	case $os in
		"1)")
			crontab crontab
			sessions=$(find /root/9HitsViewer_x64/sessions/*txt | wc -l)
			echo "${green}All $sessions Sessions has been started${reset}"
			;;
		"2)")
			crontab -r
			/root/kill.sh
			sessions=$(find /root/9HitsViewer_x64/sessions/*txt | wc -l)
			echo "${green}All $sessions sessions has been terminated${reset}"
			;;
		"3)")
			option=$(whiptail --title "How many sessions you want?" --menu "Choose an option" 16 100 9 \
	        "1)" "Use one session" \
	        "2)" "Automatic max session based on system specs" \
	        "3)" "Use custom number" 3>&2 2>&1 1>&3
	        )
	        case $option in
	            "1)")
	                number=1
					sessions=$(find /root/9HitsViewer_x64/sessions/*txt | wc -l)
					difference=$(($sessions-$number))
					if [[ $number -lt $sessions ]]; then
						for ssid in $(seq "$number" "$sessions"); do
						rm "/root/9HitsViewer_x64/sessions/156288217488$ssid.txt"
						done
						echo "${green}Because the new number is lower than the old one, $difference sessions has been deleted${reset}"
					fi
					echo "${green}Amount of $number session has been set${reset}"
	                ;;
	            "2)")
	                cores=$(nproc --all)
	                memphy=$(grep MemTotal /proc/meminfo | awk '{print $2}')
	                memswap=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
					sessions=$(find /root/9HitsViewer_x64/sessions/*txt | wc -l)
	                let memtotal=$memphy+$memswap
	                let memtotalgb=$memtotal/100000
	                let sscorelimit=$cores*6
	                let ssmemlimit=$memtotalgb*6/10
	                if [[ $sscorelimit -le $ssmemlimit ]]
	                then
						number=$sscorelimit
						difference=$(($sessions-$number))
						if [[ $number -lt $sessions ]]; then
							for ssid in $(seq "$number" "$sessions"); do
							rm "/root/9HitsViewer_x64/sessions/156288217488$ssid.txt"
							done
							echo "${green}Because the new number is lower than the old one, $difference sessions has been deleted${reset}"
						fi
						echo "${green}Amount of $number sessions has been set${reset}"
	                else
						number=$ssmemlimit
						difference=$(($sessions-$number))
						if [[ $number -lt $sessions ]]; then
							for ssid in $(seq "$number" "$sessions"); do
							rm "/root/9HitsViewer_x64/sessions/156288217488$ssid.txt"
							done
							echo "${green}Because the new number is lower than the old one, $difference sessions has been deleted${reset}"
						fi
						echo "${green}Amount of $number sessions has been set${reset}"
	                fi
	                ;;
	            "3)")
					export NEWT_COLORS='
	                window=,red
	                border=white,red
	                textbox=white,red
	                button=black,white
	                '
	                whiptail --title "WARNING" --msgbox "IF YOU SET EXCESIVE AMOUNT OF SESSIONS, SESSIONS MAY BE BLOCKED || RECOMMENDED USE A AUTOMATIC SESSION" 8 78
	                export NEWT_COLORS='
	                window=,white
	                border=black,white
	                textbox=black,white
	                button=black,white
	                '
					number=$(whiptail --inputbox "ENTER NUMBER OF SESSIONS" 8 78 --title "SESSIONS" 3>&1 1>&2 2>&3)
					sessions=$(find /root/9HitsViewer_x64/sessions/*txt | wc -l)
					difference=$(($sessions-$number))
	                numberstatus=$?
	                if [ $numberstatus = 0 ]; then
						if [[ $number -lt $sessions ]]; then
							for ssid in $(seq "$number" "$sessions"); do
								rm "/root/9HitsViewer_x64/sessions/156288217488$ssid.txt"
							done
							echo "${green}Because the new number is lower than the old one, $difference sessions has been deleted${reset}"
						fi
	                    echo "${green}Selected amount of $number sessions has been set${reset}"
	                else
	                    echo "User selected Cancel"
	                    exit
	                fi
	                ;;
	        esac
	       	isproxy=false
		    for i in $(seq 1 "$number");
	    	do
	        file="/root/9HitsViewer_x64/sessions/156288217488$i.txt"
cat > "$file" <<EOFSS
{
  "token": "$token",
  "note": "",
  "proxyType": "system",
  "proxyServer": "",
  "proxyUser": "",
  "proxyPw": "",
  "maxCpu": 10,
  "isUse9HitsProxy": $isproxy
}
EOFSS
				isproxy=true
	        	proxytype=ssh
	        done
			;;
		"4)")
			rm /root/9HitsViewer_x64/sessions/156288217488*
			token=$(whiptail --inputbox "Enter your TOKEN" 8 78 --title "TOKEN" 3>&1 1>&2 2>&3)
	        tokenstatus=$?
	        if [ $tokenstatus = 0 ]; then
	          	echo "${green}Token has been updated to $token${reset}"
	        else
	           	echo "User selected cancel"
	           	exit
	        fi
			;;
		"5)")
			crontab -r
			/root/kill.sh
			rm -R 9Hits-AutoInstall 9HitsViewer_x64 9hviewer-linux-x64.tar.bz2 crashdetect.sh crontab install.sh kill.sh manage.sh reboot.sh
			echo "${green}All files have been deleted${reset}"
			;;
	esac
fi
