#! /bin/sh
#initial value of variable
PRGEXE=`basename "$0"`
PRGDIR=`dirname "$0"`
PWDDIR=`pwd`
CONFIG=""$PRGDIR"/baklog.cfg"
BAKLOGDIR=`grep -w "TMP_BAK_LOGS" $CONFIG|awk -F = '{print $2}'`
hostname=`uname -n`
username="$LOGNAME"
#$LOGNAME 取出登录名称
todaydate=`date +%Y%m%d`
#取出当前时间
baklogdir="$BAKLOGDIR"
GZIP=`which gzip`
取出gzip所在路径
OS=`uname -s` 
#Linux
if [ $OS = Linux ]#
then
  df_cmd="df -k"
elif [ $OS = HP-UX ]
then
  df_cmd="bdf"
else
  echo "$OS is not known!"
  exit 1
fi
if [ ! -d $HOME/backup ]
then
  mkdir -p $HOME/backup
fi
if [ ! -d $baklogdir ]
then
  mkdir -p $baklogdir
fi

#define functions
baklog()
{
if [ $# -ne 2 ]
then
  echo "Usage: baklog <logdir|logfile> <logtype>"
  exit 1
fi
orilogdir="$1"
logtype="$2"
export baktarname="${hostname}-${username}-${todaydate}-${logtype}.tar"
cd $HOME
if [ `expr substr $orilogdir 1 1` != "/" ]
then
        orilogdir="$HOME/$orilogdir"
        if [ ! -d "$orilogdir" ]
        then
                echo "There is not the "$orilogdir" directory!"
                echo
                echo "Please input the absolute path or the path relative the "$HOME"!"
                echo
                exit 1
        fi
fi
logdir=`echo $orilogdir|awk -F $HOME/ '{print $2}'`

#check the remain space of disk
dirused=`du -sk $orilogdir|awk '{print $1}'`
diskavail=`$df_cmd $BAKLOGDIR | tail -1 | awk '{if ( $4 ~ /%/) { print $3 } else { print $4 } }'`
if [ $dirused -gt $diskavail ]
then
  printf "You will need at least %s kBytes of Disk Free\n" $dirused
  printf "Please free up the required Disk Space and try again\n"
  exit 3
fi

#backup the log file to tar package
if [ -d $logdir ]
then
  logdir="$logdir"/*.tar.gz
fi
if [ -f $baklogdir/$baktarname ]
then
  tar uf $baklogdir/$baktarname $logdir
else
  tar cf $baklogdir/$baktarname $logdir
fi
if [ -d $orilogdir ]
then
  echo "rm -f $orilogdir/*.tar.gz"
  rm -f $orilogdir/*.tar.gz
elif [ -f $orilogdir ]
then
  #echo "rm -f $orilogdir"
  >$orilogdir
else
  #echo "$orilogdir is Error!"
  exit 1
fi
}
leapy()
{
  year=$1
  RET="false"
  fhundred=`expr $year % 400` #expr 命令读入 Expression 参数，计算它的值，然后将结果写入到标准输出#
  ohundred=`expr $year % 100`
  four=`expr $year % 4`
  if [ $fhundred -eq 0 ]
  then
    RET="true"
  fi
  if [ \( $four -eq 0 \) -a \( $ohundred -ne 0 \) ]
  then
    RET="true"
  fi
  echo $RET
  #return $RET
}
dealy()
{
  year1=$1
  year2=$2
  ycount=`expr $year1 - $year2`
  count=1
  nday=0
  if [ $ycount -lt 0 ]
  then
    echo "The order of year's number is Error!"
    exit 1
  fi
  while [ $count -lt $ycount ]
  do
    year=`expr $year2 + $count`
    leapyear=`leapy $year`
    if $leapyear
    then
      nday=`expr $nday + 1`
    fi
    count=`expr $count + 1`
  done
  days=`expr $ycount \* 365 + $nday`
  echo $days
  #return $days
}
dealm()
{
  month=`expr $1 - 1`
  year=$2
  if [ \( $month -le 7 \) -a \( $month -ge 0 \) ]
  then
    days=`expr $month / 2 \* 31 + \( $month - $month / 2 \) \* 30`
  elif [ \( $month -ge 8 \) -a \( $month -le 12 \) ]
  then
    days=`expr $month / 2 \* 30 + \( $month - $month / 2 \) \* 31`
  else
    echo "The mistaking of month"
    exit 1
  fi
  leapyear=`leapy $year`
  if [ $month -ge 2 ]
  then
    if $leapyear
    then
      days=`expr $days - 1`
    else
      days=`expr $days - 2`
    fi
  fi
  echo $days
  #return $days
}
countdate()
{
  if [ $# -ne 2 ] #$?等于0表示上一个命令执行成功 否则执行出错#
  then 
    echo "Usage: countdate <yyyymmdd> <yyyymmdd>"
    exit 1
  fi
  date1=$1
  date2=$2
  lend1=`expr length $date1`
  lend2=`expr length $date2`
  if [ $lend1 -ne 8 -o $lend2 -ne 8 ]
  then
    echo "The date format of input is not right!"
    echo "Usage: countdate <yyyymmdd> <yyyymmdd>"
    exit 1
  fi
  year1=`expr substr $date1 1 4`
  year2=`expr substr $date2 1 4`
  month1=`expr substr $date1 5 2`
  month1=`echo $month1|sed -e 's/^0//'`
  month2=`expr substr $date2 5 2`
  month2=`echo $month2|sed -e 's/^0//'`
  day1=`expr substr $date1 7 2`
  day1=`echo $day1|sed -e 's/^0//'`
  day2=`expr substr $date2 7 2`
  day2=`echo $day2|sed -e 's/^0//'`
  yearsub=`expr $year1 - $year2`
  if [ $yearsub -ge 0 ]
  then
    ydays=`dealy $year1 $year2`
  else
    echo "The date order is Error!"
    exit 1
  fi
  mdays1=`dealm $month1 $year1`
  mdays2=`dealm $month2 $year2`
  days1=`expr $ydays + $mdays1 + $day1`
  days2=`expr $mdays2 + $day2`
  days=`expr $days1 - $days2`
  echo $days
  #return $days
}

#backup the log file to tar package
htnum=`grep -n "\[LOGS PATH LIST\]" $CONFIG|awk -F : '{print $1}'`
hlnum=`expr $htnum + 2`
ttnum=`grep -n "\[END\]" $CONFIG|awk -F : '{print $1}'`
tlnum=`expr $ttnum - 1`
sed -e "$hlnum,$tlnum"'!d' $CONFIG>$PRGDIR/logpath.txt
while read logpath logtype
do
  baklog $logpath $logtype
  if [ $? -ne 0 ]
  then
    echo "Execute baklog have Error!"
    exit 1
  fi
  cd $PWDDIR
  if [ -f $PRGDIR/tmpname.txt ]
  then
	grep -w "$logtype" $PRGDIR/tmpname.txt >/dev/null
	if [ $? -ne 0 ]
	then
	  echo "$baktarname">>$PRGDIR/tmpname.txt
	fi
  else
	echo "$baktarname">>$PRGDIR/tmpname.txt
  fi
done<$PRGDIR/logpath.txt
rm -f $PRGDIR/logpath.txt

#transfer the backup file to the backup host with ftp
cd $PWDDIR
USER=`grep -w "USERNAME" $CONFIG|awk -F = '{print $2}'`
PASS=`grep -w "PASSWORD" $CONFIG|awk -F = '{print $2}'`
SDIR=`grep -w "SAVE_DIR" $CONFIG|awk -F = '{print $2}'`
ROST=`grep -w "REMOTE_HOST" $CONFIG|awk -F = '{print $2}'`
for i in `cat $PRGDIR/tmpname.txt`
do
  cd $BAKLOGDIR
  $GZIP -9 $i
  echo "
user $USER $PASS
mkdir $SDIR
cd $SDIR
bin
put "$i".gz
bye"|ftp -n $ROST
done
rm -f $PRGDIR/tmpname.txt
 
#clean the older logs file
cd $PWDDIR
TDATE=`date +%Y%m%d`
SETDAY=`grep -w "SAVE_DAYS_NUM" $CONFIG|awk -F = '{print $2}'`
cd $BAKLOGDIR
for i in `ls`
do
  if [ -f "$i" ]
  then
    FDATE=`echo $i|awk -F - '{print $3}'`
    SUBDAYS=`countdate $TDATE $FDATE`
    if [ $SUBDAYS -gt $SETDAY ]
    then
      >./$i
      rm -f $i
    fi
  fi
done
cd $PWDDIR
