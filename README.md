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

3. The proxied response is being filtered, we see all the filters in order

   * `inflate`:

      ```
      [filter:trace4] Content-Type 'text/html' ... 
      [filter:trace4] ... matched 'text/html' 
      [filter:trace2] Content-Type condition for 'inflate' matched 
      ```

   * `proxy-html` (but **NO ACTION HAPPENS**):

      ```
      [xml2enc:debug] AH01430: Content-Type is text/html 
      [xml2enc:debug] AH01434: Charset ISO-8859-1 not supported by libxml2; trying apr_xlate 
      [xml2enc:debug] AH01439: xml2enc: consuming 156 bytes from bucket 
      [xml2enc:debug] AH01441: xml2enc: converted 156/156 bytes 
      [filter:trace4] Content-Type 'text/html;charset=utf-8' ... 
      [filter:trace4] ... matched 'text/html' 
      [filter:trace2] Content-Type condition for 'proxy-html' matched 
      ```

   * `substitute` (replaces title via regex)

      ```
      [filter:trace4] Content-Type 'text/html;charset=utf-8' ... 
      [filter:trace4] ... matched 'text/html' 
      [filter:trace2] Content-Type condition for 'substitute' matched 
      [substitute:trace8] Line read (140 bytes): <html><head><meta charset="utf-8"><link rel="stylesheet" href="/style.css"><title>Main page</title></head><body><h1>Title</h1></body></html> 
      [substitute:trace8] Replacing regex:'Title' by 'REPLACED TITLE' 
      [substitute:trace8] Matching found 
      [substitute:trace8] Result: 'REPLACED TITLE' 
      ```

   * `deflate`:

      ```
      [filter:trace4] Content-Type 'text/html;charset=utf-8' ... 
      [filter:trace4] ... matched 'text/html' 
      [filter:trace2] Content-Type condition for 'deflate' matched
      ```
4. Sent back to `curl`:

   ```
   [http:trace3] Response sent with status 200, headers: 
   [http:trace5]   Date: Tue, 04 Jun 2024 10:19:36 GMT 
   [http:trace5]   Server: Apache/2.4.52 (Ubuntu) 
   [http:trace4]   Last-Modified: Tue, 04 Jun 2024 09:58:25 GMT 
   [http:trace4]   Accept-Ranges: bytes 
   [http:trace4]   Content-Type: text/html;charset=utf-8 
   [http:trace4]   Vary: Accept-Encoding 
   [http:trace4]   Content-Length: 149 
   [proxy_http:trace2] end body send 
   ```

   so curl receives `index.html` with substituted title, but with the `href` being untouched:
   ```
   <html><head><meta charset="utf-8"><link rel="stylesheet" href="/style.css"><title>Main page</title></head><body><h1>REPLACED TITLE</h1></body></html>
