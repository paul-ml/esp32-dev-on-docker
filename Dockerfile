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
RUN git clone https://github.com/rbenv/rbenv.git /root/.rbenv
ENV PATH=$PATH:/root/.rbenv/bin
RUN echo 'eval "$(rbenv init -)"' >> /root/.bashrc
RUN mkdir -p "$(rbenv root)"/plugins
RUN git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
RUN apt-get install -y libssl-dev libreadline-dev zlib1g-dev
RUN rbenv install 2.6.3
RUN rbenv global 2.6.3
RUN eval "$(rbenv init -)" && rbenv install mruby-1.4.1

# Move to working directory
VOLUME /proj
WORKDIR /proj

ENTRYPOINT ["make"]
