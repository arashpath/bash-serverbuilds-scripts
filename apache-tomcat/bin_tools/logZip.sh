if [ -z "$1" ]
  then zipMonth=`date -d "last month" '+%Y-%m'`
  else zipMonth=$1
fi
echo "==================== $zipMonth ===================="
for i in `ls -lrth /opt/APPS/ | awk '{print $9}' | grep tom | sort -t'-' -k 2`
do 
  folder="/opt/APPS/$i/logs/"
  logfiles="localhost_access_log.$zipMonth-??.txt"  
  if ls -lrth $folder$logfiles 1> /dev/null 2>&1
    then echo "$i : Ziping log files" 
      tar -czf $folder$zipMonth".tgz" -P $folder$logfiles --remove-files
    else echo "$i : No log files to zip"
  fi  
done
echo "=================================================="