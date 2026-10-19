# Submission record

## Pull request

- PR: [#1 — Feature/repository bootstrap](https://github.com/divs-lab/devops-intern-final/pull/1)
- State: merged to `main`
- Merge commit: `d069a6375dc8396bc85f6becf8923e023d481bf9`

The pull request completed the NGINX image, shell scripts, GitHub Actions workflow, Nomad/Consul service job, local Grafana/Loki/Alloy stack, and repository documentation.

## Continuous integration and image publication

- Main workflow run: [CI #2](https://github.com/divs-lab/devops-intern-final/actions/runs/39277947649)
- Result: lint, build/test, and publish jobs all succeeded.
- Published image tags: `ghcr.io/divs-lab/devops-intern-final:sha-d069a6375dc8396bc85f6becf8923e023d481bf9` and `ghcr.io/divs-lab/devops-intern-final:latest`.
- Both tags resolved to `sha256:d1de1c8941a81ab882082ffc1916fa74182fbfa96f1453c3bf93d25534260d63` when inspected.
- Release tag: annotated `v1.0.0`, targeting the merge commit above.

## Evidence still to capture

The evidence checklist in [`evidence-checklist.md`](evidence-checklist.md) tracks the two remaining manual screenshots: ShellCheck/Hadolint terminal output and Grafana Explore showing real NGINX logs. No credentials or secrets belong in evidence.
