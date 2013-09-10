-module(install).
-include_lib("stdlib/include/qlc.hrl").
-include("init_db.hrl").
-import(math,[sqrt/1]).
-export([install/1,get_quorum/2,setup/1]).

%install([]) ->
%	io:format("Tables Created on all nodes.~n");

%creates schema on the list of nodes provided and creates tables also
install(L) ->
	io:format("Installing~n"),
	R1 = mnesia:create_schema(L),
	io:format("Installing~n"),
	R2 = rpc:multicall(L, application, start, [mnesia]),   %start  mnesia on all nodes
	io:format("Installing~n"),
	R3 = init_db:init(L),
	io:format("Installing~n"),
	R4 = insert:read_file().
	%~ rpc:multicall(L, application, stop, [mnesia]).		%stop mnesia on all nodes. can remove this if needed
	%install(L).
	
get_quorum(Index,N) ->
	NumProcs=trunc(sqrt(N)),							% find numprocs
	S=((Index-1) rem NumProcs)+1,						% find row number
	T=((Index-1) div NumProcs)+1,						% find col number
	Col=[ X*NumProcs+S || X <-lists:seq(0,NumProcs-1)],			% find entire column
	Row=[ X || X <-lists:seq(NumProcs*(T-1)+1,NumProcs*T)],		% find entire row
	%io:format("Index is ~p Col is ~p Row is ~p ~n",[Index,Col,Row]),
	Q=Row++Col--[Index],				% remove self duplicate
	Q.	

setup([]) ->
		io:format("Tables Created on all nodes.~n");


%setup takes argument of form [[n1,n2,n3],[n4,n5,n6],[n7,n8,n9],...] where n1,n2,n3 belong to one group, n4,n5,n6 belong to other.
%The idea is to use this function to setup datbases on all nodes. So use RPC to call install on any ONE node in a group, which takes care
%of job in that group. This is done for all groups using recursion. 

%IMP: the argument should be computed using quorum logic. So need to make changes here.

setup([H|T]) ->
	io:format("H ~p ",[H]),
	case H of
		[P|_] ->
				RV = rpc:multicall([P], install, install,[H]),
				case RV of
				{badrpc,nodedown} -> io:format("Node down ~p ",P);
				{badrpc,_} -> io:format("Unknown error, could not create tables on ~p",P);
				_ -> io:format("~p ~n",[RV])
				end
	end,
	setup(T).
