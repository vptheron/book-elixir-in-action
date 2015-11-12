defmodule Todo.Database do
  use GenServer

  def start(db_folder), do:
    GenServer.start(
      __MODULE__, 
      db_folder, 
      name: :database_server)

  def store(key, data) do
    worker = GenServer.call(:database_server, {:get_worker, key})
    Todo.DatabaseWorker.store(worker, key, data)
  end

  def get(key) do
    worker = GenServer.call(:database_server, {:get_worker, key})
    Todo.DatabaseWorker.get(worker, key)
  end

  def init(db_folder) do
  	File.mkdir_p(db_folder)

    workers = Enum.map(1..3, fn(index) ->
      {:ok, pid} = Todo.DatabaseWorker.start(db_folder)
      {index, pid}
    end) |> Enum.into(HashDict.new)

  	{:ok, workers}
  end

  def handle_call({:get_worker, key}, _, workers) do
    {
      :reply,
      get_worker(workers, key),
      workers
    }
  end

  defp get_worker(workers, key) do
    HashDict.get(workers, :erlang.phash2(key, 3))
  end

end