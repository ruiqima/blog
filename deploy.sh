#!/bin/sh

# If a command fails then the deploy stops
set -e

printf "\033[0;32mDeploying updates to GitHub...\033[0m\n"

# Set commit message
msg="rebuilding site $(date)"
if [ -n "$*" ]; then
	msg="$*"
fi

# Add changes to git.
git add .

# Commit changes.
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Build the project.
hugo --gc --minify # if using a theme, replace with `hugo -t <YOURTHEME>`

# Go To Public folder
cd public

# Add changes to git.
git add .

# Commit changes.
git commit -m "$msg"

# Push source and build repos.
git push -f origin master

git push -f coding master