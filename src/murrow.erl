%%%----------------------------------------------------------------
%%% @author Erlware, LLC
%%% @doc
%%%
%%% @end
%%% @copyright 2013 Erlware, LLC
%%%----------------------------------------------------------------

%% Initial version with erlang api, need to add rest api

-module(murrow).

-behaviour(gen_server).

%% Helper
-export([start/0]).

%% API
-export([start_link/1,
         get_news/1,
         news_update/2,
         get_newsc/2,
         news_updatec/3,
         terminate/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).
-export_type([]).

-define(SERVER, ?MODULE).
-define(CACHE_SIZE, 5).

-record(state, {name, cache}).
-record(cache_item, {address, timestamp, news_item}).

%%%===================================================================
%%% Public Types
%%%===================================================================

%%%===================================================================
%%% Helper
%%%===================================================================

start() ->
    start_deps(murrow, permanent).

start_deps(App, Type) ->
    io:format("Start deps App: ~p Type: ~p~n", [App, Type]),
    case application:start(App, Type) of
        ok ->
            ok;
        {error, {not_started, Dep}} ->
            start_deps(Dep, Type),
            start_deps(App, Type)
    end.

%%%===================================================================
%%% API
%%%===================================================================

start_link(Name) ->
    gen_server:start_link(?MODULE, [Name], []).

get_news(PID) ->
    gen_server:call(PID, get_news).

%% make cast?
news_update(PID, News) ->
    gen_server:call(PID, {news_update, News}).

get_newsc(FromPID, ToPID) ->
    gen_server:call(FromPID, {get_newsc, ToPID}).

%% make cast?
news_updatec(FromPID, ToPID, News) ->
    gen_server:call(FromPID, {news_updatec, ToPID, News}).

terminate(PID) ->
    gen_server:call(PID, terminate, 10000).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%% @private
init([Name]) ->
    {ok, #state{name=Name, cache=[]}}.

%% @private
handle_call(get_news, _From, #state{name=Name, cache=Cache}=State) ->
    lager:info("get_news: Name: ~p Cache: ~p", [Name, Cache]),
    {reply, <<"news">>, State};
handle_call({news_update, News}, From, #state{name=Name, cache=Cache}=State) ->
    CacheItem = #cache_item{address=From, timestamp=datetime:now(), news_item=News},
    UpdatedCache = lists:sublist([CacheItem | Cache], ?CACHE_SIZE),
    lager:info("update_news: Name: ~p Cache: ~p News: ~p", [Name, UpdatedCache, News]),
    {reply, <<"ok">>, State#state{cache=UpdatedCache}};
handle_call({get_newsc, ToPID}, _From, State) ->
    News = murrow:get_news(ToPID),
    %lager:info("get_newsc: Name: ~p Cache: ~p", [Name, Cache]),
    {reply, News, State};
handle_call({news_updatec, ToPID, News}, _From, State) ->
    Reply = murrow:news_update(ToPID, News),
    %lager:info("update_newsc: Name: ~p Cache: ~p News: ~p", [Name, UpdatedCache, News]),
    {reply, Reply, State}.

%% @private
handle_cast(_Msg, State) ->
    {noreply, State}.

%% @private
handle_info(_Info, State) ->
    {noreply, State}.

%% @private
terminate(_Reason, _State) ->
    ok.

%% @private
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================