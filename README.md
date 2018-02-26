# kube-noah
The kube-noah is designed to maintain all or some of the Kubernetes cluster objects:
Deployments/Secrets/ConfigMaps/ingresses etc..

The kube-noah uses two main processes that are called on-demand when setting their appropriate environment variables
1. Restore objects from Git to Kubernetes. (triggered by RESTORE variable)
2. Backup objects from Kubernetes to Git. (triggered by BACKUP variable)

**Note**: it is possible to trigger one or both of the processes (the order in which they are numbered above is the orther in which they will run if they are both triggered)

**Recommended**:
- Trigger the processes separately.
- Trigger 'Restore objects from Git to Kubernetes' in a job container (once), in cluster startup, and wait for its exit code, before moving forward, because some resources better to be restored, then regenerated for example: when finish successfully, Lets Encrypt TLS certificates are loaded as Kubernetes secrets and therefore used instead of requesting new ones from Let't Encrypt and wasting quota
- Trigger 'Backup objects from Kubernetes to Git' in a cronjob container (infinitely)

**Important**: Both of the proccesses because it destined to run once, so the Kubernetes scheduler (or any other container orchestrator scheduler for that matter) will try to initiate the container in an infinite loop, everytime the container will exit when it is finished.

---
### Environment Variables
environment var           | default           |  possible values    | Description
------------------------- | ----------------- | ------------------- | ----------------
GIT_REPO                  | ---               | Any https Git url   | The repository in which the objects are stored, backed up to and taken from, only https url is supported for various reasons.
GIT_DIR                   | /tmp/kube-ark     | Any valid directory | The local Git repository destination inside the container (No need to change it ever)
GIT_USER_NAME             | kube-noah service | Any username        | The username Git uses when configuring git config --global user.name
GIT_USER_EMAIL            | kube-noah@service.com   | Any email address   | The email address Git uses when configuring git config --global user.email
RESTORE                   | ---               | true                | Whether to trigger restore from Git to Kubernetes
BACKUP                    | ---               | true                | Whether to trigger backup from Kubernetes to Git
ENVIRONMENT               | ---               | Any name            | Although any name can be provided the name of the environment of the Kubernetes cluster is best appropriate for an understandable objects division and tracking

**NOTE**: All environment variables are required so those that has no default must be set, otherwise kube-noah will fail to run, with the exception of RESTORE and BACKUP that can be set one instead of the other\
**Recommended** (on the edge of **mandatory**): use private repository as your storage, if you do, needless to say that the GIT_REPO url should contain user and password/token

