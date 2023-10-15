FROM archlinux:latest

# Copy the directory into the container
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY install_sdk.sh /usr/local/bin/install_sdk.sh
COPY build_applications.sh /usr/local/bin/build_applications.sh
COPY .gitconfig /root/.gitconfig

# Obtain all needed packages from Arch Linux repos
RUN pacman -Sy --noconfirm git jdk17-openjdk npm rsync unzip base-devel glibc && \
    # Create our building directory
    mkdir -p /opt/build/ && \
    # Give execute permissions
    chmod a+x /usr/local/bin/entrypoint.sh /usr/local/bin/install_sdk.sh /usr/local/bin/build_applications.sh

WORKDIR /opt/build/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
