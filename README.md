mdb2postgresql
==============

At my day job we liberate a lot of old Access databases into open
source solutions.  It's nice to be able to perform the initial
data migration step without having to use any proprietary software.

This is the script I use to hop from Access to PostgreSQL, relying
on mdbtools.  The most recent official master of mdbtools can be
found on github at:

[https://github.com/brianb/mdbtools](https://github.com/brianb/mdbtools)


OS X Stuff
----------

Since I carry a MacBook Pro, I need it to work on OS X too, and
for that I use a combination of MacPorts and a recent build of
mdbtools twiddled for OS X, which lives here:

[https://github.com/rfc2616/mdbtools](https://github.com/rfc2616/mdbtools)

(It would be nice to get the relevant patches into mdbtools master
and update MacPorts to use it; help?)

To build and install the Mac version:

    port install glib2 libtool automake txt2man
    sh automake.sh
    sudo make install


Using The Script
----------------

Armed with your mdbtools:

    sh mdb2postgresql.sh [mdbfile] [sqlscript]

This will create a file named [sqlscript] suitable for loading
into PostgreSQL.  So, for example:

    sh mdb2postgresql.sh AccessIsUgly.mdb pg_is_lovely.sql
    createdb pg_is_lovely
    psql --set ON_ERROR_STOP=on pg_is_lovely < pg_is_lovely.sql


The More You Know
-----------------

All `BOOL`s are remapped to `INTEGER`s on their way to PostgreSQL.
Boolean values come out of Access as {0,1} which PostgreSQL
doesn't accept.  A possible future solution would be to add a
flag to mdb-export that allows us to specify how to represent
booleans in the SQL INSERT style of dump.

This script inserts everything to a `source` schema.  In my
little world there is always a next step of ETL, and this
gives me a nice baseline of the source data mostly as it was
in Access.  The next step then can consist of a set of nice
fast SQL queries to copy that data into a model that aligns
better with whatever ORM framework is in use.  Once the
original Access data is no longer needed, I can drop it all
easily with

    DROP SCHEMA source CASCADE

For speed and accuracy, each table is inserted in its own
transaction with an exclusive lock over the table.  The
entire table will fail if an error occurs in the import of
any one row.

The script doesn't attempt to deal with backslashes, which can
be a known cause of table exports failing.  I think the best
solution for this is to enable `standard_conforming_strings=on`
in your postgresql.conf; there is motion afoot to make
`standard_conforming_strings=on` the default in PostgreSQL 9.1
and later in any case.  See:

[http://wiki.postgresql.org/wiki/Standard_conforming_strings](http://wiki.postgresql.org/wiki/Standard_conforming_strings)
