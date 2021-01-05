ExUnit.start()

Logger.configure(level: :info)

defmodule Downstream do
  defmacro pong do
    [
      from: Absinthe.Compose.HTTPClient,
      opts: [url: "http://localhost:9001/api/graphql"]
    ]
  end

  defmacro produce do
    [
      from: Absinthe.Compose.HTTPClient,
      opts: [url: "http://localhost:9002/graphql"]
    ]
  end
end

{:ok, _pid} =
  Supervisor.start_link(
    [
      Plug.Cowboy.child_spec(scheme: :http, plug: Pong.Router, options: [port: 9001]),
      Plug.Cowboy.child_spec(scheme: :http, plug: Produce.Router, options: [port: 9002])
    ],
    strategy: :one_for_one,
    name: Absinthe.Proxy.Supervisor
  )
