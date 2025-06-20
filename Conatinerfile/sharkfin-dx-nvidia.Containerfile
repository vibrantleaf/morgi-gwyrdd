# This stage is responsible for holding onto
# your config without copying it directly into
# the final image
FROM scratch AS stage-files
COPY ./files /files


# Copy modules
# The default modules are inside blue-build/modules
# Custom modules overwrite defaults
FROM scratch AS stage-modules
COPY ./modules /modules

# Bins to install
# These are basic tools that are added to all images.
# Generally used for the build process. We use a multi
# stage process so that adding the bins into the image
# can be added to the ostree commits.
FROM scratch AS stage-bins
COPY --from=ghcr.io/sigstore/cosign/cosign:v2.5.0 /ko-app/cosign /bins/cosign
COPY --from=ghcr.io/blue-build/cli:latest-installer \
  /out/bluebuild /bins/bluebuild
# Keys for pre-verified images
# Used to copy the keys into the final image
# and perform an ostree commit.
#
# Currently only holds the current image's
# public key.
FROM scratch AS stage-keys
COPY cosign.pub /keys/sharkfin-dx-nvidia.pub


# Main image
FROM ghcr.io/ublue-os/bluefin-dx-nvidia@sha256:eac67fb43da17275263d0374787b9154f96e5211e31d3dda9cf9ed86ff0527ea AS sharkfin-dx-nvidia
ARG RECIPE=recipes/sharkfin-dx-nvidia.recipe.yaml
ARG IMAGE_REGISTRY=localhost
ARG CONFIG_DIRECTORY="/tmp/files"
ARG MODULE_DIRECTORY="/tmp/modules"
ARG IMAGE_NAME="sharkfin-dx-nvidia"
ARG BASE_IMAGE="ghcr.io/ublue-os/bluefin-dx-nvidia"
ARG FORCE_COLOR=1
ARG CLICOLOR_FORCE=1
ARG RUST_LOG_STYLE=always
# Key RUN
RUN --mount=type=bind,from=stage-keys,src=/keys,dst=/tmp/keys \
  mkdir -p /etc/pki/containers/ \
  && cp /tmp/keys/* /etc/pki/containers/

# Bin RUN
RUN --mount=type=bind,from=stage-bins,src=/bins,dst=/tmp/bins \
  mkdir -p /usr/bin/ \
  && cp /tmp/bins/* /usr/bin/
RUN --mount=type=bind,from=ghcr.io/blue-build/nushell-image:default,src=/nu,dst=/tmp/nu \
  mkdir -p /usr/libexec/bluebuild/nu \
  && cp -r /tmp/nu/* /usr/libexec/bluebuild/nu/
RUN --mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/scripts/ \
  /scripts/pre_build.sh

# Module RUNs
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/files:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'files' '{"type":"files","files":[{"source":"system/shared","destination":"/"}]}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/justfiles:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'justfiles' '{"type":"justfiles","validate":true,"include":["80-sharkfin-generic-hostname.just","81-sharkfin-waydroid-utils.just","82-sharkfin-extract-fonts-from-windows-iso.just"]}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/default-flatpaks:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'default-flatpaks' '{"type":"default-flatpaks","notify":true,"user":{},"system":{"install":["app.zen_browser.zen","org.libreoffice.LibreOffice","org.localsend.localsend_app","dev.geopjr.Collision","org.gnome.World.Secrets","com.belmoussaoui.Authenticator","com.github.tchx84.Flatseal","io.gitlab.adhami3310.Impression","ca.edestcroix.Recordbox","page.tesk.Refine","com.github.marhkb.Pods","io.github.dvlv.boxbuddyrs","net.nokyan.Resources"],"remove":["io.missioncenter.MissionCenter"]}}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/bling:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'bling' '{"type":"bling","install":["rpmfusion","dconf-update-service"]}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/dnf:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'dnf' '{"type":"dnf","repos":{"files":{"remove":["updates-archive"]}},"remove":{"packages":["fuse"]},"install":{"install-weak-deps":false,"packages":["virt-install","libvirt-daemon-config-network","libvirt-daemon-kvm","edk2-ovmf","virt-manager","virt-viewer","libguestfs-tools","python3-libguestfs","virt-top","swtpm","bridge-utils","gnome-boxes","cmake","gcc","gcc-c++","libglvnd-devel","fontconfig-devel","spice-protocol","make","nettle-devel","pkgconf-pkg-config","binutils-devel","libXi-devel","libXinerama-devel","libXcursor-devel","libXpresent-devel","libxkbcommon-x11-devel","wayland-devel","wayland-protocols-devel","libXScrnSaver-devel","libXrandr-devel","dejavu-sans-mono-fonts","libdecor-devel","pulseaudio-libs-devel","libsamplerate-devel","go","gnome-shell-extension-dash-to-dock","gstreamer1-plugin-libav","gstreamer1-plugins-bad-free-extras","gstreamer1-vaapi","libaacs","libbdplus","libbluray","libdvdcss","steam","steam-devices","gamemode","mangohud","gamescope","vkbasalt","crun","podman","podman-compose","skopeo","cosign","waydroid","fuse3"]}}'
COPY --from=ghcr.io/blue-build/cli:latest /usr/bin/bluebuild /usr/bin/bluebuild

RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/gnome-extensions:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'gnome-extensions' '{"type":"gnome-extensions","install":[4655,6784,4691,5940,4269,3733]}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/gschema-overrides:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'gschema-overrides' '{"type":"gschema-overrides","include":["org.gnome.desktop.gschema.override","org.gnome.mutter.gschema.override","org.gnome.nautilus.gschema.override","org.gnome.Ptyxis.gschema.override","org.gnome.shell.extensions.blur-my-shell.gschema.override","org.gnome.shell.extensions.dash-to-dock.gschema.override","org.gnome.shell.extensions.tiling-assistant.gschema.override","org.gnome.shell.extensions.wiggle.gschema.override"]}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/script:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'script' '{"type":"script","scripts":["41-get-looking-glass.sh","42-get-vibrant-updater.sh","40-branding.sh","45-get-bazzite-repos.sh","44-get-bazzite-kernel.sh","43-get-bazzite-firmware.sh","47-get-udev-rules.sh","49-extras.sh"]}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/chezmoi:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'chezmoi' '{"type":"chezmoi","repository":"https://codeberg.org/vibrantleaf/dots.git","file-conflict-policy":"replace","branch":"main","run-every":"1d","wait-after-boot":"5m","disable-update":false,"disable-init":false,"all-users":false}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/yafti:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'yafti' '{"type":"yafti","custom-flatpaks":[{"Alpaca":"com.jeffser.Alpaca"},{"Bottles":"com.usebottles.bottles"},{"Lutris":"net.lutris.Lutris"},{"ProtonPlus":"com.vysp3r.ProtonPlus"}]}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/kargs:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'kargs' '{"type":"kargs","arch":"x86_64","kargs":["vm.max_map_count=1677721","vm.swappiness=180","vm.watermark_boost_factor=0","vm.watermark_scale_factor=125","vm.page-cluster=0"]}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/initramfs:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'initramfs' '{"type":"initramfs"}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/dnf:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'dnf' '{"type":"dnf","remove":{"packages":["cmake","gcc-c++","libglvnd-devel","cmake-data","spice-protocol","nettle-devel","binutils-devel","libXi-devel","libXinerama-devel","libXcursor-devel","libXpresent-devel","libxkbcommon-x11-devel","wayland-devel","wayland-protocols-devel","libXScrnSaver-devel","libXrandr-devel","libdecor-devel","pulseaudio-libs-devel","libsamplerate-devel","lutris","winetricks","gnome-shell-extension-hotedge","gnome-shell-extension-logo-menu","gnome-shell-extension-just-perfection","gnome-shell-extension-compiz-alike-magic-lamp-effect","gnome-shell-extension-compiz-windows-effect","gnome-shell-extension-desktop-cube","gnome-shell-extension-window-list","gnome-shell-extension-restart-to","gnome-shell-extension-burn-my-windows","gnome-shell-extension-places-menu","gnome-shell-extension-launch-new-instance","rom-properties","rom-properties-utils","rom-properties-gtk3","rom-properties-common","rom-properties-thumbnailer-dbus","discover-overlay","gnome-tweaks","webapp-manager"]}}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/script:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'script' '{"type":"script","scripts":["50-cleanup.sh"]}'
RUN \
--mount=type=bind,from=stage-files,src=/files,dst=/tmp/files,rw \
--mount=type=bind,from=ghcr.io/blue-build/modules/signing:latest,src=/modules,dst=/tmp/modules,rw \
--mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/tmp/scripts/ \
  --mount=type=cache,dst=/var/cache/rpm-ostree,id=rpm-ostree-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  --mount=type=cache,dst=/var/cache/libdnf5,id=dnf-cache-sharkfin-dx-nvidia-stable,sharing=locked \
  /tmp/scripts/run_module.sh 'signing' '{"type":"signing"}'

RUN --mount=type=bind,from=ghcr.io/blue-build/cli/build-scripts:7828e7872b342d05302417db1bd94bf93d347383,src=/scripts/,dst=/scripts/ \
  /scripts/post_build.sh

# Labels are added last since they cause cache misses with buildah
LABEL org.blue-build.build-id="db6df467-0fee-462a-b6a6-76895d2b7452"
LABEL org.opencontainers.image.title="sharkfin-dx-nvidia"
LABEL org.opencontainers.image.description="This is just my persoanl fork of bluefin."
LABEL org.opencontainers.image.source=""
LABEL org.opencontainers.image.base.digest="sha256:eac67fb43da17275263d0374787b9154f96e5211e31d3dda9cf9ed86ff0527ea"
LABEL org.opencontainers.image.base.name="ghcr.io/ublue-os/bluefin-dx-nvidia:stable"
LABEL org.opencontainers.image.created="2025-06-19T02:49:17.773679105+00:00"
LABEL io.artifacthub.package.readme-url=https://raw.githubusercontent.com/blue-build/cli/main/README.md