FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update

RUN apt install -y openssh-server

RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# Install needed packages
RUN apt-get install -y build-essential \
    gcc-multilib \
    autoconf \
    automake \
    bison \
    cmake \
    curl \
    doxygen \
    flex \
    git \
    gtkwave \
    libftdi-dev \
    libftdi1 \
    libjpeg-dev \
    libsdl2-dev \
    libsdl2-ttf-dev \
    libsndfile1-dev \
    libtool \
    libusb-1.0-0-dev \
    pkg-config \
    rsync \
    scons \
    texinfo \
    wget \
    sudo \
    tmux \ 
    graphviz \
    xdg-utils

RUN mkdir -p ~/miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
RUN bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
RUN rm -rf ~/miniconda3/miniconda.sh
RUN ~/miniconda3/bin/conda init bash
RUN ~/miniconda3/bin/conda install python=3.10 -y

RUN git clone https://github.com/GreenWaves-Technologies/gap_riscv_toolchain_ubuntu.git

RUN /bin/bash -c "cd gap_riscv_toolchain_ubuntu; ./install.sh '/usr/lib/gap_riscv_toolchain'"

RUN git clone https://github.com/GreenWaves-Technologies/gap_sdk

RUN cd /gap_sdk; ~/miniconda3/bin/pip install -r requirements.txt; ~/miniconda3/bin/pip install -r doc/requirements.txt

COPY ./libtile.4.3.5.a /gap_sdk/tools/autotiler_v3/Autotiler/LibTile.a

RUN /bin/bash  -c "cd gap_sdk; source configs/gapuino_v3.sh; mv /gap_sdk/tools/autotiler_v3/Makefile /gap_sdk/tools/autotiler_v3/Makefile_tmp; make all; mv /gap_sdk/tools/autotiler_v3/Makefile_tmp /gap_sdk/tools/autotiler_v3/Makefile"

RUN curl -fsSL 'https://raw.githubusercontent.com/hyeondg/config/main/.tmux.conf' >$HOME/.tmux.conf

RUN git clone https://github.com/hyeondg/config.git; mkdir -p ~/.config; cp -r config/starter ~/.config/nvim

RUN cd; wget https://github.com/neovim/neovim/releases/download/v0.10.1/nvim-linux64.tar.gz; tar xzvf nvim-linux64.tar.gz

RUN echo "alias nvim='~/nvim-linux64/bin/nvim'" >> ~/.bashrc

RUN ~/nvim-linux64/bin/nvim --headless "+Lazy! update" +q!

RUN cd /gap_sdk/tools/nntool; ~/miniconda3/bin/pip install -r requirements.txt; ~/miniconda3/bin/pip install pydot;

RUN cd /gap_sdk; git remote set-url origin https://github.com/hyeondg/gap_sdk.git
