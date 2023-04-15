FROM ubuntu
SHELL ["bash", "-c"]
WORKDIR /usr/local/src
RUN apt update && sudo apt install -y --no-install-recommends linux-modules-extra-$(uname -r) xvfb anbox gawk lzip adb privoxy ffmpeg kmod && apt clean
ENTRYPOINT ["lsmod"]
