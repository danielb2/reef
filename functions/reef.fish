function reef -d 'package manager for fish'
    set -l cmd $argv[1]
    set -e argv[1]

    switch $cmd
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

        case help
            command cat (dirname (status filename))/../splash
            reef_show_help reef
        case rm remove
            for coral in $argv
                set coral (dirname $coral)
                set -l path "$__fish_config_dir/corals/$coral"
                if test -d $path
                    command rm -rf $path
                    echo "Removed coral: $coral"
                else
                    echo "Coral not found: $coral"
                end
            end

        case up update
            for coral in $argv
                set -l path "$__fish_config_dir/corals/$coral"
                if test -d $path
                    git -C $path pull || echo "Failed to update $coral"
                else
                    echo "Coral not installed: $coral"
                end
            end

            if not [ $argv[1] ]
                for coral in $__fish_config_dir/corals/*/*
                    set name (string replace -r "^$__fish_config_dir/corals/" "" $coral)
                    printf "%-30s " $name
                    git -C $coral pull || echo "Failed to update $name"
                end
            end
        case '*'
            reef help
    end
end
