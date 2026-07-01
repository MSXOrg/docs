/* global document$, Tablesort */
document$.subscribe(function () {
  var tables = document.querySelectorAll("article table:not([class])");
  tables.forEach(function (table) {
    // If table doesn't have a thead, create one from the first row
    if (!table.querySelector("thead")) {
      var firstRow = table.querySelector("tr");
      if (firstRow) {
        var thead = document.createElement("thead");
        thead.appendChild(firstRow);
        table.insertBefore(thead, table.firstChild);
      }
    }
    new Tablesort(table);

    // Tablesort makes header cells focusable (tabindex=0) and sorts on click,
    // but does not handle keyboard activation. Let Enter/Space sort too, so the
    // sortable headers are usable without a mouse.
    table.querySelectorAll("th").forEach(function (header) {
      header.addEventListener("keydown", function (event) {
        if (event.key === "Enter" || event.key === " ") {
          event.preventDefault();
          header.click();
        }
      });
    });
  });
});
