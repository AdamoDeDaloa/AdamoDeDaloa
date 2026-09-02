# CLAUDE.md — Be4Ball

Les règles du jeu pour ce projet. Voir `ROADMAP.md` pour le "où on va" (NOW/NEXT/LATER).

## Contexte projet

Application mobile d'idéation — projet du Mastère 1 Data & Customer Experience (Digital Campus Paris), mené dans le cadre du bootcamp "IA Boost Camps 2026" (méthode Cadrer → Planifier → Construire → Vérifier, sur 3 jours : J1 Build, J2 Automate, J3 Augment).

**Idée** : répertorier tous les playgrounds de basket d'une ville et permettre aux utilisateurs de se programmer des moments pour jouer avec d'autres membres de la communauté, afin de créer une communauté active autour de chaque terrain.

**Sport** : basket / streetball uniquement (pas de multi-sport au lancement).

**Problème résolu** : les terrains existent mais on ne sait jamais qui va venir jouer et quand. Quatre frictions : découverte (pas de visibilité sur les terrains), coordination (pas de visibilité sur la présence), sociale (jouer avec des inconnus demande de la confiance), fidélisation (groupes existants fermés et dispersés).

**Personas**
1. Le Nouveau — vient d'emménager, ne connaît personne → besoin de **rassurance**
2. Le Régulier / Fédérateur — veut élargir son groupe de jeu → besoin de **visibilité**
3. L'Occasionnel — veut jouer sans engagement fixe → besoin de **flexibilité**

**Proposition de valeur** : "Trouve ton prochain match de streetball, dans ton quartier, avec des joueurs de ton niveau."

**Différenciation** : aucune alternative existante (WhatsApp/Discord, Meetup, apps de réservation, bouche-à-oreille) ne connecte communauté ouverte + spontanéité + niveau de jeu, spécifiquement autour du streetball.

## Conventions

- Langue du projet : français (contenu, UI, code de démo)
- Palette : asphalte `#15191D` (fond), orange ballon `#FF6B2C` (accent/CTA), vert filet `#2F6E52` (accent secondaire), blanc craie `#F5F2EC` (texte sur fond sombre), béton clair `#E8E3DA` (fond clair)
- Typographie : Archivo Black (titres), Inter (texte courant)
- Stack technique du sprint J1 : HTML/JS autonome (single file), données fictives en dur — pas de backend à ce stade
- Stack technique J2 (ajoutée sans remplacer le J1) : Make (automatisation) → Claude (enrichissement IA) → Supabase (BDD) → lecture dans `streetball-app.html` via Leaflet (carte) + `@supabase/supabase-js` (lecture seule, clé anon)

## Méthode

- Analyse avant d'agir : proposer un plan avant toute modification structurante
- MVP découpé en MUST / SHOULD / COULD (voir `ROADMAP.md`) — ne pas construire au-delà du MUST pendant un sprint
- Toute nouvelle idée qui sort du sprint en cours va dans `ROADMAP.md`, pas dans le build
- Debug avec la boucle O.D.C.T. : Observer → Diagnostiquer → Corriger → Tester

## Contraintes

- L'app doit rester **simple et accessible** (peu de friction à l'usage, lisible rapidement en extérieur)
- Pas de chat intégré, pas de tournois, pas de système de classement au MVP
- Un seul sport (basket) au lancement

## Règles à respecter

- Ne pas ajouter de fonctionnalité hors MUST sans passer par `ROADMAP.md` d'abord
- Toute fiche terrain doit rester lisible en un coup d'œil (niveau, distance/quartier, prochaine session)
- Le design garde le principe "carte photo + texte ancré en bas + badges courts", pas de blocs de texte longs

---

## Statut du sprint J1 (Build)

**MUST — fait**
- [x] Afficher les terrains (liste avec quartier, niveau, surface, éclairage)
- [x] Rechercher / filtrer par niveau et par quartier
- [x] Voir le détail d'un terrain (fiche + prochaine session + rejoindre)

Livrable : `streetball-app.html` — interface fonctionnelle autonome, données fictives, interactions réelles (recherche live, filtres par niveau, ouverture de fiche détail, toggle "rejoindre la session"), responsive (grille 1 colonne en dessous de 640px).

**Sprint de test — fait (boucle O.D.C.T.)**

Cas testés (navigateur réel, Chromium) : recherche vide, recherche sans résultat,
recherche espaces uniquement, recherche insensible à la casse, filtre par niveau
seul et combiné à la recherche (y compris combinaison à 0 résultat), ouverture/
fermeture de la fiche détail (bouton fermer + clic extérieur), toggle rejoindre/
quitter une session et persistance de l'état à la réouverture, redimensionnement
jusqu'à 320px de large (grille 1 colonne, pas de débordement horizontal).

Résultat : aucun bug bloquant. Seule anomalie relevée : l'`@import` Google Fonts
échoue si le poste est hors ligne, mais les polices de fallback (`sans-serif`)
prennent le relais sans casser l'affichage — non bloquant, pas de correction
nécessaire.

**Definition of Done — J1**
- [x] Interface fonctionnelle
- [x] Données affichées
- [x] Recherche / filtre
- [x] Détail (fiche + session + rejoindre)
- [x] Testée
- [x] Stable

**J1 Build : terminé.**

## Sprint J2 (Automate)

Objectif du brief : `SOURCE → AUTOMATISATION → IA → BDD → FRONTEND`, une donnée
qui voyage de bout en bout — pas 500 terrains d'un coup.

**Contrainte découverte en route** : cette session Claude Code tourne dans un
environnement au réseau sortant restreint (proxy egress avec liste blanche par
domaine) — impossible d'appeler data.gouv.fr, l'API Data ES, Supabase ou même
des CDN comme unpkg/jsdelivr depuis ce sandbox pour les *tester* en direct.
Cela ne concerne que cette session de développement : une fois le fichier
hébergé (GitHub Pages, machine perso, etc.), tous ces appels fonctionnent
normalement pour les vrais visiteurs.

**Source retenue** : Data ES — Recensement des Équipements Sportifs, ministère
chargé des Sports (`equipements.sports.gouv.fr`), plus de 330 000 équipements
sportifs en France, mis à jour quotidiennement, exhaustif et gratuit. C'est la
base de données complète demandée — bien plus fiable qu'un recensement manuel.

**Ce qui a été construit dans le repo**
- `supabase/schema.sql` — table `terrains` (1 seule table, MVP J2, comme
  enseigné : champs bruts + `ai_accroche`/`ai_categorie` enrichis par Claude)
- `automation/MAKE_SCENARIO.md` — recette module par module du scénario Make
  (TRIGGER Schedule → GET Data ES → TRANSFORM → AI Claude → SAVE Supabase),
  avec le mapping exact des champs, à construire et tester dans Make toi-même
  (je n'ai pas accès à ton compte Make ni à ton projet Supabase)
- `streetball-app.html` — nouvel onglet **"Carte France"** à côté des
  "Sessions du quartier" du J1 : carte Leaflet + liste, lecture (READ) de la
  table `terrains` via `@supabase/supabase-js` (clé anon, lecture seule).
  Tant que `SUPABASE_URL`/`SUPABASE_ANON_KEY` (en tête du script carte) ne
  sont pas renseignés, un terrain d'exemple s'affiche pour que l'écran ne
  soit jamais vide pendant le développement.

**Testé (Chromium, avec les vraies librairies Leaflet/Supabase servies en
local pour contourner la restriction réseau du sandbox)** : bascule entre les
deux onglets, recherche/filtre de l'onglet Sessions toujours fonctionnels
après la bascule, carte + liste + recherche par commune sur l'onglet Carte
France, timeout de 8s avec message clair si Supabase est injoignable (au lieu
de rester bloqué sur "Chargement...").

**Le scénario Make a été construit et tourne réellement** (par Adama, dans
son compte Make) : HTTP (GET Data ES, filtre `aps_name like "Basket"`) →
Iterator → Set multiple variables → Make AI Toolkit (enrichissement,
alternative à l'API Anthropic directe) → Parse JSON → Supabase Create a Row.
Programmé "Daily at 14:00". Champs Data ES confirmés en direct : `equip_numero`,
`equip_nom`, `new_name`, `inst_cp`, `inst_adresse`, `equip_x`/`equip_y`,
`equip_type_name`, `equip_acc_libre`, `aps_name` (voir `automation/MAKE_SCENARIO.md`
pour le détail).

**Vérifié en production** (`https://adamodedaloa.github.io/AdamoDeDaloa/streetball-app.html`,
hébergé via GitHub Pages) : 20 vrais terrains de basket chargés depuis
Supabase, affichés sur une vraie carte OpenStreetMap partout en France
(Albi, Saint-Ouen-sur-Seine, Vitrolles, Fleury-sur-Andelle, Le Bouscat...),
avec accroche générée par l'IA pour chacun.

**Sprint de correction de défauts (après mise en prod)**
- Faille XSS corrigée : `nom`/`commune`/`type_equipement`/`ai_accroche`
  viennent de Supabase (Data ES + texte IA) et étaient insérés dans le DOM
  sans échappement — ajout d'un `escapeHtml()` systématique, testé avec une
  tentative d'injection réelle (neutralisée).
- Classe CSS `.terrain-marker` manquante (marqueurs invisibles) — corrigée.
- `carteMap.invalidateSize()` ajouté par précaution après création de la carte.
- `aria-label` ajoutés sur les deux barres de recherche.

**Definition of Done — J2**
- [x] Une vraie source identifiée (Data ES)
- [x] Un déclencheur Make (scénario programmé "Daily at 14:00")
- [x] Un scénario Make qui tourne sans erreur
- [x] Un traitement IA (Make AI Toolkit, sortie JSON structurée)
- [x] Une écriture Supabase (table `terrains`)
- [x] Une lecture Supabase depuis le frontend (onglet Carte France)
- [x] Une donnée réelle visible dans l'app (20 terrains, en production)
- [x] Le flux testé brique par brique, puis vérifié de bout en bout en prod

**J2 Automate : terminé.**

## Déploiement

L'app est hébergée via GitHub Pages depuis cette branche :
`https://adamodedaloa.github.io/AdamoDeDaloa/streetball-app.html`

## Fichiers du projet

- `claude.md` — ce fichier (règles du jeu)
- `ROADMAP.md` — NOW / NEXT / LATER
- `streetball-app.html` — interface J1 (Sessions du quartier) + J2 (Carte France)
- `streetball-app-mockup.jsx` — mockup visuel initial (3 écrans, avant version fonctionnelle)
- `streetball-app-wireframes.md` — documentation détaillée des wireframes v1
- `supabase/schema.sql` — schéma de la table `terrains` (J2)
- `automation/MAKE_SCENARIO.md` — recette du scénario Make (J2)
