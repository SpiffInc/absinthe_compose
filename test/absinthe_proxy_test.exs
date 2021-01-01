defmodule AbsintheProxyTest do
  use ExUnit.Case
  doctest AbsintheProxy

  test "greets the world" do
    assert AbsintheProxy.hello() == :world
  end
end
