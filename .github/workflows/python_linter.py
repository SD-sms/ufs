name: Python linting
on:
  push:
    branches:
      - develop
      - 'release/*'
  pull_request:
    branches:
      - develop
      - 'release/*'
  workflow_dispatch:

defaults:
  run:
    shell: bash
jobs:

  python_linter:
    name: Python unittests
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v2

      # Install dependencies
      - name: Install dependencies
        run: |
          sudo apt-get update
          sudo apt-get install python3 python3-pip netcdf-bin
          sudo pip3 install pylint

      # Run python unittests
      - name: Lint the test directory
        run: |
          pylint --ignore-imports=yes tests/test_python/
