-record(sender, {s_id,s_name,s_balance,loc_id}).
-record(receiver, {r_id,r_name,r_balance,loc_id}).
-record(cause, {c_id,c_name}).
-record(subscriber, {r_id,c_id}).
-record(t_table, {t_id,s_id,s_loc_id,r_id,amount}).