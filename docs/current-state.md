# Current state and maintenance

## Installed state

| Component | State |
| --- | --- |
| Desktop | Linux Mint Cinnamon 6.6.9 on X11 |
| Muffin source used | `6.6.3`, commit `25f17c16175cc10a25a4581cfa8609443a05bab0` |
| Installed local package | `libmuffin0 6.6.3+zena` |
| FancyTiles | enabled: `fancytiles@basgeertsema` |
| Cinnamon edge tiling | enabled for drags without Shift |

The installed `/usr/lib/x86_64-linux-gnu/libmuffin.so.0.0.0` was checked
against the rebuilt package after Cinnamon restarted.

## What happens on updates

This is a local build with the same version as Mint's installed package.
`libmuffin0` is held with APT, so a normal Mint update cannot replace this
library and silently remove the patch. FancyTiles settings persist.

An APT hold is the reliable way to prevent that automatic replacement, but it
also defers Muffin security and bug-fix updates. When Mint publishes a new
Muffin version, rebuild this patch for its matching source before deliberately
accepting that update. Enable the hold only after accepting that tradeoff:

```sh
pkexec apt-mark hold libmuffin0
```

Confirm the protection and the current library checksum at any time:

```sh
./scripts/check-fix.sh
```

Before an update, check the installed version:

```sh
dpkg-query -W -f='${Package} ${Version} ${Status}\\n' libmuffin0 muffin cinnamon
```

To update Muffin deliberately, first remove the hold:

```sh
pkexec apt-mark unhold libmuffin0
```

Obtain the matching Muffin source, apply the patch in this repository, build
and install the replacement `libmuffin0`, then restore the hold:

```sh
pkexec apt-mark hold libmuffin0
```

Finally restart Cinnamon with:

```sh
gdbus call --session --dest org.Cinnamon --object-path /org/Cinnamon \\
  --method org.Cinnamon.RestartCinnamon false
```

## Rollback

The previous local package is saved as:

```text
artifacts/libmuffin0_6.6.3+zena_previous-local_amd64.deb
```

To restore the previous FancyTiles-only drag behavior:

```sh
pkexec dpkg --force-hold -i artifacts/libmuffin0_6.6.3+zena_previous-local_amd64.deb
pkexec apt-mark hold libmuffin0
gsettings set org.cinnamon.muffin edge-tiling false
gdbus call --session --dest org.Cinnamon --object-path /org/Cinnamon \\
  --method org.Cinnamon.RestartCinnamon false
```

Run these commands from this repository. The package in `artifacts/` is ignored
by Git, so preserve it separately before deleting this worktree. To restore
stock Mint Muffin, download its package separately:

```sh
mkdir -p ~/Downloads/muffin-rollback
cd ~/Downloads/muffin-rollback
apt-get download libmuffin0=6.6.3+zena
```

## Scope

The patch affects Muffin's Shift-driven native edge snap and tile preview
during a window move. It preserves ordinary drag-to-edge tiling without Shift.
It does not change window resizing, keyboard shortcuts, FancyTiles' own zone
logic, or other Cinnamon behaviour.
