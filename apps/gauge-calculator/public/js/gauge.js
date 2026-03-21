function showError(message) {
  const banner = document.getElementById("errorBanner")
  banner.innerText = message
  banner.classList.remove("hidden")
}

function clearError() {
  const banner = document.getElementById("errorBanner")
  banner.classList.add("hidden")
}

async function apiPost(url, body) {
  clearError()
  const res = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body)
  })
  const data = await res.json()
  if (!res.ok) {
    showError(data.error || "Something went wrong")
    return null
  }
  return data
}

function getUnit() {
  return document.getElementById("unit").value
}

function updateUnitLabels() {
  const unit = getUnit()
  const singular = unit === "inches" ? "inch" : "centimeter"

  document.querySelectorAll(".unitLabel").forEach(el => el.innerText = unit)
  document.querySelectorAll(".unitLabelSingular").forEach(el => el.innerText = singular)
}

function getSwatchParams() {
  const params = {
    stitches: document.getElementById("stitches").value,
    rows: document.getElementById("rows").value,
    width: document.getElementById("width").value,
    unit: getUnit()
  }
  const height = document.getElementById("height").value
  if (height) params.height = height
  return params
}

async function calculateGauge() {
  const data = await apiPost("/api/gauge", getSwatchParams())
  if (!data) return

  document.getElementById("spi").innerText = data.spi
  document.getElementById("rpi").innerText = data.rpi
}

async function calculateStitches() {
  const repeat = document.getElementById("repeat").value
  const offset = document.getElementById("offset").value

  const payload = {
    ...getSwatchParams(),
    target_width: document.getElementById("targetWidth").value
  }
  if (repeat) {
    payload.repeat = parseInt(repeat)
    payload.offset = parseInt(offset || 0)
  }

  const data = await apiPost("/api/gauge/stitches", payload)
  if (!data) return

  document.getElementById("stitchResult").innerText =
    data.base_stitches
      ? `${data.base_stitches} -> ${data.stitches} (adjusted)`
      : `${data.stitches}`
}

async function calculateRows() {
  const payload = {
    ...getSwatchParams(),
    target_height: document.getElementById("targetHeight").value
  }

  const data = await apiPost("/api/gauge/rows", payload)
  if (!data) return

  document.getElementById("rowResult").innerText = data.rows
}
