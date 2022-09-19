#
# Container Image Tomcat
#

.PHONY: container-run-linux
container-run-linux:
	$(BIN_DOCKER) container create \
		--platform "$(PROJ_PLATFORM_OS)/$(PROJ_PLATFORM_ARCH)" \
		--name "tomcat" \
		-h "tomcat" \
		-u "480" \
		--entrypoint "catalina.sh" \
		--net "$(NET_NAME)" \
		-p "443":"443" \
		--health-start-period "10s" \
		--health-interval "10s" \
		--health-timeout "8s" \
		--health-retries "3" \
		--health-cmd "tomcat-healthcheck \"443\" \"8\"" \
		"$(IMG_REG_URL)/$(IMG_REPO):$(IMG_TAG_PFX)-$(PROJ_PLATFORM_OS)-$(PROJ_PLATFORM_ARCH)" \
		run
	$(BIN_FIND) "bin" -mindepth "1" -type "f" -iname "*" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "0" --group "0" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "tomcat":"/opt/tomcat"
	$(BIN_FIND) "conf" -mindepth "1" -type "f" -iname "*" ! -iname "tls-key.pem" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "0" --group "0" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "tomcat":"/opt/tomcat"
	$(BIN_FIND) "conf" -mindepth "1" -type "f" -iname "tls-key.pem" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "480" --group "480" --mode "600" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "tomcat":"/opt/tomcat"
	$(BIN_FIND) "webapps" -mindepth "1" -type "f" -iname "*" -print0 \
	| $(BIN_TAR) -c --numeric-owner --owner "480" --group "480" -f "-" --null -T "-" \
	| $(BIN_DOCKER) container cp "-" "tomcat":"/opt/tomcat"
	$(BIN_DOCKER) container start -a "tomcat"

.PHONY: container-run
container-run:
	$(MAKE) "container-run-$(PROJ_PLATFORM_OS)"

.PHONY: container-rm
container-rm:
	$(BIN_DOCKER) container rm -f "tomcat"
