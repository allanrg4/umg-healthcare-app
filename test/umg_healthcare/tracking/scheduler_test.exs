defmodule UmgHealthcare.Tracking.SchedulerTest do
  use ExUnit.Case, async: true

  alias UmgHealthcare.Tracking.Scheduler

  # Guatemala is UTC-6 all year (no daylight saving time).

  test "scheduled_at/4 converts a local time plus offset into UTC" do
    assert Scheduler.scheduled_at(~T[07:00:00], 30, ~D[2026-09-28]) == ~U[2026-09-28 13:30:00Z]
    assert Scheduler.scheduled_at(~T[00:10:00], -30, ~D[2026-09-28]) == ~U[2026-09-28 05:40:00Z]
    assert Scheduler.scheduled_at(~T[21:00:00], 0, ~D[2026-09-28]) == ~U[2026-09-29 03:00:00Z]
  end

  test "day_range/1 returns the UTC bounds of a local day" do
    assert Scheduler.day_range(~D[2026-09-28]) ==
             {~U[2026-09-28 06:00:00Z], ~U[2026-09-29 06:00:00Z]}
  end

  test "today/1 gives the local date" do
    assert Scheduler.today(~U[2026-09-29 03:00:00Z]) == ~D[2026-09-28]
    assert Scheduler.today(~U[2026-09-29 06:00:00Z]) == ~D[2026-09-29]
  end

  test "status/3 is pending until one hour after the scheduled time" do
    dose = %{scheduled_at: ~U[2026-09-28 13:00:00Z], taken_at: nil}

    assert Scheduler.status(dose, ~U[2026-09-28 12:00:00Z]) == :pending
    assert Scheduler.status(dose, ~U[2026-09-28 14:00:00Z]) == :pending
    assert Scheduler.status(dose, ~U[2026-09-28 14:00:01Z]) == :missed
    assert Scheduler.status(dose, ~U[2026-09-28 13:31:00Z], 30) == :missed

    taken = %{dose | taken_at: ~U[2026-09-28 13:05:00Z]}
    assert Scheduler.status(taken, ~U[2026-09-29 00:00:00Z]) == :taken
  end

  test "minutes_until/2 can be negative" do
    dose = %{scheduled_at: ~U[2026-09-28 13:00:00Z]}

    assert Scheduler.minutes_until(dose, ~U[2026-09-28 12:35:00Z]) == 25
    assert Scheduler.minutes_until(dose, ~U[2026-09-28 13:10:00Z]) == -10
  end
end
