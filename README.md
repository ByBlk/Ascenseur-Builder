# Ascenseur Builder by BLK 🚀

Ascenseur Builder est un script **FiveM** développé pour créer et gérer des ascenseurs directement en jeu. Ce script permet aux joueurs de se téléporter entre différents étages grâce à un système de menu intuitif. Il est hautement personnalisable et conçu pour améliorer les scénarios de roleplay sur votre serveur.

## Fonctionnalités

- **Création d'ascenseurs** : Créez des ascenseurs facilement avec des noms personnalisés.
- **Gestion des étages** : Ajoutez, modifiez ou supprimez les étages pour chaque ascenseur.
- **Téléportation** : Les joueurs peuvent se téléporter à un étage spécifique d'un ascenseur.
- **Marqueurs et UI** : Des marqueurs et une interface utilisateur personnalisables.
- **Système de permissions** : Accès réservé aux rôles définis dans la configuration.

## Prérequis

- [ESX Framework](https://github.com/esx-framework/esx_core)
- MySQL ou MariaDB
- Librairie RageUI (pour les menus)

## Installation

1. **Téléchargez le Script**
   - Clonez ou téléchargez ce dépôt dans votre dossier `resources`.

2. **Configuration de la Base de Données**
   - Importez le fichier SQL suivant dans votre base de données :
     ```sql
     CREATE TABLE `ascenseurs` (
         `id` INT AUTO_INCREMENT PRIMARY KEY,
         `name` VARCHAR(50) NOT NULL
     );

     CREATE TABLE `ascenseurs_etages` (
         `id` INT AUTO_INCREMENT PRIMARY KEY,
         `ascenseur_id` INT NOT NULL,
         `etage_number` INT NOT NULL,
         `pos_x` FLOAT NOT NULL,
         `pos_y` FLOAT NOT NULL,
         `pos_z` FLOAT NOT NULL,
         FOREIGN KEY (`ascenseur_id`) REFERENCES `ascenseurs`(`id`) ON DELETE CASCADE
     );
     ```

3. **Configurez le Script**
   - Ouvrez le fichier `config.lua` et personnalisez les paramètres selon vos besoins :
     ```lua
     Config = {}

     Config.Marker = 1 -- Type de marqueur (voir la documentation FiveM)
     Config.DistanceVu = 5.0 -- Distance pour voir les marqueurs
     Config.DistanceAction = 2.0 -- Distance pour interagir avec les marqueurs
     Config.Perms = {"admin", "moderateur", "fondateur"} -- Groupes ayant accès au menu
     Config.Couleurpoint = {255, 0, 150} -- Couleur des marqueurs (R, G, B)
     ```

4. **Ajoutez-le au Fichier de Configuration du Serveur**
   - Ajoutez le script dans votre fichier `server.cfg` :
     ```
     ensure AscenseurBuilder
     ```

5. **Redémarrez Votre Serveur**
   - Redémarrez votre serveur FiveM, et le script sera prêt à l'emploi.

## Utilisation

### Commandes

- **`/menuascenseur`** : Ouvre le menu de gestion des ascenseurs (réservé aux rôles définis dans le fichier de configuration).

### Fonctionnement

1. **Menu Staff**
   - Utilisez `/menuascenseur` pour créer, modifier ou supprimer des ascenseurs et des étages.

2. **Interaction Joueur**
   - Les joueurs peuvent se rapprocher des marqueurs d'ascenseur et interagir pour se téléporter à différents étages.

3. **Persistance**
   - Tous les ascenseurs et étages sont sauvegardés dans la base de données et automatiquement rechargés après un redémarrage.

## Problèmes Connus

- Aucun pour le moment. Merci de signaler tout problème en créant un ticket sur notre discord https://discord.gg/CCVAwUCYBn
