#!/bin/bash
set -ue


# This is required so that the default configuration file works.
source /home/www-data/biostar-central/live/custom.env

# Setting the various access logs.
ACCESS_LOG=/home/www-data/biostar-central/live/logs/celery-access.log
ERROR_LOG=/home/www-data/biostar-central/live/logs/celery-error.log

# The user and group the unicorn process will run as.
NUM_WORKERS=3

# The name of the application.
NAME="biostar"

# The gunicorn instance to run.
CELERY="/home/www-data/.virtualenvs/biostarsenv/bin/celery"

echo "starting celery worker with DJANGO_SETTINGS_MODULE=$DJANGO_SETTINGS_MODULE"

exec $CELERY -A $NAME worker -l info

