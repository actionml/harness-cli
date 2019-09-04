# does not work properly
# bugs:
#  1) the harness-cli script is not executable, is not in the executable path

FROM ubuntu:cosmic

ARG GIT_HASH
ARG DATE_BUILD
ENV GIT_HASH=${GIT_HASH}
ENV DATE_BUILD=${DATE_BUILD}

COPY . /harness-cli
ENV PATH=/harness-cli/harness-cli/:$PATH
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
