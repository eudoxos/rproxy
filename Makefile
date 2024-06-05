MAKEFLAGS+=-j3
TASKS=apache2 python curl
.PHONY: $(TASKS)
run: $(TASKS)

apache2:
	APACHE_RUN_DIR=. timeout 3 apache2 -d. -f ./apache2.conf -D FOREGROUND | ccze -A
python:
	timeout 3 python3 -m http.server 8081
curl:
	sleep 1
	curl -s http://localhost:8080/proxied/

