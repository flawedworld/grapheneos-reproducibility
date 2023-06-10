FROM archlinux:latest

# Obtain all needed packages from Arch Linux repos
RUN pacman -Syyuu --noconfirm repo python git gnupg diffutils freetype2 \
fontconfig ttf-dejavu openssl rsync unzip zip python-protobuf nodejs-lts-hydrogen \
yarn gperf lib32-glibc lib32-gcc-libs signify openssh base-devel make cpio parallel

# Obtain all needed packages from AUR
USER nobody
RUN curl --create-dirs -o /tmp/aur/ncurses5-compat-libs/PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=ncurses5-compat-libs && \
echo "033d2b4847a426c3acce3c037708be4cb26890b65f20f2fadc20b2c2d5b7bcfb8e0faf12d2f72350a42c3a3d65a976b0e3016178fc0f19c2427f4a5fae6525d9 /tmp/aur/ncurses5-compat-libs/PKGBUILD" | sha512sum -c || exit 1 && \
cd /tmp/aur/ncurses5-compat-libs/ && makepkg --skippgpcheck
USER root
RUN pacman -U /tmp/aur/ncurses5-compat-libs/ncurses5-compat-libs-* --noconfirm &&\
    useradd -m builduser && \
    usermod -a -G wheel builduser && \
    echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/nopass

COPY entrypoint.bash /usr/local/bin/build-entrypoint.bash
USER builduser

# Customize build as needed
# Build target: development, stable, or a specific tag
# Kernels to build: coral, oriole  etc.
# Apps to build: Auditor, Apps, etc.

ENV DEVICES_TO_BUILD=redfin,oriole,bluejay \
    BUILD_TARGET=development \
    KERNELS_TO_BUILD=none \
    APPS_TO_BUILD=none \
    SKIP_GRAPHENEOS=false \
    BUILD_VANADIUM=false \
    OFFICIAL_BUILD=true 

WORKDIR /opt/build/grapheneos
ENTRYPOINT ["/usr/local/bin/build-entrypoint.bash"]