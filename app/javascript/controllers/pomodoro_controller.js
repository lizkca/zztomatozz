import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "dialog", "label", "note", "csrf"]

  connect() {
    this.workSeconds = 25 * 60
    this.remaining = this.workSeconds
    this.timer = null
    this.startedAt = null
    this.render()
  }

  render() {
    const m = Math.floor(this.remaining / 60)
    const s = this.remaining % 60
    this.displayTarget.textContent = `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`
    document.title = `${this.displayTarget.textContent} · 番茄`
  }

  start() {
    if (this.timer) return
    this.startedAt = new Date()
    this.timer = setInterval(() => {
      this.remaining -= 1
      this.render()
      if (this.remaining <= 0) this.finish()
    }, 1000)
  }

  pause() {
    if (!this.timer) return
    clearInterval(this.timer)
    this.timer = null
  }

  resume() {
    if (this.timer) return
    this.start()
  }

  reset() {
    if (this.timer) clearInterval(this.timer)
    this.timer = null
    this.remaining = this.workSeconds
    this.startedAt = null
    this.render()
  }

  finish() {
    clearInterval(this.timer)
    this.timer = null
    this.remaining = 0
    this.render()
    this.dialogTarget.showModal()
  }

  async save(event) {
    event.preventDefault()
    const endedAt = new Date()
    const startedAt = this.startedAt || endedAt
    const duration = Math.max(0, Math.round((endedAt - startedAt) / 1000))
    const payload = {
      pomodoro_session: {
        started_at: startedAt.toISOString(),
        ended_at: endedAt.toISOString(),
        duration_seconds: duration,
        label: this.labelTarget.value,
        note: this.noteTarget.value,
        date: startedAt.toISOString().slice(0, 10)
      }
    }
    const res = await fetch("/pomodoro_sessions", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.csrfTarget.value
      },
      body: JSON.stringify(payload)
    })
    if (res.ok) {
      this.dialogTarget.close()
      this.reset()
      Turbo.visit(window.location.href)
    }
  }
}