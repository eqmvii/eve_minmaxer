# Ecto.Adapters.SQL.query!(
#   Webapp.Repo, "SELECT * FROM items WHERE name = $1", ["plex"]
# )

Ecto.Adapters.SQL.query!(
  Webapp.Repo,
  "DELETE FROM prices
    WHERE type_id in (
      SELECT type_id FROM items WHERE (name ILIKE '%20%' OR name ILIKE '%=%')
    );",
  [])

Ecto.Adapters.SQL.query!(
  Webapp.Repo, "DELETE FROM items WHERE (name ILIKE '%20%' OR name ILIKE '%=%');", []
)

# mix run apps/webapp/priv/repo/cleanup_item_uris.exs
# heroku run mix run apps/webapp/priv/repo/cleanup_item_uris.exs

# Did not seem to work; errors:

# 15:45:31.233 [error] Postgrex.Protocol
# (#PID<0.317.0>) failed to connect: ** (Postgrex.Error) FATAL 53300 (too_many_connections)
# too many connections for role "zdohngdcffzazj"
