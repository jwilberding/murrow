%%%----------------------------------------------------------------
%%% @author Erlware, LLC
%%% @doc
%%%
%%% @end
%%% @copyright 2013 Erlware, LLC
%%%----------------------------------------------------------------
-module(murrow_rest_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

-spec start_link() -> {ok, pid()} | any().
start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================


%% @private
-spec init(list()) -> {ok, {SupFlags::any(), [ChildSpec::any()]}} |
                       ignore | {error, Reason::any()}.
init([]) ->
    %% Dispatch = cowboy_router:compile([
    %%                                   {'_',
    %%                                    [{<<"/1/myrcast">>, murrow_rest_handler, []},
    %%                                     {[<<"/1/myrcast">>, id], murrow_rest_handler, []}]
    %%                                   }
    %%                                  ]),

    Dispatch = [{'_', [{<<"/1/myrcast">>, murrow_rest_handler, []},
                       {[<<"/1/myrcast">>, id], murrow_rest_handler, []}]}],

    ListenPort = list_to_integer(os:getenv("PORT")),

    ChildSpec = ranch:child_spec(erlangdc_cowboy, 100,
                                    ranch_tcp, [{port, ListenPort}],
                                    cowboy_protocol, [{env, [{dispatch, Dispatch}]}]),

    {ok, {{one_for_one, 10, 10}, [ChildSpec]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
