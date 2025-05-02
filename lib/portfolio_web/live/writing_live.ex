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
        <h3>
          <.link navigate="/writings/gsoc-proposal">
            FreeBSD WiFi Management Utility Proposal
          </.link>
        </h3>
        <p>My GSoC proposal for FreeBSD WiFi Management Utility project</p>
      </article>
    </section>
    """
  end
end
