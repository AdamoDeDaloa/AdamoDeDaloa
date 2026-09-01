# Scénario Make — J2 — Terrains de basket en France

Suit exactement l'anatomie enseignée le J2 : **TRIGGER → GET → TRANSFORM → AI → SAVE**.
Je ne peux pas créer ce scénario à ta place (pas d'accès à ton compte Make ni à ton
projet Supabase depuis cette session) — ce document est la recette précise à suivre
dans l'éditeur Make. `supabase/schema.sql` doit être exécuté avant de commencer.

## Objectif du jour (rappel du brief)

> Le succès du jour n'est pas 500 terrains : c'est UN terrain qui voyage correctement.

Construis et teste module par module (`A → TEST ✓`, puis `A → B → TEST ✓`, etc.) —
ne chaîne jamais tout d'un coup avant le premier run.

## TRIGGER : programmation horaire du scénario

Dans l'interface actuelle de Make, ce n'est pas un module à chercher/ajouter
sur le canevas (chercher "Schedule" dans la recherche d'apps renvoie des apps
tierces sans rapport, pas le bon outil). C'est un réglage du scénario entier :

1. Ajoute d'abord ton module 1 (GET, ci-dessous) — c'est lui le premier module
   du canevas
2. Clique l'icône **horloge** en bas à gauche du canevas (à côté du bouton
   "Run once")
3. Choisis **"At regular intervals"** → "Every 1 Days" (le référentiel Data ES
   est mis à jour quotidiennement, pas besoin de plus fréquent)

## Module 1 — GET : HTTP > Make a request

Source : **Data ES**, le Recensement des Équipements Sportifs du ministère chargé
des Sports — base ouverte et exhaustive (330 000+ équipements en France).
Plateforme Opendatasoft, hébergée sur `equipements.sports.gouv.fr`.

- URL : `https://equipements.sports.gouv.fr/api/explore/v2.1/catalog/datasets/data-es/records`
- Méthode : GET
- Query string :
  - `where` : filtre sur la discipline basket-ball (le nom exact du champ discipline
    doit être vérifié dans l'aperçu de réponse Make — voir encadré ci-dessous)
  - `limit` : commence à `20` pour le premier test, augmente une fois le flux validé
- Parse response : activer (Make convertit le JSON en structure exploitable)

**⚠️ À vérifier toi-même avant de construire la suite** : je n'ai pas d'accès réseau
sortant depuis cette session sandbox pour interroger l'API en direct, donc je ne
peux pas te garantir les noms de champs exacts du JSON renvoyé. Lance ce module
seul, ouvre l'onglet "Output" et note les vrais noms de champs (nom de
l'équipement, commune, code postal, adresse, coordonnées GPS, type d'équipement,
discipline). Ajuste le `where` et le mapping du module 2 en conséquence — c'est
l'étape "Output inspecté" de la Definition of Done du Sprint 1.

Noms de champs les plus probables sur ce jeu de données (à confirmer) :
`inst_nom`, `equip_nom`, `equip_type_name`, `inst_adresse`, `inst_cp`,
`inst_com_nom`, `equip_x`/`equip_y` ou `geo_point_2d`, `equip_aps_nom` (discipline).

## Module 2 — TRANSFORM : Set variable(s)

Prépare un item propre par terrain, à partir des champs bruts trouvés au module 1 :

| Variable Make   | Vient de (champ Data ES, à confirmer) |
|-----------------|----------------------------------------|
| `source_id`     | identifiant de l'équipement             |
| `nom`           | nom de l'équipement                     |
| `commune`       | commune                                 |
| `code_postal`   | code postal                             |
| `adresse`       | adresse                                 |
| `latitude`      | coordonnée Y / lat                      |
| `longitude`     | coordonnée X / lon                      |
| `type_equipement` | type d'équipement                     |
| `acces_libre`   | à déduire du champ "accès libre" si présent, sinon `true` par défaut |

## Module 3 — AI : Anthropic (Claude) — Create a Message

Rôle : Claude est ici **un module spécialisé dans un chemin prédéfini** (pas un
agent) — il reçoit la donnée transformée, produit une sortie structurée, rien de plus.

- Modèle : `claude-sonnet-5` (ou l'alias disponible dans le connecteur Anthropic de Make)
- Prompt système/utilisateur (à adapter dans le module) :

  ```
  Voici un équipement sportif : nom="{{nom}}", commune="{{commune}}",
  type="{{type_equipement}}".
  Réponds uniquement en JSON avec exactement ces deux clés :
  {"accroche": "une phrase courte et conviviale invitant à venir jouer ici",
   "categorie": "Plein air" | "Salle" | "Scolaire"}
  ```

- Sortie attendue (2 champs, comme "résumé/catégorie/score" dans le brief) :
  `accroche`, `categorie`

- Parse la réponse JSON de Claude (module JSON > Parse JSON) pour obtenir
  `ai_accroche` et `ai_categorie` en variables exploitables au module suivant.

## Module 4 — SAVE : Supabase — Create a Row (ou Upsert a Row si disponible)

Table : `terrains` (créée via `supabase/schema.sql`).

### Le mapping

| Sortie du pipeline | Colonne Supabase   |
|---------------------|--------------------|
| `source_id`          | `source_id`        |
| `nom`                | `nom`               |
| `commune`            | `commune`           |
| `code_postal`        | `code_postal`       |
| `adresse`            | `adresse`           |
| `latitude`           | `latitude`          |
| `longitude`          | `longitude`         |
| `type_equipement`    | `type_equipement`   |
| `acces_libre`        | `acces_libre`       |
| `accroche` (Claude)  | `ai_accroche`       |
| `categorie` (Claude) | `ai_categorie`      |

Utilise **Upsert** sur `source_id` si le module Supabase de Make le permet,
pour que les runs suivants mettent à jour les lignes existantes au lieu de
créer des doublons. Sinon, ajoute un module "Search Rows" avant le SAVE pour
vérifier si `source_id` existe déjà (cas "Et si l'article existe déjà ?" du
brief) et ne créer que les nouvelles lignes.

## Definition of Done (calquée sur le brief, page "Definition of Done J2")

- [ ] Une vraie source (Data ES)
- [ ] Un déclencheur (scénario programmé "At regular intervals")
- [ ] Un scénario Make qui tourne sans erreur
- [ ] Un traitement IA (Claude, sortie structurée)
- [ ] Une écriture Supabase (`terrains`)
- [ ] Une lecture Supabase depuis le frontend (voir `streetball-app.html`, onglet "Carte France")
- [ ] Une donnée visible dans l'app
- [ ] Un flux testé module par module, pas d'un coup

## Debug (mantra du brief)

> Où la donnée s'est-elle arrêtée ?

TRIGGER → SOURCE → TRANSFORM → AI → SAVE → DISPLAY : ouvre chaque module dans
Make et regarde son output réel avant de passer au suivant.
