defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  defp common_variables do
    %{
      elixir_version: System.version(),
      phoenix_version: Application.spec(:phoenix, :vsn),
      run_mode: (if System.get_env("RELEASE_NAME"), do: "prod (release)", else: "dev (mix)"),
      owner_site_url: Application.get_env(:hello, HelloWeb.Endpoint)[:owner_site_url],
      repository_url: Application.get_env(:hello, HelloWeb.Endpoint)[:repository_url],
      page_title: "wrask blog"
    }
  end

  def index(conn, _params) do
    posts = Hello.Blog.list_posts()
    view_counts = Hello.Blog.get_post_view_counts(Enum.map(posts, & &1.id))

    conn
    |> render(:index,
      common_variables()
      |> Map.put(:posts, posts)
      |> Map.put(:view_counts, view_counts)
    )
  end

  def show(conn, %{"slug" => slug}) do
    post = Hello.Blog.get_post_by_id!(slug)

    Hello.Blog.increment_post_view!(post.id)
    view_count = Hello.Blog.get_post_view_count(post.id)

    conn
    |> render(:show,
      common_variables()
      |> Map.put(:post, post)
      |> Map.put(:view_count, view_count)
    )
  end

  def tags(conn, %{"tag" => tag}) do
    posts = Hello.Blog.list_posts_by_tag!(tag)
    view_counts = Hello.Blog.get_post_view_counts(Enum.map(posts, & &1.id))

    conn
    |> render(:index,
      common_variables()
      |> Map.put(:posts, posts)
      |> Map.put(:view_counts, view_counts)
    )
  end
end
