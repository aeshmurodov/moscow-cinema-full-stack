#!/bin/bash
pg_dump -s -h localhost -U user -d test_db > back/db_schema/current_schema.sql