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
- Favoris
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

## LATER — J3 Augment

- Agent qui aide à organiser une session (propose un créneau selon les dispos du groupe)
- Agent de matching par niveau (suggère les sessions les plus adaptées à un joueur)
- Chatbot d'aide à la découverte ("trouve-moi un match ce soir near moi, niveau intermédiaire")

---

*Toute nouvelle idée qui sort du MUST du sprint en cours va ici, pas dans le build en cours.*
