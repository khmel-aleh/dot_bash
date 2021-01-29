#!/usr/bin/env bash

echo "Setting bash prompt..."

# PS1='\n' # newline
# PS1+='\[\e[1;37m\]|-- ' # open prompt
# PS1+='\[\e[1;32m\]\u' # user name
# PS1+='\[\e[0;39m\]@' # @ symbol
# PS1+='\[\e[1;36m\]\h' # host name
# PS1+='\[\e[0;39m\]:' # : symbol
# PS1+='\[\e[1;33m\]\w' # directory path

# git_prompt="/etc/bash_completion.d/git-prompt"

# if [[ "$OSTYPE" == "darwin"* ]]; then
#   git_prompt="/etc/bash_completion.d/git-prompt.sh"
#   git_prompt="$(brew --prefix)/$git_prompt"
# fi


# if [ -f "$git_prompt" ] ; then
#     echo 'Source git prompt...'
#     source "$git_prompt"
#     PS1+='\[\e[0;39m\]\[\e[1;35m\]$(__git_ps1 " (%s)")\[\e[0;39m\] ' # git branch
# fi

# PS1+='\[\e[1;37m\]--|' # close prompt
# PS1+='\[\e[0;39m\]\n' # new line
# PS1+='$ '

# export PS1

