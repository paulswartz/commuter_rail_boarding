defmodule TripUpdates.ProducerConsumerTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import TripUpdates.ProducerConsumer
  alias BoardingStatus

  describe "handle_events/3" do
    test "returns a TripUpdates_enhanced.json file" do
      {_, state, _} = init([])
      statuses = [
        %BoardingStatus{
          stop_id: "North Station",
          trip_id: "CR-Weekday-Fall-17-315",
          direction_id: 0,
          scheduled_time: DateTime.from_unix!(1518797520),
          status: :on_time
        }
      ]
      assert {:noreply, [{"TripUpdates_enhanced.json", "{" <> _}], ^state} =
        handle_events([statuses], :from, state)
    end
  end
end
