# kristalalfred/tap

Homebrew formulae for Exo, Ramp, Ronna, ws, aui, and facetty.

## Install

```sh
brew install kristalalfred/tap/ws
```

ws depends on `kristalalfred/tap/ronna`. Ramp depends on
`kristalalfred/tap/exo`, which provides `exo` and `exod`. To install the runtime alone:

```sh
brew install kristalalfred/tap/exo
```

The packages contain binaries and release metadata. Install Lua plugins and
configuration through the [Ramp starter](https://github.com/kristalalfred/ramp-starter).
Native packages support macOS 12 or newer and Linux, on arm64 and x86_64.
Linux packages require glibc 2.35 or newer.

## Exo

`exo` is the command-line client; `exod` runs agents. Exo is distributed under
the MIT license.

## Ramp

`ramp` is a programmable terminal frontend for agent harnesses. Ramp is
distributed under the MIT license.

## Ronna

`ronna` signs in to a Ronna server and manages teams, GitHub access and cloud
workspaces. Ronna is closed source. Its public packages contain the client
binary; server binaries remain in the private source repository.

## ws

`ws` gives each Ronna workspace you can use a Rex host and opens workspaces in
Rex.app. It uses the installed `ronna` CLI and needs Rex. ws is closed source.

## aui

`aui` is the Lua-customizable terminal client for Ronna 0.1. It is retired and
does not work with Ronna 0.2 or newer. aui is closed source.

## Publish a release

Maintainers need `gh` authenticated for the source repositories and this tap,
Python 3.11 or newer, `just`, and `actionlint`. Set `PYTHON` to choose an
interpreter, for example `export PYTHON=/opt/homebrew/bin/python3`.

Run `just check`, then build each project at its release commit:

```sh
just build exo 0.1.0 <exo-commit>
just build ramp 0.1.0 <ramp-commit>
just build ronna 0.1.0 <ronna-commit>
just build ws 0.1.0 <ws-commit>
```

The source's Cargo version must match the requested version. The build command
freezes a `homebrew-vVERSION` source tag, runs the repository's native release
workflow, verifies its artifacts, and stores them in a private GitHub release.
An existing published source release is reused. To store archives built with
the project's `scripts/package-release.sh` instead, pass their directory as the
fourth argument; ws has no release workflow.

Prepare the Exo runtime before Ramp:

```sh
just prepare exo 0.1.0
just prepare ramp 0.1.0
just prepare ronna 0.1.0
just prepare ws 0.1.0
```

Preparation verifies checksums, source revisions, platforms, and Ramp's Exo
revision. It copies only each formula's binaries and release metadata into
the public archives. Generated formulae and provenance records live in
`Formula/` and `releases/`; private downloads and prepared archives stay in the
ignored `.dist/` directory.

Review the files, run `just check` and `brew style Formula/{exo,ramp,ronna,ws}.rb`,
then commit and push them to this repository before publishing:

```sh
just publish exo 0.1.0
just publish ramp 0.1.0
just publish ronna 0.1.0
just publish ws 0.1.0
just ci
```

Publishing creates public releases in this tap with tags `PROJECT-vVERSION`.
Published versions are immutable. `just ci` verifies Homebrew installation and
formula tests on macOS and Linux, on both architectures. This workflow uses
public downloads and needs no access to the private source repositories.
