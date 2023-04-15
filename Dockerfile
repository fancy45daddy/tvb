FROM ubuntu
SHELL ["bash", "-c"]
WORKDIR /usr/local/src
RUN git clone https://github.com/anbox/anbox-modules && awk {gsub\(/sudo/\,\"\"\)}1 anbox-modules/INSTALL.sh | bash
ENTRYPOINT lsmod
