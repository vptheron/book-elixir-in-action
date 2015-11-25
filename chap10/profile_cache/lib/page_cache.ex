defmodule PageCache do
  use GenServer

  def start_link do
    GenServer.start_link(
      __MODULE__,
      nil,
      name: :page_cache
    )
  end

  def cached(key, f) do
    GenServer.call(
      :page_cache,
      {:cached, key, f}
    )
  end

  def init(_) do
    {:ok, HashDict.new}
  end

  def handle_call({:cached, key, f}, _, cache) do
    case HashDict.fetch(cache, key) do
      {:ok, value} -> {:reply, value, cache}
      :error ->
        value = f.()
        {:reply, value, HashDict.put(cache, key, value)}
    end
  end

end