# Test des Deux Modes Ray Temp Blue

## Mode Continu (par défaut)

```bash
cd example
flutter run lib/main.dart
```

**Comportement attendu :**
- ✅ Connexion au Ray Temp Blue
- ✅ Température s'affiche automatiquement et se met à jour en continu
- ✅ Pas besoin d'appuyer sur le bouton du thermomètre
- ✅ Idéal pour monitoring en temps réel

## Mode HOLD

```bash
cd example
flutter run lib/main_hold.dart
```

**Comportement attendu :**
- ✅ Connexion au Ray Temp Blue
- ✅ Le thermomètre reste en mode HOLD (manuel)
- ✅ Température s'affiche seulement quand :
  - On appuie sur le bouton du thermomètre
  - On clique sur "Trigger Measurement" dans l'app
- ✅ Idéal pour mesures ponctuelles

## Différences Clés

| Aspect | Mode Continu | Mode HOLD |
|--------|--------------|-----------|
| **Classe** | `RayTempBlue` | `RayTempBlueHold` |
| **Mesures** | Automatiques/continues | Sur demande uniquement |
| **Bouton thermomètre** | Optionnel | Nécessaire pour mesure |
| **Usage** | Monitoring temps réel | Mesures ponctuelles |
| **Consommation** | Plus élevée | Plus faible |

## Test Recommandé

1. **Tester le mode HOLD d'abord** (comportement original du thermomètre)
2. **Puis tester le mode continu** (pour voir la différence)
3. **Éteindre/rallumer le thermomètre** entre les tests pour reset le mode

## Notes Importantes

- Le thermomètre revient toujours en mode HOLD après extinction/rallumage
- Le mode continu modifie temporairement les paramètres du thermomètre
- Les deux modes sont compatibles avec le même appareil
- Choisir le mode selon le cas d'usage de votre application
