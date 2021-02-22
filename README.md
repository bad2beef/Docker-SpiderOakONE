# SpiderOakONE Backup Docker Container

[SpiderOakONE Backup](https://spideroak.com/one/)

There are quite a few SpiderOakONE containers published at Docker Hub. Unfortunately may are too far out of date to continue working, and many others require passing or modify commands to the container to configure and run properly.

This image should be easy to maintain, can be run with commands if required, but can also be configured and run completely through files on disk. These features make it well suited for headless, non-interactive runs on a NAS appliance in addition to on a standard desktop or server.

## Preparation

Build the following items available before you begin.

### Common Requirements

1. _Backup User_. The user can be any valid user. The container will run SpiderOakONE as a UID and GID provided to allow safe access to resources outside of the container.
2. _Application Datastore_. This is a local directory which will be mounted into the container to store persistent data. This must be separate from backup data. This directory should be owned by the UID and GID used to run SpiderOakONE.
3. _Data to Backup_. Ensure the data to back up is available and that _Backup User_ is permitted read access.
4. `setup.json` configuration file. see [--setup (One)](https://spideroak.support/hc/en-us/articles/115001893283--setup) for details.

### Backup Selections

Backup selections can be made one of two ways. The container will pass parameters to SpiderOakONE except in the case of initial setup. Therefore if you can run the container with parameters you may use the SpiderOakONE backup selection manipulation parameters `--include-dir`, `--exclude-dir`, `--include-file`, and `--exclude-file`.

If custom container launches are not available (Synology NAS DSM, etc…) a text file may be used. Place the file `selections.txt` in Application Datastore. The file must contain backup selections, one per line, in the format `type:path`. `type` corresponds to the selection type and SpiderOakONE command line parameter. It may be one of `include-dir`, `exclude-dir`, `include-file` or `exclude-file`. `path` must be the absolute path of the directory or file to back up or exclude.

## Running

### Common

Ensure the following options are set when running the container.

- Environment
  - `SPIDEROAK_UID` – UID of the _Backup User_
  - `SPIDEROAK_GID` – GID of the _Backup User_
- Volumes
  - _Application Datastore_ – Mount at `/home/spideroakone/.config/SpiderOakONE`
  - _Data to Backup_ – Mount at `/home/spideroakone/data`

### First-Run Setup

1. Run the container for initial setup. If successful, `setup.json` will be deleted and the container will terminate.

### Regular Runs

1. Run the container normally with no special options.
2. If `selections.txt` is present current selections will be reset via `SpiderOakONE --reset-selections`, then selections will be applied from the file. `selections.txt` will then be removed.

## Maintenance

### General

Extra commands may be passed to SpiderOakONE in the standard Docker fashion. Default commands are `--verbose` and `--batchmode`. The setup process does not allow additional commands.

### Modifying Backup Selections

Selections may be modified at any time by re-creating `selections.txt`.

## Example

### Build Container

```bash
$ cd /tmp
$ wget https://github.com/bad2beef/Docker-SpiderOakONE/archive/master.zip
$ unzip master.zip
$ cd Docker-SpiderOakONE-master
$ make
wget https://spideroak.com/release/spideroak/slack_tar_x64
--2020-05-01 20:19:12--  https://spideroak.com/release/spideroak/slack_tar_x64
Resolving spideroak.com (spideroak.com)... 123.123.123.123
Connecting to spideroak.com (spideroak.com)|123.123.123.123|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 27851548 (27M) [application/x-tar]
Saving to: ‘slack_tar_x64’
slack_tar_x64                 100%[=================================================>]  26.56M  3.94MB/s    in 13s
2020-05-01 20:19:25 (2.12 MB/s) - ‘slack_tar_x64’ saved [27851548/27851548]

sudo docker build .
Sending build context to Docker daemon  27.86MB
Step 1/10 : FROM amd64/debian:latest
 ---> 3de0e2c97e5c
Step 2/10 : COPY slack_tar_x64 /tmp/
 ---> Using cache
 ---> 75e94cb92927
Step 3/10 : RUN         tar xzf /tmp/slack_tar_x64 -C / &&      rm -f /tmp/slack_tar_x64
 ---> Using cache
 ---> 1d53352a3128
Step 4/10 : COPY entrypoint.sh /usr/local/bin/entrypoint.sh
 ---> e58c13ae2eab
Step 5/10 : RUN chmod +x /usr/local/bin/entrypoint.sh
 ---> Running in ABCDEF012345
Removing intermediate container ABCDEF012345
 ---> ABCDEF012345
Step 6/10 : RUN adduser --disabled-password --gecos "" spideroakone
 ---> Running in ABCDEF012345
Adding user 'spideroakone' ...
Adding new group 'spideroakone' (1000) ...
Adding new user 'spideroakone' (1000) with group 'spideroakone' ...
Creating home directory '/home/spideroakone' ...
Copying files from '/etc/skel' ...
Removing intermediate container ABCDEF012345
 ---> ABCDEF012345
Step 7/10 : ENTRYPOINT [ "entrypoint.sh" ]
 ---> Running in ABCDEF012345
Removing intermediate container ABCDEF012345
 ---> ABCDEF012345
Step 8/10 : VOLUME /home/spideroakone/.config/SpiderOakONE
 ---> Running in ABCDEF012345
Removing intermediate container ABCDEF012345
 ---> ABCDEF012345
Step 9/10 : VOLUME /home/spideroakone/SpiderOak Hive
 ---> Running in ABCDEF012345
Removing intermediate container ABCDEF012345
 ---> ABCDEF012345
Step 10/10 : VOLUME /home/spideroakone/data
 ---> Running in ABCDEF012345
Removing intermediate container ABCDEF012345
 ---> ABCDEF012345
Successfully built ABCDEF012345
```

### Run Container - Setup

#### Get UID & GID

```bash
$ id uid=1234(user) gid=1234(user)
$
```

#### Prepare Application Datastore

```bash
$ mkdir /home/user/SpiderOakONE
```

#### Prepare setup.json

```bash
$ nano /home/user/SpiderOakONE/setup.json
$
```

#### Prepare selections.txt

```bash
$ nano /home/user/SpiderOakONE/selections.txt
$
```

#### Run

Please note during initial setup UID updates may take some time.

```bash
$ sudo docker run --env SPIDEROAK_UID=1234 --env SPIDEROAK_GID=1234 --volume /home/user/SpiderOakONE:/home/spideroakone/.config/SpiderOakONE --volume /home/user/Documents:/home/spideroakone/data/Documents --volume /home/user/Pictures:/home/spideroakone/data/Pictures ABCDEF012345
Setting UID
Setting GID
Starting SpiderOakONE Setup
Logging in...
Getting list of devices...
Reinstalling device...
Finalizing device setup...
Synchronizing with server (this could take a while)...
batchmode run complete: shutting down
Completed SpiderOakONE Setup
```

### Run Container - Normal / Batch Mode

```bash
$ sudo docker run --env SPIDEROAK_UID=1234 --env SPIDEROAK_GID=1234 --volume /home/user/SpiderOakONE:/home/spideroakone/.config/SpiderOakONE --volume /home/user/Documents:/home/spoderoakone/data/Documents --volume /home/user/Pictures:/home/spoderoakone/data/Pictures ABCDEF012345
Setting UID
Setting GID
Starting SpiderOakONE
Status:
Status: Waiting for initial updates from server
...
batchmode run complete: shutting down
```

### Run Container - Automated

Automated backups may be run on a NAS or similar device. SpiderOakONE can back up continuously or on a schedule, but only if configured from the GUI. Therefore unattended backups are best scheduled automatically, allowing a backup to complete and the application to exit.

In this scenario ensure:

1. Containers are *not* set up to automatically restart on exit / failure.
2. A cron job or scheduled tasks exist to start the container on your preferred interval.

#### Example Job

```bash
0 1 * * * docker container start bad2beef-spideroakone
```
