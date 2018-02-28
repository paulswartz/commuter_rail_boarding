defmodule ConfigHelpersTest do
  @moduledoc false
  use ExUnit.Case, async: true
  import ConfigHelpers

  setup do
    Application.put_env(
      :commuter_rail_boarding,
      __MODULE__,
      environment_variable: {:system, "PATH"},
      value: :value
    )

    on_exit(fn ->
      Application.delete_env(:commuter_rail_boarding, __MODULE__)
    end)
  end

  describe "config/2" do
    test "returns an environment variable" do
      assert config(__MODULE__, :environment_variable) == System.get_env("PATH")
    end

    test "returns a value" do
      assert config(__MODULE__, :value) == :value
    end
  end
end
