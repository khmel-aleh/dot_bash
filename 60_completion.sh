#!/usr/bin/env bash

echo "Setting bash completion..."

# # Brew completion
# if [[ "$OSTYPE" == "darwin"* ]]; then
#   HOMEBREW_PREFIX=$(brew --prefix)
#   if type brew &>/dev/null; then
#     if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
#       source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
#     else
#       for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
#         [[ -r "$COMPLETION" ]] && source "$COMPLETION"
#       done
#     fi
#   fi
# fi


# # Heroku completion
# if type heroku &>/dev/null; then
#   $(heroku autocomplete:script bash)
# fi

