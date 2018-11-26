defmodule ElixWallet.Network.Helpers do
  require Logger
  alias Elixium.Node.Supervisor, as: Peer
  alias Elixium.Node.ConnectionHandler
  alias Elixium.Store.Ledger

  def setup() do
   :ets.insert(:scenic_cache_key_table, {"registered_peers", 1, 0})
   :ets.insert(:scenic_cache_key_table, {"connected_peers", 1, 0})
   :ets.insert(:scenic_cache_key_table, {"latency", 1, {0.0, 0.0, 0.0}})
   :ets.insert(:scenic_cache_key_table, {"block_info", 1, {0, 0.0}})
   :ets.insert(:scenic_cache_key_table, {"latency_global", 1, scheduled_latency([0,0,0,0,0,0,0,0,0,0])})
   :ets.insert(:scenic_cache_key_table, {"network_hash", 1, [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]})
end


  def get_stats() do
    connected_peers = Peer.connected_handlers
    registered_peers = Peer.fetch_peers_from_registry(31013)
     get_last_average_blocks
    ping_times = connected_peers |> Enum.map(fn peer ->
      Elixium.Node.ConnectionHandler.ping_peer(peer) end)
    store_latency(ping_times)
     get_block_info()
    case registered_peers do
      [] -> Scenic.Cache.put("registered_peers", 0)
      :not_found -> Scenic.Cache.put("registered_peers", 0)
      _-> Scenic.Cache.put("registered_peers", Enum.count(registered_peers))
    end
    case connected_peers do
      [] -> Scenic.Cache.put("connected_peers", 0)
      :not_found -> Scenic.Cache.put("connected_peers", 0)
      _-> Scenic.Cache.put("connected_peers", Enum.count(connected_peers))
    end
  end

  defp store_latency(times) do
    case times do
      [] ->
        Logger.info("No Network Latency found..")
      _->
      min_ping = Enum.min(times)
      max_ping = Enum.max(times)
      avg_ping = Enum.sum(times) / Enum.count(times)
      global_latency = scheduled_latency(times)
      Scenic.Cache.put("latency_global", global_latency)
      Scenic.Cache.put("latency", {avg_ping/1, min_ping/1, max_ping/1})
    end
  end


  defp scheduled_latency(times) do
    0..9 |> Enum.map(fn id ->
      ping_time = Enum.fetch(times, id)
      case ping_time do
        {:ok, ping} ->
          {id+1, ping}
        :error ->
          {id+1, 999}
      end
    end)
  end

  defp get_block_info() do
    last_block = GenServer.call(:"Elixir.Elixium.Store.LedgerOracle", {:last_block, []}, 20000)
    case last_block do
      :err ->
        difficulty = 0.0
        index = 0
      _->
        difficulty = last_block.difficulty/1
        index = :binary.decode_unsigned(last_block.index)
        Scenic.Cache.put("block_info", {index, difficulty/1})
    end
  end

  def get_last_average_blocks do
    #GenServer.call(:"Elixir.Elixium.Store.LedgerOracle", {:last_block, []}, 20000)
    bin_index = Ledger.last_block() |> IO.inspect(label: "LAST BLOCK FROM LEDGER")
    case bin_index do
      :err ->
        Logger.info("Not Connected to Store Yet")
      _->
        current_index = :binary.decode_unsigned(bin_index.index)
        if current_index > 200 do
          block_range = GenServer.call(:"Elixir.Elixium.Store.LedgerOracle", {:last_n_blocks, [120]}, 20000)
          avg_map = block_range |> Enum.map(fn block -> calculate_hash(block.difficulty) end)
          network_hash = Enum.sum(avg_map) / Enum.count(avg_map)
          check_table_and_insert_hash(Kernel.round(network_hash/1000))
        else
          0
        end
      end
  end

  defp calculate_hash(difficulty), do: difficulty / 120

  defp check_table_and_insert_hash(hash_rate) do
    hash_list = Scenic.Cache.get!("network_hash")
    nine_list = Enum.drop(hash_list, 1)
    reversed_list = Enum.reverse(nine_list)
    built_list = [hash_rate | reversed_list]
    temp_list = Enum.reverse(built_list)
    corrected_values = check_values(temp_list)
    Scenic.Cache.put("network_hash", corrected_values)
  end

  defp check_values([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]), do: [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
  defp check_values([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, j]) do
    IO.puts "This"
    [1*(j/10), 2*(j/10), 3*(j/10), 4*(j/10), 5*(j/10), 6*(j/10), 7*(j/10), 8*(j/10), 9*(j/10), j]
  end
  defp check_values([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, i, j]), do: [1*(i/10), 2*(i/10), 3*(i/10), 4*(i/10), 5*(i/10), 6*(i/10), 7*(i/10), 8*(i/10), i, j]
  defp check_values([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, h, i, j]), do: [1*(h/10), 2*(h/10), 3*(h/10), 4*(h/10), 5*(h/10), 6*(h/10), 7*(h/10), h, i, j]
  defp check_values([0.0, 0.0, 0.0, 0.0, 0.0, 0.0, g, h, i, j]), do: [1*(g/10), 2*(g/10), 3*(g/10), 4*(g/10), 5*(g/10), 6*(g/10), g, h, i, j]
  defp check_values([0.0, 0.0, 0.0, 0.0, 0.0, f, g, h, i, j]), do: [1*(f/10), 2*(f/10), 3*(f/10), 4*(f/10), 5*(f/10), f, g, h, i, j]
  defp check_values([0.0, 0.0, 0.0, 0.0, e, f, g, h, i, j]), do: [1*(e/10), 2*(e/10), 3*(e/10), 4*(e/10), e, f, g, h, i, j]
  defp check_values([0.0, 0.0, 0.0, d, e, f, g, h, i, j]), do: [1*(d/10), 2*(d/10), 3*(d/10), d, e, f, g, h, i, j]
  defp check_values([0.0, 0.0, c, d, e, f, g, h, i, j]), do: [1*(d/10), 2*(d/10), c, d, e, f, g, h, i, j]
  defp check_values([0.0, b, c, d, e, f, g, h, i, j]), do: [1*(d/10), b, c, d, e, f, g, h, i, j]
  defp check_values([a, b, c, d, e, f, g, h, i, j]), do: [a, b, c, d, e, f, g, h, i, j]

end
