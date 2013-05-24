%%%----------------------------------------------------------------
%%% @author Erlware, LLC
%%% @doc
%%%
%%% @end
%%% @copyright 2013 Erlware, LLC
%%%----------------------------------------------------------------

%% Initial version with erlang api, need to add rest api

-module(murrow_demo).
-export([start/0]).

start() ->
    murrow:start(),
    {ok, _PID1} = murrow_sup:start_child(<<"node1">>).
