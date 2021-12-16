defmodule ChatAssignmentWeb.PageController do
  use ChatAssignmentWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
