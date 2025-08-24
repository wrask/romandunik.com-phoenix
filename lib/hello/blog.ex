defmodule Hello.Blog do
  alias Hello.Blog.Post

  use NimblePublisher,
    build: Post,
    from: "./posts/**/*.md",
    as: :posts,
    highlighters: [:makeup_elixir]

  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})
  @tags @posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

  def list_posts, do: @posts
  def list_tags, do: @tags

  defmodule NotFoundError do
    defexception [:message, plug_status: 404]
  end

  def get_post_by_id!(id) do
    Enum.find(list_posts(), &(&1.id == id)) ||
      raise NotFoundError, "post with id=#{id} not found"
  end

  def list_posts_by_tag!(tag) do
    case Enum.filter(list_posts(), &(tag in &1.tags)) do
      [] -> raise NotFoundError, "posts with tag=#{tag} not found"
      posts -> posts
    end
  end
end
