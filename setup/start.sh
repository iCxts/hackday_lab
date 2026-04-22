#!/bin/bash
service postgresql start
service ssh start
service apache2 start
tail -f /dev/null
