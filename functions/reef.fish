function __reef_resolve_coral
    set -l repo $argv[1]
    set -l base (string replace -r '@[^/]+$' '' -- "$repo")
    string replace -r '^.*(:|/)([^/]*)/([^/]*)$' '$2/$3' $base
end

function reef -d 'package manager for fish'
    set -l cmd $argv[1]
    set -e argv[1]
    set -l reef_plugins_file $__fish_config_dir/reef_plugins

    switch $cmd
        case version
            echo reef 1.6.0
        case ed
            $EDITOR (status current-filename)
        case fish_reload
            eval exec (status fish-path)
        case list ls
            for coral in $__fish_config_dir/corals/*/*
                echo (string replace -r "^$__fish_config_dir/corals/" "" $coral)
            end
        case install add
            if not command -sq git
                echo 🪸🐟 (set_color red)yeah, you need to install `git` first
                return 1
            end
            for repo in $argv
                set base (string replace -r '@[^/]+$' '' -- "$repo")
                set tag (string match -r '@([^/]+)$' "$repo")[2]

                set -l dest (string replace -r '^.*(:|/)([^/]*)/([^/]*)$' '$2/$3' $base)
                set -l name (string replace -r '^.*?([^/]*)$' '$1' $base)
                set path (string replace -r '.git$' '' $__fish_config_dir/corals/$dest)

                if not string match -rq '^(https?://|\w+@)' -- "$base"
                    if test -d $base
                        set base file://github.com/$base
                    else
                        set base https://github.com/$base
                    end
                end

                if test -d $path
                    echo "Coral already exists: $dest"
                    continue
                end

                set -l clone_args --depth 1 --single-branch
                if test -n "$ref"
                    set clone_args -b "$ref" $clone_args
                end

                git clone $clone_args -- "$base" "$path"
                if test $status -eq 0
                    emit {$name}_install
                    if test -f $reef_plugins_file
                        set -l plugins (cat $reef_plugins_file)
                        if not contains "$repo" $plugins
                            echo "$repo" >> $reef_plugins_file
                        end
                    else
                        echo "$repo" >> $reef_plugins_file
                    end
                else
                    echo "Failed to clone $repo"
                end
            end
            reef reload
        case reload
            for i in $__fish_config_dir/corals/**/reef/*/reef.fish
                source $i
            end
            echo 🪸🐟 reloaded
        case init
            set -l reef_path $__fish_config_dir/corals/**/reef
            mkdir -p $__fish_config_dir/conf.d
            echo "source $reef_path/conf.d/reef.fish" >"$__fish_config_dir/conf.d/reef.fish"
            echo 🪸🐟 initialized - ready to go
            reef splash
        case splash
            reef_splash
        case "" help
            reef splash
            reef_show_help reef
        case theme
            # list themes
            if ! [ $argv[1] ]
                reef_list_themes
                return
            end

            set -l real (ls $__fish_config_dir/corals/$argv/functions/{fish_prompt,fish_right_prompt}.fish 2>/dev/null)
            if ! [ $real[1] ]
                echo "🎣 alas, there's no theme to be found here"
                return 1
            end

            for prompt in $__fish_config_dir/corals/$argv/functions/{fish_prompt,fish_right_prompt}.fish
                not test -f $prompt && break # if there's no such file, move on
                set -l relative_prompt (string replace $__fish_config_dir .. $prompt)
                set -l main (string replace /corals/$argv '' $prompt)
                if [ $argv[1] ] && test -f $main && ! test -L $main
                    set -l date (date +%F)
                    path is $main
                    and cp -v $main{,-$date.bak}
                    echo 🪸🐟 there was a (basename $main) already. backedup it up for you
                end
                ln -sf $relative_prompt $main
                source $main
            end
        case rm remove
            for coral in $argv
                set -l path "$__fish_config_dir/corals/$coral"
                set -l name (string replace -r '^.*?([^/]*)$' '$1' $coral)
                if test -d $path
                    command rm -rf $path
                    echo "🪸🐟 removed coral: $coral"
                    emit {$name}_uninstall

                    if test -f $reef_plugins_file
                        set -l tmp (mktemp)
                        # Resolve input coral once
                        set -l coral_slug (__reef_resolve_coral $coral)
                        while read -l line
                            set -l resolved (__reef_resolve_coral $line)
                            if test "$resolved" != "$coral_slug"
                                echo "$line" >> $tmp
                            end
                        end < $reef_plugins_file
                        mv $tmp $reef_plugins_file
                    end
                else
                    echo 🪸🐟 (set_color red)coral not found: $coral(set_color normal)
                    return 1
                end
            end
            reef reload
        case sync
            if not test -f $reef_plugins_file
                echo "🪸🐟 no plugins file found at $reef_plugins_file"
                echo "🪸🐟 you can create it by adding corals or manually at that path"
                return 1
            end

            set -l desired_lines (cat $reef_plugins_file | string trim | string match -r -v '^#|^$')
            set -l installed (reef ls)

            set -l missing
            for line in $desired_lines
                set -l coral (__reef_resolve_coral $line)
                if not contains $coral $installed
                    set -a missing $line
                end
            end

            set -l extra
            set -l desired_corals
            for line in $desired_lines
                set -a desired_corals (__reef_resolve_coral $line)
            end
            for coral in $installed
                if not contains $coral $desired_corals
                    if test "$coral" = "danielb2/reef"
                        continue
                    end
                    set -a extra $coral
                end
            end

            if test -n "$missing"
                reef add $missing
            end

            if test -n "$extra"
                reef rm $extra
            end
        case up update upgrade
            set -l corals $argv
            if not [ $argv[1] ]
                set corals $__fish_config_dir/corals/*/*
                set corals (string replace $__fish_config_dir/corals/ '' $corals)
            end

            for coral in $corals
                set -l s_name (string replace -r '^.*?([^/]*)$' '$1' $coral)
                set name (string replace -r "^$__fish_config_dir/corals/" "" $coral)
                printf "%-30s " $name
                git -C "$__fish_config_dir/corals/"$coral pull && emit {$s_name}_update || echo "Failed to update $name"
            end
            reef reload
        case '*'
            reef help
            echo 🪸🐟(set_color red) unknown command `$cmd`
            return 1
    end
end
