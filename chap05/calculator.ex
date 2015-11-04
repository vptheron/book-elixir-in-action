defmodule Calculator do

  def start() do
    spawn(fn -> loop(0) end)
  end

  def add(pid, n), do: send(pid, {:add, n})
 
  def sub(pid, n), do: send(pid, {:sub, n})

  def mul(pid, n), do: send(pid, {:mul, n})

  def div(pid, n), do: send(pid, {:div, n})

  def value(pid) do
  	send(pid, {:value, self})
  	receive do
  		{:response, value} -> value
  	after 2000 -> {:error, :timeout}
    end
  end

  defp loop(current_value) do
    new_value = receive do
      message -> 
        process_message(current_value, message)
    end

    loop(new_value)
  end

  defp process_message(current_value, {:value, caller}) do
    send(caller, {:response, current_value})
    current_value
  end

  defp process_message(
  	current_value, 
  	{:add, value}), do: current_value + value

  defp process_message(
  	current_value, 
  	{:sub, value}), do: current_value - value

  defp process_message(
  	current_value, 
  	{:mul, value}), do: current_value * value

  defp process_message(
  	current_value,
  	{:div, value}), do: current_value / value

  defp process_message(current_value, invalid_req) do 
    IO.puts "invalid request #{inspect invalid_req}"
    current_value
  end

end