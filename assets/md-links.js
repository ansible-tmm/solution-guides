/**
 * GitHub Pages serves rendered guides without a .md suffix. Repo markdown
 * keeps .md hrefs so links still work on github.com; rewrite them for Pages.
 */
(function () {
  var host = window.location.host;

  document.querySelectorAll("a[href]").forEach(function (anchor) {
    var href = anchor.getAttribute("href");
    if (!href || href.indexOf(".md") === -1) return;

    if (/^https?:\/\//i.test(href)) {
      try {
        if (new URL(href).host !== host) return;
      } catch (e) {
        return;
      }
    }

    anchor.setAttribute(
      "href",
      href.replace(/\.md(?=(?:#|\?|$))/i, "")
    );
  });
})();
