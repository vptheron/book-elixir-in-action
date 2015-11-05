defmodule Todo.Server do

  # Interface
  def start do
    GenServer.start(Todo.Server, nil)
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
  def init(_), do: {:ok, Todo.List.new}

  def handle_cast({:add_entry, entry}, state) do
    {:noreply, Todo.List.add_entry(state, entry)} 
  end

  def handle_cast({:delete_entry, entry_id}, state) do
    {:noreply, Todo.List.delete_entry(state, entry_id)}
  end

  def handle_call({:entries, date}, _, state) do
    {:reply, Todo.List.entries(state, date), state}
  end

end