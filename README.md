# Script de vérification pour les hash de fichiers en ligne de commande sur un Synology en SSH

J'ai récemment téléchargé sur mon NAS Synology (avec Download Station), des images de iOS et de windows dont j'ai voulu vérifier l'intégrité des fichiers téléchargés.

Je me suis rendu compte qu'en ligne de commande SSH il n'y avait pas grand chose de rapide pour comparer le hash fourni par le site et le hash généré par les commandes ***sum. (j'aurais pu passer par une application sur un des ordinateurs PC ou mac, mais le dossier où sont les fichiers ne sont pas forcément montés, et passer par le réseau wifi, c'est pas très rapide).

Ce script permet donc de copier/coller un hash de fichier fourni comme référence à celui généré par une des commandes suivantes :
- `md5sum fichier` pour un hash MD5 ;
- `sha256sum fichier` pour un hash SHA256 ;
- `sha1sum fichier` pour un hash SHA1.

Ces commandes sont présentes sur mon NAS (DS920+) à priori par défaut.

Le script doit être lancé avec un premier argument qui spécifie le type de hash utilisé, et en deuxième argument le fichier à vérifier :

```bash
./hash_verif.sh sha256 ./chemin_et_nom_du_fichier_à_vérifier.ext
```

Ensuite il sera demandé de coller (ou de taper pour les volontaires) le hash fourni par le site.

Je n'ai pas testé le script en étant en dehors du dossier du fichier testé. Ni chercher à placer le script ailleurs que dans le dossier de téléchargement du NAS.

Toute amélioration est la bienvenue :wink: .
