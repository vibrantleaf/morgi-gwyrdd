#!/usr/bin/env -S just --justfile

# Build iso file from the recipe file.
build-iso-from-recipe:
    #!/usr/bin/env bash

    if [ "$(command -v run0)" ]
    then
      printf "\033[0;33m pkexec found using run0 ...\033[0m\n"
     pk='run0'
    elif [ "$(command -v pkexec)" ]
    then
      printf "\033[0;33m pkexec found using pkexec ...\033[0m\n"
      pk='pkexec'
    elif [ "$(command -v doas)" ]
    then
      printf "\033[0;33m doas found using doas ...\033[0m\n"
      pk='doas'
    elif [ "$(command -v sudo)" ]
    then
      printf "\033[0;33m sudo found using sudo ...\033[0m\n"
      pk='sudo'
    fi

    $pk bluebuild generate-iso --iso-name sharkfin-latest.iso recipe recipes/recipe.yml

# Build iso file from the image
build-iso-from-image:
    #!/usr/bin/env bash

    if [ "$(command -v run0)" ]
    then
      printf "\033[0;33m pkexec found using run0 ...\033[0m\n"
     pk='run0'
    elif [ "$(command -v pkexec)" ]
    then
      printf "\033[0;33m pkexec found using pkexec ...\033[0m\n"
      pk='pkexec'
    elif [ "$(command -v doas)" ]
    then
      printf "\033[0;33m doas found using doas ...\033[0m\n"
      pk='doas'
    elif [ "$(command -v sudo)" ]
    then
      printf "\033[0;33m sudo found using sudo ...\033[0m\n"
      pk='sudo'
    fi

    $pk bluebuild generate-iso --iso-name sharkfin-latest.iso image ghcr.io/vibrantleaf/sharkfin:latest
