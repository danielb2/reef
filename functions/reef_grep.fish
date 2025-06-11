function reef_grep --description 'fish implementation of grep'
    set -l args $argv
    if ! isatty stdin # piped input
        while read -l line
            set -a args $line
        end
    end

    set -l pattern $args[1]
    set -l array $args[2..-1]
    for i in $array
        if string match -qr "$pattern" $i
            if isatty stdout
                string replace -a -r "($pattern)" (set_color red)'$1'(set_color normal) $i
            else
                echo $i
            end
        end
    end
end
