defmodule Pong.Router do
  use Plug.Router

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json, Absinthe.Plug.Parser],
    pass: ["*/*"],
    json_decoder: Jason
  )

  plug(:match)
  plug(:dispatch)

  match("/api/graphql",
    to: Absinthe.Plug,
    init_opts: [schema: Pong.Schema]
  )

  match _ do
    send_resp(conn, 404, "Oops!")
  end
end
