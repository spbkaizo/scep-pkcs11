FROM debian:stable

COPY cmd/scepserver/scepserver /usr/bin/scepserver

EXPOSE 8080

ENTRYPOINT ["/usr/bin/scepserver"]
