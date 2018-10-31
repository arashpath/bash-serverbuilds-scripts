ps -aef | awk '/[j]ava/ {
    for(i=1;i<=NF;i++){
        if ($i ~ /-Dcatalina.base/){
            split($i, subfield, "=")
            print $2" "subfield[2]
        }
    }
}'