defmodule TripUpdates do
  @moduledoc """
  Responsible for converting lists of BoardingStatus structs into an enhanced TripUpdates JSON feed

  The basic TripUpdates feed is a Protobuf, documented here: https://developers.google.com/transit/gtfs-realtime/guides/trip-updates

  The enhanced JSON feed takes the Protobuf, expands it into JSON, and adds some additional fields.
  """

  def to_map(boarding_statuses) do
    current_time = System.system_time(:second)

    %{
      header: header(current_time),
      entity: entity(current_time, boarding_statuses)
    }
  end

  def header(current_time) do
    %{
      gtfs_realtime_version: "1.0",
      timestamp: current_time
    }
  end

  def entity(current_time, boarding_statuses) do
    for {_trip_id, trip_statuses} <-
          Enum.group_by(boarding_statuses, & &1.trip_id),
        update <- trip_update(current_time, trip_statuses) do
      update
    end
  end

  def trip_update(_current_time, []) do
    []
  end

  def trip_update(current_time, [%BoardingStatus{} = bs | _] = statuses) do
    [
      %{
        id: "#{current_time}_#{bs.trip_id}",
        trip_update: %{
          trip: trip(bs),
          stop_time_update: Enum.map(statuses, &stop_time_update/1)
        }
      }
    ]
  end

  def trip(%BoardingStatus{} = bs) do
    start_date =
      case bs.scheduled_time do
        :unknown -> DateHelpers.service_date()
        dt -> DateHelpers.service_date(dt)
      end

    Map.merge(
      %{
        trip_id: bs.trip_id,
        route_id: bs.route_id,
        start_date: start_date,
        schedule_relationship: schedule_relationship(bs)
      },
      direction_id_map(bs.direction_id)
    )
  end

  def stop_time_update(%BoardingStatus{} = bs) do
    Enum.reduce(
      [
        stop_sequence_map(bs.stop_sequence),
        boarding_status_map(bs.status),
        platform_id_map(bs.stop_id, bs.track),
        %{stop_id: bs.stop_id}
      ],
      &Map.merge/2
    )
  end

  def schedule_relationship(%BoardingStatus{added?: true}) do
    "ADDED"
  end

  def schedule_relationship(%BoardingStatus{}) do
    "SCHEDULED"
  end

  def direction_id_map(:unknown) do
    %{}
  end

  def direction_id_map(direction_id) do
    %{direction_id: direction_id}
  end

  def stop_sequence_map(:unknown) do
    %{}
  end

  def stop_sequence_map(stop_sequence) do
    %{stop_sequence: stop_sequence}
  end

  def boarding_status_map(:unknown) do
    %{}
  end

  def boarding_status_map(status) do
    %{
      boarding_status: status
    }
  end

  def platform_id_map(_, "") do
    %{}
  end

  def platform_id_map(stop_id, track) do
    platform_id = "#{stop_id}-#{String.pad_leading(track, 2, ["0"])}"

    %{
      stop_id: platform_id
    }
  end
end
