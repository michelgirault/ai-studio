#!/bin/bash
#load env variable
set -a
source .env
set +a
#optional
#sync with s3 from the start
mkdir ~/.s3-folder/
s3cmd sync s3://lumimai-datasets/ ~/.s3-folder/ --host=$S3_HOST --host-bucket=$S3_BUCKET --secret_key=$S3_SECRET_KEY --access_key=$S3_ACCESS_KEY
#startup soft
jupyter-lab --ip 0.0.0.0 --port 8887 --no-browser --allow-root --notebook-dir=/workspace/notebook