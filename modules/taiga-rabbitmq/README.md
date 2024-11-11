# taiga-rabbitmq

This module abstracts the deployment of a RabbitMQ instance for Taiga.

## Requirements

### Secret

The secret must contain the following keys:

- `RABBITMQ_PASS`: the password for the RabbitMQ user
- `RABBITMQ_ERLANG_COOKIE`: the Erlang cookie for the RabbitMQ user

### Config Map

The config map must contain the following keys:

- `RABBITMQ_USER`: the username for the RabbitMQ user
- `RABBITMQ_VHOST`: the default virtual host for the RabbitMQ user
