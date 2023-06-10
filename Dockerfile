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
RUN pacman -U /tmp/aur/ncurses5-compat-libs/ncurses5-compat-libs-* --noconfirm

# Paths to each individual build tree
ENV AUDITOR_TREE /opt/build/auditor/
ENV APPS_TREE /opt/build/apps/
ENV CAMERA_TREE /opt/build/camera/
ENV GMSCOMPATCONFIG_TREE /opt/build/gmscompatconfig/
ENV PDFVIEWER_TREE /opt/build/pdfviewer/
ENV TALKBACK_TREE /opt/build/talkback/
ENV VANADIUM_TREE /opt/build/vanadium/
# Path to each individual kernel tree
ENV KERNEL_CORAL_TREE /opt/build/coral-kernel/
ENV KERNEL_REDBULL_TREE /opt/build/redbull-kernel/
ENV KERNEL_RAVIOLE_TREE /opt/build/raviole-kernel/
ENV KERNEL_BLUEJAY_TREE /opt/build/bluejay-kernel/
ENV KERNEL_PANTAH_TREE /opt/build/pantah-kernel/
ENV KERNEL_LYNX_TREE /opt/build/lynx-kernel/
# Path to main GrapheneOS build tree
ENV GRAPHENEOS_TREE /opt/build/grapheneos/

# Customize build as needed
ENV DEVICES_TO_BUILD redfin,oriole,bluejay
ENV SKIP_AUDITOR true
ENV SKIP_APPS true
ENV SKIP_CAMERA true
ENV SKIP_GMSCOMPATCONFIG true
ENV SKIP_PDFVIEWER true
ENV SKIP_TALKBACK true
ENV SKIP_VANADIUM true
ENV SKIP_CORAL_KERNEL true
ENV SKIP_REDBULL_KERNEL true
ENV SKIP_RAVIOLE_KERNEL true
ENV SKIP_BLUEJAY_KERNEL true
ENV SKIP_PANTAH_KERNEL true
ENV SKIP_LYNX_KERNEL true
ENV SKIP_GRAPHENEOS false

RUN useradd -m builduser
RUN usermod -a -G wheel builduser
RUN echo "%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/nopass
RUN mkdir -p /opt/build/grapheneos/ && chown builduser:builduser /opt/build/grapheneos/
COPY .gitconfig /home/builduser/.gitconfig
COPY entrypoint.bash /usr/local/bin/build-entrypoint.bash
USER builduser
ENTRYPOINT /usr/local/bin/build-entrypoint.bash
