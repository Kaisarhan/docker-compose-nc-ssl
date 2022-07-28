#!/bin/bash
#Перевыпуск ssl сертификатов 
docker-compose run certbot renew --dry-run #&& \ ## && \  это нужнго добавить, если certbot отработал все правильно 
#Рестартануть nginx после выпуска сертефикатов 
docker-compose restart nginx
