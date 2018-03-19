defmodule TraceTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest Trace

  describe "all_processes/0" do
    test "sets subject" do
      assert Trace.all_processes().subject == :processes
    end
  end

  describe "calls/3" do
    test "sets flag" do
      trace = Trace.all_processes() |> Trace.calls(String.reverse(_))
      assert :call in trace.flags
    end

    test "adds call pattern" do
      trace = Trace.all_processes() |> Trace.calls(String.reverse(_))
      assert {{String, :reverse, 1}, []} in trace.call_specs
      alias String, as: FooBar
      trace = Trace.all_processes() |> Trace.calls(FooBar.reverse(_))
      assert {{String, :reverse, 1}, []} in trace.call_specs
    end
  end

  describe "start/2" do
    test "runs call traces" do
      Trace.all_processes() |> Trace.calls(String.reverse(_)) |> Trace.start()
      String.reverse("abc")
      self = self()
      assert_received {:trace, ^self, :call, {String, :reverse, ["abc"]}}
    end
  end
end
