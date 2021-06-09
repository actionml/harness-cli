# does not work properly
# bugs:
#  1) the harness-cli script is not executable, is not in the executable path

FROM ubuntu

ARG GIT_HASH
ARG DATE_BUILD
ARG BRANCH
ENV GIT_HASH=${GIT_HASH}
ENV DATE_BUILD=${DATE_BUILD}
ENV BRANCH=${BRANCH}
ENV DEBIAN_FRONTEND=noninteractive

RUN mkdir -p /data
COPY . /harness-cli
ENV PATH=/harness-cli/harness-cli/:$PATH

RUN apt update && \
    apt-get install -y tzdata curl unzip && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && ./aws/install

RUN apt install -y python3 python3-pip curl openjdk-8-jdk && \
    pip3 install pytz && \
    pip3 install datetime && \
    pip3 install argparse && \
    cd /harness-cli/python-sdk/ && python3 setup.py install

RUN cd /harness-cli/diff-tool/ && make build && \
    apt autoremove && \
    rm -rf /harness-cli/python-sdk && \
    rm -rf /var/apt/cache/*
CMD ["tail", "-f", "/dev/null"]