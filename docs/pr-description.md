# Pull request draft

**Title:** `Complete DevOps intern assessment implementation and validation`

## Description

Completes the local assessment repository with a hardened NGINX image and structured access logs, a local Grafana/Loki/Alloy stack, the Nomad job and Consul HTTP health check, and implementation-focused setup and verification documentation.

The application image was rebuilt and smoke-tested locally. ShellCheck and Hadolint passed in the versioned tool containers used by CI. The Nomad job validates and its existing allocation is healthy; Grafana, Loki, and Alloy are healthy and a real NGINX log query returned entries. GitHub Actions, GHCR publication, and release creation have not yet been verified or performed.

## Reviewer checklist

- [ ] Confirm the remote repository name, visibility, and default branch.
- [ ] Review the feature branch diff against current `main`; confirm only intended files are included.
- [ ] Confirm no `.env`, credentials, local state, or generated cache files are staged.
- [ ] Review NGINX base image/version, non-root runtime, port 8080, health check, and JSON log format.
- [ ] Review CI triggers, permissions, PR-safe publish condition, and GHCR tags.
- [ ] Review Alloy's Docker socket access and local-only monitoring exposure.
- [ ] Confirm the existing Nomad allocation is intentionally left on NGINX 1.27.4 until a separate redeployment is reviewed.
- [ ] Require all pull-request CI checks to pass before merge.
- [ ] Capture and inspect the required screenshots listed in `evidence-checklist.md`.

## Proposed local commit sequence

1. `fix: repair gitignore and refresh nginx image logging`
2. `feat: add local grafana loki alloy monitoring`
3. `feat: add Nomad deployment job with Consul health checks`
4. `docs: document assessment setup validation and evidence`

These commits have not been created. The workflow and homepage status flags currently have no content diff and should not be staged unless a fresh review identifies an intentional change.

## Submission commands (run only after owner approval)

After confirming the remote repository and updating the feature branch with the intended commits:

```bash
git push -u origin feature/repository-bootstrap
gh pr create --base main --head feature/repository-bootstrap \
  --title "Complete DevOps intern assessment implementation and validation" \
  --body-file docs/pr-description.md
```

After the PR is reviewed and checks pass, merge using the repository's approved merge method. Then verify the merge commit and successful `main` workflow/GHCR publication in GitHub before tagging. Once the intended final commit is confirmed:

```bash
git switch main
git pull --ff-only origin main
git log -1 --oneline
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

For a merge commit that preserves the proposed incremental history, the optional GitHub CLI command is:

```bash
gh pr merge <PR_NUMBER> --merge
```

Verify the main workflow before release:

```bash
gh run list --branch main --workflow ci.yml --limit 5
gh run watch <RUN_ID> --exit-status
docker buildx imagetools inspect ghcr.io/divs-lab/devops-intern-final:sha-<FULL_COMMIT_SHA>
docker buildx imagetools inspect ghcr.io/divs-lab/devops-intern-final:latest
```

Replace the placeholders with the reviewed PR number, successful workflow run ID, and full merge commit SHA. Confirm package visibility separately in GitHub if public pulls are required. The merge and tag commands are later external actions and are not authorized or executed as part of local preparation. Verify the tag resolves to the reviewed merge commit and the required CI checks are green before pushing it.
