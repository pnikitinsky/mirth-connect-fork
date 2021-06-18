FROM openjdk:11-jre

ENV MIRTH_CONNECT_VERSION 3.11.0.b2609

# Mirth Connect is run with user `connect`, uid = 1000
# If you bind mount a volume from the host or a data container,
# ensure you use the same uid
RUN useradd -u 1000 mirth && \
  # then update and install requirements
  apt-get update && \
  apt-get install -y --no-install-recommends ca-certificates wget && \
  # grab gosu for easy step-down from root
  set -eux && \
  apt-get install -y gosu && \
  apt-get autoremove -y && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/* && \
  # verify that the binary works
  gosu nobody true

# Expose mirth appdata volume
VOLUME /opt/mirth-connect/appdata

# Download and install Mirth Connect
RUN \
  cd /tmp && \
  wget https://s3.amazonaws.com/downloads.mirthcorp.com/connect/$MIRTH_CONNECT_VERSION/mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  tar xvzf mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  rm -f mirthconnect-$MIRTH_CONNECT_VERSION-unix.tar.gz && \
  mkdir -p /opt/mirth-connect && \
  mv Mirth\ Connect/* /opt/mirth-connect/ && \
  chown -R mirth /opt/mirth-connect

WORKDIR /opt/mirth-connect

# Expose the default Mirth Ports
EXPOSE 8080 8443

COPY docker-entrypoint.sh /
RUN chmod +x /docker-entrypoint.sh
ENTRYPOINT ["/docker-entrypoint.sh"]

CMD ["java", "-jar", "mirth-server-launcher.jar"]