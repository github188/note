#!/bin/bash
DBNAME="mysql"
BACKPATH=/backup
USER=root
PASSWORD=123456
mysql -u$USER -p$PASSWORD <$BACKPATH/$DBNAME-$(date +%Y%m%d).sql
find $BACKPATH -mtime +2 -name "*.sql" |xargs rm -rf {}


