defmodule ElixiumWallet.Supervisor do
  use Supervisor
  require Logger

  def start_link do
    Logger.info("ELIXIUM WALLET SUPERVISOR RUNNING")


    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    #port = 31013
    children = [
      {Elixium.Node.Supervisor, [:"Elixir.ElixiumWallet.PeerRouter"]},
      ElixiumWallet.PeerRouter.Supervisor
    ]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
