defmodule HelloWeb.ErrorHTMLTest do
  use HelloWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template

  test "renders 404.html" do
    assert render_to_string(HelloWeb.ErrorHTML, "404", "html", []) ==
             "404 error\n"
  end

  test "renders 500.html" do
    assert render_to_string(HelloWeb.ErrorHTML, "500", "html", []) ==
             "500 error\n"
  end
end
