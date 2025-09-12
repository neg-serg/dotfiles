{
  lib,
  config,
  ...
}:
with lib;
  mkIf config.features.fun.enable {
    # Inline files under XDG data using text fields (no symlinks)
    xdg = {
      dataFile = {
        # hack-art files
        "hack-art/bonsai" = {
          text = ''
            #!/usr/bin/env bash

            # I'm a bonsai-making machine!

            #################################################
            ##
            # author: John Allbritten
            # my website: theSynAck.com
            #
            # repo: https://gitlab.com/jallbrit
            #  script can be found in the bin/bin/fun folder.
            #
            # license: this script is published under GPLv3.
            #  I don't care what you do with it, but I do ask
            #  that you leave this message please!
            #
            # inspiration: http://andai.tv/bonsai/
            #  andai's version was written in JS and served
            #  as the basis for this script. Originally, this
            #  was just a port.
            ##
            #################################################

            # ------ vars ------
            # CLI options

            flag_h=false
            live=false
            infinite=false

            termCols=$(tput cols)
            termRows=$(tput lines)
            geometry="$((termCols - 1)),$termRows"

            leafchar='&'
            termColors=false

            message=""
            flag_m=false
            basetype=1
            multiplier=5

            lifeStart=28
            steptime=0.01	# time between steps

            # non-CLI options
            lineWidth=4	# words per line

            # ------ parse options ------

            OPTS="hlt:ig:c:Tm:b:M:L:"	# the colon means it requires a value
            LONGOPTS="help,live,time:,infinite,geo:,leaf:,termcolors,message:,base:,multiplier:,life:"

            parsed=$(getopt --options=$OPTS --longoptions=$LONGOPTS -- "$@")
            eval set -- "${"$"}{parsed[@]}"

            while true; do
            	case "$1" in
            		-h|--help)
            			flag_h=true
            			shift
            			;;

            		-l|--live)
            			live=true
            			shift
            			;;

            		-t|--time)
            			steptime="$2"
            			shift 2
            			;;

            		-i|--infinite)
            			infinite=true
            			shift
            			;;

            		-g|--geo)
            			geo=$2
            			shift 2
            			;;

            		-c|--leaf)
            			leafchar="$2"
            			shift 2
            			;;

            		-T|--termcolors)
            			termColors=true
            			shift
            			;;

            		-m|--message)
            			flag_m=true
            			message="$2"
            			shift 2
            			;;

            		-b|--basetype)
            			basetype="$2"
            			shift 2
            			;;

            		-M|--multiplier)
            			multiplier="$2"
            			shift 2
            			;;

            		-L|--life)
            			lifeStart="$2"
            			shift 2
            			;;

            		--) # end of arguments
            			shift
            			break
            			;;

            		*)
            			echo "error while parsing CLI options"
            			flag_h=true
            			;;
            	esac
            done

            HELP="Usage: bonsai [-h] [-i] [-l] [-T] [-m message] [-t time]
                          [-g x,y] [ -c char] [-M 0-9]

            bonsai.sh is a static and live bonsai tree generator, written in bash.

            optional args:
              -l, --live             enable live generation
              -t, --time time        time between each step of growth [default: 0.01]
              -m, --message text     attach a message to the tree
              -b, --basetype 0-2     which ascii-art plant base to use (0 for none) [default: 1]
              -i, --infinite         keep generating trees until quit (2s between each)
              -T, --termcolors       use terminal colors
              -g, --geo geo          set custom geometry [default: fit to terminal]
              -c, --leaf char        character used for leaves [default: &]
              -M, --multiplier 0-9   branch multiplier; higher equals more branching [default: 5]
              -L, --life int         life of tree; higher equals more overall growth [default: 28]
              -h, --help             show help"

            # check for help
            $flag_h && echo -e "$HELP" && exit 0

            # geometry processing
            cols=$(echo "$geometry" | cut -d ',' -f1)	# width; X
            rows=$(echo "$geometry" | cut -d ',' -f2)	# height; Y

            IFS=$'\n'	# delimit strings by newline
            tabs 4 		# set tabs to 4 spaces

            declare -A gridMessage

            # message processing
            if [ $flag_m = true ]; then

            	messageWidth=20

            	# make room for the message to go on the right side
            	cols=$((cols - messageWidth - 8 ))

            	# wordwrap message, delimiting by spaces
            	message="$(echo "$message" | fold -sw $messageWidth)"

            	# get number of lines in the message
            	messageLineCount=0
            	for line in $message; do
            		messageLineCount=$((messageLineCount + 1))
            	done

            	messageOffset=$((rows - messageLineCount - 7))

            	# put lines of message into a grid
            	index=$messageOffset
            	for line in $message; do
            		gridMessage[$index]="$line"
            		index=$((index + 1))
            	done
            fi

            # define colors
            if [ $termColors = true ]; then
            	LightBrown='\e[1;33m'
            	DarkBrown='\e[0;33m'
            	BrownGreen='\e[1;32m'
            	Green='\e[0;32m'
            else
            	LightBrown='\e[38;5;172m'
            	DarkBrown='\e[38;5;130m'
            	BrownGreen='\e[38;5;142m'
            	Green='\e[38;5;106m'
            fi
            Grey='\e[1;30m'
            R='\e[0m'

            # create ascii base in lines
            base=""
            case $basetype in
            	0)
            		base="" ;;

            	1)
            		width=15
            		art="\
            ${"$"}{Grey}:${"$"}{Green}___________${"$"}{DarkBrown}./~~\\.${"$"}{Green}___________${"$"}{Grey}:
             \\                          /
              \\________________________/
              (_)                    (_)"
            		;;

            	2)
            		width=7
            		art="\
            ${"$"}{Grey}(${"$"}{Green}---${"$"}{DarkBrown}./~~\\.${"$"}{Green}---${"$"}{Grey})
             (          )
              (________)"
            		;;
            esac

            # get base height
            baseHeight=0
            for line in $art; do
            	baseHeight=$(( baseHeight + 1 ))
            done

            # add spaces before base so that it's in the middle of the terminal
            iter=1
            for line in $art; do
            	filler='${""}'
            	for (( i=0; i < $(( (cols / 2) - width )); i++)); do
            		filler+=" "
            	done
            	base+="${"$"}{filler}${"$"}{line}"
            	[ $iter -ne $baseHeight ] && base+='\n'
            	iter=$((iter+1))
            done
            unset IFS	# reset delimiter

            rows=$((rows - baseHeight))

            declare -A grid	# must be done outside function for unknown reason

            trap 'echo "press q to quit"' SIGINT	# disable CTRL+C

            init() {
            	branches=0
            	shoots=0

            	branchesMax=$((multiplier * 110))
            	shootsMax=$multiplier

            	# fill grid full of spaces
            	for (( row=0; row < $rows; row++ )); do
            		for (( col=0; col < $cols; col++ )); do
            			grid[$row,$col]=' '
            		done
            	done

            	# No echo stdin and hide the cursor
            	if [ $live = true ]; then
            		stty -echo
            		echo -ne "\e[?25l"

            	 	echo -ne "\e[2J"
            	fi
            }

            grow() {
            	local start=$((cols / 2))

            	local x=$((cols / 2))		# start halfway across the screen
            	local y=$rows	# start just above the base

            	branch $x $y trunk $lifeStart
            }

            branch() {
            	# argument declarations
            	local x=$1
            	local y=$2
            	local type=$3
            	local life=$4
            	local dx=0
            	local dy=0

            	# check if the user is hitting q
            	timeout=0.001
            	[ $live = "false" ] && timeout=.0001
            	read -n 1 -t $timeout input
            	[ "$input" = "q" ] && clean "quit"

            	branches=$((branches + 1))

            	# as long as we're alive...
            	while [ $life -gt 0 ]; do

            		life=$((life - 1))	# ensure life ends

            		# case $life in
            		# 	[0]) type=dead ;;
            		# 	[1-4]) type=dying ;;
            		# esac

            		# set dy based on type
            		case $type in
            			shoot*)	# if this is a shoot, trend horizontal/downward growth
            				case "$((RANDOM % 10))" in
            					[0-1]) dy=-1 ;;
            					[2-7]) dy=0 ;;
            					[8-9]) dy=1 ;;
            				esac
            				;;

            			dying) # discourage vertical growth
            				case "$((RANDOM % 10))" in
            					[0-1]) dy=-1 ;;
            					[2-8]) dy=0 ;;
            					[9-10]) dy=1 ;;
            				esac
            				;;

            			*)	# otherwise, let it grow up/not at all
            				dy=0
            				[ $life -ne $lifeStart ] && [ $((RANDOM % 10)) -gt 2 ] && dy=-1
            				;;
            		esac
            		# if we're about to hit the ground, cut it off
            		[ $dy -gt 0 ] && [ $y -gt $(( rows - 1 )) ] && dy=0
            		[ $type = "trunk" ] && [ $life -lt 4 ] && dy=0

            		# set dx based on type
            		case $type in
            			shootLeft)	# tend left: dx=[-2,1]
            				case $(( RANDOM % 10 )) in
            					[0-1]) dx=-2 ;;
            					[2-5]) dx=-1 ;;
            					[6-8]) dx=0 ;;
            					[9]) dx=1 ;;
            				esac ;;

            			shootRight)	# tend right: dx=[-1,2]
            				case $(( RANDOM % 10 )) in
            					[0-1]) dx=2 ;;
            					[2-5]) dx=1 ;;
            					[6-8]) dx=0 ;;
            					[9]) dx=-1 ;;
            				esac ;;

            			dying)	# tend left/right: dx=[-3,3]
            				dx=$(( (RANDOM % 7) - 3)) ;;

            			*)	# tend equal: dx=[-1,1]
            				dx=$(( (RANDOM % 3) - 1)) ;;

            		esac

            		# re-branch upon conditions
            		if [ $branches -lt $branchesMax ]; then

            			# branch is dead
            			if [ $life -lt 3 ]; then
            				branch $x $y dead $life

            			# branch is dying and needs to branch into leaves
            			elif [ $type = trunk ] && [ $life -lt $((multiplier + 2)) ]; then
            				branch $x $y dying $life

            			elif [[ $type = "shoot"* ]] && [ $life -lt $((multiplier + 2)) ]; then
            				branch $x $y dying $life

            			# re-branch if: not close to the base AND (pass a chance test OR be a trunk, not have too man shoots already, and not be about to die)
            			elif [[ $type = trunk && $life -lt $((lifeStart - 8)) \
            			&& ( $(( RANDOM % (16 - multiplier) )) -eq 0 \
            			|| ($type = trunk && $(( life % 5 )) -eq 0 && $life -gt 5) ) ]]; then

            				# if a trunk is splitting and not about to die, chance to create another trunk
            				if [ $((RANDOM % 3)) -eq 0 ] && [ $life -gt 7 ]; then
            					branch $x $y trunk $life

            				elif [ $shoots -lt $shootsMax ]; then

            					# give the shoot some life
            					tmpLife=$(( life + multiplier - 2 ))
            					[ $tmpLife -lt 0 ] && tmpLife=0

            					# first shoot is randomly directed
            					if [ $shoots -eq 0 ]; then
            						tmpType=shootLeft
            						[ $((RANDOM % 2)) -eq 0 ] && tmpType=shootRight


            					# secondary shoots alternate from the first
            					else
            						case $tmpType in
            							shootLeft) # last shoot was left, shoot right
            								tmpType=shootRight ;;
            							shootRight) # last shoot was right, shoot left
            								tmpType=shootLeft ;;
            						esac
            					fi
            					branch $x $y $tmpType $tmpLife
            					shoots=$((shoots + 1))
            				fi
            			fi
            		else # if we're past max branches but want to branch...
            			char='<>'
            		fi

            		# implement dx,dy
            		x=$((x + dx))
            		y=$((y + dy))

            		# choose color
            		case $type in
            			trunk|shoot*)
            				color=${"$"}{DarkBrown}
            				[ $(( RANDOM % 4 )) -eq 0 ] && color=${"$"}{LightBrown}
            				;;

            			dying) color=${"$"}{BrownGreen} ;;

            			dead) color=${"$"}{Green} ;;
            		esac

            		# choose branch character
            		case $type in
            			trunk)
            				if [ $dx -lt 0 ]; then
            					char='\\'
            				elif [ $dx -eq 0 ]; then
            					char='/|'
            				elif [ $dx -gt 0 ]; then
            					char='/'
            				fi
            				[ $dy -eq 0 ] && char='/~'	# not growing
            				#[ $dy -lt 0 ] && char='/~'	# growing
            				;;

            			# shoots tend to look horizontal
            			shootLeft)
            				case $dx in
            					[-3,-1]) 	char='\\|' ;;
            					[0]) 		char='/|' ;;
            					[1,3]) 		char='/' ;;
            				esac
            				#[ $dy -lt 0 ] && char='/~'	# growing up
            				[ $dy -gt 0 ] && char='/'	# growing down
            				[ $dy -eq 0 ] && char='\\_'	# not growing
            				;;

            			shootRight)
            				case $dx in
            					[-3,-1]) 	char='\\|' ;;
            					[0]) 		char='/|' ;;
            					[1,3]) 		char='/' ;;
            				esac
            				#[ $dy -lt 0 ] && char='${""}'	# growing up
            				[ $dy -gt 0 ] && char='\\'	# growing down
            				[ $dy -eq 0 ] && char='_/'	# not growing
            				;;

            			#dead)
            			#	#life=$((life + 1))
            			#	char="${"$"}{leafchar}"
            			#	[ $dx -lt -2 ] || [ $dx -gt 2 ] && char="${"$"}{leafchar}${"$"}{leafchar}"
            			#	;;

            			esac

            		# set leaf if needed
            		[ $life -lt 4 ] && char="${"$"}{leafchar}"

            		# uncomment for help debugging
            		#echo -e "$life:\t$x, $y: $char"

            		# put character in grid
            		grid[$y,$x]="${"$"}{color}${"$"}{char}${"$"}{R}"

            		# if live, print what we have so far and let the user see it
            		if [ $live = true ]; then
            			print
            			sleep $steptime
            		fi
            	done
            }

            print() {
            	# parse grid for output
            	output=""
            	for (( row=0; row < $rows; row++)); do

            		line=""

            		for (( col=0; col < $cols; col++ )); do

            			# this prints a space at 0,0 and is necessary at the moment
            			[ $live = true ] && echo -ne "\e[0;0H "

            			# grab the character from our grid
            			line+="${"$"}{grid[$row,$col]}"
            		done

            		# add our message
            		if [ $flag_m = true ]; then
            			# remove trailing whitespace before we add our message
            			line=$(sed -r 's/[ \t]*$//' <(printf "$line"))
            			line+="   \t${"$"}{gridMessage[$row]}"
            		fi

            		line="${"$"}{line}\n"

            		# end 'er with the ol' newline
            		output+="$line"
            	done

            	# add the ascii-art base we generated earlier
            	output+="$base"

            	# output, removing trailing whitespace
            	sed -r 's/[ \t]*$//' <(printf "$output")
            }

            clean() {
            	# Show cursor and echo stdin
            	if [ $live = true ]; then
            		echo -ne "\e[?25h"
            		stty echo
            	fi

            	echo ""	# ensure the cursor resets to the next line

            	# if we wanna quit
            	if [ "$1" = "quit" ]; then
            		trap SIGINT
            		exit 0
            	fi
            }

            bonsai() {
            	init
            	grow
            	print
            	clean
            }

            bonsai

            while [ $infinite = true ]; do
            	sleep 2
            	bonsai
            done
          '';
          executable = true;
        };
        "hack-art/chess" = {
          text = ''
            #!/bin/dash

            telnet freechess.org
          '';
          executable = true;
        };
        "hack-art/nvim-logo" = {
          text = ''
            #!/bin/sh
            # neovim logo by @sunjon https://github.com/nvimdev/dashboard-nvim/wiki/Ascii-Header-Text
            # color variations and script by @xero https://git.io/.files
            case "$1" in
            -b) cat << x0
                                                          
                   ███████████           █████      ██
                  ███████████             █████ 
                  ████████████████ ███████████ ███   ███████
                 ████████████████ ████████████ █████ ██████████████
                ██████████████    █████████████ █████ █████ ████ █████
              ██████████████████████████████████ █████ █████ ████ █████
             ██████  ███ █████████████████ ████ █████ █████ ████ ██████
            x0
            ;;
            -o) cat << x0
            [48;5;0m                                              [38;2;167;201;171m
                   [38;2;31;107;152m███████████           [38;2;57;108;63m█████[38;2;167;201;171m      ██
                  [38;2;34;115;163m███████████             [38;2;61;116;68m█████ 
                  [38;2;36;122;174m███████[48;5;0m██[38;2;20;69;110m[38;2;122;187;225m███████ ███[38;2;65;124;72m████████ [38;2;152;192;157m███   ███████
                 [38;2;38;130;184m█████████[38;2;132;191;226m███████[48;5;0m ████[38;2;69;132;76m████████ [38;2;160;196;164m█████ ██████████████
                [38;2;40;138;195m█████████[38;2;142;196;228m█████[48;5;0m[38;2;20;69;110m██[38;2;142;196;228m██████[38;2;73;140;81m███████ [38;2;167;201;171m█████ █████ ████ █████
              [38;2;43;145;206m███████████[38;2;151;200;229m█████████████████[38;2;77;147;86m██████ [38;2;175;205;179m█████ █████ ████ █████
             [38;2;45;153;217m██████  ███ [38;2;160;204;231m█████████████████ [38;2;81;155;90m████ [38;2;183;209;186m█████ █████ ████ ██████
             [38;2;20;69;110m██████   ██  ███████████████   [38;2;46;78;42m██ █████████████████
            [48;2;20;20;40m [38;2;11;39;63m██████   ██  ███████████████   [38;2;25;42;23m██ █████████████████ [48;5;0m
            x0
            ;;
            -t) cat << x0
            [48;5;0m                                              [38;2;167;201;171m                      [48;5;0m
                   [38;2;187;119;68m███████████           [38;2;57;108;63m█████[38;2;167;201;171m      ██                    [48;5;0m
                  [38;2;191;125;71m███████████             [38;2;61;116;68m█████                            [48;5;0m
                  [38;2;193;131;80m███████[48;5;0m██[38;2;92;68;30m[38;2;214;196;131m███████ ███[38;2;65;124;72m████████ [38;2;152;192;157m███   ███████    [48;5;0m
                 [38;2;195;137;80m█████████[38;2;224;200;133m███████[48;5;0m ████[38;2;69;132;76m████████ [38;2;160;196;164m█████ ██████████████  [48;5;0m
                [38;2;197;143;86m█████████[38;2;226;204;134m█████[48;5;0m[38;2;92;68;30m██[38;2;226;204;134m██████[38;2;73;140;81m███████ [38;2;167;201;171m█████ █████ ████ █████  [48;5;0m
              [38;2;199;149;92m███████████[38;2;228;208;136m█████████████████[38;2;77;147;86m██████ [38;2;175;205;179m█████ █████ ████ █████ [48;5;0m
             [38;2;201;155;98m██████  ███ [38;2;230;212;138m█████████████████ [38;2;81;155;90m████ [38;2;183;209;186m█████ █████ ████ ██████
             [38;2;92;68;30m██████   ██  ███████████████   [38;2;46;78;42m██ █████████████████
            [40m                                                                      [0m
            x0
            ;;
            -l) cat << x0
            [0m[40;32m                                                                    [0m
            [40;37m      ███████████            [40;32m█████      ██                    [0m
            [40;37m     ███████████              [40;32m█████                            [0m
            [40;37m     █████████[40;36m[40;37m███████ ███ [40;32m████████ ███   ███████    [0m
            [40;37m    ████████████████ ████ [40;32m████████ █████ ██████████████  [0m
            [40;37m   ██████████████[40;36m██[40;37m██████ [40;32m███████ █████ █████ ████ █████  [0m
            [40;37m ████████████████████████████ [40;32m██████ █████ █████ ████ █████ [0m
            [40;37m██████  ███ █████████████████  [40;32m████ █████ █████ ████ ██████[0m
            [40;36m██████   ██  ███████████████    [40;34m██ █████████████████[0m
            [40m                                                                      [0m
            [0m
            x0
            ;;
            *) cat << x0
             nvim-logo: display cool text mode art banners in your shell/editor
             usage: ./nvim-logo [-t|-l|-b|-h]
             flags:
               -t  display in miasma true colors
               -o  display in origional true colors
               -l  display in limited 256 colors
               -b  display in black and white (text only)
               -h  display this message
             requirements:
              this design uses non-standard characters from NerdFonts (v3)
              please view in a patched font https://www.nerdfonts.com/
             credits:
              neovim logo by @sunjon https://github.com/nvimdev/dashboard-nvim/wiki/Ascii-Header-Text
              color variations and script by @xero https://git.io/.files
            x0
            ;;
            esac
            exit 0
          '';
          executable = true;
        };
        "hack-art/rain" = {
          text = ''
            #!/bin/bash
            # Let it Rain!
            # Copyright (C) 2011, 2013 by Yu-Jie Lin
            #
            # Permission is hereby granted, free of charge, to any person obtaining a copy
            # of this software and associated documentation files (the "Software"), to deal
            # in the Software without restriction, including without limitation the rights
            # to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
            # copies of the Software, and to permit persons to whom the Software is
            # furnished to do so, subject to the following conditions:
            #
            # The above copyright notice and this permission notice shall be included in
            # all copies or substantial portions of the Software.
            #
            # THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
            # IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
            # FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
            # AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
            # LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
            # OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
            # THE SOFTWARE.
            #
            # Blog: http://blog.yjl.im/2013/07/let-it-rain.html
            # Gist: https://gist.github.com/livibetter/5933594
            # Gif : https://lh5.googleusercontent.com/-0WJ1vSZcFPs/UdadOwdPEXI/AAAAAAAAE-c/6kuH9hP3cUo/s800/rain.sh.gif
            # Clip: http://youtu.be/EssRgAh2w_c
            #
            # Modified from falling-<3s.sh:
            # http://blog.yjl.im/2011/02/time-to-have-falling-hearts-screensaver.html

            RAINS=("|" "│" "┃" "┆" "┇" "┊" "┋" "╽" "╿")
            COLORS=("\e[37m" "\e[37;1m")
            # More from 256 color mode
            for i in {244..255}; do
            	COLORS=("${"$"}{COLORS[@]}" "\e[38;5;${"$"}{i}m")
            done
            NRAINS=${"$"}{#RAINS[@]}
            NCOLORS=${"$"}{#COLORS[@]}
            NUM_RAIN_METADATA=5


            sigwinch() {
            	TERM_WIDTH=$(tput cols)
            	TERM_HEIGHT=$(tput lines)
            	STEP_DURATION=0.025
            	((MAX_RAINS = TERM_WIDTH * TERM_HEIGHT / 4))
            	((MAX_RAIN_LENGTH = TERM_HEIGHT < 10 ? 1 : TERM_HEIGHT / 10))
            	# In percentage
            	((NEW_RAIN_ODD = TERM_HEIGHT > 50 ? 100 : TERM_HEIGHT * 2))
            	((NEW_RAIN_ODD = NEW_RAIN_ODD * 75 / 100))
            	((FALLING_ODD = TERM_HEIGHT > 25 ? 100 : TERM_HEIGHT * 4))
            	((FALLING_ODD = FALLING_ODD * 90 / 100))
            }

            do_exit() {
            	echo -ne "\e[${"$"}{TERM_HEIGHT};1H\e[0K"

            	# Show cursor and echo stdin
            	echo -ne "\e[?25h"
            	stty echo
            	exit 0
            }

            do_render() {
            	# Clean screen first
                for ((idx = 0; idx < num_rains * NUM_RAIN_METADATA; idx += NUM_RAIN_METADATA)); do
            			X=${"$"}{rains[idx]}
            			Y=${"$"}{rains[idx + 1]}
            			LENGTH=${"$"}{rains[idx + 4]}
            		for ((y = Y; y < Y + LENGTH; y++)); do
            			(( y < 1 || y > TERM_HEIGHT )) && continue
            					echo -ne "\e[${"$"}{y};${"$"}{X}H "
            		done
            	done

            	for ((idx = 0; idx < num_rains * NUM_RAIN_METADATA; idx += NUM_RAIN_METADATA)); do
            		if ((100 * RANDOM / 32768 < FALLING_ODD)); then
            			# Falling
            			if ((++rains[idx + 1] > TERM_HEIGHT)); then
            				# Out of screen, bye sweet <3
            					rains=("${"$"}{rains[@]:0:idx}"
            					"${"$"}{rains[@]:idx+NUM_RAIN_METADATA:num_rains*NUM_RAIN_METADATA}")
            				((num_rains--))
            				continue
            			fi
            		fi
            		X=${"$"}{rains[idx]}
            		Y=${"$"}{rains[idx + 1]}
            		RAIN=${"$"}{rains[idx + 2]}
            		COLOR=${"$"}{rains[idx + 3]}
            		LENGTH=${"$"}{rains[idx + 4]}
            		for ((y = Y; y < Y + LENGTH; y++)); do
            			(( y < 1 || y > TERM_HEIGHT )) && continue
            				echo -ne "\e[${"$"}{y};${"$"}{X}H${"$"}{COLOR}${"$"}{RAIN}"
            		done
            	done
            }

            trap do_exit TERM INT
            trap sigwinch WINCH
            # No echo stdin and hide the cursor
            stty -echo
            echo -ne "\e[?25l"

            echo -ne "\e[2J"
            rains=()
            sigwinch
            while :; do
            	read -n 1 -t $STEP_DURATION ch
            	case "$ch" in
            		q|Q)
            		do_exit
            		;;
            esac

            if ((num_rains < MAX_RAINS)) && ((100 * RANDOM / 32768 < NEW_RAIN_ODD)); then
            	# Need new |, 1-based
            RAIN="${"$"}{RAINS[NRAINS * RANDOM / 32768]}"
            COLOR="${"$"}{COLORS[NCOLORS * RANDOM / 32768]}"
            	LENGTH=$((MAX_RAIN_LENGTH * RANDOM / 32768 + 1))
            	X=$((TERM_WIDTH * RANDOM / 32768 + 1))
            	Y=$((1 - LENGTH))
            rains=("${"$"}{rains[@]}" "$X" "$Y" "$RAIN" "$COLOR" "$LENGTH")
            	((num_rains++))
            fi

            # Let rain fall!
            do_render
            done
          '';
          executable = true;
        };
        "hack-art/skull" = {
          text = ''
            #!/bin/bash

            f=3 b=4
            for j in f b; do
              for i in {0..7}; do
                printf -v $j$i %b "\e[${"$"}{!j}${"$"}{i}m"
              done
            done
            bld=$'\e[1m'
            rst=$'\e[0m'
            inv=$'\e[7m'


            cat << EOF
            $f4                               ...----....
            $f4                         ..-:"'${""}'         '${""}'"-..
            $f4                      .-'                      '-.
            $f4                    .'              .     .       '.
            $f4                  .'   .          .    .      .    .'${""}'.
            $f4                .'  .    .       .   .   .     .   . ..:.
            $f4              .' .   . .  .       .   .   ..  .   . ....::.
            $f4             ..   .   .      .  .    .     .  ..  . ....:IA.
            $f4            .:  .   .    .    .  .  .    .. .  .. .. ....:IA.
            $f4           .: .   .   ..   .    .     . . .. . ... ....:.:VHA.
            $f4           '..  .  .. .   .       .  . .. . .. . .....:.::IHHB.
            $f4          .:. .  . .  . .   .  .  . . . ...:.:... .......:HIHMM.
            $f4         .:.... .   . ."::"'.. .   .  . .:.:.:II;,. .. ..:IHIMMA
            $f4       ':.:..  ..::IHHHHHI::. . .  ...:.::::.,,,. . ....VIMMHM
            $f4        .:::I. .AHHHHHHHHHHAI::. .:...,:IIHHHHHHMMMHHL:. . VMMMM
            $f4       .:.:V.:IVHHHHHHHMHMHHH::..:" .:HIHHHHHHHHHHHHHMHHA. .VMMM.
            $f4       :..V.:IVHHHHHMMHHHHHHHB... . .:VPHHMHHHMMHHHHHHHHHAI.:VMMI
            $f4       ::V..:VIHHHHHHMMMHHHHHH. .   .I":IIMHHMMHHHHHHHHHHHAPI:WMM
            $f4       ::". .:.HHHHHHHHMMHHHHHI.  . .:..I:MHMMHHHHHHHHHMHV:':H:WM
            $f4       :: . :.::IIHHHHHHMMHHHHV  .ABA.:.:IMHMHMMMHMHHHHV:'. .IHWW
            $f4       '.  ..:..:.:IHHHHHMMHV" .AVMHMA.:.'VHMMMMHHHHHV:' .  :IHWV
            $f4        :.  .:...:".:.:TPP"   .AVMMHMMA.:. "VMMHHHP.:... .. :IVAI
            $f4       .:.   '... .:"'   .   ..HMMMHMMMA::. ."VHHI:::....  .:IHW'
            $f4       ...  .  . ..:IIPPIH: ..HMMMI.MMMV:I:.  .:ILLH:.. ...:I:IM
            $f4     : .   .'"' .:.V". .. .  :HMMM:IMMMI::I. ..:HHIIPPHI::'.P:HM.
            $f4     :.  .  .  .. ..:.. .    :AMMM IMMMM..:...:IV":T::I::.".:IHIMA
            $f4     'V:.. .. . .. .  .  .   'VMMV..VMMV :....:V:.:..:....::IHHHMH
            $f4       "IHH:.II:.. .:. .  . . . " :HB"" . . ..PI:.::.:::..:IHHMMV"
            $f4        :IP""HHII:.  .  .    . . .'V:. . . ..:IH:.:.::IHIHHMMMMM"
            $f4        :V:. VIMA:I..  .     .  . .. . .  .:.I:I:..:IHHHHMMHHMMM
            $f4        :"VI:.VWMA::. .:      .   .. .:. ..:.I::.:IVHHHMMMHMMMMI
            $f4        :."VIIHHMMA:.  .   .   .:  .:.. . .:.II:I:AMMMMMMHMMMMMI
            $f4        :..VIHIHMMMI...::.,:.,:!"I:!"I!"I!"V:AI:VAMMMMMMHMMMMMM'
            $f4        ':.:HIHIMHHA:"!!"I.:AXXXVVXXXXXXXA:."HPHIMMMMHHMHMMMMMV
            $f4          V:H:I:MA:W'I :AXXXIXII:IIIISSSSSSXXA.I.VMMMHMHMMMMMM
            $f4            'I::IVA ASSSSXSSSSBBSBMBSSSSSSBBMMMBS.VVMMHIMM'"'
            $f4             I:: VPAIMSSSSSSSSSBSSSMMBSSSBBMMMMXXI:MMHIMMI
            $f4            .I::. "H:XIIXBBMMMMMMMMMMMMMMMMMBXIXXMMPHIIMM'
            $f4            :::I.  ':XSSXXIIIIXSSBMBSSXXXIIIXXSMMAMI:.IMM
            $f4            :::I:.  .VSSSSSISISISSSBII:ISSSSBMMB:MI:..:MM
            $f4            ::.I:.  ':"SSSSSSSISISSXIIXSSSSBMMB:AHI:..MMM.
            $f4            ::.I:. . ..:"BBSSSSSSSSSSSSBBBMMMB:AHHI::.HMMI
            $f4            :..::.  . ..::":BBBBBSSBBBMMMB:MMMMHHII::IHHMI
            $f4            ':.I:... ....:IHHHHHMMMMMMMMMMMMMMMHHIIIIHMMV"
            $f4              "V:. ..:...:.IHHHMMMMMMMMMMMMMMMMHHHMHHMHP'
            $f4               ':. .:::.:.::III::IHHHHMMMMMHMHMMHHHHM"
            $f4                 "::....::.:::..:..::IIIIIHHHHMMMHHMV"
            $f4                   "::.::.. .. .  ...:::IIHHMMMMHMV"
            $f4                     "V::... . .I::IHHMMV"'
            $f4                       '"VHVHHHAHHHHMMV:"'

            $rst

            EOF

          '';
          executable = true;
        };
        "hack-art/skullmono.sh" = {
          text = ''
            #!/bin/sh
            echo '                      :::!~!!!!!:.'
            echo '                  .xUHWH!! !!?M88WHX:.'
            echo '                .X*#M@$!!  !X!M$$$$$$WWx:.'
            echo '               :!!!!!!?H! :!$!$$$$$$$$$$8X:'
            echo '              !!~  ~:~!! :~!$!#$$$$$$$$$$8X:'
            echo '             :!~::!H!<   ~.U$X!?R$$$$$$$$'
            echo '             ~!~!!!!~~ .:XW$$$U!!?$$$$$$RMM!'
            echo '               !:~~~ .:!M"T#$$$$WX??#MRRMMM!'
            echo '               ~?WuxiW*`   `"#$$$$8!!!!??!!!'
            echo '             :X- M$$$$       `"T#$T~!8$WUXU~'
            echo '            :%`  ~#$$$m:        ~!~ ?$$$$$$'
            echo '          :!`.-   ~T$$$$8xx.  .xWW- ~""##*"'
            echo '....   -~~:<` !    ~?T#$$@@W@*?$$    /`'
            echo 'W$@@M!!! .!~~ !!     .:XUW$W!~ `"~:    :'
            echo '#"~~`.:x%`!!  !H:   !WM$$$$Ti.: .!WUn+!`'
            echo ':::~:!!`:X~ .: ?H.!u "$$$B$$$!W:U!T$$M~'
            echo '.~~   :X@!.-~   ?@WTWo("*$$$W$TH$! `'
            echo 'Wi.~!X$?!-~    : ?$$$B$Wu("**$RM!'
            echo '$R@i.~~ !     :   ~$$$$$B$$en:``'
            echo '?MXT@Wx.~    :     ~"##*$$$$M~'
          '';
          executable = true;
        };
        "hack-art/skulls" = {
          text = ''
            #!/bin/sh
            #
            #  ┳━┓┳━┓0┏┓┓┳━┓┏━┓┓ ┳
            #  ┃┳┛┃━┫┃┃┃┃┃━┃┃ ┃┃┃┃
            #  ┃┗┛┛ ┃┃┃┗┛┻━┛┛━┛┗┻┛
            #     ┳━┓┳ ┓┳┏ ┳━┓
            #     ┃━┛┃ ┃┣┻┓┣━
            #     ┇  ┗━┛┃ ┛┻━┛
            #    ┓━┓┳┏ ┳ ┓┳  ┳
            #    ┗━┓┣┻┓┃ ┃┃  ┃
            #    ━━┛┇ ┛┗━┛┗━┛┗━┛
            #
            # the worst color script
            # by xero <http://0w.nz>

            cat << 'EOF'
            \u001b[1;37;40m                  .................
            \u001b[1;37;40m             .syhhso++++++++/++osyyhys+.
            \u001b[1;37;40m          -oddyo+o+++++++++++++++o+oo+osdms:
            \u001b[1;37;40m        :dmyo++oosssssssssssssssooooooo+/+ymm+`
            \u001b[1;37;40m       hmyo++ossyyhhddddddddddddhyyyssss+//+ymd-
            \u001b[1;37;40m     -mho+oosyhhhddmmmmmmmmmmmmmmddhhyyyso+//+hN+
            \u001b[1;37;40m     my+++syhhhhdmmNNNNNNNNNNNNmmmmmdhhyyyyo//+sd:
            \u001b[1;37;40m    hs//+oyhhhhdmNNNNNNNNNNNNNNNNNNmmdhyhhhyo//++y
            \u001b[1;37;40m    s+++shddhhdmmNNNNNNNNNNNNNNNNNNNNmdhhhdhyo/++/
            \u001b[1;37;40m    'hs+shmmmddmNNNNNNNNNNNNNNNNNNNNNmddddddhs+oh/
            \u001b[1;37;40m     shsshdmmmmmNNMMMMMMMMMMMNNNNNNNNmmmmmmdhssdh-
            \u001b[1;37;40m      +ssohdmmmmNNNNNMMMMMMMMNNNNNNmmmmmNNmdhhhs:`
            \u001b[1;37;40m  -+oo++////++sydmNNNNNNNNNNNNNNNNNNNdyyys/--://+//:
            \u001b[1;37;40m  d/+hmNNNmmdddhhhdmNNNNNNNNNNNNNNNmdhyyyhhhddmmNmdyd-
            \u001b[1;37;40m  ++--+ymNMMNNNNNNmmmmNNNNNNNNNNNmdhddmNNMMMMMMNmhyss
            \u001b[1;37;40m   /d+` -+ydmNMMMMMMNNmNMMMMMMMmmmmNNMMMMMNNmh- :sdo
            \u001b[1;37;40m    sNo   ` /ohdmNNMMMMNNMMMMMNNNMMMMMNmdyo/ `  hNh
            \u001b[1;37;40m     M+'     ``-/oyhmNNMNhNMNhNMMMMNmho/ `     'MN/
            \u001b[1;37;40m     d+'         `-+osydh0w.nzmNNmho:          'mN:
            \u001b[1;37;40m    +o/             ` :oo+:s :+o/-`            -dds
            \u001b[1;37;40m   :hdo       \u001b[0;31;40mx\u001b[1;37;40m    `-/ooss:':+ooo: `    \u001b[0;31;40m0\u001b[1;37;40m      :sdm+
            \u001b[1;37;40m  +dNNNh+         :ydmNNm'   `sddmyo          +hmNmds
            \u001b[1;37;40m dhNMMNNNNmddhsyhdmmNNNM:      NNmNmhyo+oyyyhmNMMNmysd
            \u001b[1;37;40m ydNNNNNh+/++ohmMMMMNMNh       oNNNNNNNmho++++yddhyssy
            \u001b[1;37;40m              `:sNMMMMN'       `mNMNNNd/`
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mX\u001b[1;37;40m y/hMMNm/  .dXb.  -hdmdy: ` \u001b[0;34;40mXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;37;40m `o+hNNds. -ymNNy-  .yhys+/`` \u001b[0;34;40mXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;37;40m +-+//o/+odMNMMMNdmh++////-/s \u001b[0;34;40mXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXX\u001b[1;37;40m mhNd -+d/+myo++ysy/hs -mNsdh/ \u001b[0;34;40mXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;37;40m mhMN+ dMm-/-smy-::dMN/sMMmdo \u001b[0;34;40mXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXX\u001b[1;37;40m NMy+NMMh oMMMs yMMMyNMMs+ \u001b[0;34;40mXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXX\u001b[1;37;40m dy-hMMm+dMMMdoNMMh ydo \u001b[1;34;40mX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mX \u001b[1;37;40m smm 'NMMy dms  sm  \u001b[1;34;40mXX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mXX                   \u001b[1;34;40mXXX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mXXXX\u001b[1;35;40mXXXX\u001b[0;35;40mXXXX\u001b[1;32;40mXXXX\u001b[0;32;40mXXXX\u001b[1;34;40mXXXX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mXXXX\u001b[1;35;40mXXXX\u001b[0;35;40mXXXX\u001b[1;32;40mXXXX\u001b[0;32;40mXXXX\u001b[1;34;40mXXXX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mXXXX\u001b[1;35;40mXXXX\u001b[0;35;40mXXXX\u001b[1;32;40mXXXX\u001b[0;32;40mXXXX\u001b[1;34;40mXXXX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mXXXX\u001b[1;35;40mXXXX\u001b[0;35;40mXXXX\u001b[1;32;40mXXXX\u001b[0;32;40mXXXX\u001b[1;34;40mXXXX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mXXXX\u001b[1;35;40mXXXX\u001b[0;35;40mXXXX\u001b[1;32;40mXXXX\u001b[0;32;40mXXXX\u001b[1;34;40mXXXX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mXXXX\u001b[1;35;40mXXXX\u001b[0;35;40mXXXX\u001b[1;32;40mXXXX\u001b[0;32;40mXXXX\u001b[1;34;40mXXXX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mXXXX\u001b[1;35;40mXXXX\u001b[0;35;40mXXXX\u001b[1;32;40mXXXX\u001b[0;32;40mXXXX\u001b[1;34;40mXXXX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mXXXX\u001b[1;35;40mXXXX\u001b[0;35;40mXXXX\u001b[1;32;40mXXXX\u001b[0;32;40mXXXX\u001b[1;34;40mXXXX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mXXXX\u001b[1;35;40mXXXX\u001b[0;35;40mXXXX\u001b[1;32;40mXXXX\u001b[0;32;40mXXXX\u001b[1;34;40mXXXX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mXXXX\u001b[1;35;40mXXXX\u001b[0;35;40mXXXX\u001b[1;32;40mXXXX\u001b[0;32;40mXXXX\u001b[1;34;40mXXXX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mXXXX\u001b[1;35;40mXXXX\u001b[0;35;40mXXXX\u001b[1;32;40mXXXX\u001b[0;32;40mXXXX\u001b[1;34;40mXXXX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mXXXX\u001b[1;35;40mXXXX\u001b[0;35;40mXXXX\u001b[1;32;40mXXXX\u001b[0;32;40mXXXX\u001b[1;34;40mXXXX\u001b[0;34;40mXXXX\u001b[1;37;40mXXXX
                \u001b[1;31;40mXXXX\u001b[0;31;40mXXXX\u001b[1;33;40mXXXX\u001b[0;33;40mXXXX\u001b[1;35;40mXXXX\u001b[0;35;40mXXXX\u001b[1;32;40mXXXX\u001b[0;32;40mXXXX\u001b[1;34;40mXXXX\u001b[0;34;40mXXXX\u001b[1;37;40mXER0

            EOF
          '';
          executable = true;
        };
        "hack-art/skull.txt" = {
          text = ''
            `$,a$'        $                   ,aaaa$""  $$$$$$$$$$$aaa,         '$
              $'          `a$            ,aa$""   aa"aa$$$"$$$$$$$$$$$$$aa       '$,
            ,$'             ;          a$$$" aa$$$a   $$a$$$$$$l$$$$"$" ""$a       $
            $    ,a"$       $        a$$$"a$$$"$$$ $$ "aa""aa""$ $"$$a a"$  ",     $
            $' ,$"  `     ,$'    $  $"$$$$"$$$$$ $$a  "aa$ a a""" a$a " $$     $
            $  $          $a   a'  $$$$$$$$$$""""$$$$$ia$$$$$,1$$$$a$$$$$$$a1$$   $'
            ',$'     ,a$a   `a    $$$$$$$$$aa$$$$a  ""$$$$$$$"$$ l$$'$$$$$$$a$$$ $'
             $    ,a"    `a'  `  ,$$$$$$$$$$$$$$$$$,   """"$$$$$$a$$$$`$$$$$$$$$,
            $' ,$"               $$$$$$$$"$$$$$$$$$" a$$$$$aa`"$$$""$;$$$$$"aa$a
            `,a" $    a,$        $$$$$$$$$$$$"$$$$$ a$$$$$"""$$aa`$$a$$ $$""a$$$$$$
            a'    "a$'   `a$     $$$$$$$$$$'   ""' a$$$"       "$$a`$"" aa$$$"$$$$'
            $              $      "$$$$"""'      a$$$$           `$$$a"$$$$"a"  "
            $.            'a       a"$a$$"  a  $$$$$$'             `""$$$$'
            `$'$            $      1  $$" a$$   $$$$$               a$$"
            `$,`$            `a   ,`$  $  "$$a   $$$$$             $$$'           ,
             `$ `             $   $ `$  $$" aaa  "$$$$$a          $$$'           a1
             ,$               `$a'    " 1a$$$$$$$aaa"""$$$$$$$aa $$$l     laaaa""$a
            .$'                          $    `"""$aa$$$$$$$$$$"$$$$$     $$$aa$$"
            $'                           `"aaa""$$$" $$$$$$$$" "$a1$$  a  $$$$$$'
            $                                "" z`""  $""""     1$$$a$$$$$"$$"'
            `a     a'                                 $$$aa  a$al$$$$$$$a$'
              `a,aa,"                                 a"" $$,$$$"l$$"$$"$ $
                                                       $" a""aa",a $"aa""a" a
                                                       ' ,`$ "$$l $$$ $$"$"
                                                               " `$  `$ $' `
                                                                  '   `
          '';
        };
        "hack-art/zalgo" = {
          text = ''
            #!/usr/bin/env python3
            # Read from stdin and Zalgo-ify
            # By MetroWind <chris.corsair {AT} gmail>

            import sys
            import random

            # Characters taken from http://str.blogsite.org/Zalgo.htm.
            CHAR_UP = ['\u030D', '\u030E', '\u0304', '\u0305', '\u033F',
                       '\u0311', '\u0306', '\u0310', '\u0352', '\u0357',
                       '\u0351', '\u0307', '\u0308', '\u030A', '\u0342',
                       '\u0343', '\u0344', '\u034A', '\u034B', '\u034C',
                       '\u0303', '\u0302', '\u030C', '\u0350', '\u0300',
                       '\u0301', '\u030B', '\u030F', '\u0312', '\u0313',
                       '\u0314', '\u033D', '\u0309', '\u0363', '\u0364',
                       '\u0365', '\u0366', '\u0367', '\u0368', '\u0369',
                       '\u036A', '\u036B', '\u036C', '\u036D', '\u036E',
                       '\u036F', '\u033E', '\u035B', '\u0346', '\u031A']

            CHAR_MID = ['\u0315', '\u031B', '\u0340', '\u0341', '\u0358',
                        '\u0321', '\u0322', '\u0327', '\u0328', '\u0334',
                        '\u0335', '\u0336', '\u034F', '\u035C', '\u035D',
                        '\u035E', '\u035F', '\u0360', '\u0362', '\u0338',
                        '\u0337', '\u0361', '\u0489']

            CHAR_DOWN = ['\u0316', '\u0317', '\u0318', '\u0319', '\u031C',
                         '\u031D', '\u031E', '\u031F', '\u0320', '\u0324',
                         '\u0325', '\u0326', '\u0329', '\u032A', '\u032B',
                         '\u032C', '\u032D', '\u032E', '\u032F', '\u0330',
                         '\u0331', '\u0332', '\u0333', '\u0339', '\u033A',
                         '\u033B', '\u033C', '\u0345', '\u0347', '\u0348',
                         '\u0349', '\u034D', '\u034E', '\u0353', '\u0354',
                         '\u0355', '\u0356', '\u0359', '\u035A', '\u0323']

            ZALGO_POS = ("up", "mid", "down")
            ZALGO_CHARS = {"up": CHAR_UP, "mid": CHAR_MID, "down": CHAR_DOWN}

            random.seed()


            def randStr(charset, count, allow_repeat=True, return_list=True):
                """Randomly chooses a subset with `count' number of characters
                from `charset', and returns the resulting string.  If
                `allow_repeat' is False, a permutation is chosen.  If
                `return_list' is True, a list of chars is returned, otherwise a
                string is returned.
                """
                Result = list()
                if allow_repeat:
                    for i in range(count):
                        Result.append(random.choice(charset))
                else:
                    Result = random.sample(charset, count)
                    random.shuffle(Result)

                if return_list:
                    return Result
                else:
                    return '${""}'.join(Result)


            def zalgo(orig_str, intensities, excludes=(' '), rand_intensity=True,
                      allow_repeat=True):
                """Zalgo-ify `orig_str'.  `Intensityies' is a dict in the form of
                {\"up\": intense_up, \"mid\": intense_mid, \"down\":
                intense_down}.  \"Intense_up\" denotes the intensity of the
                up-going zalgo chars, etc.  If `rand_intensity' is False,
                \"intense_up\" number of up-going zalgo chars are used, etc.  If
                `rand_intensity' is True, a random number (but less than
                \"intense_up\") of up-going zalgo chars are used, etc.  If
                `allow_repeat' is True, repeating zalgo chars on one char in
                `orig_str' is possible.  Characters in `excludes' will not be
                zalgo-ified.
                """
                Result = []
                for OrigChar in orig_str:
                    if OrigChar in excludes:
                        Result.append(OrigChar)
                    else:
                        ZalgoCounts = {"up": 0, "down": 0, "mid": 0}
                        for pos in ZALGO_POS:
                            if rand_intensity:
                                ZalgoCounts[pos] = random.randint(0, intensities[pos])
                            else:
                                ZalgoCounts[pos] = intensities[pos]

                        Result.append(OrigChar)

                        for pos in ZALGO_POS:
                            Result += randStr(
                                ZALGO_CHARS[pos], ZalgoCounts[pos], allow_repeat
                            )

                return '${""}'.join(Result)


            def main():
                Usage = "Usage: %prog [options]"

                import optparse
                OptParser = optparse.OptionParser(usage=Usage)

                OptParser.add_option("-u", "--up-intensity", dest="IntenseUp", default=2,
                                     type="int", metavar="NUM",
                                     help="The number of Zalgo characters to put above"
                                     "the original character.  Default: %default")
                OptParser.add_option("-m", "--mid-intensity", dest="IntenseMid", default=1,
                                     type="int", metavar="NUM",
                                     help="The number of Zalgo characters to put at"
                                     "the original character.  Default: %default")
                OptParser.add_option("-d", "--down-intensity", dest="IntenseDown", default=5,
                                     type="int", metavar="NUM",
                                     help="The number of Zalgo characters to put below"
                                     "the original character.  Default: %default")
                OptParser.add_option("-f", "--fix-intensity", dest="Random",
                                     default=True, action="store_false",
                                     help="Don’t randomize the intensity.")
                OptParser.add_option("-e", "--excludes", dest="Excludes",
                                     default=' ', metavar="STR",
                                     help="Don’t Zalgo-ify characters in STR. "
                                     "Default: \"%default\"")

                (Opts, Args) = OptParser.parse_args()

                Intense = {"up": Opts.IntenseUp, "mid": Opts.IntenseMid,
                           "down": Opts.IntenseDown}

                for Line in sys.stdin:
                    print(zalgo(Line, Intense, tuple(Opts.Excludes), Opts.Random))
                return 0


            if __name__ == "__main__":
                sys.exit(main())

          '';
          executable = true;
        };

        # fantasy-art files
        "fantasy-art/gandalf.txt" = {
          text = ''
            ⠀⠀⠀⠀⠀⠀⢀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⢀⠎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⢀⣾⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠤⠶⢶⣿⣿⣿⣿⣯⣴⣖⣤⡀⠀⠀⠀⠀⠀⠀⠀⣠⠔⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⣼⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⢉⢤⣶⣶⣶⣾⣝⢯⢿⣯⠿⠽⢿⣾⣷⣦⣤⣤⣤⡤⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⢠⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠊⣐⣼⣯⣿⣿⣿⣿⣿⢿⢯⠉⠀⠀⠀⠈⠉⠉⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⣸⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠃⢊⣭⣽⣿⣿⣿⣿⣿⣿⣯⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠻⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠠⠷⠟⠋⠉⠉⠉⠛⠛⠛⠛⠿⠿⣶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠰⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⣠⣤⣴⣶⣬⣥⣴⣶⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣾⣧⣴⣄⣤⡀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⣿⣷⠀⠀⠀⠀⠀⠀⠀⢰⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠸⣿⣆⠀⠀⠀⠀⠀⠀⠀⠈⠉⠛⠻⠿⠿⣿⣿⣿⣿⣿⣗⢿⡻⢻⣿⣿⣿⣿⡿⣻⣿⣮⣵⢼⡿⠿⠟⠛⠛⠉⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⢻⣿⣶⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠉⠉⣽⣿⣿⡌⣽⣾⣿⣿⣿⣿⣷⣿⣿⢻⣿⣿⡇⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⢿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣶⠛⡟⡇⣉⣾⣿⣏⡹⢿⣿⡿⣿⣾⢸⣿⢸⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⡁⠅⡜⣼⠿⡹⠹⢻⣯⣏⢿⣿⣏⢻⢨⣿⡻⣮⡭⡐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⡮⣪⢨⣙⠃⡰⢠⠇⡶⠩⠛⡆⠎⢻⡄⣬⣿⣿⣿⣟⠾⣰⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠘⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢄⣾⡕⡗⠁⣠⠁⡟⠆⡇⢀⡇⢧⠘⠜⣧⣿⣿⣿⣿⣿⣝⡺⣄⡧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⢿⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⢰⡿⠿⠐⡌⢰⠙⢄⣷⢸⣷⠏⣷⢸⢴⣧⣿⣿⣿⣿⣿⣿⣿⣿⣶⣝⠀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⢰⣿⡇⠀⠀⠀⠀⠀⠀⠀⠠⠋⢴⣿⢻⣇⣷⠃⡿⠀⡛⡿⢸⠛⣿⣿⣼⣿⣹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡱⣴⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠘⣿⣧⠀⠀⠀⠀⠀⠀⠰⠁⣸⣿⣿⡜⢬⡇⡐⢠⠱⠰⣷⡜⢰⠟⣸⢸⢩⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡹⡖⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⢿⣿⡀⠀⠀⠀⠀⠀⢷⢰⣿⣿⡿⢁⡜⡔⠰⠜⡇⢸⠇⡎⡆⢸⡟⣷⣿⣿⣿⣿⣯⣿⣿⣿⣿⣿⣿⣿⣿⣧⢿⢁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣇⠀⠀⠀⠀⠰⣸⢸⣿⣿⡵⡾⢽⡀⣦⠐⡏⣿⡆⢰⣇⣿⣿⣿⣿⣿⣿⣿⣿⡾⣿⣿⣿⣿⣿⣿⣿⣷⡺⣏⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⣆⣀⣹⣯⣸⣅⠀⢀⢂⣿⢸⣿⡿⣿⢧⣟⢻⣏⢦⣿⣿⡇⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣧⢿⣁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠰⣥⣬⣽⣿⣟⣯⡄⡰⡾⣿⢸⣿⡇⣿⣼⣿⡘⡏⣾⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣟⣿⣿⣿⣿⣿⣿⣿⣿⣼⣟⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠶⠶⢶⣿⣿⣿⣿⣾⣙⣿⣸⣿⡇⣿⣿⣿⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠈⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣏⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⢹⣿⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡞⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⡼⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⢀⠄⠄⠤⣤⠀⣀⠀⠀⠀⠀⠀⠀⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⢸⡅⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⣨⠌⠉⠰⠸⡦⣰⣼⢇⠳⢢⠄⠀⣀⣠⠞⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⢀⣇⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⢁⠂⠉⠁⠀⠀⢒⣾⠏⠁⠀⠈⠁⠀⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠘⢿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣐⣥⡕⠫⢓⣀⢀⠀⠠⣞⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠘⡎⡄⠀⠀⠀⠀⠀⠀⠀⠀⢀⡀⢠⣄⠂⠀⠭⠤⠀⠀⠀⠀⠀⠀⠈⠬⠗⠠⣄⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⢇⣇⠀⠀⠀⠀⠀⢰⡚⠉⠁⠀⠀⠀⠀⠀⢀⡀⢀⠀⠀⠀⢀⠀⡤⡠⠀⠀⠀⠀⠈⠉⢓⠦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠘⣜⡀⠀⠀⠀⠀⠀⠈⠁⠐⠂⠀⠤⠤⢠⢽⠫⠚⣀⠀⠀⢸⣁⡿⢦⡰⠆⠐⠂⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠘⡞⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠐⡻⠹⡇⣉⣿⣒⠠⣼⣞⡧⡟⢿⠣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⣇⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢐⡨⡰⢼⢋⢪⠻⣟⡝⣺⣏⠇⣲⢿⣭⣁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⣿⢰⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⣡⢢⡋⠁⢂⠆⠛⢡⢸⢀⢹⠠⠗⠰⠥⡽⣪⡢⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⢸⡜⠀⠀⠀⠀⠀⠀⠀⠀⡰⣱⠗⢘⢀⠎⢸⡄⣔⣌⡄⣆⣽⠏⠈⠀⠀⠈⠈⡑⡢⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠈⡅⡆⠀⠀⠀⠀⠀⡠⠫⡞⢿⢇⠟⠈⠀⢿⠃⠛⣾⡧⣹⡛⠀⡄⠀⠀⠀⠀⠈⢜⢆⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⣵⢃⠀⠀⠀⠀⢰⢀⠎⠀⡘⢚⠠⣠⡌⡸⠓⠐⢉⣧⡑⠀⠀⢳⠀⠀⠀⠀⠀⠀⠎⡗⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⢸⡸⡀⠀⠀⠀⣤⠈⠀⣰⣰⣓⢡⠀⡇⡟⢸⡀⡎⡜⠀⠀⠀⠈⣇⠀⠀⠀⠀⠀⠹⢹⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⢀⣒⡻⢇⣴⠀⠠⡌⠀⠀⡟⣧⣯⣴⣄⣷⢹⢸⡥⡆⠁⠀⠀⠀⠀⠸⡄⠀⠀⠀⠀⠀⠊⠹⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠒⠖⢋⠘⣿⣦⢷⣧⠐⠀⢸⠟⠿⣹⣘⠆⢸⢿⠁⠀⠀⠀⠀⡀⠀⠀⢧⠀⠀⠀⠀⠀⢘⠛⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠘⣴⠶⠂⣙⠛⠙⠳⣄⠀⢸⠀⠀⠈⣅⠀⠈⠀⠀⠀⠀⠀⠀⡀⠀⠀⠘⠆⠀⠀⢀⠀⠘⠋⢣⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⢘⠀⠀⢩⡀⠀⠀⢹⠀⢸⠀⠀⢲⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⠀⠀⠀⢱⠀⠀⢸⡀⠀⠛⠸⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⢸⠀⠀⠈⠇⠀⠀⢸⠀⣾⡄⠀⠸⠀⠀⠀⠀⠀⠀⠀⠀⠀⢨⠀⠀⠀⠈⡃⠀⠀⡅⠀⢰⠇⢇⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⢸⠀⢸⠀⠁⠀⠀⠀⠀⡏⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡀⠀⠀⠀⢙⠀⠀⠙⠀⠀⡴⠰⡀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⢸⠀⢠⠀⢧⠀⠀⠀⠀⢆⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠈⠃⠀⢠⡇⠀⢠⡆⢦⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠸⡆⠸⡆⠸⠄⠀⠀⠀⠐⠃⠀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠀⢤⠈⢠⠀⠀⠦⠘⠄⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⡇⠀⠶⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠐⠆⠈⠀⠀⠐⠄⢑⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⢆⠀⠘⢁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠃⡞⠈⠇⠀⠀⠛⠈⠧⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠘⡀⠀⢾⡀⠀⠀⠀⠀⠃⠀⠀⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠃⢰⡆⠳⠀⠀⠀⠀⠈⠦⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⡅⠀⢸⡄⠀⠀⠀⠀⠀⠀⠀⢹⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠁⠀⠀⠀⠀⠀⠀⠈⢅⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠠⠇⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠡⡀⠀⠀
            ⠀⠀⠀⠀⠀⡠⠎⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠘⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢤⣠⣮⣄⠀
            ⠠⠤⠄⠈⠙⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⣆⡁⠈⠃
            ⢀⣈⡹⢤⡔⢀⢀⣀⢀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡤⢠⡠⠠⠀⠀⠤⠦⠞⠈⠁⠉⠀⠀
            ⠈⠀⠀⠀⣀⠤⠂⠈⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⡀⠀⠀⠀⠀⠀⣛⠁⠳⠦⠀⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠐⠊⠉⢉⣡⠝⠡⠄⠐⢒⡒⠦⠚⠀⠀⠀⠀⠀⠀⠀⡀⠀⢀⡠⠩⠑⠲⠮⠍⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠄⠐⠊⠓⣐⠶⠆⠤⢐⣠⡔⣀⡀⠀⠀⠀⠁⠒⠀⠉⠛⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
          '';
        };
        "fantasy-art/helmet.txt" = {
          text = ''
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣾⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀⠀
            ⠀⢀⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀
            ⠀⢸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀
            ⠀⣸⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀
            ⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀
            ⠀⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀
            ⠀⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀
            ⢠⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⠀
            ⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣸⣿⠀
            ⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⣿⣇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⠀
            ⢸⣿⡇⠀⠀⠀⠀⠀⠀⠀⣀⣠⣤⣶⣾⣿⣿⣿⣿⣶⣦⣤⣀⡀⠀⠀⠀⠀⠀⠀⠀⣿⣿⡇
            ⢸⣿⣀⠀⠀⠀⠀⣠⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⣦⣀⠀⠀⠀⠀⣿⣿⡇
            ⢸⣿⣿⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡀⠀⢰⢹⣿⡇
            ⣿⣿⡟⡄⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⢸⣾⣿⡇
            ⠛⣿⣿⣧⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣾⣿⣿⡇
            ⢸⣽⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣯⠁
            ⠈⣻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣽⠀
            ⠀⣷⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡇⠀
            ⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠃⠀
            ⠀⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀
            ⠀⢸⣿⣿⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⣿⣿⠀⠀
            ⠀⢨⣿⣿⢸⣿⣿⣭⡛⠻⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠛⣩⣿⣿⣿⣷⣿⣿⠀⠀
            ⠀⠀⣿⣿⢿⣿⣿⣿⣿⣷⣦⣤⣍⣻⣿⣿⣿⣿⣿⣿⣭⣤⣤⣶⣿⣿⣿⣿⣿⣿⣿⡿⠀⠀
            ⠀⠀⣿⣿⣧⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⡏⣿⣿⣿⠀⠀
            ⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣇⣿⣿⡿⠀⠀
            ⠀⠀⠸⣿⣿⣿⣿⣿⣿⣿⠟⣿⢿⣿⣿⣿⣿⣿⣿⣿⠟⡽⡇⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀
            ⠀⠀⠀⢹⣿⣽⣿⣿⣿⣿⡇⣿⣇⢻⣿⣿⣿⣿⣿⣿⠋⣾⡇⠾⣿⣿⣟⣿⣿⣿⠋⠀⠀⠀
            ⠀⠀⠀⠀⢿⣽⠇⢸⣿⣿⣷⣿⢻⠀⣿⣿⣿⣿⣿⠇⠰⣸⣷⣿⣿⡟⡍⢻⣿⡏⠀⠀⠀⠀
            ⠀⠀⠀⠀⠘⣿⣷⠀⢹⣿⣿⣿⢸⠀⢸⣿⣿⣿⣿⠀⢸⣾⣿⣿⣿⡇⠁⢿⡿⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⢸⣷⠀⢘⢻⣿⣿⢸⠀⢸⣿⣿⣿⡟⠀⢸⢾⣿⣿⣿⠀⠠⣿⠃⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠈⣿⡀⠈⢸⣿⣿⣼⠀⠈⣿⣿⣿⡇⠀⢈⢿⣿⣿⠻⠀⢰⡟⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠘⡇⠀⠘⣿⣿⣿⠀⠀⣿⣿⣿⡇⠀⢘⣾⣿⣿⠀⠀⢸⠁⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⢁⠀⠀⣿⣿⣹⠀⠀⣿⣿⣿⡇⠀⢸⣹⣿⡇⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠘⠂⠀⢹⣿⣾⠀⠀⣿⣿⣿⡇⠀⢸⣾⣿⠇⠀⠘⠂⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢈⢿⣧⠄⠀⢹⣿⣿⠁⠀⢈⣿⡟⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⡟⢀⠀⢸⣿⣿⠀⠀⠸⡿⠏⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⢇⠀⢸⣿⣿⠀⠀⢶⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⢏⠀⢸⣿⣿⠀⠀⡌⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠄⢸⣿⣿⠀⠐⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⣿⣿⠂⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢿⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢘⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
          '';
        };
        "fantasy-art/hydra.txt" = {
          text = ''



              ⣴⣶⣤⡤⠦⣤⣀⣤⠆     ⣈⣭⣿⣶⣿⣦⣼⣆
               ⠉⠻⢿⣿⠿⣿⣿⣶⣦⠤⠄⡠⢾⣿⣿⡿⠋⠉⠉⠻⣿⣿⡛⣦
                     ⠈⢿⣿⣟⠦ ⣾⣿⣿⣷    ⠻⠿⢿⣿⣧⣄
                      ⣸⣿⣿⢧ ⢻⠻⣿⣿⣷⣄⣀⠄⠢⣀⡀⠈⠙⠿⠄
                     ⢠⣿⣿⣿⠈    ⣻⣿⣿⣿⣿⣿⣿⣿⣛⣳⣤⣀⣀
              ⢠⣧⣶⣥⡤⢄ ⣸⣿⣿⠘  ⢀⣴⣿⣿⡿⠛⣿⣿⣧⠈⢿⠿⠟⠛⠻⠿⠄
             ⣰⣿⣿⠛⠻⣿⣿⡦⢹⣿⣷   ⢊⣿⣿⡏  ⢸⣿⣿⡇ ⢀⣠⣄⣾⠄
            ⣠⣿⠿⠛ ⢀⣿⣿⣷⠘⢿⣿⣦⡀ ⢸⢿⣿⣿⣄ ⣸⣿⣿⡇⣪⣿⡿⠿⣿⣷⡄
            ⠙⠃   ⣼⣿⡟  ⠈⠻⣿⣿⣦⣌⡇⠻⣿⣿⣷⣿⣿⣿ ⣿⣿⡇ ⠛⠻⢷⣄
                 ⢻⣿⣿⣄   ⠈⠻⣿⣿⣿⣷⣿⣿⣿⣿⣿⡟ ⠫⢿⣿⡆
                  ⠻⣿⣿⣿⣿⣶⣶⣾⣿⣿⣿⣿⣿⣿⣿⣿⡟⢀⣀⣤⣾⡿⠃
          '';
        };
        "fantasy-art/skeleton_hood.txt" = {
          text = ''
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠴⠂⠀⠈⠁⠀⠀⠀⠉⠁⠀⠒⢄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠔⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⣄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠤⠄⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠂⠀⠀⠀⠀⠀⠀⠀⠀⡠⠊⡀⠀⠀⣳⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠌⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠰⣄⠀⠀⠀⠀⡠⢊⡤⠊⠔⠨⠁⠙⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢂⢀⡠⠊⡰⠋⠀⠀⠈⠂⠀⠀⠀⠑⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠎⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢋⠄⠋⣀⣀⡅⠀⠀⠀⠀⠠⡁⢀⠂⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢹⢣⠇⠀⠉⠢⠠⡀⠀⠀⠀⠁⠀⢀⠄
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢣⠁⠀⠀⠀⢹⠀⡢⠀⠀⢀⠔⠁⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠮⠥⢤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⡇⠀⠑⠍⢀⠀⠈⠐⠐⠁⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⠀⠀⠀⠀⠙⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⠀⠀⠈⠀⢈⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠙⠢⣄⠓⠄⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡇⠀⢀⠔⠁⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⢸⡀⠉⠲⣄⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠇⠐⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡆⠀⠀⠀⠀⠀⠀⠀⠀⢹⠀⠰⠄⡨⠙⠲⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢰⢇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡇⠀⠀⠀⠀⠀⠀⠀⠀⢸⠇⠀⢠⠃⠀⠀⠀⣙⠢⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠸⡜⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⡀⠀⠀⠀⠀⠀⠀⠀⣸⠖⠀⠠⠠⠀⠀⠃⠉⠿⠿⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢡⢇⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢇⠀⠀⠀⠀⠀⠀⢀⣿⣤⠄⠀⠀⠀⠀⠀⣦⣤⣤⣤⣽⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠫⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣘⡂⠀⠀⠀⠀⢀⡟⠙⢯⡀⠀⠀⠀⠀⠈⣉⣉⣉⣉⣁⣧⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠲⢄⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⠙⢳⠀⠀⠀⢀⠞⠀⠀⠀⣟⠀⠀⠀⠀⠀⠿⠿⠿⠛⠉⠙⡆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣇⣆⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣀⠈⠀⠀⠀⠉⠀⠀⠀⠀⠈⡇⠀⠀⠀⠀⠠⠴⠶⠤⠖⠛⢉⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣞⣏⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢸⢈⡌⠀⠀⠀⠀⠀⠀⠀⠀⢀⡼⠶⠀⠀⠀⠀⠀⠀⠀⢀⣀⠠⠤⠙⢦⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡠⠶⡋⣘⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣎⡀⠀⠀⠀⠀⠀⠀⠀⠀⠔⠁⡀⠴⠆⠀⠀⠀⢰⠒⠈⠉⢁⠀⠀⠀⠀⠈⠢⡄⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⠔⠁⠀⠈⠢⠤⡀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠆⠀⠀⠀⠀⠀⠀⠀⣠⡴⠞⠉⠀⠀⠀⠀⠀⠉⠉⠉⠉⠁⠀⠁⠀⠀⠀⠀⠀⠈⠳⡄⠀⣠⠤⣠⣶⢶⡿⠋⠁⠀⠀⠀⠀⠀⠀⣸⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠘⣆⡀⠀⢀⣠⡔⠊⢁⠆⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠑⠈⢙⣚⣥⠿⠟⠛⣉⡼⠋⠀⠀⠀⠀⠀⠀⠀⣠⣾⠏⠄⠀⠀⠀
            ⠀⠀⠀⠀⠀⣀⣀⠤⠀⠠⢄⠀⠀⠘⡇⠀⠁⣜⠚⠀⠀⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠤⣀⣀⣀⣀⠤⠄⠐⠂⢠⠜⠁⠀⠀⢀⡠⠚⠁⠀⠀⠀⠐⠀⠀⠀⡔⡼⢡⢏⡜⠀⠀⠀⠀
            ⠀⠤⢤⣀⠀⣀⠀⠀⠀⠀⠀⠉⠑⠒⠓⠀⢀⡙⠀⠀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⠴⠊⠁⣀⢀⠀⠛⠁⠀⠀⠀⠀⠀⠀⠀⠀⢀⡼⣻⠴⠃⡕⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠀⠈⡄⠀⢀⠊⠀⠀⠀⢀⢀⣀⢰⠀⠀⠀⠀⠀⠀⠀⣠⠤⠊⠉⠉⠉⠉⠉⠉⠛⢁⡴⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⠀⢀⡤⢔⡿⠗⠚⠉⠠⠉⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠠⠒⠂⠀⠄⠁⠔⢁⣦⠀⠐⢜⢹⢸⡆⡀⠀⣄⠀⢀⣀⣀⠀⠀⠀⠀⠀⠀⠀⢀⠔⠋⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣤⠖⠻⠒⣫⠼⠃⡘⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⡠⠊⠀⠀⠀⠁⠀⠀⠀⠐⡴⠄⠀⠀⢹⡆⠘⡜⡀⠈⠃⠃⠀⠀⠀⠀⠀⠀⠀⣠⠔⠁⠀⢀⡠⠐⠀⠀⠀⠀⠀⠀⣠⡶⠋⠀⢀⠴⢎⢠⠔⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠜⠀⠀⠀⠀⠂⡀⠉⠠⡀⠀⠀⠀⢀⠠⠴⡿⠀⠘⢎⠂⢤⣀⣀⡠⠤⠄⠒⣪⠕⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⣠⢞⣉⣤⡴⠊⠁⠤⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠰⡁⠀⢰⠀⠀⠑⢌⢂⠀⠀⠀⠑⠞⠁⠀⠀⢲⢦⠀⡼⠀⠀⠀⣀⠜⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣠⣾⠗⠋⣁⠤⠒⠊⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⠢⠌⠀⠀⠀⠀⠁⠑⠄⠀⠀⠀⡠⠀⠀⢸⡄⠿⢀⠀⠀⢀⡁⠀⢀⡠⢊⠴⠀⠀⠀⢄⡠⡵⠘⠈⠠⠔⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠐⠀⠀⠀⠀⠀⠀⡔⠀⠀⠀⠀⠰⠄⠠⠄⠀⢆⠀⠈⠀⠈⡸⠁⠈⠉⠁⠒⠈⢀⡠⠐⣉⠴⠂⠁⠀⠀⠂⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
            ⠀⠀⠀⠀⡀⠀⠀⠁⠢⠀⠀⠀⠀⠀⠀⠀⠀⠈⠈⠀⠀⠀⠈⠈⠒⠲⠶⠶⠖⠒⢊⣉⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
          '';
        };
      };
    };
  }
