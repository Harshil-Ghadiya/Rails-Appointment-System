import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.refreshTimer = setInterval(() => {
      this.checkSessionSwitch()
    }, 60000)
  }

  disconnect() {
    clearInterval(this.refreshTimer)
  }

  checkSessionSwitch() {
    window.location.reload()
  }
}