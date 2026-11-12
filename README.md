# alejlatorre/homebrew-tap

Fórmulas propias para las Macs.

## btop

btop con los fixes de memoria de macOS que [upstream](https://github.com/aristocratos/btop)
todavía no mergeó. Sale de la rama `mac` de [alejlatorre/btop](https://github.com/alejlatorre/btop/tree/mac).

Hoy la rama es v1.4.8 más [#1801](https://github.com/aristocratos/btop/pull/1801): la
memoria comprimida cuenta como usada y se muestra en su propia fila. En btop 1.4.8 el
"used" de macOS es `active + wired`, sin la memoria comprimida (issue
[#291](https://github.com/aristocratos/btop/issues/291), abierto desde 2022). En una Mac con
el swap lleno eso da la mitad de lo que marca Monitor de Actividad.

```sh
brew uninstall btop                 # el de homebrew-core usa la misma carpeta del Cellar
brew install alejlatorre/tap/btop   # compila: no hay bottle
```

Con poca RAM libre, `HOMEBREW_MAKE_JOBS=4` baja los procesos de la compilación.

### Subir de versión

```sh
cd btop && git fetch upstream --tags
git rebase --onto vX.Y.Z vANTERIOR mac        # los commits del fix arriba de la versión nueva
git tag -a vX.Y.Z-mac.1 -m "…" mac && git push -f origin mac vX.Y.Z-mac.1
```

Después, `url` y `sha256` en `Formula/btop.rb`, y `brew upgrade alejlatorre/tap/btop` en cada Mac.

### Cuándo se borra

Cuando upstream mergee #1801 (o un fix equivalente): `brew uninstall btop && brew install btop`
en cada Mac, y se borra la fórmula.
