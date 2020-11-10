defmodule NodeManager do
  @moduledoc false

  def set_up_other_node do
    Cluster.setup()

    System.at_exit(fn _status_code ->
      :rpc.call(other_node(), :init, :stop, [])
    end)

    wait_for_other_node_up()
  end

  def spawn_proc_on_other_node do
    Node.spawn(other_node(), Process, :sleep, [:infinity])
  end

  defp other_node do
    :"b@#{:net_adm.localhost()}"
  end

  defp wait_for_other_node_up do
    case :net_adm.ping(other_node()) do
      :pong ->
        :ok

      :pang ->
        Process.sleep(1_000)
        wait_for_other_node_up()
    end
  end

  def rpc_call_other_node(module, function, args) do
    :rpc.call(other_node(), module, function, args)
  end

  def reset_repg2 do
    for cmd <- [:stop, :start] do
      for cur_node <- [other_node(), node()] do
        :rpc.call(cur_node, __MODULE__, Application, cmd, [:repg2])
      end
    end
  end

  def reset_other_node do
    rpc_call_other_node(__MODULE__, :reset_node, [])
  end

  def reset_node do
    :ok = Application.stop(:repg2)
    :ok = Application.start(:repg2)
  end

  def kill_other_node do
    Node.monitor(other_node(), true)
    :slave.stop(:"b@127.0.0.1")

    receive do
      {:nodedown, :"b@127.0.0.1"} -> Process.sleep(1_000)
    end

    Node.monitor(other_node(), false)
    :ok
  end
end
