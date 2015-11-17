defmodule Todo.Supervisor do
  use Supervisor

  def start_link do
  	Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    processes = [
      worker(Todo.Cache, []),
      worker(Todo.Database, ["./persist/"])
    ]
    supervise(
      processes, 
      strategy: :one_for_one)
  end

end