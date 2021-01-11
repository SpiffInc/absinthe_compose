# AbsintheCompose

Compose multiple GraphQL endpoints into a single unified graph.

## Getting Started

The simplest way to compose GraphQL endpoints is to act as a gateway where you forward requests for your different top-level queries to different backends.

```elixir
defmodule Schema do
  use Absinthe.Schema

  query do
    field :paddles, list_of(:paddle) do
      meta(
        compose: [
          from: Absinthe.Compose.HTTPClient,
          opts: [
            url: "http://localhost:9000/graphql"
          ]
        ]
      )
      resolve(&Absinthe.Compose.resolve/3)
    end
  end

  # object/field definitions go here
end
```

We add a little meta-data to the field so and tell Absinthe to have this library resolve it.
Then `absinthe_compose` will call `Absinthe.Compose.HTTPClient` with the opts we've provided, a GraphQL query of all the fields requested under the `paddles` root node and any variables we need to pass along.

For more examples, see `test/proxy_query_field_test.exs` and `test/proxy_mutation_field_test.exs`.
