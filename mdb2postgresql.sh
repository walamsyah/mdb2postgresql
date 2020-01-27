#!/bin/bash

# echo "\set QUIET\nCREATE SCHEMA public;\n" > $2
echo "SET statement_timeout = 0;" > $2
echo "SET lock_timeout = 0;" >> $2
echo "SET idle_in_transaction_session_timeout = 0;" >> $2
echo "SET client_encoding = 'UTF8';" >> $2
echo "SET standard_conforming_strings = on;" >> $2
echo "SELECT pg_catalog.set_config('search_path', '', false);" >> $2
echo "SET check_function_bodies = false;" >> $2
echo "SET xmloption = content;" >> $2
echo "SET client_min_messages = warning;" >> $2
echo "SET row_security = off;" >> $2
echo "SET synchronous_commit TO off;" >> $2
echo "SET default_tablespace = '';" >> $2
echo "SET default_with_oids = false;\n" >> $2

mdb-schema -N "public" $1 postgres >> $2
perl -p -i -e 's|DROP TABLE |DROP TABLE IF EXISTS |g' $2
perl -p -i -e 's|BOOL|INTEGER|g' $2

for i in `mdb-tables $1`
do
  echo $i
  echo "BEGIN;\nLOCK TABLE public.\"$i\";\n" >> $2
  mdb-export -I postgres -q \' -N "public" -R "\n" $1 $i >> $2
  echo "COMMIT;\n" >> $2
done

# perl -p -i -e 's|"public"."|"public.|g' $2
perl -p -i -e 's|"||g' $2
perl -p -i -e 's|CONSTRAINT public.|CONSTRAINT |g' $2
perl -p -i -e 's|CREATE INDEX public.|CREATE INDEX |g' $2
perl -p -i -e 's|CREATE UNIQUE INDEX public.|CREATE UNIQUE INDEX |g' $2
perl -p -i -e 's|1RiderCode|RiderCode1|g' $2
perl -p -i -e 's|2RiderCode|RiderCode2|g' $2
