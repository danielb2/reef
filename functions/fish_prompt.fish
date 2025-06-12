# Daniel Bretoi 2018
function fish_prompt
    function format_duration
        set -l SEC 1000
        set -l MIN (math 60 x $SEC)
        set -l HOUR (math 60 x $MIN)
        set -l DAY (math 24 x $HOUR)

        set -l DURATION $argv[1]
        [ "$DURATION" ]; or set -l DURATION $cmd_duration

        set -l num_days (math "floor($DURATION / $DAY)")
        set -l num_hours (math "floor($DURATION % $DAY / $HOUR)")
        set -l num_mins (math "floor($DURATION % $HOUR / $MIN)")
        set -l num_secs (math "floor(($DURATION % $MIN) / $SEC)")
        set -l num_msecs (math "round(($DURATION % $SEC) / 10)")

        set -l time_str (string join " " \
            (test $num_days -gt 0; and echo "$num_days"d) \
            (test $num_hours -gt 0; and echo "$num_hours"h) \
            (test $num_mins -gt 0; and echo "$num_mins"m))

        set time_str "$time_str$num_secs."(printf "%02d" $num_msecs)"s"
        echo $time_str
    end

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

    # /etc/sudoers: daniel ALL=(ALL) NOPASSWD: /opt/homebrew/bin/wg
    if type -q wg
        set -l show (env -u TERMINFO sudo wg show)
        if [ $show[1] ]
            printf 🔒
        end
    end

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
