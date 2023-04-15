FROM ubuntu
SHELL ["bash", "-c"]
WORKDIR /usr/local/src
RUN apt update && apt install -y --no-install-recommends git ca-certificates && git clone https://github.com/anbox/anbox-modules && awk {gsub\(/sudo/\,\"\"\)}1 anbox-modules/INSTALL.sh | bash
ENTRYPOINT lsmod
