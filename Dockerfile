FROM ubuntu:16.04

## Helpful commands
# >> Build the docker container
# docker build -t retriforce .
# >> Run the docker container, mapping a directory into the container
# docker run --rm -it -v "<HOST_SHARE>:<GUEST_DIR>" retriforce

## Tunables
ENV UNICORNVER  0.9
#ENV CAPSTONEVER 3.0.4
ENV CAPSTONEVER next
ENV KEYSTONEVER 0.9.1

## Checkout new versions if you're interested:
# http://www.unicorn-engine.org/download/
# http://www.capstone-engine.org/download.html
# http://www.keystone-engine.org/download/

## Prepare dependencies
RUN apt-get update -y 
RUN apt-get install -y python-dev libglib2.0-dev wget less vim sed cmake time python-pip gdb git libssl-dev libffi-dev build-essential
RUN apt-get install -y lib32stdc++-4.8-dev libc6-dev-i386
RUN pip install --upgrade pip pwntools
RUN apt-get install -y glibc-source
RUN apt-get clean

###########################################################
## Install the Unicorn Engine
# Get the Unicorn-Engine sources
WORKDIR /usr/src
RUN wget https://github.com/unicorn-engine/unicorn/archive/$UNICORNVER.tar.gz && tar -xzf $UNICORNVER.tar.gz

# Build the Unicorn-Engine
WORKDIR /usr/src/unicorn-$UNICORNVER
RUN ./make.sh && ./make.sh install

# Build the Python bindings
WORKDIR /usr/src/unicorn-$UNICORNVER/bindings/python
RUN make install

###########################################################
## Install the Captsone Engine
# Get the Capstone-Engine sources
WORKDIR /usr/src
RUN wget https://github.com/aquynh/capstone/archive/$CAPSTONEVER.tar.gz && tar -xzf $CAPSTONEVER.tar.gz

# Build the Unicorn-Engine
WORKDIR /usr/src/capstone-$CAPSTONEVER
RUN ./make.sh && ./make.sh install

# Build the Python bindings
WORKDIR /usr/src/capstone-$CAPSTONEVER/bindings/python
RUN make install

###########################################################
## Install the Keystone Engine
# Get the Keystone-Engine sources
WORKDIR /usr/src
RUN wget https://github.com/keystone-engine/keystone/archive/$KEYSTONEVER.tar.gz && tar -xzf $KEYSTONEVER.tar.gz

# Build the Keystone-Engine
WORKDIR /usr/src/keystone-$KEYSTONEVER
RUN mkdir build
WORKDIR /usr/src/keystone-$KEYSTONEVER/build
RUN ../make-share.sh
RUN make install

# Build the Python bindings
WORKDIR /usr/src/keystone-$KEYSTONEVER/bindings/python
RUN make install

# Very important for Ubuntu! Otherwise keystone python scripts will not run
RUN sed  -i '1i /usr/local/lib/' /etc/ld.so.conf
RUN ldconfig

##########################################################
## Install pwngdb
WORKDIR /root
RUN git clone https://github.com/scwuaptx/Pwngdb.git
RUN cp ./Pwngdb/.gdbinit ~/
RUN wget -O ~/.gdbinit-gef.py -q https://github.com/hugsy/gef/raw/master/gef.py
RUN git clone https://github.com/longld/peda.git ~/peda
RUN tac ~/.gdbinit > gdbinit.tmp; echo "source ~/.gdbinit-gef.py\nsource ~/Pwngdb/angelheap/gdbinit.py" >> gdbinit.tmp && tac ./gdbinit.tmp > ~/.gdbinit && rm -f gdbinit.tmp
###########################################################
# Cleanup
RUN rm -rf /usr/src/*

WORKDIR /root

