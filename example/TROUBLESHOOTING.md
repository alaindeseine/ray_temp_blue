# Guide de Dépannage Ray Temp Blue

## Problème : Mode HOLD ne fonctionne pas

### Symptômes
- Vous sélectionnez le mode HOLD dans l'application
- Après connexion, vous obtenez quand même des mesures continues (live)
- Le message d'erreur dans les logs : `The WRITE property is not supported by this BLE characteristic`

### Cause
La caractéristique des paramètres de l'instrument (`45544942-4c55-4554-4845-524db87ad709`) est **en lecture seule**. L'application ne peut pas forcer le thermomètre en mode HOLD programmatiquement.

### Solution
**Éteignez et rallumez le Ray Temp Blue** avant de vous connecter en mode HOLD.

#### Procédure recommandée :
1. **Déconnectez** l'application si connectée
2. **Éteignez** le Ray Temp Blue (bouton power)
3. **Rallumez** le Ray Temp Blue
4. **Sélectionnez** le mode HOLD dans l'application
5. **Connectez-vous** au thermomètre
6. **Testez** en appuyant sur le bouton du thermomètre

### Vérification du Mode
- **Mode HOLD correct** : Température s'affiche seulement quand vous appuyez sur le bouton
- **Mode automatique** : Température se met à jour continuellement

### Pourquoi cela arrive ?
1. Le thermomètre **garde en mémoire** le dernier mode utilisé
2. Si vous avez utilisé le **mode continu** précédemment, il reste actif
3. Seul un **redémarrage** remet le thermomètre en mode HOLD par défaut

## Problème : Overflow de l'interface

### Symptômes
- Message d'erreur : `A RenderFlex overflowed by X pixels on the bottom`
- Interface coupée en bas

### Solution
L'interface est maintenant **scrollable**. Si le problème persiste :
1. **Faites défiler** l'écran vers le haut/bas
2. **Orientez** l'appareil en mode paysage si nécessaire
3. **Réduisez** la taille de police dans les paramètres Android

## Problème : Permissions Bluetooth

### Symptômes
- Erreur de permissions au démarrage
- Impossible de scanner les appareils

### Solution
1. **Vérifiez** que Bluetooth est activé
2. **Accordez** toutes les permissions demandées
3. **Redémarrez** l'application si nécessaire

### Permissions requises (Android) :
- **Android < 12** : `BLUETOOTH`, `BLUETOOTH_ADMIN`, `ACCESS_FINE_LOCATION`
- **Android ≥ 12** : `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT`

## Problème : Appareil non trouvé

### Symptômes
- Le scan ne trouve pas le Ray Temp Blue
- Liste d'appareils vide

### Solutions
1. **Vérifiez** que le Ray Temp Blue est allumé
2. **Rapprochez-vous** de l'appareil (< 10 mètres)
3. **Redémarrez** le Bluetooth sur le téléphone
4. **Relancez** le scan plusieurs fois

## Problème : Connexion échoue

### Symptômes
- Erreur lors de la connexion
- Message "Connection error"

### Solutions
1. **Assurez-vous** que l'appareil n'est pas connecté à une autre application
2. **Redémarrez** le Ray Temp Blue
3. **Effacez** le cache Bluetooth (Paramètres Android > Apps > Bluetooth)
4. **Relancez** l'application

## Problème : Pas de mesures

### Symptômes
- Connecté mais aucune température n'apparaît
- Champ de température reste vide

### Solutions Mode HOLD
1. **Appuyez** sur le bouton du Ray Temp Blue
2. **Utilisez** "Trigger Measurement" dans l'app
3. **Vérifiez** que l'appareil est bien en mode HOLD (voir solution ci-dessus)

### Solutions Mode Continu
1. **Attendez** quelques secondes après la connexion
2. **Pointez** le thermomètre vers une surface
3. **Vérifiez** que l'appareil n'est pas en erreur (écran LCD)

## Logs de Débogage

Pour diagnostiquer les problèmes, utilisez :
```bash
flutter logs > log.txt
```

### Indicateurs dans les logs :
- `Warning: Could not ensure HOLD mode` = Appareil pas en mode HOLD
- `onCharacteristicChanged` répétés = Mode continu actif
- `Connection error` = Problème de connexion BLE

## Contact Support

Si les problèmes persistent :
1. **Collectez** les logs Flutter
2. **Notez** le modèle exact du Ray Temp Blue
3. **Décrivez** la séquence d'actions qui cause le problème
