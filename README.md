## Document Server and Nextcloud Docker installation

Готовый написанный Docker-compose.yml 
Устанавливаются следующие контейнеры: 
1) Nextcloud 
2) OnlyOffice
3) Nginx
4) PostgreSQL
5) Certbot



## Requirements

* Docker (можно скачать здесь: [https://docs.docker.com/engine/installation/](https://docs.docker.com/engine/installation/))
* Docker compose (можно скачать здесь: [https://docs.docker.com/compose/install/](https://docs.docker.com/compose/install/))


## Installation

1. Установка Docker
    
    ```
    sudo apt install docker
    ```
    
2. Установка Docker-compose
    ```
    sudo apt install docker-compose
    ```    
3.1 Добавить пользователя в группу Docker
    
    sudo usermod -aG docker ${USER}
    
3.2 Рестартануть сервис

    sudo systemctl restart docker

4. Что бы подтянуть файлы на нашу станцию введите следующие команды:

    ```
    git clone https://github.com/Kaisarhan/docker-compose-nc-ssl
    ```

5. Run Docker Compose:
    Прежде чем запустить команду нужно войти в каталог **docker-compose-nextcloud**.

    ```
    docker-compose up -d
    ```

    **Обратите внимание**: Вам может потребоваться подождать пару минут, когда все контейнеры будут запущены и будут работать после указанной выше команды.

3. Теперь запустите браузер и введите адрес веб-сервера. Откроется веб-страница мастера Nextcloud здесь же нужно указать вашу БД PostgreSQL. Введите все необходимые данные для завершения работы мастера.

Ваш сервер: db

Ваша база данных: nextcloud

Имя пользователя db: postgres

Пароль нужно будет указать в Docker-compose.yml

Пароль бд указывается в docker-compose.yml **POSTGRES_PASSWORD=ваш пароль**


7. Устанавливаем **OnlyOffice** в NextCloud перейдите в папку проекта и запустите скрипт `set_configuration.sh`:

    **Обратите внимание**: действие должно производиться с правами **root**.

    ```
    bash set_configuration.sh
    ```

Теперь вы можете войти в Nextcloud и создать новый документ. Он будет открыт на Сервере документов ONLYOFFICE.

## BackUp.
**NextCloud:**

* Переход в режим обслуживание. Что бы пользователи не могули вносить изменения.

    ```
    docker exec -u www-data container_name php occ maintenance:mode --on
    ```
* Архивируем корневые папки и файлы NextCloud

    ```
    sudo tar -cvzf /mnt/path/archiv-name_`date +%d-%m-%Y`.tar.gz data
    ```  
    
**Postgres:**

* Backup-ируем всю DB

    ```
    docker exec -t db pg_dumpall -c -U postgres > /mnt/path/BackupSql-name_`date +%d-%m-%Y`.sql
    ```
    
**NextCloud:** 

* После завершения Backup-ирования не забудьте выключить режим обслуживание.
    ```
    docker exec -u www-data container_name php occ maintenance:mode --off
    ```        
## Restore.
**NextCloud:**

* Переход в режим обслуживание. Что бы пользователи не могули вносить изменения.

    ```
    docker exec -u www-data container_name php occ maintenance:mode --on
    ```
* Разархивируем корневые папки и файлы NextCloud

    ```
    sudo tar -xvf archiv-name.ter.gz
    ```    
**Postgres:**

* Restore DB

    ```
    cat BackupSql-name_`date +%d-%m-%Y`.sql | docker exec -i db psql -U postgres
    ```
**NextCloud:**

* После завершения восстановления не забудьте выключить режим обслуживание.

    ```
    docker exec -u www-data container_name php occ maintenance:mode --off
    ```        


## SSL Certbot.
**Docker-compose**

* Укажите свой данные для Certbot в command: you_mail, you_domain. Детальную информацию можете найти в интернете 

```
certbot:
    container_name: certbot-server
    image: certbot/certbot
    depends_on:
      - nginx
    volumes:
      - ./data/app_data:/var/www/html
      - ./data/certbot/conf:/etc/letsencrypt
      - ./data/certbot/logs:/var/log/letsencrypt
    command: certonly --webroot --webroot-path=/var/www/html --email you_mail@mail.kz --agree-tos --no-eff-email -d you_domain.kz
```

**Nginx**

* После запуска docker-compose нужно будет редактировать __nginx.conf__ в директорий __/nginx/nginx.conf__ нужно добавить SERVER и коректировать под свой домен
    ```
    server {
       listen 443 ssl http2;
       ssl_certificate /etc/letsencrypt/live/you_domain.kz/fullchain.pem;
       ssl_certificate_key /etc/letsencrypt/live/you_domain.kz/privkey.pem;
       ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
       ssl_ciphers  "HIGH:!RC4:!aNULL:!MD5:!kEDH";

        include /etc/nginx/nginx_http.conf;
    }
    ```
    
**NextCloud**

* Корректируем конфигурацию NextCloud для перехода на протокол https по директорий __data/app_data/config/config.php__ 
  самое главное добавить __'overwriteprotocol' => 'https'__
```php
   <?php
$CONFIG = array (
  'overwritehost' => 'you_domain.kz',
  'defaultapp' => 'files',
  'overwriteprotocol' => 'https',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'apps_paths' =>
  array (
    0 =>
    array (
      'path' => '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    1 =>
    array (
      'path' => '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => true,
    ),
  ),
  'instanceid' => 'ocxknj5xyfpj',
  'passwordsalt' => 'iEdwMfNLHFyRHO5Bk1Axcbtasdqwezxcv',
  'secret' => '9ACC3fdeF1xvXsHwJOJXEAgpUvCm+jy6loFs7rmJzxcvasfkgnjswiughj4qRGbit',
  'trusted_domains' =>
  array (
    0 => '192.168.1.225',   <---- тут ваш ip в локальной сети 
    1 => 'you_domain.kz',
  ),
  'datadirectory' => '/var/www/html/data',
  'dbtype' => 'pgsql',
  'version' => '24.0.1.1',
  'overwrite.cli.url' => 'http://192.168.1.225',    <---- тут ваш ip в локальной сети 
  'dbname' => 'nextcloud',
  'dbhost' => 'db',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'dbuser' => 'oc_admin',
  'dbpassword' => 'cxIWB3rlvi1dohwFHfssGv2p85LqweqweasmjiughLYSamwerijn',
  'installed' => true,
  'onlyoffice' =>
  array (
    'DocumentServerUrl' => '/ds-vpath/',
    'DocumentServerInternalUrl' => 'http://onlyoffice-document-server/',
    'StorageUrl' => 'http://nginx-server/',
  ),
  'allow_local_remote_servers' => 'true',
);
```    
## Все команды каторый возможно помогут вам.

**Docker-compose**

* Команда для входа в контейнер и выполнять команды из контейнера:
    ```
   docker exec -it container_name bash
    ```
* Команды для удаление Container images и container volume
    
    Список оброзов 
    
    ```
    docker images -a
    ```
    
    Удаление всех оброзов
    ```
    docker system prune -a
    ```
* Команда для удаление volumes
    
    Список volumes
    ```
    docker volume ls
    ```
    
    Удаления всех volume
    ```
    docker volume prune
    ```
**NextCloud:**

* Переход в режим обслуживание. Если нужно будет выключить режим обслуживание поменяйте значение на --off

    ```
    docker exec -u www-data container_name php occ maintenance:mode --on
    ```
     ```
    docker exec -u www-data container_name php occ maintenance:mode --off
    ```
    
**Postgres:**

* BackUp database Postgres вариант 1-ый (не рекомендую так как я сам еще не разобрался в этом варианте)
    
    ```
    docker exec container_name pg_dump -c -U postgres_user db_name > new_backup_name`date +"%Y%m%d"`.dump
    ```
    или как на официальном сайте рекомендуют использовать следующую команду
    ```
    docker exec db pg_dump -U postgres -f nextcloud > nextcloud-sqlbkp_`date +"%Y%m%d"`.bak
    ```
* BackUp database Postgres вариант 2-ой

    **BackUp DB**
    ```
    docker exec -t container_name pg_dumpall -c -U postgres > your-dump-name_`date +%d-%m-%Y`.sql
    ```
    **Restore**
    ```
    cat your-dump-name_`date +%d-%m-%Y`.sql | docker exec -i container_name psql -U postgres
    ```
    
**CertBot:**

* Перевыпуск ssl сертификатов
    
    ```
    docker-compose run certbot renew --dry-run
    ```
* Рестартануть nginx после выпуска сертефикатов
    
    ```
    docker-compose restart nginx
    ```
