FROM ubuntu:16.04

RUN apt-get update && \
    apt-get -y install \
      apt-transport-https \
      curl \
      software-properties-common
      
ENV GOROOT="/usr/local/go"
ENV GOPATH="$HOME/go"
ENV PATH="$GOPATH/bin:$GOROOT/bin:$PATH"

#install azcopy
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    apt-add-repository https://packages.microsoft.com/ubuntu/16.04/prod && \
    apt-get update && \
    if [ `uname -m` = "aarch64" ] ; then \
      apt-get install -y git wget; \
      wget https://dl.google.com/go/go1.14.linux-arm64.tar.gz; \
      tar -xvf go1.14.linux-arm64.tar.gz; \
      mv go /usr/local; \
      git clone https://github.com/Azure/azure-storage-azcopy; \
      cd azure-storage-azcopy; \
      GOARCH=arm64 GOOS=linux go build -o azcopy_linux_arm64; \
    else \
      apt-get install -y azcopy; \
    fi

#install mongo cli tools
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4 && \
    if [ `uname -m` = "aarch64" ] ; then \
    echo "deb [ arch=arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list; \
    apt-get update && apt-get install -y mongodb-org-tools; \
    else \
    echo "deb [ arch=amd64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/4.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.0.list; \
    apt-get update && apt-get install -y mongodb-org-tools; \
    fi
    
WORKDIR /tmp

COPY backup_mongo.sh .
RUN chmod a+x backup_mongo.sh
ENTRYPOINT [ "./backup_mongo.sh" ]
