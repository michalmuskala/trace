defmodule Trace do
  defstruct [subject: nil, flags: MapSet.new(), call_specs: []]

  def all_processes() do
    __ENV__
    %__MODULE__{subject: :processes}
  end

  def start(%__MODULE__{subject: subject, flags: flags, call_specs: specs}) do
    parent = self()
    pid = spawn(fn ->
      receive_traces(parent)
    end)
    :erlang.trace(subject, true, [tracer: pid] ++ MapSet.to_list(flags))
    Enum.each(specs, fn {pattern, spec} ->
      :erlang.trace_pattern(pattern, spec, [])
    end)
  end

  defp receive_traces(parent) do
    receive do
      msg -> send(parent, msg)
    end
    receive_traces(parent)
  end

  defmacro calls(trace, pattern, opts \\ []) do
    spec = compile_pattern(pattern, __CALLER__)
    quote do
      Trace.__calls__(unquote(trace), unquote(Macro.escape(spec)), unquote(opts))
    end
  end

  defp compile_pattern({{:., _, [module, function]}, _, args}, env) do
    module = Macro.expand(module, env)
    {{module, function, length(args)}, []}
  end

  def __calls__(%Trace{flags: flags, call_specs: specs} = trace, spec, _opts) do
    %Trace{trace | flags: MapSet.put(flags, :call), call_specs: [spec | specs]}
  end
end
