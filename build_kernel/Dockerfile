FROM archlinux:latest

COPY . /usr/local/bin/

# Obtain all needed packages from Arch Linux repos
RUN pacman -Sy --noconfirm repo python git openssl rsync unzip \
    openssh base-devel make cpio parallel && \
    # Create our building directory
    mkdir -p /opt/build/ && chmod a+x /usr/local/bin/entrypoint.bash /usr/local/bin/build_kernel.sh

WORKDIR /opt/build/
ENTRYPOINT ["/usr/local/bin/entrypoint.bash"]
