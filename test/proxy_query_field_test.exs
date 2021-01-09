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
        arg(:key, non_null(:id))
        meta(compose: Downstream.pong())
        resolve(&Absinthe.Compose.resolve/3)
      end

      field :fruits, list_of(:fruit) do
        meta(compose: Downstream.produce())
        resolve(&Absinthe.Compose.resolve/3)
      end

      field :vegetables, list_of(:vegetable) do
        meta(compose: Downstream.produce())
        resolve(&Absinthe.Compose.resolve/3)
      end
    end

    object :paddle do
      field(:name, :string)
      field(:quality, :integer)
    end

    object :player do
      field(:name, non_null(:id))
      field(:key, :string)
      field(:favorite_paddle, :paddle)
    end

    enum :produce_color do
      value(:red)
      value(:orange)
      value(:yellow)
      value(:green)
    end

    enum :vitamin do
      value(:c)
      value(:d)
    end

    object :fruit do
      field(:name, non_null(:string))
      field(:color, :produce_color)
      field(:sweetness, :integer)
    end

    object :vegetable do
      field(:name, non_null(:string))
      field(:color, :produce_color)
      field(:primary_vitamin, :vitamin)
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
  query($key: ID!) {
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

  test "querying enum values from downstream" do
    query = """
    query {
      fruits {
        name
        color
        sweetness
      }
    }
    """

    assert {:ok, %{data: data}} = Absinthe.run(query, Schema)

    assert data == %{
             "fruits" => [
               %{"color" => "YELLOW", "name" => "banana", "sweetness" => 4},
               %{"color" => "RED", "name" => "tomato", "sweetness" => 1},
               %{"color" => "GREEN", "name" => "watermelon", "sweetness" => 7}
             ]
           }
  end
end
