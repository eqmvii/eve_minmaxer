# EveMinmaxer

A tool for fetching EVE: Online market prices and Optimizing All Kinds Of Things

Currently an early WIP that does market searches.

# Run

mix phx.server

# lol it's on heroku

[https://polar-atoll-75486.herokuapp.com/](https://polar-atoll-75486.herokuapp.com/)

who knows how that happened but it did ~

# Things done

cd apps/webapp
mix ecto.gen.migration items
mix ecto.migrate

cd apps/webapp
mix ecto.gen.migration prices
mix ecto.migrate

# Migrations on heroku log

items:
`heroku run mix ecto.migrate`

prices:
`heroku run mix ecto.migrate`

# Things To Do

* Refactor prices and make it have a concept of freshness
* Write tests
* Build out universe info
* Rename heroku app

