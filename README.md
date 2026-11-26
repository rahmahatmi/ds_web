# DriveEasy : frontend Angular 22

Application web destinée aux agents d'agence DriveEasy. Elle consomme l'API **uniquement via l'API Gateway** (`http://localhost:8080/api`), jamais directement les microservices.

**Technologies** : Angular 22 (composants standalone, signals, nouveau control flow `@if / @for / @switch`, application *zoneless*), Reactive Forms, HttpClient avec intercepteurs fonctionnels, routage avec chargement différé (lazy loading). Aucune bibliothèque graphique externe : les graphiques sont dessinés en SVG.

## Prérequis

- Node.js **22.22+** ou **24.15+** (exigence d'Angular 22)
- npm 10+
- Le backend `driveeasy-backend` démarré (la gateway doit répondre sur le port 8080, CORS autorisé pour `http://localhost:4200`)

## Ports utilisés

| Port | Composant |
|---|---|
| **4200** | Application Angular (`ng serve`) |
| **8080** | API Gateway du backend : **seule** adresse appelée par le frontend (`http://localhost:8080/api`) |

Les microservices (8081, 8082, 8083), Eureka (8761), le Config Server (8888) et Zipkin (9411) ne sont jamais appelés directement par le frontend.

## Installation et lancement

```bash
npm install
npm start            # = ng serve -> http://localhost:4200
```

Autres commandes :

```bash
npm run build        # build de production dans dist/
npm test             # tests unitaires (Vitest)
```

L'URL de l'API est définie dans `src/app/core/api.config.ts` (jeton d'injection `API_URL`).

## Écrans

| Route | Écran | Contenu |
|---|---|---|
| `/dashboard` | Tableau de bord | Véhicules disponibles / loués / en maintenance, CA du mois, taux d'occupation, graphique du CA sur 6 mois, répartitions (anneaux), locations en cours, top véhicules |
| `/vehicules` | Catalogue | Grille de cartes avec illustration, filtres (recherche, catégorie, carburant, statut, prix max), tri, pagination |
| `/vehicules/new`, `/vehicules/:id/edit` | Formulaire véhicule | Formulaire réactif avec validations (année ≤ année courante, prix > 0…), gestion du statut, aperçu |
| `/clients` | Liste des clients | Tableau paginé, recherche, badge STANDARD / FIDELE / VIP, alerte permis expiré |
| `/clients/new`, `/clients/:id/edit` | Formulaire client | CIN 8 chiffres, e-mail, téléphone… |
| `/clients/:id` | Fiche client | Informations, éligibilité (âge, permis), catégorie, historique des locations |
| `/locations/new` | Nouvelle location | Assistant en 5 étapes : client → période → véhicule disponible → simulation du prix → confirmation |
| `/locations` | Liste des locations | Filtres statut / période / client / véhicule, pagination serveur, actions Départ / Retour / Annuler |
| `/locations/:id/retour` | Retour de véhicule | Saisie du kilométrage et de la date, estimation des pénalités, récapitulatif final **imprimable** |

## Structure

```
src/app/
├── app.ts / app.html / app.scss     coquille : menu latéral, barre de chargement, notifications
├── app.config.ts                    providers : router (lazy + input binding), HttpClient + intercepteurs
├── app.routes.ts                    routes + guards
├── core/
│   ├── models.ts                    interfaces TypeScript alignées sur les DTO du backend
│   ├── api.config.ts                URL de la gateway (InjectionToken)
│   ├── interceptors.ts              requestInterceptor (X-Request-Id + chargement), errorInterceptor (messages d'erreur)
│   ├── guards.ts                    unsavedChangesGuard (CanDeactivate), locationEnCoursGuard (CanActivate)
│   └── services/
│       ├── api.services.ts          VehiculeService, ClientService, LocationService
│       └── ui.services.ts           NotificationService (toasts), LoadingService
├── shared/shared.ts                 pipes (tnd, libelle, dateFr), badge, illustration véhicule, graphiques SVG
└── features/
    ├── dashboard/
    ├── vehicules/                   vehicule-list, vehicule-form
    ├── clients/                     client-list, client-detail, client-form
    └── locations/                   location-list, location-wizard, location-retour
```

## Intercepteurs et guards

- **requestInterceptor** : ajoute un en-tête `X-Request-Id` (repris et journalisé par le filtre personnalisé de la gateway) et alimente l'indicateur de chargement global.
- **errorInterceptor** : transforme les réponses d'erreur du backend (format `ApiError`) en notifications lisibles (409 doublon, 400 validation avec détails, 503 service indisponible, serveur injoignable…).
- **unsavedChangesGuard** : demande confirmation avant de quitter un formulaire modifié.
- **locationEnCoursGuard** : l'écran de retour n'est accessible que pour une location EN_COURS (ou TERMINEE pour réimprimer le récapitulatif).

## Jeux de données

Le frontend ne contient **aucune donnée en dur** : tout provient du backend, qui charge en mémoire un jeu de démonstration à chaque démarrage (voir le README de `driveeasy-backend`). Les données utiles pour parcourir l'interface :

| Donnée | Contenu | Intérêt pour la démonstration |
|---|---|---|
| 12 véhicules | n° 5 et 6 loués, n° 10 en maintenance, n° 1 et 7 réservés prochainement | Catalogue, filtres, badges de statut, suppression refusée sur un véhicule loué |
| 10 clients | n° 1 FIDELE, n° 8 VIP, **n° 9 permis expiré**, **n° 10 âgé de 19 ans** | Badges de catégorie, alerte « permis expiré », blocage à l'étape 1 de l'assistant |
| 16 locations | 2 en cours (n° 5 et 6), 2 réservées (n° 7 et 8), 1 annulée (n° 9), le reste terminé dont 2 avec pénalité | Actions Départ / Retour / Annuler, récapitulatif imprimable, tableau de bord |

Les données étant en mémoire, **tout redémarrage du backend remet le jeu d'origine** : les créations faites depuis l'interface sont perdues.

## Comptes de test

Le prototype **ne comporte pas d'authentification** : aucun compte, identifiant ni mot de passe n'est nécessaire. L'application s'ouvre directement sur le tableau de bord. L'ajout de Spring Security / JWT au niveau de la gateway figure dans les perspectives du rapport.

## Captures d'écran

À réaliser avec le backend démarré, puis à placer dans `docs/captures/` : la liste exacte des captures attendues figure dans `docs/captures/README.md`.
