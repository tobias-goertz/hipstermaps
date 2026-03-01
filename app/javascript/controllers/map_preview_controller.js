import { Controller } from "@hotwired/stimulus"
import { convertDMS } from "helpers/dms"

export default class extends Controller {
  static targets = ["container", "lonInput", "latInput", "zoomInput"]

  connect() {
    const token = document.querySelector('meta[name="mapbox-token"]')?.content
    if (!token || !this.hasContainerTarget) return

    mapboxgl.accessToken = token

    this.map = new mapboxgl.Map({
      container: this.containerTarget,
      style: `mapbox://styles/${this.#currentStyle()}`,
      center: [0, 0],
      zoom: 0.1
    })

    this.map.scrollZoom.disable()
    this.map.addControl(new mapboxgl.NavigationControl(), "top-left")

    this.map.on("moveend", () => this.#updatePosition())
    this.map.on("zoomend", () => this.#updateZoom())
  }

  disconnect() {
    this.map?.remove()
  }

  styleChanged(event) {
    const style = event.target.value
    this.map?.setStyle(`mapbox://styles/${style}`)
  }

  formatChanged() {
    this.#updateZoom()
  }

  flyTo(center, zoom = 11) {
    this.map?.flyTo({ center, zoom })
  }

  #updatePosition() {
    if (!this.map) return
    const center = this.map.getCenter()
    if (this.hasLonInputTarget) this.lonInputTarget.value = center.lng
    if (this.hasLatInputTarget) this.latInputTarget.value = center.lat
    this.#updateZoom()

    const dms = convertDMS(center.lat, center.lng)
    const posterCtrl = this.application.getControllerForElementAndIdentifier(this.element, "poster-preview")
    if (posterCtrl) {
      posterCtrl.updateCoords(dms)
      posterCtrl.revealFields()
    }
  }

  #updateZoom() {
    if (!this.map || !this.hasZoomInputTarget) return
    const zoom = Math.round(this.map.getZoom())
    const format = document.querySelector("[name='map[format]']")?.value
    const offset = format === "3:4" ? 2 : 3
    this.zoomInputTarget.value = zoom + offset
  }

  #currentStyle() {
    return document.querySelector("[name='map[style]']")?.value || "shigawire/cjkqod0by7xsc2rpju6kvos0x"
  }
}
