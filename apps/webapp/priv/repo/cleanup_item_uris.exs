# Ecto.Adapters.SQL.query!(
#   Webapp.Repo, "SELECT * FROM items WHERE name = $1", ["plex"]
# )

Ecto.Adapters.SQL.query!(
  Webapp.Repo,
  "DELETE FROM prices
    WHERE type_id in (
      SELECT type_id FROM items WHERE (name ILIKE '%20%' OR name ILIKE '%=%')
    );", []
)

#  mix run apps/webapp/priv/repo/cleanup_item_uris.exs
# heroku run mix run apps/webapp/priv/repo/cleanup_item_uris.exs

# Worked but threw some errors about multiple connections along the way idk
