defmodule Busloc.VehicleTest do
  use ExUnit.Case, async: true
  alias Busloc.Vehicle
  import Busloc.Vehicle
  alias Busloc.Utilities.Time, as: BuslocTime

  doctest Busloc.Vehicle

  describe "from_transitmaster_map/2" do
    test "parses a map into a Vehicle struct" do
      map = %{
        block: "A60-36",
        heading: 135,
        latitude: 42.3218438,
        longitude: -71.1777327,
        timestamp: "150646",
        vehicle_id: "0401"
      }

      datetime = Timex.to_datetime(~N[2018-03-26T15:11:05], "America/New_York")

      expected =
        {:ok,
         %Vehicle{
           vehicle_id: "0401",
           block: "A60-36",
           latitude: 42.3218438,
           longitude: -71.1777327,
           heading: 135,
           source: :transitmaster,
           timestamp: BuslocTime.parse_transitmaster_timestamp("150646", datetime)
         }}

      actual = from_transitmaster_map(map, datetime)
      assert expected == actual
    end

    test "returns an error if we're unable to convert the map" do
      assert {:error, _} = from_transitmaster_map(%{}, DateTime.utc_now())
    end
  end

  describe "log_line/2" do
    test "logs all the data from the vehicle" do
      now = DateTime.from_naive!(~N[2018-03-28T20:15:12], "Etc/UTC")

      vehicle = %Vehicle{
        vehicle_id: "veh_id",
        block: "50",
        latitude: 1.234,
        longitude: -5.678,
        heading: 29,
        source: :transitmaster,
        timestamp: now
      }

      actual = log_line(vehicle, now)
      assert actual =~ ~s(vehicle_id="veh_id")
      assert actual =~ ~s(block="50")
      assert actual =~ "latitude=1.234"
      assert actual =~ "longitude=-5.678"
      assert actual =~ "heading=29"
      assert actual =~ "source=transitmaster"
      assert actual =~ "timestamp=2018-03-28T20:15:12Z"
    end

    test "logs if the time is invalid" do
      now = DateTime.from_unix!(2000)

      vehicle = %Vehicle{
        timestamp: DateTime.from_unix!(0)
      }

      actual = log_line(vehicle, now)
      assert actual =~ "invalid_time=stale"
    end
  end

  describe "from_samsara_json/1" do
    test "parses Poison map to Vehicle struct" do
      json_map = %{
        "heading" => 0,
        "id" => 212_014_918_101_455,
        "latitude" => 42.340632833,
        "location" => "Boston, MA",
        "longitude" => -71.058374,
        "name" => "1718",
        "onTrip" => false,
        "speed" => 0,
        "time" => 1_525_100_949_275,
        "vin" => ""
      }

      expected = %Vehicle{
        block: nil,
        heading: 0,
        latitude: 42.340632833,
        longitude: -71.058374,
        source: :samsara,
        timestamp: DateTime.from_naive!(~N[2018-04-30 15:09:09.275], "Etc/UTC"),
        vehicle_id: "1718"
      }

      actual = from_samsara_json(json_map)
      assert actual == expected
    end
  end

  describe "from_eyeride_json/1" do
    setup do
      json_map = %{
        "id" => "cbd2f411-7107-45f3-9a99-4d31ea6e8bed",
        "bus" => "43915",
        "created_at" => "2018-05-15T10:28:17Z",
        "ins" => 0,
        "outs" => 0,
        "gps" => %{
          "type" => "Point",
          "coordinates" => [
            42.41673,
            -71.1075
          ]
        },
        "route_name" =>
          "MBTA Route 710 North Medford-Medford Square, Meadow Glen Mall or Wellington Station",
        "speed" => "0.000",
        "route_header" => "Doonan St",
        "direction" => "W"
      }

      {:ok, %{json_map: json_map}}
    end

    test "parses Poison map to Vehicle struct", %{json_map: json_map} do
      timestamp = DateTime.from_naive!(~N[2018-05-15T10:28:17], "Etc/UTC")

      assert %Vehicle{
               latitude: 42.41673,
               longitude: -71.1075,
               source: :eyeride,
               timestamp: ^timestamp,
               vehicle_id: "43915"
             } = from_eyeride_json(json_map)
    end
  end
end
