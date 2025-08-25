defmodule PortfolioWeb.WritingLive.NetlinkLive do
  use PortfolioWeb, :live_view

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:page_title, "rtnetlink and libifconfig")
      |> assign(:page_heading, "rtnetlink and libifconfig")

    {:ok, socket}
  end

  defmacro md(file_path) do
    file_path
    |> Earmark.from_file!()
    |> Phoenix.HTML.raw()
  end

  def render(assigns) do
    assigns =
      assigns
      |> assign(:md, md("priv/markdowns/netlink.md"))

    ~H"""
    {@md}
    """
  end
end
