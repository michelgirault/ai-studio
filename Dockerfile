FROM nvidia/cuda:12.5.1-cudnn-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility

ENV HOME=/home/llmstudio
ENV APP_PATH=/app
ENV WORKSPACE=/workspace

# All persistent state lives under /workspace so it survives pod restarts
ENV HF_HOME=/workspace/.huggingface
ENV TRANSFORMERS_CACHE=/workspace/.huggingface/hub
ENV HF_DATASETS_CACHE=/workspace/.huggingface/datasets
ENV AWS_SHARED_CREDENTIALS_FILE=/workspace/.aws/credentials
ENV AWS_CONFIG_FILE=/workspace/.aws/config
ENV PATH="$HOME/.local/bin:${PATH}"

# System packages
RUN apt-get update && apt-get install -y \
    git wget curl ca-certificates build-essential cmake pkg-config \
    software-properties-common gnupg2 unzip vim \
    libgoogle-perftools-dev ffmpeg libegl1 libglvnd-dev \
    libopenblas-dev liblapack-dev \
    fuse rclone

RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt install -y python3.10 python3-pip python3.10-distutils python3.10-venv python3.10-dev

RUN ln -sf /usr/bin/python3.10 /usr/bin/python && \
    ln -sf /usr/bin/python3.10 /usr/bin/python3

RUN rm -rf /var/lib/apt/lists/*

# AWS CLI v2
RUN curl -L "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o /tmp/awscliv2.zip && \
    cd /tmp && unzip awscliv2.zip && ./aws/install && \
    rm -rf /tmp/aws /tmp/awscliv2.zip

# Create user
RUN adduser --uid 1999 --disabled-password --gecos "" llmstudio

# Python ML stack — pinned to current stable versions
RUN python -m pip install --no-cache-dir --upgrade pip setuptools wheel

# Core ML stack — install as root so /usr/local/lib is used
RUN python -m pip install --no-cache-dir \
    torch torchvision torchaudio \
    --index-url https://download.pytorch.org/whl/cu121

RUN python -m pip install --no-cache-dir \
    transformers \
    datasets \
    accelerate \
    peft \
    trl \
    bitsandbytes \
    sentencepiece \
    safetensors \
    huggingface_hub[cli] \
    evaluate \
    tokenizers

# Data / utility libs
RUN python -m pip install --no-cache-dir \
    numpy pandas pyarrow \
    boto3 s3fs \
    scikit-learn matplotlib seaborn \
    tqdm wandb tensorboard \
    ipywidgets

# JupyterLab
RUN python -m pip install --no-cache-dir \
    jupyterlab \
    jupyterlab-git \
    notebook

# Workspace + permissions
RUN mkdir -p ${WORKSPACE} ${APP_PATH} ${HOME} && \
    chown -R llmstudio:llmstudio ${WORKSPACE} ${APP_PATH} ${HOME}

# Copy starter
COPY --chown=llmstudio:llmstudio starter.sh ${APP_PATH}/starter.sh
RUN chmod +x ${APP_PATH}/starter.sh

USER llmstudio
WORKDIR ${WORKSPACE}

EXPOSE 8888

CMD ["/bin/bash", "-c", "/app/starter.sh"]