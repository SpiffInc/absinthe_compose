defmodule Absinthe.Compose.Plug.ForwardHeader do
  @moduledoc """
  This Plug takes the given headers and add it to Absinthe.Plug context in order to be fowarded
  on to the Upstream service on the resolver level.
  """
  @behaviour Plug

  import Plug.Conn

  def init(opts), do: opts

  @spec call(Plug.Conn.t(), any) :: Plug.Conn.t()
  def call(conn, opts) do
    headers_to_forward = get_headers(conn, opts)
    Absinthe.Plug.put_options(conn, context: %{headers_to_forward: headers_to_forward})
  end

  defp get_headers(conn, header_names) do
    Enum.reduce(header_names, [], fn name, acc ->
      name = String.downcase(name)
      case get_req_header(conn, name) do
        [] -> acc
        values -> [{name, values} | acc]
      end
    end)
  end

end
