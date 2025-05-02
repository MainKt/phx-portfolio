defmodule PortfolioWeb.HomeLive do
  use PortfolioWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "~")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <h1>Hi there!</h1>
    """
  end
end
