# Comptes utilisateurs — plan et connexions

Fait suite au J3 (agent validé : `search_terrains` + `add_favori` fonctionnent
avec un `session_id` anonyme). Objectif : remplacer cet identifiant anonyme
par de vrais comptes, pour que les favoris (et plus tard l'historique,
le profil joueur du J1 SHOULD) soient rattachés à une vraie personne, pas à
un identifiant qui se perd si on change de navigateur.

## Choix : Supabase Auth (magic link)

Supabase a un système d'authentification intégré, déjà disponible sur ton
projet sans rien activer. On utilise le mode **magic link** (lien de
connexion envoyé par email) plutôt que mot de passe :

- Cohérent avec la contrainte du projet ("l'app doit rester simple et
  accessible, peu de friction" — `claude.md`)
- Rien à retenir, pas de mot de passe à créer/oublier
- Géré nativement par `@supabase/supabase-js` (déjà chargé dans l'app pour
  la Carte France), aucune nouvelle dépendance

## Ce qui change dans la base de données

`favoris.session_id` (texte libre, non fiable) devient `favoris.user_id`
(lié à `auth.users`, la table de comptes gérée par Supabase). Avec la vraie
identité, on peut enfin restreindre l'accès : chaque joueur ne voit et ne
modifie que ses propres favoris (RLS stricte, remplace la policy ouverte du
J3 qui était volontairement permissive faute de vrais comptes).

Migration SQL : `supabase/migrations/002_user_accounts.sql` (à exécuter dans
Supabase après `schema.sql`, une fois que tu es prêt).

## Ce qui change dans le frontend (`streetball-app.html`)

- Nouveau bloc dans le header : email + bouton "Recevoir un lien de
  connexion" si personne n'est connecté ; email du joueur + "Se déconnecter"
  sinon
- `supabase.auth.onAuthStateChange(...)` pour suivre l'état de connexion en
  temps réel
- La session Supabase (et donc l'identité du joueur) est gérée
  automatiquement par `supabase-js` — rien à stocker à la main

## Ce qui change côté Make (agent J3)

Le tool `add_favori` prenait `session_id` en texte libre décidé par l'agent.
Il doit maintenant recevoir le vrai `user_id` du joueur connecté — une donnée
que **l'agent ne doit pas inventer ni deviner**, elle doit venir du frontend
au moment de l'appel du webhook (une fois l'onglet "Assistant" branché).

**Limite honnête à connaître** : le module Supabase de Make écrit avec ses
propres identifiants (pas ceux du visiteur), donc `add_favori` fait confiance
au `user_id` transmis par le frontend au moment de l'appel — un webhook Make
n'est protégé que par le secret de son URL, pas par une vraie vérification de
session. Acceptable pour un MVP de bootcamp (rien de sensible en jeu), mais à
noter comme limite si le projet grandit : la vraie solution serait de vérifier
le JWT Supabase côté Make avant d'écrire.

## Étapes (dans l'ordre)

1. [ ] Exécuter `supabase/migrations/002_user_accounts.sql` dans Supabase
2. [ ] Vérifier dans Supabase → Authentication que le provider "Email" est
       actif (il l'est par défaut) et que "Magic Link" est bien la méthode
       utilisée (pas de mot de passe requis)
3. [x] Frontend : UI de connexion ajoutée (fait par Claude Code, voir
       `streetball-app.html`)
4. [ ] Onglet "Assistant" ajouté (reste du J3 — voir `AGENT_J3.md`), avec le
       `user_id` du joueur connecté transmis au webhook de l'agent
5. [ ] Tool `add_favori` dans Make : remplacer `session_id` par `user_id`
       dans le mapping
6. [ ] Test de bout en bout : se connecter avec un email, demander à
       l'agent d'ajouter un favori, vérifier dans Supabase que la ligne a
       le bon `user_id` ; se connecter avec un second email et vérifier
       qu'il ne voit pas les favoris du premier

## Definition of Done

- [ ] Un joueur peut se connecter avec juste son email (lien magique)
- [ ] Un favori ajouté est bien rattaché à son compte, pas à un `session_id`
- [ ] Deux comptes différents ne voient pas les favoris l'un de l'autre
      (vérifié via RLS, pas juste côté frontend)
- [ ] Un joueur peut se déconnecter, se reconnecter, et retrouve ses favoris
