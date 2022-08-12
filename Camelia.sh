#!/bin/bash

###
###     A mini-text-database named Camelia
###     ============
###     How to use?
###         Camelia tablename option param
###     ============
###     Options:
###         -u|-i key value
###             insert or update your data
###         -d key
###             delete your date,but not really delete
###         -tar
###             tar the table,and copy
###         -h key
###             display the history with the parameter as the key
###         --help
###             display this help and exit
###     ============
###     If you do not enter an option,Camelia will display the value with the parameter as the key:
###         Camelia testdb key
###     You can enter multiple options and parameters at once:
###         Camelia testdb -i key1 value1 -i key2 value2 -i key1 Meow key1 key2
###


ins_del() { #记录插入/修改/删除
    echo $1 >> $tname
}
sel() { #查找
    tac $tname|grep "^$1,"|head -n 1|grep "^$1,i,"|cut -d "," -f 3
}
selhistory() { #查看修改历史
    grep "^$1," $tname | cut -d "," -f 2,3,4
}
selhisval() { #查看历史值
    grep "^$1," $tname | cut -d "," -f 3
}
selhiscount() { #查看历史值计数
    grep "^$1," $tname | cut -d "," -f 3 | awk '{for(i=1;i<=NF;i++)a[$i]++}END{for(x in a)print x,a[x]}'
}

help_tname() { #初始化表名/显示帮助
    if [[ $# == 0 ]] || [[ "$1" == "--help" ]]; then
        awk -F'### ' '/^###/ { print $2 }' "$0"
        exit 1
    fi
    if [[ $1 == -* ]]; then
        echo "Honey,don't call a table $1"
        exit 1
    fi
    tname=$(ls|egrep "^$1(_[1-9]\d*)?$"|tail -1)
    if [[ -z $tname ]]; then
        echo "#$Cameliatime|$1|${USER}" >> $1
        tname=$1
    else
        local tnamesign=$(head -n 1 $tname|cut -d "|" -f 2)
        if [[ ! $tname == $tnamesign ]]; then
            echo "$1 is not Camelia's database,caution,mua~"
            exit 1
        fi
    fi
}
tar() { #压缩数据库
    local ptname=$tname #当前表名
    local start=${tname%_*} #前缀
    local index=${tname#*_} #后缀
    ((index++))
    tname=$start"_"$index
    echo "#$Cameliatime|$tname|${USER}" >> $tname
    tail -n +2 $ptname|awk -F, '{a[$1]=$0}END{for(t in a)print a[t]}' >> $tname
    exit 0;
}

tname=""
Cameliatime=$(date "+%y%m%d%H%M%S")
help_tname $1
shift
while [ -n "$1" ]
do
    case $1 in
        -u|-i) ins_del $2,i,$3,$Cameliatime
            shift 3 ;;
        -d) ins_del $2,d,$Cameliatime
                shift 2 ;;
        -h) selhistory $2
            shift 2 ;;
	-hv) selhisval $2
            shift 2 ;;
	-hc) selhiscount $2
            shift 2 ;;
	--help) help_tname $1
	    ;;
        -tar) tar ;;
        *) if [[ $1 == -* ]]; then
            echo "Invalid option $1"
            exit 1
        else
            sel $1
            shift
        fi ;;
        esac
done
