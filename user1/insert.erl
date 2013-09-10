-module(insert).
-include("init_db.hrl").
-export([main/0,report_donation_failure/3,validate_donate/3,insert_sender/1,read_sender_file/0,read_cause_file/0,read_receiver_file/0,read_subscriber_file/0,read_file/0,insert_transaction_receiver/1,insert_receiver1/2,read_receiver/1,subscribe_to_cause/2,insert_transaction/1,donate/9,tryforwardingL/10,tryforwardingLL/9,return_back/2,read_receiverlist/2,callSender_return_back/4,extract_Sender_id_locid_amount_t_table/1,payback/2,insert_receiver/1,gui_payback/2,gui_get_causes_as_string/0,convert_stringlist_to_singlestring/2,gui_get_donor_balance/1,get_cause_id/1,gui_validate_donor_id/1,gui_add_sender_balance/2]).


%donate call
%insert:donate(1000,4001,1001,'node1@Bastion','T4',node(),[['node2@Bastion'],['node3@Bastion']],3,[]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% METHODS RELATED TO INTIALISING DATABASE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

insert_sender([]) ->
	io:format("Insertion of Sender List completed.~n");
	
insert_sender([S|T]) ->
	io:format("Inserting ~p ~p ~p ~p ~n",[S#sender.s_id,S#sender.s_name,S#sender.s_balance,S#sender.loc_id]),
	F=fun()->
			mnesia:write(S)
		end,
	RV=mnesia:transaction(F),
	case RV of
		{aborted,_} -> io:format("Something Wrong in insert_sender!~n");		% 
		{_,_} -> 	io:format("~p ~n",[RV]), 
					insert_sender(T)
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
insert_receiver([]) ->
	io:format("Insertion of Receiver List completed.~n");
	
insert_receiver([S|T]) ->
	io:format("Inserting ~p ~p ~p ~p ~n",[S#receiver.r_id,S#receiver.r_name,S#receiver.r_balance,S#receiver.loc_id]),
	F=fun()->
			mnesia:write(S)
		end,
	RV=mnesia:transaction(F),
	case RV of
		{aborted,_} -> io:format("Something Wrong in insert_receiver!~n");		% 
		{_,_} -> 	io:format("~p ~n",[RV]), 
					insert_receiver(T)
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

insert_cause([]) ->	
	io:format("Insertion of Cause List completed.~n");
	
insert_cause([S|T]) ->	
	io:format("Inserting ~p ~p ~n",[S#cause.c_id,S#cause.c_name]),
	F=fun()->
			mnesia:write(S)
		end,
	RV=mnesia:transaction(F),
	case RV of
		{aborted,_} -> io:format("Something Wrong in insert_cause!~n");		% 
		{_,_} -> 	io:format("~p ~n",[RV]), 
					insert_cause(T)
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	
insert_subscriber([]) ->	
	io:format("Insertion of Subscriber List completed.~n");
	
insert_subscriber([S|T]) ->
	F=fun() ->
			Result=mnesia:read(receiver,S#subscriber.r_id),
			io:format("~p ~p ~n",[Result,S#subscriber.r_id]),
			case Result of
				[] ->
					io:format("Error: No such receiver~n");
				[_] ->
					io:format("Inserting ~p ~p ~n",[S#subscriber.r_id,S#subscriber.c_id]),
					mnesia:write(S)	
			end
		end,
	mnesia:transaction(F),	
	insert_subscriber(T).	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
insert_transaction([]) ->
			io:format("Insertion of transactions completed~n");
			

insert_transaction([S|T]) ->	
	io:format("Inserting transaction ~p ~n",[S]),
	F=fun()->
			mnesia:write(S)
		end,
	RV=mnesia:transaction(F),
	case RV of
		{aborted,_} -> io:format("Something Wrong in insert_cause!~n");		
		{_,_} -> 	io:format("~p ~n",[RV]), 
					insert_transaction(T)
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




read_sender_file() ->
	{ok,L}=file:consult("sender.lst"),
	insert_sender(L).

read_cause_file() ->
	{ok,L}=file:consult("cause.lst"),
	insert_cause(L).
	
read_receiver_file() ->
	{ok,L}=file:consult("receiver.lst"),
	insert_receiver(L).

read_subscriber_file() ->
	{ok,L}=file:consult("subscriber.lst"),
	insert_subscriber(L).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

read_file() ->
	read_sender_file(),
	read_cause_file(),
	read_receiver_file(),
	read_subscriber_file().


read_receiver(Rid) ->
		F=fun()->
			mnesia:read(receiver,Rid)
		end,
	RV=mnesia:transaction(F),
	case RV of
	{atomic,L} -> L;
	{aborted,_} -> []  %%need to take apprpriate action here
	end.
	
%takes receiver id and cause id and inserts into subscriber table	
subscribe_to_cause(Rid,Cid) ->
		F=fun() ->
			R1=mnesia:read(receiver,Rid),
			R2=mnesia:read(cause,Cid),
			io:format("~p ~p ~n",[R1,R2]),
			case {R1,R2} of
				{[],[_]} ->
					io:format("The receiver ~p is not registered~n",[Rid]);
				{[_],[]} ->
					io:format("The cause ~p is not present ~n",[Cid]);
				{[],[]} ->	
					io:format("The receiver ~p is not registered and The cause ~p is not present ~n",[Cid,Rid])	;
				{[_],[_]} ->
					mnesia:write({subscriber,Rid,Cid})
			end
		end,
	mnesia:transaction(F).	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

convert_stringlist_to_singlestring(L,Result) ->
		case L of
		[] -> Result;
		[[H]|T] -> convert_stringlist_to_singlestring(T,Result++","++H)
		end.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_cause_id(S) ->
	F = fun() ->
		MatchHead = #cause{c_id='$1',c_name=S},
		Guard = [],
		Result = ['$1'],
		mnesia:select(cause,[{MatchHead, Guard, [Result]}])
	end,
	RV=mnesia:transaction(F),
	case RV of
		{aborted,_} -> io:format("Transation Aborted!~n"),
						error_TransactionAborted;		
		{atomic,[]} -> 	error_causeNotFound;
		{atomic,[[L]]} -> 	io:format("Retrieved ~p ~n",[L]),
							L
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


insert_receiver1(Node,S) ->
	%io:format("Inserting ~p ~p ~p ~p ~n",[S#receiver.r_id,S#receiver.r_name,S#receiver.r_balance,S#receiver.loc_id]),
	%~ F=fun()->
			%~ R1 = mnesia:index_read(subscriber,S,c_id),
			%~ io:format("insert_receiver1::R1 ~p ~n",[R1])
		%~ end,
	%~ Pat = #subscriber{r_id= '_',c_id=S},
	%~ F = fun() -> mnesia:match_object(Pat) end,
	%~ F = fun() ->
	%~ MatchHead = #subscriber{r_id='$1', c_id=S},
	%~ Guard = [],
	%~ Result = '$1',
	%~ mnesia:select(subscriber,[{MatchHead, Guard, [Result]}])
	%~ end,
	%~ F = fun() ->
		%~ MatchHead = #t_table{t_id='_', s_id='$1',s_loc_id='$2',r_id ='_' ,_='_'},
		%~ Guard = [],
		%~ Result = ['$1','$2'],
		%~ mnesia:select(t_table,[{MatchHead, Guard, [Result]}])
	%~ end,
	F = fun() ->
		MatchHead = #cause{c_id='$1',c_name=S},
		Guard = [],
		Result = ['$1'],
		mnesia:select(cause,[{MatchHead, Guard, [Result]}])
	end,
	RV=mnesia:transaction(F),
	case RV of
		{aborted,_} -> io:format("Something Wrong in insert_receiver!~n");		% 
		{_,_} -> 	io:format("Retrieved ~p ~n",[RV])
	end.
	%R = rpc:call(Node,insert, read_file,[]),
	%~ io:format("GOT THIS:: ~p ~n",[R]).
	
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% METHODS RELATED TO DONATING MONEY %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
report_donation_failure(FailedList,Amount,Num_groups) ->
	io:format("Failed List : ~p ~p ~p~n",[FailedList,Amount,Num_groups]).


%%tested and working	
read_receiverlist(L1,L2) ->
	io:format("read_receiverlist:: ~p ~n",[L2]),
	case L1 of
	 []  -> L2;
	 [H|T] -> 
			io:format("read_receiverlist:: H ~p T ~p ~n",[H,T]),
			F=fun()->
					mnesia:read(receiver,H)
				end,
			RV=mnesia:transaction(F),
			case RV of
				{aborted,_} -> io:format("read_receiverlist::Something Wrong !~n");		% 
				{_,[A]} -> 	io:format("~p ~n",[RV]), 
							read_receiverlist(T,L2++[A])
			end
	end.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%tested and working
%this function receives a list of nodes on which the donation has to be made, tries to succesfully call donate an at least one node
tryforwardingL(Amount,Cid,Did,D_loc_id,T_id,Originator_name,L,Remaining_LL,Num_groups,FailedList) ->
		io:format("L: ~p ~p ~p ~p ~p ~p ~p ~p ~p~n",[Amount,Cid,Did,D_loc_id,T_id,Originator_name,L,Remaining_LL,Num_groups]),
		case L of
			[P1|P2] -> RV = rpc:call(P1,insert, donate,[Amount,Cid,Did,D_loc_id,T_id,Originator_name,Remaining_LL,Num_groups,FailedList]),
						io:format("L: RV = ~p ~n",[RV]),
						case RV of
							{badrpc,_} ->  
										io:format("L:Retrying ~n"),
										tryforwardingL(Amount,Cid,Did,D_loc_id,T_id,Originator_name,P2,Remaining_LL,Num_groups,FailedList);
							_ -> {success}
						end;
			[] -> {fail}
		end.	
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tested and working
%this function receives a List of lists L and tries to excute donate on some node in first list, if fails then on second list and so on till L becomes empty on which it return fail		
tryforwardingLL(Amount,Cid,Did,D_loc_id,T_id,Originator_name,L,Num_groups,FailedList) ->
		io:format("LL: ~p ~p ~p ~p ~p ~p ~p ~p ~n",[Amount,Cid,Did,D_loc_id,T_id,Originator_name,L,Num_groups]),
		case L of
			[] -> {fail,FailedList};
			[P1 | Remaining_LL] -> 
				%try to perform the transaction an any node in list P1
				{R} = tryforwardingL(Amount,Cid,Did,D_loc_id,T_id,Originator_name,P1,Remaining_LL,Num_groups,FailedList),
				io:format("LL: R = ~p ~n",[R]),
				case R of
					%Transaction failed on all nodes of P1, then try for remining node groups
					fail -> 
						tryforwardingLL(Amount,Cid,Did,D_loc_id,T_id,Originator_name,Remaining_LL,Num_groups,FailedList++[P1]);
					%Transaction succeded on some node in group P1,retunr success	
					success -> {success}
				end		 
		end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%this function is called by some process that wants to retunr back some amount that could not ne donated.
%tested and working
return_back(D_id,Amount) ->
		io:format("return_back :: Paying back to ~p amount ~p~n",[D_id,Amount]),
		F=fun() ->
			R1 = mnesia:read(sender,D_id)
		end,
		{Msg,[Record]} = mnesia:transaction(F),
		G =fun() ->
			R1 = mnesia:write({sender,Record#sender.s_id,Record#sender.s_name,(Record#sender.s_balance)+Amount,Record#sender.loc_id})
		end,
		mnesia:transaction(G).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tested and working
insert_transaction_receiver(L) ->
		io:format("insert_transaction_receiver: ~p ~n",[L]),
		F = fun() ->
			lists:foreach( fun({A,B}) ->
							mnesia:write(A),	%%insert receiver
							mnesia:write(B)		%%insert transaction record	
							end,L)
			end,
		mnesia:transaction(F).		
		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gui_validate_donor_id(Did) ->
	io:format("gui_validate_donor_id ~n"),
	F = fun() ->
			mnesia:read(sender,Did)
		end,
	%~ {Msg,[D_Record]} = mnesia:transaction(F),
	RV = mnesia:transaction(F),
	case RV of
	{atomic,[]} -> io:format("gui_validate_donor_id:: Donor not found"),
					error_donorNotFound;
	{aborted,_} -> io:format("gui_validate_donor_id:: Unknown error~n"),
					error_unable_to_read_database;
	{atomic,[D_Record]} -> 
					successful
	end.
						

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%checks for the validity of Did and Amount and calls the actual donate function
validate_donate(Did,CName,Amount) -> %change to cname
	Cid  = get_cause_id(CName),
	{ok,[D_loc_id]} = file:consult("Location_id.lst"),
	{ok,[A]} = file:consult("Transaction_number.lst"),
	[T_start|T_number] = A,
	T_id = [T_start]++integer_to_list(list_to_integer(T_number)+1),
	file:write_file("Transaction_number.lst", io_lib:fwrite("~p.\n", [T_id])),
	F = fun() ->
			mnesia:read(sender,Did)
		end,
	%~ {Msg,[D_Record]} = mnesia:transaction(F),
	RV = mnesia:transaction(F),
	case RV of
	{atomic,[]} -> io:format("validate_donate:: Donor not found"),
		   error_donorNotFound;
	{aborted,_} -> io:format("validate_donate:: Unknown error~n"),
			error_unable_to_read_database;
	{atomic,[D_Record]} ->		
		case Amount > D_Record#sender.s_balance of
		true -> io:format("validate_donate:: Cant donate more than balance ~n"),
				error_donationAmountMore;
		false -> 
				G = fun() ->
				mnesia:write({sender,D_Record#sender.s_id,D_Record#sender.s_name,(D_Record#sender.s_balance-Amount),D_Record#sender.loc_id})
					end,
				%~ {Msg,[D_Record]} = mnesia:transaction(F),
				RV1 = mnesia:transaction(G),
				case RV1 of 
				{atomic,_} -> io:format("validate_donate:: Donor record updated ~n"),
							{ok,[L1]} = file:consult("nodelist.lst"),
							Num_groups = length(L1)+1,%each node keeps a list of all other nodes not inclusing its own group hence add one
							io:format("~p ~p ~p ~p ~n",[D_loc_id,A,D_Record,Num_groups]),
							RV2 = donate(Amount,Cid,Did,D_loc_id,T_id,D_loc_id,L1,Num_groups,[]);
				{aborted,_} -> io:format("validate_donate:: Unable to read database~n"),
							error_unable_to_write_database
				end
		end	
	end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%~ %this function is called to donate Amount to cause Cid by donor Did, L is the list of lists processes grouped
%~ %call donate after verifying that Cid,Did,D_loc_id are valid
donate(Amount,Cid,Did,D_loc_id,T_id,Originator_name,L,Num_groups,FailedList) ->
	io:format("donate: ~p ~p ~p ~p ~p ~p ~p ~p ~n",[Amount,Cid,Did,D_loc_id,T_id,Originator_name,L,Num_groups]),
	F = fun() ->
		MatchHead = #subscriber{r_id='$1', c_id=Cid},
		Guard = [],
		Result = '$1',
		mnesia:select(subscriber,[{MatchHead, Guard, [Result]}])
		end,
	{Msg,RecieverIdList} = mnesia:transaction(F),
	io:format("donate:ReceiverIdList ~p ~n",[RecieverIdList]),

	ReceiverRecords = read_receiverlist(RecieverIdList,[]),
	io:format("donate:ReceiverRecords for ReceiverIdList ~p ~n",[ReceiverRecords]),

	UpdatedReceiverRecords = lists:map(fun(A) ->   
													V = {receiver,A#receiver.r_id,A#receiver.r_name,(A#receiver.r_balance+(Amount/length(RecieverIdList))/Num_groups),A#receiver.loc_id}	
											
										end,
									ReceiverRecords),
									
	io:format("donate:UpdatedReceiverRecords ~p ~n",[UpdatedReceiverRecords]),
	
	%construct the transaction record to be written into t_table
	TransactionRecords = lists:map(fun(A) -> 
											{t_table,T_id,Did,D_loc_id,A,(Amount/length(RecieverIdList))/Num_groups}
									end,
									RecieverIdList),
	io:format("donate:Transaction records: ~p ~n",[TransactionRecords]),
	
	ListToBeInserted = lists:zip(UpdatedReceiverRecords,TransactionRecords),
	io:format("donate:: ListToBeInserted: ~p ~n",[ListToBeInserted]),

	insert_transaction_receiver(ListToBeInserted),
	
	case L of
		[] ->
			io:format("donate: Found Empty List No more groups left~n"),
			%~ Result = rpc:call(Originator_name,insert,report_donation_failure,[FailedList,Amount,Num_groups]),
			%~ case Result of 
				%~ {atomic,ok} -> io:format("donate::DONE ~n"),
								%~ successful;
				%~ {badrpc,_} -> io:format("donate::HERE HERE~n"),
								%~ error_UnableToInformSource
			%~ end;
			%%dump data here to file
			io:format("donate: Dumping log data to file DonationFailure.txt ~n"),

			Dumpdata = FailedList++[Amount]++[Cid]++[Did]++[D_loc_id]++[T_id]++[Originator_name]++[L]++[Num_groups],
			file:write_file("DonationFailure.txt", io_lib:fwrite("~p.\n", [Dumpdata]),[append]);
		_ ->		
				%More sites are remaining for this transaction
				%try and call donate at next site which will in turn repeat the entire process
				case TransactionRecords of
				[] ->
					%no receiver is registered here so pass on the amount received				
					RV = tryforwardingLL(Amount,Cid,Did,D_loc_id,T_id,Originator_name,L,Num_groups,FailedList);
				_ ->%pass on the (amount received - amount consumed here) 
					RV = tryforwardingLL(Amount,Cid,Did,D_loc_id,T_id,Originator_name,L,Num_groups,FailedList)
				end,
				io:format("donate: RV = ~p ~n",[RV]),
				case RV of 
					{success} -> io:format("donate: My job done 1 ~n"),
								 successful;
					{fail,ReturnedFailedList} -> % the transaction could not be done at any further sites, so send back the remaining money to the place of origin of this transaction							
							%~ io:format("donate:: Returning amount ~p ~n",[Amount-(Amount/Num_groups)]),
							%~ Result = rpc:call(Originator_name,insert,return_back,[Did,Amount-(Amount/Num_groups)]),
							%~ Result = rpc:call(Originator_name,insert,report_donation_failure,[ReturnedFailedList,Amount,Num_groups]),
							Dumpdata = FailedList++[Amount]++[Cid]++[Did]++[D_loc_id]++[T_id]++[Originator_name]++[L]++[Num_groups],
							io:format("donate: Dumping log data to file DonationFailure.txt ~n"),
							file:write_file("DonationFailure.txt", io_lib:fwrite("~p.\n", [Dumpdata]),[append])

							%~ case Result of 
								%~ ok -> io:format("donate::DONE ~n"),
									  %~ successful;	
								%~ {badrpc,_} -> io:format("donate::HERE HERE~n"),
												%~ error_UnableToInformSource
							%~ end
				end
	end.		
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% METHODS RELATED TO PAYBACK %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
extract_Sender_id_locid_amount_t_table(S) ->
		F = fun() ->
			MatchHead = #t_table{t_id='_', s_id='$1',s_loc_id='$2',r_id = S ,amount='$3'},
			Guard = [],
			Result = ['$1','$2','$3'],
			mnesia:select(t_table,[{MatchHead, Guard, [Result]}])
			end,
		RV=mnesia:transaction(F),
		case RV of
			{aborted,_} -> io:format("extract_Sender_id_locid_amount_t_table:: Transaction Aborted!~n"),
						   []; 
			{_,L1} -> 	io:format("extract_Sender_id_locid_amount_t_table:: Retrieved ~p ~n",[RV]),
						L1
		end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
callSender_return_back(DonorList,Amount,DNumber,FailedList) ->
		case DonorList of
			[] -> {FailedList,Amount};
			[[Did,D_loc_id,D_amount]|T] ->	
											io:format("callSender_return_back:: ~p ~p ~p ~n",[Did,D_loc_id,D_amount]),
											case D_amount < Amount/length(DonorList) of
											true -> 
												Result = rpc:call(D_loc_id,insert,return_back,[Did,D_amount]),
												case Result of 
												{atomic,ok} -> io:format("callSender_return_back::DONE ~n"),
															   callSender_return_back(T,Amount-D_amount,DNumber,FailedList);		
												{badrpc,_} -> io:format("callSender_return_back::TROUBLE HERE ~n"),
															   callSender_return_back(T,Amount,DNumber,FailedList++[[Did,D_loc_id]])		
												end;

											false -> 
												Result = rpc:call(D_loc_id,insert,return_back,[Did,Amount/length(DonorList)]),
												case Result of 
													{atomic,ok} -> io:format("callSender_return_back::DONE ~n"),
																   callSender_return_back(T,Amount-(Amount/length(DonorList)),DNumber,FailedList);		
													{badrpc,_} -> io:format("callSender_return_back::TROUBLE HERE ~n"),
																   callSender_return_back(T,Amount,DNumber,FailedList++[[Did,D_loc_id]])		
												end
											end	
		end.				

			


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

payback(Rid,Amount) -> 
		DonorList = extract_Sender_id_locid_amount_t_table(Rid),
		case DonorList of 
		[] -> io:format("payback:: DonorList Empty!! Something Wrong ~n");
		_ ->
			{FailedList,AmountReturned} = callSender_return_back(DonorList,Amount,length(DonorList),[]),
			io:format("payback:: FailedList ~p ~n",[FailedList]),
			[ReceiverRecord] = read_receiver(Rid),
			%~ R = {receiver,ReceiverRecord#receiver.r_id,ReceiverRecord#receiver.r_name,(ReceiverRecord#receiver.r_balance)-((Amount/length(DonorList))*(length(DonorList)-(length(FailedList)))),ReceiverRecord#receiver.loc_id},
			R = {receiver,ReceiverRecord#receiver.r_id,ReceiverRecord#receiver.r_name,(ReceiverRecord#receiver.r_balance)-(Amount-AmountReturned),ReceiverRecord#receiver.loc_id},
			insert_receiver([R]),
			file:write_file("FailureLog.txt", io_lib:fwrite("~p.\n", [FailedList++[AmountReturned]]),[append])
		end.	

	

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%checks for the vakidity of Rid and Amount
gui_payback(Rid,Amount) ->
		F = fun() ->
			mnesia:read(receiver,Rid)
		end,
		RV = mnesia:transaction(F),
		case RV of
		{aborted,_} -> io:format("gui_payback: Could Not fetch your data ~n");
		{atomic,[]} ->  io:format("gui_payback: Receiver nor found ~n");
		{atomic,[R_Record]} -> 	case R_Record#receiver.r_balance < Amount of
					true -> io:format("gui_payback: Cant return more than loan ~n"),
						payback(Rid,Amount);
					false -> payback(Rid,Amount)	
					end
		end.				

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gui_add_sender_balance(Did,Amount) ->
				F = fun() ->
					mnesia:read(sender,Did)
				end,
	%~ {Msg,[D_Record]} = mnesia:transaction(F),
				RV = mnesia:transaction(F),
				case RV of
				{atomic,[]} -> io:format("add_sender_balance:: Donor not found"),
						error_donorNotFound;
				{aborted,_} -> io:format("add_sender_balance:: Unknown error~n"),
						error_unable_to_read_database;
				{atomic,[D_Record]} ->
					G = fun() ->
					mnesia:write({sender,D_Record#sender.s_id,D_Record#sender.s_name,(D_Record#sender.s_balance+Amount),D_Record#sender.loc_id})
						end,
					%~ {Msg,[D_Record]} = mnesia:transaction(F),
					RV1 = mnesia:transaction(G),
					case RV1 of 
					{atomic,_} -> io:format("add_sender_balance:: Donor record updated ~n"),
								 successful;
					{aborted,_} -> io:format("add_sender_balance:: Unable to read database~n"),
								error_unable_to_write_database
					end			
				end.
	


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_get_causes_as_string() ->
		F = fun() ->
			MatchHead = #cause{c_id='_', c_name='$1'},
			Guard = [],
			Result = ['$1'],
			mnesia:select(cause,[{MatchHead, Guard, [Result]}])
		end,
		RV=mnesia:transaction(F),
		case RV of
			{aborted,_} -> io:format("Something Wrong in insert_receiver!~n"),
							error_couldnotreadlist;		% 
			{atomic,L} -> 	io:format("Retrieved ~p ~n",[RV]),
							convert_stringlist_to_singlestring(L,[])
		end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
gui_get_donor_balance(Did) ->
		F = fun() ->
			MatchHead = #sender{s_id=Did ,s_name='_' ,s_balance='$1',loc_id='_'},
			Guard = [],
			Result = ['$1'],
			mnesia:select(sender,[{MatchHead, Guard, [Result]}])
		end,
		RV=mnesia:transaction(F),
		case RV of
			{aborted,_} -> io:format("Something Wrong in gui_get_donor_balance!~n"),
							error_TransactionAborted;		% 
			{atomic,[]} -> io:format("error_donorNotFound ~n"),
							error_donorNotFound;
			{atomic,[[L]]} -> io:format("Retrieved ~p ~n",[L]),
							L
		end.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
main() ->
	io:format("Self Id ~p ~n",[self()]),
	loop().
loop() ->
	receive
		{donate,Name,CauseName,Did,Amount} 
			-> RV = validate_donate(Did,CauseName,Amount),
					{counterserver, Name} ! {self(), RV},
				loop();
		{get_causes,Name} 
			-> RV = gui_get_causes_as_string(),
				io:format("~p ~n",[RV]),	
					{counterserver, Name} ! {self(), RV},
				loop();
		{check_bal,Name,Did} 
			-> RV = gui_get_donor_balance(Did),
				io:format("~p ~n",[RV]),	
					{counterserver, Name} ! {self(), RV*1.0},
				loop();
		{check_id,Name,Did} 
			-> 	io:format("~p ~p ~n",[Did,Name]),	
				RV = gui_validate_donor_id(Did),
				{counterserver, Name} ! {self(), RV},
				loop();
		{add,Name,Did,Amount}
			-> RV = gui_add_sender_balance(Did,Amount),
				{counterserver, Name} ! {self(), RV},
				loop()			
	end.
	
