// Wake runs the machine's own connect command (`roverspace ssh <ws> --start`
// resumes a stopped workspace), then `hc machine update` so Herdr connects now
// instead of waiting out its retry. One shell runs both, so closing the popup doesn't stop it.

import { View, div } from "gpui-kit";
import { v_flex, h_flex } from "gpui-base";
import { exec, hc, theme, props, closeOverlay, notify, checking } from "herdr";

const q = (s) => `'${String(s).replace(/'/g, `'\\''`)}'`;

function wakeScript(m) {
  const reach = m.via ? `${m.target} true` : `ssh -o BatchMode=yes ${q(m.target)} true`;
  return `${reach} && hc machine update ${q(m.name)}`;
}

export default class Machines extends View {
  init(_props, cx) {
    this.machines = [];
    this.waking = {};
    this.errors = {};
    this.loaded = false;
    this.refresh(cx);
    cx.timer.every(4000, (cx) => this.refresh(cx));
  }

  refresh(cx) {
    cx.spawn(async (cx) => {
      try {
        const r = await hc(["machine", "ls", "--json"]);
        if (r.code === 0) this.machines = (JSON.parse(r.stdout).machines ?? []).filter((m) => !m.temporary);
      } catch {}
      this.loaded = true;
      cx.notify();
    });
  }

  wake(m, cx) {
    if (this.waking[m.name] || checking()) return;
    this.waking[m.name] = true;
    delete this.errors[m.name];
    cx.notify();
    cx.spawn(async (cx) => {
      try {
        const r = await exec("sh", ["-c", wakeScript(m)], { timeout: 600000 });
        if (r.code === 0) {
          notify({ title: `${m.name} is awake`, level: "success" });
        } else {
          const why = (r.stderr || r.stdout).trim().split("\n").filter(Boolean).pop() ?? `exit ${r.code}`;
          this.errors[m.name] = why;
          notify({ title: `Couldn't wake ${m.name}`, body: why, level: "error" });
        }
      } catch (e) {
        this.errors[m.name] = String(e);
      }
      delete this.waking[m.name];
      this.refresh(cx);
    });
  }

  render(cx) {
    const t = theme();
    const down = this.machines.filter((m) => m.state !== "connected");
    const color = { connected: t.ansi2, connecting: t.working, unreachable: t.blocked };

    const button = (id, label, onClick, busy) =>
      div().id(id).px(10).py(3).rounded(6).text_size(12)
        .when(busy, (el) => el.text_color(t.muted).border_1().border_color(t.border).child(div().frames(["Waking ⠋", "Waking ⠙", "Waking ⠹", "Waking ⠸", "Waking ⠼", "Waking ⠴", "Waking ⠦", "Waking ⠧", "Waking ⠇", "Waking ⠏"], 90)))
        .when(!busy, (el) => el.bg(t.solid).text_color(t.solid_foreground).cursor_pointer().hover((s) => s.bg(t.accent)).on_click((_e, cx) => onClick(cx)).child(label));

    const row = (m) => {
      const busy = !!this.waking[m.name];
      const detail = this.errors[m.name] ?? (m.state === "connected" ? m.host : m.why) ?? "";
      return h_flex().id(`m-${m.name}`).gap(10).px(12).py(8).rounded(8).items_center().hover((s) => s.bg(t.hover))
        .child(div().w(8).h(8).rounded(4).bg(color[m.state] ?? t.unknown))
        .child(v_flex().flex_1().min_w(0).gap(2)
          .child(h_flex().gap(8).child(div().text_size(13).text_color(t.foreground).child(m.name)).child(div().text_size(11).text_color(t.muted).child(busy ? "waking" : m.state)))
          .child(div().text_size(11).text_color(this.errors[m.name] ? t.blocked : t.dim).truncate().child(detail)))
        .when(m.state !== "connected", (el) => el.child(button(`wake-${m.name}`, "Wake", (cx) => this.wake(m, cx), busy)));
    };

    return v_flex().size_full().bg(t.popover).p(8).gap(4)
      .child(h_flex().px(12).py(6).items_center().justify_between()
        .child(div().text_size(13).font_semibold().text_color(t.foreground).child("Machines"))
        .child(h_flex().gap(8).items_center()
          .when(down.length > 1, (el) => el.child(button("wake-all", "Wake all", (cx) => down.forEach((m) => this.wake(m, cx)), false)))
          .child(div().id("close").px(6).py(2).rounded(5).text_size(11).text_color(t.dim).cursor_pointer().hover((s) => s.bg(t.hover).text_color(t.foreground)).on_click(() => closeOverlay(props().overlay)).child("Esc"))))
      .child(v_flex().flex_1().overflow_y_scrollbar().gap(2)
        .when(this.loaded && this.machines.length === 0, (el) => el.child(div().px(12).text_size(12).text_color(t.dim).child("No machines. Add one with hc machine add.")))
        .children(this.machines.map(row)));
  }
}
