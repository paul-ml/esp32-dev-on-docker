FROM ubuntu:18.04
RUN apt-get update
RUN apt-get install -y git wget make libncurses-dev flex bison gperf python python-pip
RUN mkdir /esp
WORKDIR /esp
RUN wget https://dl.espressif.com/dl/xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
RUN tar -xzf xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz && rm -f xtensa-esp32-elf-linux64-1.22.0-80-g6c4433a-5.2.0.tar.gz
RUN echo 'system' > .python-version
ENV PATH=$PATH:/esp/xtensa-esp32-elf/bin
RUN git clone --recursive https://github.com/espressif/esp-idf.git --branch release/v3.2
ENV IDF_PATH=/esp/esp-idf
RUN python -m pip install --user -r $IDF_PATH/requirements.txt
RUN python -m pip install --user pygdbmi==0.9.0.2 gdbgui
RUN usermod -aG dialout root
VOLUME /proj
WORKDIR /proj
ENTRYPOINT ["make"]
