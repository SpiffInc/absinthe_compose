
defmodule Absinthe.Compose.Plug.ForwardHeaderTest do
  use ExUnit.Case, async: true
  use Plug.Test

  alias Absinthe.Compose.Plug.ForwardHeader

  setup do
    ForwardHeader.init(["Auhtorization", "origin"])
    conn = conn("post", "/", "")
    |> put_req_header("auhtorization", "some-token")
    |> put_req_header("origin", "www.coolwebsite.com")
    |> put_req_header("header-to-ignore", "ignored")

    %{
      conn: conn
    }
  end

  test "fowards given headers to abshinte context", %{conn: conn} do
   conn = ForwardHeader.call(conn, ["auhtorization", "Origin"])
   assert %{context: %{headers_to_forward: headers_to_forward}} = conn.private[:absinthe]
   assert [{"origin", ["www.coolwebsite.com"]}, {"auhtorization", ["some-token"]}] = headers_to_forward
   assert length(headers_to_forward) == 2
  end

  test "ignores non-existent headers", %{conn: conn} do
   conn = ForwardHeader.call(conn, ["auhtorization", "origin", "some-giberish"])
   assert %{context: %{headers_to_forward: headers_to_forward}} = conn.private[:absinthe]
   assert length(headers_to_forward) == 2
  end
end
