# taiga-events

This module abstracts the deployment of a Taiga events instance.

## Requirements

### Secret

The secret must contain the following keys:

- `RABBITMQ_PASS`: the password for the RabbitMQ user
- `TAIGA_SECRET_KEY`: the secret key for the Taiga instance

### Config Map

The config map must contain the following keys:

- `RABBITMQ_USER`: the username for the RabbitMQ user
