# Add all coral functions/ directories to fish_function_path
set -l coral_paths (path resolve $__fish_config_dir/corals/*/*/functions)
set -a fish_function_path $coral_paths

# Source all coral conf.d/*.fish files
for conf in (path resolve $__fish_config_dir/corals/*/*/conf.d/*.fish)
    set base (basename $conf)
    if [ $base != "reef.fish" ]
        source $conf
    end
end

# Source all coral complete/*.fish files
for complete in (path resolve $__fish_config_dir/corals/*/*/completions/*.fish)
    source $complete
end
