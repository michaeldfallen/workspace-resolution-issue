# Workspaces dependency resolution issue

This repo is a proof of concept that proves an issue we have found in yarn
workspaces.


## Preconditions

To replicate you need:

- Two workspaces with each depending on the same two dependencies
  We'll call these the "root" dependency and the "child" dependency

- The "child" dependency needs to declare a peer dependency to the "root" dependency

- The two workspaces require different versions of the "root" dependency

- Both workspaces require the same version of the "child" dependency

- The "child" dependency has been `nohoist`ed

  If it wasn't it would resolve the "root" dependency from the top level `node_modules`
  instead of the version declared in the workspaces `package.json`

In this repo we have replicated as:

- `workspace-a` requires `mobx@4.0.0` and `mobx-react@5.1.2`

- `workspace-b` requires `mobx@4.3.0` and `mobx-react@5.1.2`

- `mobx-react` requires `mobx@^4` as a peer

- The root `package.json` has `nohoist: [ "**/mobx-react" ]`


## Issue

When resolving dependencies yarn will only build the dependency tree for the same
version of a dependency once. So when it resolves the "child" it does so in
the context of the first workspace. The dependency graph for the "child" then
gets locked with the version that the first workspace has declared and resolved
for the "root" dependency.

When resolving the same version of the "child" for other workspaces yarn ignores
that the version required of the "root" is different and so the "child" gets installed
with the first workspaces version of the "root".

This results in:

```
node_modules > root 1.0.0

workspace-a > node_modules > child 1.0.0

workspace-b > node_modules > root 2.0.0
workspace-b > node_modules > child 1.0.0
workspace-b > node_modules > child > node_modules > root 1.0.0
```

The end result is that when code from the "child" runs in workspace-b it will
be using a different version of "root" than the one that workspace-b is requesting,
despite that version being correct for it's dependency string.


## Replication

Checkout this repo and run:

```bash
yarn install --force --check-files
./listVersions.sh
```

you will see that `mobx-react` inside `workspace-b` has the wrong version of
`mobx` installed inside it.
