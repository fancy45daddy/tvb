FROM fedora:32
SHELL ["bash", "-c"]
WORKDIR /usr/local/src
RUN apt update && apt install -y --no-install-recommends git ca-certificates dkms && git clone https://github.com/anbox/anbox-modules && cd anbox-modules && mkdir /etc/modules-load.d && awk {gsub\(/sudo/\,\"\"\)}1 INSTALL.sh | bash
ENTRYPOINT lsmod
