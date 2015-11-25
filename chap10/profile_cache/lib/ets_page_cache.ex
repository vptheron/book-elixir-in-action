defmodule EtsPageCache do
  use GenServer

  def start_link do
    GenServer.start_link(
      __MODULE__,
      nil,
      name: :ets_page_cache
    )
  end

  def cached(key, f) do
  	read_cached(key) ||
      GenServer.call(:ets_page_cache,{:cached, key, f})
  end

  def init(_) do
  	:ets.new(
      :ets_page_cache, 
      [:set, :named_table, :protected])
  	{:ok, nil}
  end

  def handle_call({:cached, key, f}, _, state) do
    {
      :reply,
      read_cached(key) || cache_response(key, f),
      state
    }
  end

  defp read_cached(key) do
  	case :ets.lookup(:ets_page_cache, key) do
  	  [{^key, value}] -> value
  	  _ -> nil
  	end
  end

  defp cache_response(key, f) do
    response = f.()
    :ets.insert(:ets_page_cache, {key, response})
    response
  end

end