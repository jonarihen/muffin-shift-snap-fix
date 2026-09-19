# Proposed configurable legacy snapping setting

This branch proposes an upstream Muffin setting that resolves the Shift
conflict without removing the existing feature for other users.

## Design

The patch adds the Boolean GSettings key:

```text
org.cinnamon.muffin legacy-window-snap
```

It defaults to `true`, preserving Muffin's current behavior. When a user
sets it to `false`, Muffin no longer interprets Shift as a request for legacy
snapping while a window is being moved:

```sh
gsettings set org.cinnamon.muffin legacy-window-snap false
```

The implementation is deliberately limited to the two move paths in
`src/core/window.c`: drag motion and the end of the drag. It does not alter
window resizing, normal edge tiling, or the default behavior.

## Source and validation

The patch is based on Muffin `6.6.3`, commit
`25f17c16175cc10a25a4581cfa8609443a05bab0`.

Validation completed:

- `git diff --check`
- full Meson build of all 720 targets with `meson compile -C build -j4`
- strict compilation of the generated GSettings schema
- key behavior through the keyfile GSettings backend: default `true`, accepts
  `false`, and resets to `true`

## Relationship to the installed workaround

`0001-disable-muffin-shift-edge-snap.patch` is the installed local workaround:
it unconditionally disables Shift-driven snapping. This proposal is preferable
for upstream because its default preserves current behavior and gives users a
supported opt-out.

It is not installed on this machine and does not replace the active workaround.
