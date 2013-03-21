%%%----------------------------------------------------------------
%%% @author Erlware, LLC
%%% @doc
%%%
%%% @end
%%% @copyright 2013 Erlware, LLC
%%%----------------------------------------------------------------
-module(murrow_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%%===================================================================
%%% Application callbacks
%%%===================================================================

%% @private
-spec start(normal | {takeover, node()} | {failover, node()},
            any()) -> {ok, pid()} | {ok, pid(), State::any()} |
                      {error, Reason::any()}.
start(_StartType, _StartArgs) ->
    lager:info("Starting murrow_sup"),
    case murrow_sup:start_link() of
        {ok, Pid} ->
            io:format("murrow_sup Pid: ~p", [Pid]),
            {ok, Pid};
        Error ->
            lager:info("Failed to start murrow_sup: ~p", [Error]),
            Error
    end.

%% @private
-spec stop(State::any()) -> ok.
stop(_State) ->
    ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================
