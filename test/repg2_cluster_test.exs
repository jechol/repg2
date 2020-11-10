defmodule RePG2DistributedTest do
  @moduledoc false

  use ExUnit.Case

  alias RePG2.NodeManager

  @moduletag :capture_log

  setup do
    NodeManager.reset_repg2()
  end

  test "nodes share groups" do
    :ok = RePG2.create(:test_group)
    :ok = RePG2.join(:test_group, self())
    assert_group_membership(:test_group, self())

    remote_pid = NodeManager.spawn_proc_on_other_node()
    :ok = NodeManager.rpc_call_other_node(RePG2, :create, [:test_group2])
    :ok = NodeManager.rpc_call_other_node(RePG2, :join, [:test_group2, remote_pid])
    assert_group_membership(:test_group2, remote_pid)

    :ok = RePG2.leave(:test_group, self())
    assert_no_group_member(:test_group)

    :ok = NodeManager.rpc_call_other_node(RePG2, :leave, [:test_group2, remote_pid])
    assert_no_group_member(:test_group2)
  end

  test "reset remote" do
    :ok = RePG2.create(:test_group)
    :ok = RePG2.join(:test_group, self())
    assert_group_membership(:test_group, self())

    NodeManager.reset_other_node()
    # Wait for newly created remote pg2 to sync
    Process.sleep(1_000)

    assert_group_membership(:test_group, self())
  end

  test "reset local" do
    remote_pid = NodeManager.spawn_proc_on_other_node()

    :ok = NodeManager.rpc_call_other_node(RePG2, :create, [:test_group])
    :ok = NodeManager.rpc_call_other_node(RePG2, :join, [:test_group, remote_pid])

    assert_group_membership(:test_group, remote_pid)

    Application.stop(:repg2)
    :ok = Application.start(:repg2)
    Process.sleep(1_000)

    assert_group_membership(:test_group, remote_pid)
  end

  defp assert_group_membership(name, pid) do
    this_node = node()

    {local_pid, remote_pid} =
      case node(pid) do
        ^this_node -> {[pid], []}
        _ -> {[], [pid]}
      end

    assert RePG2.get_members(name) == [pid]
    assert RePG2.get_local_members(name) == local_pid
    assert RePG2.get_closest_pid(name) == pid

    assert NodeManager.rpc_call_other_node(RePG2, :get_members, [name]) == [pid]
    assert NodeManager.rpc_call_other_node(RePG2, :get_local_members, [name]) == remote_pid
    assert NodeManager.rpc_call_other_node(RePG2, :get_closest_pid, [name]) == pid
  end

  defp assert_no_group_member(name) do
    assert RePG2.get_members(name) == []
    assert RePG2.get_local_members(name) == []
    assert RePG2.get_closest_pid(name) == {:error, {:no_process, name}}

    assert NodeManager.rpc_call_other_node(RePG2, :get_members, [name]) == []
    assert NodeManager.rpc_call_other_node(RePG2, :get_local_members, [name]) == []

    assert NodeManager.rpc_call_other_node(RePG2, :get_closest_pid, [name]) ==
             {:error, {:no_process, name}}
  end
end
