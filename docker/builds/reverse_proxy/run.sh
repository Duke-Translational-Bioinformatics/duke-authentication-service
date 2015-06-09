#!/bin/bash
/sbin/service shibd start
/usr/sbin/httpd -DFOREGROUND -DSSL
