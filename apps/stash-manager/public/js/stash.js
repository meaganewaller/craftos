async function apiRequest(url, options = {}) {
  const resp = await fetch(url, options);
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

    if (entries.length === 0) {
      listEl.innerHTML = "";
      emptyEl.classList.remove("hidden");
    } else {
      emptyEl.classList.add("hidden");
      listEl.innerHTML = entries.map(renderEntry).join("");
    }
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

document.addEventListener("DOMContentLoaded", loadStash);
