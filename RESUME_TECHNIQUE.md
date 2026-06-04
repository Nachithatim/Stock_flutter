# Resume technique

## Pile technologique

- **GoRouter**: navigation entre Login, Dashboard, Produits et Mouvements.
- **Riverpod**: gestion d'etat et injection des repositories/services.
- **Dio**: client HTTP centralise dans `lib/core/network/dio_client.dart`.
- **Firebase Authentication**: authentification email/mot de passe.
- **Cloud Firestore**: stockage des collections `Product`, `Category` et `Movement`.

## Organisation DDDA

- **Domain**: modeles metier dans `lib/domain/models`.
- **Data**: services Firestore et repositories dans `lib/data`.
- **Presentation**: ecrans Flutter dans `lib/presentation`.
- **Providers**: dependances et etats Riverpod dans `lib/providers`.

## Base de donnees SaaS

Chaque client est isole par son `uid` Firebase:

```text
tenants/{uid}/products
tenants/{uid}/categories
tenants/{uid}/movements
```

Les regles Firestore autorisent chaque utilisateur a lire/ecrire uniquement ses
propres donnees.

## Services realises

- Ajout d'un produit par categorie.
- Creation automatique de la categorie si elle n'existe pas.
- Entree en stock via transaction Firestore.
- Vente/sortie du stock avec controle du stock insuffisant.
- Dashboard par plage de date:
  - etat de stock;
  - produits les plus vendus;
  - ventes par categorie;
  - produits sous le seuil d'approvisionnement.
