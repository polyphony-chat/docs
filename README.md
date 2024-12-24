<center>

[![Build/Deploy OpenAPI specification](https://github.com/polyphony-chat/docs/actions/workflows/deploy-openapi-spec.yml/badge.svg)](https://github.com/polyphony-chat/docs/actions/workflows/deploy-openapi-spec.yml)
[![mkdocs documentation](https://github.com/polyphony-chat/docs/actions/workflows/python-mkdocs.yml/badge.svg)](https://github.com/polyphony-chat/docs/actions/workflows/python-mkdocs.yml)
[![Discord]][Discord-invite]
[![Code-of-conduct-shield]][Code-of-conduct]

[Discord]: https://img.shields.io/badge/Discord_Server-390075
[Discord-invite]: https://discord.com/invite/m3FpcapGDD
[Code-of-conduct-shield]: https://img.shields.io/badge/Code_of_Conduct-eb00ff
[Code-of-conduct]: https://github.com/polyphony-chat/.github/blob/main/CODE_OF_CONDUCT.md

</center>

# Documentation

Specification documents and API documentation for the polyproto federated messaging protocol.

Documentation built with mkdocs-material and python3.12

API documentation built with [TypeSpec](https://typespec.io).

## Pre-compiled OpenAPI schema(s)

Find the pre-compiled OpenAPI schema file(s) in the [`/api/build`](https://github.com/polyphony-chat/docs/tree/main/api/build) directory. The schema is automatically built and deployed to the `main` branch on every push to the `main` branch.

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

### Documentation

You will need the following things installed on your computer:

- `python3.12`
- `pip`
- Any sort of python virtual environment manager - use `venv` if in doubt
- `git`

Optionally, you can install [`vale`](https://vale.sh/) for spell-/grammar checking.

Use `pip install -r requirements.txt` to install the required dependencies, and `mkdocs build` or
`mkdocs serve` to build the project or serve it on localhost.

### API documentation

You will need the following things installed on your computer:

- `Node.js >= 20`
- `npm`, `pnpm` or `yarn`
- `git`
- `TypeSpec` - install it globally with `npm install -g @typespec/compiler`

1. Navigate to the `/api/src` directory.
2. Select the project you want to compile. In this example, we are compiling the `core` project.
   Navigate to that directory.
3. Run `tsp install` to install the dependencies.
4. Run `tsp compile .` to compile the project or `tsp compile --watch .` to automatically recompile
   the project when you save a file.
5. The compiled OpenAPI3 schema will be in the `$PROJECT/tsp-output/@typespec/openapi3` directory.
