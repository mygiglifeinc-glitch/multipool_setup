#!/usr/bin/env bash
#####################################################
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by cryptopool.builders for crypto use...
#####################################################

source /etc/functions.sh
cd "$HOME/multipool/install" || exit 1
source user_setup.sh
clear

# Welcome
message_box "Ultimate Crypto-Server Setup Installer" \
	"Hello and thanks for using the Ultimate Crypto-Server Setup Installer!
	\n\nInstallation for the most part is fully automated. In most cases any user responses that are needed are asked prior to the installation.
	\n\nNOTE: You should only install this on a brand new Ubuntu ${MULTIPOOL_SUPPORTED_RELEASES// / or } LTS installation."
# Root warning message box
message_box "Ultimate Crypto-Server Setup Installer" \
	"Naughty, naughty! You are trying to install this as the root user!
	\n\nRunning any application as root is a serious security risk.
	\n\nTherefore we make you create a user account :)"

# Ask if SSH key or password user
dialog --title "Create New User With SSH Key" \
	--yesno "Do you want to create your new user with SSH key login?
Selecting no will create user with password login only." 7 60
case $? in
	0) UsingSSH=yes ;;
	1) UsingSSH=no ;;
	*) clear; echo "[ESC] key pressed."; exit ;;
esac

# Ask for the new account name until we get a valid one.
while true; do
	input_box "New Account Name" \
		"Please enter your desired user name.
		\n\nUser Name:" \
		"${yiimpadmin:-yiimpadmin}" \
		yiimpadmin

	if [ -z "${yiimpadmin}" ]; then
		# user hit ESC/cancel
		exit
	fi
	if ! is_valid_username "$yiimpadmin"; then
		message_box "Invalid User Name" "User names must start with a lower case letter or underscore and may only contain lower case letters, digits, '-' and '_'."
	elif id -u "$yiimpadmin" >/dev/null 2>&1; then
		message_box "User Exists" "The user ${yiimpadmin} already exists. Log in as that user and run the installer from there, or choose another name."
	else
		break
	fi
done

if [[ "$UsingSSH" == "yes" ]]; then
	# Ask for the public key until we get one ssh-keygen accepts.
	while true; do
		input_box "Please open PuTTY Key Generator (or run ssh-keygen) on your local machine and generate a new key pair." \
			"Paste your OpenSSH format public key (ssh-ed25519 ... or ssh-rsa ...). To paste in PuTTY use ctrl shift right click.
			\n\nPublic Key:" \
			"${ssh_key:-}" \
			ssh_key

		if [ -z "${ssh_key}" ]; then
			# user hit ESC/cancel
			exit
		fi
		if ssh-keygen -l -f /dev/stdin <<< "$ssh_key" >/dev/null 2>&1; then
			break
		fi
		message_box "Invalid Public Key" "That doesn't look like a valid OpenSSH public key. It should be a single line starting with ssh-ed25519, ssh-rsa or ecdsa-sha2-."
	done

	# The account is used with the SSH key; still give it a strong random
	# password for console access.
	RootPassword=$(generate_password 20)
else
	while true; do
		input_box "User Password" \
			"Enter your new user password (at least 12 characters) or use this randomly system generated one.
			\n\nUnfortunately dialog doesn't let you copy. So you have to write it down.
			\n\nUser password:" \
			"$(generate_password 20)" \
			RootPassword

		if [ -z "${RootPassword}" ]; then
			# user hit ESC/cancel
			exit
		fi
		if [ ${#RootPassword} -ge 12 ]; then
			break
		fi
		message_box "Password Too Short" "Please use a password with at least 12 characters."
	done

	clear
	dialog --title "Verify Your Responses" \
		--yesno "Please verify your answers before you continue:

New User Name : ${yiimpadmin}
New User Pass : ${RootPassword}" 8 60

	# 0 means user hit [yes] button, 1 means [no], 255 means [Esc].
	case $? in
		0) ;;
		1) clear; exec bash "$HOME/multipool/install/start.sh" ;;
		*) clear; exit ;;
	esac
fi

clear
echo -e " Adding new user ${yiimpadmin}...$COL_RESET"
sudo useradd -m -s /bin/bash "${yiimpadmin}"
printf '%s:%s\n' "${yiimpadmin}" "${RootPassword}" | sudo chpasswd

if [[ "$UsingSSH" == "yes" ]]; then
	# Create SSH Key structure
	sudo install -d -m 0700 -o "${yiimpadmin}" -g "${yiimpadmin}" "/home/${yiimpadmin}/.ssh"
	printf '%s\n' "$ssh_key" | sudo install -m 0600 -o "${yiimpadmin}" -g "${yiimpadmin}" /dev/stdin "/home/${yiimpadmin}/.ssh/authorized_keys"
fi

multipool_grant_sudo "${yiimpadmin}"
multipool_install_command
multipool_write_global_conf

# Hand the installer over to the new user.
sudo cp -r "$HOME/multipool" "/home/${yiimpadmin}/"
sudo chown -R "${yiimpadmin}:${yiimpadmin}" "/home/${yiimpadmin}/multipool"
cd ~ || exit
sudo rm -rf "$HOME/multipool"
clear
if [[ "$UsingSSH" == "yes" ]]; then
	echo "New user ${yiimpadmin} is installed. Make sure you saved your private key..."
	echo -e "Console (non-SSH) password for ${yiimpadmin}:$YELLOW ${RootPassword}$COL_RESET  - write it down, it will not be shown again."
else
	echo "New user ${yiimpadmin} is installed..."
fi
echo -e "$RED Please reboot system and log in as the new user and type$COL_RESET $GREEN multipool$COL_RESET $RED to continue setup...$COL_RESET"
exit 0
