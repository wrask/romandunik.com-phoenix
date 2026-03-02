defmodule HelloWeb.PageController do
  use HelloWeb, :controller

  alias Hello.Blog

  @page_title "wrask blog"
  @description "A production ready example Phoenix app that's using Docker and Docker Compose."
  @view_counts_cache_time :timer.minutes(1)

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
    case Cachex.get(:hello_cache, "view_counts") do
      {:ok, nil} ->
        view_counts = posts
          |> Enum.map(& &1.id)
          |> Blog.get_post_view_counts()

        Cachex.put(:hello_cache, "view_counts", view_counts, expire: @view_counts_cache_time)
        view_counts

      {:ok, view_counts} ->
        view_counts

      {:error, _} ->
        %{}
    end
  end

  defp common_variables do
    %{
      elixir_version: elixir_version(),
      phoenix_version: phoenix_version(),
      run_mode: run_mode(),
      owner_site_url: owner_site_url(),
      repository_url: repository_url(),
      page_title: page_title(),
      description: description()
    }
  end

  defp elixir_version do
    System.version()
  end

  defp phoenix_version do
    Application.spec(:phoenix, :vsn)
  end

  defp run_mode do
    if System.get_env("RELEASE_NAME"), do: "prod (release)", else: "dev (mix)"
  end

  defp owner_site_url do
    Application.get_env(:hello, HelloWeb.Endpoint)[:owner_site_url]
  end

  defp repository_url do
    Application.get_env(:hello, HelloWeb.Endpoint)[:repository_url]
  end

  defp page_title, do: @page_title

  defp description, do: @description
end
