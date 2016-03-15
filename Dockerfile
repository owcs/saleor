FROM python:3.5
ENV PYTHONUNBUFFERED 1

# Get latest Node source
RUN curl -sL https://deb.nodesource.com/setup_5.x | bash -

RUN \
 apt-get -y update && \
 apt-get install -y nodejs && \
 apt-get clean

ADD requirements.txt /app/requirements.txt
RUN cd /app && pip install -r requirements.txt

ADD package.json /app/package.json
RUN cd /app && npm install

RUN useradd -ms /bin/bash saleor

ADD . /app
WORKDIR /app

ENV PATH $PATH:/app/node_modules/.bin
RUN grunt
RUN SECRET_KEY=tmpkey python manage.py collectstatic --noinput

EXPOSE 8000
ENV PORT 8000

ENTRYPOINT ["/app/compose/entrypoint.sh"]

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
# CMD ["uwsgi saleor/wsgi/uwsgi.ini"]
