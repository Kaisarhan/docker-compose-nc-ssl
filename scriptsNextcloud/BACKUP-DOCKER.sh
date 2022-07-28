#!/bin/bash
# Этот скрипт бэкапирует весь NextCloud

# Включаем режим ОБСЛУЖИВАНИЕ
#docker exec -u www-data app-server php occ maintenance:mode --on

# Архивируем корневой каталог NextCloud

	#архивация с полным путем
#sudo tar -cvzf /mnt/nc-backup/nc-folder-backup_`date +%d-%m-%Y`.tar.gz /home/nc/docker-compose-nextcloud/data

	#архивация определенного каталога
cd /home/nc
sudo tar --exclude='/home/nc/docker-compose-nextcloud/data' -cvzf /mnt/nc-backup/BACKUP-docker-compose-nc.tar.gz /home/nc/docker-compose-nextcloud

	# или
#cd /home/nc/docker-compose-nextcloud
#sudo tar -cvzf /mnt/nc-backup/nc-folder-backup_`date +%d-%m-%Y`.tar.gz data

# Экспортируем DB
#docker exec -t db pg_dumpall -c -U postgres > /mnt/nc-backup/nc-db-backup_`date +%d-%m-%Y`.sql

# Выключаем режим ОБСЛУЖИВАНИЕ
#docker exec -u www-data app-server php occ maintenance:mode --off





# Как развернуть BackUP NC
# Разархивация каталога Nextcloud ->sudo tar -xvf bunctest.tar.gz
# Выгрузка Backup DB ->cat test_backup_nextcloud_`date +%d-%m-%Y`.sql | docker exec -i db psql -U postgres
# Выключить режим обслуживания ->docker exec -u www-data app-server php occ maintenance:mode --off
