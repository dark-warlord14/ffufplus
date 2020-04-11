#!/bin/bash

echo -e "\n[***] ffuf on steroids [***]\n"
echo -e "Usage:\n"
echo "Parameter Discovery : ./script 1" 
echo "VHOST Discovery: ./script 2"
echo "Parse waybackurls: ./script 3"
echo "Beast Mode: ./script 4"
echo -e "\n Example: ./script 4 (to run Beast Mode)"


if [[ $1 -eq 1 ]]; then

        echo "Parameter Discovery"
        echo "Enter URL to discover parameter for"
        read input1
        ffuf -c -H "X-Forwarded-For: 127.0.0.1" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -u "$input1?FUZZ=abcd" -w wordlist/param.txt -ac -s | tee result_param.txt
        echo "Done. Result is stored in result_param.txt"
        

elif [[ $1 -eq 2 ]]; then
        
        echo "VHOST Discovery"
        echo "Enter domain for Virtual Host Discovery"
        read input1
        domain=$(echo "$input1" | unfurl -u domain)
        ffuf -c -H "X-Forwarded-For: 127.0.0.1" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -u "$input1" -H "Host: FUZZ.$domain" -w wordlist/vhost.txt -ac -s | tee result_vhost.txt
        echo "Done. Result is stored in result_vhost.txt"
        
        
elif [[ $1 -eq 3 ]]; then
        echo "Gathering waybackurls, otxUrls also commoncrawl data"
        echo "Enter the domain"
        read input1
        domain=$(echo "$input1" | unfurl -u domain)
        gau $domain > gau.tmp
        ffuf -c -H "X-Forwarded-For: 127.0.0.1" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -u FUZZ -w gau.tmp -o result_gau.tmp
        cat result_gau.tmp | jq '[.results[]|{status: .status, length: .length, url: .url}]' | grep -oP "status\":\s(\d{3})|length\":\s(\d{1,7})|url\":\s\"(http[s]?:\/\/.*?)\"" | paste -d' ' - - - | awk '{print $2" "$4" "$6}' | sed 's/\"//g' > result_wayback.txt
        rm *.tmp
        echo "Done. Result is stored in result_wayback.txt"
        
        
elif [[ $1 -eq 4 ]]; then
        echo "Beast Mode ON"
        echo -e "\n Hope you have updated your alive.txt!"
        FILE1=ffuf
        if [ ! -d "$FILE1" ]; then
                mkdir ffuf
        else
                echo -e "\nRunning it again? Let me recreate the ffuf folder!"
                rm -r ffuf
                mkdir ffuf
        fi
        xargs -P10 -I {} sh -c 'url="{}"; ffuf -c -H "X-Forwarded-For: 127.0.0.1" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -u "{}/FUZZ" -w wordlist/dicc.txt -t 50 -D -e js,php,bak,txt,asp,aspx,jsp,html,zip,jar,sql,json,old,gz,shtml,log,swp,yaml,yml,config,save,rsa,ppk -ac -se -o ffuf/${url##*/}-${url%%:*}.json' < alive.txt
        cat ffuf/* | jq '[.results[]|{status: .status, length: .length, url: .url}]' | grep -oP "status\":\s(\d{3})|length\":\s(\d{1,7})|url\":\s\"(http[s]?:\/\/.*?)\"" | paste -d' ' - - - | awk '{print $2" "$4" "$6}' | sed 's/\"//g' > result_beast.txt
        rm -r ffuf
        echo "Done. Result is stored in result_beast.txt"
        
        
else
        echo -e "\n OOPS! Invalid option Selected, Try again."
 
fi
