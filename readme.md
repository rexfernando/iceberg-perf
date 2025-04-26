# Trino with Iceberg, Postgres, and MinIO

This is an example using Trino with an Iceberg connector, a Postgres metastore, and MinIO for object storage.

Start everything up:
```shell
docker compose up
```

Connect to the Trino controller to execute some SQL:
```shell
docker compose exec trino trino
```

To Test performance (adjust the sql commands in init.sql before you run):
```docker exec -it trino trino --server localhost:8080 --catalog iceberg --schema tpch --file /etc/trino/init.sql
```

Stop and remove the containers and network:
```shell
docker compose down
```
