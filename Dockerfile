FROM ubuntu:xenial
COPY . /harness-cli
RUN apt update && \
    apt install python3 python3-pip -y 

RUN cd /harness-cli/python-sdk/ && python3 setup.py install && \
    apt autoremove && \
    rm -rf /harness-cli/python-sdk && \
    rm -rf /var/apt/cache/*
CMD ["tail", "-f", "/dev/null"]
