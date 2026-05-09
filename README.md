# Тестовое задание MobilePark

---

## Задача 1 — Ansible: подготовка серверов

**Директория:** `task1-ansible/`

### Реализовано

- Создание пользователей: администраторы `admin-1`, `admin-2`, `admin-3` и технические аккаунты `ansible`, `autodeploy`
- SSH: только ключевая аутентификация, вход под `root` запрещён
- Установка пакетов: `mc`, `ncdu`, `cifs-utils`, `nfs-common`
- Установка Docker фиксированной версии из стандартного репозитория Ubuntu (`docker.io`)
- Ввод серверов в Docker Swarm кластер с лейблом `SERVERTYPE=worker`

### Запуск

```bash
cd task1-ansible

ansible-playbook site.yml

ansible-playbook site.yml --check --diff
```

---

## Задача 2 — Docker: улучшение Dockerfile

**Директория:** `task2-docker/`

### Исходный Dockerfile (с проблемами)

```dockerfile
FROM python
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
EXPOSE 5000
CMD ["python", "app.py"]
```

### Проблемы исходного файла

| Проблема | Последствие |
|---|---|
| `FROM python` — нет версии | Непредсказуемые сборки, разные версии на разных машинах |
| Образ не slim | Лишние ~800 МБ в итоговом образе |
| `COPY . .` до установки зависимостей | Кеш `pip install` сбрасывается при любом изменении кода |
| Запуск от `root` | Уязвимость: компрометация приложения = root на хосте |
| Нет `HEALTHCHECK` | Оркестратор не знает, живо ли приложение |
| Нет `--no-cache-dir` | Лишний кеш pip увеличивает размер образа |
---

## Задача 3 — Docker Swarm: compose-стек

**Директория:** `task3-swarm/`

### Что реализовано

Docker Compose файл для развёртывания стека в Docker Swarm:

- Сервис `ubuntu-worker` на базе `ubuntu:22.04`
- Подключение к внешним сетям `db-postgres-net` и `ds-redis-net`
- 2 реплики с размещением на нодах с лейблом `SERVERTYPE=worker`
- Бесшовное обновление (rolling update): по 1 реплике, старт новой до остановки старой
- Volume для логов на хост-сервер: `/var/log/mp-ubuntu-worker`
- Лимиты: 1 CPU, 500 МБ RAM; логи: 1 файл × 5 МБ
- Переменная окружения `HOSTNAME` с именем ноды через `{{.Node.Hostname}}`

### Запуск стека

```bash
docker stack deploy -c task3-swarm/docker-compose.yml mp-stack

# Демонстрация подключения к PostgreSQL и Redis
bash task3-swarm/connect_and_test.sh mp-stack
```
