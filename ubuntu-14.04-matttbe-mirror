#!/bin/bash
# Script which should help users install / tweak some stuff immediately
# after installing Ubuntu 14.04 32bit and 64bit.
#
# The script comes with no warranty. The author is not responsible if
# your system breaks.
#
#####################
#
#  Copyright (C) 2010 Alin Andrei, http://www.webupd8.org
#  Copyright 2011-2014 Matthieu Baerts <matttbe@gmail.com>
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 3 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#
#####################
#Credits:
#based on the idea of: http://czytelnia.ubuntu.pl/index.php/2009/11/03/skrypt-ulatwiajacy-konfiguracje-ubuntu-9-10-karmic-koala/, but Ubuntu Start is a completely re-written script with lots of new features.


MIRROR_ADDR="http://192.168.1.2/"
# Download manual ## TODO: take latest version + download from the local mirror
MANUAL_FR="https://ubuntu-manual.org//download/13.10/fr/screen"
# WEBPAGE_END="http://www.louvainlinux.be/statistiques-install-party-q2/"
TRUETYPEPATH="/usr/share/fonts/truetype/"
ROOT_UID=0
cd `dirname "$0"` # ensure that this script is launched from the right dir
DIR=$(pwd)

# needs to be run with sudo
if [ "$UID" -ne "$ROOT_UID" ];
	then
	echo ""
	echo "Vous devez lancer ce script avec les droits de l'administrateur."
	echo ""
	echo "Tentative de relancement."
	echo "Merci d'entrer votre mot de passe ci-dessous (les caractères tapés seront invisibles, il n'y aura pas d'astérisque pour des raisons de sécurité)"
	echo ""
	sudo "./`basename $0`"
	exit
fi

ON_USER=$(users | awk '{print $1}') # first: the one who has launched X

#running gconf-tool2/dconf with "sudo" fails to set the options for the current user so this tweak makes it possible to run sudo for gconf-tool2 and change the setting for the current user, not the root user
# export $(grep -v "^#" /home/$ON_USER/.dbus/session-bus/`cat /var/lib/dbus/machine-id`-0)
# sudo -u $ON_USER test -z "$DBUS_SESSION_BUS_ADDRESS" && eval `sudo -u $ON_USER dbus-launch --sh-syntax --exit-with-session`

#Note: Ubuntu 14.04 Trusty: it's no longer possible to launch gsettings/gconftool with that... #TODO: find a better fix...
CMD_FOR_USER="$DIR/$ON_USER.sh"
echo '#!/bin/bash
[ "$UID" -eq "0" ] && echo "Ne pas lancer avec ROOT" && exit 1' > "$CMD_FOR_USER"
chmod +x "$CMD_FOR_USER"
chown $ON_USER:$ON_USER "$CMD_FOR_USER"

DISTRIB=$(grep -e DISTRIB_CODENAME /etc/lsb-release | cut -d= -f2)
DISTRIBNUM=$(grep -e DISTRIB_RELEASE= /etc/lsb-release | cut -d= -f2 | cut -d. -f1)
DISTRIBNUM2=$(grep -e DISTRIB_RELEASE= /etc/lsb-release | cut -d= -f2 | cut -d. -f2)

# warning ##################### MIRROR
if test "$DISTRIB" = "trusty"; then
	echo "Check mirror addr ($MIRROR_ADDR)"
	`wget -q --no-check-certificate --timeout=5 --tries=2 $MIRROR_ADDR -O /dev/null > /dev/null 2>&1` && MIRROR_GOOD_DISTRIB=TRUE || MIRROR_GOOD_DISTRIB=FALSE
else
	echo "WARNING: This script has been made for Ubuntu Trusty 14.04! "
	/usr/bin/zenity --warning --title="WARNING" --text="You are not using Ubuntu 14.04 Trusty Thar"
	MIRROR_GOOD_DISTRIB=FALSE
fi

#check if the user is running 32 or 64bit
if [ "i686" = `uname -m` ]; then
	echo "Using `cat /etc/issue.net` x86 (i386) - [ OK ]"
	arch=i386
elif [ "x86_64" = `uname -m` ]; then
	echo "Using `cat /etc/issue.net` x68_64 (amd64) - [ OK ]"
	arch=amd64
else
	/usr/bin/zenity --warning --title="Architecture not supported" --text="Your architecture is not supported"
	echo You are not using `cat /etc/issue.net` 32 or 64bits, exiting
	exit
fi

# check if there are applications running which can interfere with the script
sleep 1
for lock in synaptic update-manager software-center apt-get dpkg aptitude
do
if ps -U root -u root u | grep $lock | grep -v grep > /dev/null;
	then
	echo "Installation won't work. Please close $lock first then try again.";
	/usr/bin/zenity --warning --title="Erreur" --text="L'installation ne fonctionne pas. Fermez $lock et essayez à nouveau."
	exit
fi
done

# force port 80, the default port (11371) is maybe blocked
function addppakey()
{
	if test -f "$DIR/keys.gpg"; then
		sudo apt-key adv --import "$DIR/keys.gpg"
	else
		# Author: Dominic Evans https://launchpad.net/~oldman
		# License: LGPL v2
		echo '#!/bin/sh
		echo "Hit your password (its invisible by security ;) )! "
		sudo -v
		echo "Please wait! "
		for APT in `find /etc/apt/ -name *.list`; do
			grep -o "^deb http://ppa.launchpad.net/[a-z0-9\-]\+/[a-z0-9\-]\+" $APT | while read ENTRY ; do
			# work out the referenced user and their ppa
			USERPPA=`echo $ENTRY | cut -d/ -f4`
			PPA=`echo $ENTRY | cut -d/ -f5`
			# some legacy PPAs say "ubuntu" when they really mean "ppa", fix that up
			if [ "ubuntu" = "$PPA" ]
			then
				PPA=ppa
			fi
			# scrape the ppa page to get the keyid
			KEYID=`wget -q --no-check-certificate https://launchpad.net/~$USERPPA/+archive/$PPA -O- | grep -o "1024R/[A-Z0-9]\+" | cut -d/ -f2`
			sudo apt-key adv --list-keys $KEYID >/dev/null 2>&1
			if [ $? -ne 0 ]
			then
				echo "Grabbing key $KEYID for archive $PPA by ~$USERPPA"
				sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com:80 $KEYID
			else
				echo "Already have key $KEYID for archive $PPA by ~$USERPPA"
			fi
			done
		done
		sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com:80 5044912E #dropbox key
		sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com:80 CFD74EDE # me key' > /home/$ON_USER/ubuntu-keyserver.sh
		chmod +x /home/$ON_USER/ubuntu-keyserver.sh
		chown $ON_USER /home/$ON_USER/ubuntu-keyserver.sh

		if [ "$KEYSERVER_FAIL" != "" ]; then
			/usr/bin/zenity --info --text="Le serveur de clé n'est pas disponible. Merci de lancer le script 'ubuntu-keyserver.sh' disponible dans votre répertoire Home en double cliquant dessus plus tard."
		else
			sh /home/$ON_USER/ubuntu-keyserver.sh
			rm -f /home/$ON_USER/ubuntu-keyserver.sh
		fi
	fi
}



function addallkey()
{
	if test -f "$DIR/keys.gpg"; then
		sudo apt-key adv --import "$DIR/keys.gpg"
	else
		#addkey
		wget -q http://repository.glx-dock.org/cairo-dock.gpg -O- | sudo apt-key add -
		wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
		addppakey
		wget -q http://download.videolan.org/pub/debian/videolan-apt.asc -O- | sudo apt-key add -
	fi
}


#check if the user has an active internet connection
function testConnection()
{
	# ping can be blocked -> wget
	testconnection=`wget --tries=3 --timeout=15 www.google.com -O /tmp/testinternet &>/dev/null 2>&1`
	if [ $? -gt 0 ]; then
		echo	"You are not connected to the Internet. Please check your Internet connection and try again."
		/usr/bin/zenity --info --text="<b>Erreur:</b> Vous n'êtes pas connecté à Internet mais vous avez choisi une option nécessitant une connexion à Internet. Merci de corriger votre connexion à Internet et essayer à nouveau."
	else
		echo Internet connection - ok
	fi
}

function testKeyServer()
{
	if test -f "$DIR/keys.gpg"; then
		sudo apt-key adv --import "$DIR/keys.gpg"
	else
		# keyserver.ubuntu.com -> test
		# normalement sur le port 11371
		testconnection=`wget --tries=2 --timeout=5 "http://keyserver.ubuntu.com:80/pks/lookup?op=get&search=0x60D11217247D1CFF" -O /tmp/testinternet2 &>/dev/null 2>&1`
		if [ $? -gt 0 ]; then
			echo	"The keyserver isn't available, please double-click on 'ubuntu-keyserver.sh' script later"
			KEYSERVER_FAIL=1
		else
			echo "Keyserver connection - ok"
		fi
		addallkey
	fi
}

## n'ajoute que le dépôt (car le port pour communiquer avec le serveur de clé
##  peut être bloqué dans un réseau universitaire)
function AddMeApt ()
{
	myRepoComm=$1
	myRepo=`echo ${myRepoComm:0:$(expr index "$myRepoComm" \#)-2}`
	if [ "$MIRROR" = "yes" ]; then
		SRC_FILE="$DIR/sources_out.list"
		grep "^$myRepo" "$SRC_FILE" > /dev/null
		if [ $? -eq 1 ]; then
			# to not duplicate the repository
			echo "$myRepoComm" | sudo tee -a "$SRC_FILE"
		fi
	fi
	SRC_FILE="/etc/apt/sources.list"
	grep "^$myRepo" $SRC_FILE > /dev/null
	if [ $? -eq 1 ]; then
		# to not duplicate the repository
		echo "$myRepoComm" | sudo tee -a $SRC_FILE
	fi
}

function OurMirror ()
{
	if [ "$1" = "up" ]; then
		if test -f "$DIR/keys.gpg"; then
			sudo apt-key adv --import "$DIR/keys.gpg"
		fi
		if test -f "$DIR/sources_local.list"; then
			sudo cp /etc/apt/sources.list /etc/apt/sources.list_ORIGINAL
			sudo cp "$DIR/sources_local.list" /etc/apt/sources.list
		else
			echo "Pas de fichier sources_local.list"
		fi
	elif [ "$1" = "down" ]; then
		if test -f "$DIR/sources_out.list"; then
			sudo cp "$DIR/sources_out.list" /etc/apt/sources.list
		else
			echo "Pas de fichier /etc/apt/sources_out.list"
		fi
	elif [ "$1" = "original" ]; then
		if test -f "/etc/apt/sources.list_ORIGINAL"; then
			sudo cp /etc/apt/sources.list_ORIGINAL /etc/apt/sources.list
		else
			echo "Pas de fichier /etc/apt/sources.list_ORIGINAL"
		fi
	fi
}

WORD8="Etape 1 : Réglages, corrections et dépôts"
WORD9="Important: \\n\\n1. Si vous n'utilisez pas notre mirroir et ne sélectionnez pas\\nl'option 'Ajouter des dépôts additionnels', vous ne serez \\npas en mesure d'installer certains paquets à l'étape 2. \\n\\n2. Afin que certains paramètres soient pris en compte, vous devrez vous déconnecter et \\nvous reconnecter de votre session (mais seulement après que les étapes 1 et 2 soient \\nterminées!).\\n\\n3. Choisir \"Reset\" remettra à zéro cette option si vous l'aviez utilisée avant. Ne pas \\nchoisir à la fois un réglage et son option de remise à zéro! \\n\\nChoisir:"
WORD10="Sélectionné"
WORD11="Améliorations"
WORD12="Déplacer les boutons de la fenêtres à droite (Affichage classique)"
WORD13=">> Reset: \"$WORD12\""
WORD16="Supprimer les icônes des lecteurs montés sur le Bureau"
WORD17=">> Reset: \"$WORD16\""
WORD20="Activer les icônes dans les menus et les boutons"
WORD21=">> Reset: \"$WORD20\""
WORD26="Enlever le paquet ubuntu-docs (libération de 252Mo)"
WORD27=">> Reset \"$WORD26\""
WORD34="Ajouter des dépôts additionnels (PPA de Cairo-Dock, Matttbe, LaTeXila et Ubuntu-Tweak) SI VOUS N'UTILISEZ PAS NOTRE MIRROIR"
WORD39="Ajouter notre miroir (32 and 64bits only)"
WORD40="Télécharger un centre de logiciels dédié aux jeux"
WORD41="Défilement des messages du terminal sans limite"
WORD42=">> Reset: \"$WORD41\""
WORD44="Défilement de la souris à deux doigts"
WORD45=">> Reset: \"$WORD44\""
WORD46="Désactiver les propositions d'achat dans le dash Unity"
WORD47=">> Reset: \"$WORD46\""
WORD48="Compiz/Unity: 2x2 viewports (4 bureaux)"
WORD49="Télécharger un manuel d'utilisation en PDF sur le bureau"
WORD50="Désactiver la session invitée (guest session)"
WORD51=">> Reset: \"$WORD50\""
WORD52="À l'activation de fichiers texte exécutables, demander que faire au lieu d'ouvrir l'éditeur de texte"
WORD53=">> Reset: \"$WORD52\""
WORD54="Barre de progression pour APT-GET (installation de programmes depuis le terminal)"
WORD55=">> Reset: \"$WORD54\""
WORD56="Ajouter des couleurs pour les info du terminal (PS)"
WORD57=">> Reset: \"$WORD56\""

# For additionnal PPA, do not enable it if repo is used (already in sources.list)
test "$MIRROR_GOOD_DISTRIB" = "TRUE" && PPAS=FALSE || PPAS=TRUE

#gui 1
choicess=`/usr/bin/zenity --title="$WORD8" --width=600 --height=600 \
				--text="$WORD9" \
				--list --column="$WORD10" --column="$WORD11" \
				--checklist FALSE "$WORD12" FALSE "$WORD13" FALSE "$WORD16" FALSE "$WORD17" TRUE "$WORD20" FALSE "$WORD21" FALSE "$WORD26" FALSE "$WORD27" $PPAS "$WORD34" $MIRROR_GOOD_DISTRIB "$WORD39" FALSE "$WORD40" TRUE "$WORD41" FALSE "$WORD42" TRUE "$WORD44" FALSE "$WORD45" TRUE "$WORD46" FALSE "$WORD47" TRUE "$WORD48" TRUE "$WORD49" FALSE "$WORD50" FALSE "$WORD51" TRUE "$WORD52" FALSE "$WORD53" TRUE "$WORD54" FALSE "$WORD55" TRUE "$WORD56" FALSE "$WORD57"`

if [ $? -eq 0 ];
then
	IFS="|"
	for choicee in $choicess
	do
		if [ "$choicee" = "$WORD12" ]; # WM: button: layout
			then
			echo 'gconftool-2 --type string --set /apps/metacity/general/button_layout "menu:minimize,maximize,close"' >> "$CMD_FOR_USER"
			echo 'gsettings set org.gnome.desktop.wm.preferences "menu:minimize,maximize,close"' >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD13" ];
			then
			echo 'gconftool-2 --type string --set /apps/metacity/general/button_layout "close,minimize,maximize:"' >> "$CMD_FOR_USER"
			echo 'gsettings set org.gnome.desktop.wm.preferences "close,minimize,maximize:"' >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD16" ]; # volumes: icons in desktop
			then
			echo 'gsettings set org.gnome.nautilus.desktop volumes-visible false' >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD17" ];
			then
			echo 'gsettings set org.gnome.nautilus.desktop volumes-visible true' >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD20" ]; # buttons/menus have icons
			then
			echo 'gsettings set org.gnome.desktop.interface buttons-have-icons true' >> "$CMD_FOR_USER"
			echo 'gsettings set org.gnome.desktop.interface menus-have-icons true' >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD21" ];
			then
			echo 'gsettings set org.gnome.desktop.interface buttons-have-icons false' >> "$CMD_FOR_USER"
			echo 'gsettings set org.gnome.desktop.interface menus-have-icons false' >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD26" ]; # docs
			then
			sudo apt-get purge -y --force-yes ubuntu-docs
		elif [ "$choicee" = "$WORD27" ];
			then
			sudo apt-get -y --force-yes install ubuntu-docs
		elif [ "$choicee" = "$WORD34" ]; # repos
			then
			testConnection
			sudo rm /etc/apt/sources.list_backup > /dev/null 2>&1;
			sudo cp /etc/apt/sources.list /etc/apt/sources.list_backup

			ARRAY=( "deb http://archive.canonical.com/ubuntu $DISTRIB partner ## Canonical" "deb http://ppa.launchpad.net/cairo-dock-team/ppa/ubuntu $DISTRIB main ## Cairo-Dock-PPA" "deb http://ppa.launchpad.net/matttbe/ppa/ubuntu $DISTRIB main ## Matttbe" "deb http://download.videolan.org/pub/debian/stable / ## dvdcss")

			ELEMENTS=${#ARRAY[@]}
			for (( i=0;i<$ELEMENTS;i++));
			do
				AddMeApt "${ARRAY[${i}]}"
			done
			testConnection
			addallkey
			sudo apt-get update
		elif [ "$choicee" = "$WORD39" ]; # mirror
			then
			echo "Check mirror (again)"
			wget -q --no-check-certificate --timeout=5 --tries=2 $MIRROR_ADDR -O /dev/null > /dev/null 2>&1 && echo "Add mirror" || continue ## recheck if the mirror is available
			OurMirror "up"
			apt-get update
			MIRROR="yes"
		elif [ "$choicee" = "$WORD40" ]; # extra games
			then
			sudo -u $ON_USER mkdir /home/$ON_USER/Jeux
			cd /home/$ON_USER/Jeux
			sudo -u $ON_USER wget -c -q --no-check-certificate --timeout=5 --tries=2 http://www.lastos.org/team/LastOS/mgp/release/lastos-mgp-1.0.0-11.tar.gz
			sudo -u $ON_USER tar xzf lastos-mgp-1.0.0-11.tar.gz
			sudo -u sed -i "/desktop/d" install # pas besoin de son raccourcis qui se place sur un dossier inexistant sans les permissions.
			sudo ./install
			cd $DIR
		elif [ "$choicee" = "$WORD41" ]; # terminal: scrollback unlimited
			then # gnome-terminal is still using GConf
			echo 'gconftool-2 -s /apps/gnome-terminal/profiles/Default/scrollback_unlimited --type bool true' >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD42" ];
			then
			echo 'gconftool-2 -s /apps/gnome-terminal/profiles/Default/scrollback_unlimited --type bool false' >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD44" ]; # scroll with two fingers
			then
			echo 'gsettings set org.gnome.settings-daemon.peripherals.touchpad scroll-method two-finger-scrolling' >> "$CMD_FOR_USER"
			echo 'gsettings set org.gnome.settings-daemon.peripherals.touchpad horiz-scroll-enabled true' >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD45" ];
			then
			echo 'gsettings set org.gnome.settings-daemon.peripherals.touchpad scroll-method edge-scrolling' >> "$CMD_FOR_USER"
			echo 'gsettings set org.gnome.settings-daemon.peripherals.touchpad horiz-scroll-enabled false' >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD46" ]; # disable shopping
			then
			echo "gsettings set com.canonical.Unity.Lenses disabled-scopes \"['more_suggestions-amazon.scope', 'more_suggestions-u1ms.scope', 'more_suggestions-populartracks.scope', 'music-musicstore.scope', 'more_suggestions-ebay.scope', 'more_suggestions-ubuntushop.scope', 'more_suggestions-skimlinks.scope']\"" >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD47" ];
			then
			echo 'gsettings set com.canonical.Unity.Lenses disabled-scopes "[]"' >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD48" ];
			then
			echo 'gsettings set org.compiz.core:/org/compiz/profiles/Default/plugins/core/ hsize 2' >> "$CMD_FOR_USER"
			echo 'gsettings set org.compiz.core:/org/compiz/profiles/Default/plugins/core/ vsize 2' >> "$CMD_FOR_USER"
			echo 'gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ hsize 2' >> "$CMD_FOR_USER"
			echo 'gsettings set org.compiz.core:/org/compiz/profiles/unity/plugins/core/ vsize 2' >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD49" ];
			then
			XDG_DESKTOP_DIR=`grep XDG_DESKTOP_DIR /home/$ON_USER/.config/user-dirs.dirs | cut -d/ -f2 | cut -d\" -f1`
			test -z "$XDG_DESKTOP_DIR" && XDG_DESKTOP_DIR="Bureau"
			wget -c -q --no-check-certificate --timeout=5 --tries=2 $MANUAL_FR -O /home/$ON_USER/$XDG_DESKTOP_DIR/Ubuntu-Manuel.pdf
			chown $ON_USER:$ON_USER /home/$ON_USER/$XDG_DESKTOP_DIR/Ubuntu-Manuel.pdf
		elif [ "$choicee" = "$WORD50" ];
			then
			sudo mkdir -p /etc/lightdm/lightdm.conf.d
			echo "[SeatDefaults]" > /etc/lightdm/lightdm.conf.d/50-matttbe-disable-guest.conf
			echo "allow-guest=false" >> /etc/lightdm/lightdm.conf.d/50-matttbe-disable-guest.conf
		elif [ "$choicee" = "$WORD51" ];
			then
			rm -f /etc/lightdm/lightdm.conf.d/50-matttbe-disable-guest.conf
		elif [ "$choicee" = "$WORD52" ];
			then
			echo 'gsettings set org.gnome.nautilus.preferences executable-text-activation ask' >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD53" ];
			then
			echo 'gsettings set org.gnome.nautilus.preferences executable-text-activation display' >> "$CMD_FOR_USER"
		elif [ "$choicee" = "$WORD54" ];
			then
			echo 'Dpkg::Progress-Fancy "1";' > /etc/apt/apt.conf.d/99progressbar
		elif [ "$choicee" = "$WORD55" ];
			then
			rm -f /etc/apt/apt.conf.d/99progressbar
		elif [ "$choicee" = "$WORD56" ];
			then
			sudo -u $ON_USER sed -i "s/^#force_color_prompt=yes/force_color_prompt=yes/g" /home/$ON_USER/.bashrc
			source /home/$ON_USER/.bashrc
		elif [ "$choicee" = "$WORD57" ];
			then
			sudo -u $ON_USER sed -i "s/^force_color_prompt=yes/#force_color_prompt=yes/g" /home/$ON_USER/.bashrc
			source /home/$ON_USER/.bashrc
		fi
	done
	# sudo -u $ON_USER "DBUS_SESSION_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS gsettings-data-convert
	IFS=""
	if test `wc "$CMD_FOR_USER" | awk '{print $1}'` -gt 2; then ## TODO: remove this workaround if we find something better to really execute gsettings/gconftool with user's DBus session.
		# It seems we can't execute these command from the root user (even with sudo -u $ON_USER)
		# If we set the right DBUS_SESSION_BUS_ADDRESS and we launch it with the right user
		#  or if we launch all commands with: sudo -u $ON_USER $COLORTERM -x "$CMD_FOR_USER"
		#  settings are not "saved". We can see the new settings with dconf-editor but they are not used by all applications!
		rm -f $CMD_FOR_USER.launched
		echo "date -R > \"$CMD_FOR_USER.launched\"" >> "$CMD_FOR_USER"
		MSG_FOR_USER="Merci de lancer le script suivant depuis un nouveau terminal de l'utilisateur $ON_USER :\n\t$CMD_FOR_USER"
		echo -e "\n$MSG_FOR_USER\n"
		zenity --info --text="$MSG_FOR_USER" --title="Étape manuelle" &
		ZENITY_PID=$!
		echo -e "\n\tAttente de l'exécution du script: le script continuera une fois que ce script sera exécuté"
		while test ! -f $CMD_FOR_USER.launched; do sleep 1; done
		kill -15 $ZENITY_PID 2> /dev/null
	fi
	echo "Fait! L'étape 2 va commencer!"
else
	echo cancel selected
fi

# ZRAM: enable by default for <= 4G
test `grep "MemTotal:" /proc/meminfo | awk '{print $2}'` -le 4000000 && ZRAM=TRUE || ZRAM=FALSE
# nVidia prime: enable by default if we detect two cards where at least one is a Nvidia.
test `lspci | grep VGA | grep -ci nvidia` -ge 1 -a `lspci -vnn | grep -c '\''[030[02]\]'` -ge 2 && NVIDIA_PRIME=TRUE || NVIDIA_PRIME=FALSE

#gui 2
choices=`/usr/bin/zenity --title="Etape 2: installation des paquets" --width=800 --height=600 --text="Choisissez les paquets à installer:" --list --column="Sélectionné" --column="Paquet" --column="Description" --checklist TRUE "Cairo-Dock" "Un environnement et une barre des tâches (dock) sympa et pratique" FALSE "Cairo-Dock Weekly" "Un environnement et une barre des tâches sympa et pratique (Weekly version)" FALSE "Chromium Browser" "Navigateur open source avec Pepper (flash)" FALSE "Thèmes supplémentaires" "Installation des thèmes de community" FALSE "Evolution" "Client E-mail" FALSE "Dropbox" "Application qui synchronise un dossier avec des serveurs sur le cloud (Gratuit, 2Go)" FALSE "Google Earth" "Google Earth vous permet de voyager partout sur Terre" FALSE "Outils de développement" "De build-essential à Subversion, GIT et autres" FALSE "Outils de packaging Debian-Ubuntu" "Pour la construction de paquets et développement pour Debian et Ubuntu" FALSE "Pidgin" "Client de messageries instantanées" TRUE "Inkscape" "Editeur d'images vectorielles" TRUE "Gimp" "Editeur complet d'images bitmap" FALSE "LaTeX" "LaTeX (binaires, modules et éditeur)" FALSE "Eclipse" "L'éditeur pour développeur par IBM" TRUE "Misc" "Quelques utilitaires (convertir du texte, de la musique, renommer plusieurs fichiers, etc.)" TRUE "Environnement de bureau Gnome" "Gnome-Shell et le Gnome-Panel" FALSE "Wine" "Lancer des applications Windows sous Linux" TRUE "VLC" "Lecteur de vidéos" TRUE "Codecs et extras" "Codecs (multimedia, java, flash), support d'archives supplémentaires, support DVD et fonts" TRUE "Ubuntu-Tweak" "Outil d'amélioration d'Ubuntu et plein de dépôts additionnels (PPAs) (Attention, beta)" TRUE "Unity-Tweak-Tool" "Outil simple de personnalisation" TRUE "CCSM et extra plugins" "CompizConfig Settings Manager et extra plugins" FALSE "Skype" "Application VoIP chat" TRUE "OpenShot" "Éditeur de vidéo simple et puissant" FALSE "Audacity" "Éditeur audio simple et puissant" FALSE "Blender" "Logiciel complet et puissant de création de vidéos animée" TRUE "Google Talk plugin" "Plugin Google Talk pour le navigateur (audio et vidéo chat dans GMail et Google Plus)" FALSE "GThumb" "Visionneur d'image rapide avec plusieurs options intéressantes" FALSE "EasyTag" "Éditeur performant de tags pour les fichiers audio" FALSE "Gobby" "Editeur de texte collaboratif (édition à plusieurs en même temps)" FALSE "Hugin" "Créateur de panorama à partir de plusieurs photos" FALSE "FileZilla" "Client FTP réputé" TRUE "Synapse" "Recherche rapide d'un peu de tout" FALSE "EasyStroke" "Contrôle du bureau avec des mouvements de souris" $ZRAM "ZRam" "Utiliser ZRam (compression de la mémoire ram peu utilisée): très conseillé pour les PCs avec 2 voir 4 Go de Ram et moins)" FALSE "Steam" "Installer Steam (jeux vidéos propriétaires)" $NVIDIA_PRIME "nVidia Prime" "nVidia Optimus technology (ex Optimus) - Uniquement si nécessaire" FALSE "Pipelight" "Installe et active les plugins propriétaires Silverlight, Unity3D et Widevine pour Firefox" FALSE "Atom" "Éditeur de texte du style de Sublime Text mais libre, plus personnalisable et éditer par Github"`

packagesInst=""
if [ $? -eq 0 ]
then
	IFS="|"
	testConnection
	/usr/bin/zenity --info --text="Le téléchargement et l'installation des paquets va commencer. Merci de ne pas redémarrer votre ordinateur tant que le script n'a pas terminé! " &
	if [ "$choices" = "" ]; then
		echo "Opération annulée"
		sleep 1
		exit 1
	fi
	for choice in $choices
	do
		if [ "$choice" = "Cairo-Dock" ];
			then
				if [ "$MIRROR" != "yes" ]; then
					AddMeApt "deb http://ppa.launchpad.net/cairo-dock-team/ppa/ubuntu $DISTRIB main ## Cairo-Dock-PPA"
				fi
				packagesInst="$packagesInst cairo-dock cairo-dock-plug-ins "
		elif [ "$choice" = "Cairo-Dock Weekly" ];
			then
				AddMeApt "deb http://ppa.launchpad.net/cairo-dock-team/weekly/ubuntu $DISTRIB main ## Cairo-Dock-PPA-Weekly"
				packagesInst="$packagesInst cairo-dock cairo-dock-plug-ins "
		elif [ "$choice" = "Chromium Browser" ];
			then
				packagesInst="$packagesInst chromium-browser chromium-browser-l10n pepperflashplugin-nonfree "
				PEPPER="1"
		elif [ "$choice" = "Thèmes supplémentaires" ];
			then
				packagesInst="$packagesInst elementary-icon-theme suru-icon-theme " # TODO: add more themes
		elif [ "$choice" = "Google Earth" ];
			then
				sudo echo googleearth shared/accepted-googleearth-eula select true | sudo /usr/bin/debconf-set-selections
				AddMeApt "deb http://dl.google.com/linux/earth/deb/ stable main ## Google Repo"
				packagesInst="$packagesInst googleearth googleearth-data "
		elif [ "$choice" = "Google Talk plugin" ];
			then
				GT_LIST="/etc/apt/sources.list.d/google-talkplugin.list"
				sudo rm -f $GT_LIST
				sudo touch $GT_LIST
				echo "### THIS FILE IS AUTOMATICALLY CONFIGURED ###" | sudo tee -a $GT_LIST > /dev/null
				echo "# You may comment out this entry, but any other modifications may be lost." | sudo tee -a $GT_LIST > /dev/null
				echo "deb http://dl.google.com/linux/talkplugin/deb/ stable main" | sudo tee -a $GT_LIST > /dev/null
				packagesInst="$packagesInst google-talkplugin "
				# Or download and install: https://dl.google.com/linux/direct/google-talkplugin_current_i386.deb or https://dl.google.com/linux/direct/google-talkplugin_current_amd64.deb
		elif [ "$choice" = "Outils de développement" ];
			then
				packagesInst="$packagesInst build-essential automake make patch dpatch patchutils autotools-dev cmake libtool autoconf git gitg meld subversion bzr mercurial geany geany-plugins colordiff vim zsh gdb valgrind nemiver d-feet devhelp "
		elif [ "$choice" = "Outils de packaging Debian-Ubuntu" ];
			then
				packagesInst="$packagesInst debhelper pbuilder cdbs quilt fakeroot xutils lintian dh-make ubuntu-dev-tools "
		elif [ "$choice" = "Dropbox" ];
			then
				# echo "deb http://linux.dropbox.com/ubuntu $DISTRIB main" > /home/$ON_USER/dropbox.list
				# sudo mv /home/$ON_USER/dropbox.list /etc/apt/sources.list.d/dropbox.list
				packagesInst="$packagesInst dropbox nautilus-dropbox "
		elif [ "$choice" = "LaTeX" ];
			then
				packagesInst="$packagesInst texlive dvipdfmx lmodern perl-tk texlive-latex-extra latex-beamer latex-xcolor texlive-science texlive-generic-extra texlive-fonts-recommended texlive-pictures texmaker latexila rubber chktex pstoedit python-poppler gedit-latex-plugin texlive-lang-french latexila "
				LATEX_DOC_REMOVE=`zenity --title="LaTeX" --text="Voulez-vous enlever les paquets contenant la doc (généralement inutiles, grand gain de place)" --list --column="Choix" --column="" --radiolist TRUE "Oui" FALSE "Non"`
		elif [ "$choice" = "VLC" ];
			then
				packagesInst="$packagesInst vlc-plugin-notify vlc-plugin-pulse "
		elif [ "$choice" = "Codecs et extras" ];
			then
				sudo echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | sudo /usr/bin/debconf-set-selections
				packagesInst="$packagesInst ubuntu-restricted-addons ubuntu-restricted-extras libdvdnav4 libdvdread4 libdvdcss2 rar unrar p7zip-full p7zip-rar unace ttf-mscorefonts-installer ttf-liberation mencoder adobe-flashplugin "
		elif [ "$choice" = "Ubuntu-Tweak" ];
			then
				if [ "$MIRROR" != "yes" ]; then
					AddMeApt "deb http://ppa.launchpad.net/tualatrix/ppa/ubuntu $DISTRIB main ## Ubuntu-Tweak Next"
				fi
				packagesInst="$packagesInst ubuntu-tweak "
		elif [ "$choice" = "CCSM et extra plugins" ];
			then
				packagesInst="$packagesInst compizconfig-settings-manager compiz-fusion-plugins-extra compiz-fusion-plugins-main compiz-plugins compiz-plugins-default compiz-plugins-extra compiz-plugins-main compiz-plugins-main-default "
		elif [ "$choice" = "Skype" ];
			then
				packagesInst="$packagesInst skype"
				if [ $(uname -i) = 'x86_64' ]; then ## Workaround Skype theme and systray
					packagesInst="$packagesInst gtk2-engines-murrine:i386 gtk2-engines-pixbuf:i386 sni-qt:i386"
				fi
		elif [ "$choice" = "Misc" ];
			then
				packagesInst="$packagesInst ntfs-3g soundconverter trickle nautilus-open-terminal nautilus-image-manipulator nautilus-image-converter xournal cheese frozen-bubble winff parcellite gedit-plugins pyrenamer hardinfo libnotify-bin sl ffmpeg libav-tools pdfshuffler dconf-tools gconf-editor htop powertop gtk-redshift "
				if [ "`echo $LANG |cut -d_ -f1`" = "fr" ]; then
					packagesInst="$packagesInst libreoffice-l10n-fr language-pack-gnome-fr language-support-writing-fr aspell-fr "
				fi
		elif [ "$choice" = "ZRam" ];
			then
				packagesInst="$packagesInst zram-config "
		elif [ "$choice" = "Environnement de bureau Gnome" ];
			then
				packagesInst="$packagesInst gnome-panel gnome-shell gnome-tweak-tool "
				custom_gnome_shell
				# apt-cache search gnome-shell-extension | awk '{ print $1 }' | xargs
		elif [ "$choice" = "nVidia Prime" ];
			then
				packagesInst="$packagesInst nvidia-prime "
		elif [ "$choice" = "Pipelight" ];
			then
				AddMeApt "deb http://ppa.launchpad.net/pipelight/stable/ubuntu $DISTRIB main ## Pipelight"
				PIPELIGHT="1"
				packagesInst="$packagesInst pipelight-multi "
		elif [ "$choice" = "Atom" ];
			then
				AddMeApt "deb http://ppa.launchpad.net/webupd8team/atom/ubuntu $DISTRIB main ## Atom text editor"
				packagesInst="$packagesInst atom "
		else
				choiceLOW=`echo $choice | tr '[:upper:]' '[:lower:]'`
				packagesInst="$packagesInst $choiceLOW "
		fi
	done


	##################
	## Installation ##
	##################

	testConnection # connexion
	testKeyServer	# keys

	# removed cdrom
	sudo sed -i 's/^deb cdrom/# deb cdrom/g' /etc/apt/sources.list
	sudo apt-get update

	# Upgrade
	echo -e "\n\t ====== Dist Upgrade ======\n"
	sudo apt-get dist-upgrade -y --force-yes || (bPostInstFailed=1 && echo -e "\n\n\t=== ERROR UPGRADE ===\n\n")
	if [ "$bPostInstFailed" = "1" ]; then # Try to fix the error: maybe something missing or dpkg --configure -a? or display an error
		sudo apt-get install -f -y --force-yes || sudo dpkg --configure -a
		sudo apt-get install -f -y --force-yes || (zenity --error --text="Une erreur est survenue, merci de la fixer et relancer le script" && exit 1)
	fi

	# Script vérification
	echo -e "\n\t ====== Packages verification and installation! =======\n"

	mkdir -p "$DIR/matttbe"
	echo -e '# on ajoute que les paquets qui manquent
	echo "\t on ajoute que les paquets qui manquent"
	unset $paquetsPresent
	for testPkg in '"$packagesInst"'; do
		dpkg -s $testPkg |grep installed |grep "install ok" > /dev/null	
		if [ $? -eq 1 ]; then
			paquetsPresent="$paquetsPresent $testPkg"
		fi
	done
	# on vérifie la présence des paquets :
	unset $paquetsOK
	unset $paquetsNOTok
	echo "\t on vérifie la présence des paquets"
	for testPkg in $paquetsPresent; do
		sudo apt-get install -s $testPkg > /dev/null 2>&1
		if [ $? -eq 0 ]; then
			paquetsOK="$paquetsOK $testPkg"
			echo "$testPkg est un paquet disponible"
		else
			paquetsNOTok="$paquetsNOTok $testPkg"
			echo "==== $testPkg est introuvable sur les dépôts ===="
		fi
	done
	## Une fois la liste vérifiée, on écrase le fichier avec la commande minimale pour la suite
	echo "sudo apt-get install -y --force-yes -m $paquetsOK || exit 1
	# Paquets mauvais: $paquetsNOTok" > "'$DIR'/matttbe/install_packages.sh"
	#sudo apt-get install -y --force-yes -m $paquetsOK' > "$DIR/matttbe/check_packages.sh"
	chmod +x "$DIR/matttbe/check_packages.sh"
	sudo sh "$DIR/matttbe/check_packages.sh" # check packages
	chmod +x "$DIR/matttbe/install_packages.sh"
	sudo sh "$DIR/matttbe/install_packages.sh" || (bPostInstFailed=1 && echo -e "\n\n\t=== ERROR INSTALL ===\n\n")


	sudo apt-get install -f -y || (bPostInstFailed=1 && echo -e "\n\n\t=== ERROR: install empty ===\n\n")


	##################
	## POST Install ##
	##################

	if test -e "/usr/share/doc/libdvdread4/install-css.sh"; then
		sudo /usr/share/doc/libdvdread4/install-css.sh	#dvd
	fi

	if [ "$LATEX_DOC_REMOVE" = "Oui" ]; then # CLEAN
		packageToRemove=""
		for i in "texlive-latex-extra-doc texlive-science-doc texlive-fonts-recommended-doc texlive-pictures-doc"; do
			if test -d /usr/share/doc/$i; then
				packageToRemove="$packageToRemove $i "
			fi
		done
		if [ "$packageToRemove" != "" ]; then
			sudo apt-get purge -y --force-yes $packageToRemove || (bPostInstFailed=1 && echo -e "\n\n\t=== ERROR purge: $packageToRemove ===\n\n")
		fi
	fi

	if [ "$PEPPER" = "1" ]; then
		sudo update-pepperflashplugin-nonfree --install
	fi

	if [ "$PIPELIGHT" = "1" ]; then
		sudo touch /home/$ON_USER/.config/wine-wininet-installer.accept-license
		sudo pipelight-plugin --accept --enable silverlight
		sudo pipelight-plugin --accept --enable unity3D
		sudo pipelight-plugin --accept --enable widevine
	fi

	###########
	## CLEAN ##
	###########

	sudo apt-get clean || (bPostInstFailed=1 && echo -e "\n\n\t=== ERROR clean ===\n\n")
	sudo apt-get autoclean || (bPostInstFailed=1 && echo -e "\n\n\t=== ERROR autoclean ===\n\n")
	sudo apt-get autoremove -y || (bPostInstFailed=1 && echo -e "\n\n\t=== ERROR autoremove ===\n\n")
	if [ "$MIRROR" = "yes" ]; then
		OurMirror "down"
		echo "Utilisation des serveurs externes"
		sudo apt-get update
	fi

	###################
	## Notifications ##
	###################

	lang=${LANG%_*}
	text="Installation terminée, merci d'avoir utilisé ce script"
	(mplayer "http://translate.google.com/translate_tts?ie=UTF-8&tl=${lang}&q=${text}" &> /dev/null &)
	if [ "$bPostInstFailed" = "1" ]; then
		/usr/bin/zenity --error --text="Installation terminée, ERREUR détectée!"
	else
		/usr/bin/zenity --info --text="Installation terminée, merci d'avoir utilisé ce script!"
	fi
	IFS=""
	sl	# train
	rm /tmp/testinternet > /dev/null 2>&1;
	if [ "$WEBPAGE_END" != "" ]; then xdg-open "$WEBPAGE_END" ; fi
else
	rm /tmp/testinternet > /dev/null 2>&1;
	echo cancel selected
	exit
fi
