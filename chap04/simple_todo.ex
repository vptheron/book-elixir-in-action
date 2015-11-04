defmodule TodoList do

  def new, do: MultiDict.new

  def add_entry(todo, date, event) do
    MultiDict.add(todo, date, event)
  end

  def entries(todo, date) do
    MultiDict.get(todo, date)
  end

end