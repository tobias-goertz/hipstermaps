import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "title", "subtitle", "coords", "titleInput", "subtitleInput", "coordsInput", "fieldsContainer"]

  titleChanged() {
    if (this.hasTitleTarget) {
      this.titleTarget.textContent = this.titleInputTarget.value
    }
  }

  subtitleChanged() {
    if (this.hasSubtitleTarget) {
      this.subtitleTarget.textContent = this.subtitleInputTarget.value
    }
  }

  coordsChanged() {
    if (this.hasCoordsTarget) {
      this.coordsTarget.textContent = this.coordsInputTarget.value
    }
  }

  formatChanged(event) {
    if (this.hasContainerTarget) {
      this.containerTarget.dataset.format = event.target.value
    }
  }

  updateCoords(dms) {
    if (this.hasCoordsInputTarget) {
      this.coordsInputTarget.value = dms
    }
    if (this.hasCoordsTarget) {
      this.coordsTarget.textContent = dms
    }
  }

  revealFields() {
    if (this.hasFieldsContainerTarget) {
      this.fieldsContainerTarget.classList.remove("hidden")
    }
  }

  setLocation(city, country, dms) {
    this.revealFields()

    if (this.hasTitleInputTarget) {
      this.titleInputTarget.value = city
      this.titleChanged()
    }
    if (this.hasSubtitleInputTarget) {
      this.subtitleInputTarget.value = country
      this.subtitleChanged()
    }
    this.updateCoords(dms)
  }
}
