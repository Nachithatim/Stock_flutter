# Stock Flutter

Application Flutter SaaS simplifiee de gestion de stock.

## Fonctionnalites

- Authentification email/mot de passe avec Firebase Authentication.
- Donnees Firestore isolees par client dans `tenants/{uid}`.
- Gestion des produits par categorie avec creation automatique de categorie.
- Entrees en stock et ventes avec transaction Firestore.
- Dashboard par plage de dates:
  - etat de stock;
  - produits les plus vendus;
  - ventes par categorie;
  - produits sous le seuil d'approvisionnement.

## Pile technique

- Flutter
- GoRouter
- Riverpod
- Dio
- Firebase Auth
- Cloud Firestore

## Architecture

Le code suit une organisation DDDA simple:

- `lib/domain/models`: objets metier.
- `lib/data/services`: acces Firestore.
- `lib/data/repositories`: orchestration data.
- `lib/providers`: injection Riverpod.
- `lib/presentation`: ecrans et widgets.
- `lib/core`: router, theme et reseau.

## Firebase

Executer la configuration Firebase avant lancement reel:

```bash
flutterfire configure
```

Puis activer Email/Password dans Firebase Authentication et publier les regles:

```bash
firebase deploy --only firestore:rules
```

## Validation

Commandes executees:

```bash
flutter analyze
flutter test
```

Resultat: analyse sans erreurs et tests valides.

## Lancement demo web

Pour garder les donnees locales apres redemarrage, lancer toujours Chrome avec
le meme port:

```powershell
.\run_demo.ps1
```

Ou directement:

```powershell
flutter run -d chrome --web-port 63006
```

Temps utilise final: 12 minutes 28 secondes.
Jetons consommes final: 121524.
