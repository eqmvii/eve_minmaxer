defmodule EsiApiTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  doctest EsiApi

  setup_all do
    HTTPoison.start
  end

  setup do
    ExVCR.Config.cassette_library_dir("fixture/vcr_cassettes")

    :ok
  end

  # TODO ERIC more of this
  test "greets the world" do
    assert EsiApi.hello() == :world
  end

  # TODO ERIC more robust test here
  test "plex_price/0 returns the current plex price" do
    use_cassette "example_api_hit" do
      assert EsiApi.plex_price()
    end
  end
end
