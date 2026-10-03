defmodule UmgHealthcare.DemoData do
  @moduledoc "Demo users and data to try the app. Loaded by priv/repo/seeds.exs; see README."

  alias UmgHealthcare.{Accounts, Medications, Patients, Repo, Routines, Tracking, Treatments}
  alias UmgHealthcare.Tracking.Scheduler

  # Shared password of every demo user (test value, documented in the README).
  @password "demo-lapaz-2026"
  @doctor_email "medico@lapaz.test"

  def password, do: @password

  # Loads everything once. Running it again does nothing.
  def load(today \\ Scheduler.today()) do
    if Accounts.get_user_by_email(@doctor_email) do
      :already_loaded
    else
      {:ok, :ok} = Repo.transaction(fn -> load_all(today) end)
      :ok
    end
  end

  defp load_all(today) do
    Medications.seed_catalog()
    meds = Map.new(Medications.list_medications(), &{&1.name, &1})
    doctor = user!(@doctor_email, "Dra. María Ruiz", :doctor)
    days_ago = &Date.add(today, -&1)

    # Ana: hypertension, allergic to penicillin, one prescription about to end.
    ana = patient!("ana@lapaz.test", "Ana López", ~D[1985-03-14], "5555-1234")

    a =
      routine!(ana, [{"Desayuno", ~T[07:00:00]}, {"Cena", ~T[19:00:00]}, {"Dormir", ~T[22:00:00]}])

    allergy!(ana, "Penicilina", "Urticaria", :severe)
    record!(ana, doctor, :diagnosis, "Hipertensión arterial", "Presión 150/95", days_ago.(20))
    record!(ana, doctor, :test_result, "Perfil lipídico", "Colesterol 190 mg/dL", days_ago.(10))
    prescribe!(ana, doctor, meds["Losartán"], days_ago.(10), 30, [{a["Desayuno"], 0}])
    prescribe!(ana, doctor, meds["Omeprazol"], days_ago.(12), 14, [{a["Desayuno"], -30}])
    old = prescribe!(ana, doctor, meds["Ibuprofeno"], days_ago.(40), 5, [{a["Cena"], 0}])
    {:ok, _} = Treatments.complete_prescription(old)
    take_doses!(ana, days_ago.(12), today, 4)

    # Carlos: diabetes, two doses a day, one prescription about to end.
    carlos = patient!("carlos@lapaz.test", "Carlos Pérez", ~D[1958-11-02], "5555-9876")

    c =
      routine!(carlos, [
        {"Desayuno", ~T[06:30:00]},
        {"Cena", ~T[18:30:00]},
        {"Dormir", ~T[21:30:00]}
      ])

    allergy!(carlos, "Polen", "Estornudos", :mild)

    record!(
      carlos,
      doctor,
      :consultation,
      "Control de diabetes",
      "Glucosa 140 mg/dL",
      days_ago.(7)
    )

    prescribe!(carlos, doctor, meds["Metformina"], days_ago.(7), 90, [
      {c["Desayuno"], 0},
      {c["Cena"], 0}
    ])

    prescribe!(carlos, doctor, meds["Atorvastatina"], days_ago.(7), 9, [{c["Dormir"], 0}])
    take_doses!(carlos, days_ago.(7), today, 3)

    # Sofía: new patient without routine, to see the empty states.
    patient!("sofia@lapaz.test", "Sofía Ramírez", ~D[2000-06-21], nil)
    :ok
  end

  defp user!(email, name, role) do
    attrs = %{email: email, password: @password, full_name: name, role: role}
    {:ok, user} = Accounts.register_user(attrs)
    user
  end

  defp patient!(email, name, birth_date, phone) do
    user = user!(email, name, :patient)
    {:ok, patient} = Patients.create_patient(user, %{birth_date: birth_date, phone: phone})
    patient
  end

  defp routine!(patient, activities) do
    Map.new(activities, fn {name, time} ->
      {:ok, activity} = Routines.create_activity(patient, %{name: name, time_of_day: time})
      {name, activity}
    end)
  end

  defp allergy!(patient, substance, reaction, severity) do
    attrs = %{substance: substance, reaction: reaction, severity: severity}
    {:ok, _} = Patients.create_allergy(patient, attrs)
  end

  defp record!(patient, doctor, kind, title, details, date) do
    attrs = %{kind: kind, title: title, details: details, recorded_on: date}
    {:ok, _} = Patients.create_medical_record(patient, doctor, attrs)
  end

  defp prescribe!(patient, doctor, medication, starts_on, days, schedules) do
    {:ok, prescription} =
      Treatments.create_prescription(patient, doctor, %{
        medication_id: medication.id,
        dose: "1 unidad",
        starts_on: starts_on,
        duration_days: days,
        dose_schedules:
          for(
            {activity, offset} <- schedules,
            do: %{activity_id: activity.id, offset_minutes: offset}
          )
      })

    prescription
  end

  # Marks past doses as taken, skipping every `skip_every`-th one so some show as missed.
  defp take_doses!(patient, from, to, skip_every) do
    now = DateTime.utc_now()
    :ok = Tracking.ensure_doses(patient, from, to)

    from
    |> Date.range(to)
    |> Enum.flat_map(&Tracking.list_doses_for_day(patient, &1))
    |> Enum.filter(&(DateTime.compare(&1.scheduled_at, now) == :lt))
    |> Enum.with_index(1)
    |> Enum.reject(fn {_dose, index} -> rem(index, skip_every) == 0 end)
    |> Enum.each(fn {dose, _} ->
      Tracking.mark_taken(dose, DateTime.add(dose.scheduled_at, 10, :minute))
    end)
  end
end
