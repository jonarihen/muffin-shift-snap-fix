# Current state and maintenance

## Installed state

| Component | State |
| --- | --- |
| Desktop | Linux Mint Cinnamon 6.6.9 on X11 |
| Muffin source used | `6.6.3`, commit `25f17c16175cc10a25a4581cfa8609443a05bab0` |
| Installed local package | `libmuffin0 6.6.3+zena` |
| FancyTiles | enabled: `fancytiles@basgeertsema` |
| Cinnamon edge tiling | disabled |

The installed `/usr/lib/x86_64-linux-gnu/libmuffin.so.0.0.0` was checked
against the rebuilt package after Cinnamon restarted.

## What happens on updates

This is a local build with the same version as Mint's installed package.
When Mint publishes a newer `libmuffin0`, its package replaces this one.
FancyTiles settings persist, but the Muffin patch will need to be rebuilt
for the updated source and reinstalled.

Before an update, check the installed version:

```sh
dpkg-query -W -f='${Package} ${Version} ${Status}\\n' libmuffin0 muffin cinnamon
```

After an update, check whether Shift again triggers Mint's own snap while
dragging. If it does, obtain the matching Muffin source, apply the patch in
this repository, build the library package, install it, then restart
Cinnamon with:

```sh
gdbus call --session --dest org.Cinnamon --object-path /org/Cinnamon \\
  --method org.Cinnamon.RestartCinnamon false
```

## Rollback

The original Mint package saved during the initial installation is:

```text
/tmp/muffin-original/libmuffin0_6.6.3+zena_amd64.deb
```

To restore it:

```sh
pkexec dpkg -i /tmp/muffin-original/libmuffin0_6.6.3+zena_amd64.deb
gsettings set org.cinnamon.muffin edge-tiling true
gdbus call --session --dest org.Cinnamon --object-path /org/Cinnamon \\
  --method org.Cinnamon.RestartCinnamon false
```

`/tmp` can be cleared by the system, so download another original copy
before relying on rollback later:

```sh
mkdir -p ~/Downloads/muffin-rollback
cd ~/Downloads/muffin-rollback
apt-get download libmuffin0=6.6.3+zena
```

## Scope

The patch affects only Muffin's Shift-driven native edge snap during a
window move. It does not change window resizing, keyboard shortcuts,
FancyTiles' own zone logic, or other Cinnamon behaviour.
