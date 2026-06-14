FROM alpine:3.18

RUN apk add --no-cache \
    ansible \
    openssh-client \
    sshpass \
    git \
    rsync \
    bash \
    python3 \
    py3-pip

# Ensure proper permissions for SSH
RUN mkdir -p ~/.ssh && \
    chmod 700 ~/.ssh

WORKDIR /ansible

# By default, verify the installation
CMD ["ansible-playbook", "--version"]
