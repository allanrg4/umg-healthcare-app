defmodule UmgHealthcare.DemoDataTest do
  use UmgHealthcare.DataCase, async: true

  alias UmgHealthcare.{Accounts, DemoData, Patients, Tracking, Treatments}
  alias UmgHealthcare.Tracking.Scheduler

  test "load/0 creates usable demo data only once" do
    assert DemoData.load() == :ok
    assert DemoData.load() == :already_loaded

    doctor = Accounts.get_user_by_email_and_password("medico@lapaz.test", DemoData.password())
    assert doctor.role == :doctor

    patients = Patients.list_patients()
    assert length(patients) == 3

    today = Scheduler.today()
    assert [_, _] = Treatments.due_for_renewal(doctor, today)

    ana = Enum.find(patients, &(&1.user.full_name == "Ana López"))
    summary = Tracking.adherence(ana, Date.add(today, -12), today, DateTime.utc_now())
    assert summary.taken > 0
    assert summary.missed > 0
  end
end
