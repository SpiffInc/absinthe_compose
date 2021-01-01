defmodule Pong.Schema do
  use Absinthe.Schema

  @paddles [
    %{name: "Big Red", quality: 4},
    %{name: "Little Red", quality: 3},
    %{name: "Tony", quality: 7},
    %{name: "Blue Betty", quality: 9}
  ]

  query do
    field :paddles, list_of(:paddle) do
      resolve(fn _, _, _ ->
        {:ok, @paddles}
      end)
    end
  end

  object :paddle do
    field(:name, :string)
    field(:quality, :integer)
  end
end
