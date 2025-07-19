function fish_title
    set -l ssh
    set -q SSH_TTY
    and set ssh "["(prompt_hostname)"]"
    
    if set -q argv[1]
        echo -- $ssh (string sub -l 20 -- $argv[1]) (prompt_pwd -d 0)
    else
        set -l command (status current-command)
        if test "$command" = fish
            set command
        end
        echo -- $ssh (string sub -l 20 -- $command) (prompt_pwd -d 0)
    end
end
