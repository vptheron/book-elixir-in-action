defmodule Todo.Cache do
  use GenServer

  def start_link do
    IO.puts "Starting to-do cache"
  	GenServer.start_link(
      __MODULE__, 
      nil,
      name: :todo_cache)
  end

  def server_process(list_name) do
    case Todo.Server.whereis(list_name) do
      :undefined ->
  	    GenServer.call(:todo_cache, {:server_process, list_name})
      pid -> pid
    end
  end

  # Callbacks

  def init(_) do
  	{:ok, nil}
  end

  def handle_call(
  	{:server_process, list_name},
  	_,
  	state) do

    case Todo.Server.whereis(list_name) do
      {:ok, todo_server} -> 
        {:reply, todo_server, state}
       
      :undefined ->
        {:ok, new_server} = 
          Todo.ServerSupervisor.start_child(list_name)
        {
          :reply, 
          new_server, 
          state
        }
    end
  end

end
