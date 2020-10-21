#!/bin/sh

## README
# /!\ Ce script d'installation est conçu pour mon usage. Ne le lancez pas sans vérifier chaque commande ! /!\
# Utiliser la commande suivante pour rendre le script exécutable :
# chmod 755 ./HomeBrew-Restore-Installation.sh

## NOTE IMPORTANTE
# Il faudra probablement modifier le script pour l'adapter à vos besoin. !
# Ne l'excécuter pas sans l'avoir lu entièrement afin de vérifier que ce qui est sauvegarder/restaurer
# correspond bien à vos attentes.
#
# Le script sauvegarde ceci :
#       - la liste de tout ce qui a été installé avec HomeBrew (donc soit avec `brew install`, soit avec
#         `brew cask install` et aussi les `brew tap`).
#       - Certains paramètres par défaut (exemple : `defaults write com.apple.dock tilesize -int 32`)
#       - Sauvegarde de certains fichiers de configuration : Oh My Zsh, et certains fichiers/dossiers
#         présents dans ~/Library. Il faudra probablement modifier le script pour l'adapter à vos besoin.
# Lors de la sauvegarde, le script va tester l'existance du dossier de destination ./Fichier :
# Si ce dernier existe, il sera proposé de le supprimer ou de le renommer car le script doit commencer
# avec un dossier vierge.
# Tout ce qui sera sauvegarder (par copie directe ou par archivage) sera contenu dans ce fichier.
# Veillez à ne pas toucher ce dossier pendant l'éxécution du script.
#

## SYNTAX
#
# syntax:   Backup-Restore-Apps-Script.sh [<ARG>]
#           [<ARG>] :   RESTORE
#                       BACKUP
#                       -h ou h ou -help ou help ou --h ou --help

## LICENCE
#
# This  program  is free software: you can redistribute it and/or modify  it
# under the terms of the GNU General Public License as published by the Free
# Software  Foundation, either version 3 of the License, or (at your option)
# any later version.
#
# This  program  is  distributed  in the hope that it will  be  useful,  but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public  License
# for more details.
#
# You  should  have received a copy of the GNU General Public License  along
# with this program. If not, see <http://www.gnu.org/licenses/>

declare -r TRUE=0  # Read-only variable, i.e., a constant.
declare -r FALSE=1 # Read-only variable, i.e., a constant.

declare -r nb_param=$#                           # Nombre d'argument(s) fourni(s) au script.
declare -r param_1="$1"                          # 1er argument fourni
declare -r nom_script=$0                         # Nom du script
declare -r script_dir=$(cd ${0%/*} && pwd -P)    # Chemin complet d'accès du script
declare -r script_dir_rel=$(dirname $0)          # Chemin d'accès relatif du script
declare -r calling_dir=$(pwd)                    # Chemin d'accès complet du dossier de lancement du script (peut différer de script_dir si l'appel du script est fait d'ailleurs...)
declare -r dossier_fichiers=$script_dir/Fichiers # Dossier qui doit exister tout le temps
debug_v=true                                     # Une variable de debug pour tester des bouts de code et pas d'autres
compteur=0                                       # Pour affihcer une numérotation des étapes

################################################################################################################
## On défini des couleurs de texte et de fond, avec des mises en forme.
## Il faut utiliser ${xxxx} juste avant le texte à mettre en forme (avec xxxx = une des variables ci-dessous).
##

BLACK=$(tput setaf 0)   # Pour faire un echo avec le texte en noir
RED=$(tput setaf 1)     # Pour faire un echo avec le texte en rouge
GREEN=$(tput setaf 2)   # Pour faire un echo avec le texte en vert
YELLOW=$(tput setaf 3)  # Pour faire un echo avec le texte en jaune
BLUE=$(tput setaf 4)    # Pour faire un echo avec le texte en bleu
MAGENTA=$(tput setaf 5) # Pour faire un echo avec le texte en magenta
CYAN=$(tput setaf 6)    # Pour faire un echo avec le texte en cyan
WHITE=$(tput setaf 7)   # Pour faire un echo avec le texte en blanc
GREY=$(tput setaf 8)    # Pour faire un echo avec le texte en gris (dans ma config iTerm c'est gris)
LIME_YELLOW=$(tput setaf 190)
POWDER_BLUE=$(tput setaf 153)
AUTRE_COULEUR=$(tput setaf 180)

BLACK_BG=$(tput setab 0)   # Pour faire un echo avec le fond en noir
RED_BG=$(tput setab 1)     # Pour faire un echo avec le fond en rouge
GREEN_BG=$(tput setab 2)   # Pour faire un echo avec le fond en vert
YELLOW_BG=$(tput setab 3)  # Pour faire un echo avec le fond en jaune
BLUE_BG=$(tput setab 4)    # Pour faire un echo avec le fond en bleu
MAGENTA_BG=$(tput setab 5) # Pour faire un echo avec le fond en magenta
CYAN_BG=$(tput setab 6)    # Pour faire un echo avec le fond en cyan
WHITE_BG=$(tput setab 7)   # Pour faire un echo avec le fond en blanc
GREY_BG=$(tput setab 8)    # Pour faire un echo avec le fond en gris
LIME_YELLOW_BG=$(tput setab 190)
POWDER_BLUE_BG=$(tput setab 153)

BOLD=$(tput bold)      # Pour faire un echo avec le texte en gras (c'est pas vraiment gras...)
NORMAL=$(tput sgr0)    # Pour faire un echo avec le texte normal (on réinitialise toutes les personnalisations)
BLINK=$(tput blink)    # Pour faire un echo avec le texte clignotant
REVERSE=$(tput smso)   # Pour faire un echo avec le texte en négatif
UNDERLINE=$(tput smul) # Pour faire un echo avec le texte souligné
HBRIGHT=$(tput dim)
# tput bold    # Select bold mode
# tput dim     # Select dim (half-bright) mode
# tput smul    # Enable underline mode
# tput rmul    # Disable underline mode
# tput rev     # Turn on reverse video mode
# tput smso    # Enter standout (bold) mode
# tput rmso    # Exit standout mode
##
################################################################################################################

cd $script_dir # On se place dans le dossier du script

f_affiche_parametre() {
    #
    # syntax:   f_affiche_parametre [<argument1> [<argument2>]]
    #           Les arguments sont facultatifs...
    #
    if [ -z "$1" ]; then
        echo "${WHITE}${RED_BG}Aucun paramètre n'a été fourni. Il faut fournir le fichier à hasher.${NORMAL}"
    elif [ -n "$2" ]; then
        echo "${YELLOW}Le paramètre fourni ${WHITE}${RED_BG} $1 ${NORMAL}${YELLOW} n'est pas correct. ${NORMAL}"
    else
        echo "${YELLOW}Le nombre de paramètre fourni n'est pas correct : ${WHITE}${RED_BG} $1 ${NORMAL}"
    fi
    echo
    echo "${UNDERLINE}${WHITE}Utilisation du script :${NORMAL}\t${POWDER_BLUE}      $nom_script ${GREEN}[paramètre]${NORMAL}"
    echo
    echo "${UNDERLINE}${WHITE}Liste des [paramètre] utilisables :${GREEN} fichier${NORMAL}"
}






clear # On efface l'écran
echo "${WHITE}Ce script permet de vérifier le HASH md5/sha1/sha256 d'un fichier "
echo "en collant le hash de comparaison.${NORMAL}"
echo

if [ $nb_param -eq 0 ]; then
    # Aucun paramètre n'a été fourni. On va afficher la liste de ce qui peut être utilisé.
    f_affiche_parametre # On appelle la fonction qui affiche l'utilisation des paramètres
    exit
elif [ $nb_param -ne 1 ]; then
    # Il ne faut qu'un seul paramètre, donc s'il y a un nombre de paramètre différent de 1...
    f_affiche_parametre "$*"
    exit
else
    # On récupère le hash de comparaison :
    echo "Entrez le hash de comparaison : "
    read hash_origin
    echo
    echo "Le hash d'origine à vérifier est : $hash_origin"
    echo "Vérification du hash du fichier :"
    echo
    
    
    case "$param_1" in
    #######################################################################################################
    "sha256")      # 

        ;;
    
    #######################################################################################################
    "sha1")      # 
        ;;

    #######################################################################################################
    "md5")      # 
        ;;

    *)
        f_affiche_parametre "$param_1" "param_inc" # On appelle la fonction qui affiche l'utilisation des paramètres
        exit
        ;;
    esac
fi
echo "-----------------------------------  Fin du Script  -----------------------------------"
