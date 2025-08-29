defmodule Hello.Blog do
  alias Hello.Blog.Post
  alias Hello.Blog.PostView
  alias Hello.Repo
  import Ecto.Query

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

  # Views tracking
  def increment_post_view!(post_id) when is_binary(post_id) do
    Repo.insert!(%PostView{post_id: post_id, count: 1},
      on_conflict: [inc: [count: 1]],
      conflict_target: :post_id
    )
  end

  def get_post_view_count(post_id) when is_binary(post_id) do
    case Repo.one(from pv in PostView, where: pv.post_id == ^post_id, select: pv.count) do
      nil -> 0
      count -> count
    end
  end

  def get_post_view_counts(post_ids) when is_list(post_ids) do
    from(pv in PostView, where: pv.post_id in ^post_ids, select: {pv.post_id, pv.count})
    |> Repo.all()
    |> Map.new()
  end
end
