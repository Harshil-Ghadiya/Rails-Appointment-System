import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.reorder()
  }

  reorder() {
    const rows = Array.from(this.element.querySelectorAll('tr.appointment-row'))
    if (rows.length <= 1) return

    rows.sort((a, b) => {
      let valA = parseInt(a.dataset.tokenValue) || 0
      let valB = parseInt(b.dataset.tokenValue) || 0
      return valA - valB
    })

    rows.forEach(row => this.element.appendChild(row))
  }
}