FROM ubuntu
RUN apt-get update && \
    apt-get install -y software-properties-common curl && \
    curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add - && \
    apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main" && \
    apt-get update --fix-missing -y && \
    apt-get install -y terraform python3-pip

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get install -y awscli
                                                            
RUN pip3 install checkov

COPY . /app
WORKDIR /app

VOLUME /app

ENTRYPOINT ["/bin/sh"]