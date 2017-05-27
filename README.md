# Standard File Server, Go Implementation

Golang implementation of the [Standard File](https://standardfile.org/) protocol.

## Dockerized Version
This is the dockerized version of the Standard File Go Server. All routes expect to begin with /api which is
not the case when being used with standardnotes app. Please see the modified nginx configuration to take
care of this.

We chose Alpine as a lightweight base with a reasonably small surface area for security concerns, but with enough functionality for development and interactive debugging.

The base image always runs under dumb-init, which handles reaping zombie processes and forwards signals on to all processes running in the container. This base image is built by HashiCorp and signed with their GPG key, so you can verify the signed package.

Standardfile runs on this minimal base image and is built by dvbportal and signed with our GPG key, so you can
verify the signed binary.

The container exposes two optional VOLUMEs:

* **/stdfile/logs**, to use for writing persistent logs. Its content is also tailed into docker logs.
* **/stdfile/db**, to use for writing persistent storage data.

The standard port exposed by the container is **8888**.

### Running your own server
You can run your own Standard File server, and use it with any SF compatible client (like Standard Notes).
This allows you to have 100% control of your data.
This server implementation is built with Go and can be deployed in seconds.

##### You may require to add `/api` to the url of your server if you plan to use this server with https://standardnotes.org/

#### Getting started

**Requirements**

- Go 1.7+
- SQLite3 database

**Instructions**

1. Initialize project:

```
go get github.com/tectiv3/standardfile
go install github.com/tectiv3/standardfile
```

2. Start the server:

```
standardfile
```

3. Stop the server:

```
standardfile -s stop
```
### Configuration options

# Customize port and database location
```
-p 8080
```
and
```
-db /var/lib/sf.db
```
default port is `8888` and database file named `sf.db` will be created in working directory

### Deploying to a live server
I suggest putting it behind nginx with https enabled location
```
server {
    server_name sf.example.com;
    listen 80;
    return 301 https://$server_name$request_uri;
}

server {
    server_name sf.example.com;
    listen 443 ssl http2;

    ssl_certificate /etc/letsencrypt/live/sf.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/sf.example.com/privkey.pem;

    include snippets/ssl-params.conf;

    rewrite /(.*) /api/$1 break;
    location / {
    	add_header Access-Control-Allow-Origin '*' always;
    	add_header Access-Control-Allow-Credentials true always;
    	add_header Access-Control-Allow-Headers 'authorization,content-type' always;
    	add_header Access-Control-Allow-Methods 'GET, POST, PUT, PATCH, DELETE, OPTIONS' always;
    	add_header Access-Control-Expose-Headers 'Access-Token, Client, UID' always;

    	if ($request_method = OPTIONS ) {
    		return 200;
    	}

    	proxy_set_header        Host $host;
    	proxy_set_header        X-Real-IP $remote_addr;
    	proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
    	proxy_set_header        X-Forwarded-Proto $scheme;

    	proxy_pass          http://localhost:8888;
    	proxy_read_timeout  90;
    }
}
```
### Optional Environment variables

**SECRET_KEY_BASE**

JWT secret key

## Contributing
Contributions are encouraged and welcome. Currently outstanding items:

- Test suite

## License

Licensed under the GPLv3: http://www.gnu.org/licenses/gpl-3.0.html
