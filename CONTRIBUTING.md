# Contributing

## Local Development

Use the Makefile to manage your local installation during development:

| Target      | Description                                      |
|-------------|--------------------------------------------------|
| `help`      | Print usage information                          |
| `install`   | Symlink the addon into your WoW AddOns directory |
| `uninstall` | Remove the addon symlink                         |
| `clean`     | Alias for `uninstall`                            |

All targets that interact with the WoW directory require the `WOW_DIR` variable:

```sh
make install WOW_DIR='/path/to/World of Warcraft'
```

## Reporting Issues

Please report bugs and feature requests through the GitLab Issues tracker. Pull requests are welcome, but an issue must exist before a PR is opened. Reference the relevant issue number in your PR description.

## Generated Code

Any pull request that contains generated code (from AI tools, code generators, scaffolding utilities, or similar) must have a human author who is responsible for reviewing, understanding, and managing the PR. The human author must be able to explain every change in the PR and respond to review feedback. PRs that consist solely of unreviewed generated output will be closed.
