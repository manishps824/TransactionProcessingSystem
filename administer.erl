-module(administer).
-include_lib("stdlib/include/qlc.hrl").
-include("init_db.hrl").
-import(math,[sqrt/1]).
-export([write_record/1,add_cause/2]).


%add cause writes a cause to the cause table
write_record(R) ->
		F=fun()->
			mnesia:write(R)
		end,
		mnesia:transaction(F).
		
%C is a list of cause id and cause name you want to insert . It is of format [[cause_id1,cause_name1],[cause_id2,cause_name2],[cause_id3,cause_name3]]
%N is the list of processes on which you want to execute write_cause i.e a list of processes one from each group. 
%IMP : N should be calculated using quorum logic, right now user supllies N
add_cause(C,N) ->
		case C of
			[[A|[B]]|T] -> R = {cause,A,B},
						   rpc:multicall(N, administer, write_record,[R]),
						   add_cause(T,N);
			[] -> io:format("All causes inserted.~n")			   
		end.
		
				   	
		
	
			
		
		
