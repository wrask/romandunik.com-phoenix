defmodule Hello.Repo.Migrations.CreatePostViews do
  use Ecto.Migration

  def change do
    create table(:post_views) do
      add :post_id, :string, null: false
      add :count, :integer, null: false, default: 0

      timestamps(type: :utc_datetime)
    end

    create unique_index(:post_views, [:post_id])
  end
end


