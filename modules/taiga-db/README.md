# taiga-db

This module abstracts the deployment of a Taiga database instance. It is using PostgreSQL 14.

## Requirements

### Secret

The secret must contain the following keys:

- `POSTGRES_PASSWORD`: the password for the database user

### Config Map

The config map must contain the following keys:

- `POSTGRES_USER`: the username for the database user
