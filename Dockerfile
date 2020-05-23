FROM ubuntu:18.04

# Use bash
SHELL ["/bin/bash", "-c"]

# Install packages
RUN apt update
RUN apt install -y tree gcc git wget make libncurses-dev flex bison \
                   gperf python python-pip python-setuptools python-serial \
                   python-cryptography python-future python-pyparsing

# Install ESP32 tools
RUN mkdir /esp
WORKDIR /esp
RUN wget https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
RUN tar -xzf xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz && rm -f xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz

# Set environment variables
ENV PATH=$PATH:/esp/xtensa-esp32-elf/bin
ENV IDF_PATH=/esp/esp-idf
# Clone ESP-IDF
RUN git clone --recursive https://github.com/espressif/esp-idf.git --branch release/v3.2

# Install tools made by python
RUN echo 'system' > .python-version
RUN python -m pip install --user -r $IDF_PATH/requirements.txt
RUN python -m pip install --user pygdbmi==0.9.0.2 gdbgui

# Add to dialout group to add permission to access serial port
RUN usermod -aG dialout root

# Install Ruby
# basics
RUN apt-get install -qy procps curl ca-certificates gnupg2 build-essential --no-install-recommends && apt-get clean

# install RVM and Ruby
RUN gpg2 --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install 2.6.3"
RUN /bin/bash -l -c ". /etc/profile.d/rvm.sh && rvm install mruby-1.4.1"
RUN source /etc/profile.d/rvm.sh
RUN PATH="$PATH"
RUN exec bash
RUN apt-get install -y mruby
RUN export PATH="/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin"
# Move to working directory
VOLUME /proj
WORKDIR /proj

ENTRYPOINT ["make"]

