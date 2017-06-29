# Prisebox

## Software
1. Install GPG
    * Ubuntu `sudo apt-get install gnupg`
    * Software.1.15 (Modern)
        https://www.gnupg.org/download/index.html

2. Generate GPG Keys
```bash
gpg --full-gen-key

Key Type: 1
Key Size: 4096
Expires Date: 0
Real Name: Todd Niswonger
Email Address: todd.niswonger@myhomepay.com
```
3. Export your gpg key to a file
```bash
gpg --export todd.niswonger@myhomepay.com | base64 > environments/local/shared/gpg/<yourname>.asc
```
4. Install jq. jq is a lightweight and flexible command-line JSON processor
```bash
apt-get install jq
```

## Running Prisebox
First set the ENV environment variable, the current supported environments are `local` and `development`. Once this is set run the `create` command in prisebox.
```bash
./prisebox create
```


## Running Prisebox in Joyent Triton
Triton is the Joyents offering for cloud infrastructure, it's a managed solution that can run docker containers in bare metal.
Joyent also provides a way to have a self-hosted private cloud for testing and developing applications.
It provides an implementation for docker which we can use to host our container infrastructure. This implementation differs slightly from Docker Inc's so changes have to be considered before trying to run Prisebox in such environment.

>docker-compose supported version;
Triton supports only version 1 of docker-compose, because of this networking, volumes, and hosted-volumes have to be adapted to use Container Naming Service (CNS), Volumes from Containers to Container and Environment Variables.

>Docker Socket;
Docker needs to use the hosted docker socket, which Triton does not support, however we were able to connect directly to set the ```$DOCKER_HOST``` environment variable to achieve the same result.

### Setup 
The Triton setup has to be completed in several parts:

Determine the Service Host Name: A triton hostname is made up of several pieces.

`consul.svc.a02adf22-1492-e9f6-b41b-85fec6c3688f.aus-stack01.cns.breedlove.local`

|Breakdown| |
|-------|---|
|consul|consul is the service name|
|svc|Fixed value in Triton|
|a02adf22-...-85fec6c3688f|User TRITON_ACCOUNT|
|aus-stack01.cns|Hostname |
|cnd|Fixed value in Triton|
|breedlove.local|Server Domain Name|

Determine An Instance Name:

`development-consul-1.inst.a02adf22-1492-e9f6-b41b-85fec6c3688f.aus-stack01.cns.breedlove.local`

|Breakdown| |
|-------|---|
|development-consul1|Service instance created by docker, it changes depending on the name of the folder that contains the docker-compose file and the number of scaled instances requested|
|inst|Fixed value in Triton|
|a02adf22-...-85fec6c3688f|User TRITON_ACCOUNT|
|aus-stack01.cns|Hostname |
|cnd|Fixed value in Triton|
|breedlove.local|Server Domain Name|


Set up the hostnames in the `development/shared/environment.env` file:
```bash
CONSUL_HOST=consul.svc.a02adf22-1492-e9f6-b41b-85fec6c3688f.aus-stack01.cns.breedlove.local
VAULT_HOST=vault.svc.a02adf22-1492-e9f6-b41b-85fec6c3688f.aus-stack01.cns.breedlove.local
VAULT_ADDR=https://vault.svc.a02adf22-1492-e9f6-b41b-85fec6c3688f.aus-stack01.cns.breedlove.local:8200
```

Setup the services host names in the `util-tlsgen/mounts/config.json` file:
```
"certificates": {
    "consul": {
      ...snip...
      "alt_names": [
        "localhost",
        "server.dc1.consul",
        "consul.svc.a02adf22-1492-e9f6-b41b-85fec6c3688f.aus-stack01.cns.breedlove.local"
      ],
      ...snip...
    },
    "vault": {
      ...snip...
      "alt_names": [
        "localhost",
        "development-vault-1.inst.a02adf22-1492-e9f6-b41b-85fec6c3688f.aus-stack01.cns.breedlove.local",
        "vault.svc.a02adf22-1492-e9f6-b41b-85fec6c3688f.aus-stack01.cns.breedlove.local"
      ]
      ...snip...
    }
  }

```

Adjust cidr blocks for network assignment; this depends on the available network addresse range your triton instance can provide. They are set in the `/development/util-vault-admin/config/apps.json` file

```json
{
  "vault": {
    "app_id": "da3d0f06-1fe1-48f3-aa6a-97208cc6ce3b",
    "cidr_blocks": ["10.110.20.128/25"],
    "policies": [
      "apps"
    ]
  },
  "consul": {
    "app_id": "3aad081a-89b9-445b-ad33-d4aa8d62bdf5",
    "cidr_blocks": ["10.110.20.128/25"],
    "policies": [
      "apps"
    ]
  }
}
```

Finally Setup a environment file such as `/development/util-vault-admin/triton.env` that contains the triton account and triton's docker host information 
```bash
SDC_URL=https://10.110.20.152
SDC_ACCOUNT=leo.hinojosa
TRITON_ACCOUNT=a02adf22-1492-e9f6-b41b-85fec6c3688f
DOCKER_CERT_PATH=/root/.sdc/docker/leo.hinojosa
DOCKER_HOST=tcp://10.110.20.153:2376
DOCKER_CLIENT_TIMEOUT=300
COMPOSE_HTTP_TIMEOUT=300
PRIVATE_KEY=-----BEGIN RSA PRIVATE ...snip... END RSA PRIVATE KEY-----#
DOCKER_IMPLEMENTATION=triton
```

