defmodule Absinthe.Compose.ProxyMutationFieldTest do
  use ExUnit.Case, async: true

  defmodule Schema do
    use Absinthe.Schema
    require Downstream

    query do
    end

    mutation do
      field :create_paddle, :paddle do
        arg(:name, non_null(:string))
        arg(:quality, :integer)

        meta(compose: Downstream.pong())
        resolve(&Absinthe.Compose.resolve/3)
      end
    end

    object :paddle do
      field(:name, :string)
      field(:quality, :integer)
    end
  end

  test "proxy a mutation to a downstream app" do
    query = """
    mutation {
      createPaddle(name: "Boogy") {
        name
        quality
      }
    }
    """

    assert {:ok, %{data: data}} = Absinthe.run(query, Schema)

    assert data == %{
             "createPaddle" => %{
               "name" => "Boogy",
               "quality" => nil
             }
           }
  end
end
