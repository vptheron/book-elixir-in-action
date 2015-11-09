defmodule Todo.Database do
  use GenServer

  def start(db_folder), do:
    GenServer.start(__MODULE__, db_folder, name: :database_server)

  def store(key, data), do:
    GenServer.cast(:database_server, {:store, key, data})

  def get(key), do:
    GenServer.call(:database_server, {:get, key})

  def init(db_folder) do
  	File.mkdir_p(db_folder)
  	{:ok, db_folder}
  end

  def handle_cast({:store, key, data}, db_folder) do
    file_name(db_folder, key)
    |> File.write!(:erlang.term_to_binary(data))

    {:noreply, db_folder}
  end

  def handle_call({:get, key}, _, db_folder) do
  	data = 
  	  case File.read(file_name(db_folder, key)) do
  	    {:ok, content} -> :erlang.binary_to_term(content)
  	    _ -> nil
  	  end
  	{:reply, data, db_folder}
  end

  defp file_name(folder, key), do:
    "#{folder}/#{key}"

end