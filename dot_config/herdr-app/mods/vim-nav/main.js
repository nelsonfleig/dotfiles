// vim-tmux-navigator for Herdr: ctrl-hjkl (keys.json "vim-nav.<dir>") moves
// between panes, unless vim is in front, which gets the key instead.
// Runs headless from a 0px block in the layout so it can receive commands.

import { View, div } from "gpui-kit";
import { run, nextCommand, focused, terminals, hc } from "herdr";

const KEYS = { left: "ctrl+h", down: "ctrl+j", up: "ctrl+k", right: "ctrl+l" };
const VIM = /^(n?vim?|vimdiff|nvim-.*)$/;

function isVim(t) {
  return VIM.test(t?.program?.key ?? "") || VIM.test(t?.foreground?.name ?? "");
}

export default class VimNav extends View {
  init(_props, cx) {
    cx.spawn(async () => {
      for (;;) {
        const dir = await nextCommand();
        if (!KEYS[dir]) continue;
        const address = focused()?.terminal;
        const term = address && terminals().find((t) => t.address === address);
        if (isVim(term)) await hc(["keys", address, KEYS[dir]]);
        else run("pane.go", { direction: dir });
      }
    });
  }

  render() {
    return div().id("vim-nav").size_0();
  }
}
