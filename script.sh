#!/bin/bash

echo "ffuf on steroids"
PS3="Select one of the options from above : "
choices=("Parameter Discovery" "VHOST Discovery" "Parse waybackurls" "Beast Mode")
select choice in "${choices[@]}"; do
        case $choice in
                "Parameter Discovery")
                        echo "Parameter Discovery"
                        echo "Enter URL to discover parameter for"
                        read input1
                        ffuf -H "X-Forwarded-For: 127.0.0.1" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -u "$input1?FUZZ=abcd" -w ~/tools/wordlist/param.txt -ac -s | tee result_param.txt
			echo "Done. Result is stored in result_param.txt"
                        break
                        ;;
                "VHOST Discovery")
                        echo "VHOST Discovery"
                        echo "Enter domain for Virtual Host Discovery"
                        read input1
                        domain=$(echo "$input1" | unfurl -u domain)
                        ffuf -H "X-Forwarded-For: 127.0.0.1" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -u "$1" -H "Host: FUZZ.$domain" -w "~/tools/wordlist/vhost.txt" -ac -s | tee result_vhost.txt
			echo "Done. Result is stored in result_vhost.txt"
                        break
                        ;;
                "Parse waybackurls")
                        echo "Gathering waybackurls, otxUrls also commoncrawl data"
                        echo "Enter the domain"
                        read input1
                        domain=$(echo "$input1" | unfurl -u domain)
                        gau $domain > gau.tmp
                        ffuf -H "X-Forwarded-For: 127.0.0.1" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -u FUZZ -w gau.tmp -o result_gau.tmp
                        cat result_gau.tmp | jq '[.results[]|{status: .status, length: .length, url: .url}]' | grep -oP "status\":\s(\d{3})|length\":\s(\d{1,7})|url\":\s\"(http[s]?:\/\/.*?)\"" | paste -d' ' - - - | awk '{print $2" "$4" "$6}' | sed 's/\"//g' > result_wayback.txt
                        rm *.tmp
			echo "Done. Result is stored in result_wayback.txt"
                        break
                        ;;
                "Beast Mode")
                        echo "Beast Mode ON"
                        echo "Enter the path to alive.txt"
                        read input1
                        mkdir ffuf
                        xargs -P10 -I {} sh -c 'url="{}"; ffuf -H "X-Forwarded-For: 127.0.0.1" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -u "{}/FUZZ" -w ~/tools/wordlist/dicc.txt -t 50 -D -e js,php,bak,txt,asp,aspx,jsp,html,zip,jar,sql,json,old,gz,shtml,log,swp,yaml,yml,config,save,rsa,ppk -ac -se -o ffuf/${url##*/}-${url%%:*}.json' < $input1
                        cat ffuf/* | jq '[.results[]|{status: .status, length: .length, url: .url}]' | grep -oP "status\":\s(\d{3})|length\":\s(\d{1,7})|url\":\s\"(http[s]?:\/\/.*?)\"" | paste -d' ' - - - | awk '{print $2" "$4" "$6}' | sed 's/\"//g' > result_beast.txt
                        rm ffuf -r
			echo "Done. Result is stored in result_beast.txt"
                        break
                        ;;
                *)
                        echo "Invalid option"
                        ;;
        esac
done
