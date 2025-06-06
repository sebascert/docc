# Docc

Docc converts a collection of markdown sources into a given target, using
[pandoc](https://pandoc.org/) under the hood.

## Dependencies

Docc requires:

- [pandoc >=3](https://pandoc.org/installing.html).
- [python >=3.7](https://www.python.org/downloads/).
- [yq >=4](https://github.com/mikefarah/yq/#install).

## How to use

There are several ways to use this project depending on your [version control
needs](#version-control-workflows). After choosing a version control workflow,
add your document contents to `src/` in markdown files, then generate your
document with:

```bash
./docc.sh
```

The output document will be in `out/<configured-name>`, which defaults to
`out/doc.pdf`.

To see the full usage of this script run:

```bash
./docs.sh --help
```

### Sources Formatting

[Prettier](https://prettier.io/) is used for formatting the source files, to do
so run:

> The cover page is excluded as it uses non standard pandoc markdown syntax.

```bash
./docc.sh --format
```

## Config

> The default configuration is mostly to my taste.

Pandoc configuration is stored in `config/metadata.yaml`, read the official docs on
[pandoc metadata](https://pandoc.org/MANUAL.html#metadata-variables) for the
available options. Change the cover contents in `src/cover.md`, read the
[official docs](https://pandoc.org/MANUAL.html#extension-pandoc_title_block) for
the format and options.

> The table of contents is configured in `config/metadata.yaml`

Docc configuration is stored in `config/config.yaml`, the available options are
as follows:

```yaml
output_filename: doc.pdf

cover_page: true

include_all_sources: true
# defines the rendering order for the given sources
# if include_all_sources is set to false, only include this sources
# provide sources relative to src/ i.e. source.md, not src/source.md
sources:
#- source1
#- source2
#- ...
```

## Version Control Workflows

### GitHub Fork

The simplest way to use Docc with version control is to
[fork](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/about-forks)
this repo, this gives you an identical copy of this repo, under your GitHub
account.

### Within a Git Repo

A common scenario is wanting to track the documentation for a project. The
straightforward approach is to discard the history of this repo, and just
commit the project files into your project history. However, this becomes
problematic when you need to upgrade to a different version of Docc.

A better solution is to use `git submodules`, with them you can manage the
history of both your project and docc simultaneously by [forking](#github-fork)
this repo and then using it as a submodule of your project.

> If you're not familiar with them, I highly recommend reading this
> [guide](https://git-scm.com/book/en/v2/Git-Tools-Submodules).

### Discard Version Control

If you wish to discard version control (discouraged), simply download the repo
contents and remove the git database:

```bash
git clone --depth=1 "https://github.com/sebascert/docc.git"
rm -rf ./docc/.git
```

### Tags

When you fork the repo you may want to keep this repo as a remote to upgrade to
new versions, to do so add it as the `upstream` remote in your local clone:

```bash
# on your docc clone
git remote add upstream https://github.com/sebascert/docc.git
```

Another useful tip is to take advantage of the `git refspec`, and prefix the
Docc tags with `docc/` (as git prefix branches from a remote with `remote/`),
for configuring this, edit the `[remote "upstream"]` section in your
`.git/config` with:

```ini
# DO NOT actually comment your url or +fetch/heads/ lines
[remote "upstream"]
#	url = https://github.com/sebascert/docc.git
#	fetch = +refs/heads/*:refs/remotes/upstream/*
	fetch = +refs/tags/*:refs/tags/docc/*
	tagopt = --no-tags
```

## Contributing

For bugs or requested features please contribute an issue, if you want to
contribute code or documentation open a PR.
