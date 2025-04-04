FROM golang:1.24 AS build
ARG VERSION
ARG GIT_COMMIT
WORKDIR /app
RUN wget -qO- https://github.com/kiurchv/external-dns/archive/${GIT_COMMIT}.tar.gz | tar -xzf - --strip-components=1
RUN make build

FROM gcr.io/distroless/static-debian12
COPY --from=build /app/build/external-dns /external-dns
EXPOSE 7979
ENTRYPOINT ["/external-dns"]
