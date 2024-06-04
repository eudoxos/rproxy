# Debugging Proxy HTML

MWE for running Apache serving index.html through http://localhost/proxied/, which should rewrite links in HTML so that `<link href="/style.css">` becomes `<link href="/proxied/style.css>`. That is not the case. Why?

Run `make` to launch apache and one request (which goes through the proxy, so apache proxies the request to itself, then sends the index.html back through the reverse proxy); the result should have the links modified (but does not). Apache is terminated after a few seconds.

This MWE was tested on Debian, you need `apache2` installed, and also `ccze` (for colors). All runs as the current user in the current directory, for a few seconds, does not touch anything else. Port 8080.

# Output

Fragments (after running `make`) with some comments:

1. request from curl comes:

   ```
   [core:trace5] Request received from client: GET /proxied/ HTTP/1.1 
   [http:trace4] Headers received from client: 
   [http:trace4]   Host: localhost:8080 
   [http:trace4]   User-Agent: curl/7.81.0 
   [http:trace4]   Accept: */* 
   ```
2. proxy directive matches, and makes the request to itself, without `/proxy`:

   ```
   [proxy:trace2] AH03461: attempting to match URI path '/proxied/' against prefix '/proxied/' for proxying 
   [proxy:trace1] AH03464: URI path '/proxied/' matches proxy handler 'proxy:http://localhost:8080/' 
   ```

3. The proxied response is received and about to be sent back to curl; HTML is parsed by the `xml2enc` module, correctly:

   ```
   [xml2enc:debug] AH01439: xml2enc: consuming 156 bytes from bucket 
   [xml2enc:debug] AH01441: xml2enc: converted 156/156 bytes 
   ```

4. `proxy_html` matches the MIME type

   ```
   [filter:trace4] Content-Type 'text/html;charset=utf-8' ... 
   [filter:trace4] ... matched 'text/html' 
   [filter:trace2] Content-Type condition for 'proxy-html' matched 
   ```
5. **but then, nothing happens?**

   ```
   [http:trace3] Response sent with status 200, headers: 
   [http:trace5]   Date: Tue, 04 Jun 2024 09:51:20 GMT 
   [http:trace5]   Server: Apache/2.4.52 (Ubuntu) 
   [http:trace4]   Last-Modified: Tue, 04 Jun 2024 09:13:50 GMT 
   [http:trace4]   Accept-Ranges: bytes 
   [http:trace4]   Content-Type: text/html;charset=utf-8 
   [http:trace4]   Content-Length: 140 
   [proxy_http:trace2] end body send 
   ```

   so curl receives `index.html` unaltered:
   ```
   <html><head><meta charset="utf-8"><link rel="stylesheet" href="/style.css"><title>Main page</title></head><body><h1>Title</h1></body></html>
