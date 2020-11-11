defmodule RePG2.NodeDownTest do
  @moduledoc false

  use ExUnit.Case

  alias NodeManager

  setup do
    NodeManager.reset_cluster()
    :ok
  end

  test "join remote_pid from already dead node to local pg2" do
    :ok = RePG2.create(:test_group)

    remote_pid = NodeManager.spawn_proc_on_other_node()

    :ok = Cluster.stop_other_node()
    :ok = RePG2.join(:test_group, remote_pid)

    Process.sleep(1_000)
    assert RePG2.get_members(:test_group) == []
  end
end
