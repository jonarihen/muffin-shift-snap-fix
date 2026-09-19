# Muffin Shift snap fix

This repository keeps the local Cinnamon/Muffin change that prevents
Muffin from treating **Shift** as its own edge-snapping command while a
window is being moved.

It is paired with FancyTiles:

- hold **Shift** to show and use FancyTiles zones;
- hold **Shift + Ctrl** to merge zones;
- release Shift to stop snapping.

## What it fixes

Linux Mint's Muffin window manager uses Shift during a drag to enable
its independent edge resistance and edge-snap behaviour. That conflicted
with FancyTiles' Shift shortcut: windows could jump toward native Mint
targets while FancyTiles was also trying to place them.

`patches/0001-disable-muffin-shift-edge-snap.patch` changes the two move
paths in `src/core/window.c` so they no longer pass Shift to Muffin's
native move/snap handler. It covers both dragging and dropping a window.

## Upstream context

The root cause is tracked in
[Muffin issue #863](https://github.com/linuxmint/muffin/issues/863), which
requests a configurable setting for Shift-driven legacy snapping. This
repository is the documented workaround until Muffin provides that setting.

[FancyTiles issue #38](https://github.com/BasGeertsema/fancytiles/issues/38)
documents the same user-facing conflict. It is closed and recommends using
Ctrl; this repository keeps the option to use Shift without that conflict.

Native Cinnamon edge tiling is also disabled with:

```sh
gsettings set org.cinnamon.muffin edge-tiling false
```

That leaves FancyTiles as the only snapping system during a drag.

## Current installation

The fix was built against Muffin source tag `6.6.3`
(`25f17c16175cc10a25a4581cfa8609443a05bab0`) and installed as a locally
rebuilt `libmuffin0` package with the existing Mint version `6.6.3+zena`.
Cinnamon was restarted using its supported `org.Cinnamon.RestartCinnamon`
D-Bus method and was confirmed to map the rebuilt library.

See [docs/current-state.md](docs/current-state.md) for verification,
rollback, and future-update instructions.

## Proposed upstream fix

The `proposal/configurable-legacy-window-snap` branch contains
`patches/0002-add-configurable-legacy-window-snap.patch`, a build-verified
proposal for Muffin upstream. It adds an opt-in preference rather than
changing the default for everyone:

```sh
gsettings set org.cinnamon.muffin legacy-window-snap false
```

With the default `true`, existing Shift-based legacy snapping is unchanged.
The setting affects only moving windows; resizing behaviour and standard edge
tiling remain unchanged. It is a proposal for Muffin 6.6.3, not a change that
has been installed on this system. See
[docs/upstream-proposal.md](docs/upstream-proposal.md).

## Update protection

An APT hold on `libmuffin0` prevents normal Mint updates from silently
replacing this local fix. It is not enabled by default because it defers
Muffin security and bug-fix updates. To enable it deliberately:

```sh
pkexec apt-mark hold libmuffin0
```

Run the following from a normal terminal to confirm both the installed file
and the hold:

```sh
./scripts/check-fix.sh
```

When an update is available, rebuild this patch for its matching source first,
then deliberately remove and restore the hold as part of that update.

## Applying the patch to matching source

From a checkout of the matching Muffin source version:

```sh
git apply /path/to/0001-disable-muffin-shift-edge-snap.patch
```

Rebuild only after confirming that the patch applies cleanly and the
package version remains compatible with the installed Cinnamon packages.
