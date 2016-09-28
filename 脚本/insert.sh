#!/bin/bash
#
if [ ! -e qqqqq.txt ] ; then
  exit 2
fi
FILENAME="qqqqq.txt "
NUMBER=`sed -n '$=' $FILENAME `
NUMBER1=$[$NUMBER-1]
i=1
for I in `seq 1 $NUMBER1`;do
    
    word=`sed  -n ''$[$i+1]'p' $FILENAME`
    let i=$i+1
    word1=($word)
    mysql -uroot -p123456 -e "insert into yundongguanjia.test1 values('${word1[0]}','${word1[1]}','${word1[2]}','${word1[3]}','${word1[4]}','${word1[5]}','${word1[6]}','${word1[7]}','${word1[8]}','${word1[9]}','${word1[10]}','${word1[11]}','${word1[12]}','${word1[13]}','${word1[14]}'); "  
if [ $? -eq 0 ];then
  echo "insert  data OK"
else
 echo  "insert date FAIL"
 exit 2
fi
done   

