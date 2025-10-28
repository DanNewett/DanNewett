#!/usr/bin/env bash
set -euo pipefail

HANDLE="DanNewett"
EMAIL="dannewettsr@gmail.com"

ROOT_DIR="github-fast-track-personalized"
REPOS=(
  "engineering-playbook"
  "ci-cd-pipeline-templates"
  "aws-microservices-demo"
  "ai-doc-intelligence"
  "program-portfolio-tracker"
)

echo "==> Checking prerequisites..."
command -v gh >/dev/null 2>&1 || { echo "ERROR: GitHub CLI (gh) not found. Install from https://cli.github.com/"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "ERROR: git not found."; exit 1; }
gh auth status || { echo "ERROR: Please run 'gh auth login' first."; exit 1; }

echo "==> Setting git identity (local)"
git config --global user.name "${HANDLE}"
git config --global user.email "${EMAIL}"

if [ ! -d "${ROOT_DIR}" ]; then
  echo "ERROR: '${ROOT_DIR}' not found. Unzip the personalized bundle first so this folder exists."
  exit 1
fi

echo "==> Creating and pushing profile repo '${HANDLE}'"
cd "${ROOT_DIR}/${HANDLE}"
git init
git add .
git commit -m "feat: profile README"
git branch -M main
gh repo create "${HANDLE}" --public --source=. --push --disable-issues=false --disable-wiki=true

echo "==> Creating and pushing showcase repos"
cd ..  # back to root of bundle (github-fast-track-personalized)

# Replace workflow approver handle
if [ -f "ci-cd-pipeline-templates/github-actions/app-ci-cd-multienv.yml" ]; then
  if sed --version >/dev/null 2>&1; then
    # GNU sed
    sed -i "s/approvers: your-github-handle/approvers: ${HANDLE}/" ci-cd-pipeline-templates/github-actions/app-ci-cd-multienv.yml
  else
    # BSD sed (macOS)
    sed -i '' "s/approvers: your-github-handle/approvers: ${HANDLE}/" ci-cd-pipeline-templates/github-actions/app-ci-cd-multienv.yml
  fi
fi

for r in "${REPOS[@]}"; do
  echo "----> ${r}"
  cd "${r}"
  git init
  git add .
  git commit -m "chore: initial import"
  git branch -M main
  gh repo create "${HANDLE}/${r}" --public --source=. --push --disable-issues=false --disable-wiki=true
  cd ..
done

echo ""
echo "==> All repos created and pushed to https://github.com/${HANDLE}"
cat <<EONOTE

Next steps:
1) Go to your GitHub profile → Customize your pins → pin in this order:
   1) engineering-playbook
   2) ci-cd-pipeline-templates
   3) aws-microservices-demo
   4) program-portfolio-tracker
   5) ai-doc-intelligence
   6) ${HANDLE}
2) In engineering-playbook → Actions → ensure 'profile-refresh' is enabled.
3) Done! Your profile is polished and active.
EONOTE
