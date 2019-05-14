#!/bin/bash

###############################################################
# SCRIPT PARA RESPALDO DE BASES DE DATOS MYSQL                #
# CREADO POR: ROMAN BARRIOS                                   #
# RB@ROMANBARRIOS.COM                                         #
# SE DEBE CAMBIAR EL PERMISO DEL SCRIPT A CHMOD 700 PARA QUE  #
# PUEDA EJECUTARSE                                            #
# PARA EL CRON CORRA 02:00 am                                 #
# * 2 * * * root /etc/roman/autobackup/autobackup.sh          #
###############################################################

# Crea variables necesarias
FECHA=`date +%Y%m%d`
ROOT_DIR="/home/backup/"
DIRECTORIO="$ROOT_DIR$FECHA"


# Se escribe en el log el inicio del respaldo
echo "----------------------------------------------------------------------" >> $ROOT_DIR/backup.log
echo "Inicio de respaldo automatico el `date`" >> $ROOT_DIR/backup.log
echo "Crea directorio de respaldo para la fecha del dia" >> $ROOT_DIR/backup.log

# Se crea directorio de trabajo
mkdir $DIRECTORIO

#indica en el log que se incia el respaldo de las bases de datos
echo "Inicia el mysqldump para cada una de las bases de datos encontradas" >> $ROOT_DIR/backup.log

# Se ejecuta el for de respaldo por cada base de datos usuario-> usuario mysql clave-> clave mysql, se escribe -pclave
for DB in `mysql -e "show databases" -u usuario -pclave | grep -v Database`; 
do 
	mysqldump -u usuario -pclave $DB | gzip > "$DIRECTORIO/$DB.sql.gz";
	echo "Base de dato respaldada $DB `date`" >> $ROOT_DIR/backup.log
done

# Se envia el respaldo completo de las base de datos comprimidas al servidor de backup
echo "Enviando respaldo a servidor de backup  `date`" >> $ROOT_DIR/backup.log
# aqui utiliza el usuario y la clave de conexion remota del servidor de respaldo y el nombre dl servidor
tar czf - $DIRECTORIO | ncftpput -u usuario -p clave -c servidor Backup.tar.gz

# Para descargar el respaldo del servidor de backup
# ncftpget -v -u usuario -p clave servidor /home/backup /Backup.tar.gz

# Elimina respaldos anteriores a 7 dias en este servidor, el externo es diario siempre
for i in `find /home/backup/* -maxdepth 1 -type d -mtime 7 -print`
do
        echo "Borrando respaldo obsoleto $i" >> $ROOT_DIR/backup.log;
        rm -rf $i; 
done

# Se escribe en el log el resultado final
echo "Respaldo realizado exitosamente el `date`" >> $ROOT_DIR/backup.log


