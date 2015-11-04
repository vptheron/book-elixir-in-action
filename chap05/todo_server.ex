defmodule TodoServer do

  def start do
    spawn(fn -> loop(TodoList.new) end)
  end

  def add_entry(todo_server, new_entry) do
    send(todo_server, {:add_entry, new_entry})
  end

  def entries(todo_server, date) do
    send(todo_server, {:entries, self, date})
    receive do
      {:entries, entries} -> entries
    after 2000 -> 
      {:error, :timeout}
    end
  end

  defp loop(todo_list) do
    new_todo_list = receive do
      message -> process_message(todo_list, message)
    end

    loop(new_todo_list)
  end

  defp process_message(
    todo_list, 
    {:add_entry, new_entry}) do
    TodoList.add_entry(todo_list, new_entry)
  end
  
  defp process_message(
    todo_list, 
    {:entries, caller, date}) do
    send(
      caller, 
      {:entries, TodoList.entries(date)})
    todo_list
  end

end

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