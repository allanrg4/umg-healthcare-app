defmodule UmgHealthcareWeb.Doctor.RenewalAlertHTML do
  use UmgHealthcareWeb, :html

  alias UmgHealthcare.Treatments.Prescription

  embed_templates "renewal_alert_html/*"

  def days_label(0), do: "Vence hoy"
  def days_label(1), do: "Vence en 1 día"
  def days_label(days) when days > 0, do: "Vence en #{days} días"
  def days_label(-1), do: "Venció hace 1 día"
  def days_label(days), do: "Venció hace #{-days} días"
end
