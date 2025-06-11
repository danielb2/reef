function __reef_list_corals
    for coral in $__fish_config_dir/corals/*/*
        echo (string replace -r "^$__fish_config_dir/corals/" "" $coral)
    end
end

complete -e reef
complete -c reef -n "not __fish_seen_subcommand_from install add rm remove up update list" -f \
    -a "install add rm remove up update list" \
    -d "install, remove, update, list corals"

complete -c reef -n "__fish_seen_subcommand_from install" -a "" \
    -d "Git URL or user/repo to install"

complete -c reef -f -n "__fish_seen_subcommand_from rm remove up update" \
    -a "(__reef_list_corals)" \
    -d "Installed coral"

complete -c reef -n "__fish_seen_subcommand_from list" -a "" \
    -d "List installed corals"
