#!/bin/bash
#mysql backup
DBNAME="mysql"
BACKPATH="/backup"
USER=root
PASSWORD=123456
if [ ! -d $BACKPATH ];then
  mkdir -p $BACKPATH
fi
mysqldump -u$USER  -p$PASSWORD -A -B --events >$BACKPATH/$DBNAME-$(date +%Y%m%d).sql
tar zPcf $BACKPATH/$DBNAME-$(date +%Y%m%d).sql.tar.gz $BACKPATH/$DBNAME-$(date +%Y%m%d).sql
#find $BACKPATH -mtime +2 -name "*.sql.tar.gz" |xargs rm -rf {} 
rm -rf $BACKPATH/*.sql
find $BACKPATH -mtime +2 -name "*.sql.tar.gz" |xargs rm -rf {}
scp -p 20022  $BACKPATH/$DBNAME-$(date +%Y%m%d).sql.tar.gz root@221.208.171.174:/backup