#!/bin/bash
#load env variable
set -a
source .env
set +a
#optional
#sync with s3 from the start
#startup soft
jupyter-lab --ip 0.0.0.0 --port 8887 --no-browser --allow-root --notebook-dir=/app/notebook