defmodule Busloc.TmShuttle do
  @moduledoc """
  Represents a TransitMaster shuttle login message.
  """
  defstruct [
    :vehicle_id,
    :operator_name,
    :operator_id,
    :block,
    :run
  ]

  @type t :: %__MODULE__{
          vehicle_id: String.t(),
          operator_name: String.t(),
          operator_id: String.t(),
          block: String.t(),
          run: String.t()
        }

  defdelegate log_line(shuttle), to: Busloc.LogHelper, as: :log_struct

  @spec from_map(map) :: [t()]
  def from_map(%{
        "vehicle_id" => vehicle_id,
        "block_id" => block_id,
        "operator_name" => operator_name,
        "operator_id" => operator_id,
        "run_id" => run_id
      }) do
    [
      %__MODULE__{
        vehicle_id: vehicle_id,
        operator_name: operator_name,
        operator_id: operator_id,
        block: block_id,
        run: run_id
      }
    ]
  end

  def from_map(_), do: []
end
