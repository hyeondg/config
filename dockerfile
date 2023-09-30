FROM --platform=linux/amd64 ubuntu:latest
MAINTAINER Hyeondong Lee <info@hyeondg.org>

RUN apt update 
RUN apt-get -y install vim screen
RUN apt-get -y install libgl1-mesa-glx libglib2.0-0 libx11-xcb-dev libxkbcommon-x11-0
RUN apt-get -y install libfontconfig1 libdbus-1-3
RUN apt-get -y install qemu-system-mips cpp-mips-linux-gnu gcc-mips-linux-gnu qemu-user

COPY rust/qtspim_9.1.24_linux64.deb  .
RUN dpkg -i qtspim_9.1.24_linux64.deb



