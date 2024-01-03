# Postgres-pro для 1с

## Краткое описание

Это набор образов с PostgreSQL для 1с.

В данном образе используется сборка доступная на сайте [https://1c.postgres.ru/](https://1c.postgres.ru/)

## Скрипт запуска

При запуске контейнера активируется скрипт, который выполняет следующие действия:

* Поиск и копирование конфигурации: Скрипт ищет предварительно заданный файл конфигурации в `/opt/pgpro/init/postgresql.conf` и копирует его в рабочую директорию PostgreSQL.
* Обработка директивы include_dir: Если в файле конфигурации указана директива include_dir, скрипт также копирует указанную директорию с дополнительными настройками.

## Пример использования

```yaml
version: '3.8'

services:
  srv:
    image: my-registry.com/onec-server:8.3.23.1997
    hostname: sw-01.eff-tex.lan
    environment:
      - PORT=1540
      - REGPORT=1541
      - RANGE=1560:1591
      - SECLEVEL=0
      - PINGPERIOD=1000
      - PINGTIMEOUT=5000
      - DEBUG=-http
      - DEBUGSERVERPORT=1550
      - RAS_PORT=1545
    ports:
      - "1540-1541:1540-1541"
      - "1560-1591:1560-1591"
      - "1545:1545"
      - "1550:1550"
      - "9095:9095"
    volumes:
      - 1c_srv_data:/home/usr1cv8/.1cv8
      - 1c_srv_log:/var/log/1C
      - 1c_srv_conf:/opt/1cv8/current/conf/
      - 1c_srv_lic:/var/1C/licenses
    networks:
      - 1c_back_net

  db:
    image: segateekb/pg_pro:15
    hostname: db
    ports:
      - "5432:5432"
    environment:
      - DEBUG=false
      - PG_TRUST_LOCALNET=true
      - POSTGRES_PASSWORD=supersecurepwd
    volumes:
      - /etc/localtime:/etc/localtime:ro
      - pg_data:/opt/pgpro/data
      # Каталог преднастроеной конфигурации postgresql.conf
      - ./conf_example:/opt/pgpro/init/
      - pg_1c:/opt/pgpro/1C/
      - pg_1c_data:/opt/pgpro/1C/data
      - pg_1c_index:/opt/pgpro/1C/index
    networks:
     1c_back_net:
      aliases:
        - db

networks:
  1c_back_net:
    external: true


volumes:
  1c_srv_data:
  1c_srv_log:
  1c_srv_conf:  
  1c_srv_lic:
  pg_data:   
  pg_1c:
  pg_1c_data:
  pg_1c_index:
```

## Помощь в разработке

* Все ошибки связанные с данным образом можно фиксировать [Здесь](https://github.com/Segate-ekb/pg_pro_1c/issues)
* Там же можно посмотреть пример конфигурации для `/opt/pgpro/init/`