function reef_list_themes
    for prompt in $__fish_config_dir/corals/**/functions/fish_prompt.fish
        set prompt (string replace $__fish_config_dir/corals/ '' $prompt)
        set prompt (string replace /functions/fish_prompt.fish '' $prompt)
        echo $prompt
    end
end
