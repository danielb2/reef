function reef -d 'package manager for fish'
    set -l cmd $argv[1]
    set -e argv[1]

    switch $cmd
        case version
            echo reef 1.0.0
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
            echo "source $reef_path/conf.d/reef.fish" >"$__fish_config_dir/conf.d/reef.fish"
            echo 🪸🐟 initialized - ready to go
            reef splash
        case splash
            reef_splash
        case "" help
            reef splash
            reef_show_help reef
        case prompt
            set -l date (date +%F)
            path is $__fish_config_dir/functions/fish_prompt.fish
            and cp $__fish_config_dir/functions/fish_prompt.fish{,-$date.bak}
            path is $__fish_config_dir/functions/fish_right_prompt.fish
            and cp $__fish_config_dir/functions/fish_right_prompt.fish{,-$date.bak}
            function fish_prompt
            end
            function fish_right_prompt
            end
            source $__fish_config_dir/corals/**/reef/functions/fish_prompt.fish
            funcsave -q fish_prompt
            funcsave -q fish_right_prompt 2>/dev/null
        case theme
            set prompt_file $__fish_config_dir/functions/fish_prompt.fish
            if test -f $prompt_file && ! test -L $prompt_file
                echo 🪸🐟 theres a fish_prompt already. backup and delete first if you want to set a theme
                return 1
            end
            if ! [ $argv[1] ]
                for prompt in $__fish_config_dir/corals/**/functions/fish_prompt.fish
                    set prompt (string replace $__fish_config_dir/corals/ '' $prompt)
                    set prompt (string replace /functions/fish_prompt.fish '' $prompt)
                    echo $prompt
                end
                return
            end
            set -l chosen $__fish_config_dir/corals/$argv/functions/fish_prompt.fish
            if test -f $chosen
                ln -sf $chosen $prompt_file
                source $prompt_file
                echo 🪸🐟 set
            else
                echo 🪼 cant find that theme
                return 1
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
