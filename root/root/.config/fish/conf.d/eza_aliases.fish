alias ls 'eza -a --icons'
alias la 'eza -al --icons --header --total-size --sort size --reverse '

for i in (seq 1 9)
  alias lt$i "eza -a --icons -T -L$i"
end

function lt
    if set -q argv[1]
        eza -a --icons -T -L$argv
    else
        eza -a --icons -T -L1
    end
end
