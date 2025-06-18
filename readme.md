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
  prompt        use the reef supplied prompt
  reload        reload reefs files (you probably dont need this)
  rm/remove     remove corals
  splash        show the reef splash
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

# notes
- no dependency tree

