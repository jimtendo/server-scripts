#!/bin/bash
  
EXPECTED_ARGS=4
E_BADARGS=65
MYSQL=`which mysql`
  
Q1="CREATE DATABASE IF NOT EXISTS $2;"
Q2="GRANT USAGE ON *.* TO $3@localhost IDENTIFIED BY '$4';"
Q3="GRANT ALL PRIVILEGES ON $2.* TO $3@localhost;"
Q4="FLUSH PRIVILEGES;"
SQL="${Q1}${Q2}${Q3}${Q4}"
  
if [ $# -ne $EXPECTED_ARGS ]
then
  echo "Usage: $0 rootpass dbname dbuser dbpass"
  exit $E_BADARGS
fi
  
$MYSQL -u root -p$1 -e "$SQL"
