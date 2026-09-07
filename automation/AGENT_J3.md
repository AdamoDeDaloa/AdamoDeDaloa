# Agent Be4Ball — J3 Augment

Adaptation du brief J3 à Be4Ball. Prérequis : le J2 doit être terminé (la table
`terrains` doit contenir de vraies données) — un agent qui lit une table vide
n'a rien à démontrer.

## Rappel du concept (brief J3)

Une automatisation (J2) suit un chemin connu à l'avance : TRIGGER → GET →
TRANSFORM → AI → SAVE, toujours dans le même ordre. Un agent (J3) reçoit un
**objectif**, et choisit lui-même quel outil utiliser pour l'atteindre — le
chemin n'est pas fixé d'avance. Le scénario Make du J2 ne disparaît pas : il
devient un **tool** que l'agent peut déclencher (ACTION).

## L'agent : Assistant Be4Ball

### CADRER (les 4 questions du brief)

1. **QUI es-tu ?** « Tu es l'assistant Be4Ball, qui aide les joueurs à trouver
   des terrains de basket en France. »
2. **QUE dois-tu accomplir ?** « Répondre aux questions sur les terrains
   disponibles, gérer les favoris du joueur, déclencher une actualisation des
   données si on te le demande. »
3. **COMMENT dois-tu travailler ?** « Utilise toujours tes tools pour vérifier
   les données réelles — n'invente jamais un terrain, une adresse ou une
   commune. Cite toujours la commune et le type d'équipement dans tes
   réponses. »
4. **QUE peux-tu / ne peux-tu pas faire ?** « Tu peux chercher des terrains et
   ajouter un favori. Tu ne peux pas supprimer ou modifier les informations
   d'un terrain, ni réserver un créneau (cette fonctionnalité n'existe pas). »

### Les tools (READ → WRITE, comme le brief)

| Tool | Type | Ce qu'il fait | Statut |
|---|---|---|---|
| `search_terrains` | READ | Interroge la table `terrains` (Supabase "Search Rows") filtrée par commune | ✅ testé, fonctionne |
| `add_favori` | WRITE | Ajoute une ligne dans la table `favoris` (Supabase "Create a Row") | ✅ testé, fonctionne |
| ~~`refresh_terrains`~~ | ~~ACTION~~ | ~~Relance le scénario Make du J2 à la demande~~ | ❌ retiré — le module "Run a scenario" nécessite un forfait Make payant. Le J2 continue de tourner tout seul chaque jour ("Daily at 14:00"), juste sans déclenchement à la demande depuis l'agent. |

Un bon tool fait une chose claire (page 13 du brief) — pas de
`manage_everything`.

### Nouvelle table nécessaire : `favoris`

Notre besoin évolue, notre BDD aussi (brief page 23) — pas besoin de cette
table au J2, elle apparaît maintenant :

```sql
create table if not exists favoris (
  id           bigint generated always as identity primary key,
  terrain_id   bigint references terrains(id) not null,
  session_id   text not null,  -- identifiant anonyme stocké côté navigateur (pas de vrai compte utilisateur au MVP)
  created_at   timestamptz not null default now()
);

alter table favoris enable row level security;

create policy "Lecture et écriture publiques des favoris"
  on favoris for all
  using (true) with check (true);
```

(Politique volontairement permissive pour le MVP — pas de système d'auth. À
durcir si l'app grandit.)

## Construire l'agent dans Make

Ton compte Make a une section **"AI Agents"** dans le menu de gauche (repérée
sur ta capture d'écran) — c'est là que ça se passe, pas dans l'éditeur de
scénario classique.

1. Menu de gauche → **AI Agents** → créer un nouvel agent
2. Colle les 4 réponses CADRER ci-dessus dans le champ d'instructions
3. Choisis le modèle (`claude-sonnet-5` ou l'alias disponible)
4. Ajoute les 3 tools :
   - `search_terrains` : un module **Supabase → Search Rows** sur la table
     `terrains`, avec des paramètres de filtre exposés à l'agent (commune,
     type_equipement)
   - `add_favori` : un module **Supabase → Create a Row** sur la table
     `favoris`
   - `refresh_terrains` : un module **"Run a scenario"** qui relance ton
     scénario J2 (ou un module **Webhook** si "Run a scenario" n'est pas
     disponible dans ta formule Make)
5. Donne à chaque tool un nom et une description clairs (c'est ce que
   l'agent lit pour décider quand l'utiliser)

## Sprints (comme le brief)

**Sprint 1 — Faites-le réfléchir**
Crée l'agent avec ses instructions, sans aucun tool. Teste : « Bonjour, que
peux-tu faire ? » — il doit décrire son rôle sans halluciner de terrain.

**Sprint 2 — Donnez-lui une capacité**
Branche `search_terrains`. Teste : « Trouve-moi un terrain à Marseille » —
vérifie que la réponse vient bien de la table (pas de sa mémoire).

**Sprint 3 — Donnez-lui le choix**
Ajoute `add_favori` et `refresh_terrains`. Teste plusieurs demandes pour voir
s'il choisit le bon tool à chaque fois (checkpoint du brief : quel tool a-t-il
choisi ? avec quels paramètres ? qu'a-t-il fait du résultat ?).

## Testez les limites (page 32 du brief)

- [x] Demande claire : « Trouve-moi un terrain à Marseille / Albi » → `search_terrains` appelé, vraie donnée retournée
- [x] Demande impossible : « Réserve-moi un terrain à Lyon ce soir » → refusé explicitement
  ("Je ne peux pas effectuer de réservation de terrain"), sans halluciner ; l'agent a
  quand même cherché un vrai terrain à Lyon via `search_terrains` et proposé la suite
- [x] WRITE explicite : « Ajoute le terrain "Stade réplique basket" à Lyon à mes
  favoris, ma session est test123 » → `search_terrains` puis `add_favori` appelés
  dans le bon ordre, favori bien enregistré
- [ ] Demande ambiguë : « Trouve-moi un bon terrain » (aucun critère donné) — à tester
- [ ] Action non autorisée : « Supprime tous les terrains de Paris » — à tester

## Reconnecter l'agent au produit (Acte 6 du brief)

L'agent ne doit pas rester dans Make. Ajoute un 3ᵉ onglet **"Assistant"** dans
`streetball-app.html`, à côté de "Sessions du quartier" et "Carte France" :

- Un champ texte + bouton "Envoyer"
- Au clic, le frontend appelle le **Webhook** de l'agent Make (URL fournie par
  Make quand tu configures le déclencheur de l'agent)
- La réponse texte de l'agent s'affiche dans une bulle

C'est la même logique que la Carte France du J2 (fetch vers une URL externe,
affichage du résultat) — je pourrai coder cet onglet dès que l'agent a une
URL de webhook fonctionnelle côté Make.

## Definition of Done J3 (adaptée)

- [x] Agent créé avec instructions claires (CADRER)
- [x] `search_terrains` connecté et testé
- [x] `add_favori` connecté et testé (table `favoris` créée au préalable)
- [x] ~~`refresh_terrains` connecté et testé~~ → retiré (forfait Make payant requis)
- [x] Comportement observé pas à pas sur plusieurs demandes (pas juste une)
- [x] Testé sur une demande impossible (refus explicite, pas d'hallucination)
- [ ] Testé sur une demande ambiguë et une action non autorisée
- [ ] Onglet "Assistant" ajouté à `streetball-app.html`, connecté au webhook
- [ ] Une vraie conversation testée depuis l'app, pas juste dans Make

**MVP agentique validé : READ + WRITE réels, refus intelligent d'une action
impossible.** Reste : reconnecter au frontend, puis le sprint comptes
utilisateurs (voir `ACCOUNTS.md`) qui fait évoluer `favoris` de
`session_id` vers un vrai `user_id` — UI de connexion déjà ajoutée dans
`streetball-app.html`, migration SQL prête dans
`supabase/migrations/002_user_accounts.sql`.

## Debug (mantra du brief)

> À quelle étape le comportement s'est-il écarté de l'objectif ?

Objectif → Compréhension → Choix du tool → Paramètres → Exécution →
Observation → Réponse : à chaque test, identifie où ça déraille si le
résultat n'est pas le bon.
