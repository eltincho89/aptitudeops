# AptitudeOPS

Distro basada en Debian con enfoque a devops. Es parte de una prueba de concepto.

Distro Linux basada en Debian trixie, pensada para programación y devops.
Se construye con `debootstrap` y se entrega como ISO Live con instalador Calamares (BIOS + EFI).

- Escritorio: GNOME (GDM, PipeWire, NetworkManager)
- Herramientas: git, zsh, python3, nodejs, docker, neovim, tmux, ripgrep, fd, bat, fzf
- ISO ~926 MB (squashfs comprimido)
- Secure Boot: no soportado todavía

## Estructura

- `scripts/` — scripts de cada fase (`phase*.sh`), se ejecutan dentro del chroot
- `build/enter-chroot.sh`, `build/exit-chroot.sh` — montan/desmontan el chroot
- `build/rebuild-iso.sh` — regenera squashfs e ISO versionada
- `build/tools/` — utilidades para probar la ISO en QEMU
- `PROGRESS.md` — bitácora detallada de la construcción

`build/chroot`, `build/iso` y las ISO no se versionan (varios GB).

## Construcción (resumen)

Las fases 2 requieren definir la contraseña inicial de `dev`/`root` por entorno
(no se versiona ninguna): `export DEV_PASSWORD='...'`.

```sh
sudo debootstrap --arch=amd64 --variant=minbase trixie build/chroot http://deb.debian.org/debian
build/enter-chroot.sh   # copiar scripts/ a /root del chroot y ejecutarlos en orden de fase
build/rebuild-iso.sh
```

Ver `PROGRESS.md` para el orden y las notas de cada fase.

## Licencia

[MIT](LICENSE)
