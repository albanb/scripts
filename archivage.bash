#!/bin/bash
REPERTOIRE_SOURCE=""
RACINE_DESTINATION="/media/5211529A04099FF7/sauvegarde"
REPERTOIRE_CONFIGURATION="/home/alban/.config/archivage"
SOFTWARE_CONFIGURATION="$RACINE_DESTINATION/software_config"

#Fonction d'aide : affichage de l'aide
function aide
{
echo "NOM"
echo "archivage.bash : sauvegarde du home"
echo "SYNOPSIS"
echo "archivage.bash [OPTIONS] [USER] [DOSSIER]"
echo "DESCRIPTION"
echo "Le script archivage permet d'archiver le dossier DOSSIER de l'utilisateur USER vers un disque dur amovible sous sauvegarde/USER."
echo "Le paramètre USER permet de choisir le USER dont on veut sauvegarder un dossier. Par défaut, si il n'y a que le paramètre DOSSIER, c'est le home de l'utilisateur courant qui est sauvegardé"
echo "Le paramètre DOSSIER permet de choisir le dossier à sauvegarder"
echo "Les sous-dossiers TMP sont ignorés"
echo "Les options possible sont :"
echo "-h ou --help : pour afficher cette aide"
}

#Fonction d'archivage proprement dite
function archive
{
#Synchronisation des dossiers sources et destination
echo $REPERTOIRE_SOURCE
echo $REPERTOIRE_DESTINATION
rsync -rtD --del --stats --progress $REPERTOIRE_SOURCE $REPERTOIRE_DESTINATION
echo "La commande de sauvegarde a terminé son travail..."
}

#Fonction permettant de s'assurer que le disque dur est en place avant l'archivage
function ready
{
# Détecter la présence du volume de destination et interrompre l'opération si nécessaire
while [ ! -e "$RACINE_DESTINATION" ]
do
	#Si le volume de sauvegarde n'est pas présent on affiche un message demandant quoi faire	
	echo "Le dossier de sauvegarde $RACINE_DESTINATION n'existe pas. Insère le disque dur de sauvegarde si tu veux sauvegarder. Disque monté? y/n"
	read answer
	if [ "$answer" != "y" ]
	then
		#On demande de repousser la sauvegarde		
		echo "Attention la sauvegarde du dossier est repoussée"
		exit 3
	fi
done
if [ ! -e "$REPERTOIRE_CONFIGURATION" ]
then
	echo "Le fichier de configuration est absnet. Créer le pour définir quoi sauvegarder"
	exit 4
fi
}

#Fonction permettant de parser le fichier de configuration
function parse
{
	#Parsing du fichier de configuration
	for line in $(cat $HOME/bin/archivage/config)
	do
		nb=$(echo $line | grep -c "#")
		#Ignore comments
		if [ $nb -eq 0 ]
		then
			#Set le repertoire source a sauvegarder
			REPERTOIRE_SOURCE=$(echo $line)
			end_path=$(echo $line | sed 's/\/[^\/]*$//')
			#Set le repertoire du depertoire de sauvegarde
			REPERTOIRE_DESTINATION=$(echo $RACINE_DESTINATION$end_path)
			#Archivage via rsync
			archive
		fi
	done
}

#Back-up liste de software installes
function software
{
	echo "pacman -Qe" >> $SOFTWARE_CONFIGURATION
	pacman -Qe >> $SOFTWARE_CONFIGURATION
	echo "pacman -Qm" >> $SOFTWARE_CONFIGURATION
	pacman -Qm >> $SOFTWARE_CONFIGURATION
}

ready
parse
software
