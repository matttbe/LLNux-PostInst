#!/bin/sh
DIR=$(pwd)
if test -f "$DIR/keys.gpg"; then
	echo "Ajout des clés"
	sudo apt-key adv --import "$DIR/keys.gpg"
fi
if test -f "$DIR/sources_local.list"; then
	echo "Utilisation de notre miroir"
	sudo cp /etc/apt/sources.list /etc/apt/sources.list_ORIGINAL
	sudo cp "$DIR/sources_local.list" /etc/apt/sources.list
	sudo apt-get update
else
	echo "Pas de fichier sources_local.list"
fi

echo "Tapez sur la touche Enter lorsque vous avez terminé d'utiliser notre miroir"
read p

if test -f /etc/apt/sources.list_ORIGINAL; then
	sudo cp /etc/apt/sources.list_ORIGINAL /etc/apt/sources.list
	sudo apt-get update
else
	echo "Pas de fichier /etc/apt/sources.list_ORIGINAL"
fi

