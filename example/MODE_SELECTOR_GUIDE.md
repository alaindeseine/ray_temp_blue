# Guide du Sélecteur de Mode Ray Temp Blue

## Vue d'ensemble

L'application exemple principale (`lib/main.dart`) intègre maintenant un **sélecteur de mode** qui permet de basculer entre les deux modes d'opération du Ray Temp Blue :

- **Mode HOLD** (par défaut) - Mesures manuelles uniquement
- **Mode Continu** - Mesures automatiques continues

## Interface Utilisateur

### Sélecteur de Mode
- **Carte colorée** en haut de l'écran indiquant le mode actuel
- **Boutons segmentés** pour basculer entre les modes
- **Icônes visuelles** : ⏸️ pour HOLD, ▶️ pour Continu
- **Description** du comportement de chaque mode

### Indicateurs Visuels
- **Couleur orange** pour le mode HOLD
- **Couleur bleue** pour le mode Continu
- **Champ de température** adapté selon le mode :
  - "Temperature (On Demand)" en mode HOLD
  - "Temperature (Live)" en mode Continu

### Boutons d'Action
- **Mode HOLD** :
  - "Trigger Measurement" avec indicateur de chargement
  - Instructions pour utiliser le bouton du thermomètre
- **Mode Continu** :
  - "Manual Trigger" (optionnel)
  - Message indiquant les mises à jour automatiques

## Fonctionnement

### Changement de Mode
1. **Déconnexion automatique** si un appareil est connecté
2. **Réinitialisation** de l'instance appropriée
3. **Vérification des permissions** pour le nouveau mode
4. **Interface mise à jour** selon le mode sélectionné

### Mode HOLD
- Utilise la classe `RayTempBlueHold`
- Force le thermomètre en mode manuel (measurement interval = 0x0000)
- Mesures uniquement sur :
  - Appui du bouton du thermomètre
  - Clic sur "Trigger Measurement"
- Méthode `triggerMeasurement()` retourne directement la mesure

### Mode Continu
- Utilise la classe `RayTempBlue`
- Le thermomètre passe en mode automatique
- Mesures continues en temps réel
- Stream de température mis à jour automatiquement

## Utilisation Recommandée

### Test Initial
1. **Démarrer en mode HOLD** (par défaut)
2. **Se connecter** au Ray Temp Blue
3. **Tester** les mesures manuelles
4. **Basculer** en mode Continu
5. **Observer** la différence de comportement

### Cas d'Usage

**Mode HOLD - Idéal pour :**
- Mesures ponctuelles précises
- Applications de contrôle qualité
- Saisie de données spécifiques
- Économie d'énergie

**Mode Continu - Idéal pour :**
- Monitoring en temps réel
- Surveillance de température
- Enregistrement de données
- Applications de suivi

## Notes Techniques

### Gestion des Instances
- Une seule instance active à la fois
- Nettoyage automatique lors du changement de mode
- Gestion séparée des streams et connexions

### Persistance du Mode
- Le mode sélectionné reste actif pendant la session
- Retour au mode HOLD au redémarrage de l'app
- Le thermomètre revient en mode HOLD après extinction/rallumage

### Gestion d'Erreurs
- Déconnexion propre lors du changement de mode
- Messages d'erreur adaptés selon le mode
- Gestion des timeouts en mode HOLD

## Commandes de Test

```bash
# Lancer l'application avec sélecteur de mode
cd example
flutter run lib/main.dart

# Lancer uniquement le mode HOLD (legacy)
flutter run lib/main_hold.dart
```

## Avantages du Sélecteur

1. **Une seule application** pour tous les cas d'usage
2. **Comparaison facile** entre les modes
3. **Interface unifiée** avec adaptation contextuelle
4. **Flexibilité maximale** pour l'utilisateur
5. **Maintenance simplifiée** du code

Cette implémentation offre la meilleure expérience utilisateur en combinant les deux modes dans une interface intuitive et flexible.
