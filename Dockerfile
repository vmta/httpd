FROM python:alpine
WORKDIR /opt/html
COPY *.py /opt/
EXPOSE 80
ENTRYPOINT [ "python3", "/opt/server.py" ]
