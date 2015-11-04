defmodule ListHelper do

  def list_len(xs), do: do_list_len(xs, 0)

  defp do_list_len([], l), do: l
  defp do_list_len([_h|t], l), do: do_list_len(t, l+1)

  def range(from, to) when from <= to do
    do_range(from, to, [])
  end

  defp do_range(from, from, l), do: [from|l]
  defp do_range(from, to, l) do
    do_range(from, to-1, [to|l])
  end

  def positive(l) do
    do_positive(l, [])
    |> Enum.reverse
  end

  defp do_positive([], ps), do: ps
  defp do_positive([h|t], ps) do
    new_ps = cond do
               h > 0 -> [h|ps]
               true -> ps
             end
    do_positive(t, new_ps)
  end

end