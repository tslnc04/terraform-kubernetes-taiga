# taiga-protected

This module abstracts the deployment of a Taiga protected instance.

## Requirements

### Secret

The secret must contain the following keys:

- `TAIGA_SECRET_KEY`: the secret key for the Taiga instance

### Config Map

The config map must contain the following keys:

- `MAX_AGE`: the maximum age of the cache in seconds
