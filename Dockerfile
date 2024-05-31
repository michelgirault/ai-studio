FROM nvidia/cuda:12.3.1-base-ubuntu22.04

#setup declaration
ENV DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV INSTALL_APT="apt install -y"
ENV INSTALL_PIP="python3 -m pip --no-cache-dir install --upgrade"
ENV HOME=/home/llmstudio


RUN apt-get update && apt-get install -y \
    git \
    git-lfs \
    curl \
    software-properties-common \
    libgoogle-perftools-dev \
    bc \
    ffmpeg \
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

#install all python and pip
RUN $INSTALL_PIP \
    Wave \
    h2o-wave \
    jupyterlab \
    pickleshare \
    bash_kernel \
    s3contents \
    jupyter-app-launcher 

#install spec for bash kernel
RUN python3 -m bash_kernel.install


#based on llmstudio from h2o

RUN adduser --uid 1999 llmstudio
USER llmstudio

#create working folder
WORKDIR /workspace
COPY . /workspace
USER root
RUN \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 && \
    chmod -R a+w /home/llmstudio && chown -R llmstudio:llmstudio /home/llmstudio
RUN chmod +x /workspace/starter.sh
RUN mkdir /workspace/notebook/apps
RUN chmod +x /workspace/notebook/apps && chown -R llmstudio:llmstudio /workspace/notebook/apps
RUN chmod +x /workspace/notebook/ && chown -R llmstudio:llmstudio /workspace/notebook/
USER llmstudio
#h2o env for llmstudio
ENV H2O_WAVE_APP_ADDRESS=http://127.0.0.1:8756
ENV H2O_WAVE_MAX_REQUEST_SIZE=25MB
ENV H2O_WAVE_NO_LOG=true
ENV H2O_WAVE_PRIVATE_DIR="/download/@/workspace/output/download"
#for llmstudio jupyter book h2ogpt
EXPOSE 10101 8887 7860 5000
CMD [ "/workspace/starter.sh" ]
