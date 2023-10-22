FROM alpine:latest

# Обновляем и устанавливаем необходимые пакеты postgresql-contrib postgresql-dev gcc
RUN apk update && apk add postgresql  python3-dev musl-dev psycopg

# Создайте и установите рабочий каталог внутри контейнера
ENV HOME=/home/app
ENV APP_HOME=/home/app/web
RUN mkdir -p $APP_HOME
RUN mkdir $APP_HOME/static
WORKDIR $APP_HOME

# Устанавливаем и обновляем pip
RUN python3 -m ensurepip && pip3 install --upgrade pip

# Установка зависимостей Python
COPY requirements.txt $APP_HOME
RUN pip3 install -r requirements.txt

# Копирование кода проекта в контейнер
COPY . $APP_HOME

# Установка Django и Gunicorn
RUN pip3 install gunicorn

# Устанавливаем и настраиваем Nginx
RUN apk add nginx && mkdir -p /run/nginx && mkdir -p /usr/share/nginx/html && echo "Hello, Docker!" > /usr/share/nginx/html/index.html
COPY nginx/config/nginx.conf /etc/nginx/http.d/default.conf


# Определение переменных для PostgreSQL
ENV POSTGRES_USER=postgres
ENV POSTGRES_PASSWORD=postgres
ENV POSTGRES_DB=postgres
ENV POSTGRES_HOST=0.0.0.0
ENV POSTGRES_PORT=5432

# Конфигурирование PostgreSQL
RUN mkdir -p /run/postgresql && chown -R postgres:postgres /run/postgresql
RUN mkdir -p /var/lib/postgresql/data && chown -R postgres:postgres /var/lib/postgresql/data

USER postgres
RUN initdb -D /var/lib/postgresql/data && \
    pg_ctl start -D /var/lib/postgresql/data && \
    echo "USER PASSWORD 'postgres';"postgres | psql && \
    pg_ctl stop -D /var/lib/postgresql/data

USER root
# Команда для запуска всех сервисов
CMD su postgres -c 'pg_ctl start -D /var/lib/postgresql/data' &&\
 sleep 2 &&\
 python3 manage.py migrate &&\
 python3 manage.py createadminuser &&\
 python manage.py collectstatic --noinput &&\
 nginx &&\
 gunicorn DeployProject.wsgi:application -b 0.0.0.0:8000 &&\
 django-admin runserver

#RUN python manage.py collectstatic --noinput
#  RUN django-admin runserver
# RUN python shell -c "from django_superuser_admin --username admin --email ddd@ya.ru"

# Открываем порты
EXPOSE 5432
EXPOSE 80
EXPOSE 8000
