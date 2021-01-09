defmodule Absinthe.Compose.Downstream do
  @moduledoc """
  Translates the raw results we get from downstream schemas to a format that our schema can traverse
  """

  alias Absinthe.Blueprint.Document.Field

  def translate(nil, _field, _schema), do: nil

  def translate(downstream, %Field{schema_node: %{type: %Absinthe.Type.List{}}} = field, schema) do
    translate_list(downstream, field, schema)
  end

  def translate(downstream, %Field{selections: []} = field, schema) do
    type = Absinthe.Schema.lookup_type(schema, field.schema_node.type)
    translate_scalar(downstream, type)
  end

  def translate(downstream, %Field{} = field, schema) do
    translate_object(downstream, field, schema)
  end

  def translate(downstream, tree, _schema) do
    raise "Not sure how to translate #{inspect(downstream)} to #{inspect(tree)}"
  end

  def translate_list(downstream, field, schema) do
    %Absinthe.Type.List{of_type: type_id} = field.schema_node.type
    of_type = Absinthe.Schema.lookup_type(schema, type_id)
    sub_schema_node = Map.put(field.schema_node, :type, of_type)
    item_field = Map.put(field, :schema_node, sub_schema_node)
    Enum.map(downstream, &translate(&1, item_field, schema))
  end

  def translate_object(nil, _list, _schema), do: nil

  def translate_object(downstream, field, schema) do
    Enum.reduce(field.selections, %{}, fn field, map ->
      internal_name = field.schema_node.identifier
      raw = Map.get(downstream, field.name)
      internal_value = translate(raw, field, schema)
      Map.put(map, internal_name, internal_value)
    end)
  end

  def translate_scalar(nil, _), do: nil

  def translate_scalar(downstream, %Absinthe.Type.Scalar{identifier: :string}) do
    downstream
  end

  def translate_scalar(downstream, %Absinthe.Type.Scalar{identifier: :id}) do
    downstream
  end

  def translate_scalar(downstream, %Absinthe.Type.Scalar{identifier: :integer}) do
    downstream
  end

  def translate_scalar(downstream, %Absinthe.Type.Enum{} = enum) do
    case Map.get(enum.values_by_name, downstream) do
      nil -> raise "Invalid Enum value #{inspect(downstream)} for #{enum.name}"
      %Absinthe.Type.Enum.Value{value: value} -> value
    end
  end

  def translate_scalar(downstream, type) do
    raise "Not sure how to translate #{inspect(downstream)} to #{inspect(type)}"
  end
end
