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
            for repo in $argv
                set -l dest (string replace -r '.*://.*?\/(.*)' '$1' $repo)
                set path $__fish_config_dir/corals/$dest

                if ! [ (string match -r 'https?://git' $repo) ]
                    set repo https://github.com/$repo
                end

                if test -d $path
                    echo "Coral already exists: $dest"
                else
                    git clone --depth 1 --single-branch $repo $path || echo "Failed to clone $repo"
                end
            end
            ref reload
        case reload
            for i in $__fish_config_dir/corals/**/reef/*/reef.fish
                source $i
            end
            echo 🪸🐟 reloaded
        case init
            reef reload
            set -l reef_path $__fish_config_dir/corals/**/reef
            echo "source $reef_path/conf.d/reef.fish" >"$__fish_config_dir/conf.d/reef.fish"
            echo 🪸🐟 initialized - ready to go
            reef splash
        case splash
            command cat (dirname (status filename))/../splash
        case help
            reef splash
            reef_show_help reef
        case prompt
            path is $__fish_config_dir/functions/fish_prompt.fish
            and cp $__fish_config_dir/functions/fish_prompt.fish{,.bak}
            function fish_prompt
            end
            function fish_right_prompt
            end
            source $__fish_config_dir/corals/**/reef/functions/fish_prompt.fish
            funcsave fish_prompt
            funcsave fish_right_prompt 2>/dev/null
        case rm remove
            for coral in $argv
                set -l path "$__fish_config_dir/corals/$coral"
                if test -d $path
                    command rm -rf $path
                    echo "🪸🐟 removed coral: $coral"
                else
                    echo "🪸🐟 coral not found: $coral"
                    return 1
                end
            end
        case up update
            set -l corals $argv
            if not [ $argv[1] ]
                set corals $__fish_config_dir/corals/*/*
            end

            for coral in $corals
                set name (string replace -r "^$__fish_config_dir/corals/" "" $coral)
                printf "%-30s " $name
                git -C "$__fish_config_dir/corals/"$coral pull || echo "Failed to update $name"
            end
            reef reload
        case '*'
            reef help
            return 1
    end
end
