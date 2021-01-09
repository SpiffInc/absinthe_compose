defmodule Produce.Schema do
  use Absinthe.Schema

  @fruits [
    %{name: "banana", color: :yellow, sweetness: 4},
    %{name: "tomato", color: :red, sweetness: 1},
    %{name: "watermelon", color: :green, sweetness: 7}
  ]

  @vegetables [
    %{name: "onion", color: :yellow, primary_vitamin: :c},
    %{name: "brocolli", color: :green, primary_vitamin: :d}
  ]

  @produce @fruits ++ @vegetables

  query do
    field :fruits, list_of(:fruit) do
      resolve(fn _, _, _ ->
        {:ok, @fruits}
      end)
    end

    field :vegetables, list_of(:vegetable) do
      resolve(fn _, _, _ ->
        {:ok, @vegetables}
      end)
    end

    field :produce, :produce do
      arg(:name, non_null(:string))

      resolve(fn _, %{name: name}, _ ->
        produce = Enum.find(@produce, fn candidate -> candidate.name == name end)
        {:ok, produce}
      end)
    end
  end

  mutation do
    field :new_fruit, :fruit do
      arg(:name, non_null(:string))
      arg(:color, :produce_color)
      arg(:sweetness, :integer)

      resolve(fn _, args, _ ->
        fruit = %{
          name: Map.get(args, :name),
          color: Map.get(args, :color),
          sweetness: Map.get(args, :sweetness)
        }
        {:ok, fruit}
      end)
    end
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

  interface :produce do
    field(:name, non_null(:string))
    field(:color, :produce_color)

    resolve_type(fn obj, _resolution ->
      case obj do
        %{sweetness: _} -> :fruit
        _ -> :vegetable
      end
    end)
  end

  object :fruit do
    interface(:produce)

    field(:name, non_null(:string))
    field(:color, :produce_color)
    field(:sweetness, :integer)
  end

  object :vegetable do
    interface(:produce)

    field(:name, non_null(:string))
    field(:color, :produce_color)
    field(:primary_vitamin, :vitamin)
  end
end
