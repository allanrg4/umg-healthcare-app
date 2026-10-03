defmodule UmgHealthcareWeb.AdherenceComponents do
  @moduledoc "Adherence summary shared by the patient and doctor pages."

  use UmgHealthcareWeb, :html

  alias UmgHealthcare.Tracking.Scheduler

  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :summary, :map, required: true
  attr :now, DateTime, required: true
  attr :show_doses, :boolean, default: true

  def adherence_summary(assigns) do
    ~H"""
    <.panel title={@title} id={"#{@id}-summary"} flush>
      <div class="grid grid-cols-3 divide-x divide-base-300 border-b border-base-300">
        <div class="px-6 py-4">
          <p class="text-xs font-medium uppercase tracking-wide text-base-content/60">
            Cumplimiento
          </p>
          <p class={["mt-1 text-3xl font-bold", percentage_color(@summary)]}>
            {@summary.percentage}%
          </p>
          <p class="text-xs text-base-content/60">
            {@summary.taken} de {@summary.expected} tomas a tiempo
          </p>
          <progress
            class="progress progress-primary mt-2 h-1.5 w-full"
            value={@summary.percentage}
            max="100"
          ></progress>
        </div>
        <div class="px-6 py-4">
          <p class="text-xs font-medium uppercase tracking-wide text-base-content/60">Omitidas</p>
          <p class="mt-1 text-3xl font-bold">{@summary.missed}</p>
        </div>
        <div class="px-6 py-4">
          <p class="text-xs font-medium uppercase tracking-wide text-base-content/60">Pendientes</p>
          <p class="mt-1 text-3xl font-bold">{@summary.pending}</p>
        </div>
      </div>

      <%= if @show_doses do %>
        <.empty_state :if={@summary.doses == []} icon="hero-calendar">
          No hay tomas registradas en este período.
        </.empty_state>
        <.table :if={@summary.doses != []} id={@id} rows={Enum.reverse(@summary.doses)}>
          <:col :let={dose} label="Fecha">{format_date(dose.scheduled_at)}</:col>
          <:col :let={dose} label="Hora">{format_time(dose.scheduled_at)}</:col>
          <:col :let={dose} label="Medicamento">
            {dose.dose_schedule.prescription.medication.name}
          </:col>
          <:col :let={dose} label="Estado">
            <.status_badge status={Scheduler.status(dose, @now)} />
          </:col>
        </.table>
      <% end %>
    </.panel>
    """
  end

  defp percentage_color(%{expected: 0}), do: "text-base-content/40"
  defp percentage_color(%{percentage: p}) when p >= 80, do: "text-success"
  defp percentage_color(%{percentage: p}) when p >= 50, do: "text-warning"
  defp percentage_color(_summary), do: "text-error"
end
