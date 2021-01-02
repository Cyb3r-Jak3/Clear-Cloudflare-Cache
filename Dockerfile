FROM cyb3rjak3/docker-curl-ssh

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]