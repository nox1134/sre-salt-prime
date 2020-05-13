# Provides support for the Wordfence plugin, if it is installed
{% set DOCROOT = pillar.wordpress.docroot -%}
{% set WP_CONTENT = "{}/wp-content".format(DOCROOT) -%}
{% set PLUGINS = "{}/plugins".format(WP_CONTENT) -%}


{{ sls }} dir wp-content/plugins/wordfence:
  file.directory:
    - name: {{ PLUGINS }}/wordfence
    - mode: '2775'
    - user: composer
    - group: webdev
    - require:
      - composer: wordpress.composer_site composer update
      - group: user.webdevs webdev group
    - onlyif:
      - test -d {{ PLUGINS }}/wordfence


{{ sls }} dir wp-content/wflogs:
  file.directory:
    - name: {{ DOCROOT }}/wp-content/wflogs
    - mode: '2775'
    - user: composer
    - group: www-data
    - require:
      - file: {{ sls }} dir wp-content/plugins/wordfence
      - group: php_cc.composer www-data group
    - onlyif:
      - test -d {{ PLUGINS }}/wordfence
