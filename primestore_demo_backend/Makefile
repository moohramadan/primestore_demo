postgres:
	docker run --name primestore_db -p 5433:5432 -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=secret -d postgres:16-alpine

createdb:
	docker exec -it primestore_db createdb --username=postgres --owner=postgres primestore

dropdb:
	docker exec -it primestore_db dropdb --username=postgres primestore

migrateup:
	migrate -path db/migration -database "postgresql://postgres:secret@localhost:5433/primestore?sslmode=disable" -verbose up

migratedown:
	migrate -path db/migration -database "postgresql://postgres:secret@localhost:5433/primestore?sslmode=disable" -verbose down

sqlc:
	sqlc generate

.PHONY: postgres createdb dropdb migrateup migratedown sqlc

