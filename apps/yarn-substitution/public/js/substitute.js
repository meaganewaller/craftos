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

function renderMatch(yarn) {
  const fibers = yarn.fiber_content
    ? Object.entries(yarn.fiber_content).map(([k, v]) => `${v}% ${k}`).join(", ")
    : "Not specified";

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
        </div>
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
    const data = await apiPost("/api/substitute", body);

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
      listEl.innerHTML = data.matches.map(renderMatch).join("");
    }
  } catch (e) {
    showError(e.message);
  }
}
