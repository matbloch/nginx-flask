FROM python:3.7.2-alpine

COPY requirements.txt /tmp/requirements.txt
RUN pip3 install -r /tmp/requirements.txt

COPY . /api
WORKDIR /api

EXPOSE 5000
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "3", "--capture-output", "wsgi:app"]