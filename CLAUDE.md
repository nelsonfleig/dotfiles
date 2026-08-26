# Dotfiles (chezmoi source)

Notes for coding agents working in this repo. Humans are welcome to read it too,
but it exists to answer the things that are not obvious from the file tree.

This is a [chezmoi](https://www.chezmoi.io) source directory, not a pile of
symlinked dotfiles. That single fact drives most of what follows.

## How to read the file tree

chezmoi derives each target path from the source filename's prefixes. Nothing here
is named for decoration:

| Source | Target / effect |
|---|---|
| `dot_vimrc` | `~/.vimrc` — `dot_` becomes a leading `.` |
| `dot_config/ghostty/config` | `~/.config/ghostty/config` |
| `*.tmpl` | Rendered as a Go template before it lands |
| `executable_statusline.sh` | Target gets the executable bit |
| `modify_settings.json.tmpl` | **A script, not a file.** See below |
| `run_after_*.sh` | Runs after every apply |
| `run_once_after_*.sh` | Runs once ever, tracked in chezmoi's state |
| `.chezmoitemplates/` | Shared content, never a target itself |
| `.chezmoiignore` | Target paths to skip |

Two consequences worth internalising:

- **Anything at the root without a prefix becomes a target in `$HOME`.** A stray
  `notes.md` here would be applied to `~/notes.md`. That is why `CLAUDE.md` and
  `setup.sh` are listed in `.chezmoiignore`. Entries starting with `.` are exempt —
  chezmoi ignores them — which is how `.gitignore` and `.git` sit here safely.
- **Source paths are not target paths.** `.chezmoiignore` patterns match the
  *target* (`.config/**/lazy-lock.json`), not the source.

## Layout

```
.chezmoitemplates/     Content included by the modify_ scripts (see below)
  claude-settings.json   Desired ~/.claude/settings.json
  zshrc                  The actual zshrc — edit this, not a dot_zshrc
dot_claude/            Claude Code config
dot_config/            ghostty, tmux, nvim-nelson, nvim-rover
dot_gitconfig.tmpl     Templated: macOS-only sections are skipped on Linux
dot_p10k.zsh           powerlevel10k prompt
modify_dot_zshrc.tmpl  Script that emits ~/.zshrc
run_after_*.sh         Post-apply hooks
setup.sh               One-shot bootstrap; chezmoiignored, never a target
```

## The two `modify_` scripts, and why they exist

`~/.zshrc` and `~/.claude/settings.json` are both written by *other* programs
after chezmoi writes them:

- Claude Code persists its own keys into `settings.json` (`tui`), and
  `run_after_wiki_setup.sh` adds `hooks`.
- The Rover web repo's `scripts/refresh-secrets.sh` strips and re-appends an OTel
  block to `~/.zshrc` on **every** run.

As plain managed files, chezmoi saw both targets as externally modified and
stopped to ask what to do. With no TTY — a container build, CI, any
non-interactive apply — that prompt is a hard error, and it aborted the apply
*before the `run_after_` scripts ran*. That is the failure this design exists to
prevent, and it is why the wiki setup silently stopped working after a rebuild.

A `modify_` entry is a script: chezmoi feeds it the current target on stdin and
writes its stdout to the target. Crucially it is **not** state-compared, so there
is nothing to prompt about. Each script merges the desired content over whatever
is already on disk:

- `modify_settings.json.tmpl` — deep-merges JSON. Declared keys win, nested
  objects merge recursively, arrays are unioned. So runtime-granted permissions
  and Claude Code's own keys survive an apply instead of being reverted.
- `modify_dot_zshrc.tmpl` — emits `.chezmoitemplates/zshrc`, then re-appends
  refresh-secrets' block if the file on disk had one.

Both are idempotent: applying twice changes nothing the second time.

### Editing these two files

```sh
$EDITOR .chezmoitemplates/zshrc       # or .chezmoitemplates/claude-settings.json
chezmoi apply ~/.zshrc
```

**Do not run `chezmoi add ~/.zshrc`.** It prompts `adding .zshrc would remove
template attribute` and, if confirmed, replaces the `modify_` script with a plain
snapshot of the current file. That reintroduces the prompt bug and bakes
machine-specific content into the repo (refresh-secrets' absolute
`/workspaces/web/...` cache path; `tui` and the wiki `hooks`). The same applies to
`chezmoi add ~/.claude/settings.json`.

`chezmoi edit ~/.zshrc` is also not the entry point — it opens the wrapper script,
not the content. There is no way to point it at the template.

The general rule: `chezmoi add` is for bringing a *new* file under management. Once
a file is managed, edit the source.

## Bootstrap

`setup.sh` is the one-shot bootstrap Codespaces runs. It is chezmoiignored, so it
is never applied anywhere. It is **not** idempotent — it does `chsh`, `sudo
install`, and clones oh-my-zsh plugins — so do not re-run it whole to test a
change. Run the specific `run_after_*.sh` script instead.

Downloads go through `mktemp -d` with an EXIT trap; clones go through
`clone_once`; release lookups go through `latest_release`, which sends
`$GITHUB_TOKEN` when set and fails loudly rather than silently installing nothing.

## Post-apply hooks

| Script | Does |
|---|---|
| `run_after_wiki_setup.sh` | Clones/updates the private research wiki at `/workspaces/wiki`, registers its Claude hooks, imports its schema into `~/.claude/CLAUDE.md` so it loads in every repo, sets up push auth. Codespaces-only, always exits 0 |
| `run_after_source_zsh.sh` | Installs tmux plugins via tpm. Codespaces-only |
| `run_after_preinstall_nvim_plugins.sh` | Headless `Lazy! sync` + `TSUpdate` for nvim-nelson |
| `run_once_after_fzf_install.sh` | Clones and installs fzf (needed by zoxide). Linux-only |

Anything a `run_after_` script does must be idempotent and must not fail the
apply — `setup.sh` runs `chezmoi init --apply` under `set -e`.

Note chezmoi extracts these scripts to a temp file before executing, so
`${BASH_SOURCE[0]}` does **not** point into this repo. `run_after_wiki_setup.sh`
resolves itself via the `~/.dotfiles` symlink that `setup.sh` creates, and falls
back to `BASH_SOURCE` for a standalone run from a checkout.

## Editors and shells

`~/.zshrc` prefers nvim and falls back to vim, and exports
`NVIM_APPNAME=nvim-nelson`. That export is load-bearing: there is no
`~/.config/nvim`, so without it a bare `nvim` — and therefore `$EDITOR` and
anything shelling out to it — would start unconfigured. `nvim-rover` (via `vr`) is
a WIP minimal config for Rover work.

`setup.sh` runs `chsh` with `/usr/bin/zsh` and the Codespaces branch of the zshrc
exports the same path. Keep those two in step.

## Known warts

- **`chezmoi diff` with no arguments hangs.** It pipes to a pager, which blocks
  with no TTY. Use `chezmoi diff --no-pager`, and `chezmoi apply --no-tty
  --dry-run` to check an apply non-interactively.
- **`.chezmoitemplates/zshrc` goes through Go templating.** A literal `{{` in it
  breaks the render with `missing value for if`. It fails loudly rather than
  corrupting the file, and escapes as `{{ "{{" }}` when genuinely needed. There is
  none today.
- **Mode noise.** `chezmoi diff` reports 0644→0664 / 0755→0775 churn on many
  targets in Codespaces, from a umask difference. Cosmetic, unresolved.
- **`~/.bashrc` is unmanaged** but refresh-secrets appends its block there too, so
  it drifts freely. Fine today, since nothing here reads it.
- **The merge scripts need `python3`.** Without it they fall back to writing the
  desired content alone — i.e. the old clobbering behaviour.

## Possible improvements

Roughly in order of value:

1. **Inline the `modify_` content as heredocs** and drop `.chezmoitemplates`. Two
   files instead of four, no Go templating in the path, and the `{{` hazard
   disappears. Costs editor support: the zshrc becomes a string inside a shell
   script, so no zsh highlighting and no `zsh -n` on the source, and a line
   matching the heredoc delimiter would truncate it. Deliberately not done — see
   the trade-off before changing it.
2. **Trim the oh-my-zsh boilerplate.** ~120 lines of commented-out stock config in
   `.chezmoitemplates/zshrc`.
3. **Resolve the umask mode churn**, so `chezmoi diff` is quiet enough to be
   useful as a review tool.
4. **Decide `nvim-rover`'s fate.** Long-running WIP; either finish it or fold what
   is useful into `nvim-nelson`.
5. **Manage `~/.bashrc`**, or confirm nothing needs it and stop wondering.
6. **Make `setup.sh` re-runnable end to end.** The download and clone paths are
   already guarded; `chsh` and `sudo install` are not.

## House style

- Comments explain *why*, not what. Do not narrate a change or restate a prompt —
  write as if the code had always been that way.
- Verify a claim before writing it down. Much of this file exists because a
  plausible-sounding explanation (a script ordering bug) was wrong, and the real
  cause was chezmoi's external-modification check.
- Keep this file current when you change the mechanics it describes.
