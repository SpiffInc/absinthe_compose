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

      field :new_fruit, :fruit do
        arg(:name, non_null(:string))
        arg(:color, :produce_color)
        arg(:sweetness, :integer)

        meta(compose: Downstream.produce())
        resolve(&Absinthe.Compose.resolve/3)
      end
    end

    object :paddle do
      field(:name, :string)
      field(:quality, :integer)
    end

    enum :produce_color do
      value(:red)
      value(:orange)
      value(:yellow)
      value(:green)
    end

    object :fruit do
      field(:name, non_null(:string))
      field(:color, :produce_color)
      field(:sweetness, :integer)
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

  test "sending enum values in args" do
    query = """
    mutation {
      newFruit(name: "Starfruit", color: YELLOW) {
        name
        color
        sweetness
      }
    }
    """

    assert {:ok, %{data: data}} = Absinthe.run(query, Schema)

    assert data == %{
             "newFruit" => %{
               "name" => "Starfruit",
               "color" => "YELLOW",
               "sweetness" => nil
             }
           }
  end

  test "sending enum values in args as variables" do
    query = """
    mutation($name: String!, $color: ProduceColor) {
      newFruit(name: $name, color: $color) {
        name
        color
        sweetness
      }
    }
    """
    vars = %{"name" => "Starfruit", "color" => "YELLOW"}

    assert {:ok, %{data: data}} = Absinthe.run(query, Schema, variables: vars)

    assert data == %{
             "newFruit" => %{
               "name" => "Starfruit",
               "color" => "YELLOW",
               "sweetness" => nil
             }
           }
  end
end
