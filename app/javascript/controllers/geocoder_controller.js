import { Controller } from "@hotwired/stimulus"
import { convertDMS } from "helpers/dms"

export default class extends Controller {
  static targets = ["searchContainer", "lonInput", "latInput"]

  connect() {
    const token = document.querySelector('meta[name="mapbox-token"]')?.content
    if (!token || !this.hasSearchContainerTarget) return

    this.geocoder = new MapboxGeocoder({
      accessToken: token,
      flyTo: false,
      marker: false,
      placeholder: "Search for a city..."
    })

    this.geocoder.addTo(this.searchContainerTarget)

    this.geocoder.on("result", (data) => this.#handleResult(data))
  }

  disconnect() {
    this.geocoder?.onRemove()
  }

  #handleResult(data) {
    const { center, place_name } = data.result
    const [lng, lat] = center

    // Update hidden fields
    if (this.hasLonInputTarget) this.lonInputTarget.value = lng
    if (this.hasLatInputTarget) this.latInputTarget.value = lat

    // Fly map to location
    const mapCtrl = this.application.getControllerForElementAndIdentifier(this.element, "map-preview")
    if (mapCtrl) mapCtrl.flyTo(center)

    // Parse location name
    const parts = place_name.toUpperCase().split(", ")
    const city = parts[0]
    const country = parts[parts.length - 1]
    const dms = convertDMS(lat, lng)

    // Update poster preview
    const posterCtrl = this.application.getControllerForElementAndIdentifier(this.element, "poster-preview")
    if (posterCtrl) posterCtrl.setLocation(city, country, dms)
  }
}
