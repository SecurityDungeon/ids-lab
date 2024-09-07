Put your fullchain.pem and privkey.pem files here.
Or generate the self-signed certificate with:

```
openssl req -x509 -newkey rsa:4096 -keyout privkey.pem -out fullchain.pem -sha256 -days 3650 -nodes -subj "/CN=*.ids-lab.home.arpa"
```
