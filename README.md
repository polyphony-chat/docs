# Documentation

Specification documents and API documentation for the polyproto federated messaging protocol
Built with mkdocs-material and python3.12

## File structure

The `/docs` folder has the specification documents for the polyproto protocol.

The `/snippets` folder has snippets of text used in many places in the documentation. This is to ensure consistency across the documentation. Error messages appearing in many places are also stored in the `/snippets/errors` folder.

API documentation in form of [TypeSpec](https://typespec.io) files can be found in the `/api` directory.
TypeSpec can compile to OpenAPI3, JSON Schema and Protobuf. Our TypeSpec project is targeting OpenAPI3
output. Read the TypeSpec documentation for information on how to compile TypeSpec or use a pre-compiled
version of the OpenAPI schema if you'd like.

## Contributing

The best way to contribute is to open an issue if you find any problems with the documentation. Creating an issue is generally the best way to contribute to any open source project. Issues allow for an exchange between contributors and maintainers to discuss the viability of implementing an issue, usually minimizing frustration.

You should also read our [Code of Conduct](https://github.com/polyphony-chat/.github/blob/main/CODE_OF_CONDUCT.md) and [Contributing Guidelines](https://github.com/polyphony-chat/.github/blob/main/CONTRIBUTION_GUIDELINES.md) before contributing.

## Setting up a development environment

You will need the following things installed on your computer:

- `python3.12`
- `pip`
- Any sort of python virtual environment manager - use `venv` if in doubt
- `git`

Optionally, you can install [`vale`](https://vale.sh/) for spell-/grammar checking.

Use `pip install -r requirements.txt` to install the required dependencies, and `mkdocs build` or
`mkdocs serve` to build the project or serve it on localhost.
