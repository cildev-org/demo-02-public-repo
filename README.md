# demo-02-public-repo

Demo target for Blue-Oryx version-bump pull requests.

> **This image is vulnerable on purpose.** `main` pins `haproxy=2.6.12-1`,
> which is affected by CVE-2023-40225. Do not deploy it anywhere that is
> reachable from a network you care about.

## What is here

| File | Purpose |
| --- | --- |
| `Dockerfile` | Debian 12 image that installs a pinned haproxy from a fixed `snapshot.debian.org` timestamp |
| `haproxy.cfg` | Plain reverse proxy config. Not part of the fix |
| `.github/workflows/build.yml` | Builds the image on every push to `main` and on every pull request. It pushes and deploys nothing |

## Demo flow

1. Blue-Oryx receives a confirmed finding for CVE-2023-40225 on the asset bound
   to this repository.
2. It opens a pull request from a `blue-oryx/<id>` branch that changes one
   thing: the haproxy pin in `Dockerfile`, to the fixed version
   (`2.6.12-1+deb12u1`).
3. The `build` workflow runs on the pull request.
4. A person reviews and merges the pull request. Blue-Oryx never merges.
5. Blue-Oryx reads the merge and moves the task to `awaiting-deploy`.

### What this demo does not prove

The retest is not run against this repository, because there is no live target
behind it. A merged pull request is **not** proof that the exploit is blocked,
and the task does not become `verified-fixed` here. The closed loop (the
original exploit run again against the deployed target, and blocked) is shown
in Demo 1, on the local lab.

## Branches

| Branch | Purpose |
| --- | --- |
| `main` | What Blue-Oryx patches |
| `vulnerable-baseline` | The vulnerable state before any fix. Used only to reset `main`. Do not merge into it and do not delete it |
| `blue-oryx/<id>` | Opened by Blue-Oryx, one per task |

## Reset after a demo

Run from a clone of this repository, with your own credentials (not the token
Blue-Oryx uses):

```bash
# 1. main goes back to the vulnerable state
git fetch origin
git push --force origin origin/vulnerable-baseline:main

# 2. close pull requests that are still open, and delete their branches
gh pr list --state open --json number -q '.[].number' | xargs -n1 gh pr close --delete-branch

# 3. delete blue-oryx/* branches left by merged pull requests
git ls-remote --heads origin 'blue-oryx/*' | cut -f2 | sed 's|^refs/heads/||' | xargs -n1 git push origin --delete
```

Steps 2 and 3 print a usage error when there is nothing to close or delete;
that is fine.

The force push in step 1 is refused when `main` is protected. Either give
repository admins a bypass in the ruleset, or reset through a pull request
from `vulnerable-baseline`.

Blue-Oryx keeps its own record of the old task. Close that task there, and
ingest the finding again under a new finding key before the next run.
