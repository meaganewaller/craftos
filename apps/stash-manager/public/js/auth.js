function showAuthError(msg) {
  const el = document.getElementById("error");
  el.textContent = msg;
  el.classList.remove("hidden");
}

function hideAuthError() {
  document.getElementById("error").classList.add("hidden");
}

document.addEventListener("DOMContentLoaded", function () {
  const loginForm = document.getElementById("login-form");
  const signupForm = document.getElementById("signup-form");

  if (loginForm) {
    loginForm.addEventListener("submit", async function (e) {
      e.preventDefault();
      hideAuthError();

      try {
        const resp = await fetch("/api/auth/login", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            username: document.getElementById("username").value,
            password: document.getElementById("password").value
          })
        });

        const data = await resp.json();
        if (!resp.ok) {
          showAuthError(data.error || "Login failed");
          return;
        }

        window.location.href = "/";
      } catch (err) {
        showAuthError("Something went wrong. Please try again.");
      }
    });
  }

  if (signupForm) {
    signupForm.addEventListener("submit", async function (e) {
      e.preventDefault();
      hideAuthError();

      try {
        const resp = await fetch("/api/auth/signup", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({
            username: document.getElementById("username").value,
            password: document.getElementById("password").value
          })
        });

        const data = await resp.json();
        if (!resp.ok) {
          showAuthError(data.error || "Signup failed");
          return;
        }

        window.location.href = "/";
      } catch (err) {
        showAuthError("Something went wrong. Please try again.");
      }
    });
  }
});
