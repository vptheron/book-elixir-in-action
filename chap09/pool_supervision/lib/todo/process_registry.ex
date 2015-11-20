defmodule Todo.ProcessRegistry do
  use GenServer

  import Kernel, except: [send: 2]

  def start_link do
  	GenServer.start_link(
  		__MODULE__, 
  		nil,
  		name: :process_registry)
  end

  def register_name(name, pid) do
  	GenServer.call(
      :process_registry, 
      {:register, name, pid})
  end

  def whereis_name(name) do
  	GenServer.call(
  		:process_registry,
  		{:whereis, name})
  end

  def send(name, msg) do
  	case whereis_name(name) do
  	  :undefined -> {:badarg, {name, msg}}
  	  pid ->
  	  	Kernel.send(pid, msg)
  	  	pid
  	end
  end

  def unregister_name(name) do
  	GenServer.cast(
  		:process_registry,
  		{:unregister, name})
  end

  def init(_) do
  	{:ok, HashDict.new}
  end

  def handle_call({:register, name, pid}, _, registry) do
  	case HashDict.get(registry, name) do
  	  nil ->
  	    Process.monitor(pid)
  	    {:reply, :yes, HashDict.put(registry, name, pid)}
  	  _ -> 
  	  	{:reply, :no, registry}
  	 end
  end

  def handle_call({:whereis, name}, _, registry) do
    {
      :reply,
      HashDict.get(registry, name, :undefined),
      registry
    }
  end

  def handle_cast({:unregister, name}, registry) do
  	{:noreply, HashDict.delete(registry, name)}
  end

  def handle_info({:DOWN, _, :process, pid, _}, registry) do
    {:noreply, deregister_pid(registry, pid)}
  end

  defp deregister_pid(registry, pid) do
    Enum.filter(
    	registry, 
    	fn({_,p}) -> p != pid end)
    |> Enum.into(HashDict.new)
  end

end