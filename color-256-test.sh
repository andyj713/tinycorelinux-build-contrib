#!/bin/sh

# Andrew S. Johnson, 2022
# inspired by print256colours.sh by Tom Hale, 2016
# looks the same, but rewritten for busybox ash / Tiny Core Linux
# Print out 256 colours, with each number printed in its corresponding color
# See http://askubuntu.com/questions/821157/print-a-256-color-test-pattern-in-the-terminal/821163#821163
# for the original inspiration

function print_color() {
	printf "\e[48;5;%sm" "$1"		# Start block of $1 color
	printf "\e[38;5;%sm%3d" "$2" "$1"	# In $2 contrasting color text, print number
	printf "\e[0m "				# Reset color
}

blacktext=0
whitetext=15

for b1 in $(seq 0 4 12); do
	print_color $b1 $whitetext
	for b2 in $(seq 1 3); do
		print_color $(($b1+$b2)) $blacktext
	done
done
printf "\n\n"

for group in $(seq 16 108 124); do
	for row in $(seq $group 6 $(($group+30))); do
		[ $((($row-16)%36)) -lt 18 ] && cx=$whitetext || cx=$blacktext
		for chunk in $(seq $row 36 $(($row+72))); do
			for block in $(seq $chunk $(($chunk+5))); do
				print_color $block $cx
			done
			printf "  "
		done
		printf "\n"
	done
	printf "\n"
done

for grey in $(seq 232 243); do
	print_color $grey $whitetext
done
printf "\n"

for grey in $(seq 244 255); do
	print_color $grey $blacktext
done
printf "\n"

