#!/bin/bash

mkdir -p ./_h
cat /usr/local/share/sdcc/include/sms/SMSlib.h > ./_h/SMSlib.h
cat /usr/local/share/sdcc/include/sms/PSGlib.h > ./_h/PSGlib.h

echo 'Header files exported to ./_h folder'
