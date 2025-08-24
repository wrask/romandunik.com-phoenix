defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  defp common_variables do
    %{
      elixir_version: System.version(),
      phoenix_version: Application.spec(:phoenix, :vsn),
      run_mode: (if System.get_env("RELEASE_NAME"), do: "prod (release)", else: "dev (mix)"),
      owner_site_url: Application.get_env(:hello, HelloWeb.Endpoint)[:owner_site_url],
      repository_url: Application.get_env(:hello, HelloWeb.Endpoint)[:repository_url]
    }
  end

  def index(conn, _params) do
    conn
    |> render(:index,
      Map.put(common_variables(),
        :posts, Hello.Blog.list_posts()
      )
    )
  end

  def show(conn, %{"slug" => slug}) do
    conn
    |> render(:show,
      Map.put(common_variables(),
        :post, Hello.Blog.get_post_by_id!(slug)
      )
    )
  end

  def tags(conn, %{"tag" => tag}) do
    conn
    |> render(:index,
      Map.put(common_variables(),
        :posts, Hello.Blog.list_posts_by_tag!(tag)
      )
    )
  end
end
