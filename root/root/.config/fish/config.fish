if status is-interactive
  set fish_greeting

  alias ls='eza --icons --grid'
  alias la='eza --icons --grid -a'
  alias ll='eza --icons --grid -a --long -h'
  alias lls='eza --icons --grid -a --long -h --total-size'
  alias lss='eza --icons --grid --long -h --total-size  --no-user --no-permissions --no-time -s size --reverse'
  alias las='eza --icons --grid -a --long -h --total-size  --no-user --no-permissions --no-time -s size --reverse'

  for i in (seq 1 9)
    alias lt$i="eza --icons -T -L$i"
    alias lta$i="eza --icons -a -T -L$i"
    alias l$i="eza --icons -a --long --grid --no-user --no-permissions --no-time --total-size -s size --reverse -T -L$i"
  end

  alias lt 'eza --icons -T -L' # Tree view -L level of depth(recursive)
  alias lta 'eza --icons -a -T -L' # Tree view -L level of depth(recursive)
  alias l="eza --icons -a --long --grid --no-user --no-permissions --no-time --total-size -s size --reverse -T -L"

  alias du='du -sh'
  alias cp='cp -r'
  alias rm='rm -rf'
  alias cd='z'

  alias jj='trash'
  alias jjr='trash-restore'
  alias jjl='trash-list'
  alias jje='trash-empty'
  complete -c trash-restore -a "(trash-list | awk '{print \$3}' | sed 's/ /\\ /g')"

  alias n='nvim'
  alias gs='git status'
  alias ga='git add .'
  alias gc='git commit'
  alias gp='git push'
  alias gg='git add .;git status'

  function sudo
    if test "$argv[1]" = "n"
      command sudo nvim $argv[2..-1]
    else if test "$argv[1]" = "pacman"
      if test "$argv[2]" = "-Syyuu"
        command sudo pacman -Syyuu --needed --noconfirm $argv[3..-1]
      else
        command sudo pacman $argv[2..-1]
      end
    else if test "$argv[1]" = "reflector"
      command sudo reflector --save /etc/pacman.d/mirrorlist --protocol https --country Ukraine,Poland,Germany,Czechia,Romania,Slovakia,Moldova,Bulgaria,Hungary,Serbia --age 24 --latest 10 --fastest 10 --sort rate
    else
      command sudo $argv
    end
  end

  function git
    if test "$argv[1]" = "clone"
      command git clone --depth 1 $argv[2..-1]
    else
      command git $argv
    end
  end

  zoxide init fish | source
end
