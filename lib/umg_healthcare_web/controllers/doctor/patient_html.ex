defmodule UmgHealthcareWeb.Doctor.PatientHTML do
  use UmgHealthcareWeb, :html

  import UmgHealthcareWeb.AdherenceComponents

  alias UmgHealthcare.Treatments.Prescription

  embed_templates "patient_html/*"
end
