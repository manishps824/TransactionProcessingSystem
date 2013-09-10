-module(interface).
-export([get_donation/0]).

see_causes([]) ->
		io:format("The causes are.~n");

