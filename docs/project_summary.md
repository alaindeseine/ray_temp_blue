# Ray Temp Blue - Résumé du Projet

## Objectif du Projet

Créer un package Flutter pour s'interfacer avec un capteur thermomètre laser Bluetooth (Ray Temp Blue). Le package permettra de récupérer automatiquement les valeurs de température mesurées par l'appareil et de les mettre à disposition d'une application Flutter.

## Use Case Principal

Quand l'utilisateur effectue une mesure sur l'appareil Ray Temp Blue, la valeur mesurée est automatiquement récupérée et peut être saisie dans un champ de l'application Flutter.

## Spécifications Techniques

### Protocole Bluetooth LE
- **Service privé** : UUID `0x455449424C5545544845524DB87AD700`
- **Caractéristique principale** : Sensor 1 Reading (`0x455449424C5545544845524DB87AD701`)
- **Format des données** : IEEE-754 32-bit float (Little Endian)
- **Plage de mesure** : -50°C à 350°C (capteur infrarouge Type 1)

### Mécanisme d'écoute
- **Notification automatique** : `0x0001` (Button pressed) quand l'utilisateur appuie sur le bouton
- **Lecture de la valeur** : Via la caractéristique Sensor 1 Reading
- **Gestion d'erreur** : `0xFFFFFFFF` indique une erreur capteur

## Architecture Choisie

### Approche retenue : Stream/Callback
- Le package expose un `Stream<double>` pour les valeurs de température
- L'application gère l'affectation aux champs selon ses besoins
- Contrôle du focus et de la logique UI dans l'application

### Avantages de cette approche
- **Flexibilité maximale** : L'application décide où utiliser les valeurs
- **Séparation des responsabilités** : Package = BLE, Application = UI
- **Réutilisabilité** : Une mesure peut être utilisée dans plusieurs endroits
- **Contrôle du focus** : Géré par l'application selon ses besoins

### Architecture suggérée
```dart
class RayTempBlue {
  Stream<double> get temperatureStream => _temperatureController.stream;
  void startListening() { /* ... */ }
  void stopListening() { /* ... */ }
}
```

## Dépendances Requises

- `flutter_blue_plus` : Pour la communication Bluetooth LE
- Package Flutter standard pour l'interface

## Prochaines Étapes

1. Ajouter la dépendance BLE au `pubspec.yaml`
2. Implémenter la classe principale `RayTempBlue`
3. Gérer la connexion et l'écoute des notifications
4. Exposer le stream de températures
5. Créer des exemples d'utilisation

## Fichiers du Projet

- `specifications_ray_temp_blue.md` : Spécifications complètes du protocole BlueTherm LE
- `lib/ray_temp_blue.dart` : Classe principale (à implémenter)
- `pubspec.yaml` : Configuration du package