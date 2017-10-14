FROM ubuntu:16.04 as builder

## Tunables
ENV UNICORNVER  0.9
#ENV CAPSTONEVER 3.0.4
ENV CAPSTONEVER next
ENV KEYSTONEVER 0.9.1

## Prepare dependencies
RUN apt-get update -y 
RUN apt-get install -y python-dev libglib2.0-dev wget less vim sed cmake time python-pip gdb git libssl-dev libffi-dev build-essential
RUN apt-get install -y lib32stdc++-4.8-dev libc6-dev-i386

###########################################################
## Install the Unicorn Engine
# Get the Unicorn-Engine sources
WORKDIR /usr/src
RUN wget https://github.com/unicorn-engine/unicorn/archive/$UNICORNVER.tar.gz && tar -xzf $UNICORNVER.tar.gz

# Build the Unicorn-Engine
WORKDIR /usr/src/unicorn-$UNICORNVER
RUN ./make.sh && ./make.sh install

###########################################################
## Install the Captsone Engine
# Get the Capstone-Engine sources
WORKDIR /usr/src
RUN wget https://github.com/aquynh/capstone/archive/$CAPSTONEVER.tar.gz && tar -xzf $CAPSTONEVER.tar.gz

# Build the Capstone-Engine
WORKDIR /usr/src/capstone-$CAPSTONEVER
RUN ./make.sh && ./make.sh install

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

##########################################################
## The big show

FROM ubuntu:16.04

## Pwntools deps + wget, gdb
RUN apt-get update
RUN apt-get install -y python2.7 python-pip python-dev git libssl-dev libffi-dev build-essential python3-pip wget gdb
RUN pip install -U pip
RUN pip install -U pwntools

## Bring in artifacts
RUN mkdir /usr/include/unicorn
COPY --from=builder /usr/include/unicorn/* /usr/include/unicorn/

RUN mkdir /usr/include/capstone
COPY --from=builder /usr/include/capstone/* /usr/include/capstone/

COPY --from=builder /usr/local/lib/libkeystone.so.0 /usr/local/lib/

RUN sed  -i '1i /usr/local/lib/' /etc/ld.so.conf
RUN ldconfig

RUN pip3 install --upgrade unicorn ropper capstone retdec-python keystone-engine

##########################################################
## Install pwngdb
WORKDIR /root
RUN git clone https://github.com/scwuaptx/Pwngdb.git
RUN cp ./Pwngdb/.gdbinit ~/
RUN wget -O ~/.gdbinit-gef.py -q https://github.com/hugsy/gef/raw/master/gef.py
RUN git clone https://github.com/longld/peda.git ~/peda
RUN tac ~/.gdbinit > gdbinit.tmp; echo "source ~/.gdbinit-gef.py\nsource ~/Pwngdb/angelheap/gdbinit.py" >> gdbinit.tmp && tac ./gdbinit.tmp > ~/.gdbinit && rm -f gdbinit.tmp

WORKDIR /root

