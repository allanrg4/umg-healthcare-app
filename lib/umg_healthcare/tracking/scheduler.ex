defmodule UmgHealthcare.Tracking.Scheduler do
  @moduledoc "Pure time functions for dose tracking. No database, so they are tested with fixed dates."

  @tolerance_minutes 60
  @utc "Etc/UTC"

  def timezone, do: Application.fetch_env!(:umg_healthcare, :timezone)

  def tolerance_minutes, do: @tolerance_minutes

  # Local date for the UTC instant `now`.
  def today(%DateTime{} = now \\ DateTime.utc_now()) do
    now |> DateTime.shift_zone!(timezone()) |> DateTime.to_date()
  end

  # Local activity time plus an offset, as a UTC datetime on the given date.
  def scheduled_at(%Time{} = time, offset_minutes, %Date{} = date, tz \\ timezone()) do
    date
    |> DateTime.new!(time, tz)
    |> DateTime.add(offset_minutes, :minute)
    |> DateTime.shift_zone!(@utc)
  end

  # Start (inclusive) and end (exclusive) of a local day, in UTC.
  def day_range(%Date{} = date, tz \\ timezone()) do
    start = date |> DateTime.new!(~T[00:00:00], tz) |> DateTime.shift_zone!(@utc)
    {start, DateTime.add(start, 1, :day)}
  end

  # Status of a dose at instant `now`. Never stored, always computed.
  def status(dose, now, tolerance_minutes \\ @tolerance_minutes)

  def status(%{taken_at: %DateTime{}}, _now, _tolerance), do: :taken

  def status(%{scheduled_at: %DateTime{} = at}, %DateTime{} = now, tolerance) do
    deadline = DateTime.add(at, tolerance, :minute)
    if DateTime.compare(now, deadline) == :gt, do: :missed, else: :pending
  end

  # Minutes until the dose (negative once it is past).
  def minutes_until(%{scheduled_at: %DateTime{} = at}, %DateTime{} = now) do
    div(DateTime.diff(at, now, :second), 60)
  end
end
