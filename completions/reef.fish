function __fish_lb_tags
    lb ls
end

complete -c lb -e
complete -c lb -f
complete -c lb -n "__fish_use_subcommand" -a "add" -d "Add an entry"
complete -c lb -n "__fish_use_subcommand" -a "ls" -d "List tags or entries"
complete -c lb -n "__fish_use_subcommand" -a "log" -d "List entries chronologically"
complete -c lb -n "__fish_use_subcommand" -a "search" -d "Search entries"
complete -c lb -n "__fish_use_subcommand" -a "rm" -d "Remove an entry or tag"
complete -c lb -n "__fish_use_subcommand" -a "edit" -d "Edit an entry or tag's entries"
complete -c lb -n "__fish_use_subcommand" -a "info" -d "Show tool info"
complete -c lb -n "__fish_use_subcommand" -a "init" -d "Initialize configuration or completions"
complete -c lb -n "__fish_use_subcommand" -a "push" -d "Push to Joplin"
complete -c lb -n "__fish_use_subcommand" -a "bkup" -d "Backup database"
complete -c lb -n "__fish_use_subcommand" -a "cal" -d "Show calendar"

complete -c lb -n "__fish_seen_subcommand_from init" -a "fish" -d "Generate fish completions"

complete -c lb -n "__fish_seen_subcommand_from ls" -s l -d "Long format"
complete -c lb -n "__fish_seen_subcommand_from ls" -s v -d "Verbose (-v, -vv)"
complete -c lb -n "__fish_seen_subcommand_from ls" -s a -d "All entries (chronological)"
complete -c lb -n "__fish_seen_subcommand_from log" -s l -d "Long format"
complete -c lb -n "__fish_seen_subcommand_from log" -s v -d "Verbose (-v, -vv)"
complete -c lb -n "__fish_seen_subcommand_from search" -s l -d "Long format"
complete -c lb -n "__fish_seen_subcommand_from search" -s v -d "Verbose (-v, -vv)"
complete -c lb -n "__fish_seen_subcommand_from edit" -s y -d "YAML mode"
complete -c lb -n "__fish_seen_subcommand_from cal" -s y -d "Year view"
complete -c lb -n "__fish_seen_subcommand_from cal" -s i -d "Include tags"
complete -c lb -n "__fish_seen_subcommand_from cal" -s x -d "Exclude tags"
complete -c lb -n "__fish_seen_subcommand_from add ls rm mv edit cal" -a "(__fish_lb_tags)"
