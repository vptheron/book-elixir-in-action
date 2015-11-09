defmodule Todo.Cache do
  use GenServer

  def start do
  	GenServer.start(__MODULE__, nil)
  end

  def server_process(pid, list_name) do
  	GenServer.call(pid, {:server_process, list_name})
  end

  # Callbacks

  def init(_) do
    Todo.Database.start("./persist/")
  	{:ok, HashDict.new}
  end

  def handle_call(
  	{:server_process, list_name},
  	_,
  	todo_servers) do

     case HashDict.fetch(todo_servers, list_name) do
       {:ok, todo_server} -> 
         {:reply, todo_server, todo_servers}
       
       :error ->
         {:ok, new_server} = Todo.Server.start(list_name)
         {
          :reply, 
          new_server, 
          HashDict.put(todo_servers, list_name, new_server)
         }
     end
  end

end