include:
  - 3_HST.ccorg.secrets
  - letsencrypt
  - mysql
  - php

letsencrypt:
  post_hooks:
    restart_apache2.sh: /usr/sbin/service apache2 reload
mounts:
  - spec: /dev/xvdf
    file: /var/www
    type: ext4
    opts: defaults
    freq: 0
    pass: 2
# Also see pillars/php/init.sls
php:
  apache2:
    ini:
      settings:
        PHP:
          post_max_size: 41M
          upload_max_filesize: 40M
states:
  mount: {{ sls }}
  wordpress.apache2: {{ sls }}
  wordpress.ccorg: {{ sls }}
wordpress:
  multisite: False
  site_conf: creativecommons_org.conf
