defmodule Absinthe.Compose do
  def resolve(_parent, _args, resolution) do
    %{
      schema: schema,
      definition: %{
        name: name,
        schema_node: %{__private__: private, type: type}
      }
    } = resolution

    compose = get_in(private, [:meta, :compose])
    compose_module = Keyword.fetch!(compose, :from)
    opts = Keyword.get(compose, :opts, [])

    {query, variables} = Absinthe.Compose.QueryGenerator.render(resolution)

    with {:ok, results} <- proxy(compose_module, opts, query, variables) do
      value = Absinthe.Compose.Downstream.translate(schema, type, name, results)
      {:ok, value}
    end
  end

  def proxy(module, opts, query, variable) when is_atom(module) do
    prepared = apply(module, :init, [opts])
    apply(module, :resolve, [prepared, query, variable])
  end
end
