// Load stitch patterns on page load
document.addEventListener("DOMContentLoaded", function () {
  loadStitchPatterns();
});

function loadStitchPatterns() {
  fetch("/api/stitch_patterns")
    .then(function (res) { return res.json(); })
    .then(function (patterns) {
      var select = document.getElementById("stitchPattern");
      patterns.forEach(function (p) {
        var opt = document.createElement("option");
        opt.value = p.key;
        opt.textContent = p.name + " (width: " + p.width_factor + "x, yarn: " + p.yarn_factor + "x)";
        select.appendChild(opt);
      });
    })
    .catch(function () {
      // Stitch patterns are optional, fail silently
    });
}

function updateUnitLabels() {
  var unit = document.getElementById("unit").value;
  var labels = document.querySelectorAll(".unitLabel");
  labels.forEach(function (el) {
    el.textContent = unit;
  });
}

function showError(msg) {
  var banner = document.getElementById("errorBanner");
  banner.textContent = msg;
  banner.classList.remove("hidden");
}

function hideError() {
  document.getElementById("errorBanner").classList.add("hidden");
}

function calculatePiece() {
  hideError();

  var unit = document.getElementById("unit").value;
  var gaugeStitches = parseFloat(document.getElementById("gaugeStitches").value);
  var gaugeRows = parseFloat(document.getElementById("gaugeRows").value);
  var gaugeWidth = parseFloat(document.getElementById("gaugeWidth").value);
  var pieceWidth = parseFloat(document.getElementById("pieceWidth").value);
  var pieceHeight = parseFloat(document.getElementById("pieceHeight").value);
  var stitchPattern = document.getElementById("stitchPattern").value;
  var repeatMultiple = parseInt(document.getElementById("repeatMultiple").value, 10);
  var repeatOffset = parseInt(document.getElementById("repeatOffset").value, 10) || 0;

  if (!gaugeStitches || !gaugeRows || !gaugeWidth || !pieceWidth || !pieceHeight) {
    showError("Please fill in all gauge and piece dimension fields.");
    return;
  }

  var body = {
    gauge: {
      stitches: gaugeStitches,
      rows: gaugeRows,
      width: gaugeWidth,
      unit: unit
    },
    piece: {
      width: pieceWidth,
      height: pieceHeight
    }
  };

  if (stitchPattern) {
    body.stitch_pattern = stitchPattern;
  }

  if (repeatMultiple > 0) {
    body.repeat = { multiple: repeatMultiple, offset: repeatOffset };
  }

  fetch("/api/piece", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body)
  })
    .then(function (res) {
      if (!res.ok) {
        return res.json().then(function (data) {
          throw new Error(data.error || "Something went wrong");
        });
      }
      return res.json();
    })
    .then(function (data) {
      document.getElementById("castOnResult").textContent = data.cast_on;
      document.getElementById("totalRowsResult").textContent = data.total_rows;
      document.getElementById("finishedWidthResult").textContent = data.finished_width;
      document.getElementById("finishedHeightResult").textContent = data.finished_height;
      document.getElementById("resultsPanel").classList.remove("hidden");
      drawSchematic(data.finished_width, data.finished_height, data.cast_on, data.total_rows, unit);
    })
    .catch(function (err) {
      showError(err.message);
    });
}

function drawSchematic(width, height, castOn, totalRows, unit) {
  var container = document.getElementById("schematic");
  var maxSvgWidth = 280;
  var maxSvgHeight = 200;
  var padding = 50;

  var availW = maxSvgWidth - padding * 2;
  var availH = maxSvgHeight - padding * 2;
  var scale = Math.min(availW / width, availH / height);
  var rectW = width * scale;
  var rectH = height * scale;
  var rectX = (maxSvgWidth - rectW) / 2;
  var rectY = (maxSvgHeight - rectH) / 2;

  var unitAbbr = (unit === "centimeters") ? "cm" : "in";

  var svg = '<svg width="' + maxSvgWidth + '" height="' + maxSvgHeight + '" xmlns="http://www.w3.org/2000/svg">';

  // Rectangle
  svg += '<rect x="' + rectX + '" y="' + rectY + '" width="' + rectW + '" height="' + rectH + '" ';
  svg += 'fill="#fce7f3" stroke="#ec4899" stroke-width="2" rx="4"/>';

  // Width label (bottom)
  var widthLabelX = rectX + rectW / 2;
  var widthLabelY = rectY + rectH + 16;
  svg += '<text x="' + widthLabelX + '" y="' + widthLabelY + '" text-anchor="middle" ';
  svg += 'font-size="11" fill="#be185d" font-weight="600">' + width + ' ' + unitAbbr + '</text>';
  svg += '<text x="' + widthLabelX + '" y="' + (widthLabelY + 13) + '" text-anchor="middle" ';
  svg += 'font-size="10" fill="#9ca3af">' + castOn + ' sts</text>';

  // Height label (right)
  var heightLabelX = rectX + rectW + 10;
  var heightLabelY = rectY + rectH / 2;
  svg += '<text x="' + heightLabelX + '" y="' + (heightLabelY - 6) + '" text-anchor="start" ';
  svg += 'font-size="11" fill="#1d4ed8" font-weight="600">' + height + ' ' + unitAbbr + '</text>';
  svg += '<text x="' + heightLabelX + '" y="' + (heightLabelY + 8) + '" text-anchor="start" ';
  svg += 'font-size="10" fill="#9ca3af">' + totalRows + ' rows</text>';

  svg += '</svg>';
  container.innerHTML = svg;
}
