    server_name siem;

    client_body_timeout 300s;
    client_max_body_size 100M;

    location /patch {
        root   /var/www/;
        index  index.html index.htm;
    }

    location /web/alerts {
    	deny   all;
    }
    location /web/streams {
    	deny   all;
    }
    location /web/iam {
    	deny   all;
    }
    location /swagger {
    	deny   all;
    }

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Scheme $scheme;
        proxy_pass http://openobserve:5080;
	proxy_set_header Accept-Encoding '';
	sub_filter '</head>' '<link rel="stylesheet" href="/patch/openobserve.css"></head>';        
        sub_filter_once on;
    }
