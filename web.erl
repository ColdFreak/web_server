-module(web).
-export([start/1]).

start(Port) ->
    %% `{active, false}` - we want to receive data as results of a function call
    Pid = spawn_link(fun() -> 
                    {ok, Socket} = gen_tcp:listen(Port, [{active, false}, binary]),
                    spawn(fun() -> loop(Socket) end),
                    timer:sleep(infinity)
    end),
    {ok, Pid}.

loop(Socket) ->
    %% `accept(ListenSocket) -> {ok, Socket} | {error, Reason}`
    {ok, Conn} = gen_tcp:accept(Socket),
    spawn(fun() -> loop(Socket) end),
    handle(Conn).

handle(Conn) ->
    gen_tcp:send(Conn, response("Hello, World")),
    gen_tcp:close(Conn).

response(Str) ->
    B = iolist_to_binary(Str),
    iolist_to_binary(io_lib:fwrite(
            "HTTP/1.0 200 OK\nContent-Type: text/html\nContent-Length: ~p\n\n~s",
            [size(B), B])).
