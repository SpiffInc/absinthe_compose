defmodule Absinthe.Proxy do
  def resolve(_parent, _args, resolution) do
    %{
      schema: schema,
      definition: %{
        name: name,
        schema_node: %{__private__: private, type: type}
      }
    } = resolution

    proxy_to = get_in(private, [:meta, :proxy_to])
    {query, variables} = Absinthe.Proxy.QueryGenerator.render(resolution)

    with {:ok, results} <- proxy(proxy_to, query, variables) do
      value = Absinthe.Proxy.Downstream.translate(schema, type, name, results)
      {:ok, value}
    end
  end

  def proxy(url, query, variables) when is_binary(url) do
    Absinthe.Proxy.HTTPClient.resolve(%{url: url}, query, variables)
  end

  def proxy(proxy_to, query, variable) when is_atom(proxy_to) do
    apply(proxy_to, :resolve, [query, variable])
  end

  def proxy(proxy_to, _query, _variable) do
    require Logger
    Logger.error("Cannot proxy graphql query to #{inspect(proxy_to)}")
    {:error, "Cannot resolve"}
  end
end
