#!/bin/bash

# Запуск cron в фоне
service cron start

# Запуск основного процесса
/app/owlistic.run
