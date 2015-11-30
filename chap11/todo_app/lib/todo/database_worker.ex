defmodule Todo.DatabaseWorker do
  
  use GenServer

  def start_link(db_folder, id) do
    IO.puts "Starting database worker #{id}"
    GenServer.start_link(
      __MODULE__, 
      db_folder,
      name: via_tuple(id))
  end

  def store(id, key, data), do:
    GenServer.cast(via_tuple(id), {:store, key, data})

  def get(id, key) do
    GenServer.call(via_tuple(id), {:get, key})
  end

  def init(db_folder) do
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

  defp via_tuple(worker_id) do
    {
      :via, 
      Todo.ProcessRegistry, 
      {:database_worker, worker_id}
    }
  end

end