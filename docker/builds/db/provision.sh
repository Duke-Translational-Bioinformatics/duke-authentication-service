#!/bin/bash
export ORACLE_HOME=/u01/app/oracle/product/11.2.0/xe
export PATH=${ORACLE_HOME}/bin:${PATH}
export ORACLE_SID=XE
echo "PROVISIONING WITH ${ORACLE_HOME}"
if [ -z ${DEV_DB_USER} ] || [ -z ${DEV_DB_PASS} ] || [ -z ${TEST_DB_USER} ] || [ -z ${TEST_DB_PASS} ]
then
  echo "WARNING: YOU NEED ENVIRONMENT DEV_DB_USER DEV_DB_PASS TEST_DB_USER TEST_DB_PASS"
else
  /usr/sbin/startup.sh
  sqlplus system/oracle @/root/provision.sql ${DEV_DB_USER} ${DEV_DB_PASS} ${TEST_DB_USER} ${TEST_DB_PASS}
fi
exit
