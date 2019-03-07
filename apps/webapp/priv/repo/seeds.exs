# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Webapp.Repo.insert!(%Webapp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Webapp.Repo.insert!(%Webapp.Testtable{id: 2, name: "Inserted from seeds"});

# heroku run mix run apps/webapp/priv/repo/seeds.exs

# Worked but threw some errors about multiple connections along the way idk
