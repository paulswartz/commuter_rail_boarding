defmodule TrainLoc.Conflicts.StateTest do
  @moduledoc false
  use ExUnit.Case, async: true
  alias TrainLoc.Conflicts.{Conflict, Conflicts, State}

  setup do
    Application.ensure_all_started(:train_loc)
  end

  test "handles undefined call" do
    assert GenServer.call(State, :invalid_callback) ==
             {:error, "Unknown callback."}
  end

  test "handles undefined cast" do
    GenServer.cast(State, :unknown_cast)
  end

  test "handles undefined message" do
    send(State, :unknown_message)
  end

  test "updates state of known conflicts and returns a diff" do
    conflict1 = %Conflict{
      assign_type: :trip,
      assign_id: 123,
      vehicles: [1111, 2222],
      service_date: ~D[2017-09-02]
    }

    conflict2 = %Conflict{
      assign_type: :block,
      assign_id: 456,
      vehicles: [3333, 4444],
      service_date: ~D[2017-09-02]
    }

    conflict3 = %Conflict{
      assign_type: :block,
      assign_id: 789,
      vehicles: [5555, 6666],
      service_date: ~D[2017-09-01]
    }

    pre_existing = Conflicts.new([conflict1, conflict2])

    # empty
    removed_conflicts = Conflicts.new()

    assert {removed_conflicts, pre_existing} ==
             State.set_conflicts(pre_existing)

    current = Conflicts.new([conflict2, conflict3])

    unseen_conflicts = Conflicts.new([conflict3])
    removed_conflicts = Conflicts.new([conflict1])

    assert {removed_conflicts, unseen_conflicts} ==
             State.set_conflicts(current)

    assert current == State.all_conflicts()
  end
end
