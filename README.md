# llm-ly
This repo serves as an installer for the LLM proxy generator tool driven by GitOps using the ArgoCD app-of-apps pattern.

### Prerequisites
- `yq` - `brew install yq` or see here (https://mikefarah.gitbook.io/yq/v/v3.x/)
- `k3d` - `brew install k3d` or see here (https://k3d.io/v5.4.7/#installation)
- `kubectl` - `brew install kubectl` or see here (https://kubernetes.io/docs/tasks/tools/#kubectl)


#### Renaming Cluster Context
If your local clusters have a different context name, you will want to have it match the expected context name `kapoozi`.
```
kubectl config rename-context <current_context> kapoozi
```

## To deploy
```
./aoa-tools/deploy.sh deploy -f environments/kapoozi
```

### Installer options
```
Syntax: installer [-f|-i|-h]

commands:
deploy     deploys an environment with the specified path
destroy    destroys an environment with the specified path

options:
-f     path to environment files
-i     install infra
-h     print help

additional flags:
--skip-argo  skip argo installation
```

Notes on flag options: 
- If `-i` is used, the installer will check for a folder named `.infra` in the environment directory and will install the infra before running the script. This currently only supports `k3d` for local deployments

### catalog.yaml
The `catalog.yaml` exists in each demo environment directory which provides a list of app-of-apps "waves" to be deployed in order by the installer. A wave consists of the `location` (relative to the root path of the selected environment) as well as `pre_deploy` and `post_deploy` scripts which can be optionally run which can be useful for tasks such as health checks, or waiting for pods to be ready or printing output.

Example sequence of events:
```
(Wave 1)
pre_deploy scripts > deploy app-of-app > post_deploy scripts
(Wave 2)
pre_deploy scripts > deploy app-of-app > post_deploy scripts
<...>
``````

### vars.env
The `vars.env` exists in each demo environment directory with a few variables used in the installation such as inputting license keys, defining cluster contexts, and configuring app sync behavior. The installer will use any passed in flags and attempt to discover all of the necessary variables in the pre-check. Please verify the output before continuing.
```
cluster_context="kapoozi"
parent_app_sync="true"
openai_api_key="$OPENAI_API_KEY"
claude_api_key="$ANTHROPIC_API_KEY"
google_api_key="$GEMINI_API_KEY"
mistral_api_key="$MISTRAL_API_KEY"
```

When `parent_app_sync="false"` the installer will disable ArgoCD `autosync` and `prune` features. This is particularly useful for development so manual changes using `kubectl` are not re-synced by ArgoCD.

#### using a private repo
ArgoCD makes it pretty easy to connect to a private repo. Prior to running the installer, provide the private repo and your github access token as a Kubernetes secret in the `argocd` namespace
```
apiVersion: v1
kind: Secret
metadata:
  name: first-repo
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: git
  url: https://github.com/solo-io/aoa-lib-private
---
apiVersion: v1
kind: Secret
metadata:
  name: private-repo-creds
  namespace: argocd
  labels:
    argocd.argoproj.io/secret-type: repo-creds
stringData:
  type: git
  url: https://github.com/solo-io
  # personal access token
  password: <access_token>
  username: solo-io
```
