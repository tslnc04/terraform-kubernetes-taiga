# terraform-kubernetes-taiga

A Terraform module for deploying Taiga to Kubernetes, adapted from the [taiga-docker] project.

[taiga-docker]: https://github.com/taigaio/taiga-docker

## Usage

This module is intentionally not published to the Terraform registry. Instead, it is recommended to fork this repository and use it as a starting point for your own module. Many specifics of the environment are assumed in this repository, such as the use of 1Password for secrets and the use of a local volume provisioner.

## Copyright

The taiga-docker project is licensed under the [MPL-2.0]. Its license can be found in the [LICENSE-taiga] file.

[MPL-2.0]: https://www.mozilla.org/en-US/MPL/2.0/
[LICENSE-taiga]: ./LICENSE-taiga

This module itself is licensed under the [MIT License](./LICENSE). Copyright 2024 Kirsten Laskoski.
