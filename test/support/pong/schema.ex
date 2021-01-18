defmodule Pong.Schema do
  use Absinthe.Schema

  @paddles [
    %{name: "Big Red", quality: 4},
    %{name: "Little Red", quality: 3},
    %{name: "Tony", quality: 7},
    %{name: "Blue Betty", quality: 9}
  ]

  @players [
    %{active: true, name: "Star Lord", key: "SL", favorite_paddle: Enum.at(@paddles, 0)},
    %{active: true, name: "Code Cowboy", key: "🤠", favorite_paddle: Enum.at(@paddles, 2)},
    %{active: false, name: "Obi Wan", key: "OW", favorite_paddle: Enum.at(@paddles, 3)}
  ]

  query do
    field :paddles, list_of(:paddle) do
      resolve(fn _, _, _ ->
        {:ok, @paddles}
      end)
    end

    field :players, list_of(:player) do
      resolve(fn _, _, _ ->
        {:ok, @players}
      end)
    end

    field :player, :player do
      arg(:key, non_null(:id))

      resolve(fn _, %{key: key}, _ ->
        player = Enum.find(@players, fn candidate -> candidate.key == key end)
        {:ok, player}
      end)
    end
  end

  mutation do
    field :create_paddle, :paddle do
      arg(:name, non_null(:string))
      arg(:quality, :integer)

      resolve(fn _source, %{name: name} = args, _resolution ->
        paddle = %{
          name: name,
          quality: Map.get(args, :quality)
        }

        {:ok, paddle}
      end)
    end
  end

  object :paddle do
    field(:name, :string)
    field(:quality, :integer)
  end

  object :player do
    field(:active, :boolean)
    field(:name, non_null(:id))
    field(:key, :string)
    field(:favorite_paddle, :paddle)
  end
end
