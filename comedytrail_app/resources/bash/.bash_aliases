# My personal aliases
alias aliases="vim $HOME/.bash_aliases; . $HOME/.bash_aliases ; clear ; echo 'Aliases updated' ; alias|sort"

# Docker Aliases
alias build="docker-compose up"

# System Admin
alias ip='ip address | grep inet'

# Short Status Report
alias st="systemctl --type=service --state=active list-units | egrep 'tightvnc|nginx|fpm'"

# Long Status Report
alias status='systemctl status nginx php-fpm tightvnc'

# Git aliases
"
alias clist="history | grep git | grep checkout"
alias mlist="history | grep git | grep merge"
alias blist="history | grep git | grep branch"

alias gadd="git add * && git status"

#EOF