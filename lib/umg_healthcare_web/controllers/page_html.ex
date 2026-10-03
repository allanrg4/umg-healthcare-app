defmodule UmgHealthcareWeb.PageHTML do
  use UmgHealthcareWeb, :html

  embed_templates "page_html/*"

  attr :icon, :string, required: true
  attr :title, :string, required: true
  slot :inner_block, required: true

  def feature(assigns) do
    ~H"""
    <div class="rounded-2xl border border-base-300 bg-base-100 p-6 shadow-sm transition hover:-translate-y-0.5 hover:shadow-md">
      <div class="mb-4 inline-flex size-11 items-center justify-center rounded-xl bg-primary/10 text-primary">
        <.icon name={@icon} class="size-6" />
      </div>
      <h3 class="text-base font-semibold">{@title}</h3>
      <p class="mt-2 text-sm leading-relaxed text-base-content/70">{render_slot(@inner_block)}</p>
    </div>
    """
  end
end
