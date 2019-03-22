FROM python:3.6-slim-stretch
COPY . /harness-cli
CMD ["tail", "-f", "/dev/null"]
