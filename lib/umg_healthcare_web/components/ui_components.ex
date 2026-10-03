defmodule UmgHealthcareWeb.UIComponents do
  @moduledoc "Small layout pieces shared by our pages (cards, empty states)."

  use Phoenix.Component

  @doc "White card that groups related content, with an optional title and actions."
  attr :id, :string, default: nil
  attr :title, :string, default: nil
  attr :flush, :boolean, default: false, doc: "no inner padding, for full-width tables"
  slot :inner_block, required: true
  slot :actions

  def panel(assigns) do
    ~H"""
    <section
      id={@id}
      class="overflow-hidden rounded-box border border-base-300 bg-base-100 shadow-sm"
    >
      <div
        :if={@title || @actions != []}
        class="flex flex-wrap items-center justify-between gap-3 border-b border-base-300 px-6 py-4"
      >
        <h2 class="text-base font-semibold">{@title}</h2>
        <div class="flex flex-wrap gap-2">{render_slot(@actions)}</div>
      </div>
      <div class={if(@flush, do: "py-1", else: "p-6")}>
        {render_slot(@inner_block)}
      </div>
    </section>
    """
  end

  @doc "Colored badge for a dose status (:pending, :taken or :missed)."
  attr :status, :atom, required: true

  def status_badge(assigns) do
    ~H"""
    <span class={[
      "badge badge-sm",
      @status == :taken && "badge-success",
      @status == :missed && "badge-error",
      @status == :pending && "badge-ghost"
    ]}>
      {UmgHealthcareWeb.Formatters.status_label(@status)}
    </span>
    """
  end

  @doc "Friendly message for lists without items."
  attr :icon, :string, required: true
  slot :inner_block, required: true

  def empty_state(assigns) do
    ~H"""
    <div class="flex flex-col items-center gap-2 px-6 py-10 text-center text-sm text-base-content/60">
      <span class={[@icon, "size-8 text-base-content/30"]} />
      {render_slot(@inner_block)}
    </div>
    """
  end
end
