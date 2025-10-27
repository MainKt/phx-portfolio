defmodule PortfolioWeb.ResumeController do
  use PortfolioWeb, :controller

  @link "https://drive.google.com/file/d/1Ykj2RJdoFcODATulDY6ZNMJgJcNhy8z9"

  def index(conn, _), do: redirect(conn, external: @link)
end
