defmodule Portfolio.Repo do
  use Ecto.Repo,
    otp_app: :portfolio,
    adapter: Ecto.Adapters.SQLite3
end
