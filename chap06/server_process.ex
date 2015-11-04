defmodule ServerProcess do

  def start(callback_module) do
  	spawn(fn ->
      intial_state = callback_module.init
      loop(callback_module, intial_state)
    end)
  end

  def call(server_pid, request) do
    send(server_pid, {:call, request, self})
    receive do
      {:response, response} -> response
    end
  end

  def cast(server_pid, request) do
  	send(server_pid, {:cast, request})
  end

  defp loop(callback_module, state) do
    new_state = receive do
      {:call, request, caller} ->
        {response, new_state} = 
          callback_module.handle_call(request, state)    
        send(caller, {:response, response})
        new_state

      {:cast, request} ->
        callback_module.handle_cast(request, state)
    end

    loop(callback_module, new_state)
  end

end

defmodule KeyValueStore do

  def start do
  	ServerProcess.start(KeyValueStore)
  end

  def put(pid, key, value) do
  	ServerProcess.cast(pid, {:put, key, value})
  end

  def get(pid, key) do
  	ServerProcess.call(pid, {:get, key})
  end

  def init do
  	HashDict.new
  end

  def handle_cast({:put, key, value}, state) do
  	HashDict.put(state, key, value)
  end

  def handle_call({:get, key}, state) do
  	{HashDict.get(state, key), state}
  end

end