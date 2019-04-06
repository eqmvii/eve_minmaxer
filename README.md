# EveMinmaxer

A tool for fetching EVE: Online market prices and Optimizing All Kinds Of Things

Currently an early WIP that does market searches.

# Run

`mix phx.server`

or interactive console style

`iex -S mix`

and

`recompile`

 as needed

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

Biggest issue: Only one price is stored, historically, forever. Make it update for prices that are stale.

* Refactor prices and make it have a concept of freshness
* Write tests
* Build out universe info
* Rename heroku app

# Datagrip!

Installed and working. Helpfully queries:

`
SELECT items.*, prices.average_price FROM items
  JOIN prices on items.type_id = prices.type_id
`

# Important hard coded data

* the forge region id: 10000002
* jita structure id: 60003760

# Interesting type_id

34 Tritanium
35 Pyerite
36 Mexallon
37 Isogen
38 Nocxium
40 Megacyte
44992 PLEX (old?)
645 Dominix

# Test data

[
  %{
    "duration" => 90,
    "is_buy_order" => false,
    "issued" => "2019-03-18T23:24:57Z",
    "location_id" => 60003760,
    "min_volume" => 1,
    "order_id" => 5385644363,
    "price" => 4.45,
    "range" => "region",
    "system_id" => 30000153,
    "type_id" => 34,
    "volume_remain" => 8256,
    "volume_total" => 8256
  },
  %{
    "duration" => 90,
    "is_buy_order" => false,
    "issued" => "2019-03-18T23:24:57Z",
    "location_id" => 60003760,
    "min_volume" => 1,
    "order_id" => 5385644363,
    "price" => 0.02,
    "range" => "region",
    "system_id" => 30000153,
    "type_id" => 34,
    "volume_remain" => 8256,
    "volume_total" => 8256
  },
  %{
    "duration" => 90,
    "is_buy_order" => false,
    "issued" => "2019-03-18T23:24:57Z",
    "location_id" => 1,
    "min_volume" => 1,
    "order_id" => 5385644363,
    "price" => 0.02,
    "range" => "region",
    "system_id" => 30000153,
    "type_id" => 34,
    "volume_remain" => 8256,
    "volume_total" => 8256
  }
]

# BUGS: Duplicate items with similar encoded names (warrior+ii and warrior%20)
