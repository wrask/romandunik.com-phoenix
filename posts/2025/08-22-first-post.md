%{
  title: "Shulz gravel",
  author: "Roman Dunik",
  tags: ~w(sport bike shulz),
  description: "Let's write the first post",
  image: "/images/shulz.webp"
}
---

### The Third One.

Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.

## Code Examples

Here's some Elixir code with syntax highlighting:

```elixir
defmodule Hello.Blog do
  use NimblePublisher,
    build: Post,
    from: "./posts/**/*.md",
    as: :posts

  @posts Enum.sort_by(@posts, & &1.date, {:desc, Date})
  
  def list_posts, do: @posts
end
```


