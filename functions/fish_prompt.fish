function fish_prompt

    set -l __last_command_exit_status $status

    set -U fish_color_autosuggestion BD93F9 --bold
    set -U fish_color_command brcyan --bold
    set -U fish_color_param 00afff --bold
    set -U fish_color_error brred -b
    set -U fish_color_quote bryellow -b

    if not set -q CMD_DURATION
        set CMD_DURATION 0
    end

    set -l brblue (set_color brblue)
    set -l cyan (set_color cyan)
    set -l brcyan (set_color 3FF)
    set -l green (set_color green)

    set -l user_host "$brblue"'['"$cyan"(whoami)$brcyan@$cyan(hostname -s)$brblue']'
    set -l time "$brblue($cyan"(date +%T)$brblue")"
    set -l last_command_duration "($cyan"(format_duration $CMD_DURATION)"$brblue)"

    # set the first line of the prompt
    echo -n $user_host$time$last_command_duration

    if [ $__last_command_exit_status -ne 0 ]
        set_color red
        echo -n ' ✗'
    end

    # newline
    echo ''

    set -l path $brblue"["$cyan(prompt_pwd)$brblue"]"

    set -l prompt_symbol $green'$ '
    if fish_is_root_user
        set prompt_symbol $green'# '
    end

    # second line of prompt
    echo -n $path$prompt_symbol
    set_color normal
end
