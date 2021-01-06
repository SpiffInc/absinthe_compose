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
    end

    object :paddle do
      field(:name, :string)
      field(:quality, :integer)
    end
  end

  test "proxy a query to a downstream app" do
    query = """
    query {
      paddles {
        name
        quality
      }
    }
    """

    assert {:ok, %{data: data}} = Absinthe.run(query, Schema)

    assert data == %{
             "paddles" => [
               %{"name" => "Big Red", "quality" => 4},
               %{"name" => "Little Red", "quality" => 3},
               %{"name" => "Tony", "quality" => 7},
               %{"name" => "Blue Betty", "quality" => 9}
             ]
           }
  end
end
