export function convertDMS(lat, lng) {
  const latitude = toDMS(Math.abs(lat))
  const latCard = lat >= 0 ? "N" : "S"
  const longitude = toDMS(Math.abs(lng))
  const lngCard = lng >= 0 ? "E" : "W"
  return `${latitude} ${latCard} - ${longitude} ${lngCard}`
}

function toDMS(coordinate) {
  const degrees = Math.floor(coordinate)
  const minutesNotTruncated = (coordinate - degrees) * 60
  const minutes = Math.floor(minutesNotTruncated)
  const seconds = Math.floor((minutesNotTruncated - minutes) * 60)
  return `${degrees}\u00B0 ${minutes}' ${seconds}"`
}
