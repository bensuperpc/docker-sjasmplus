ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS builder

RUN apk add --no-cache gcc g++ make ninja boost-dev cmake git \
	&& git clone --recurse-submodules https://github.com/sjasmplus/sjasmplus.git
WORKDIR /sjasmplus

RUN mkdir -p build && cd build && cmake -GNinja .. && ninja

ARG DOCKER_IMAGE=alpine:latest
FROM $DOCKER_IMAGE AS runtime

LABEL author="Bensuperpc <bensuperpc@gmail.com>"
LABEL mantainer="Bensuperpc <bensuperpc@gmail.com>"

ARG VERSION="1.0.0"
ENV VERSION=$VERSION

RUN apk add libgcc libstdc++ make --no-cache make

COPY --from=builder /sjasmplus/build /usr/local

ENV PATH="/usr/local:${PATH}"

ENV CC=/usr/local/bin/sjasmplus
WORKDIR /usr/src/myapp

CMD ["sjasmplus"]

LABEL org.label-schema.schema-version="1.0" \
	  org.label-schema.build-date=$BUILD_DATE \
	  org.label-schema.name="bensuperpc/docker-sjasmplus" \
	  org.label-schema.description="build tinycc compiler" \
	  org.label-schema.version=$VERSION \
	  org.label-schema.vendor="Bensuperpc" \
	  org.label-schema.url="http://bensuperpc.com/" \
	  org.label-schema.vcs-url="https://github.com/Bensuperpc/docker-sjasmplus" \
	  org.label-schema.vcs-ref=$VCS_REF \
	  org.label-schema.docker.cmd="docker build -t bensuperpc/sjasmplus -f Dockerfile ."