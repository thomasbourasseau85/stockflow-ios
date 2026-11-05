# STOCKFLOW iOS — projet natif SwiftUI

Application iOS native SwiftUI, interface sombre avec accent vert citron. Les données sont stockées localement dans `Documents/stockflow-data.json`.

## Fonctionnalités incluses
- Tableau de bord (stock, commandes actives, chiffre d'affaires, marge estimée)
- Création, modification, recherche et suppression d'articles
- Emplacements de rangement personnalisables
- Saisie et suivi des commandes avec statuts
- Demande d'autorisation et rappel de notification locale
- Persistance locale JSON

## Limites importantes
- Il s'agit d'un projet source iOS, pas encore d'un fichier IPA signé.
- La compilation iOS nécessite Xcode sur macOS. Windows seul ne peut pas compiler une application SwiftUI native.
- Sideloadly sert à installer/signer un IPA déjà compilé ; il ne compile pas le projet.
- Avec un compte Apple gratuit, la signature personnelle expire généralement après 7 jours. Le renouvellement est gratuit, mais doit être refait.
- Les notifications locales sont incluses. Les notifications push distantes nécessitent une infrastructure et les capacités Apple appropriées.
- Aucune connexion Vinted automatique n'est implémentée : elle nécessite une API/intégration autorisée et documentée. Le projet ne collecte aucun identifiant Vinted.

## Compilation
1. Ouvrir `STOCKFLOW.xcodeproj` sur un Mac avec Xcode.
2. Dans Signing & Capabilities, sélectionner ton équipe Personal Team.
3. Modifier le Bundle Identifier si nécessaire.
4. Sélectionner ton iPhone et lancer Run, ou archiver/exporter un IPA pour Sideloadly.

Cible minimale : iOS 16.0.
