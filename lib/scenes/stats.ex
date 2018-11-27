defmodule ElixWallet.Scene.Stats do
  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives
  import Scenic.Components
  alias Scenic.ViewPort

  alias ElixWallet.Component.Nav
  alias ElixWallet.Component.HashGraph

  @theme Application.get_env(:elix_wallet, :theme)

  @ping_row_1 110
  @calc_ping_row_1 135
  @calc_ping_row_2 190
  @ping_row_2 165

  @graph Graph.build(font: :roboto, font_size: 24)
         |> line({{130,300}, {1024, 300}},  stroke: {4, @theme.jade})
         |> line({{130,450}, {1024, 450}},  stroke: {4, @theme.jade})
         |> circle(10, id: :lat1_stat,  fill: :green, stroke: {2, :white}, t: {475, @ping_row_1})
         |> text("90ms", id: :lat1, font_size: 16, translate: {450, @calc_ping_row_1})
         |> circle(10, id: :lat2_stat, fill: :clear, stroke: {2, :white}, t: {575, @ping_row_1})
         |> text("0ms", id: :lat2, font_size: 16, translate: {550, @calc_ping_row_1})
         |> circle(10, id: :lat3_stat, fill: :clear, stroke: {2, :white}, t: {675, @ping_row_1})
         |> text("0ms", id: :lat3, font_size: 16, translate: {650, @calc_ping_row_1})
         |> circle(10, id: :lat4_stat, fill: :clear, stroke: {2, :white}, t: {775, @ping_row_1})
         |> text("0ms", id: :lat4, font_size: 16, translate: {750, @calc_ping_row_1})
         |> circle(10, id: :lat5_stat, fill: :clear, stroke: {2, :white}, t: {875, @ping_row_1})
         |> text("0ms", id: :lat5, font_size: 16, translate: {850, @calc_ping_row_1})
         |> circle(10, id: :lat6_stat, fill: :clear, stroke: {2, :white}, t: {475, @ping_row_2})
         |> text("0ms", id: :lat6, font_size: 16, translate: {450, @calc_ping_row_2})
         |> circle(10, id: :lat7_stat, fill: :clear, stroke: {2, :white}, t: {575, @ping_row_2})
         |> text("0ms", id: :lat7, font_size: 16, translate: {550, @calc_ping_row_2})
         |> circle(10, id: :lat8_stat, fill: :clear, stroke: {2, :white}, t: {675, @ping_row_2})
         |> text("0ms", id: :lat8, font_size: 16, translate: {650, @calc_ping_row_2})
         |> circle(10, id: :lat9_stat, fill: :clear, stroke: {2, :white}, t: {775, @ping_row_2})
         |> text("0ms", id: :lat9, font_size: 16, translate: {750, @calc_ping_row_2})
         |> circle(10, id: :lat10_stat, fill: :clear, stroke: {2, :white}, t: {875, @ping_row_2})
         |> text("0ms", id: :lat10, font_size: 16, translate: {850, @calc_ping_row_2})
         |> text("STATISTICS", fill: @theme.nav, font_size: 26, translate: {450, 75})
         |> text("Peers", fill: @theme.nav, font_size: 22, translate: {175, 100})
         |> text("Registered Peers", fill: @theme.nav, font_size: 20, translate: {150, 120})
         |> text("0", id: :reg_peers, font_size: 20, translate: {300, 120})
         |> text("Connected Peers", fill: @theme.nav, font_size: 20, translate: {150, 150})
         |> text("0", id: :con_peers, font_size: 20, translate: {300, 150})
         |> text("Average Ping: ", fill: @theme.nav, font_size: 20, translate: {150, 180})
         |> text("90ms", id: :av_input, font_size: 20, translate: {300, 180})
         |> text("Highest Ping: ", fill: @theme.nav, font_size: 20, translate: {150, 210})
         |> text("90ms", id: :hi_input, font_size: 20, translate: {300, 210})
         |> text("Lowest Ping: ", fill: @theme.nav, font_size: 20, translate: {150, 240})
         |> text("90ms", id: :lo_input, font_size: 20, translate: {300, 240})
         |> text("Current Difficulty: ", fill: @theme.nav, font_size: 20, translate: {450, 320})
         |> text("3000", id: :diff_input, font_size: 20, translate: {600, 320})
         |> text("Current Block: ", fill: @theme.nav, font_size: 20, translate: {150, 320})
         |> text("213", id: :block_input, font_size: 20, translate: {300, 320})
         |> HashGraph.add_to_graph("Graph")
         #|> text("AVERAGE NETWORK HASHRATE: ", fill: @theme.nav, font_size: 20, translate: {150, 550})
        # |> text("0.0", id: :hash_rate, font_size: 20, translate: {150, 580})
         |> Nav.add_to_graph(__MODULE__)


  def init(_, opts) do
    viewport = opts[:viewport]
    {:ok, %ViewPort.Status{size: {vp_width, vp_height}}} = ViewPort.info(viewport)
    push_graph(@graph)
    update(@graph)
    {:ok, %{graph: @graph, viewport: opts[:viewport]}}
  end

  def filter_event(event, _, state), do: {:continue, event, state}


  def update(graph) do
    latency_table = Scenic.Cache.get!("latency_global")


    graph =
      graph
      |> Graph.modify(:reg_peers, &text(&1, Integer.to_string(Scenic.Cache.get!("registered_peers"))))
      |> Graph.modify(:con_peers, &text(&1, Integer.to_string(Scenic.Cache.get!("connected_peers"))))
      |> Graph.modify(:av_input, &text(&1, Integer.to_string(Kernel.round(elem(Scenic.Cache.get!("latency"), 0)))))
      |> Graph.modify(:hi_input, &text(&1, Integer.to_string(Kernel.round(elem(Scenic.Cache.get!("latency"), 2)))))
      |> Graph.modify(:lo_input, &text(&1, Integer.to_string(Kernel.round(elem(Scenic.Cache.get!("latency"), 1)))))
      |> Graph.modify(:block_input, &text(&1, Integer.to_string(elem(Scenic.Cache.get!("block_info"), 0))))
      |> Graph.modify(:diff_input, &text(&1, Float.to_string(elem(Scenic.Cache.get!("block_info"), 1))))
      |> Graph.modify(:lat1, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 0))/1)<>"ms"))
      |> Graph.modify(:lat1_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 0))))
      |> Graph.modify(:lat2, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 1))/1)<>"ms"))
      |> Graph.modify(:lat2_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 1))))
      |> Graph.modify(:lat3, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 2))/1)<>"ms"))
      |> Graph.modify(:lat3_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 2))))
      |> Graph.modify(:lat4, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 3))/1)<>"ms"))
      |> Graph.modify(:lat4_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 3))))
      |> Graph.modify(:lat5, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 4))/1)<>"ms"))
      |> Graph.modify(:lat5_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 4))))
      |> Graph.modify(:lat6, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 5))/1)<>"ms"))
      |> Graph.modify(:lat6_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 5))))
      |> Graph.modify(:lat7, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 6))/1)<>"ms"))
      |> Graph.modify(:lat7_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 6))))
      |> Graph.modify(:lat8, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 7))/1)<>"ms"))
      |> Graph.modify(:lat8_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 7))))
      |> Graph.modify(:lat9, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 8))/1)<>"ms"))
      |> Graph.modify(:lat9_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 8))))
      |> Graph.modify(:lat10, &text(&1, Float.to_string(get_times(Enum.fetch!(latency_table, 9))/1)<>"ms"))
      |> Graph.modify(:lat10_stat, &update_opts(&1, fill: get_status(Enum.fetch!(latency_table, 9))))
      |> HashGraph.add_to_graph("graph")
      |> push_graph()
  end

  defp get_times({id, time}), do: time
  defp get_status({id, time}) when time == 999, do: :red
  defp get_status({id, time}) when time !== 999, do: :green





end
