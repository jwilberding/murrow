-module(murrow_rest_handler).

-export([init/3,
         allowed_methods/2,
         content_types_provided/2,
         process_post/2,
         delete_resource/2,
         get_json/2,
         terminate/3]).

init(_Transport, _Req, _Opts) ->
    {upgrade, protocol, cowboy_rest}.

allowed_methods(Req, State) ->
    {[<<"HEAD">>, <<"GET">>, <<"POST">>, <<"DELETE">>], Req, State}.

content_types_provided(Req, State) ->
    {[{{<<"application">>, <<"json">>, []}, get_json}], Req, State}.

process_post(Req, State) ->
    {ok, UserValues, Req2} = cowboy_req:body_qs(Req),
    lager:info("at=process_post user=~p", [UserValues]),

    %%

    {true, Req2, State}.

delete_resource(Req, State) ->
    %%
    {true, Req, State}.

get_json(Req, State) ->
    lager:info("wooo"),
    try
        %estatsd:increment("erlangdc_handler.requests"),
        %{ok, {<<"basic">>, {Key, Value}}, Req2} = cowboy_req:parse_header(<<"authorization">>, Req),
        %User = erlangdc_user:get_user(Key, Value),
        %lager:info("Key=~p, Value=~p", [Key, Value]),
        {Id, Req2} = cowboy_http_req:binding(id, Req1),
        lager:info("id=~p", [Id]),
        {<<"boo">>, Req2, State}
    catch
        T:E ->
            lager:info("at=handle type=~p exception=~p ~p", [T, E, erlang:get_stacktrace()]),
            {ok, Req3} = cowboy_req:reply(401, Req),
            {halt, Req3, State}
    end.

terminate(_Reason, _Req, _State) ->
    ok.


%%
%% Internal functions
%%
