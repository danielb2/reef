function __reef_list_corals
    for coral in $__fish_config_dir/corals/*/*
        echo (string replace -r "^$__fish_config_dir/corals/" "" $coral)
    end
end

set -l __reef_commands install add rm remove up update list theme

complete -e reef

complete -c reef -n "not __fish_seen_subcommand_from $__reef_commands" -f \
    -a "add install" \
    -d "add corals"

complete -c reef -n "not __fish_seen_subcommand_from $__reef_commands" -f \
    -a "rm remove" \
    -d "remove corals"

complete -c reef -n "not __fish_seen_subcommand_from $__reef_commands" -f \
    -a "up update" \
    -d "update coral(s)"

complete -c reef -n "not __fish_seen_subcommand_from $__reef_commands" -f \
    -a version \
    -d "display reef version"

complete -c reef -n "not __fish_seen_subcommand_from $__reef_commands" -f \
    -a theme \
    -d "list or set new theme"

complete -c reef -n "not __fish_seen_subcommand_from $__reef_commands" -f \
    -a splash \
    -d "show the reef splash"

complete -c reef -n "not __fish_seen_subcommand_from $__reef_commands" -f \
    -a reload \
    -d "reload reefs files (you probably dont need this)"

complete -c reef -n "not __fish_seen_subcommand_from $__reef_commands" -f \
    -a help \
    -d "this beautiful help"

complete -c reef -n "__fish_seen_subcommand_from install" -a "" \
    -d "Git URL or user/repo to install"

complete -c reef -f -n "__fish_seen_subcommand_from rm remove up update" \
    -a "(__reef_list_corals)" \
    -d "installed coral"

complete -c reef -f -n "__fish_seen_subcommand_from theme" \
    -a "(reef_list_themes)" \
    -d 'set theme'

complete -c reef -f -d 'list installed corals' -a 'ls list' -n "not __fish_seen_subcommand_from $__reef_commands"
complete -c reef -f -n '__fish_seen_subcommand_from ls list version'
