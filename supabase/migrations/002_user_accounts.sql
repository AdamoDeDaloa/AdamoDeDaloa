-- Be4Ball — Comptes utilisateurs (voir ACCOUNTS.md)
-- À exécuter dans Supabase après supabase/schema.sql.
-- Remplace favoris.session_id (texte libre, anonyme) par favoris.user_id
-- (lié à auth.users, la table de comptes gérée par Supabase Auth).

alter table favoris add column if not exists user_id uuid references auth.users(id);

-- session_id devient optionnel : gardé pour ne pas casser les lignes déjà
-- créées pendant les tests J3, mais plus utilisé pour les nouvelles écritures.
alter table favoris alter column session_id drop not null;

-- Remplace la policy ouverte du J3 (tout le monde peut tout lire/écrire,
-- faute de vrais comptes) par des règles strictes par utilisateur.
drop policy if exists "Lecture et écriture publiques des favoris" on favoris;

create policy "Un joueur voit ses propres favoris"
  on favoris for select
  using (auth.uid() = user_id);

create policy "Un joueur ajoute ses propres favoris"
  on favoris for insert
  with check (auth.uid() = user_id);

create policy "Un joueur supprime ses propres favoris"
  on favoris for delete
  using (auth.uid() = user_id);
