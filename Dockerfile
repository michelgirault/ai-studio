FROM ubuntu:jammy

#start with root to install packages
#setup declaration
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV INSTALL_APT="apt install -y"
ENV INSTALL_PIP="python3 -m pip --no-cache-dir install --upgrade"
ENV HOME=/home/llmstudio
ENV APP_PATH=/app
ENV JUPYTER_APP_LAUNCHER_PATH=${APP_PATH}/notebook/apps

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
    python3-opencv

#clear
RUN rm -rf /var/lib/apt/lists/*

#install all python and pip packages
RUN $INSTALL_PIP \
    Wave \
    h2o-wave \
    jupyterlab \
    notebook \
    pickleshare \
    bash_kernel \
    s3contents \
    s3cmd \
    huggingface_hub \
    awscli \
    jupyter-app-launcher \
    wheel 

#install spec for bash kernel
RUN python3 -m bash_kernel.install

#based on llmstudio from h2o setup use uid not common

RUN adduser --uid 1999 llmstudio
USER llmstudio

#create working folder
WORKDIR ${APP_PATH}
COPY . ${APP_PATH}

USER root

#run fix gpu driver vultr
#RUN bash script-gpu-install.sh
#RUN apt install -y vultr-nvidia-client-drivers

RUN \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 && \
    chmod -R a+w /home/llmstudio && chown -R llmstudio:llmstudio /home/llmstudio

#fix permission and add execution right
RUN chmod +x ${APP_PATH}/starter.sh
RUN mkdir ${APP_PATH}/notebook/apps && mv jp_app_launcher.yaml ${JUPYTER_APP_LAUNCHER_PATH}
RUN chmod +x ${APP_PATH}/notebook/apps && chown -R llmstudio:llmstudio ${APP_PATH}/notebook/apps
RUN chmod +x ${APP_PATH}/notebook/ && chown -R llmstudio:llmstudio ${APP_PATH}/notebook/
#folder for s3 sync
RUN mkdir ${APP_PATH}/.s3folder && chown -R llmstudio:llmstudio ${APP_PATH}/.s3folder

#switch to the llmstudio user
USER llmstudio

#h2o env for llmstudio
ENV H2O_WAVE_APP_ADDRESS=http://127.0.0.1:8756
ENV H2O_WAVE_MAX_REQUEST_SIZE=25MB
ENV H2O_WAVE_NO_LOG=true
ENV H2O_WAVE_PRIVATE_DIR="/download/@/${APP_PATH}/output/download"

#for llmstudio jupyter
EXPOSE 8887
CMD ["/bin/bash", "-c", "./starter.sh"]


