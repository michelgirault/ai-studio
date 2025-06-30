FROM nvidia/cuda:12.9.1-cudnn-runtime-ubuntu22.04
#start with root to install packages
#setup declaration
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV INSTALL_APT="apt install -y"
ENV INSTALL_PIP="python3 -m pip --no-cache-dir install --upgrade --timeout=100"
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
    nvidia-cuda-toolkit 

#install python and libs
RUN add-apt-repository ppa:deadsnakes/ppa && \
    $INSTALL_APT \
    python3.10 \
    python3-pip \
    python3.10-distutils \
    python3-venv 

RUN cp /usr/bin/python3 /usr/bin/python

#clear
RUN rm -rf /var/lib/apt/lists/*

RUN apt update -y && apt upgrade -y 



#based on llmstudio from h2o setup use uid not common
RUN adduser --uid 1999 llmstudio

#create working folder
WORKDIR ${APP_PATH}
COPY . ${APP_PATH}

#install jupyter
RUN $INSTALL_PIP \
    jupyterlab \
    jupyterhub \
    notebook

#prepare folders
RUN mkdir apps/
RUN mkdir models/
RUN mkdir datasets/



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


