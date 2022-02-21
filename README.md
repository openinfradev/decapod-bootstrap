# Decapod-bootstrap

This repo includes materials to bootstrap decapod controllers using app of apps pattern.
Currently the following applications are bootstrapped by default.
* argo-cd
* postgresql
* argo-workflow

## Installation

### Clone repository
clone this repository that includes:
- value-override file for argocd installation, which contains initial (meta) project/app configurations
- actual manifest directory watched by the above meta apps, which contains actual decapod project and application configurations

```
$ git clone https://github.com/openinfradev/decapod-bootstrap
```

The repository structure looks as follows.
```
├── README.md
├── genereate_yamls.sh
├── argocd-install
│   └── values-override.yaml
├── decapod-apps
│   ├── README.md
│   ├── argo-workflows.yaml
│   ├── db-secret-decapod-db.yaml
│   ├── db-secret-argo.yaml
│   └── postgresql.yaml
└── decapod-projects
    ├── README.md
    └── decapod-controller.yaml
```

* genereate_yamls.sh: create YAML files for bootstrapping if you don't use the default decapod git repository in github.com/openinfradev

Directory contents
* argocd-install: value-override file for argocd helm chart, which contains configuration to create the following (meta) project and app.
  * meta-project 'decapod-projects'
  * meta-application 'decapod-apps'

* decapod-projects: directory for actual project manifest files. Once any manifest file is added, it's detected by 'decapod-projects' project, and created as argocd project.

* decapod-apps: directory for actual application manifest files. Once any manifest file is added, it's detected by 'decapod-apps' project, and created as argocd application.

### Create namespaces
```
$ kubectl create ns argo
$ kubectl create ns decapod-db
```

### Install argo-cd using helm-chart /w value-override file
(chart location: https://artifacthub.io/packages/helm/argo/argo-cd)
```
$ helm repo add argo https://argoproj.github.io/argo-helm
$ helm install argo-cd argo/argo-cd --version 3.33.6 -f ./decapod-bootstrap/argocd-install/values-override.yaml -n argo
```
Once argocd is installed, it creates the meta project and apps, which in turn, bootstraps actual decapod applications.

### Watch for applications to bootstrap automatically
```
$ kubectl get pods -n decapod-db
NAME                      READY   STATUS    RESTARTS   AGE
postgresql-postgresql-0   1/1     Running   0          4m10s

$ kubectl get pods -n argo
NAME                                                           READY   STATUS             RESTARTS   AGE
argo-cd-argocd-application-controller-7bc75f949c-svrnk         1/1     Running            0          5m34s
argo-cd-argocd-dex-server-7bd494f8b5-j5br5                     1/1     Running            0          5m34s
argo-cd-argocd-redis-6f696857c5-zmqfh                          1/1     Running            0          5m34s
argo-cd-argocd-repo-server-545455798b-st5x8                    1/1     Running            0          5m34s
argo-cd-argocd-server-6666cb7689-tswfr                         1/1     Running            0          5m34s
argo-workflows-operator-server-d7df65b99-gpx5q                 0/1     Running            0          4m21s
argo-workflows-operator-workflow-controller-598dfdd565-vrzg9   0/1     Running            0          4m21s

```
