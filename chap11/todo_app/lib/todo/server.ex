defmodule Todo.Server do

  # Interface
  def start_link(list_name) do
    IO.puts "Starting Todo Server for #{list_name}"
    GenServer.start_link(
      Todo.Server, 
      list_name,
      name: via_tuple(list_name)
    )
  end

  def whereis(name) do
    Todo.ProcessRegistry.whereis_name(
      {:todo_server, name})
  end
 
  def add_entry(pid, new_entry) do
    GenServer.cast(pid, {:add_entry, new_entry})
  end

  def entries(pid, date) do
    GenServer.call(pid, {:entries, date})
  end

  def delete(pid, entry_id) do
    GenServer.cast(pid, {:delete_entry, entry_id})
  end

  # Callbacks
  def init(list_name) do
    list = Todo.Database.get(list_name) || Todo.List.new
    {:ok, {list, list_name}}
  end

  def handle_cast(
    {:add_entry, entry}, 
    {list, name}) do
    new_list = Todo.List.add_entry(list, entry)
    Todo.Database.store(name, new_list)
    {:noreply, {new_list, name}} 
  end

  def handle_cast(
    {:delete_entry, entry_id}, 
    {list, name}) do
    new_list = Todo.List.delete_entry(list, entry_id)
    Todo.Database.store(name, new_list)
    {:noreply, {new_list, name}}
  end

  def handle_call({:entries, date}, _, {list, _} = state) do
    {:reply, Todo.List.entries(list, date), state}
  end

  defp via_tuple(name) do
    {:via, Todo.ProcessRegistry, {:todo_server, name}}
  end

end