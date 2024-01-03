#!/bin/sh

echo "Начало работы скрипта..."

# Путь к исходному файлу конфигурации
SOURCE_CONF="/opt/pgpro/init/postgresql.conf"
# Путь к целевой директории
TARGET_DIR="/opt/pgpro/data"

# Путь к исполняемому файлу pg_ctl
PG_CTL=$(which pg_ctl)

# Путь к каталогу данных PostgreSQL
PG_DATA="/var/lib/pgsql/data"

# Проверяем, существует ли файл конфигурации
if [ -f "$SOURCE_CONF" ]; then
  echo "Файл конфигурации найден: $SOURCE_CONF"
  
  # Копируем файл с заменой в целевую папку
  echo "Копирование файла конфигурации в $TARGET_DIR"
  cp -f "$SOURCE_CONF" "$TARGET_DIR" && echo "Копирование успешно завершено." || echo "Ошибка копирования."

  # Проверяем, установлен ли параметр include_dir и получаем его значение
  INCLUDE_DIR=$(grep -E '^include_dir\s*=\s*' "$SOURCE_CONF" | cut -d"'" -f2)
  
  # Если параметр установлен и директория существует
  if [ -n "$INCLUDE_DIR" ] && [ -d "/opt/pgpro/init/$INCLUDE_DIR" ]; then
    # Копируем директорию
    echo "Копирование директории $INCLUDE_DIR в $TARGET_DIR"
    cp -r "/opt/pgpro/init/$INCLUDE_DIR" "$TARGET_DIR" && echo "Копирование директории успешно завершено." || echo "Ошибка копирования директории."
  else
    echo "Параметр include_dir не установлен или директория не существует."
  fi

  # Меняем владельца скопированных файлов и папок на postgres:postgres
  echo "Изменение владельца файлов и папок на postgres:postgres"
  chown -R postgres:postgres "$TARGET_DIR" && echo "Владелец успешно изменён." || echo "Ошибка при изменении владельца."

  # Перезапускаем сервер PostgreSQL
  echo "Перезапуск сервера PostgreSQL"
  $PG_CTL restart && echo "Сервер PostgreSQL успешно перезапущен." || echo "Ошибка при перезапуске сервера PostgreSQL."

else
  echo "Файл конфигурации $SOURCE_CONF не найден. Прерывание работы скрипта."
  exit 1
fi

echo "Скрипт завершил работу."
exit 0
