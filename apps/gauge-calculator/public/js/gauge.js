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

async function calculateGauge() {
  const stitches = document.getElementById("stitches").value
  const rows = document.getElementById("rows").value
  const width = document.getElementById("width").value
  const unit = getUnit()

  const data = await apiPost("/api/gauge", { stitches, rows, width, unit })
  if (!data) return

  document.getElementById("spi").innerText = data.spi
  document.getElementById("rpi").innerText = data.rpi
}

async function calculateStitches() {
  const stitches = document.getElementById("stitches").value
  const rows = document.getElementById("rows").value
  const width = document.getElementById("width").value
  const targetWidth = document.getElementById("targetWidth").value
  const unit = getUnit()

  const repeat = document.getElementById("repeat").value
  const offset = document.getElementById("offset").value

  const payload = { stitches, rows, width, target_width: targetWidth, unit }
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
  const stitches = document.getElementById("stitches").value
  const rows = document.getElementById("rows").value
  const width = document.getElementById("width").value
  const targetHeight = document.getElementById("targetHeight").value
  const unit = getUnit()

  const data = await apiPost("/api/gauge/rows", {
    stitches, rows, width, target_height: targetHeight, unit
  })
  if (!data) return

  document.getElementById("rowResult").innerText = data.rows
}
