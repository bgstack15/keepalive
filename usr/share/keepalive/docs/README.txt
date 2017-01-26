File: etc/keepalive/README.txt
Package: keepalive 1.0-7
Author: bgstack15@gmail.com
Startdate: 2016-06-07
Title: Readme file for keepalive
Purpose: All packages should come with a readme
History: 
Usage: Read it.
Reference: README.txt
Improve:
Document: Below this line

### WELCOME
To use the keepalive program, start the service.
systemctl start keepalive.service

### REFERENCE

### CHANGELOG
keepalive 1.0-4 2016-06-07
Changed packaging so bgscripts is a prerequisite, not a corequisite package so framework.sh exists before keepalive service is started for the first time.
https://docs.fedoraproject.org/en-US/Fedora_Draft_Documentation/0.1/html/RPM_Guide/ch-advanced-packaging.html
https://www.debian.org/doc/debian-policy/ch-relationships.html

keepalive 1.0-5 2016-07-22
Rewrote the application in python3

2016-10-27 keepalive 1.0-6
Added scrub.py subpackage
Modified to be suitable for sharing on github
