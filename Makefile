MAKEFLAGS+=-j2
TASKS=apache2 curl
.PHONY: $(TASKS)
run: $(TASKS)

apache2:
	APACHE_RUN_DIR=. timeout 3 apache2 -d. -f ./apache2.conf -D FOREGROUND | ccze -A
curl:
	sleep 1
	curl -s http://localhost:8080/proxied/

