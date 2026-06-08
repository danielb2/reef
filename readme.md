
<img width="1450" height="550" alt="reef-latest-3 (1)" src="https://github.com/user-attachments/assets/5359ab68-31c0-4bc9-b459-fb774bff0d34" />


```plaintext
                __
 _ __ ___  ___ / _|
| '__/ _ \/ _ \ |_
| | |  __/  __/  _|
|_|  \___|\___|_|  🪸🐟

Usage: reef <subcommand> [options]
Subcommands:
  add/install   add corals
  fish_reload   reload the fish shell
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
curl -sL https://tinyurl.com/fish-reef | source && reef init
```

# reef

To stick with a fish theme, I've chosen to go with the name reef, and to keep
the metaphor going, plugins are called corals.

I made this because while I like the simplicity of fisher, I don't like how
everything is clobbered in the main fish folder. With this design, each plugin
has it's own folder while still keeping things very simple.

## compatibility

Fisher, omf plugins, and anything following the standard `functions/`,
`conf.d/` etc directory structure are compatible. reef will not honor any
`init.fish` file however, although functionality can be copied into a file in
functions.

### Fisher migration

Reef mirrors Fisher's behavior to make switching easy:
- It uses the standard `fish_plugins` file in your fish config directory.
- `reef update` (with no arguments) will install missing corals, remove extras, and update existing ones—exactly like `fisher update`.
- If you are already using Fisher, just install Reef and run `reef update` to migrate your plugins into the Reef structure.

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
