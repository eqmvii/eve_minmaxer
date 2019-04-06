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
        |> process_string_to_money(1_000_000_000_000, " Trillion")
      digits >= 10 ->
        number
        |> process_string_to_money(1_000_000_000, " Billion")
      digits >= 7 ->
        number
        |> process_string_to_money(1_000_000, " Million")
      true ->
        number
        |> trunc()
        |> add_commas()
    end
  end

  defp process_string_to_money(number, divisor, unit) do
    number
    |> Kernel./(divisor)
    |> Float.floor(2)
    |> to_string()
    |> Kernel.<>(unit)
  end

  defp add_commas(number) do # TODO BUG: This can produce weird numbers of zeros
    digits =
      number
      |> to_string
      |> String.replace_leading("-", "")
      |> String.length()

    if digits > 3 do
      number = number |> to_string
      front_chunk = digits - 3
      front = String.slice(number, 1, front_chunk)
      back = String.slice(number, front_chunk, String.length(number))

      Enum.join([front, ",", back])
    else
      number |> to_string()
    end
  end
end

