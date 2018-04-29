#!/usr/bin/env fish

#
# Variables
#

set -x SYSTEM 0
set -x MAC 1
set -x LINUX 2
set -x USAGE "USAGE:
  update-pip.fish [option] [system]

  options:
    h, help     : Print this info and exit

  systems:
    m, mac      : MacOS
    l, linux    : Linux"

#
# Functions
#

function err
    printf "\n"
    printf "ERROR: %s\n" $argv
    exit 1
end

function pip_update
    set prefix ''
    set python_ver ''

    switch "$argv[1]"
        case 2
            set prefix 'sudo -EH'
    end

    switch "$argv[2]"
        case '2'
            set python_ver '2'
        case '3'
            set python_ver '3'
        case \*
            err "Unknown Python version: $argv[2]"
    end


    eval (echo "$prefix""pip""$python_ver install -U pip")
    and for package in (\
            pip2 freeze --local \
            | grep -v '^\-e' \
            | cut -d = -f 1\
    )
        eval (echo "$prefix""pip""$python_ver install -U $package")
    end
end

function main
    if test "$SYSTEM" -gt "$LINUX"
        printf "%s\n" $USAGE
        err "You cannot select multiple systems"
    else if test "$SYSTEM" -eq 0
        printf "%s\n" $USAGE
        err "You must select a system"
    end

    pip_update "$SYSTEM" '3'
    pip_update "$SYSTEM" '2'
end

#
# Run
#

for option in $argv
    switch "$option"
        case h help
            printf "%s\n" $USAGE
            exit 0
        case m mac
            set SYSTEM (math "$SYSTEM + $MAC")
            set MAC 0 # so multiple 'm' options don't add up to 'l' ;)
        case l linux
            set SYSTEM (math "$SYSTEM + $LINUX")
            set LINUX 0
        case \*
            printf "error: Unknown option %s\n" $option
    end
end

main 
