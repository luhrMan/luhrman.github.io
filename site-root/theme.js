// Shares the "theme" localStorage key and data-bs-theme attribute with the Doks theme used under /sqyre/.
(() => {
  const media = window.matchMedia("(prefers-color-scheme: dark)");
  const stored = () => localStorage.getItem("theme");
  const apply = (theme) => {
    const dark = theme === "dark" || (theme !== "light" && media.matches);
    document.documentElement.setAttribute("data-bs-theme", dark ? "dark" : "light");
  };

  apply(stored());
  media.addEventListener("change", () => apply(stored()));

  window.addEventListener("DOMContentLoaded", () => {
    document.querySelector(".theme-toggle")?.addEventListener("click", () => {
      const next = document.documentElement.getAttribute("data-bs-theme") === "dark" ? "light" : "dark";
      localStorage.setItem("theme", next);
      apply(next);
    });
  });
})();
