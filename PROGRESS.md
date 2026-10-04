# AptitudeOPS — Progreso de construcción

Última actualización: 2026-10-04 (Fase 13: EFI probado, ISO versionada 1.0; probada en VirtualBox; solo queda hardware real)

## Objetivo
Nombre de la distro: **AptitudeOPS** (renombrada el 2026-09-30; branding aplicado en
`/etc/os-release` con `ID=aptitudeops`/`ID_LIKE=debian`, `/etc/issue` y `/etc/motd` del chroot.
El directorio del proyecto sigue llamándose `linux-propio`; hostname sigue `devbox`).

Distro Linux personalizada Nivel 2, base Debian (debootstrap), Wayland+Sway (o Xorg+i3),
probada en VM (VirtualBox/KVM), orientada a programación/devops (terminal moderna, Git,
Docker, Python/Node, Zsh). Entrega final: ISO Live arrancable, optimizada en peso.

## Decisiones ya tomadas (no volver a preguntar)
- Base: Debian **trixie** (stable), `debootstrap --variant=minbase`, arch amd64
- Locale: `en_US.UTF-8`
- Timezone: `America/Argentina/Buenos_Aires`
- Hostname: `devbox`
- Usuario: `dev` (grupo `sudo`) + `root` — ambos con una contraseña temporal (no se versiona)
  -> **cambiada en Fase 8** por una contraseña aleatoria de 16 caracteres (no está
  guardada en este repo). Para cambiarla: `chpasswd` en el chroot + `rebuild-iso.sh`
- Red: **NetworkManager** + `systemd-resolved` (cambiado el 2026-09-30 a pedido del usuario
  para que GNOME gestione red/wifi). `systemd-networkd` deshabilitado; su config quedó en
  `/etc/systemd/network-disabled/`
- Init: `systemd-sysv`

## Rutas del proyecto
- Directorio de trabajo: `/home/martin/test/linux-propio`
- Build dir: `/home/martin/test/linux-propio/build`
- Chroot: `/home/martin/test/linux-propio/build/chroot`
- Scripts de conveniencia:
  - `build/enter-chroot.sh` — monta pseudo-fs y entra al chroot (requiere sudo)
  - `build/exit-chroot.sh` — desmonta pseudo-fs del chroot (requiere sudo)
  - `build/chroot/root/phase2-setup.sh` — script fase 2 (se detuvo antes de tiempo, ver nota)
  - `build/chroot/root/phase2-finish.sh` — completó lo que faltó de fase 2

## Estado del chroot ahora mismo
- Pseudo-filesystems **desmontados** (al cierre de la Fase 13) — usar `enter-chroot.sh` antes de operar
  dentro del chroot.
- Tamaño actual: ~2.9G tras Fase 7 (antes 3.7G)
- Kernel instalado: `6.12.107+deb13-amd64` (con initrd generado)

## Fases completadas

### Fase 1 — Base y bootstrap ✅
- `debootstrap --arch=amd64 --variant=minbase trixie` ejecutado con éxito
- Pseudo-filesystems montados, `resolv.conf` copiado
- `sources.list` configurado (main/contrib/non-free-firmware + security)
- Verificado `apt update` funcionando dentro del chroot

### Fase 2 — Configuración base del sistema ✅
- Locale, timezone, hostname/hosts configurados
- Paquetes esenciales instalados: `systemd-sysv`, `udev`, `kmod`, `sudo`, `less`, `nano`,
  `curl`, `wget`, `ca-certificates`, `gnupg2`, `console-setup`, `keyboard-configuration`
- Kernel `linux-image-amd64` instalado + initrd generado
- Red configurada: `systemd-networkd` (DHCP) + `systemd-resolved`, ambos `enabled`
- Usuario `dev` (sudo) y `root` creados con una contraseña temporal (no se versiona)

**Nota técnica importante:** en Debian trixie, `systemd-resolved` es un paquete
**separado** (no viene con el systemd base). El primer intento (`phase2-setup.sh`)
falló en `systemctl enable systemd-resolved` por este motivo y se cortó ahí
(tenía `set -e`). Se resolvió instalando el paquete aparte y completando el resto
de la fase con `phase2-finish.sh`. Tenerlo en cuenta para futuras fases si se
usan otros servicios systemd que se asuman "incluidos".

### Fase 3A — Herramientas de programación/devops ✅
Script: `build/chroot/root/phase3a-devtools.sh` (con `--no-install-recommends`).
- git 2.47, zsh 5.9 (shell por defecto de `dev`), python3 3.13 + pip + venv + pipx,
  nodejs 20.19 + npm 9.2, docker.io 26.1 (+ docker-cli, containerd; servicio `enabled`),
  build-essential, make, jq, ripgrep, fd-find, bat, fzf, tmux, htop, neovim, openssh-client, unzip
- `dev` agregado al grupo `docker`
- Caches de apt limpiadas al final
- Nota: Docker viene del repo de Debian (`docker.io`), no de docker.com. Pendiente (opcional):
  configuración de Zsh (`.zshrc`, prompt, plugins) y aliases para bat/fd (`batcat`/`fdfind`).

### Fase 3B — Entorno gráfico GNOME ✅ (decisión del usuario: GNOME)
Script: `build/chroot/root/phase3b-gnome.sh` (con `--no-install-recommends`).
- `gnome-core`, `gdm3` (enabled, `graphical.target` por defecto), gnome-terminal,
  PipeWire (+pulse, wireplumber), fuentes Noto/DejaVu, firefox-esr
- Red: ver Fase 4 (se cambió a NetworkManager).
- Sin probar arrancar todavía (se probará con la ISO en VM).

### Fase 4 — NetworkManager ✅
`phase4-nm.sh`: `network-manager` + `network-manager-gnome`, NM enabled, networkd disabled.

### Fase 5 — ISO Live ✅ (generada y probada en QEMU/KVM, BIOS)
- `phase5-live.sh`: `live-boot`, `live-config`, `live-config-systemd` + initramfs regenerado
- `build/iso/`: `live/vmlinuz`, `live/initrd.img`, `live/filesystem.squashfs`
  (zstd nivel 15, 1.2G), `boot/grub/grub.cfg` (entrada normal + safe mode; usuario `dev`)
- ISO: `build/AptitudeOPS.iso` (893M tras Fase 7, BIOS+EFI vía `grub-mkrescue`, volid APTITUDEOPS)
- Host: se instaló `mtools` (lo requiere grub-mkrescue para EFI). Host ahora tiene qemu-system-x86 + ovmf.
- Regenerar: `sudo mksquashfs chroot iso/live/filesystem.squashfs -comp zstd -Xcompression-level 15
  -b 1M -noappend -wildcards -e 'proc/*' 'sys/*' 'dev/*' 'run/*' 'tmp/*'` y luego
  `sudo grub-mkrescue -o AptitudeOPS.iso iso -volid APTITUDEOPS` (copiar antes kernel/initrd nuevos a iso/live/)
- Prueba 2026-09-30 (qemu-system-x86 instalado en el host, 4G RAM, KVM): arranca y entra
  directo al escritorio GNOME (autologin), icono de red NM presente. Wallpaper/tema aún Debian.

### Fase 6 — Verificación en VM live (QEMU, consola serie) ✅
- `dev`: uid 1000, grupos sudo+docker, shell zsh, hostname `devbox`, os-release AptitudeOPS OK
- NetworkManager `connected` (DHCP), docker `active`, sin units fallidas reportadas
- Docker pull no se pudo probar: el host tampoco resuelve `auth.docker.io` (problema de red/DNS
  del host, no de la distro). `deb.debian.org` sí resuelve/descarga desde la VM.
- Corregido: primer login de zsh abría el asistente -> agregado `/etc/skel/.zshrc` (+ `/home/dev/.zshrc`)
  con prompt, historial, aliases (`bat`=batcat, `fd`=fdfind, fzf). Faltaban `ip`/`ping` -> `phase6-fixes.sh`
  instala `iproute2` + `iputils-ping`.

### Fase 7 — Optimización ✅ (parcial)
`phase7-optimize.sh`: purga de `yelp` + `gnome-user-docs` (+ metapaquete `gnome-core`; se reinstalaron
gnome-shell, gdm3, nautilus, control-center, terminal, text-editor, etc. explícitos), autoremove,
eliminados docs/man/info/help y locales salvo `en*`, y `dpkg path-exclude` para que no vuelvan.
Chroot 3.7G -> 2.9G. ISO 1.3G -> **893M** (squashfs xz 830M, build ~15 min) (`build/rebuild-iso.sh` regenera todo).
Pendiente de optimizar: firefox-esr (300M), kernel/modules, libllvm (mesa), servicios en background.

### Fase 8 — Afinado y branding ✅ (probado en QEMU, EFI+serie)
`phase8-tune.sh`:
- Branding GNOME: wallpaper propio (`/usr/share/backgrounds/aptitudeops/aptitudeops.png`), tema oscuro y
  favoritos del dock vía dconf (`/etc/dconf/db/local.d/00-aptitudeops` + profile `user`)
- Servicios: deshabilitados bluetooth, NetworkManager-wait-online, apt-daily(+upgrade), dpkg-db-backup,
  fstrim, systemd-pstore; docker/containerd ya no arrancan al boot (docker.socket los activa bajo demanda);
  enmascarados ModemManager/cups/avahi. Resultado en live: 15 servicios corriendo, 0 fallidos,
  ~1.07G RAM usada con GNOME en idle (VM de 4G).
- Contraseña de dev/root cambiada (ver arriba). Login verificado en la VM.
- Firefox-esr (294M, casi todo libxul) se mantiene: es el navegador de la distro. No se reduce más
  sin quitarlo. Módulos del kernel (107M) tampoco se tocaron (riesgo de hardware no soportado).
- ISO final: 893M.

### Fase 9 — Plymouth, instalador Calamares, sin gcc ✅ (con pruebas pendientes)
- `phase9-installer.sh`: calamares + calamares-settings-debian, plymouth(+themes), grub-efi-amd64-bin,
  grub-pc-bin, efibootmgr, parted, dosfstools, rsync, squashfs-tools, os-prober, cryptsetup.
  Purgados build-essential/gcc/g++ (make se conserva; gcc se reinstala con apt cuando haga falta).
- Plymouth: theme propio `aptitudeops` (copia de spinner, `/usr/share/plymouth/themes/aptitudeops`).
  OJO: el hook de initramfs de Debian pisa watermark.png con
  `/usr/share/desktop-base/debian-logos/logo-text-version-64.png` -> se reemplazó ESE archivo por
  nuestro logo (hecho; verificado en VM: splash muestra "AptitudeOPS").
- Calamares: branding AptitudeOPS (`/etc/calamares/branding/debian/`, dir sigue llamándose `debian`),
  icono `/usr/share/pixmaps/install-debian.png`, desktop "Install AptitudeOPS" en el dock,
  `users.conf`: grupo docker, shell zsh, `allowWeakPasswords: true` (default false),
  `shellprocess_cleanup.conf` (borra usuario `dev` y bloquea root en el sistema instalado),
  instancia `shellprocess@cleanup` declarada en `settings.conf` tras `users`.

### Fase 10 — Fixes de pruebas (diccionario y GRUB) ✅
- `phase10-fixes.sh`: `wamerican` + `cracklib-runtime` (sin diccionario, Calamares bloqueaba el Next).
- `phase11-grub.sh`: `grub2-common` (trae grub-install/update-grub; faltaban) + `/etc/default/grub` propio
  (GRUB_DISTRIBUTOR=AptitudeOPS) creado a mano (antes no existía).
- `usr/share/calamares/helpers/calamares-bootloader-config` parcheado: se quitaron los `apt-get install
  grub-pc/grub-efi` (sin red/listas en ese paso; grub-pc y grub-efi-amd64 son excluyentes) y se agregó
  `mkdir -p $CHROOT/boot/grub` antes de `update-grub`.
- `modules/packages.conf`: `remove` -> `try_remove` (apt fallaba con exit 100 al purgar paquetes
  live-* no instalados).

### Fase 12 — Pruebas del sistema instalado (2026-10-01) 
- Reinstalación completa sin parches manuales: OK en QEMU BIOS (ISO con fixes try_remove/mkdir boot/grub,
  timezone por defecto America/Argentina/Buenos_Aires via `modules/locale.conf`, GNOME Software sin
  avisos de updates via dconf).
- **Arranque del disco instalado:** GRUB OK, tty login OK (banner AptitudeOPS), usuario `tester` con
  sudo+docker, `dev` eliminado, root bloqueado, live-boot/calamares-settings-debian desinstalados,
  timezone Buenos Aires OK, `/boot/grub/grub.cfg` generado.
- **BUG encontrado: pantalla negra tras GDM en el sistema instalado.** Causa raiz: el directorio
  `build/chroot` era propiedad de `martin` (uid 1001), asi que `/` del squashfs -> `/` del sistema
  instalado quedaba con dueño uid 1001 (= el primer usuario creado, `tester`). systemd-tmpfiles aborta
  con "unsafe path transition" (status 73), no crea `/tmp/.X11-unix` con 1777 root, gdm lo crea como
  Debian-gdm y gnome-shell del usuario falla ("Failed to start X Wayland: /tmp/.X11-unix is not
  writable"). **Fix:** `chown root:root build/chroot && chmod 755` (hecho) y `rebuild-iso.sh` lo
  fuerza siempre. (La ISO live no se veia afectada.)
- **BUG: `userShell: /usr/bin/zsh` de users.conf no se aplica** (tester quedo con /bin/bash). Fix:
  `/usr/local/sbin/aptitudeops-postinstall.sh` (userdel dev, passwd -l root, chsh zsh a usuarios
  uid>=1000) llamado desde `shellprocess_cleanup.conf`. Sin verificar todavia.
- Hostname sugerido por el instalador sale de DMI de la VM (QEMU: "tester-ubuntu2404pcv2"); es de la
  maquina de prueba, no de la distro.

### Fase 12b — Verificación final del sistema instalado ✅ (2026-10-01, QEMU BIOS)
ISO 955M reconstruida con todos los fixes (`rebuild-iso.sh` fuerza `chown root:root chroot`).
Instalación sin parches manuales -> arranque del disco instalado:
- GRUB -> splash AptitudeOPS -> **GDM con logo AptitudeOPS** -> sesión GNOME OK (wallpaper, dock propios,
  el icono del instalador desaparece porque calamares se desinstala)
- `/` es root:root 755; usuario `tester` (uid 1001) con shell **zsh**, grupos sudo+docker; `dev` no existe;
  root bloqueado; timezone America/Argentina/Buenos_Aires; sin live-boot/calamares-settings-debian
- `docker ps` funciona sin sudo (docker.socket activa el daemon bajo demanda); git 2.47, python 3.13,
  node 20.19, make presentes; gcc ausente (a proposito)
- Recursos del instalado: ~780 MB RAM en uso con GNOME en reposo (VM 4G), 3.1G de disco usado
- Sobra (menor): `/etc/calamares/modules` queda en el sistema instalado (restos de nuestra config).

### Fase 13 — Cierre de pendientes (2026-10-01) ✅
- **Instalación EFI probada** (QEMU + OVMF, disco virtio 12G): Calamares detecta EFI, crea GPT con ESP FAT32
  300M en `/boot/efi` + ext4; instala sin errores; arranca desde el disco (la ISO seguía conectada como CD, pero BootCurrent fue la entrada del disco): entrada NVRAM `AptitudeOPS`
  (`\EFI\AptitudeOPS\grubx64.efi`, BootCurrent), GDM con logo, login OK. Secure Boot sigue NO soportado.
  Receta de la VM: `-machine q35`, `-drive if=pflash,...OVMF_CODE_4M.fd` (readonly) + copia de `OVMF_VARS_4M.fd`.
- **Hostname por defecto fijo `devbox`**: `users.conf` -> `hostname: template: "devbox"` (el campo queda
  vacío hasta que se escribe el nombre; luego se rellena con `devbox`, editable). Verificado en el instalado.
- **Requisito de disco bajado de 15 a 8 GiB** (`welcome.conf` `requiredStorage: 8`); instalado ocupa 2.9G.
- **`docker run hello-world` OK** en el sistema instalado (el host ya resuelve auth.docker.io).
- **Limpieza de `/etc/calamares`** en el sistema instalado vía `aptitudeops-postinstall.sh` (verificado).
- **Peso:** purgados `gstreamer1.0-plugins-bad` y `ghostscript` (+ autoremove: onnxruntime, x265, etc.).
  ISO 955M -> **926M**. gcc/cpp NO se pueden purgar: `gdm3` -> `x11-xserver-utils` -> `cpp` (en la
  práctica gcc-14 sigue instalado; la nota de Fase 9 "sin gcc" es inexacta). Orca/speech-dispatcher se
  dejaron por accesibilidad. Firefox (294M) sigue siendo lo más grande.
- **Versionado:** `os-release` tiene `IMAGE_VERSION=1.0` y `BUILD_ID=20261001`; `rebuild-iso.sh` genera
  `AptitudeOPS-<versión>-<build>.iso` + `.sha256`.
  `build/AptitudeOPS-1.0-20261001.iso` sha256 `59af71e278ad3b6b649967819a1b330fbb12daf85dd25f32767d986e4bc7feac`
- `build/test-disk-installed.img` ya no existía (nada que borrar).

## ESTADO Y PENDIENTE
Las VMs de prueba usan un usuario `tester` con credenciales descartables (no versionadas).
Herramientas QEMU en `build/tools/` (keys/qclick/shot/type; los sockets AF_UNIX tienen límite de ~107
caracteres de ruta: usar un symlink corto tipo `/tmp/q` y copiar los .py ahí).
1. ✅ **VirtualBox:** probado por el usuario el 2026-10-04, funciona bien.
   **Pendiente: probar en hardware real.** No se incluyó firmware no-libre extra (wifi/GPU) — evaluar
   `firmware-linux-nonfree` según el hardware.
2. Opcional: más peso (quitar paquetes GNOME no usados, `-Xdict-size`), Secure Boot (shim-signed).
