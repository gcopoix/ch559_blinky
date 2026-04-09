FROM debian:11-slim

ARG USER_NAME=user
ARG USER_UID=1000
ARG USER_GID=$USER_UID

ENV DEBIAN_FRONTEND=noninteractive


RUN apt update \
  && apt install -y --no-install-recommends \
        sudo \
        bash-completion \
        ca-certificates \
        wget \
        build-essential \
        # Small Devices C Compiler (e.g. C51)
        sdcc \
        gawk \
        # git
        git \
        git-lfs \
        # required for git message editing (rebase -i)
        nano \
    && git lfs install --system

# CH559 udev rules and USB services/utils
RUN  apt install -y --no-install-recommends \
        udev \
        usbutils \
  && echo 'ATTRS{idVendor}=="4348", ATTRS{idProduct}=="55e0", GROUP="plugdev", MODE="0666"' > '/etc/udev/rules.d/99-ch559.rules'

# Add user account and add to sudo group (password-free)
RUN  groupadd --gid $USER_GID $USER_NAME \
  && adduser  --uid $USER_UID --gid $USER_GID --disabled-password --gecos "" $USER_NAME \
  && usermod -a -G dialout $USER_NAME \
  && usermod -a -G plugdev $USER_NAME \
  && echo "$USER_NAME ALL = NOPASSWD: ALL" > /etc/sudoers.d/user \
  && chmod 0440 /etc/sudoers.d/user

WORKDIR /root/src

# install CH55x flash tool from source (lacks support of new bootloader version)
#RUN  apt install -y --no-install-recommends \
#         libusb-1.0-0-dev \
#         pkg-config \
#  && git clone --depth=1 https://github.com/rgwan/librech551.git \
#  && make -C librech551/usbisp -j install \
#  && rm -rf librech551

# install WCH CH55x, CH57x and CH32Fx flashing tool from source
RUN  apt install -y --no-install-recommends \
        libusb-1.0-0-dev \
  && git clone --depth=1 https://github.com/frank-zago/isp55e0.git \
  && make -C isp55e0 -j \
  && mv isp55e0/isp55e0 /usr/local/bin/ \
  && rm -rf isp55e0

# install another working WCH CH55x flashing tool from source
RUN  apt install -y --no-install-recommends \
        libusb-1.0-0-dev \
  && git clone --depth=1 https://github.com/ole00/chprog.git \
  && (cd chprog && ./build_linux.sh) \
  && mv chprog/chprog /usr/local/bin/ \
  && rm -rf chprog

# another CH55x flash tool written in Python (https://github.com/MarsTechHAN/ch552tool)
#RUN  apt install -y --no-install-recommends \
#        python3 \
#        python3-pip \
#  && python3 -mpip install ch55xtool

# install sddbg from source
#RUN  apt install -y --no-install-recommends \
#        cmake \
#        pkg-config \
#        python2.7 \
#        libfmt-dev \
#        libusb-dev \
#        libreadline-dev \
#  && ln -s /usr/bin/env /bin/env \
#  && git clone --depth=1 --recurse-submodules https://github.com/bkleiner/sddbg.git \
#  && mkdir sddbg/build \
#  && cmake -S sddbg -B sddbg/build \
#  && make -C sddbg/build -j \
#  && mv sddbg/build/bin/* /usr/local/bin/ \
#  && rm -rf sddbg

USER $USER_NAME
