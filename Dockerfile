FROM ubuntu:stable

# Install aws kms dependencies
RUN apt update && apt install -y libjson-c libssl1.1

# Install aws kms
COPY aws-kms-pkcs11/aws-kms-pkcs11.so /usr/local/lib/

# Copy all aws sdk cpp lib
COPY vcpkg/installed/x64-linux-dynamic/lib/* /usr/local/lib/

# Copy SCEP server images
COPY scep-pkcs11/cmd/scepserver/scepserver /usr/bin/scepserver


EXPOSE 8080

ENTRYPOINT ["/usr/bin/scepserver"]
