FROM archlinux:latest

COPY entrypoint.bash /usr/local/bin/entrypoint.bash
COPY build_kernel.sh /usr/local/bin/build_kernel.sh
COPY .gitconfig /root/.gitconfig

# Obtain all needed packages from Arch Linux repos
RUN pacman -Syu --noconfirm repo python git openssl rsync unzip openssh base-devel make gcc cpio parallel && \
    # Create our building directory
    mkdir -p /opt/build/kernel/ /opt/build/compiled_kernel/ && \
    # Give execute permissions
    chmod a+x /usr/local/bin/entrypoint.bash /usr/local/bin/build_kernel.sh

WORKDIR /opt/build/kernel/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
