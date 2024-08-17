FROM nvidia/cuda:12.5.1-base-ubuntu22.04
#start with root to install packages
#setup declaration
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV INSTALL_APT="apt install -y"
ENV INSTALL_PIP="python3 -m pip --no-cache-dir install --upgrade"
ENV HOME=/home/llmstudio
ENV APP_PATH=/app
ENV PATH="$PATH:$HOME/.local/bin"

#start update current packages
RUN apt-get update && apt-get install -y \
    git \
    ethtool \
    wget \
    build-essential \
    zlib1g \
    cmake \
    ca-certificates \
    lsb-release \
    apache2-utils \
    gnupg2 \
    unzip \
    vim \
    man \
    git-lfs \
    kmod \
    curl \
    software-properties-common \
    libgoogle-perftools-dev \
    bc \
    ffmpeg \
    linux-headers-generic \
    libopenblas-dev \
    liblapack-dev \
    libegl1 \
    libglvnd-dev \
    pkg-config \
    pipenv 

#install python and libs
RUN add-apt-repository ppa:deadsnakes/ppa && \
    $INSTALL_APT \
    python3.10 \
    python3-pip \
    python3.10-distutils \
    python3-venv \
    python3-opencv \
    python3-tk

#clear
RUN rm -rf /var/lib/apt/lists/*

#install all python and pip packages
RUN $INSTALL_PIP \
    Wave \
    jupyterlab \
    notebook \
    pickleshare \
    huggingface_hub \
    awscli \
    wheel \
    perftool \
    fastapi \
    deepspeed \
    pickleshare

#based on llmstudio from h2o setup use uid not common

RUN adduser --uid 1999 llmstudio

#create working folder
WORKDIR ${APP_PATH}
COPY . ${APP_PATH}


#prepare folders
RUN mkdir apps/
RUN mkdir models/
RUN mkdir datasets/

#install git repo for the fine tune studio
RUN git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git apps/stable-diffusion-webui/
RUN cd apps/stable-diffusion-webui/ && \
    pip install -r requirements.txt --no-cache-dir
#llama factory
RUN git clone --depth 1 https://github.com/hiyouga/LLaMA-Factory.git apps/llama-factory/
RUN cd apps/llama-factory/ && \
    pip install -e .[torch,metrics]

RUN \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 && \
    chmod -R a+w /home/llmstudio && chown -R llmstudio:llmstudio /home/llmstudio &&\
    chmod +x ${APP_PATH}/starter.sh &&\
    chmod -R a+w ${APP_PATH} && chown -R llmstudio:llmstudio ${APP_PATH}

#switch to the llmstudio user
USER llmstudio

#for llmstudio 
EXPOSE 7861
EXPOSE 7860
CMD ["/bin/bash", "-c", "./starter.sh"]


