# install oci8 libs & extension
mkdir -p /opt/oracle

# download
#wget https://download.oracle.com/otn_software/linux/instantclient/214000/instantclient-basic-linux.x64-21.4.0.0.0dbru.zip
#wget https://download.oracle.com/otn_software/linux/instantclient/214000/instantclient-sdk-linux.x64-21.4.0.0.0dbru.zip
wget https://download.oracle.com/otn_software/linux/instantclient/2117000/instantclient-basic-linux.x64-21.17.0.0.0dbru.zip
wget https://download.oracle.com/otn_software/linux/instantclient/2117000/instantclient-sdk-linux.x64-21.17.0.0.0dbru.zip

#unzip
unzip -o ./instantclient-basic-linux.x64-21.17.0.0.0dbru.zip -d /opt/oracle
unzip -o ./instantclient-sdk-linux.x64-21.17.0.0.0dbru.zip -d /opt/oracle

#symbolic lln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1inks
ln -s /opt/oracle/instantclient_21_17/sqlplus /usr/bin/sqlplus

ln -s /opt/oracle/instantclient_21_17 /opt/oracle/instantclient
#ln -s /opt/oracle/instantclient/libclntsh.so.21.1 /opt/oracle/instantclient/libclntsh.so
#ln -s /opt/oracle/instantclient/libocci.so.21.1 /opt/oracle/instantclient/libocci.so
ln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1
ln -s /lib/libc.musl-x86_64.so.1 /usr/lib/libresolv.so.2
ln -s /lib/ld-musl-x86_64.so.1 /usr/lib/ld-linux-x86-64.so.2


# export LD_LIBRARY_PATH=/opt/oracle/instantclient
LD_LIBRARY_PATH=/opt/oracle/instantclient:$LD_LIBRARY_PATH

#install oci8
echo "Installing oci8"
/usr/bin/pecl84 channel-update pecl.php.net
sh -c "echo 'instantclient,/opt/oracle/instantclient' | /usr/bin/pecl84 install oci8"

#enable extension
echo 'extension=oci8' > /etc/php84/conf.d/03_oci8.ini

rm instantclient-basic-linux.x64-21.17.0.0.0dbru.zip
rm instantclient-sdk-linux.x64-21.17.0.0.0dbru.zip