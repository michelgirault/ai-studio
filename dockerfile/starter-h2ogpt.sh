#!/bin/bash
#load env variable
set -a
source .env
set +a
#get folder from git
git clone https://github.com/h2oai/h2ogpt.git h2ogpt/
#create venv
#create local virtual env
python3 -m venv h2ogpt
source h2ogpt/bin/activate
#reinstall ffmpeg
pip install wheel --no-input
pip install ffmpeg --no-input
pip install soundfile librosa wavio --no-input

#install req packages
pip install -r h2ogpt/requirements.txt
pip install -r h2ogpt/reqs_optional/requirements_optional_langchain.txt
#plus addon
pip uninstall llama_cpp_python llama_cpp_python_cuda -y
pip install -r h2ogpt/reqs_optional/requirements_optional_llamacpp_gpt4all.txt --no-cache-dir
pip install -r h2ogpt/reqs_optional/requirements_optional_langchain.urls.txt
pip install -r h2ogpt/reqs_optional/requirements_optional_langchain.urls.txt

#start with one model load from s3
#s3cmd sync s3://lumimai-models/sd/  models/Stable-diffusion --host=${S3_HOST} --host-bucket=${S3_BUCKET} --secret_key=${S3_SECRET_KEY} --access_key=${S3_ACCESS_KEY}
#start with the model selected
python3 h2ogpt/generate.py  --base_model=TheBloke/Mistral-7B-Instruct-v0.2-GGUF --prompt_type=mistral --max_seq_len=4096 --share=True --openai_server=True --openai_workers=2 --openai_port=5000
#python3 h2ogpt/generate.py --base_model=$MODEL_LOCALPATH/Llama-2-7B.gguf --prompt_type=llama2 --score_model=None --langchain_mode=UserData --openai_server=True --share=True #optional