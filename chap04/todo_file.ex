defmodule TodoList do

  defstruct auto_id: 1, entries: HashDict.new

  def new(entries \\ []) do
    Enum.reduce(
      entries,
      %TodoList{},
      fn(entry, list_acc) ->
        add_entry(list_acc, entry)
      end
    )
  end

  def add_entry(
  	%TodoList{auto_id: auto_id, entries: entries} = todo_list,
  	entry
  ) do
  	entry = Map.put(entry, :id, auto_id)
    new_entries = HashDict.put(entries, auto_id, entry)
  	
  	%TodoList{ todo_list | 
  	  auto_id: auto_id + 1, 
  	  entries: new_entries
  	}
  end

  def entries(%TodoList{entries: entries}, date) do
    entries
    |> Stream.filter(fn({_, entry}) -> entry.date == date end)
    |> Enum.map(fn({_, entry}) -> entry end)
  end

  def update_entry(
    %TodoList{} = todo_list,
    %{id: id} = new_entry
  ) do
  	update_entry(
      todo_list,
      id,
      fn(_) -> new_entry end
  	)
  end

  def update_entry(
  	%TodoList{entries: entries} = todo_list,
  	entry_id,
  	updater_fun
  ) do 
  	case entries[entry_id] do
  		nil -> todo_list
  		old_entry ->
  		  old_entry_id = old_entry.id
  		  new_entry = %{id: ^old_entry_id} = 
  		    updater_fun.(old_entry)
  		  new_entries = HashDict.put(entries, new_entry.id, new_entry)
  		  %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(
    %TodoList{entries: entries} = todo_list,
    entry_id
  ) do 
  	new_entries = HashDict.delete(entries, entry_id)
  	%TodoList{todo_list | entries: new_entries}
  end	
end

defimpl String.Chars, for: TodoList do
  def to_string(_), do: "#TodoList"
end

defimpl Access, for: TodoList do
  def get(c, {_y,_m,_d} = date) do
  	TodoList.entries(c, date)
  end
end

defimpl Collectable, for: TodoList do

  def into(original) do
  	{original, &into_callback/2}
  end

  defp into_callback(todo_list, {:cont, entry}) do
    TodoList.add_entry(todo_list, entry)
  end
  defp into_callback(todo_list, :done), do: todo_list
  defp into_callback(todo_list, :halt), do: :ok

end

defmodule TodoList.CsvImporter do

  def import(file) do
    File.stream!(file)
    |> Stream.map(&String.replace(&1, "\n", ""))
    |> Stream.map(&parse_line(&1))
    |> Stream.map(fn({d,e}) ->
         %{date: d, title: e}
       end)
    |> TodoList.new
  end

  defp parse_line(l) do 
    [date, event] = String.split(l, ",")
    [y,m,d] = 
      String.split(date, "/")
      |> Enum.map(&String.to_integer(&1))
    {{y,m,d}, event}
  end

end