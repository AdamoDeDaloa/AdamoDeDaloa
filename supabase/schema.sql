-- Streetball App — J2 — table "terrains"
-- À exécuter dans Supabase (SQL Editor) avant de brancher le scénario Make.
-- MVP J2 = 1 table (voir claude.md). Pas de users, alerts, categories tant
-- que le MVP n'en a pas besoin.

create table if not exists terrains (
  id                bigint generated always as identity primary key,

  -- Donnée brute (source : Data ES — Recensement des Équipements Sportifs,
  -- ministère chargé des Sports, https://equipements.sports.gouv.fr)
  source_id         text unique,            -- identifiant de l'équipement dans Data ES (évite les doublons entre deux runs)
  nom               text not null,
  commune           text,
  code_postal       text,
  adresse           text,
  latitude          double precision,
  longitude         double precision,
  type_equipement   text,                   -- ex : "Terrain de basket-ball", "City stade", "Plateau EPS"
  acces_libre       boolean,

  -- Donnée enrichie par l'IA (Claude, étape AI du scénario Make)
  ai_accroche       text,                   -- courte accroche conviviale générée à partir du nom/type/commune
  ai_categorie      text,                   -- catégorisation simple : "Plein air" / "Salle" / "Scolaire"

  created_at        timestamptz not null default now()
);

create index if not exists terrains_commune_idx on terrains (commune);
create index if not exists terrains_geo_idx on terrains (latitude, longitude);

-- Lecture publique pour le frontend (READ). L'écriture (WRITE) passe
-- uniquement par le scénario Make, authentifié avec la clé service_role —
-- jamais avec la clé anon utilisée côté frontend.
alter table terrains enable row level security;

create policy "Lecture publique des terrains"
  on terrains for select
  using (true);
