# Debugging Proxy HTML

MWE for running Apache serving index.html through http://localhost/proxied/, which should rewrite links in HTML so that `<link href="/style.css">` becomes `<link href="/proxied/style.css>`. That is not the case. Why?

Run `make` to launch apache and one request (which goes through the proxy, so apache proxies the request to itself, then sends the index.html back through the reverse proxy); the result should have the links modified (but does not). Apache is terminated after a few seconds.

This MWE was tested on Debian, you need `apache2` installed, and also `ccze` (for colors). All runs as the current user in the current directory, for a few seconds, does not touch anything else. Port 8080.

Output fragments (after running `make`) with some comments:

```
#
# REQUEST FROM curl
#
[core:trace5] Request received from client: GET /proxied/ HTTP/1.1 
[http:trace4] Headers received from client: 
[http:trace4]   Host: localhost:8080 
[http:trace4]   User-Agent: curl/7.81.0 
[http:trace4]   Accept: */* 
#
# PROXY MATCHES 
#
[proxy:trace2] AH03461: attempting to match URI path '/proxied/' against prefix '/proxied/' for proxying 
[proxy:trace1] AH03464: URI path '/proxied/' matches proxy handler 'proxy:http://localhost:8080/' 
#
# … 
# apache proxies to itself, serves index.html from /
# …
#
[xml2enc:debug] AH01439: xml2enc: consuming 119 bytes from bucket 
[xml2enc:debug] AH01441: xml2enc: converted 119/119 bytes 
#
# HERE proxy-html matches
#
[filter:trace4] Content-Type 'text/html;charset=utf-8' ... 
[filter:trace4] ... matched 'text/html' 
[filter:trace2] Content-Type condition for 'proxy-html' matched 
#
# BUT THEN NOTHING HAPPENS??
#
[http:trace3] Response sent with status 200, headers: 
[http:trace5]   Date: Tue, 04 Jun 2024 09:51:20 GMT 
[http:trace5]   Server: Apache/2.4.52 (Ubuntu) 
[http:trace4]   Last-Modified: Tue, 04 Jun 2024 09:13:50 GMT 
[http:trace4]   Accept-Ranges: bytes 
[http:trace4]   Content-Type: text/html;charset=utf-8 
[http:trace4]   Content-Length: 118 
[proxy_http:trace2] end body send 
```
