defmodule Geometry do
  @moduledoc "Basic geometry functions"

  @pi 3.14159
 
  @doc "Computes the area of a rectangle"
  @spec rectangle_area(number, number) :: number
  def rectangle_area(a,b), do: a * b

  @doc "Computes the area of a square"
  @spec square_area(number) :: number
  def square_area(a), do: rectangle_area(a,a)

end