defmodule Absinthe.Proxy.BasicProxyTest do
  use ExUnit.Case, async: true

  defmodule Schema do
    use Absinthe.Schema

    query do
      field :paddles, list_of(:paddle) do
        meta(proxy_to: "http://localhost:9001/api/graphql")
        resolve(&Absinthe.Proxy.resolve/3)
      end
    end

    object :paddle do
      field(:name, :string)
      field(:quality, :integer)
    end
  end

  test "test basic proxying by type" do
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
