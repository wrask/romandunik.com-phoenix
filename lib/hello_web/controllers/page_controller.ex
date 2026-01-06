defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  alias Hello.Blog

  defp common_variables do
    %{
      elixir_version: System.version(),
      phoenix_version: Application.spec(:phoenix, :vsn),
      run_mode:
        if(System.get_env("RELEASE_NAME"),
          do: "prod (release)",
          else: "dev (mix)"
        ),
      owner_site_url:
        Application.get_env(:hello, HelloWeb.Endpoint)[:owner_site_url],
      repository_url:
        Application.get_env(:hello, HelloWeb.Endpoint)[:repository_url],
      page_title: "wrask blog",
      description:
        "A production ready example Phoenix app that's using Docker and Docker Compose."
    }
  end

  def index(conn, _params) do
    posts = Blog.list_posts()
    view_counts = view_counts(posts)

    conn
    |> render(
      :index,
      common_variables()
      |> Map.put(:posts, posts)
      |> Map.put(:view_counts, view_counts)
    )
  end

  def show(conn, %{"slug" => slug}) do
    post = Blog.get_post_by_id!(slug)

    Blog.increment_post_view!(post.id)

    view_count = Blog.get_post_view_count(post.id)

    conn
    |> render(
      :show,
      common_variables()
      |> Map.put(:post, post)
      |> Map.put(:view_count, view_count)
    )
  end

  def tags(conn, %{"tag" => tag}) do
    posts = Blog.list_posts_by_tag!(tag)
    view_counts = view_counts(posts)

    conn
    |> render(
      :index,
      common_variables()
      |> Map.put(:posts, posts)
      |> Map.put(:view_counts, view_counts)
    )
  end

  def view_counts(posts) do
    posts
    |> Enum.map(& &1.id)
    |> Blog.get_post_view_counts()
  end
end
