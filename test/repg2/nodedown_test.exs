defmodule RePG2.NodeDownTest do
  @moduledoc false

  use ExUnit.Case

  alias NodeManager

  setup do
    NodeManager.reset_repg2()
  end

  test "join remote_pid from already dead node to local pg2" do
    :ok = RePG2.create(:test_group)

    remote_pid = NodeManager.spawn_proc_on_other_node()

    Node.monitor(:"b@127.0.0.1", true)
    :ok = NodeManager.kill_other_node()

    receive do
      {:nodedown, :"b@127.0.0.1"} -> Process.sleep(1_000)
    end

    :ok = RePG2.join(:test_group, remote_pid)

    Process.sleep(1_000)
    assert RePG2.get_members(:test_group) == []
  end
end
