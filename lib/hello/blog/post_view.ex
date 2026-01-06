defmodule Hello.Blog.PostView do
  use Ecto.Schema
  import Ecto.Changeset

  schema "post_views" do
    field :post_id, :string
    field :count, :integer, default: 0

    timestamps(type: :utc_datetime)
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:post_id, :count])
    |> validate_required([:post_id])
    |> unique_constraint(:post_id)
  end
end
