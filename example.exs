Trace.calls(String.reverse(_))
Trace.send({:reply, _, _}, sender: pid)
Trace.calls(String.downcase(str) when binary_part(str, 0, 1) == "a", return: true)

Trace.all_processes()
|> Trace.calls(String.reverse(_))
|> ...
|> Trace.start(time: 1000, msgs: 10, into: File.stream!("trace.log"))
