defmodule PortfolioWeb.WritingLive.WutuiLive do
  use PortfolioWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "Cooking wutui on an Uncooked Terminal")
      |> assign(:page_heading, "Cooking wutui on an Uncooked Terminal")

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
      |> assign(:md, md("priv/markdowns/wutui.md"))

    ~H"""
    {@md}
    """
  end
end
