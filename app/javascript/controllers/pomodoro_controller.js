import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "dialog", "label", "note", "csrf", "minutes", "wakeToggle", "primaryButton"]
  static values = { titleBase: String, defaultLabel: String, defaultNote: String, finishTitle: String, startLabel: String, pauseLabel: String, resumeLabel: String }

  connect() {
    const saved = parseInt(localStorage.getItem("pomodoro_work_minutes"), 10)
    const base = (!isNaN(saved) && saved > 0) ? saved : parseInt(this.minutesTarget?.value || "25", 10)
    const minutes = (!isNaN(base) && base > 0) ? base : 25
    this.workSeconds = minutes * 60
    this.remaining = this.workSeconds
    this.timer = null
    this.startedAt = null
    this.wakeLock = null
    this.render()
  }

  render() {
    const m = Math.floor(this.remaining / 60)
    const s = this.remaining % 60
    this.displayTarget.textContent = `${String(m).padStart(2, "0")}:${String(s).padStart(2, "0")}`
    const base = this.titleBaseValue || "Pomodoro"
    document.title = `${this.displayTarget.textContent} · ${base}`

    if (this.hasPrimaryButtonTarget) {
      const label = this.primaryLabelForState()
      this.primaryButtonTarget.textContent = label
      this.primaryButtonTarget.classList.toggle("bg-emerald-600", label === (this.startLabelValue || "Start") || label === (this.resumeLabelValue || "Resume"))
      this.primaryButtonTarget.classList.toggle("bg-amber-500", label === (this.pauseLabelValue || "Pause"))
      this.primaryButtonTarget.classList.toggle("text-white", true)
    }
  }

  start() {
    if (this.timer) return
    this.startedAt = new Date()
    this.timer = setInterval(() => {
      this.remaining -= 1
      this.render()
      if (this.remaining <= 0) this.finish()
    }, 1000)
    this.requestWakeLockIfEnabled()
    this.requestNotificationPermission()
    this.render()
  }

  pause() {
    if (!this.timer) return
    clearInterval(this.timer)
    this.timer = null
    this.releaseWakeLock()
    this.render()
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
    this.releaseWakeLock()
  }

  primary() {
    if (this.timer) {
      this.pause()
      return
    }
    if (this.remaining <= 0) {
      this.reset()
      this.start()
      return
    }
    if (this.startedAt) {
      this.resume()
      return
    }
    this.start()
  }

  primaryLabelForState() {
    if (this.timer) return this.pauseLabelValue || "Pause"
    if (this.remaining <= 0) return this.startLabelValue || "Start"
    if (this.startedAt) return this.resumeLabelValue || "Resume"
    return this.startLabelValue || "Start"
  }

  setMinutes() {
    const val = parseInt(this.minutesTarget.value, 10)
    const clamped = isNaN(val) ? 25 : Math.min(180, Math.max(1, val))
    this.minutesTarget.value = clamped
    this.workSeconds = clamped * 60
    localStorage.setItem("pomodoro_work_minutes", String(clamped))
    this.reset()
  }

  finish() {
    clearInterval(this.timer)
    this.timer = null
    this.remaining = 0
    this.render()
    const savedLabel = localStorage.getItem("pomodoro_default_label")
    const savedNote = localStorage.getItem("pomodoro_default_note")
    this.labelTarget.value = savedLabel || this.defaultLabelValue || "Pomodoro"
    this.noteTarget.value = savedNote || this.defaultNoteValue || ""
    this.notifyFinish()
    this.dialogTarget.showModal()
  }

  openRecord() {
    const savedLabel = localStorage.getItem("pomodoro_default_label")
    const savedNote = localStorage.getItem("pomodoro_default_note")
    this.labelTarget.value = savedLabel || this.defaultLabelValue || "Pomodoro"
    this.noteTarget.value = savedNote || this.defaultNoteValue || ""
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
      try {
        localStorage.setItem("pomodoro_default_label", this.labelTarget.value || "")
        localStorage.setItem("pomodoro_default_note", this.noteTarget.value || "")
      } catch (e) {}
      this.dialogTarget.close()
      this.reset()
      Turbo.visit(window.location.href)
    }
  }

  async requestWakeLockIfEnabled() {
    try {
      if (this.wakeToggleTarget?.checked && "wakeLock" in navigator) {
        this.wakeLock = await navigator.wakeLock.request("screen")
      }
    } catch (e) {}
  }

  async toggleWakeLock() {
    if (this.wakeToggleTarget?.checked) {
      await this.requestWakeLockIfEnabled()
    } else {
      this.releaseWakeLock()
    }
  }

  releaseWakeLock() {
    try {
      this.wakeLock?.release?.()
      this.wakeLock = null
    } catch (e) {}
  }

  requestNotificationPermission() {
    try {
      if ("Notification" in window && Notification.permission === "default") {
        Notification.requestPermission()
      }
    } catch (e) {}
  }

  notifyFinish() {
    try {
      if ("Notification" in window && Notification.permission === "granted") {
        const title = this.finishTitleValue || (document.querySelector("[data-pomodoro-finish-title-value]")?.dataset?.pomodoroFinishTitleValue) || "Pomodoro finished"
        new Notification(this.titleBaseValue || "Pomodoro", { body: title })
      }
    } catch (e) {}
    try {
      if (navigator.vibrate) navigator.vibrate([300, 150, 300])
    } catch (e) {}
    try {
      const Ctx = window.AudioContext || window.webkitAudioContext
      if (!Ctx) return
      const ctx = new Ctx()
      const osc = ctx.createOscillator()
      const gain = ctx.createGain()
      osc.type = "sine"
      osc.frequency.setValueAtTime(880, ctx.currentTime)
      gain.gain.setValueAtTime(0.001, ctx.currentTime)
      gain.gain.exponentialRampToValueAtTime(0.3, ctx.currentTime + 0.05)
      osc.connect(gain)
      gain.connect(ctx.destination)
      osc.start()
      setTimeout(() => { gain.gain.exponentialRampToValueAtTime(0.0001, ctx.currentTime + 0.1); osc.stop(ctx.currentTime + 0.12) }, 200)
    } catch (e) {}
  }
}
