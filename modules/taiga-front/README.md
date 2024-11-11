# taiga-front

This module abstracts the deployment of a Taiga front instance.

## Requirements

### Config Map

The config map must contain the following keys:

- `TAIGA_URL`: the URL of the gateway, starting with `https://`
- `TAIGA_WEBSOCKETS_URL`: the URL of the gateway, starting with `wss://`
- `TAIGA_SUBPATH`: the subpath to use for the front instance
