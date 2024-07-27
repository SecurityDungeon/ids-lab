# AdminPC RDP Access and Lateral Movement

**For educational purposes only!**

**Warning:** This scenario could trigger the IDS detections on your network.

### Setup
- AdminPC
  - Windows VM or VPS connected to IDS-Lab via wireguard
  - remote access enabled and allowed from the "Internet"
    - *simulation of Home Office mode for administrator, when he needs to access his desktop in the office*
    - allow remote connections to this computer -> System Properties -> Select Users
    - recommended: enable [process creation events and include the command line](https://logrhythm.com/blog/how-to-enable-process-creation-events-to-track-malware-and-threat-actor-activity/) (Event ID 4688)
- Wireguard
  - port forwarding from 3389 to the AdminPC with IP 10.x.y.z
```
iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 3389 -j DNAT --to-destination 10.x.y.z
```

### Scenario

- admin credentials discovered by attacker, e.g.
  - found on darkweb / data leak
  - successful bruteforce attack, e.g. with `hydra` tool
  - reused credentials, e.g. admin uses same password for his desktop and wordpress website
    - see [wordpress-hack](../wordpress-hack/) scenario
- after successful login, attacker can do:
  - system information , process and service discovery
    - e.g. `systeminfo`, `winver`, `ipconfig /all`, `tasklist`, `net start`, `net use`
  - credentials discovery
    - e.g. Mimikatz or LaZagne
  - remote system discovery
    - e.g. Nmap, MASSCAN, Advanced IP Scanner
- based on gathered information, attacker can proceed with lateral movement, e.g.
  - access remote services and use valid accounts discovered during previous step
  - exploit vulnerable remote services
