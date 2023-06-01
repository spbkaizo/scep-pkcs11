FROM ubuntu:latest

# Install aws kms dependencies
RUN apt update && apt install --no-install-recommends -y libjson-c5 awscli jq

### add required libs for pkcs11 provider
# ignore symlinks.
COPY vcpkg/installed/x64-linux-dynamic/lib/ /usr/local/lib/

# Install aws kms (depends on aws-sdk-cpp libs
COPY aws-kms-pkcs11/aws_kms_pkcs11.so /usr/local/lib/
# create required symlinks for above libs
RUN /usr/sbin/ldconfig

# Copy SCEP server images
COPY scep-pkcs11/cmd/scepserver/scepserver /usr/bin/scepserver
# Copy fake config so we can write to the filesystem
COPY scep-pkcs11/etc.aws-kms-pkcs11.config.json /tmp/aws-kms-pkcs11/config.json
RUN mkdir -p /etc/aws-kms-pkcs11/
RUN ln -s /tmp/aws-kms-pkcs11/config.json /etc/aws-kms-pkcs11/config.json
# Add startup.sh
COPY scep-pkcs11/startup.sh /startup.sh
RUN chmod 0755 /startup.sh
EXPOSE 8080

ENTRYPOINT ["/startup.sh"]
