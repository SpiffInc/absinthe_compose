defmodule Absinthe.Compose.Downstream do
  @moduledoc """
  Translates the raw results we get from downstream schemas to a format that our schema can traverse
  """

  def translate(schema, type, name, downstream) do
    downstream = Map.get(downstream, name)
    translate(schema, type, downstream)
  end

  def translate(schema, %Absinthe.Type.List{of_type: sub_type_id}, downstream) do
    sub_type = Absinthe.Schema.lookup_type(schema, sub_type_id)

    Enum.map(downstream, fn raw ->
      translate(schema, sub_type, raw)
    end)
  end

  def translate(schema, %Absinthe.Type.Object{fields: fields}, downstream) do
    Enum.reduce(fields, %{}, fn {key, field}, map ->
      if Map.has_key?(downstream, field.name) do
        raw = Map.get(downstream, field.name)
        field_type = Absinthe.Schema.lookup_type(schema, field.type)
        Map.put(map, key, translate(schema, field_type, raw))
      else
        map
      end
    end)
  end

  def translate(_schema, %Absinthe.Type.Scalar{}, raw), do: raw

  def translate(_schema, type, downstream) do
    raise "Not sure how to translate #{inspect(downstream)} to #{inspect(type)}"
  end
end
