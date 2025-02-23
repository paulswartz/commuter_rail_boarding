defmodule TrainLoc.Vehicles.Vehicles do
  @moduledoc """
  Functions for working with collections of vehicles.
  """

  alias TrainLoc.Conflicts.Conflict
  alias TrainLoc.Utilities.Time
  alias TrainLoc.Vehicles.Vehicle

  use Timex

  require Logger

  @spec new() :: %{}
  @spec new([Vehicle.t()]) :: map
  def new do
    %{}
  end

  def new(vehicles) do
    Enum.reduce(vehicles, %{}, fn x, acc -> Map.put(acc, x.vehicle_id, x) end)
  end

  @spec all_vehicles(map) :: [Vehicle.t()]
  def all_vehicles(map) do
    Map.values(map)
  end

  @spec all_ids(map) :: [String.t()]
  def all_ids(map) do
    Map.keys(map)
  end

  @spec get(map, Vehicle.t()) :: Vehicle.t() | nil
  def get(vehicles, vehicle_id) do
    Map.get(vehicles, vehicle_id)
  end

  @spec put(map, Vehicle.t()) :: map
  def put(vehicles, vehicle) do
    Map.put(vehicles, vehicle.vehicle_id, vehicle)
  end

  @doc """
  Updates or inserts vehicles into a map of 'old vehicles'.

  """
  @spec upsert(map, [Vehicle.t()]) :: map
  def upsert(old_vehicles, new_vehicles) do
    log_changed_assigns(old_vehicles, new_vehicles)
    # Convert the incoming list of vehicles to a map
    Enum.reduce(new_vehicles, old_vehicles, fn new_vehicle, acc ->
      _ = Vehicle.log_vehicle(new_vehicle)
      Map.put(acc, new_vehicle.vehicle_id, new_vehicle)
    end)
  end

  @spec delete(map, String.t()) :: map
  def delete(vehicles, vehicle_id) do
    Map.delete(vehicles, vehicle_id)
  end

  @doc """
  Detects conflicting assignments. Returns a list of
  `TrainLoc.Conflicts.Conflict` structs.

  A conflict is when multiple vehicles are assigned to the same trip or block.
  """
  @spec find_duplicate_logons(map) :: [Conflict.t()]
  def find_duplicate_logons(vehicles) do
    same_trip =
      vehicles
      |> Map.values()
      |> Enum.group_by(& &1.trip)
      |> Enum.reject(&reject_group?/1)
      |> Enum.map(&Conflict.from_tuple(&1, :trip))

    same_block =
      vehicles
      |> Map.values()
      |> Enum.group_by(& &1.block)
      |> Enum.reject(&reject_group?/1)
      |> Enum.map(&Conflict.from_tuple(&1, :block))

    Enum.concat(same_trip, same_block)
  end

  @spec reject_group?({String.t(), [Vehicle.t()]}) :: boolean
  defp reject_group?({_, [_]}), do: true
  defp reject_group?({"000", _}), do: true
  defp reject_group?({_, _}), do: false

  @spec log_changed_assigns(map, [Vehicle.t()]) :: any
  defp log_changed_assigns(old_vehicles, new_vehicles) do
    for new <- new_vehicles do
      old = Map.get(old_vehicles, new.vehicle_id, new)

      _ =
        if old.block != new.block do
          Logger.debug(fn ->
            "BLOCK CHANGE #{Time.format_datetime(new.timestamp)} - #{
              new.vehicle_id
            }: #{old.block}->#{new.block}"
          end)
        end

      _ =
        if old.trip != new.trip do
          Logger.debug(fn ->
            "TRIP CHANGE #{Time.format_datetime(new.timestamp)} - #{
              new.vehicle_id
            }: #{old.trip}->#{new.trip}"
          end)
        end
    end

    :ok
  end
end
