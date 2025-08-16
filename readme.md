```plaintext
                __
 _ __ ___  ___ / _|
| '__/ _ \/ _ \ |_
| | |  __/  __/  _|
|_|  \___|\___|_|  🪸🐟

Usage: reef <subcommand> [options]
Subcommands:
  add/install   add corals
  help          this beautiful help
  ls/list       list installed corals
  reload        reload reefs files (you probably dont need this)
  rm/remove     remove corals
  splash        show the reef splash
  theme         list or set new theme
  up/update     update coral(s)
  version       display reef version
```

# Install
```console
curl -sL https://tinyurl.com/fish-reef | source && reef add danielb2/reef && reef init
```

# reef

To stick with a fish theme, I've chosen to go with the name reef, and to keep
the metaphor going, plugins are called corals.

I made this because while I like the simplicity of fisher, I don't like how
everything is clobbered in the main fish folder. With this design, each plugin
has it's own folder while still keeping things very simple.

## compatability

Fisher, omf plugins, and anything following the standard `functions/`,
`conf.d/` etc directory structre are compatible. reef will not honor any
`init.fish` file however, although functionality can be copied into a file in
functions.

### events

just like fisher, events are emitted when plugins are installed, updated (attempted), or removed

for example: for danielb2/reef, the following events will be emitted:

- install: reef_install
- update: reef_update
- uninstall: reef_uninstall

example:
```fish
function reef_install --on-event reef_install
  # handle setup
end
```

## themes

example:

```
reef add git@github.com:oh-my-fish/theme-bobthefish.git
reef theme # to see list of themes
reef theme bob<tab>  # tab complete to fill it in
reef theme oh-my-fish/theme-bobthefish. # set new theme while backing up existing files
```

# notes
- no dependency tree

