FROM archlinux:latest

# Copy the directory into the container
COPY . /usr/local/bin

# Obtain all needed packages from Arch Linux repos
RUN pacman -Sy --noconfirm git jdk17-openjdk npm rsync unzip base-devel && \
    # Create our building directory
    mkdir -p /opt/build/ && \
    # Give execute permissions
    chmod a+x /usr/local/bin/entrypoint.bash /usr/local/bin/install_sdk.sh /usr/local/bin/build_applications.sh

WORKDIR /opt/build/
ENTRYPOINT ["/usr/local/bin/entrypoint.bash"]
