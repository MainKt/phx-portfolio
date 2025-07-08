defmodule PortfolioWeb.WritingLive do
  use PortfolioWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "~/writings")
      |> assign(:page_heading, "My Writings")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <section id="writings">
      <article>
        <h2>
          <.link navigate={~p"/writings/wutil-organ-transplants"}>
            [GSoC] wutil with libifconfig and libwpa_client
          </.link>
        </h2>
        <p>After some organ transplants, <code>wutil</code> no longer uses any
          shell calls</p>
      </article>
      <article>
        <h2>
          <.link navigate={~p"/writings/gsoc-proposal"}>
            FreeBSD WiFi Management Utility Proposal
          </.link>
        </h2>
        <p>My GSoC proposal for FreeBSD WiFi Management Utility project</p>
      </article>
    </section>
    """
  end
end
