#!/bin/bash 

EXIT_FRM_ECO="0"               #Exit code generated after operation was success
EXIR_FRM_FUN="4"               #Exit from special_keys function
EXIT_FRM_HLP="45"              #Exit code generated after help was used

#Function shows usage after using -h or --help keys
function show_usage () {
    cat <<-usage

    NAME: 
        $0 - colored echo

    SYNOPSIS:
        $0 - this script allows to output colored text using "echo -e".
        Text style and colors depends on terminal type.
    
    DESCRIPTION:
        -h      show usage
        -n      do not output the trailing newline
        -H      hidden
        -U      underlined
        -D      dim
        -I      inverse
        -B      bold
        -R      reset to default (use for outputing special symbols)
        -c      cyan
        -d      dark gray
        -f      black (foul)
        -r      red
        -g      green
        -y      yellow
        -b      blue
        -m      magenta
        -w      white

        --test  show color gradient and term colors
        --raw   show raw format of ANSI values
        --help  show usage
    
    EXAMPLES:
        This example shows "Hello world" sting painted to yellow color
        and it has underline style:
                $0 -yU "Hello world"

        This example output "Hello world" string on magenta background:
                $0 -mI "Hello world"

        This example outputs text like simple echo utilite:
                $0 -R --text

        This example outputs raw format of ANSI color codes:
                $0 --raw -y "Hello world" 
	
    EXIT CODE:
        0      successful exit
        4      exit from special_keys function
       45      successful exit from help (used by -h either --help) - success

    AUTHOR:
        Written by Flood_ctrl
        https://github.com/Flood-ctrl
        
usage
    exit $EXIT_FRM_HLP
}

#Function for using standart echo utilite and exit with status code 0
function simple_echo () {
    echo "$@" && exit $EXIT_FRM_ECO
}

#Special keys from $1 like "--help" and other begins with "--" chars
function special_keys () {
    case $1 in
        --test) for i in {0..255} {255..0} ; do
                    echo -en "\e[48;5;${i}m \e[0m" ;
                    done ; echo "Colors: $(tput colors)"
        ;;
        --help) show_usage
        ;;
        --raw) rawFormat=1; return $EXIR_FRM_FUN
        ;;
        *) simple_echo "$@"
        ;;
    esac
    exit $EXIT_FRM_ECO
}

#If it absents color and text style arguments it uses echo utilite
[[ ! "$1" =~ ^- ]] && simple_echo "$@"

#If $1 contais at begin of string "--" it chooes special functions
[[ "$1" =~ ^-- ]] && special_keys "$@"

#Test for show_usage arguments
[[ "$1" =~ ^-h || -z "$1" ]] && show_usage

#If it just one argument it shows using standart echo utilite 
[[ "$#" -eq 1 ]] && simple_echo "$@"

#If --raw was enabled it shifting $1
[[ $rawFormat = "1" ]] && shift

#It combines all arguments (exclude from $0, $1, $2) to list
if [[ "$#" -gt 2 ]]; then
    nextPositionParam=3
    until [[ $nextPositionParam -gt $# ]]; do
        eval paramPosition='$'$nextPositionParam
            if [[ $nextPositionParam -eq $# ]]; then
                nextArguments+=${paramPosition}
            elif [[ $nextPositionParam -eq 3 ]]; then
                nextArguments+=" "
                nextArguments+=${paramPosition}" "
            else
                nextArguments+=${paramPosition}" "
            fi;
        ((++nextPositionParam))
    done;
fi;

#cecho_main function outputs colored and styled text using echo utilite with ANSI/VT100 escape sequences
function cecho_main () {
#If $1 contains -n key it unites with -e key
    if [[ "$1" == *"n"* ]]; then
        echoKey="-en"
        colorArgument=${1/n/}
    elif [[ ${rawFormat} -eq 1 ]]; then
        echoKey=""
        colorArgument=${1/-/}
    else
        echoKey="-e"
        colorArgument=${1/-/}
    fi;
#Removing duplicated symbols in rows
    colorArgument=$(echo ${colorArgument} | tr -s 'a-z')

    local argsCount=${#colorArgument}       #Count of color and style arguments

#This loop integrates all parameters to list
    while [[ ${argsCount} -ne 0 ]]; do
        case ${colorArgument: -${argsCount}:1} in
            *"D"*) textColor+="\e[2m"
            ;;
            *"I"*) textColor+="\e[7m"
            ;;
            *"B"*) textColor+="\e[1m"
            ;;
            *"H"*) textColor+="\e[8m"
            ;;
            *"R"*) textColor+="\e[0m"
            ;;
            *"U"*) textColor+="\e[4m"
            ;;
            *"c"*) textColor+="\e[36m"
            ;;
            *"d"*) textColor+="\e[90m"
            ;;
            *"f"*) textColor+="\e[30m"
            ;;
            *"r"*) textColor+="\033[1;31m"
            ;;
            *"g"*) textColor+="\033[32m"
            ;;
            *"y"*) textColor+="\e[33m"
            ;;
            *"b"*) textColor+="\e[34m"
            ;;
            *"m"*) textColor+="\e[35m"
            ;;
            *"w"*) textColor+="\e[97m"
            ;;
            *) simple_echo "$@"
            ;;
        esac
        ((--argsCount))
    done;

    echo ${echoKey} "$textColor$2$3\033[0m" 
}

#[[ "$#" -eq 1 ]] && set -- "${@:-2:2}" "BOLD"
cecho_main "$1" "$2" "$nextArguments"
