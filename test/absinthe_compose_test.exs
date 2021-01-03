defmodule Absinthe.ProxyTest do
  use ExUnit.Case

  describe "sub-apps are started automatically" do
    test "pong server is up" do
      {:ok, %{status_code: 200, body: body}} =
        HTTPoison.post(
          "http://localhost:9001/api/graphql",
          Jason.encode!(%{
            "query" => "query { paddles { name quality } }"
          }),
          [{"Content-Type", "application/json"}, {"Accept", "application/graphql"}]
        )

      response = Jason.decode!(body)

      assert response == %{
               "data" => %{
                 "paddles" => [
                   %{"name" => "Big Red", "quality" => 4},
                   %{"name" => "Little Red", "quality" => 3},
                   %{"name" => "Tony", "quality" => 7},
                   %{"name" => "Blue Betty", "quality" => 9}
                 ]
               }
             }
    end

    test "produce server is up" do
      {:ok, %{status_code: 200, body: body}} =
        HTTPoison.post(
          "http://localhost:9002/graphql",
          Jason.encode!(%{
            "query" => """
              query {
                produce(name: "banana") {
                  name
                  color
                  __typename
                  ... on Fruit {
                    sweetness
                  }
                  ... on Vegetable {
                    primaryVitamin
                  }
                }
              }
            """
          }),
          [{"Content-Type", "application/json"}, {"Accept", "application/graphql"}]
        )

      response = Jason.decode!(body)

      assert response == %{
               "data" => %{
                 "produce" => %{
                   "__typename" => "Fruit",
                   "name" => "banana",
                   "color" => "YELLOW",
                   "sweetness" => 4
                 }
               }
             }
    end
  end
end
