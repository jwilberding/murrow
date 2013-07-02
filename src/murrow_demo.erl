%%%----------------------------------------------------------------
%%% @author Erlware, LLC
%%% @doc
%%%
%%% @end
%%% @copyright 2013 Erlware, LLC
%%%----------------------------------------------------------------

%% Initial version with erlang api, need to add rest api

-module(murrow_demo).
-export([start/0,
         start2/0,
         start3/0]).

start() ->
    murrow:start(),
    {ok, PID1} = murrow_sup:start_child(<<"node1">>),
    {ok, PID2} = murrow_sup:start_child(<<"node2">>),
    {ok, PID3} = murrow_sup:start_child(<<"node3">>),
    {ok, PID4} = murrow_sup:start_child(<<"node4">>),
    {ok, PID5} = murrow_sup:start_child(<<"node5">>),
    {PID1, PID2, PID3, PID4, PID5}.

start2() ->
    murrow:start(),
    lager:info("starting node1"),
    {ok, P1} = murrow_sup:start_child(<<"node1">>),
    timer:sleep(5000),
    lager:info("starting node2"),
    {ok, P2} = murrow_sup:start_child(<<"node2">>),
    timer:sleep(5000),
    lager:info("starting node3"),
    {ok, P3} = murrow_sup:start_child(<<"node3">>),
    murrow:news_updatec(P1, P2, <<"news_1a">>),
    murrow:news_updatec(P1, P2, <<"news_2a">>),
    murrow:news_updatec(P1, P2, <<"news_3a">>),
    murrow:news_updatec(P1, P3, <<"news_1b">>),
    murrow:news_updatec(P1, P3, <<"news_2b">>),
    murrow:news_updatec(P1, P3, <<"news_3b">>),
    murrow:news_updatec(P3, P1, <<"news_1c">>),
    murrow:news_updatec(P3, P1, <<"news_2c">>),
    %%{ok, PID4} = murrow_sup:start_child(<<"node4">>),
    %%{ok, PID5} = murrow_sup:start_child(<<"node5">>),
    {P1, P2, P3}.

start3() ->
    %murrow:start(),
    lager:info("starting node1 rest"),
    murrow_rest_sup:start_link().
