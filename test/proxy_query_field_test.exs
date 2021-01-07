defmodule Absinthe.Compose.ProxyQueryFieldTest do
  use ExUnit.Case, async: true

  defmodule Schema do
    use Absinthe.Schema
    require Downstream

    query do
      field :paddles, list_of(:paddle) do
        meta(compose: Downstream.pong())
        resolve(&Absinthe.Compose.resolve/3)
      end

      field :player, :player do
        arg(:key, non_null(:string))
        meta(compose: Downstream.pong())
        resolve(&Absinthe.Compose.resolve/3)
      end
    end

    object :paddle do
      field(:name, :string)
      field(:quality, :integer)
    end

    object :player do
      field(:name, :string)
      field(:key, :string)
      field(:favorite_paddle, :paddle)
    end
  end

  @paddles_query """
  query {
    paddles {
      name
      quality
    }
  }
  """

  @player_query """
  query($key: String!) {
    player(key: $key) {
      key
      name
      favoritePaddle {
        name
        quality
      }
    }
  }
  """

  test "proxy a query to a downstream app" do
    assert {:ok, %{data: data}} = Absinthe.run(@paddles_query, Schema)

    assert data == %{
             "paddles" => [
               %{"name" => "Big Red", "quality" => 4},
               %{"name" => "Little Red", "quality" => 3},
               %{"name" => "Tony", "quality" => 7},
               %{"name" => "Blue Betty", "quality" => 9}
             ]
           }
  end

  test "querying nested data from downstream" do
    variables = %{"key" => "SL"}
    assert {:ok, %{data: data}} = Absinthe.run(@player_query, Schema, variables: variables)

    assert data == %{
             "player" => %{
               "key" => "SL",
               "name" => "Star Lord",
               "favoritePaddle" => %{
                 "name" => "Big Red",
                 "quality" => 4
               }
             }
           }
  end

  test "queries that return null for an object" do
    variables = %{"key" => "WAT"}
    assert {:ok, %{data: data}} = Absinthe.run(@player_query, Schema, variables: variables)

    assert data == %{"player" => nil}
  end
end
