defmodule UmgHealthcare.Tracking do
  @moduledoc "Dose tracking: materializes doses per day, marks them taken and measures adherence."

  import Ecto.Query, warn: false

  alias UmgHealthcare.Patients.Patient
  alias UmgHealthcare.Repo
  alias UmgHealthcare.Tracking.{Dose, Scheduler}
  alias UmgHealthcare.Treatments

  # Creates the missing doses of the patient for `date` and returns that day's doses.
  def generate_doses_for_day(%Patient{id: patient_id} = patient, %Date{} = date) do
    now = DateTime.utc_now(:second)

    rows =
      for schedule <- Treatments.active_schedules_for(patient, date) do
        %{
          patient_id: patient_id,
          dose_schedule_id: schedule.id,
          scheduled_at:
            Scheduler.scheduled_at(schedule.activity.time_of_day, schedule.offset_minutes, date),
          inserted_at: now,
          updated_at: now
        }
      end

    if rows != [], do: Repo.insert_all(Dose, rows, on_conflict: :nothing)

    list_doses_for_day(patient, date)
  end

  # Generates the doses of every day between `from` and `to` (both included).
  def ensure_doses(%Patient{} = patient, %Date{} = from, %Date{} = to) do
    Enum.each(Date.range(from, to), &generate_doses_for_day(patient, &1))
  end

  def list_doses_for_day(%Patient{id: patient_id}, %Date{} = date) do
    {start, finish} = Scheduler.day_range(date)

    patient_id
    |> doses_query()
    |> where([d], d.scheduled_at >= ^start and d.scheduled_at < ^finish)
    |> Repo.all()
  end

  # Pending doses ordered by time and grouped by instant (several medications at once).
  def upcoming(%Patient{id: patient_id}, %DateTime{} = now, limit \\ 5) do
    cutoff = DateTime.add(now, -Scheduler.tolerance_minutes(), :minute)

    patient_id
    |> doses_query()
    |> where([d], is_nil(d.taken_at) and d.scheduled_at > ^cutoff)
    |> limit(^limit)
    |> Repo.all()
    |> Enum.chunk_by(& &1.scheduled_at)
    |> Enum.map(fn [first | _] = doses -> {first.scheduled_at, doses} end)
  end

  def get_dose!(%Patient{id: patient_id}, id) do
    patient_id |> doses_query() |> Repo.get!(id)
  end

  def mark_taken(%Dose{} = dose, %DateTime{} = now) do
    dose
    |> Ecto.Changeset.change(taken_at: DateTime.truncate(now, :second))
    |> Repo.update()
  end

  # Adherence between two local dates. `expected` only counts doses whose deadline passed.
  def adherence(%Patient{id: patient_id}, %Date{} = from, %Date{} = to, %DateTime{} = now) do
    {start, _} = Scheduler.day_range(from)
    {_, finish} = Scheduler.day_range(to)

    doses =
      patient_id
      |> doses_query()
      |> where([d], d.scheduled_at >= ^start and d.scheduled_at < ^finish)
      |> Repo.all()

    counts =
      doses
      |> Enum.group_by(&Scheduler.status(&1, now))
      |> Map.new(fn {k, v} -> {k, length(v)} end)

    taken = Map.get(counts, :taken, 0)
    missed = Map.get(counts, :missed, 0)
    expected = taken + missed

    %{
      expected: expected,
      taken: taken,
      missed: missed,
      pending: Map.get(counts, :pending, 0),
      percentage: if(expected == 0, do: 0, else: round(taken / expected * 100)),
      doses: doses
    }
  end

  defp doses_query(patient_id) do
    Dose
    |> where(patient_id: ^patient_id)
    |> order_by(asc: :scheduled_at, asc: :id)
    |> preload(dose_schedule: [:activity, prescription: :medication])
  end
end
