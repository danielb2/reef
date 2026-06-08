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
    if not command -sq git
        echo 🪸🐟 (set_color red)yeah, you need to install `git` first(set_color normal)
        return 1
    end
    for repo in $argv
        set -l expanded_repo (string replace -r '^~' "$HOME" -- "$repo")

        # If it looks like a local path but doesn't exist, skip it early
        if string match -rq '^[~/]' -- "$repo"
            if not test -d "$expanded_repo"
                echo "🪸🐟 (set_color yellow)warning: local path not found: $repo(set_color normal)"
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
            emit reef_add "$repo"
            emit {$name}_install
        else
            echo "Failed to clone $repo"
        end
    end
end

function __reef_rm
    for coral in $argv
        set -l path "$__fish_config_dir/corals/$coral"
        set -l name (string replace -r '^.*?([^/]*)$' '$1' $coral)
        if test -d "$path"
            command rm -rf "$path"
            echo "🪸🐟 removed coral: $coral"
            emit reef_rm "$coral"
            emit {$name}_uninstall
        else
            echo 🪸🐟 (set_color red)coral not found: $coral(set_color normal)
        end
    end
end

function __reef_update
    set -l corals $argv
    if not set -q argv[1]
        emit reef_update
        set corals (__reef_list)
    end

    for coral in $corals
        set -l s_name (string replace -r '^.*?([^/]*)$' '$1' $coral)
        printf "%-30s " $coral
        git -C "$__fish_config_dir/corals/$coral" pull && emit {$s_name}_update || echo "Failed to update $coral"
    end
end

function reef -d 'package manager for fish'
    set -l cmd $argv[1]
    set -e argv[1]

    switch $cmd
        case version
            echo reef 1.6.1
        case ed
            $EDITOR (status current-filename)
        case fish_reload
            eval exec (status fish-path)
        case list ls
            __reef_list
        case install add
            __reef_add $argv
            reef reload
        case cd
            cd $__fish_config_dir/corals/**/reef/
        case rm remove
            __reef_rm $argv
            reef reload
        case up update upgrade
            __reef_update $argv
            reef reload
        case reload
            for i in $__fish_config_dir/corals/**/reef/*/reef.fish
                source $i
            end
            echo 🪸🐟 reloaded
        case init
            if not test -d "$__fish_config_dir/corals/danielb2/reef"
                __reef_add danielb2/reef
            end
            mkdir -p "$__fish_config_dir/conf.d"
            set -l reef_path "$__fish_config_dir/corals/danielb2/reef"
            echo "source $reef_path/conf.d/reef.fish" >"$__fish_config_dir/conf.d/reef.fish"
            reef reload
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
