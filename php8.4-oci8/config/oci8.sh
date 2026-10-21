#!/bin/sh
set -e

# Install Oracle Instant Client & OCI8 extension
mkdir -p /opt/oracle

wget -q https://download.oracle.com/otn_software/linux/instantclient/2117000/instantclient-basic-linux.x64-21.17.0.0.0dbru.zip
wget -q https://download.oracle.com/otn_software/linux/instantclient/2117000/instantclient-sdk-linux.x64-21.17.0.0.0dbru.zip

unzip -oq ./instantclient-basic-linux.x64-21.17.0.0.0dbru.zip -d /opt/oracle
unzip -oq ./instantclient-sdk-linux.x64-21.17.0.0.0dbru.zip -d /opt/oracle

ln -sf /opt/oracle/instantclient_21_17/sqlplus /usr/bin/sqlplus
ln -sf /opt/oracle/instantclient_21_17 /opt/oracle/instantclient
ln -sf /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1 || true
ln -sf /lib/libc.musl-x86_64.so.1 /usr/lib/libresolv.so.2
ln -sf /lib/ld-musl-x86_64.so.1 /usr/lib/ld-linux-x86-64.so.2

export LD_LIBRARY_PATH=/opt/oracle/instantclient:$LD_LIBRARY_PATH

echo "Installing oci8 via PECL..."
sh -c "echo 'instantclient,/opt/oracle/instantclient' | /usr/local/bin/pecl install oci8"

echo "extension=oci8.so" > /usr/local/etc/php/conf.d/03_oci8.ini

rm -f instantclient-basic-linux.x64-21.17.0.0.0dbru.zip
rm -f instantclient-sdk-linux.x64-21.17.0.0.0dbru.zip
