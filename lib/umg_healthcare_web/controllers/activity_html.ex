defmodule UmgHealthcareWeb.ActivityHTML do
  use UmgHealthcareWeb, :html

  embed_templates "activity_html/*"

  attr :form, Phoenix.HTML.Form, required: true
  attr :action, :string, required: true
  attr :method, :string, default: "post"
  attr :submit_label, :string, required: true
  def activity_form(assigns)
end
