var pieces = [];
var nextPieceId = 1;
var craftType = "knit";
var allStitchPatterns = [];

var KNIT_PATTERNS = ["stockinette", "garter", "rib_1x1", "rib_2x2", "seed", "moss_stitch"];
var CROCHET_PATTERNS = ["single_crochet", "half_double_crochet", "double_crochet", "treble_crochet", "shell_stitch", "v_stitch"];

function craftTerms() {
  if (craftType === "crochet") {
    return { castOn: "foundation chain", bindOff: "fasten off", castOnVerb: "chain", sts: "sts" };
  }
  return { castOn: "cast on", bindOff: "bind off", castOnVerb: "cast on", sts: "sts" };
}

document.addEventListener("DOMContentLoaded", function () {
  loadStitchPatterns();
  addPiece("Back", 20, 25);
});

function setCraftType(type) {
  craftType = type;
  var knitBtn = document.getElementById("craftKnit");
  var crochetBtn = document.getElementById("craftCrochet");
  if (type === "knit") {
    knitBtn.className = "flex-1 p-3 rounded-xl border-2 font-medium text-sm transition craft-type-btn border-pink-400 bg-pink-50 text-pink-700";
    crochetBtn.className = "flex-1 p-3 rounded-xl border-2 font-medium text-sm transition craft-type-btn border-gray-200 bg-white text-gray-500";
  } else {
    crochetBtn.className = "flex-1 p-3 rounded-xl border-2 font-medium text-sm transition craft-type-btn border-pink-400 bg-pink-50 text-pink-700";
    knitBtn.className = "flex-1 p-3 rounded-xl border-2 font-medium text-sm transition craft-type-btn border-gray-200 bg-white text-gray-500";
  }
  filterStitchPatterns();
  updateRepeatHint();
}

function updateRepeatHint() {
  var hint = document.getElementById("repeatHint");
  if (hint) {
    hint.textContent = (craftType === "crochet")
      ? "example: 3 dc, ch 1 = repeat of 4"
      : "example: k2, p2 = repeat of 4";
  }
}

function loadStitchPatterns() {
  fetch("/api/stitch_patterns")
    .then(function (res) { return res.json(); })
    .then(function (patterns) {
      allStitchPatterns = patterns;
      filterStitchPatterns();
    })
    .catch(function () {});
}

function filterStitchPatterns() {
  var select = document.getElementById("stitchPattern");
  var currentValue = select.value;
  var allowed = (craftType === "crochet") ? CROCHET_PATTERNS : KNIT_PATTERNS;

  var defaultLabel = (craftType === "crochet") ? "None (plain single crochet gauge)" : "None (plain stockinette gauge)";
  select.innerHTML = '<option value="">' + defaultLabel + '</option>';
  allStitchPatterns.forEach(function (p) {
    if (allowed.indexOf(p.key) !== -1) {
      var opt = document.createElement("option");
      opt.value = p.key;
      opt.textContent = p.name + " (width: " + p.width_factor + "x, yarn: " + p.yarn_factor + "x)";
      select.appendChild(opt);
    }
  });

  // Restore selection if still valid, otherwise reset
  if (allowed.indexOf(currentValue) !== -1) {
    select.value = currentValue;
  } else {
    select.value = "";
  }
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
  var terms = craftTerms();
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
    html += '<p class="text-xs text-gray-500">' + terms.castOn + '</p>';
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
      var shapingVerb = (piece.shaping.method === "increase") ? "inc" : "dec";
      var everyRows = piece.shaping.every_n_rows;
      html += '<div class="bg-purple-50 rounded-xl p-3 text-sm space-y-1">';
      html += '<p class="font-semibold text-purple-700">shaping: ' + piece.shaping.method + '</p>';
      html += '<p class="text-xs text-purple-600">' + piece.finished_width + ' ' + unitAbbr + ' → ' + piece.shaping.end_width + ' ' + unitAbbr + '</p>';
      html += '<p class="text-xs text-purple-600">' + piece.cast_on + ' ' + terms.sts + ' → ' + piece.shaping.end_stitches + ' ' + terms.sts + '</p>';
      html += '<p class="text-xs text-purple-500">' + shapingVerb + ' every ' + everyRows + ' rows, ' + piece.shaping.total_changes + ' times</p>';
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
  var startWidth = piece.finished_width;
  var height = piece.finished_height;
  var castOn = piece.cast_on;
  var totalRows = piece.total_rows;
  var hasShaping = piece.shaping && piece.shaping.enabled;
  var endWidth = hasShaping ? piece.shaping.end_width : startWidth;
  var endStitches = hasShaping ? piece.shaping.end_stitches : castOn;
  var maxW = Math.max(startWidth, endWidth);

  var maxSvgWidth = 280;
  var maxSvgHeight = 220;
  var padding = 50;

  var availW = maxSvgWidth - padding * 2;
  var availH = maxSvgHeight - padding * 2;
  var scale = Math.min(availW / maxW, availH / height);
  var bottomW = startWidth * scale;
  var topW = endWidth * scale;
  var shapeH = height * scale;

  var unitAbbr = (unit === "centimeters") ? "cm" : "in";
  var terms = craftTerms();
  var svg = '<svg width="' + maxSvgWidth + '" height="' + maxSvgHeight + '" xmlns="http://www.w3.org/2000/svg">';

  // Bottom edge is cast-on/chain (where you start), top edge is bind-off/fasten-off (where you end)
  var centerX = maxSvgWidth / 2;
  var bottomY = padding + shapeH;
  var topY = padding;

  if (hasShaping) {
    // Trapezoid: bottom = starting width, top = end width
    var blX = centerX - bottomW / 2;
    var brX = centerX + bottomW / 2;
    var tlX = centerX - topW / 2;
    var trX = centerX + topW / 2;

    var points = tlX + ',' + topY + ' ' + trX + ',' + topY + ' ' + brX + ',' + bottomY + ' ' + blX + ',' + bottomY;
    svg += '<polygon points="' + points + '" fill="#fce7f3" stroke="#ec4899" stroke-width="2" stroke-linejoin="round"/>';

    // Top label (end/bind-off/fasten-off)
    svg += '<text x="' + centerX + '" y="' + (topY - 18) + '" text-anchor="middle" ';
    svg += 'font-size="11" fill="#7c3aed" font-weight="600">' + endWidth + ' ' + unitAbbr + '</text>';
    svg += '<text x="' + centerX + '" y="' + (topY - 6) + '" text-anchor="middle" ';
    svg += 'font-size="10" fill="#9ca3af">' + endStitches + ' sts</text>';

    // Bottom label (cast-on/chain)
    svg += '<text x="' + centerX + '" y="' + (bottomY + 16) + '" text-anchor="middle" ';
    svg += 'font-size="11" fill="#be185d" font-weight="600">' + startWidth + ' ' + unitAbbr + '</text>';
    svg += '<text x="' + centerX + '" y="' + (bottomY + 29) + '" text-anchor="middle" ';
    svg += 'font-size="10" fill="#9ca3af">' + castOn + ' sts (' + terms.castOnVerb + ')</text>';
  } else {
    // Rectangle for no shaping
    var rectX = centerX - bottomW / 2;
    svg += '<rect x="' + rectX + '" y="' + topY + '" width="' + bottomW + '" height="' + shapeH + '" ';
    svg += 'fill="#fce7f3" stroke="#ec4899" stroke-width="2" rx="4"/>';

    // Bottom label
    svg += '<text x="' + centerX + '" y="' + (bottomY + 16) + '" text-anchor="middle" ';
    svg += 'font-size="11" fill="#be185d" font-weight="600">' + startWidth + ' ' + unitAbbr + '</text>';
    svg += '<text x="' + centerX + '" y="' + (bottomY + 29) + '" text-anchor="middle" ';
    svg += 'font-size="10" fill="#9ca3af">' + castOn + ' sts (' + terms.castOnVerb + ')</text>';
  }

  // Height label (right side)
  var heightLabelX = centerX + Math.max(bottomW, topW) / 2 + 10;
  var heightLabelY = topY + shapeH / 2;
  svg += '<text x="' + heightLabelX + '" y="' + (heightLabelY - 6) + '" text-anchor="start" ';
  svg += 'font-size="11" fill="#1d4ed8" font-weight="600">' + height + ' ' + unitAbbr + '</text>';
  svg += '<text x="' + heightLabelX + '" y="' + (heightLabelY + 8) + '" text-anchor="start" ';
  svg += 'font-size="10" fill="#9ca3af">' + totalRows + ' rows</text>';

  svg += '</svg>';
  return svg;
}
