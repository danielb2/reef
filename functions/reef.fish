function __reef_resolve_coral
    set -l repo $argv[1]
    set -l base (string replace -r '@[^/]+$' '' -- "$repo") # strip tags
    set -l slug (string replace -r '^.*(:|/)([^/]*)/([^/]*)$' '$2/$3' $base) # get user/repo
    string replace -r '.git$' '' $slug # strip .git
end

function __reef_list
    for coral in $__fish_config_dir/corals/*/*
        echo (string replace -r "^$__fish_config_dir/corals/" "" $coral)
    end
end

function __reef_add
    set -l corals_file $__fish_config_dir/fish_plugins
    if not command -sq git
        echo 🪸🐟 (set_color red)yeah, you need to install `git` first(set_color normal)
        return 1
    end
    for repo in $argv
        set -l expanded_repo (string replace -r '^~' "$HOME" -- "$repo")
        
        # If it looks like a local path but doesn't exist, skip it early
        if string match -rq '^[~/]' -- "$repo"
            if not test -d "$expanded_repo"
                echo 🪸🐟 (set_color yellow)warning: local path not found: $repo(set_color normal)
                continue
            end
        end

        set -l base (string replace -r '@[^/]+$' '' -- "$expanded_repo")
        set -l tag (string match -r '@([^/]+)$' "$repo")[2]

        set -l dest (__reef_resolve_coral $base)
        set -l name (string replace -r '^.*?([^/]*)$' '$1' $dest)
        set -l path $__fish_config_dir/corals/$dest

        if not string match -rq '^(https?://|\w+@|file://|/)' -- "$base"
            if test -d "$expanded_repo"
                set base "file://$expanded_repo"
            else
                set base "https://github.com/$base"
            end
        end

        # Ensure local paths use the correct file:// format for git
        if string match -rq '^/' -- "$base"
            set base "file://$base"
        end

        if test -d "$path"
            echo "Coral already exists: $dest"
            continue
        end

        set -l clone_args --depth 1 --single-branch
        if test -n "$tag"
            set clone_args -b "$tag" $clone_args
        end

        git clone $clone_args -- "$base" "$path"
        if test $status -eq 0
            emit {$name}_install
            # Save the portable version (~ instead of /Users/...) to config
            set -l portable_repo (string replace "$HOME" "~" -- "$repo")
            if test -f $corals_file
                set -l plugins (cat $corals_file)
                if not contains "$portable_repo" $plugins
                    echo "$portable_repo" >> $corals_file
                end
            else
                echo "$portable_repo" >> $corals_file
            end
        else
            echo "Failed to clone $repo"
        end
    end
end

function __reef_rm
    set -l corals_file $__fish_config_dir/fish_plugins
    for coral in $argv
        set -l path "$__fish_config_dir/corals/$coral"
        set -l name (string replace -r '^.*?([^/]*)$' '$1' $coral)
        if test -d "$path"
            command rm -rf "$path"
            echo "🪸🐟 removed coral: $coral"
            emit {$name}_uninstall

            if test -f $corals_file
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
        else
            echo 🪸🐟 (set_color red)coral not found: $coral(set_color normal)
        end
    end
end

function __reef_up
    set -l corals $argv
    if not set -q argv[1]
        set corals (__reef_list)
    end

    for coral in $corals
        set -l s_name (string replace -r '^.*?([^/]*)$' '$1' $coral)
        printf "%-30s " $coral
        git -C "$__fish_config_dir/corals/$coral" pull && emit {$s_name}_update || echo "Failed to update $coral"
    end
end

function __reef_sync
    set -l corals_file $__fish_config_dir/fish_plugins

    if test -f $corals_file
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
                # Don't self-destruct reef if it's not in the file
                test "$coral" = "danielb2/reef"; and continue
                set -a extra $coral
            end
        end

        test -n "$missing"; and __reef_add $missing
        test -n "$extra"; and __reef_rm $extra
    end

    __reef_up
end

function reef -d 'package manager for fish'
    set -l cmd $argv[1]
    set -e argv[1]

    switch $cmd
        case version
            echo reef 1.6.0
        case ed
            $EDITOR (status current-filename)
        case fish_reload
            eval exec (status fish-path)
        case list ls
            __reef_list
        case install add
            __reef_add $argv
            reef reload
        case rm remove
            __reef_rm $argv
            reef reload
        case up update upgrade
            if not set -q argv[1]
                __reef_sync
            else
                __reef_up $argv
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
            if not set -q argv[1]
                reef_list_themes
                return
            end

            set -l real (ls $__fish_config_dir/corals/$argv[1]/functions/{fish_prompt,fish_right_prompt}.fish 2>/dev/null)
            if not set -q real[1]
                echo "🎣 alas, there's no theme to be found here"
                return 1
            end

            for prompt in $__fish_config_dir/corals/$argv[1]/functions/{fish_prompt,fish_right_prompt}.fish
                test -f $prompt; or break
                set -l relative_prompt (string replace $__fish_config_dir .. $prompt)
                set -l main (string replace "/corals/$argv[1]" '' $prompt)
                if test -f "$main"; and not test -L "$main"
                    set -l date (date +%F)
                    cp -v "$main" "$main-$date.bak"
                    echo 🪸🐟 there was a (basename "$main") already. backedup it up for you
                end
                ln -sf "$relative_prompt" "$main"
                source "$main"
            end
        case '*'
            reef help
            echo 🪸🐟(set_color red) unknown command `$cmd`(set_color normal)
            return 1
    end
end
