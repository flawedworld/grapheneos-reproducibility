FROM archlinux:latest

# Obtain all needed packages from Arch Linux repos
RUN pacman -Syyuu --noconfirm repo python git gnupg diffutils freetype2 \
fontconfig ttf-dejavu openssl rsync unzip zip python-protobuf nodejs-lts-hydrogen \
yarn gperf lib32-glibc lib32-gcc-libs signify openssh base-devel make cpio

# Obtain all needed packages from AUR
USER nobody
RUN curl --create-dirs -o /tmp/aur/ncurses5-compat-libs/PKGBUILD https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=ncurses5-compat-libs && \
echo "033d2b4847a426c3acce3c037708be4cb26890b65f20f2fadc20b2c2d5b7bcfb8e0faf12d2f72350a42c3a3d65a976b0e3016178fc0f19c2427f4a5fae6525d9 /tmp/aur/ncurses5-compat-libs/PKGBUILD" | sha512sum -c || exit 1 && \
cd /tmp/aur/ncurses5-compat-libs/ && makepkg --skippgpcheck
USER root
RUN pacman -U /tmp/aur/ncurses5-compat-libs/ncurses5-compat-libs-* --noconfirm
