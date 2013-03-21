%%%----------------------------------------------------------------
%%% @author Erlware, LLC
%%% @doc
%%%
%%% @end
%%% @copyright 2013 Erlware, LLC
%%%----------------------------------------------------------------
-module(murrow_sup).

-behaviour(supervisor).

%% API
-export([start_link/0,
         start_child/1,
         terminate_child/1]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

-spec start_link() -> {ok, pid()} | any().
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

start_child(Name) ->
    supervisor:start_child(?SERVER, [Name]).

terminate_child(PID) ->
    wingman_db:terminate(PID).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================


%% @private
-spec init(list()) -> {ok, {SupFlags::any(), [ChildSpec::any()]}} |
                       ignore | {error, Reason::any()}.
init(_) ->
    RestartStrategy = simple_one_for_one,
    MaxRestarts = 0,
    MaxSecondsBetweenRestarts = 1,

    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},

    Restart = temporary,
    Shutdown = 2000,
    Type = worker,

    AChild = {murrow, {murrow, start_link, []},
              Restart, Shutdown, Type, [murrow]},

    {ok, {SupFlags, [AChild]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
