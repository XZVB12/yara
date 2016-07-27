FROM malice/alpine

MAINTAINER blacktop, https://github.com/blacktop

COPY . /go/src/github.com/maliceio/malice-yara
COPY rules /rules
RUN apk-install openssl file jansson ca-certificates
RUN apk-install -t build-deps go git mercurial autoconf automake file-dev flex gcc git jansson-dev libc-dev libtool build-base openssl-dev \
  && set -x \
  && cd /tmp/ \
  && git clone --recursive --branch v3.4.0 git://github.com/plusvic/yara \
  && cd /tmp/yara \
  && ./bootstrap.sh \
  && ./configure --enable-cuckoo \
                 --enable-magic \
                 --with-crypto \
  && make \
  && make install \
  && echo "Building info Go binary..." \
  && cd /go/src/github.com/maliceio/malice-yara \
  && export GOPATH=/go \
  && export CGO_CFLAGS="-I/usr/local/include" \
  && export CGO_LDFLAGS="-L/usr/local/lib" \
  && go version \
  && go get \
  && go build -ldflags "-X main.Version=$(cat VERSION) -X main.BuildTime=$(date -u +%Y%m%d)" -o /bin/scan \
  && rm -rf /go /tmp/* \
  && apk del --purge build-deps

VOLUME ["/malware"]
VOLUME ["/rules"]

WORKDIR /malware

ENTRYPOINT ["/bin/scan"]

CMD ["--help"]
