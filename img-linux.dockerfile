#
# Container Image Tomcat
#

FROM alpine:3.16.2

ARG PROJ_NAME
ARG PROJ_VERSION
ARG PROJ_BUILD_NUM
ARG PROJ_BUILD_DATE
ARG PROJ_REPO
ARG OPENJDK_VERSION

LABEL org.opencontainers.image.authors="V10 Solutions"
LABEL org.opencontainers.image.title="${PROJ_NAME}"
LABEL org.opencontainers.image.version="${PROJ_VERSION}"
LABEL org.opencontainers.image.revision="${PROJ_BUILD_NUM}"
LABEL org.opencontainers.image.created="${PROJ_BUILD_DATE}"
LABEL org.opencontainers.image.description="Container image for Tomcat"
LABEL org.opencontainers.image.source="${PROJ_REPO}"

RUN apk update \
	&& apk add --no-cache "shadow" "bash" \
	&& usermod -s "$(command -v "bash")" "root"

SHELL [ \
	"bash", \
	"--noprofile", \
	"--norc", \
	"-o", "errexit", \
	"-o", "nounset", \
	"-o", "pipefail", \
	"-c" \
]

ENV LANG "C.UTF-8"
ENV LC_ALL "${LANG}"
ENV CATALINA_HOME "/opt/tomcat"
ENV PATH "${CATALINA_HOME}/bin:${PATH}"

RUN apk add --no-cache \
	"ca-certificates" \
	"curl" \
	"openjdk${OPENJDK_VERSION}-jre-base" \
	"tomcat-native"

RUN groupadd -r -g "480" "tomcat" \
	&& useradd \
		-r \
		-m \
		-s "$(command -v "nologin")" \
		-g "tomcat" \
		-c "Tomcat" \
		-u "480" \
		"tomcat"

WORKDIR "/tmp"

RUN PROJ_VERSION_PARTS=(${PROJ_VERSION//\./ }) \
	&& curl -L -f -o "tomcat.tar.gz" "https://archive.apache.org/dist/tomcat/tomcat-${PROJ_VERSION_PARTS[0]}/v${PROJ_VERSION}/bin/apache-tomcat-${PROJ_VERSION}.tar.gz" \
	&& mkdir -p "${CATALINA_HOME}" \
	&& tar -x -f "tomcat.tar.gz" -C "${CATALINA_HOME}" --strip-components "1" \
	&& rm "tomcat.tar.gz"

WORKDIR "${CATALINA_HOME}"

RUN chmod -R "+rX" "." \
	&& folders=("webapps" "conf/Catalina" "logs" "temp" "work") \
	&& for folder in "${folders[@]}"; do \
		mkdir -p "${folder}" \
		&& chmod "700" "${folder}" \
		&& chown -R "480":"480" "${folder}"; \
	done

WORKDIR "/"
