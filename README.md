# kube-noah
[![BuildStatus Widget]][BuildStatus Result]

[BuildStatus Result]: https://jenkins.onestage.xyz/view/all/job/GefenOnline/job/kube-noah/job/master/
[BuildStatus Widget]: https://jenkins.onestage.xyz/buildStatus/icon?job=GefenOnline/kube-noah/master

<img src="images/kube-noah.png" width="50">

## What is kube-noah?

kube-noah is a tool designed to backup and restore Kubernetes cluster objects: Deployments, Secrets, ConfigMaps, Ingresses, Services and more, it uses two main processes that are called on-demand when setting their appropriate environment variables:
1. Restore objects from Git to Kubernetes (triggered by ```RESTORE```).
2. Backup objects from Kubernetes to Git (triggered by ```BACKUP```).

**Notes**:
- it is possible to trigger one or both of the processes (the order in which they are numbered above is the orther in which they will run if they are both triggered)
- All environment variables below are required so those that has no default must be set, otherwise kube-noah will fail to run, with the exception of ```RESTORE``` and ```BACKUP``` that can be set one instead of the other

**Recommendations**:
- Trigger the processes separately.
- Trigger 'Restore objects from Git to Kubernetes' in a job container (once), in cluster startup, and wait for its exit code, before moving forward, if you have resources that are better to be restored then regenerated, like Lets Encrypt TLS certificates for example, that when are loaded as Kubernetes secrets, used instead of requesting new ones from Let't Encrypt and wasting quota.
- Trigger 'Backup objects from Kubernetes to Git' in a cronjob container (infinitely).
- Use private repository for the backend storage, if you do, needless to say that the ```GIT_REPO_URL``` url should contain user and password/token.

---
### Environment Variables
Key                       | Default value     |  Possible values    | Description
------------------------- | ----------------- | ------------------- | ----------------
GIT_REPO_URL              | ---               | Any https Git url   | The repository in which the objects are stored, backed up to and taken from, only https url is supported for various reasons.
GIT_LOCAL_DIR                   | /tmp/kube-ark     | Any valid directory | The local Git repository destination inside the container (No need to change it ever)
GIT_USER_NAME             | kube-noah service | Any username        | The username Git uses when configuring git config --global user.name
GIT_USER_EMAIL            | kube-noah@service.com   | Any email address   | The email address Git uses when configuring git config --global user.email
RESTORE                   | ---               | true                | Whether to trigger 'restore from Git to Kubernetes'
BACKUP                    | ---               | true                | Whether to trigger 'backup from Kubernetes to Git'
KUBE_CLUSTER_NAME         | ---               | Any name            | Although any name can be provided a unique name of the Kubernetes cluster is best appropriate for an understandable objects division and tracking

