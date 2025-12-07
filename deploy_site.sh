#!/bin/bash

LOG="/var/log/deploy.log"
FILE="/var/www/html/index.html"
TS() { date '+%F %T'; } # TimeStamp formatting Year-Month-Day and time in HH:MM:SS

echo "$(TS) START deploy"            >> "$LOG"

if nc -z localhost 80; then
  echo "$(TS) Server listening on port 80"   >> "$LOG"
else
  echo "$(TS) Server not listening on port 80" >> "$LOG"
  exit 1
fi

if [ -s "$FILE" ]; then
  echo "$(TS) $FILE ok"           >> "$LOG"
else
  echo "$(TS) $FILE missing/empty" >> "$LOG"
  exit 1
fi

if systemctl restart apache2; then
  echo "$(TS) apache2 restarted"   >> "$LOG"
else
  echo "$(TS) apache2 failed"      >> "$LOG"
  exit 1
fi

echo "$(TS) END deploy"              >> "$LOG"
