defmodule Todo.PoolSupervisor do
  use Supervisor

  def start_link(db_folder, pool_size) do
  	Supervisor.start_link(
  	  __MODULE__,
  	  {db_folder, pool_size}
  	)
  end

  def init({db_folder, pool_size}) do
    processes = for id <- 1..pool_size do
      worker(
        Todo.DatabaseWorker, [db_folder, id],
        id: {:database_worker, id}
      ) 
    end

    supervise(processes, strategy: :one_for_one)
  end

end