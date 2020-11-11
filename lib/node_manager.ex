defmodule NodeManager do
  @moduledoc false

  def spawn_proc_on_other_node do
    _pid = Node.spawn(Cluster.other_node(), Process, :sleep, [:infinity])
  end

  def reset_cluster() do
    for cmd <- [:stop, :start] do
      for cur_node <- [node(), Cluster.other_node()] do
        :rpc.call(cur_node, Application, cmd, [:repg2])
      end
    end

    :ok
  end

  def reset_other_node() do
    Cluster.rpc_other_node(__MODULE__, :reset_this_node, [])
  end

  def reset_this_node() do
    :ok = Application.stop(:repg2)
    :ok = Application.start(:repg2)
  end
end
