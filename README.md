Docker Moodle LMS
-----------------

This is the Docker Image for The Moodle LMS

Included: MySQL 5.4, Apache2 + PHP5, Moodle 2.9


QuickStart
----------

```
$ docker docker build --force-rm
$ docker build --force-rm --tag="YOURNAME/moodle:2.9" .
$ docker run --rm --name moodle -v /localfs/moodle/mysql_data:/var/lib/mysql -v /localfs/moodle/moodledata:/opt/moodle/moodledata -p 80:80 moodle:2.9
```

=> Access to [http://localhost](http://localhost), Let's begin install !

NOTE: build estimate time is about 5 minutes. (git clone moodle is very slow so big repo)


Spec
----

Volumes:

* `/var/lib/mysql` : MySQL data
* `/opt/moodle/moodledata` : Moodle's anything data (Cache, localization and more)


Customize
---------

### Change URL ###

Edit line `$CFG->wwwroot = 'http://localhost';` in `/localfs/moodle/moodledata/config.php` 

e.g.) `$CFG->wwwroot = 'https://example.jp';`

NOTE: Not support running under the sub-directory.


NOTES
-----

Original is Peter John <peter@playlyfe.com> THX!!

EoT
