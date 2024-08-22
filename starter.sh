#!/bin/bash

#custom script for ai model workflow builder

#Load env variable 
aws configure set aws_access_key_id $aws_access_key_id
aws configure set aws_secret_access_key $aws_secret_access_key

LLAMA_APP="apps/llama-factory"
STABLE_APP="apps/stable-diffusion-webui"
#make sure the folder existing within the volume

#huggingface-cli download --token $HF_TOKEN stabilityai/stable-diffusion-2 --local-dir /app/notebook/apps/models

#aws s3 sync --endpoint-url=$S3_ENDPOINT s3://$S3_BUCKET=$ $S3_DATASETS_FOLDER --no-progress --quiet

#cd $LLAMA_APP && CUDA_VISIBLE_DEVICES=0 GRADIO_SHARE=1 GRADIO_SERVER_PORT=7861 llamafactory-cli webui --port 7861 &

git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git apps/stable-diffusion-webui/
#install missing package
pip install wheel --no-cache-dir
#install additional libraries and dependencies
pip install perftool fastapi pickleshare perftool --no-input --no-cache-dir
#install package for sd
cd $STABLE_APP && pip install -r requirements.txt --no-cache-dir

cd $STABLE_APP && ./webui.sh -f --port 7860 &
jupyter-lab --ip 0.0.0.0 --port 7861 --no-browser --allow-root --notebook-dir=/app/notebook &
wait
