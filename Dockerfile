FROM nvidia/cuda:12.3.1-base-ubuntu22.04

ARG DEBIAN_FRONTEND=noninteractive
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility

RUN apt-get update && apt-get install -y \
    git \
    curl \
    software-properties-common \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt install -y python3.10 \
    && apt install -y python3-pip \
    && apt install -y python3.10-distutils \
    && apt install -y python3-venv \
    && rm -rf /var/lib/apt/lists/*
RUN pip install Wave --no-input
RUN pip install h2o-wave --no-input
#add additional lib missing
RUN apt update && apt install -y libgoogle-perftools-dev bc python3-opencv ffmpeg pipenv
#install jupyter for fine tuning
RUN pip install jupyterlab --no-input
#RUN pip install --upgrade "elyra[all]" --no-input
RUN pip install pickleshare bash_kernel --no-input
RUN python3 -m bash_kernel.install
RUN pip install jupyter-app-launcher s3contents
# Pick an unusual UID for the llmstudio user.
# In particular, don't pick 1000, which is the default ubuntu user number.
# Force ourselves to test with UID mismatches in the common case.
RUN adduser --uid 1999 llmstudio
USER llmstudio
#create working folder
WORKDIR /workspace
RUN \
    curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10 && \
    chmod -R a+w /home/llmstudio
COPY . /workspace
RUN ls -la
USER root
RUN chmod +x /workspace/starter.sh
RUN mkdir /workspace/notebook/apps
RUN chmod +x /workspace/notebook/apps && chown -R llmstudio:llmstudio /workspace/notebook/apps
RUN chmod +x /workspace/notebook/ && chown -R llmstudio:llmstudio /workspace/notebook/
USER llmstudio
#add sd tools
ENV HOME=/home/llmstudio
#add env variables
ENV H2O_WAVE_APP_ADDRESS=http://127.0.0.1:8756
ENV H2O_WAVE_MAX_REQUEST_SIZE=25MB
ENV H2O_WAVE_NO_LOG=true
ENV H2O_WAVE_PRIVATE_DIR="/download/@/workspace/output/download"
#for llmstudio
EXPOSE 10101
#for jupyter
EXPOSE 8887
#for h2ogpt
EXPOSE 7860
#h20gpt openai
EXPOSE 5000
CMD [ "/workspace/starter.sh" ]
