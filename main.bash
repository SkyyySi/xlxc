#!/usr/bin/env bash
# This script helps to make and manage containers for running
# graphical applications within lxc / lxd.
# Important: This script is only compatible with Arch Linux at
# this time. Other distros may also work but they are untested.

# These options will always be passed.
# Useful for debugging.
DEFAULT_OPTS=( "-u" )

# Print the version number.
_version() {
	local version="0.0.1"
	echo "${0##*/} ${version}"
}

# Print some useful help text.
_usage() {
	cat <<EOL
Usage: ${0##*/} [OPTION]... [COMMAND]...
Run graphical applications using LXD.

This script will fail to execute when run without root privileges,
so make sure to run it as root or to use 'sudo ${0##*/} ...'!

Options:
  -c     enables colored output
  -i     install lxc and perform setup
  -g     generate a new container
  -s     set the distro for generation
  -d     execute as .desktop entry (instead of as command)
  -u     show debug information
  -v     display version number and exit
  -h     display this help text and exit

Examples:
  ${0##*/} -g "mysandbox" -s "arch" 
EOL
}

# Show an error and exit.
_raise_error() {
	cat <<EOL
${0##*/}: ${*}
Try '${0##*/} -h' for more information.
EOL
	exit 1
}

# Check if a command exits on the system.
_command_exitst() {
	command -v "${1}" &> "/dev/null"
}

# Rerun this script as root.
_get_root_privs() {
	if [[ "${EUID}" != "0" ]]; then
		if   _command_exitst "sudo"; then
			sudo "${@}"
		elif _command_exitst "doas"; then
			doas "${@}"
		else
			_raise_error "This script requires root privileges!"
		fi
	fi
}

# Exit if no arguments are specified.
if [[ "$#" -eq 0 ]]; then
	_raise_error "missing argument"
	exit 1
fi

install_lxd() {
	local _packages=()
	if ! _command_exitst "lxd"; then
		pacman -S
	fi

}

# Parse options
parse_opts() {
	while getopts ":vhcigsdu" opts; do
		case "${opts}" in
			v) _version; exit 0 ;;
			h) _usage;   exit 0 ;;
			*)
				_get_root_privs "${0}" "${@}"
				case "${opts}" in
					i) echo install_lxd;;
					c) echo ENABLE_COLOR="true";;
					s) echo DISTRO="${OPTART}";;
					d) echo DESKTOP_ENTRY="true";;
					u) echo DEBUG="true";;
					*) _raise_error "invalid option -- '${OPTARG}'" ;;
				esac
		esac
	done
}

# Run the option parser. This must be at the end of the file.
parse_opts "${DEFAULT_OPTS[@]}" "${@}"
