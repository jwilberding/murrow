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
    {ok, PID1} = murrow_sup:start_child(<<"node1">>),
    {ok, PID2} = murrow_sup:start_child(<<"node2">>),
    {ok, PID3} = murrow_sup:start_child(<<"node3">>),
    {ok, PID4} = murrow_sup:start_child(<<"node4">>),
    {ok, PID5} = murrow_sup:start_child(<<"node5">>),
    {PID1, PID2, PID3, PID4, PID5}.
