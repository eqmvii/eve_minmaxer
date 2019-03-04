defmodule EsiApiTest do
  use ExUnit.Case
  doctest EsiApi

  test "greets the world" do
    assert EsiApi.hello() == :world
  end
end
