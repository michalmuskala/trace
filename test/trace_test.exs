defmodule TraceTest do
  use ExUnit.Case
  doctest Trace

  test "greets the world" do
    assert Trace.hello() == :world
  end
end
