FROM alpine

# Install required packages
RUN apk update
RUN apk add curl git bash

# Set kubectl command
RUN curl -o /usr/local/bin/kubectl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x /usr/local/bin/kubectl

# Copy app directory
COPY app /opt/app

# Define workdir
WORKDIR /opt/app

ENTRYPOINT [ "./run.sh" ]
