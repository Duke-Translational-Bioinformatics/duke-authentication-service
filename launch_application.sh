#!/bin/bash

if [ -z $COMPOSE_FILE ]
then
  docker-compose up -d
  docker-compose -f dc-dev.utils.yml run rake db:migrate
  docker-compose -f dc-dev.utils.yml run consumer
else
  docker-compose up -d rproxy
  docker-compose run rake db:migrate
  docker-compose run consumer
fi
