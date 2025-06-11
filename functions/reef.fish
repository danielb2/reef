function reef
    set -l cmd $argv[1]
    set -e argv[1]

    switch $cmd
        case list ls
            for coral in $__fish_config_dir/corals/*/*
                echo (string replace -r "^$__fish_config_dir/corals/" "" $coral)
            end
        case install
            for repo in $argv
                set -l dest (string replace -r '.*/([^/]+)$' '$1' $repo)
                set -l path "$__fish_config_dir/corals/(string split / $repo[-1])"

                if test -d $path
                    echo "Coral already exists: $path"
                else
                    git clone $repo $path || echo "Failed to clone $repo"
                end
            end

        case rm remove
            for coral in $argv
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

        case '*'
            echo "Usage: reef [install|rm|up] <coral>..."
    end
end
