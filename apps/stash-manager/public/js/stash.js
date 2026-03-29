async function apiRequest(url, options = {}) {
  const resp = await fetch(url, options);
  if (resp.status === 401) {
    window.location.href = "/login";
    throw new Error("Unauthorized");
  }
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

function renderEntry(entry) {
  const colorway = entry.colorway ? ` - ${entry.colorway}` : "";
  return `
    <div class="flex justify-between items-center border-b py-3" data-id="${entry.id}">
      <div>
        <div class="font-semibold text-teal-800">${entry.brand} ${entry.line}${colorway}</div>
        <div class="text-sm text-gray-500">${entry.quantity} skein(s) &middot; ${entry.yardage} yd each &middot; ${entry.total_yardage} yd total</div>
      </div>
      <button onclick="removeEntry(${entry.id})" class="text-red-400 hover:text-red-600 text-sm">Remove</button>
    </div>
  `;
}

async function loadStash() {
  hideError();
  try {
    const search = document.getElementById("search").value;
    const url = search ? `/api/stash?search=${encodeURIComponent(search)}` : "/api/stash";
    const entries = await apiRequest(url);
    const listEl = document.getElementById("stash-list");
    const emptyEl = document.getElementById("empty-stash");

    stashEntries = entries;
    if (entries.length === 0) {
      listEl.innerHTML = "";
      emptyEl.classList.remove("hidden");
    } else {
      emptyEl.classList.add("hidden");
      listEl.innerHTML = entries.map(renderEntry).join("");
    }
    updateYarnSelectors();
  } catch (e) {
    showError(e.message);
  }
}

async function addToStash() {
  hideError();
  const body = {
    brand: document.getElementById("brand").value,
    line: document.getElementById("line").value,
    colorway: document.getElementById("colorway").value || undefined,
    yardage: parseFloat(document.getElementById("yardage").value),
    skein_weight: parseFloat(document.getElementById("skein_weight").value),
    quantity: parseInt(document.getElementById("quantity").value) || 1
  };

  if (!body.brand || !body.line || !body.yardage || !body.skein_weight) {
    showError("Please fill in brand, line, yardage, and skein weight.");
    return;
  }

  try {
    await apiRequest("/api/stash", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body)
    });
    document.getElementById("brand").value = "";
    document.getElementById("line").value = "";
    document.getElementById("colorway").value = "";
    document.getElementById("yardage").value = "";
    document.getElementById("skein_weight").value = "";
    document.getElementById("quantity").value = "1";
    loadStash();
  } catch (e) {
    showError(e.message);
  }
}

async function removeEntry(id) {
  hideError();
  try {
    await apiRequest(`/api/stash/${id}`, { method: "DELETE" });
    loadStash();
  } catch (e) {
    showError(e.message);
  }
}

async function checkYardage() {
  hideError();
  const required = parseFloat(document.getElementById("required_yardage").value);
  if (!required || required <= 0) {
    showError("Please enter a positive yardage amount.");
    return;
  }

  try {
    const result = await apiRequest(`/api/stash/check?yardage=${required}`);
    const el = document.getElementById("check-result");
    el.classList.remove("hidden");

    if (result.sufficient) {
      el.className = "mt-4 p-3 rounded bg-green-100 text-green-800";
      el.textContent = `You have ${result.available} yards available. That's enough! (${result.available - result.required} yards to spare)`;
    } else {
      el.className = "mt-4 p-3 rounded bg-amber-100 text-amber-800";
      el.textContent = `You have ${result.available} yards available but need ${result.required}. Short by ${result.shortage} yards.`;
    }
  } catch (e) {
    showError(e.message);
  }
}

// --- Project Check ---

let stashEntries = [];

function toggleProjectMode() {
  const mode = document.querySelector('input[name="project_mode"]:checked').value;
  document.getElementById("simple-fields").classList.toggle("hidden", mode !== "simple");
  document.getElementById("colorwork-fields").classList.toggle("hidden", mode !== "colorwork");
  if (mode === "colorwork" && document.getElementById("color-roles").children.length === 0) {
    addColorRole();
    addColorRole();
  }
}

function buildYarnCheckbox(entry, namePrefix) {
  const label = `${entry.brand} ${entry.line}${entry.colorway ? " - " + entry.colorway : ""} (${entry.total_yardage} yd)`;
  return `<label class="flex items-center gap-2 text-sm">
    <input type="checkbox" name="${namePrefix}" value="${entry.id}">
    <span>${label}</span>
  </label>`;
}

function buildYarnSelect(entry) {
  const label = `${entry.brand} ${entry.line}${entry.colorway ? " - " + entry.colorway : ""} (${entry.total_yardage} yd)`;
  return `<option value="${entry.id}">${label}</option>`;
}

function updateYarnSelectors() {
  const simpleEl = document.getElementById("simple-yarn-selector");
  if (stashEntries.length === 0) {
    simpleEl.innerHTML = '<span class="text-sm text-gray-400">No yarn in stash yet.</span>';
    return;
  }
  simpleEl.innerHTML = stashEntries.map(e => buildYarnCheckbox(e, "simple_yarn")).join("");

  document.querySelectorAll(".cw-yarn-select").forEach(select => {
    const current = select.value;
    select.innerHTML = '<option value="">Select yarn...</option>' + stashEntries.map(buildYarnSelect).join("");
    if (current) select.value = current;
  });
}

let colorRoleCount = 0;

function addColorRole() {
  const idx = colorRoleCount++;
  const container = document.getElementById("color-roles");
  const div = document.createElement("div");
  div.className = "grid grid-cols-12 gap-2 items-start";
  div.id = `color-role-${idx}`;
  div.innerHTML = `
    <input type="text" class="col-span-3 border rounded px-2 py-1 text-sm" placeholder="Color name" data-role="name-${idx}">
    <input type="number" step="0.01" min="0" max="1" class="col-span-2 border rounded px-2 py-1 text-sm" placeholder="0.50" data-role="proportion-${idx}">
    <select class="cw-yarn-select col-span-6 border rounded px-2 py-1 text-sm" data-role="yarn-${idx}">
      <option value="">Select yarn...</option>
      ${stashEntries.map(buildYarnSelect).join("")}
    </select>
    <button onclick="removeColorRole(${idx})" class="col-span-1 text-red-400 hover:text-red-600 text-sm py-1">x</button>
  `;
  container.appendChild(div);
}

function removeColorRole(idx) {
  const el = document.getElementById(`color-role-${idx}`);
  if (el) el.remove();
}

async function checkProject() {
  hideError();
  const mode = document.querySelector('input[name="project_mode"]:checked').value;

  const gauge = {
    stitches: parseFloat(document.getElementById("gauge_stitches").value),
    rows: parseFloat(document.getElementById("gauge_rows").value),
    width: parseFloat(document.getElementById("gauge_width").value),
    height: parseFloat(document.getElementById("gauge_height").value)
  };

  if (!gauge.stitches || !gauge.rows || !gauge.width) {
    showError("Please fill in gauge stitches, rows, and width.");
    return;
  }
  if (!gauge.height) gauge.height = gauge.width;

  const dimensions = {
    width: parseFloat(document.getElementById("dim_width").value),
    height: parseFloat(document.getElementById("dim_height").value)
  };

  if (!dimensions.width || !dimensions.height) {
    showError("Please fill in finished dimensions.");
    return;
  }

  let body;
  if (mode === "simple") {
    const checked = [...document.querySelectorAll('input[name="simple_yarn"]:checked')].map(cb => parseInt(cb.value));
    if (checked.length === 0) {
      showError("Please select at least one yarn from your stash.");
      return;
    }
    body = { mode: "simple", gauge, dimensions, stash_entry_ids: checked };
  } else {
    const technique = document.getElementById("cw_technique").value;
    const roles = document.getElementById("color-roles").children;
    const colors = {};

    for (const role of roles) {
      const name = role.querySelector('[data-role^="name-"]').value.trim();
      const proportion = parseFloat(role.querySelector('[data-role^="proportion-"]').value);
      const yarnId = parseInt(role.querySelector('[data-role^="yarn-"]').value);

      if (!name || !proportion || !yarnId) {
        showError("Please fill in all color role fields.");
        return;
      }
      colors[name] = { proportion, stash_entry_ids: [yarnId] };
    }

    body = { mode: "colorwork", gauge, dimensions, technique, colors };
  }

  try {
    const result = await apiRequest("/api/stash/project-check", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(body)
    });
    renderProjectResult(result);
  } catch (e) {
    showError(e.message);
  }
}

function renderProjectResult(result) {
  const el = document.getElementById("project-result");
  el.classList.remove("hidden");

  if (result.mode === "simple") {
    const ok = result.sufficient;
    el.className = `mt-4 p-3 rounded ${ok ? "bg-green-100 text-green-800" : "bg-amber-100 text-amber-800"}`;
    el.innerHTML = `
      <div class="font-semibold mb-1">${ok ? "You have enough yarn!" : "Not enough yarn"}</div>
      <div class="text-sm">Estimated: ${result.estimated_yardage} yd (${result.estimated_skeins} skeins)</div>
      <div class="text-sm">Available: ${result.available_yardage} yd</div>
      <div class="text-sm">${ok ? `Surplus: ${result.surplus} yd` : `Shortage: ${result.shortage} yd`}</div>
    `;
  } else {
    const ok = result.all_sufficient;
    el.className = `mt-4 p-3 rounded ${ok ? "bg-green-100 text-green-800" : "bg-amber-100 text-amber-800"}`;

    let colorHtml = "";
    for (const [name, data] of Object.entries(result.colors)) {
      const colorOk = data.sufficient;
      const icon = colorOk ? "&#10003;" : "&#10007;";
      colorHtml += `<div class="text-sm ${colorOk ? "" : "font-semibold"}">
        ${icon} ${name}: ${data.estimated_yardage} yd needed, ${data.available_yardage} yd available
        ${colorOk ? `(+${data.surplus} yd)` : `(-${data.shortage} yd)`}
      </div>`;
    }

    el.innerHTML = `
      <div class="font-semibold mb-1">${ok ? "All colors sufficient!" : "Some colors are short"}</div>
      <div class="text-sm mb-2">Technique: ${result.technique} | Total: ${result.total_estimated_yardage} yd</div>
      ${colorHtml}
    `;
  }
}

document.addEventListener("DOMContentLoaded", async () => {
  await loadStash();
  try {
    stashEntries = await apiRequest("/api/stash");
    updateYarnSelectors();
  } catch (e) { /* stash will show empty */ }
});
