FROM ubuntu:cosmic
COPY . /harness-cli
RUN apt update && \
    apt install python3 python3-pip curl -y && \
    pip3 install pytz && \
    pip3 install datetime && \
    pip3 install argparse && \
    cd /harness-cli/python-sdk/ && python3 setup.py install && \
    apt autoremove && \
    rm -rf /harness-cli/python-sdk && \
    rm -rf /var/apt/cache/*
CMD ["tail", "-f", "/dev/null"]
