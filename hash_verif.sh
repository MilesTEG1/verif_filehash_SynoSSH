#!/bin/sh

## README
# /!\ Ce script d'installation est conçu pour mon usage. Ne le lancez pas sans vérifier chaque commande ! /!\
# Utiliser la commande suivante pour rendre le script exécutable :
# chmod 755 ./hash_verif.sh

## SYNTAX
#
# syntax:   Bhash_verif.sh [<ARG>]
#           [<ARG>] :   fichier
#                       -h ou -help ou --h ou --help

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
declare -r param_1="$1"                          # 1er argument fourni - Ici ce sera le type de hash
declare -r param_2="$2"                          # 2ème argument fourni - Ici ce sera le fichier à hasher
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

    if [ -z "$1" ]; then    # $1 est vide
        echo "${WHITE}${RED_BG}Aucun paramètre n'a été fourni. Il faut fournir le fichier à hasher.${NORMAL}"
    elif [ -n "$1" ] && [ "$1" != "help" ]; then  # $1 n'est pas vide et n'est pas help
        echo "${YELLOW}Le paramètre fourni ${WHITE}${RED_BG} $1 ${NORMAL}${YELLOW} n'est pas correct. ${NORMAL}"
    elif [ $# -ne 2 ]; then
        echo "${YELLOW}Le nombre de paramètre fourni n'est pas correct : ${WHITE}${RED_BG} $* ${NORMAL}"
    else
        echo "${YELLOW}Le paramètre fourni ${WHITE}${RED_BG} $1 ${NORMAL}${YELLOW} n'est pas correct. ${NORMAL}"
    fi
    echo
    echo "${UNDERLINE}${WHITE}Utilisation du script :${NORMAL}\t${POWDER_BLUE}      $nom_script ${GREEN}type_hash fichier${NORMAL}"
    echo
    echo "${POWDER_BLUE}Le type de hash doit être une de ces options :    ${GREEN}sha256${NORMAL}"
    echo "${POWDER_BLUE}                                                  ${GREEN}sha1${NORMAL}"
    echo "${POWDER_BLUE}                                                  ${GREEN}md5${NORMAL}"
    echo
}






clear # On efface l'écran
echo "${WHITE}Ce script permet de vérifier le HASH md5/sha1/sha256 d'un fichier sur un NAS Synology via SSH."
echo "Il faudra coller le hash d'origine lorsqu'il sera demandé.${NORMAL}"
echo

if [ $nb_param -eq 0 ]; then
    # Aucun paramètre n'a été fourni. On va afficher la liste de ce qui peut être utilisé.
    f_affiche_parametre # On appelle la fonction qui affiche l'utilisation des paramètres
    exit
elif [ $param_1 = "-h" ] || [ $param_1 = "-help" ] || [ $param_1 = "--h" ] || [ $param_1 = "--help" ] || [ $param_1 = "h" ] || [ $param_1 = "help" ]; then
        # La paramètre entré est une demande d'affichage de la syntaxe...
        f_affiche_parametre "help" # On appelle la fonction qui affiche l'utilisation des paramètres
        exit
elif [ $nb_param -ne 2 ]; then
    # Il ne faut que deux paramètres, donc s'il y a un nombre de paramètre différent de 1...
    f_affiche_parametre "$*"
    exit
else
    
    # On affiche le nom du fichier à tester (pour être sur du hash à utiliser)
    echo "Le fichier à vérifier est : €{param_2}"
    echo
    # On récupère le hash de comparaison :
    echo "Entrez le hash de comparaison (faire un copier/coller): "
    read hash_origin
    echo

    if [ -z $hash_origin ]; then
        # aucun hash coller
        echo ""
        echo "${WHITE}${RED_BG}Aucun hash n'a été fourni.${NORMAL}"
        echo "Interruption du script."
        exit 99 # On stoppe immédiatement l'exécution de la fonction !
    fi

    echo "hash fourni = $hash_origin"
    echo "paramètre n°1 = $param_1"
    case "$param_1" in
        [Ss][Hh][Aa]256)      # 
            echo "Vérification du hash SHA256 :"
            echo "$hash_origin $param_2" | sha256sum -c
            ;;
            
        #######################################################################################################
        [Ss][Hh][Aa]1)      # 
            echo "Vérification du hash SHA1 :"
            echo "$hash_origin $param_2" | sha1sum -c
            ;;

        #######################################################################################################
        [Mm][Dd]5)      # 
            echo "Vérification du hash md5 :"
            echo "$hash_origin $param_2" | md5sum -c
            ;;

        *)
        echo "${WHITE}${RED_BG}Erreur inattendue.${NORMAL}"
        echo "Interruption du script."
        exit 99 # On stoppe immédiatement l'exécution de la fonction !            exit
            ;;
    esac
fi
echo "-----------------------------------  Fin du Script  -----------------------------------"
