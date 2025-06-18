<img src="https://cloud.bitfl0wer.de/apps/files_sharing/publicpreview/2qCxoXJ27yW7QNR?file=/&fileId=1143147&x=256&y=256&a=true" align="left" alt="a purple cog, split in the middle along the horizontal axis with a gap inbetween the two halves. three overlayed, offset sinus-like waves travel through that gap. each wave has a different shade of purple" width="128px" height="auto"></img>

### `typespec-openapi`

[![Code-of-conduct-shield]][Code-of-conduct]
[![Build/Deploy OpenAPI specification](https://github.com/polyphony-chat/docs/actions/workflows/deploy-openapi-spec.yml/badge.svg)](https://github.com/polyphony-chat/docs/actions/workflows/deploy-openapi-spec.yml)
[![Discord]][Discord-invite]
[![FAQ-shield]][FAQ]

[FAQ-shield]: https://img.shields.io/badge/Frequently_Asked_Questions_(FAQ)-ff62bd
[FAQ]: https://github.com/polyphony-chat/.github/blob/main/FAQ.md

Specification documents and API documentation for `polyproto`, `polyproto-chat` and `polyproto-mls`.

API documentation built with [TypeSpec](https://typespec.io).

## Pre-compiled OpenAPI schema(s)

Find the pre-compiled OpenAPI v3.1 schema file(s) in the [`/build`](https://github.com/polyphony-chat/docs/tree/main/build) directory. The schema is automatically built and deployed to the `main` branch on every push to the `main` branch.

## Contributing

The best way to contribute is to open an issue if you find any problems with the documentation. Creating an issue is generally the best way to contribute to any open source project. Issues allow for an exchange between contributors and maintainers to discuss the viability of implementing an issue, usually minimizing frustration.

You should also read our [Code of Conduct](https://github.com/polyphony-chat/.github/blob/main/CODE_OF_CONDUCT.md) and [Contributing Guidelines](https://github.com/polyphony-chat/.github/blob/main/CONTRIBUTION_GUIDELINES.md) before contributing.

## Setting up a development environment

You will need the following things installed on your computer:

- `Node.js >= 20`
- `npm`. I personally prefer `pnpm`, but have found it to *not work* with TypeSpec. Maybe this is
  a me-issue, but I recommend `npm` for best compatibility nonetheless.
- `git`
- `TypeSpec` - install it globally with `npm install -g @typespec/compiler`

1. Navigate to the `/polyproto` directory.
2. Select the project you want to compile. In this example, we are compiling the `core` project.
   Navigate to that directory.
3. Run `tsp install` to install the dependencies.
4. Run `tsp compile .` to compile the project or `tsp compile --watch .` to automatically recompile
   the project when you save a file.
5. The compiled OpenAPI3 schema will be in the `$PROJECT/tsp-output/@typespec/openapi3` directory.

[Discord]: https://dcbadge.vercel.app/api/server/m3FpcapGDD?style=flat
[Discord-invite]: https://discord.com/invite/m3FpcapGDD
[Code-of-conduct-shield]: https://img.shields.io/badge/Code_of_Conduct-eb00ff
[Code-of-conduct]: https://github.com/polyphony-chat/.github/blob/main/CODE_OF_CONDUCT.md