defmodule PortfolioWeb.WritingLive.WutilLive do
  use PortfolioWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "wutil with libifconfig and libwpa_client")
      |> assign(:page_heading, "wutil with libifconfig and libwpa_client")

    {:ok, socket}
  end

  defmacrop md(file_path) do
    file_path
    |> Earmark.from_file!()
    |> Phoenix.HTML.raw()
  end

  def render(assigns) do
    assigns =
      assigns
      |> assign(:md, md("priv/markdowns/wutil-organ-transplants.md"))

    ~H"""
    {@md}
    """
  end
end
