defmodule WebappWeb.Formatter do
  def shorthand(number) do
    digits =
      number
      |> round()
      |> to_string
      |> String.replace_leading("-", "")
      |> String.length()

    cond do
      digits >= 13 ->
        number
        |> process_string_to_money(1_000_000_000, " Trillion")
      digits >= 10 ->
        number
        |> process_string_to_money(1_000_000, " Billion")
      digits >= 7 ->
        number
        |> process_string_to_money(1_000_000, " Million")
      true ->
        number
        |> Float.round()
        |> to_string()
    end
  end

  defp process_string_to_money(number, divisor, unit) do
    number
    |> Kernel./(divisor)
    |> Float.floor(2)
    |> to_string()
    |> Kernel.<>(unit)
  end
end

