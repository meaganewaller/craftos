let lastTarget = null;

async function apiPost(url, body) {
  const resp = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body)
  });
  const data = await resp.json();
  if (!resp.ok) throw new Error(data.error || "Request failed");
  return data;
}

function showError(msg) {
  const el = document.getElementById("error");
  el.textContent = msg;
  el.classList.remove("hidden");
}

function hideError() {
  document.getElementById("error").classList.add("hidden");
}

function formatCategory(cat) {
  if (!cat) return "Unknown";
  return cat.replace(/_/g, " ").replace(/\b\w/g, c => c.toUpperCase());
}

function formatFibers(fiberContent) {
  if (!fiberContent) return "Not specified";
  return Object.entries(fiberContent).map(([k, v]) => `${v}% ${k}`).join(", ");
}

function renderCompare(target, yarn) {
  return `
    <div class="bg-purple-50 rounded-lg p-4 mt-2 mb-3 border border-purple-200">
      <h3 class="text-sm font-semibold text-purple-700 mb-3">Side-by-side comparison</h3>
      <table class="w-full text-sm">
        <thead>
          <tr class="text-gray-600">
            <th class="text-left py-1">Property</th>
            <th class="text-center py-1">Your Yarn</th>
            <th class="text-center py-1">${yarn.brand} ${yarn.line}</th>
          </tr>
        </thead>
        <tbody>
          <tr class="border-t">
            <td class="py-1 text-gray-700">Weight Category</td>
            <td class="text-center">${formatCategory(target.weight_category)}</td>
            <td class="text-center">${formatCategory(yarn.weight_category)}</td>
          </tr>
          <tr class="border-t">
            <td class="py-1 text-gray-700">Yards/100g</td>
            <td class="text-center">${target.yards_per_100g}</td>
            <td class="text-center">${yarn.yards_per_100g}</td>
          </tr>
          <tr class="border-t">
            <td class="py-1 text-gray-700">Grist</td>
            <td class="text-center">${target.grist}</td>
            <td class="text-center">${yarn.grist}</td>
          </tr>
          <tr class="border-t">
            <td class="py-1 text-gray-700">Fiber</td>
            <td class="text-center">${formatFibers(target.fiber_content)}</td>
            <td class="text-center">${formatFibers(yarn.fiber_content)}</td>
          </tr>
        </tbody>
      </table>
    </div>
  `;
}

function toggleCompare(btn, idx) {
  const container = document.getElementById(`compare-${idx}`);
  if (container.classList.contains("hidden")) {
    container.classList.remove("hidden");
    btn.textContent = "Hide comparison";
  } else {
    container.classList.add("hidden");
    btn.textContent = "Compare";
  }
}

function renderMatch(yarn, idx) {
  const fibers = formatFibers(yarn.fiber_content);
  const gristDiff = Math.abs(yarn.yards_per_100g - lastTarget.yards_per_100g).toFixed(1);

  return `
    <div class="bg-white rounded-lg shadow p-4 mb-3">
      <div class="flex justify-between items-start">
        <div>
          <div class="font-semibold text-purple-800">${yarn.brand} ${yarn.line}</div>
          <div class="text-sm text-gray-600">${fibers}</div>
        </div>
        <div class="text-right">
          <div class="text-sm font-medium text-purple-700">${formatCategory(yarn.weight_category)}</div>
          <div class="text-sm text-gray-500">${yarn.yards_per_100g} yd/100g</div>
          <div class="text-xs text-gray-400">&Delta; ${gristDiff} yd/100g</div>
        </div>
      </div>
      <div class="mt-2">
        <button onclick="toggleCompare(this, ${idx})" class="text-sm text-purple-600 hover:text-purple-800 underline">Compare</button>
      </div>
      <div id="compare-${idx}" class="hidden">
        ${renderCompare(lastTarget, yarn)}
      </div>
    </div>
  `;
}

async function findSubstitutes() {
  hideError();

  const yardage = parseFloat(document.getElementById("yardage").value);
  const skeinWeight = parseFloat(document.getElementById("skein_weight").value);

  if (!yardage || !skeinWeight || yardage <= 0 || skeinWeight <= 0) {
    showError("Please enter valid yardage and skein weight.");
    return;
  }

  const body = {
    yardage: yardage,
    skein_weight: skeinWeight,
    brand: document.getElementById("brand").value || undefined,
    line: document.getElementById("line").value || undefined,
    tolerance: parseFloat(document.getElementById("tolerance").value)
  };

  const fiber = document.getElementById("fiber_filter").value;
  if (fiber) body.fiber = fiber;

  try {
    const data = await apiPost("/api/substitution", body);

    lastTarget = data.target;

    const infoEl = document.getElementById("target-info");
    document.getElementById("weight-category").textContent = formatCategory(data.target.weight_category);
    document.getElementById("yards-per-100g").textContent = data.target.yards_per_100g;
    document.getElementById("grist").textContent = data.target.grist;
    infoEl.classList.remove("hidden");

    const resultsEl = document.getElementById("results");
    const listEl = document.getElementById("matches-list");
    const noMatchesEl = document.getElementById("no-matches");

    resultsEl.classList.remove("hidden");

    if (data.matches.length === 0) {
      listEl.innerHTML = "";
      noMatchesEl.classList.remove("hidden");
    } else {
      noMatchesEl.classList.add("hidden");
      listEl.innerHTML = data.matches.map((m, i) => renderMatch(m, i)).join("");
    }
  } catch (e) {
    showError(e.message);
  }
}
