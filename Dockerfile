FROM debian:stable

# Install aws kms dependencies
RUN apt update && apt install -y libjson libssl1.1

# Install aws kms
COPY aws-kms-pkcs11/aws_kms_pkcs11.x86_64.so /tmp/
RUN install -m 0644 -o root -g bin /tmp/aws_kms_pkcs11.x86_64.so /usr/lib/

# Copy SCEP server images
COPY cmd/scepserver/scepserver /usr/bin/scepserver


EXPOSE 8080

ENTRYPOINT ["/usr/bin/scepserver"]
