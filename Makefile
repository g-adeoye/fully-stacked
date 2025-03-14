# sqlc yaml file
SQLC_YAML ?= ./sqlc.yaml

psql:
	docker exec -it fully-stacked-db psql -U fully -d fully
createdb:
	docker exec -it fully-stacked-db psql -U fully -d fully -c "\i /schema/schema.sql"
postgresdown:
	docker exec -it fully-stacked-db psql -U fully -d fully -c "\i /schema/drop_schema.sql"
postgresup:
	docker compose up -d
teardown_recreate: postgresdown postgresup
	sleep 5
	$(MAKE) creat

generate:
	@echo "Generating Go models with sqlc "
	sqlc generate -f $(SQLC_YAML)

build-binary:
	@echo: "Building go binary"
	go build -C cmd/ -o ../bin/server