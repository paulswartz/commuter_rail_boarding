defmodule Busloc.Cmd.Sqlcmd do
  @moduledoc """
  Executes a `sqlcmd` script to retrieve the operator data.
  """
  @behaviour Busloc.Cmd
  require Logger

  def sql do
    ~s[DECLARE @max_calendar_id as numeric(10,0);
      set @max_calendar_id = (select max(calendar_id)
        FROM TMDailylog.dbo.DAILY_WORK_PIECE);
      SELECT PROPERTY_TAG as 'vehicle_id'
        ,LAST_NAME as 'operator_name'
        ,ONBOARD_LOGON_ID as 'operator_id'
        ,BLOCK_ABBR as 'block_id'
        ,RUN_DESIGNATOR AS 'run_id'
      FROM TMDailylog.dbo.DAILY_WORK_PIECE
      INNER JOIN tmmain.dbo.VEHICLE ON current_vehicle_id = vehicle.vehicle_id
      INNER JOIN tmmain.dbo.operator ON current_operator_id = operator.operator_id
      INNER JOIN tmmain.dbo.work_piece ON daily_work_piece.work_piece_id = work_piece.work_piece_id
      INNER JOIN tmmain.dbo.block ON work_piece.block_id = block.block_id
      INNER JOIN tmmain.dbo.run ON work_piece.run_id = run.run_id
      WHERE calendar_id = @max_calendar_id
        AND  actual_logoff_time IS NULL
      ORDER BY PROPERTY_TAG]
  end

  @impl Busloc.Cmd
  def can_connect? do
    case System.cmd("sqlcmd", ["-l", "1", "-Q", "select 1"], stderr_to_stdout: true) do
      {_, 0} -> true
      _ -> false
    end
  rescue
    ErlangError -> false
  end

  @impl Busloc.Cmd
  def cmd do
    {data, 0} = System.cmd("sqlcmd", cmd_list(), stderr_to_stdout: true)
    data
  end

  def cmd_list do
    query = sql()

    cmd_list = [
      "-s",
      ",",
      "-Q",
      query
    ]

    Logger.debug(fn ->
      "executing TM query: #{query}"
    end)

    cmd_list
  end
end
