FROM debian:stable

# Copy SCEP server images
COPY cmd/scepserver/scepserver /usr/bin/scepserver

EXPOSE 8080

ENTRYPOINT ["/usr/bin/scepserver"]
