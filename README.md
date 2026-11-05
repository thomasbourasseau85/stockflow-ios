# STOCKFLOW iOS — guide Windows + compilation cloud

Projet source iOS natif SwiftUI (iOS 16+). Le projet n'est pas encore un IPA signé.
Le workflow GitHub Actions ci-dessous compile l'application sur un runner macOS hébergé par GitHub, sans Mac personnel.

## 1. Préparer le projet sur Windows
1. Télécharge et extrais `STOCKFLOW-iOS-Natif.zip`.
2. Dans le dossier `STOCKFLOW-iOS`, tu dois voir `STOCKFLOW.xcodeproj`, `STOCKFLOW/` et `.github/`.
3. Crée un compte sur https://github.com si tu n'en as pas.

## 2. Envoyer le projet sur GitHub
1. Sur GitHub, clique sur **New repository**.
2. Nom : `stockflow-ios`. Choisis **Private** puis **Create repository**.
3. Sur la page du dépôt, utilise **Add file > Upload files**.
4. Ouvre le dossier extrait `STOCKFLOW-iOS` sur ton PC et sélectionne TOUT son contenu, y compris le dossier caché `.github` (il contient le workflow).
   - Si Windows ne montre pas `.github`, active **Affichage > Afficher > Éléments masqués** dans l'Explorateur.
   - Le dépôt doit afficher à sa racine `STOCKFLOW.xcodeproj`, `STOCKFLOW` et `.github`, pas un dossier `STOCKFLOW-iOS` contenant tout le reste.
5. Clique **Commit changes**.

## 3. Lancer la compilation cloud
1. Dans le dépôt GitHub, ouvre l'onglet **Actions**.
2. Si GitHub demande d'autoriser les workflows, confirme.
3. Dans la colonne de gauche, sélectionne **Build STOCKFLOW iOS IPA**.
4. Clique **Run workflow**, puis le bouton vert **Run workflow**.
5. Attends la fin. Il faut que l'exécution soit verte (**Success**).
6. Ouvre cette exécution terminée. En bas, dans **Artifacts**, télécharge `STOCKFLOW-unsigned-IPA`.
7. Décompresse le ZIP téléchargé : il contient `STOCKFLOW-unsigned.ipa`.

Le runner macOS GitHub compile le code. Il peut consommer des minutes GitHub Actions, notamment sur dépôt privé. Vérifie les quotas/prix affichés par GitHub avant de lancer si tu veux éviter toute facturation. Un dépôt public peut exposer le code source : ne le rends public que si tu acceptes cette visibilité.

## 4. Signer et installer avec Sideloadly
1. Télécharge Sideloadly depuis son site officiel : https://sideloadly.io/
2. Installe-le sur Windows et branche l'iPhone avec un câble USB.
3. Déverrouille l'iPhone et appuie sur **Faire confiance** si demandé.
4. Dans Sideloadly, sélectionne ton iPhone et glisse `STOCKFLOW-unsigned.ipa` dans la zone IPA.
5. Renseigne ton identifiant Apple dans Sideloadly lorsque demandé, puis lance **Start**.
6. Suis les instructions de confiance du certificat sur l'iPhone si iOS le demande : Réglages > Général > VPN et gestion de l'appareil (le libellé peut varier).
7. Ouvre STOCKFLOW.

Utilise uniquement ton propre identifiant Apple et télécharge Sideloadly depuis son site officiel. Ne communique jamais ton mot de passe Apple à un tiers.

## 5. Renouvellement
Avec une signature gratuite de compte personnel, l'app expire généralement après 7 jours. Rebranche l'iPhone au PC et réinstalle/renouvelle l'app avec Sideloadly avant expiration. La signature est gratuite, mais le renouvellement est une manipulation à refaire.

## Contenu actuel et limites
- Tableau de bord, stock, emplacements, commandes, paramètres.
- Données enregistrées localement sur l'iPhone dans un fichier JSON.
- Notifications locales (rappels planifiés par l'app), sous réserve d'autorisation iOS.
- Pas de synchronisation cloud entre appareils.
- Pas de connexion/synchronisation Vinted automatique intégrée. Il faudra une API ou intégration autorisée et testable ; ne donne pas ton mot de passe Vinted à un outil tiers.
- Les notifications push distantes ne sont pas configurées dans ce projet.

## Dépannage
- Si le workflow échoue, ouvre l'exécution rouge dans Actions, copie le premier message d'erreur rouge et demande de l'aide avec ce texte.
- Si `STOCKFLOW.xcodeproj` n'est pas à la racine du dépôt, le dépôt a probablement été envoyé avec un dossier parent en trop : déplace les fichiers à la racine.
- Si Sideloadly indique que l'IPA est invalide, partage le message exact avant de recommencer.
