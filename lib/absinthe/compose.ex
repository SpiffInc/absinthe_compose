defmodule Absinthe.Compose do
  def resolve(_parent, _args, resolution) do
    %{
      schema: schema,
      definition: %{
        schema_node: %{__private__: private},
        name: name
      },
      context: context
    } = resolution
    compose = get_in(private, [:meta, :compose])
    compose_module = Keyword.fetch!(compose, :from)
    opts = Keyword.get(compose, :opts, [])
    |> forward_hearders(context)

    {query, variables} = Absinthe.Compose.QueryGenerator.render(resolution)

    with {:ok, downstream} <- proxy(compose_module, query, variables, opts, resolution) do
      downstream = Map.get(downstream, name)
      value = Absinthe.Compose.Downstream.translate(downstream, resolution.definition, schema)
      {:ok, value}
    end
  end

  def proxy(module, query, variables, opts, resolution) when is_atom(module) do
    apply(module, :resolve, [query, variables, opts, resolution])
  end

  defp forward_hearders(opts, %{headers_to_forward: headers}) do
    [headers: Keyword.get(opts, :headers, []) ++ headers]
    |> Keyword.merge(opts)
  end

  defp forward_hearders(opts, _context), do: opts
end
