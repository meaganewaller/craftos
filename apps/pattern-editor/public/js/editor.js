var pieces = [];
var nextPieceId = 1;

document.addEventListener("DOMContentLoaded", function () {
  loadStitchPatterns();
  addPiece("Back", 20, 25);
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
    .catch(function () {});
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

// --- Piece management ---

function addPiece(name, width, height) {
  var id = nextPieceId++;
  var lastPiece = pieces[pieces.length - 1];
  var piece = {
    id: id,
    name: name || "Piece " + id,
    width: width || (lastPiece ? lastPiece.width : 20),
    height: height || (lastPiece ? lastPiece.height : 25),
    endWidth: "",
    collapsed: false
  };
  pieces.push(piece);
  renderPieces();
}

function removePiece(id) {
  if (pieces.length <= 1) return;
  pieces = pieces.filter(function (p) { return p.id !== id; });
  renderPieces();
}

function togglePiece(id) {
  var piece = pieces.find(function (p) { return p.id === id; });
  if (piece) {
    piece.collapsed = !piece.collapsed;
    renderPieces();
  }
}

function syncPieceField(id, field, value) {
  var piece = pieces.find(function (p) { return p.id === id; });
  if (piece) {
    if (field === "name") {
      piece[field] = value;
    } else {
      piece[field] = value;
    }
  }
}

function renderPieces() {
  var container = document.getElementById("piecesList");
  var unit = document.getElementById("unit").value;
  var html = "";

  pieces.forEach(function (piece, index) {
    var isOnly = pieces.length === 1;
    var chevron = piece.collapsed ? "&#9654;" : "&#9660;";

    html += '<div class="mb-3 border border-blue-200 rounded-xl overflow-hidden">';

    // Header
    html += '<div class="flex items-center justify-between bg-blue-50 px-4 py-2 cursor-pointer" onclick="togglePiece(' + piece.id + ')">';
    html += '<div class="flex items-center gap-2">';
    html += '<span class="text-xs text-blue-400">' + chevron + '</span>';
    html += '<input type="text" value="' + escapeAttr(piece.name) + '" ';
    html += 'class="piece-name bg-transparent border-none text-sm font-semibold text-blue-700 focus:outline-none focus:ring-1 focus:ring-blue-300 rounded px-1 w-32" ';
    html += 'onclick="event.stopPropagation()" ';
    html += 'oninput="syncPieceField(' + piece.id + ', \'name\', this.value)">';
    html += '</div>';
    if (!isOnly) {
      html += '<button onclick="event.stopPropagation(); removePiece(' + piece.id + ')" ';
      html += 'class="text-red-400 hover:text-red-600 text-xs font-medium px-2 py-1 rounded hover:bg-red-50 transition">';
      html += 'remove</button>';
    }
    html += '</div>';

    // Body
    if (!piece.collapsed) {
      html += '<div class="p-4 space-y-3">';

      // Width
      html += '<div>';
      html += '<label class="block text-sm font-semibold text-gray-700">desired width (<span class="unitLabel">' + unit + '</span>)</label>';
      html += '<input type="number" value="' + piece.width + '" ';
      html += 'oninput="syncPieceField(' + piece.id + ', \'width\', this.value)" ';
      html += 'class="w-full p-3 rounded-xl border border-blue-200 focus:outline-none focus:ring-2 focus:ring-blue-300">';
      html += '</div>';

      // Height
      html += '<div>';
      html += '<label class="block text-sm font-semibold text-gray-700">desired height (<span class="unitLabel">' + unit + '</span>)</label>';
      html += '<input type="number" value="' + piece.height + '" ';
      html += 'oninput="syncPieceField(' + piece.id + ', \'height\', this.value)" ';
      html += 'class="w-full p-3 rounded-xl border border-blue-200 focus:outline-none focus:ring-2 focus:ring-blue-300">';
      html += '</div>';

      // Shaping (end width)
      html += '<div>';
      html += '<label class="block text-sm font-semibold text-gray-700">end width (<span class="unitLabel">' + unit + '</span>)</label>';
      html += '<p class="text-xs text-gray-400 mb-1">optional — for shaping (taper or flare)</p>';
      html += '<input type="number" value="' + piece.endWidth + '" placeholder="same as width" ';
      html += 'oninput="syncPieceField(' + piece.id + ', \'endWidth\', this.value)" ';
      html += 'class="w-full p-3 rounded-xl border border-blue-200 focus:outline-none focus:ring-2 focus:ring-blue-300">';
      html += '</div>';

      html += '</div>';
    }

    html += '</div>';
  });

  container.innerHTML = html;
}

function escapeAttr(str) {
  return str.replace(/&/g, "&amp;").replace(/"/g, "&quot;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
}

// --- Presets ---

function addPreset(type) {
  pieces = [];
  nextPieceId = 1;

  if (type === "pullover") {
    addPiece("Front", 20, 25);
    addPiece("Back", 20, 25);
    addPiece("Left Sleeve", 18, 20);
    addPiece("Right Sleeve", 18, 20);
  } else if (type === "cardigan") {
    addPiece("Left Front", 12, 25);
    addPiece("Right Front", 12, 25);
    addPiece("Back", 20, 25);
    addPiece("Left Sleeve", 18, 20);
    addPiece("Right Sleeve", 18, 20);
  } else if (type === "vest") {
    addPiece("Front", 20, 25);
    addPiece("Back", 20, 25);
  }
}

// --- Calculate ---

function calculateAll() {
  hideError();

  var unit = document.getElementById("unit").value;
  var gaugeStitches = parseFloat(document.getElementById("gaugeStitches").value);
  var gaugeRows = parseFloat(document.getElementById("gaugeRows").value);
  var gaugeWidth = parseFloat(document.getElementById("gaugeWidth").value);
  var stitchPattern = document.getElementById("stitchPattern").value;
  var repeatMultiple = parseInt(document.getElementById("repeatMultiple").value, 10);
  var repeatOffset = parseInt(document.getElementById("repeatOffset").value, 10) || 0;

  if (!gaugeStitches || !gaugeRows || !gaugeWidth) {
    showError("Please fill in all gauge fields.");
    return;
  }

  var pieceDefs = [];
  for (var i = 0; i < pieces.length; i++) {
    var p = pieces[i];
    var w = parseFloat(p.width);
    var h = parseFloat(p.height);
    if (!w || !h) {
      showError("Please fill in width and height for \"" + p.name + "\".");
      return;
    }
    var def = { name: p.name, width: w, height: h };
    var ew = parseFloat(p.endWidth);
    if (ew > 0) {
      def.shaping = { end_width: ew };
    }
    pieceDefs.push(def);
  }

  var body = {
    gauge: { stitches: gaugeStitches, rows: gaugeRows, width: gaugeWidth, unit: unit },
    pieces: pieceDefs
  };

  if (stitchPattern) {
    body.stitch_pattern = stitchPattern;
  }
  if (repeatMultiple > 0) {
    body.repeat = { multiple: repeatMultiple, offset: repeatOffset };
  }

  fetch("/api/project", {
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
      renderResults(data.pieces, unit);
    })
    .catch(function (err) {
      showError(err.message);
    });
}

function renderResults(piecesData, unit) {
  var container = document.getElementById("resultsContainer");
  var unitAbbr = (unit === "centimeters") ? "cm" : "in";
  var html = "";

  piecesData.forEach(function (piece) {
    html += '<div class="mb-4 border border-gray-200 rounded-xl overflow-hidden">';
    html += '<div class="bg-gray-50 px-4 py-2">';
    html += '<p class="text-sm font-semibold text-gray-700">' + escapeHtml(piece.name) + '</p>';
    html += '</div>';
    html += '<div class="p-4 space-y-3">';

    // Stats grid
    html += '<div class="grid grid-cols-2 gap-3">';
    html += '<div class="bg-pink-50 rounded-xl p-4 text-center">';
    html += '<p class="text-xs text-gray-500">cast on</p>';
    html += '<p class="text-lg font-bold text-pink-600">' + piece.cast_on + '</p>';
    html += '<p class="text-xs text-gray-400">stitches</p>';
    html += '</div>';
    html += '<div class="bg-blue-50 rounded-xl p-4 text-center">';
    html += '<p class="text-xs text-gray-500">work</p>';
    html += '<p class="text-lg font-bold text-blue-600">' + piece.total_rows + '</p>';
    html += '<p class="text-xs text-gray-400">rows</p>';
    html += '</div>';
    html += '</div>';

    html += '<div class="grid grid-cols-2 gap-3">';
    html += '<div class="bg-pink-50 rounded-xl p-4 text-center">';
    html += '<p class="text-xs text-gray-500">finished width</p>';
    html += '<p class="text-lg font-bold text-pink-600">' + piece.finished_width + '</p>';
    html += '<p class="text-xs text-gray-400">' + unitAbbr + '</p>';
    html += '</div>';
    html += '<div class="bg-blue-50 rounded-xl p-4 text-center">';
    html += '<p class="text-xs text-gray-500">finished height</p>';
    html += '<p class="text-lg font-bold text-blue-600">' + piece.finished_height + '</p>';
    html += '<p class="text-xs text-gray-400">' + unitAbbr + '</p>';
    html += '</div>';
    html += '</div>';

    // Shaping info
    if (piece.shaping && piece.shaping.enabled) {
      html += '<div class="bg-purple-50 rounded-xl p-3 text-sm">';
      html += '<p class="font-semibold text-purple-700">shaping: ' + piece.shaping.method + '</p>';
      html += '<p class="text-xs text-purple-500">' + piece.shaping.total_changes + ' changes over ' + piece.total_rows + ' rows</p>';
      html += '</div>';
    }

    // Schematic
    html += '<div class="bg-white rounded-xl p-4 border border-gray-200">';
    html += '<p class="text-xs text-gray-500 text-center mb-2">schematic</p>';
    html += '<div class="flex justify-center">' + buildSchematicSvg(piece, unit) + '</div>';
    html += '</div>';

    html += '</div></div>';
  });

  container.innerHTML = html;
  document.getElementById("resultsPanel").classList.remove("hidden");
}

function escapeHtml(str) {
  var div = document.createElement("div");
  div.textContent = str;
  return div.innerHTML;
}

function buildSchematicSvg(piece, unit) {
  var width = piece.finished_width;
  var height = piece.finished_height;
  var castOn = piece.cast_on;
  var totalRows = piece.total_rows;

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
  svg += '<rect x="' + rectX + '" y="' + rectY + '" width="' + rectW + '" height="' + rectH + '" ';
  svg += 'fill="#fce7f3" stroke="#ec4899" stroke-width="2" rx="4"/>';

  var widthLabelX = rectX + rectW / 2;
  var widthLabelY = rectY + rectH + 16;
  svg += '<text x="' + widthLabelX + '" y="' + widthLabelY + '" text-anchor="middle" ';
  svg += 'font-size="11" fill="#be185d" font-weight="600">' + width + ' ' + unitAbbr + '</text>';
  svg += '<text x="' + widthLabelX + '" y="' + (widthLabelY + 13) + '" text-anchor="middle" ';
  svg += 'font-size="10" fill="#9ca3af">' + castOn + ' sts</text>';

  var heightLabelX = rectX + rectW + 10;
  var heightLabelY = rectY + rectH / 2;
  svg += '<text x="' + heightLabelX + '" y="' + (heightLabelY - 6) + '" text-anchor="start" ';
  svg += 'font-size="11" fill="#1d4ed8" font-weight="600">' + height + ' ' + unitAbbr + '</text>';
  svg += '<text x="' + heightLabelX + '" y="' + (heightLabelY + 8) + '" text-anchor="start" ';
  svg += 'font-size="10" fill="#9ca3af">' + totalRows + ' rows</text>';

  svg += '</svg>';
  return svg;
}
