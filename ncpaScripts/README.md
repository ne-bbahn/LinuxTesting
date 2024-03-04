# Guide:
- Install NCPA
- `activatePassive.sh [ip_addr]` to open firewall port 5693/tcp and activate NCPA's passive (it will just turn on the passive and is not configured to point to a server)

## Other Scripts:
#### note any script not listed here are experimental and may not be finished

### NCPA 3.0.2 QA
- `setSSL_Ciphers.sh` - should set ssl_ciphers to true and allows AES256-GCM-SHA384:AES256-SHA256:AES256-SHA:CAMELLIA256-SHA as ciphers. 

### NCPA 3.0.1 QA
- `disableIPV6.sh` - disables IPV6 on el distros
- `debDisableIPV6.sh` - disables IPV6 on deb distros
