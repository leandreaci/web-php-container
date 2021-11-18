# install oci8 libs & extension
mkdir -p /opt/oracle

# download
wget https://github.com/bumpx/oracle-instantclient/raw/master/instantclient-basic-linux.x64-12.1.0.2.0.zip
wget https://github.com/bumpx/oracle-instantclient/raw/master/instantclient-sdk-linux.x64-12.1.0.2.0.zip

#unzip
unzip -o ./instantclient-basic-linux.x64-12.1.0.2.0.zip -d /opt/oracle
unzip -o ./instantclient-sdk-linux.x64-12.1.0.2.0.zip -d /opt/oracle

#symbolic lln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1inks
ln -s /opt/oracle/instantclient/sqlplus /usr/bin/sqlplus

ln -s /opt/oracle/instantclient_12_1 /opt/oracle/instantclient
ln -s /opt/oracle/instantclient/libclntsh.so.12.1 /opt/oracle/instantclient/libclntsh.so
ln -s /opt/oracle/instantclient/libocci.so.12.1 /opt/oracle/instantclient/libocci.so
ln -s /usr/lib/libnsl.so.2 /usr/lib/libnsl.so.1


# export LD_LIBRARY_PATH=/opt/oracle/instantclient
LD_LIBRARY_PATH=/opt/oracle/instantclient:$LD_LIBRARY_PATH

#install oci8

sh -c "pecl channel-update pecl.php.net"
sh -c "echo 'instantclient,/opt/oracle/instantclient' | pecl install oci8-2.2.0"

#enable extension
echo 'extension=oci8' > /etc/php7/conf.d/03_oci8.ini