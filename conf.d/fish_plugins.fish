function __reef_fish_plugins_add --on-event reef_add
    set -l repo $argv[1]
    set -l fish_plugins_file $__fish_config_dir/fish_plugins
    test -f $fish_plugins_file; or return

    # If the file exists but is empty, bootstrap it first
    if not string match -rq '[^[:space:]]' < $fish_plugins_file
        reef ls > $fish_plugins_file
    end

    set -l portable_repo (string replace "$HOME" "~" -- "$repo")
    set -l plugins (cat $fish_plugins_file)
    if not contains "$portable_repo" $plugins
        echo "$portable_repo" >> $fish_plugins_file
    end
end

function __reef_fish_plugins_rm --on-event reef_rm
    set -l coral $argv[1]
    set -l fish_plugins_file $__fish_config_dir/fish_plugins
    test -f $fish_plugins_file; or return
    set -l tmp (mktemp)
    set -l coral_slug (__reef_resolve_coral $coral)
    while read -l line
        set -l resolved (__reef_resolve_coral $line)
        if test "$resolved" != "$coral_slug"
            echo "$line" >> $tmp
        end
    end < $fish_plugins_file
    mv $tmp $fish_plugins_file
end

function __reef_fish_plugins_update --on-event reef_update
    set -l fish_plugins_file $__fish_config_dir/fish_plugins
    test -f $fish_plugins_file; or return

    set -l desired_lines (string trim < $fish_plugins_file | string match -r -v '^#|^$')
    set -l installed (__reef_list)

    # If the file exists but is empty, populate it from current disk state
    if not set -q desired_lines[1]
        reef ls > $fish_plugins_file
        return
    end

    set -l missing
    set -l desired_corals
    for line in $desired_lines
        set -l resolved (__reef_resolve_coral $line)
        set -a desired_corals $resolved
        if not contains $resolved $installed
            set -a missing $line
        end
    end

    set -l extra
    for coral in $installed
        if not contains $coral $desired_corals
            test "$coral" = "danielb2/reef"; and continue
            set -a extra $coral
        end
    end

    test -n "$missing"; and __reef_add $missing
    test -n "$extra"; and __reef_rm $extra
end
