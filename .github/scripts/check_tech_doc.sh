#!/bin/bash
# This script recreates technical documentation for the ush and tests/WE2E Python scripts
# If the tech docs produced here do not match the branch's contents, the script will fail

# Install prerequisites
sudo apt-get install python3-sphinx
sudo apt-get install python3-sphinx-rtd-theme
pip install sphinxcontrib-bibtex

# Remove existing directories
cd doc/TechDocs
rm -rf ush
rm -rf tests/WE2E

# Regenerate tech docs in ush and tests/WE2E based on current state of scripts in those directories.
sphinx-apidoc -fM -o ./ush ../../ush
sphinx-apidoc -fM -o ./tests/WE2E ../../tests/WE2E

# Check for mismatch between what comes out of this action and what is in the PR. 
status=`git status -s`
echo "...${status}..."

if [ -n "${status}" ]; then
  echo ${status}
  echo "Status size is: ${#status}."
  echo ""
  echo "Please update your Technical Documentation RST files."
  exit 1
else
  echo "Status size is: ${#status}."
  echo "Technical documentation is up-to-date."
  exit 0
fi
