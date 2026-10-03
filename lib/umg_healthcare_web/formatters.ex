defmodule UmgHealthcareWeb.Formatters do
  @moduledoc "Dates, times and labels in Spanish for the templates."

  alias UmgHealthcare.Tracking.Scheduler

  def format_time(%DateTime{} = at) do
    at |> DateTime.shift_zone!(Scheduler.timezone()) |> Calendar.strftime("%H:%M")
  end

  def format_time(%Time{} = time), do: Calendar.strftime(time, "%H:%M")

  def format_date(%Date{} = date), do: Calendar.strftime(date, "%d/%m/%Y")

  def format_date(%DateTime{} = at) do
    at |> DateTime.shift_zone!(Scheduler.timezone()) |> Calendar.strftime("%d/%m/%Y")
  end

  # "en 25 min", "en 2 h 5 min", "ahora" or "hace 10 min".
  def relative_time(%DateTime{} = at, %DateTime{} = now) do
    minutes = div(DateTime.diff(at, now, :second), 60)

    cond do
      minutes < 0 -> "hace #{duration(-minutes)}"
      minutes == 0 -> "ahora"
      true -> "en #{duration(minutes)}"
    end
  end

  defp duration(minutes) when minutes < 60, do: "#{minutes} min"
  defp duration(minutes), do: "#{div(minutes, 60)} h #{rem(minutes, 60)} min"

  def activity_label(%{activity: %{name: name}, offset_minutes: 0}), do: "con #{name}"

  def activity_label(%{activity: %{name: name}, offset_minutes: minutes}) when minutes > 0,
    do: "#{minutes} min después de #{name}"

  def activity_label(%{activity: %{name: name}, offset_minutes: minutes}),
    do: "#{-minutes} min antes de #{name}"

  def status_label(:pending), do: "Pendiente"
  def status_label(:taken), do: "Tomada"
  def status_label(:missed), do: "Omitida"

  def severity_label(:mild), do: "Leve"
  def severity_label(:moderate), do: "Moderada"
  def severity_label(:severe), do: "Grave"

  def kind_label(:consultation), do: "Consulta"
  def kind_label(:diagnosis), do: "Diagnóstico"
  def kind_label(:test_result), do: "Resultado de prueba"

  def prescription_status_label(:active), do: "Activa"
  def prescription_status_label(:completed), do: "Finalizada"
  def prescription_status_label(:renewed), do: "Renovada"
end
