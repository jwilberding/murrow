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
         interval/1,
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
    {ok, PID} = gen_server:start_link(?MODULE, [Name], []),
    timer:apply_interval(40000, murrow, interval, [PID]),
    {ok, PID}.

get_news(PID) ->
    gen_server:call(PID, get_news).

%% make cast?
%% only used internally
news_update(PID, News) ->
    gen_server:call(PID, {news_update, News}).

%% only used internally
get_newsc(FromPID, ToPID) ->
    gen_server:call(FromPID, {get_newsc, ToPID}).

%% make cast?
news_updatec(FromPID, ToPID, News) ->
    gen_server:call(FromPID, {news_updatec, ToPID, News}).

%% used to make periodic updates
interval(PID) ->
    gen_server:cast(PID, interval).

terminate(PID) ->
    gen_server:call(PID, terminate, 10000).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

%% @private
init([Name]) ->
    {ok, #state{name=Name, cache=[]}}.

%% @private
handle_call(get_news, _From, State) ->
    %%lager:info("get_news: Name: ~p~nCache: ~p", [Name, Cache]),
    News = get_news_i(State),
    {reply, News, State};
handle_call({news_update, News}, From, #state{name=Name, cache=Cache}=State) ->
    {PID, _Ref} = From,
    CacheItem = #cache_item{address=PID, timestamp=os:timestamp(), news_item=News},
    UpdatedCache = lists:sublist([CacheItem | Cache], ?CACHE_SIZE),
    lager:info("update_news: Name: ~p~nCache: ~p", [Name, UpdatedCache]),
    {reply, <<"ok">>, State#state{cache=UpdatedCache}};
handle_call({get_newsc, ToPID}, _From, State) ->
    News = murrow:get_news(ToPID),
    {reply, News, State};
handle_call({news_updatec, ToPID, News}, _From, State) ->
    Reply = murrow:news_update(ToPID, News),
    {reply, Reply, State}.

%% @private
handle_cast(interval, State) ->
    lager:info("interval"),
    %% get current local news list
    News = get_news_i(State),
    lager:info("News: ~p", [News]),
    %% pick random item, get from, use it query news from that server,
    Count = length(News),
    State2 = update_with_random(Count, News, State),
    {noreply, State2}.

update_with_random(0, _News, State) ->
    State;
update_with_random(N, News, State) ->
    Random = random:uniform(N),
    lager:info("Random: ~p", [Random]),
    NewsItem = lists:nth(Random, News),
    From = NewsItem#cache_item.address,
    lager:info("From: ~p", [From]),
    RemoteNews = get_news(From),
    lager:info("RemoteNews: ~p", [RemoteNews]),
    %% merge news and keep latest 5
    %% todo: sort with record syntax, not assumed list of tuples
    NewNews = lists:sublist(lists:reverse(lists:keysort(3,lists:flatten([News | RemoteNews]))), ?CACHE_SIZE),
    lager:info("NewNews: ~p", [NewNews]),
    State#state{cache=NewNews}.
    %%State.

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

get_news_i(#state{cache=Cache}=_State) ->
    Cache.
