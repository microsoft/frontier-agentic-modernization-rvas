/* =====================================================================
   RVAS SHARED SHELL JS — vX  (source of truth: /shared/shell.js)
   Self-contained, no data dependencies. Safe to load on every page.
   - Mobile nav toggle (+ Esc to close, click-outside)
   - Scroll reveal for .reveal elements
   - Count-up for .stat-num (respects prefers-reduced-motion)
   Works alongside a site's own core.js/home.js. Idempotent.
   ===================================================================== */
(function () {
  "use strict";

  var reduceMotion = window.matchMedia &&
    window.matchMedia("(prefers-reduced-motion: reduce)").matches;

  /* ── Mobile nav ─────────────────────────────────────────────────── */
  function initNav() {
    var toggle = document.querySelector(".nav-toggle");
    var links = document.querySelector(".nav-links");
    if (!toggle || !links || toggle.dataset.shellBound) return;
    toggle.dataset.shellBound = "1";
    function close() {
      links.classList.remove("open");
      toggle.setAttribute("aria-expanded", "false");
    }
    toggle.addEventListener("click", function () {
      var open = links.classList.toggle("open");
      toggle.setAttribute("aria-expanded", String(open));
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape" && links.classList.contains("open")) close();
    });
    document.addEventListener("click", function (e) {
      if (!links.classList.contains("open")) return;
      if (!links.contains(e.target) && !toggle.contains(e.target)) close();
    });
  }

  /* ── Scroll reveal ──────────────────────────────────────────────── */
  function initReveal() {
    var els = document.querySelectorAll(".reveal:not(.visible)");
    if (!els.length) return;
    if (reduceMotion || !("IntersectionObserver" in window)) {
      els.forEach(function (el) { el.classList.add("visible"); });
      return;
    }
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (en.isIntersecting) {
          en.target.classList.add("visible");
          io.unobserve(en.target);
        }
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -40px 0px" });
    els.forEach(function (el) { io.observe(el); });
  }

  /* ── Count-up for .stat-num ─────────────────────────────────────── */
  // Target resolution order: data-count attr, else the numeric text present
  // when first revealed (handles values injected async by a site's home.js).
  function parseTarget(str) {
    if (str == null) return null;
    var m = String(str).replace(/,/g, "").match(/-?\d+(?:\.\d+)?/);
    return m ? parseFloat(m[0]) : null;
  }
  function formatWith(template, value) {
    // Preserve any suffix/prefix around the number in the template (e.g. "42h", "~5").
    if (template == null) return String(value);
    var hasNum = String(template).match(/-?\d+(?:\.\d+)?/);
    if (!hasNum) return String(value);
    return String(template).replace(/-?\d+(?:\.\d+)?/, String(value));
  }
  function animateEl(el, target, template) {
    if (reduceMotion) { el.textContent = formatWith(template, target); return; }
    var dur = 1100, start = null, isFloat = target % 1 !== 0;
    function tick(ts) {
      if (start === null) start = ts;
      var p = Math.min((ts - start) / dur, 1);
      var eased = 1 - Math.pow(1 - p, 4); // ease-out-quart
      var v = target * eased;
      v = isFloat ? Math.round(v * 10) / 10 : Math.round(v);
      el.textContent = formatWith(template, v);
      if (p < 1) requestAnimationFrame(tick);
      else el.textContent = formatWith(template, target);
    }
    requestAnimationFrame(tick);
  }
  function runCounter(el) {
    if (el.dataset.shellCounted) return;
    var explicit = parseTarget(el.getAttribute("data-count"));
    if (explicit != null) {
      el.dataset.shellCounted = "1";
      animateEl(el, explicit, el.getAttribute("data-count-format") || el.textContent || "");
      return;
    }
    // No data-count: wait until a numeric value is present (may be injected async).
    var current = parseTarget(el.textContent);
    if (current != null && el.textContent.trim() !== "") {
      el.dataset.shellCounted = "1";
      animateEl(el, current, el.textContent);
    }
  }
  function initCounters() {
    var nums = document.querySelectorAll(".stat-num");
    if (!nums.length) return;

    function schedule(el) {
      // If value not ready yet, observe text mutations until it appears.
      if (el.dataset.shellCounted) return;
      var ready = el.getAttribute("data-count") != null ||
        (parseTarget(el.textContent) != null && el.textContent.trim() !== "");
      if (ready) { runCounter(el); return; }
      var mo = new MutationObserver(function () {
        if (parseTarget(el.textContent) != null && el.textContent.trim() !== "") {
          mo.disconnect();
          runCounter(el);
        }
      });
      mo.observe(el, { childList: true, characterData: true, subtree: true });
    }

    if (!("IntersectionObserver" in window)) {
      nums.forEach(schedule);
      return;
    }
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (en) {
        if (en.isIntersecting) { schedule(en.target); io.unobserve(en.target); }
      });
    }, { threshold: 0.4 });
    nums.forEach(function (el) { io.observe(el); });
  }

  function boot() {
    initNav();
    initReveal();
    initCounters();
  }
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
  // Expose for sites that inject stats after boot.
  window.RVASShell = { refresh: boot, animate: animateEl };
})();
