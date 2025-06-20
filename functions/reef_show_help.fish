function reef_show_help --description 'show help for subcommands based on complete'
    set -l cmd $argv
    echo "Usage: $cmd <subcommand> [options]"
    echo "Subcommands:"
    set -l regex 'complete .* -d \'([^\']+)\'.*-a \'?([a-z ]+).*'
    for line in (complete -c $cmd | reef_grep "$cmd -d .*-a \'?[a-z]+")
        set -l subcmd (string replace ' ' '/' ( string trim (string replace -r $regex '$2' $line)))
        set -l description (string replace -r $regex '$1' $line)
        printf "  %-13s %s\n" "$subcmd" "$description"
    end | sort
end
