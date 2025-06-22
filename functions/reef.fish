function reef -d 'package manager for fish'
    set -l cmd $argv[1]
    set -e argv[1]

    switch $cmd
        case version
            echo reef 1.2.0
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
                set -l dest (string replace -r '^.*(:|/)([^/]*)/([^/]*)$' '$2/$3' $repo)
                set path (string replace -r '.git$' '' $__fish_config_dir/corals/$dest)

                if not string match -rq '^(https?://|\w+@)' -- "$repo"
                    set repo https://github.com/$repo
                end

                if test -d $path
                    echo "Coral already exists: $dest"
                else
                    git clone --depth 1 --single-branch $repo $path || echo "Failed to clone $repo"
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
                if test -d $path
                    command rm -rf $path
                    echo "🪸🐟 removed coral: $coral"
                else
                    echo 🪸🐟 (set_color red)coral not found: $coral
                    return 1
                end
            end
        case up update
            set -l corals $argv
            if not [ $argv[1] ]
                set corals $__fish_config_dir/corals/*/*
                set corals (string replace $__fish_config_dir/corals/ '' $corals)
            end

            for coral in $corals
                set name (string replace -r "^$__fish_config_dir/corals/" "" $coral)
                printf "%-30s " $name
                git -C "$__fish_config_dir/corals/"$coral pull || echo "Failed to update $name"
            end
            reef reload
        case '*'
            reef help
            echo 🪸🐟(set_color red) unknown command `$cmd`
            return 1
    end
end
