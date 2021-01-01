ExUnit.start()

Logger.configure(level: :info)

{:ok, _pid} =
  Supervisor.start_link(
    [
      Plug.Cowboy.child_spec(scheme: :http, plug: Pong.Router, options: [port: 9001])
    ],
    strategy: :one_for_one,
    name: Absinthe.Proxy.Supervisor
  )
