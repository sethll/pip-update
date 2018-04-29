#!/usr/bin/env fish

# Copyright 2018, Seth Leick <sethll>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
