// tmux-style prefix: the leader key opens this popup, the next key runs a
// command and closes it. Esc or an unmapped key cancels.
// @ts-check

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { run, props, closeOverlay, theme } from "herdr";

const BINDINGS = [
  { key: "|", label: "split right", run: () => run("pane.split", { direction: "right" }) },
  { key: "-", label: "split down", run: () => run("pane.split", { direction: "down" }) },
  { key: "z", label: "zoom", run: () => run("pane.zoom") },
  { key: "x", label: "close pane", run: () => run("pane.close") },
  { key: "c", label: "new tab", run: () => run("tab.new") },
  { key: "C", label: "new named tab", run: () => { run("tab.new"); run("tab.rename"); } },
  { key: "r", label: "rename tab", run: () => run("tab.rename") },
  { key: "m", label: "move tab to…", mode: "move" },
  { key: "n", label: "next tab", run: () => run("tab.next") },
  { key: "p", label: "prev tab", run: () => run("tab.prev") },
  { key: "1-9", label: "select tab" },
  { key: "[", label: "select from cursor", run: () => run("terminal.select") },
];

export default class Leader extends View {
  init(_props, cx) {
    this.mode = null;
    this.handle = cx.focus_handle();
    this.handle.focus();
    cx.timer.after(50, () => this.handle.focus());
  }

  close() {
    closeOverlay(props().overlay);
  }

  key(e, cx) {
    cx.stop_propagation();
    if (e.key === "escape") return this.close();
    const ch = e.key_char ?? e.key;
    const digit = /^[1-9]$/.test(ch) ? Number(ch) : null;

    if (this.mode === "move") {
      this.close();
      if (digit) run("tab.move", { index: digit });
      return;
    }
    if (digit) {
      this.close();
      run("tab.select", { index: digit });
      return;
    }
    const b = BINDINGS.find((b) => b.key === ch);
    if (b?.mode) {
      this.mode = b.mode;
      cx.notify();
      return;
    }
    this.close();
    b?.run?.();
  }

  render() {
    const t = theme();
    const chip = (b) =>
      h_flex().gap(6).items_center().w(160)
        .child(div().min_w(28).px(5).rounded(4).bg(t.raised).text_color(t.accent).font_semibold().child(b.key))
        .child(div().text_color(t.muted).child(b.label));
    const title = this.mode === "move" ? "Move tab to position 1–9" : "Leader";
    return v_flex()
      .id("leader")
      .track_focus(this.handle)
      .on_key_down((e, cx) => this.key(e, cx))
      .size_full().p(12).gap(8).bg(t.popover).text_size(12).text_color(t.foreground)
      .child(h_flex().items_center()
        .child(div().flex_1().font_semibold().child(title))
        .child(div().text_size(11).text_color(t.dim).child("Esc")))
      .when(this.mode === null, (el) =>
        el.child(h_flex().flex_wrap().gap_y(4).children(BINDINGS.map(chip))));
  }
}
