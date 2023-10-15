FROM archlinux:latest

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY build_vanadium.sh /usr/local/bin/build_vanadium.sh
COPY .gitconfig /root/.gitconfig

# Obtain all needed packages from Arch Linux repos
RUN pacman -Sy --noconfirm repo python git  \ 
    openssl rsync unzip zip python-protobuf \
    gperf lib32-glibc lib32-gcc-libs base-devel make cpio parallel && \
    # Create our building directory
    mkdir -p /opt/build/ && \
    chmod a+x /usr/local/bin/entrypoint.bash /usr/local/bin/build_vanadium.sh 

WORKDIR /opt/build/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
