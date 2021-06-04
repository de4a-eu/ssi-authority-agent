# DE4A Authority Agent

This project contains files and scripts for deploying the DE4A SSI Authority Agent. The Agent's implementation is based on open-source project Hyperledger Aries Go: https://github.com/hyperledger/aries-framework-go.

## Requirements (installation of tools for Linux)

-   Linux server (scripts were not tested on other OSes)
-   Docker (20.10.2): for Debian based installations of Linux (e.g. Ubuntu) installation instructions for Docker can be found [here](https://docs.docker.com/engine/install/ubuntu/) and for Fedora [here](https://docs.docker.com/engine/install/fedora/).
-   Docker Compose (1.27.4): for Debian distributions installation instructions are [here](https://docs.docker.com/compose/install/) and for Fedora [here](https://docs.docker.com/engine/install/fedora/).

## Set environment variables

Before the deployment of SSI Authority Agent, the following environment variable must be set (path: agent/.env):

-   DOMAIN=INSERT_PUBLIC_DOMAIN_HERE (replace INSERT_PUBLIC_DOMAIN_HERE with your host's public domain name)

## Make ports public

The following ports must be open (public), so SSI Agents can communicate and exchange messages:

-   8081/tcp

## Deploy SSI Authority Agent

In the deployment, several Docker containers are started. We have created a docker-compose to set up the whole environment.
Docker Compose file contains the following containers:

-   SSI Authority Agent Java REST server
-   Aries Go REST server
-   A webhook server
-   CouchDB database server
-   Sideetree container (ledger)

Deployment diagram:

<img src="deployment_diagram.png" alt="Deployment Diagram" width="1000"/>

You can find more details of the container's configuration within the file `agent/docker-compose.yml`

The configuration parameters to feed the docker compose is in the file `agent/.env`

> Please review the contents of this configuration file to fit your development, for instance, you can change ports according to your needs.

<!-- ````

### Generate Keys

For the actual sake of the development, the use of TLS is disable in the different environment recreated (due problems to connect mobile with a self signed certificate). However there is a script ready to generate the keys used within the different containers deployed. In order to generate it, it is just necessary to run the following command:

```bash
$cd testing-environment
$./generate_test_keys.sh
```` -->

Once the Aries-related components are configured, it is necessary to adjust the properties required to run the SSI Authority Agent. The properties file (`app.properties`) can be found under `agent/api-java/conf` folder. 
Since the Authority Agent API communicates with the Aries Go server and the CouchDB database, it is necessary to specify the name of the database where internal status of DID, VC and VP status will be stored along with the credentials for connecting to this database.
The following entries in `app.properties` file for the SSI Authority Agent API need to be changed before running the Docker containers:
```bash
db.ip.address=<INSERT IP adress:port of your database server> (example value: http://couchdb.de4a.eu:5984/)
db.username=<INSERT DB administrator username>
db.password=<INSERT DB administrator password>
db.name=<INSERT DB name, which will created when using the Authority Agent automatically> (example value: de4a-authority-agent)

aries.enterprise.ip.address=<INSERT IP address:port of the Aries Go server> (example value: http://de4a.informatika.uni-mb.si:8082/)
did.key=did:key:z6Mkf3mSeHmehoXVdXQt1uNimKxD9RqFXHS6EgbVaDx4B5Z5 (note: DID key value of the Authority Agent, which is used for signing VC, the generation will be done automatically in future iterations)
signature.type=Ed25519Signature2018

```

Once these basic environment properties are changed, you can proceed to starting the containers.

### Start containers

To start the containers, it will be necessary to execute the following command:

```bash
$cd agent
$docker-compose up -d
```

If everything has gone well, you should be able to see something similar to this:

```bash
Creating couchdb.de4a.eu              ... done
Creating de4a.informatika.uni-mb.si   ... done
Creating aries.bdd.sidetree.mock      ... done
Creating government.agent.api.de4a.eu ... done
Creating government.webhook.de4a.eu   ... done
```

To see the logs of each container, you can use the following command:

```bash
$docker logs -f government.agent.api.de4a.eu
```

### Stop containers

To stop the containers, you need to execute the following command:

```bash
$cd agent
$docker-compose stop
```

If everything goes well, you should be able to see the following:

```bash
Stopping aries.bdd.sidetree.mock      ... done
Stopping government.agent.api.de4a.eu ... done
Stopping government.webhook.de4a.eu   ... done
Stopping couchdb.de4a.eu              ... done
Stopping de4a.informatika.uni-mb.si   ... done
Removing aries.bdd.sidetree.mock      ... done
Removing government.agent.api.de4a.eu ... done
Removing government.webhook.de4a.eu   ... done
Removing couchdb.de4a.eu              ... done
Removing de4a.informatika.uni-mb.si   ... done
Removing network agent_bdd_net        ... done
```

### Testing the SSI Authority Agent deployment

You can test if the deployment of the SSI Authority Agent has been successfull directly by calling its API methods from the preferred API development tool (e.g. Postman) or the Swagger documentation (file `authority-agent-api-v0.2.yml`). 
If you are using the Swagger file, make sure that you change the Authority Agent server `url` property in the YAML file:
``` bash
servers:
  - url: 'http://164.8.250.43:8080/de4a-agent/v1' (to be replaced with your IP address and port on which you run the server)
```

You can test if the Authority Agent is working properly by checking the current DID connection status for a random user ID (note: replace IP ADDRESS:PORT with your Authority Agent server address). 
The following request is made:

``` bash
curl -X 'GET' \
  'http://<IP ADDRESS:PORT>/de4a-agent/v1/did-conn-status/LvvPxYsevpdefYV' \
  -H 'accept: application/json'
```

This request should return `-1`, as there is no DID connection for user ID "LvvPxYsevpdefYV" at the beginning.

The flow of API requests for the DP side is the following:
1.  `/generate-invitation`
2.  `/did-conn-status/{userId}`
3.  `/send-vc-offer` (requires generating a DID of the Authority Agent as a pre-condition, will be updated)
4.  `/check-offer-vc-response/{userId}` (requires generating a DID of the Authority Agent as a pre-condition, will be updated)
5.  `/send-vc` (requires generating a DID of the Authority Agent as a pre-condition, will be updated)

The flow of API requests for the DC side is the following:
1.  `/generate-invitation`
2.  `/did-conn-status/{userId}`
3.  `/send-vp-request` 
4.  `/check-request-vp-response/{userId}`
5.  `/validate-vp/{userId}` (requires EBSI integration, will be updated)

<!-- Document is comprised as follows:

1. Installation of the Linux OS under Windows
2. Requirements (installation of tools for Linux)
3. Running the Aries agent

# 1. Installation of the Linux OS under Windows

If you are already running the Linux OS then you can skip this section and go directly to the step 2.

Otherwise, to sucessfully build and run the Aries agent (built with [Hyperledger Aries Framework Go](https://github.com/hyperledger/aries-framework-go)) the Linux operating environment (bash console) is needed.
In Windows OS there are two prominent options (among others) of running Linux image:

-   Windows Subsystem for Linux (WSL): to install WSL please follow this [guide](https://docs.microsoft.com/en-us/windows/wsl/install-win10).
    Note: if during the installation of the WSL the [»The virtualization is not enabled in the BIOS«](https://github.com/microsoft/WSL/issues/5363) error occurs, please restart the computer, run BIOS setting and enable it.

-   the VirtualBox: first install the [VirtualBox](https://www.virtualbox.org/) then download the Linux image. We tested the Fedora 32 image (found [here](https://www.osboxes.org/fedora/) - password: osboxes.org).

# 2. Requirements (installation of tools for Linux)

-                 Git version control: needed to clone the Agent project repository. For installation of Git tools follow the instructions [here](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git).
-                 Docker (20.10.2): for Debian based installations of Linux (e.g. Ubuntu) installation instructions for Docker can be found [here](https://docs.docker.com/engine/install/ubuntu/) and for Fedora Linux instruction are [here](https://docs.docker.com/engine/install/fedora/).
-                 Docker Compose (1.27.4): for Debian distributions installation instructions are [here](https://docs.docker.com/compose/install/) and for Fedora are [here](https://docs.docker.com/engine/install/fedora/).
-                 Go (1.15.x): Go(lang) is already included with the Docker installation. If there is need for manual installation (e.g. to install the [specific version](https://golang.org/dl/) of Go) please reffer to this [link](https://golang.org/doc/install).

# 3. Running the Aries agent

# TODO

-   [ ] Build and publish Hyperledger Aries Go Docker image on GitLab Container Registry / Update: running the agent-rest from already built image of the Aries Framework Go repository

In the Linux bash shell run the following command to pull the Aries Framework Go Framework from repository (all commands are set for the example of 0.1.6 version):
docker pull ghcr.io/hyperledger/aries-framework-go:0.1.6

To run the aries rest agent from the image that was just pulled run the following command (note: agent name and rest agent flags/commands can be also set differently):
docker run -d --name agent_name -t ghcr.io/hyperledger/aries-framework-go:0.1.6 start --api-host localhost:8080 --database-type mem --inbound-host http@localhost:8081,ws@localhost:8082 --inbound-host-external http@https://example.com:8081,ws@ws://localhost:8082 --webhook-url localhost:8082 --agent-default-label --auto-accept true MyAgent

To save the image to archive:
docker save ghcr.io/hyperledger/aries-framework-go:0.1.6 > ./aries_0_1_6.tar

To load image from archive:
docker load < aries_0_1_6.tar

-   [ ] Generate OpenAPI specs file
-   [ ] Create Docker Compose file for all services (agent, webhook, sidetree, swagger)

# Future

-   add HTTPS support -->
