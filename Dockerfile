FROM debian:stable

# Copy SCEP server images
COPY cmd/scepserver/scepserver /usr/bin/scepserver

#RUN apt update && apt install -y libjson-c libp11

EXPOSE 8080

ENTRYPOINT ["/usr/bin/scepserver"]
