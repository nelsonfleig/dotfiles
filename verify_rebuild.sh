#!/usr/bin/env bash
# Post-rebuild verification. Run this from a Claude Code Bash tool (not a login
# shell) after "Codespaces: Rebuild Container":
#
#   bash ~/.dotfiles/verify_rebuild.sh
#
# Read-only: it checks state, it does not fix anything. Exits nonzero if any
# check fails. Chezmoiignored, so it is never applied into $HOME.

pass=0; fail=0
ok()   { printf '  \033[32mPASS\033[0m  %s\n' "$1"; pass=$((pass+1)); }
no()   { printf '  \033[31mFAIL\033[0m  %s\n' "$1"; fail=$((fail+1)); }
chk()  { if eval "$2" >/dev/null 2>&1; then ok "$1"; else no "$1"; fi; }
head_() { printf '\n\033[1m%s\033[0m\n' "$1"; }

WIKI=/workspaces/wiki
SET=~/.claude/settings.json

head_ "1. The regression this rebuild was for"
chk "chezmoi apply completes non-interactively (no external-modification prompt)" \
    "chezmoi apply --no-tty --dry-run"

head_ "2. Shell"
chk "login shell is /usr/bin/zsh" "getent passwd \"\$(id -un)\" | grep -q ':/usr/bin/zsh$'"
chk "~/.zshrc exists and is the managed one" "grep -q 'NVIM_APPNAME' ~/.zshrc"
if grep -q 'MANAGED BY refresh-secrets' ~/.zshrc 2>/dev/null; then
  ok "refresh-secrets block survived the apply (merge working)"
else
  printf '  \033[33mSKIP\033[0m  refresh-secrets block absent — expected until you run scripts/refresh-secrets.sh\n'
fi
chk "interactive zsh sets EDITOR=nvim" "zsh -ilc 'test \"\$EDITOR\" = nvim'"
chk "interactive zsh sets NVIM_APPNAME=nvim-nelson" "zsh -ilc 'test \"\$NVIM_APPNAME\" = nvim-nelson'"

head_ "3. Claude settings merge"
chk "settings.json is valid JSON" "python3 -m json.tool \"\$SET\""
chk "statusLine registered" "jq -e '.statusLine.command' \"\$SET\""
chk "permissions survived (11 allow entries)" "test \"\$(jq '.permissions.allow|length' \"\$SET\")\" -ge 11"
chk "exactly one SessionStart hook" "test \"\$(jq '.hooks.SessionStart|length' \"\$SET\")\" -eq 1"
chk "exactly one Stop hook" "test \"\$(jq '.hooks.Stop|length' \"\$SET\")\" -eq 1"
chk "status line actually renders" \
    "echo '{\"workspace\":{\"current_dir\":\"/workspaces/web\"}}' | sh ~/.claude/statusline.sh | grep -q ."

head_ "4. Wiki"
chk "wiki cloned" "test -d \$WIKI/.git"
chk "remote is nelsonfleig/llm-wiki" "git -C \$WIKI remote -v | grep -q 'nelsonfleig/llm-wiki'"
chk "skill symlink resolves to a real SKILL.md" "test -f ~/.claude/skills/llm-wiki/SKILL.md"
chk "schema imported in ~/.claude/CLAUDE.md exactly once" \
    "test \"\$(grep -c '@/workspaces/wiki/WIKI.md' ~/.claude/CLAUDE.md)\" -eq 1"
chk "old web-only import location NOT recreated" \
    "! grep -q '@/workspaces/wiki/WIKI.md' /workspaces/web/CLAUDE.local.md 2>/dev/null"

head_ "5. Tokens (presence only, never printed)"
for v in WIKI_REPO_TOKEN DOTFILES_REPO_TOKEN; do
  if [ -n "${!v:-}" ]; then ok "$v is set in this (non-login) environment"
  else no "$v is UNSET here — hooks cannot push, even if a login shell has it"; fi
done

head_ "6. Credential helpers are idempotent (2 local values each, not accumulating)"
# --local is load-bearing: a bare --get-all merges in ~/.gitconfig's own
# credential.https://github.com.helper, so it never reads as 2.
for r in "$WIKI" "$HOME/.dotfiles"; do
  n=$(git -C "$r" config --local --get-all credential.https://github.com.helper 2>/dev/null | wc -l)
  if [ "$n" -eq 2 ]; then ok "$r has 2 local helper values"; else no "$r has $n local helper values (expected 2)"; fi
done

head_ "7. Nothing stray landed in \$HOME"
for f in lazygit lazygit.tar.gz AGENTS.md; do
  if [ -e "$HOME/$f" ]; then no "~/$f leaked in"; else ok "~/$f absent"; fi
done
for d in nvim nvim-lazy nvim-devaslife nvim-vhyrro kitty; do
  if [ -e "$HOME/.config/$d" ]; then no "~/.config/$d should have been removed"; else ok "~/.config/$d absent"; fi
done

printf '\n\033[1m%d passed, %d failed\033[0m\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
