-module(init_db).
-include_lib("stdlib/include/qlc.hrl").
-include("init_db.hrl").
-export([init/1]).

%%init takes the list of all nodes on which the tables will ne physically replicated and created tables
init(L) ->
	R1 = mnesia:create_table(cause,[{attributes,record_info(fields, cause)},{disc_copies,L}]),
	io:format("R1: ~p.~n",[R1]),
	R2 = mnesia:create_table(sender,[{attributes,record_info(fields, sender)},{disc_copies,L}]),
	io:format("R2: ~p.~n",[R2]),
	R3 = mnesia:create_table(receiver,[{attributes,record_info(fields, receiver)},{disc_copies,L}]),
	io:format("R3: ~p.~n",[R3]),
	R4 = mnesia:create_table(subscriber,[{type, bag},{attributes,record_info(fields,subscriber)},{disc_copies,L},{index, [#subscriber.c_id]}]),
	io:format("R4: ~p.~n",[R4]),
	R5 = mnesia:create_table(t_table,[{type, bag},{attributes, record_info(fields, t_table)},{disc_copies,L}]),
	io:format("R5: ~p.~n",[R5]).
