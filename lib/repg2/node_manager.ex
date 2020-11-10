defmodule RePG2.NodeManager do
  @moduledoc false

  def set_up_other_node do
    Cluster.setup()

    System.at_exit(fn _status_code ->
      :rpc.call(other_node(), :init, :stop, [])
    end)

    wait_for_other_node_up()
  end

  def spawn_proc_on_other_node do
    Node.spawn(other_node(), __MODULE__, :receive_forever, [])
  end

  def receive_forever do
    Process.sleep(:infinity)

    :ok
  end

  def other_node do
    "a@" <> hostname = node() |> to_string()

    :"b@#{hostname}"
  end

  def wait_for_other_node_up do
    IO.puts("ping...")

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
    rpc_call_other_node(Application, :stop, [:repg2])
    _ = Application.stop(:repg2)

    :ok = rpc_call_other_node(Application, :start, [:repg2])
    :ok = Application.start(:repg2)
  end

  def reset_other_node do
    rpc_call_other_node(__MODULE__, :reset_node, [])
  end

  def stop_repg2_other_node do
    rpc_call_other_node(Application, :stop, [:repg2])
  end

  def reset_node do
    _ = Application.stop(:repg2)
    :ok = Application.start(:repg2)
  end

  def disconnect_other_node do
    rpc_call_other_node(__MODULE__, :disconnect, [])
  end

  def kill_other_node do
    :slave.stop(:"b@127.0.0.1")
  end

  def disconnect do
    :ok = Node.stop()
    Process.sleep(1_000)
    {:ok, _} = Node.start(:b, :shortnames)
  end
end
