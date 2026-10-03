defmodule UmgHealthcare.Treatments.PrescriptionTest do
  use ExUnit.Case, async: true

  alias UmgHealthcare.Treatments.Prescription

  @prescription %Prescription{starts_on: ~D[2026-09-28], duration_days: 7, status: :active}

  test "ends_on/1 counts the first day as day one" do
    assert Prescription.ends_on(@prescription) == ~D[2026-10-04]
    assert Prescription.ends_on(%{@prescription | duration_days: 1}) == ~D[2026-09-28]
  end

  test "active_on?/2 is true only inside the range and while active" do
    assert Prescription.active_on?(@prescription, ~D[2026-09-28])
    assert Prescription.active_on?(@prescription, ~D[2026-10-04])
    refute Prescription.active_on?(@prescription, ~D[2026-09-27])
    refute Prescription.active_on?(@prescription, ~D[2026-10-05])
    refute Prescription.active_on?(%{@prescription | status: :completed}, ~D[2026-09-28])
  end
end
