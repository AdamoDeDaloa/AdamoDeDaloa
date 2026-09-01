# ROADMAP.md — Be4Ball

## NOW — J1 Build (interface, données fictives)

**MUST**
- [x] Afficher les terrains (liste avec infos clés : quartier, niveau, surface, éclairage)
- [x] Rechercher / filtrer (par niveau, par quartier)
- [x] Voir le détail d'un terrain (fiche + prochaine session + rejoindre)

**SHOULD** (pas ce sprint, mais proches)
- Créer une session soi-même (formulaire lieu/heure/niveau/places)
- Profil joueur simple (pseudo, niveau, terrains habituels)
- ~~Carte géographique interactive (vraie carte, pas juste une liste)~~ → fait en J2, voir ci-dessous

**COULD** (plus tard, si le temps le permet)
- Badge de fiabilité / présence
- ~~Favoris~~ → planifié en J3 (tool `add_favori` de l'agent, voir ci-dessous)
- Notifications de nouvelles sessions
- Historique des sessions jouées

## NOW — J2 Automate (récupérer les vrais terrains, source réelle)

**MUST**
- [x] Trouver une base de données complète des terrains de basket en France
      → Data ES (Recensement des Équipements Sportifs, ministère des Sports),
      330 000+ équipements, exhaustif, mis à jour quotidiennement
- [x] Concevoir le schéma de données (table `terrains`, `supabase/schema.sql`)
- [x] Décrire le scénario d'automatisation Make module par module
      (`automation/MAKE_SCENARIO.md`) : TRIGGER → GET → TRANSFORM → AI → SAVE
- [x] Ajouter la carte interactive au frontend (onglet "Carte France",
      Leaflet + lecture Supabase), avec exemple de démo tant que Supabase
      n'est pas branché
- [ ] Construire réellement le scénario dans Make et exécuter `schema.sql`
      dans Supabase (à faire côté utilisateur — Claude Code n'a pas accès à
      ces comptes ni au réseau externe depuis ce sandbox)
- [ ] Une vraie donnée qui a traversé tout le pipeline, visible dans l'app

**SHOULD** (pas ce sprint, mais proches)
- Automatiser la création/mise à jour des fiches terrain (upsert sur `source_id`)
- Base de données des sessions (créées par les utilisateurs, en temps réel)
- Notifications automatiques (rappel de session, nouvelle session près de chez soi)

## LATER — J3 Augment (préparé, à construire une fois le J2 terminé)

Plan détaillé : `automation/AGENT_J3.md`. Un agent ≠ une automatisation — il
reçoit un objectif et choisit lui-même son chemin (pas de TRIGGER→GET→SAVE fixe).

**MUST du sprint J3**
- [ ] Agent "Assistant Be4Ball" créé dans Make (section "AI Agents"), instructions cadrées
- [ ] Tool READ : `search_terrains` (interroge la table `terrains`)
- [ ] Tool WRITE : `add_favori` (nouvelle table `favoris`, schéma dans `AGENT_J3.md`)
- [ ] Tool ACTION : `refresh_terrains` (relance le scénario Make du J2 à la demande)
- [ ] Onglet "Assistant" ajouté à `streetball-app.html` (champ + réponse, connecté au webhook de l'agent)
- [ ] Testé sur une demande claire, une ambiguë, une impossible (voir `AGENT_J3.md`)

**Idées plus lointaines** (hors MVP agentique du J3)
- Agent qui aide à organiser une session (propose un créneau selon les dispos du groupe)
- Agent de matching par niveau (suggère les sessions les plus adaptées à un joueur)

---

*Toute nouvelle idée qui sort du MUST du sprint en cours va ici, pas dans le build en cours.*
