# Stop Waydroid
stop-waydroid:
    #!/usr/bin/env bash
    read -t 10 -p "Press Enter to continue within 10 seconds..." input
    if [ $? -ne 0 ] || [ "$input" != "" ]
    then
      echo "Exiting."
      exit 0
    fi

    #if [ "$(command -v run0)" ]
    #then
    #  printf "\033[0;33m pkexec found using run0 ...\033[0m\n"
    #  pk='run0'
    #elif [ "$(command -v pkexec)" ]
    #then
    #  printf "\033[0;33m pkexec found using pkexec ...\033[0m\n"
    # pk='pkexec'
    #elif [ "$(command -v doas)" ]
    #then
    #  printf "\033[0;33m doas found using doas ...\033[0m\n"
    #  pk='doas'
    #elif [ "$(command -v sudo)" ]
    #then
    #  printf "\033[0;33m sudo found using sudo ...\033[0m\n"
    #  pk='sudo'
    #fi

    run0 waydroid session stop
    run0 waydroid container stop
