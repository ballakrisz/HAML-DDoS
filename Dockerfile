# this base image has python, torch and cuda already. Using this version so CUDA is comapitble with the 1080Ti in my PC (it runs faster than the laptop 3090)
FROM pytorch/pytorch:2.3.1-cuda11.8-cudnn8-devel

RUN apt-get update

# set shell to bash, set -c flag so the commands are interpreted as strings by deafult
SHELL ["/bin/bash", "-c"]

# set informative colors for the building process
ENV BUILDKIT_COLORS=run=green:warning=yellow:error=red:cancel=cyan

# start with root user
USER root

# build-time argument given by build_docker.sh. It is the host user group id
# this is needed so the container user can manipulate the host files without sudo
ARG HOST_USER_GROUP_ARG

# create group appuser with id 999
# create grour hostgroup. This is needed so appuser can manipulate the host file without sudo
# create user appuser: home at /home/appuser, default shell is bash, id 999 and add to appuser group  
# set sudo password as admin for user appuser
# add user appuser to the following groups:
#   sudo (admin privis)
#   hostgroup
#   adm (system logging) --> might not be necessary
#   dip (network devices)
# finally, copy a .bashrc file into the container
RUN groupadd -g 999 appuser && \
    groupadd -g $HOST_USER_GROUP_ARG hostgroup && \
    useradd --create-home --shell /bin/bash -u 999 -g appuser appuser && \
    echo 'appuser:admin' | chpasswd && \
    usermod -aG sudo,hostgroup,adm,dip appuser && \
    cp /etc/skel/.bashrc /home/appuser/

# set working directory
WORKDIR /home/appuser

#install basic dependencies for everything (useful for development, may be stripped for deployment)
USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noniteractive \
    apt-get install -y \
    git \
    git-lfs \
    build-essential \
    wget \
    curl \
    jq \
    gdb \
    sudo \
    nano \
    net-tools \
    python3-venv \
    unzip

# install gdown
USER root
RUN pip install --no-cache-dir gdown

# donwload tha dataset from google drive
USER appuser
RUN gdown https://drive.google.com/file/d/1cr5rGvA7tEiiji801M33SETEz-6POdfQ/view --fuzzy

# unzip the dataset and delete the zip file
USER appuser
RUN unzip 2025-adatelemzo-ddos.zip && \
    rm 2025-adatelemzo-ddos.zip

# create data direcotories and place the .csv files in their corresponding folders
USER appuser
RUN mkdir -p /home/appuser/data/train/ && \
    mkdir -p /home/appuser/data/test/ && \
    mkdir -p /home/appuser/data/gen/
RUN mv 2025-adatelemzo-ddos/*SetA* 2025-adatelemzo-ddos/*SetB* /home/appuser/data/train/ && \
    mv 2025-adatelemzo-ddos/*SetC* /home/appuser/data/test/ && \
    mv 2025-adatelemzo-ddos/*SetD* /home/appuser/data/gen/
RUN rm -rf 2025-adatelemzo-ddos

# copy the requirements.txt into the image
USER root
COPY /misc/requirements.txt .

# install python packages (doesn't need to install python and pip, as it's already installed in base image)
USER appuser
RUN pip install --no-cache-dir -r requirements.txt

# ipykernel is needed for jupyter notebooks
RUN pip install --upgrade --force-reinstall ipykernel

# remove the requirements file, because it will be attached as a volume later, so it can be modified from within the container
USER appuser
RUN rm requirements.txt

#install vscode server and extensions inside the container (if the use_vscode flag is set to true in the /misc/.params file)
USER root
COPY  --chown=appuser:appuser ./misc/.devcontainer/ /home/appuser/.devcontainer/
USER appuser
ARG VSCODE_COMMIT_HASH
RUN bash /home/appuser/.devcontainer/preinstall_vscode.sh $VSCODE_COMMIT_HASH /home/appuser/.devcontainer/devcontainer.json
RUN rm -r .devcontainer

# start as appuser
USER appuser