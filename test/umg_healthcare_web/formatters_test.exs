defmodule UmgHealthcareWeb.FormattersTest do
  use ExUnit.Case, async: true

  import UmgHealthcareWeb.Formatters

  test "format_time/1 shows Guatemala local time" do
    assert format_time(~U[2026-09-28 13:30:00Z]) == "07:30"
    assert format_time(~T[19:05:00]) == "19:05"
  end

  test "format_date/1 uses day/month/year" do
    assert format_date(~D[2026-09-28]) == "28/09/2026"
    assert format_date(~U[2026-09-29 03:00:00Z]) == "28/09/2026"
  end

  test "relative_time/2 speaks Spanish" do
    at = ~U[2026-09-28 13:00:00Z]

    assert relative_time(at, ~U[2026-09-28 12:35:00Z]) == "en 25 min"
    assert relative_time(at, ~U[2026-09-28 10:55:00Z]) == "en 2 h 5 min"
    assert relative_time(at, ~U[2026-09-28 13:00:30Z]) == "ahora"
    assert relative_time(at, ~U[2026-09-28 13:10:00Z]) == "hace 10 min"
  end

  test "activity_label/1 describes the anchor" do
    schedule = %{activity: %{name: "Desayuno"}, offset_minutes: 0}

    assert activity_label(schedule) == "con Desayuno"
    assert activity_label(%{schedule | offset_minutes: 30}) == "30 min después de Desayuno"
    assert activity_label(%{schedule | offset_minutes: -15}) == "15 min antes de Desayuno"
  end

  test "labels" do
    assert status_label(:pending) == "Pendiente"
    assert status_label(:taken) == "Tomada"
    assert status_label(:missed) == "Omitida"
    assert severity_label(:severe) == "Grave"
    assert kind_label(:test_result) == "Resultado de prueba"
    assert prescription_status_label(:renewed) == "Renovada"
  end
end
