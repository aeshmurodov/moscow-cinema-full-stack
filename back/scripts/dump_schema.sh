#!/bin/bash
pg_dump -s -h localhost -U user -d test_db > db_schema/current_schema.sql