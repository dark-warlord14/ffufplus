#!/bin/bash

printf "\nffuf on Steroids\n\n"
PS3="
Select one of the options from above : "
choices=("Directory BruteForcing" "Parameter Discovery" "VHOST Discovery" "Parse waybackurls" "Beast Mode")
select choice in "${choices[@]}"; do
        case $choice in
		"Directory BruteForcing")
			printf "\nDirectory Bruteforcing"
			printf "\n\nEnter the url for Directory Bruteforcing: "
			read input1
			ffuf -mc all -c -H "X-Forwarded-For: 127.0.0.1" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -u "$input1/FUZZ" -w wordlist/dicc.txt -D -e js,php,bak,txt,asp,aspx,jsp,html,zip,jar,sql,json,old,gz,shtml,log,swp,yaml,yml,config,save,rsa,ppk -ac -o result_dir.tmp
			cat result_dir.tmp | jq '[.results[]|{status: .status, length: .length, url: .url}]' | grep -oP "status\":\s(\d{3})|length\":\s(\d{1,7})|url\":\s\"(http[s]?:\/\/.*?)\"" | paste -d' ' - - - | awk '{print $2" "$4" "$6}' | sed 's/\"//g' > result_dir.txt
			printf "\nDone. Result is stored in result_dir.txt\n"
			break
			;;
                "Parameter Discovery")
                        printf "\nParameter Discovery"
                        printf "\n\nEnter URL to discover parameter for: "
                        read input1
                        ffuf -mc all -c -H "X-Forwarded-For: 127.0.0.1" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -u "$input1?FUZZ=abcd" -w wordlist/param.txt -ac | tee result_param.txt
			printf "\nDone. Result is stored in result_param.txt\n"
                        break
                        ;;
                "VHOST Discovery")
                        printf "\nVHOST Discovery"
                        printf "\n\nEnter domain for Virtual Host Discovery: "
                        read input1
                        domain=$(echo "$input1" | unfurl -u domain)
                        ffuf -mc all -c -u "$input1" -H "Host: FUZZ.$domain" -w wordlist/vhost.txt -ac -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -o result_vhost.txt
			printf "\nDone. Result is stored in result_vhost.txt\n"
                        break
                        ;;
                "Parse waybackurls")
                        printf "\nGathering waybackurls, otxUrls also commoncrawl data"
                        printf "\n\nEnter the domain: "
                        read input1
                        domain=$(echo "$input1" | unfurl -u domain)
                        gau $domain > gau.tmp
                        ffuf -mc all -c -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -u FUZZ -w gau.tmp -o result_gau.tmp
                        cat result_gau.tmp | jq '[.results[]|{status: .status, length: .length, url: .url}]' | grep -oP "status\":\s(\d{3})|length\":\s(\d{1,7})|url\":\s\"(http[s]?:\/\/.*?)\"" | paste -d' ' - - - | awk '{print $2" "$4" "$6}' | sed 's/\"//g' > result_wayback.txt
                        rm *.tmp
			printf "\nDone. Result is stored in result_wayback.txt\n"
                        break
                        ;;
                "Beast Mode")
                        echo "Beast Mode ON"
                        mkdir ffuf
                        xargs -P10 -I {} sh -c 'url="{}"; ffuf -s -mc all -c -H "X-Forwarded-For: 127.0.0.1" -H "User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:72.0) Gecko/20100101 Firefox/72.0" -u "{}/FUZZ" -w wordlist/dicc.txt -t 50 -D -e js,php,bak,txt,asp,aspx,jsp,html,zip,jar,sql,json,old,gz,shtml,log,swp,yaml,yml,config,save,rsa,ppk -ac -se -o ffuf/${url##*/}-${url%%:*}.json' < alive.txt
                        cat ffuf/* | jq '[.results[]|{status: .status, length: .length, url: .url}]' | grep -oP "status\":\s(\d{3})|length\":\s(\d{1,7})|url\":\s\"(http[s]?:\/\/.*?)\"" | paste -d' ' - - - | awk '{print $2" "$4" "$6}' | sed 's/\"//g' > result_beast.txt
                        rm ffuf -r
			printf "\nDone. Result is stored in result_beast.txt\n"
                        break
                        ;;
                *)
                        echo "Invalid option"
                        ;;
        esac
done
