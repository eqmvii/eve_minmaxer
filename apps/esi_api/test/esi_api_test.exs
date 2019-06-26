defmodule EsiApiTest do
  use ExUnit.Case
  doctest EsiApi

  # TODO ERIC more of this
  test "greets the world" do
    assert EsiApi.hello() == :world
  end

  test "plex_price/0 returns the current plex price" do
    assert EsiApi.plex_price()
  end
end
