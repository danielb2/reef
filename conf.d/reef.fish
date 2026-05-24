set -a fish_function_path (path resolve $__fish_config_dir/corals/*/*/functions)
set -a fish_complete_path (path resolve $__fish_config_dir/corals/*/*/completions)
source $__fish_config_dir/corals/*/reef/completions/reef.fish # source completions for reef help

# Source all coral conf.d/*.fish files
for conf in (path resolve $__fish_config_dir/corals/*/*/conf.d/*.fish)
    set base (basename $conf)
    if [ $base != "reef.fish" ]
        source $conf
    end
end

function __reef_fish_plugins_add --on-event reef_add
    set -l repo $argv[1]
    set -l corals_file $__fish_config_dir/fish_plugins
    set -l portable_repo (string replace "$HOME" "~" -- "$repo")
    if test -f $corals_file
        set -l plugins (cat $corals_file)
        if not contains "$portable_repo" $plugins
            echo "$portable_repo" >> $corals_file
        end
    else
        echo "$portable_repo" >> $corals_file
    end
end

function __reef_fish_plugins_rm --on-event reef_rm
    set -l coral $argv[1]
    set -l corals_file $__fish_config_dir/fish_plugins
    test -f $corals_file; or return
    set -l tmp (mktemp)
    set -l coral_slug (__reef_resolve_coral $coral)
    while read -l line
        set -l resolved (__reef_resolve_coral $line)
        if test "$resolved" != "$coral_slug"
            echo "$line" >> $tmp
        end
    end < $corals_file
    mv $tmp $corals_file
end

function __reef_fish_plugins_sync --on-event reef_update
    set -l corals_file $__fish_config_dir/fish_plugins
    test -f $corals_file; or return

    set -l desired_lines (string trim < $corals_file | string match -r -v '^#|^$')
    set -l installed (__reef_list)

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
