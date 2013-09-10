install.erl : has functions related to setting up of databases on nodes
init_db.erl : has functions related to creating tables on given list of nodes
insert.erl  : has functions for populating the tables created by reading data from file
administer.erl : functions for administration like adding causes, etc

SETUP PROCEDURE:
After setting up nodes,
call install:setup(L). See setup definition for details about L. This will create tables with copies on nodes as required.
call insert:read_file() on one node in each group to populate the tables created, may automate this also if needed.


A pool of users is already registered.
try except for case of down nodes.
