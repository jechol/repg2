defmodule RePG2SplitTest do
  @moduledoc false

  use ExUnit.Case

  alias RePG2.NodeManager

  @moduletag :capture_log
  @moduletag :distributed

  setup do
    NodeManager.reset_repg2()
  end

  test "join pid from disconnected node" do
    :ok = RePG2.create(:test_group)

    pid = NodeManager.spawn_proc_on_other_node()

    :ok = NodeManager.kill_other_node()

    Node.list() |> IO.inspect()

    :timer.sleep(1_000)

    assert RePG2.join(:test_group, pid) == :ok

    :timer.sleep(1_000)

    name = :test_group
    assert RePG2.get_members(name) == []

    assert RePG2.get_local_members(name) == []

    assert RePG2.get_closest_pid(name) == {:error, {:no_process, name}}
  end
end
