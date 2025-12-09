#!/bin/bash
sqlite3 test_db.db ".schema" > back/db_schema/current_schema.sql
