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
    <section class="mb-8" id={"#{@id}-summary"}>
      <h2 class="text-lg font-semibold mb-2">{@title}</h2>

      <div class="stats shadow mb-4">
        <div class="stat">
          <div class="stat-title">Cumplimiento</div>
          <div class="stat-value">{@summary.percentage}%</div>
          <div class="stat-desc">{@summary.taken} de {@summary.expected} tomas a tiempo</div>
        </div>
        <div class="stat">
          <div class="stat-title">Omitidas</div>
          <div class="stat-value">{@summary.missed}</div>
        </div>
        <div class="stat">
          <div class="stat-title">Pendientes</div>
          <div class="stat-value">{@summary.pending}</div>
        </div>
      </div>

      <p :if={@show_doses and @summary.doses == []} class="opacity-70">
        No hay tomas registradas en este período.
      </p>

      <.table :if={@show_doses and @summary.doses != []} id={@id} rows={@summary.doses}>
        <:col :let={dose} label="Fecha">{format_date(dose.scheduled_at)}</:col>
        <:col :let={dose} label="Hora">{format_time(dose.scheduled_at)}</:col>
        <:col :let={dose} label="Medicamento">
          {dose.dose_schedule.prescription.medication.name}
        </:col>
        <:col :let={dose} label="Estado">{status_label(Scheduler.status(dose, @now))}</:col>
      </.table>
    </section>
    """
  end
end
