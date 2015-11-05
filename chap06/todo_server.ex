defmodule TodoServer do

  # Interface
  def start do
    GenServer.start(TodoServer, nil)
  end
 
  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  # Callbacks
  def init(_), do: {:ok, TodoList.new}

  def handle_cast({:add_entry, entry}, state) do
    {:noreply, TodoList.add_entry(state, entry)} 
  end

  def handle_call({:entries, date}, _, state) do
    {:reply, TodoList.entries(state, date), state}
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