#!/bin/bash

VOLUME_HOME="/var/lib/mysql"

sed -ri -e "s/^upload_max_filesize.*/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" \
    -e "s/^post_max_size.*/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php5/apache2/php.ini
if [[ ! -d $VOLUME_HOME/mysql ]]; then
    echo "=> An empty or uninitialized MySQL volume is detected in $VOLUME_HOME"
    echo "=> Installing MySQL ..."
    mysql_install_db > /dev/null 2>&1
    echo "=> Done!"  
    /create_mysql_admin_user.sh
else
    echo "=> Using an existing volume of MySQL"
fi

mkdir -p ${APP_ROOT}/moodledata
chown -R www-data:www-data ${APP_ROOT}/moodledata
chmod 755 ${APP_ROOT}/moodledata
if [ ! -e ${APP_ROOT}/moodledata/config.php ]; then
	cat << EOT > ${APP_ROOT}/moodledata/config.php
<?php  // Moodle configuration file

unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype    = 'mysqli';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = 'localhost';
\$CFG->dbname    = 'moodle';
\$CFG->dbuser    = 'moodle';
\$CFG->dbpass    = 'moodle';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => '',
  'dbsocket' => '',
);

\$CFG->wwwroot   = 'http://localhost';
\$CFG->dataroot  = '${APP_ROOT}/moodledata';
\$CFG->admin     = 'admin';

\$CFG->directorypermissions = 0777;

require_once(dirname(__FILE__) . '/../app/lib/setup.php'); // modify from origin

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
EOT
fi
rm -f ${APP_ROOT}/app/config.php
ln -s ${APP_ROOT}/moodledata/config.php ${APP_ROOT}/app/config.php 

echo "=> I am $(ip route | grep eth0 | cut -f 12 -d " " | tr -d "\n")"
exec supervisord -n -c /etc/supervisor/supervisord.conf
