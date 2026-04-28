(function () {
  var SPANS = { big: [2, 2], wide: [2, 1], tall: [1, 2] };
  var DESKTOP_BREAKPOINT = 900;

  function getNumCols() {
    return window.innerWidth > DESKTOP_BREAKPOINT ? 4 : 2;
  }

  function packGrid(tiles, numCols) {
    var occupied = Object.create(null);
    var key = function (r, c) { return r + ',' + c; };
    var taken = function (r, c) { return !!occupied[key(r, c)]; };

    function canPlace(r, c, cSpan, rSpan) {
      if (c + cSpan > numCols) return false;
      for (var dr = 0; dr < rSpan; dr++) {
        for (var dc = 0; dc < cSpan; dc++) {
          if (taken(r + dr, c + dc)) return false;
        }
      }
      return true;
    }

    function mark(r, c, cSpan, rSpan) {
      for (var dr = 0; dr < rSpan; dr++) {
        for (var dc = 0; dc < cSpan; dc++) {
          occupied[key(r + dr, c + dc)] = true;
        }
      }
    }

    function firstFit(cSpan, rSpan) {
      for (var r = 0; r < 1000; r++) {
        for (var c = 0; c <= numCols - cSpan; c++) {
          if (canPlace(r, c, cSpan, rSpan)) return [r, c];
        }
      }
      return null;
    }

    var placements = [];

    // Pass 1: large tiles in declaration order.
    for (var i = 0; i < tiles.length; i++) {
      var size = tiles[i].getAttribute('data-size');
      if (!size || !SPANS[size]) continue;
      var span = SPANS[size];
      var cSpan = span[0];
      var rSpan = span[1];
      // A tile larger than the available column count degrades to 1×1.
      if (cSpan > numCols) { cSpan = 1; rSpan = 1; }
      var pos = firstFit(cSpan, rSpan);
      if (!pos) continue;
      mark(pos[0], pos[1], cSpan, rSpan);
      placements.push({
        tile: tiles[i],
        c1: pos[1] + 1, c2: pos[1] + 1 + cSpan,
        r1: pos[0] + 1, r2: pos[0] + 1 + rSpan
      });
    }

    // Pass 2: flood remaining cells with 1×1 fillers.
    var smalls = [];
    for (var j = 0; j < tiles.length; j++) {
      var s = tiles[j].getAttribute('data-size');
      if (!s || !SPANS[s]) smalls.push(tiles[j]);
    }

    var maxRow = 0;
    for (var p = 0; p < placements.length; p++) {
      if (placements[p].r2 - 1 > maxRow) maxRow = placements[p].r2 - 1;
    }
    var totalRows = maxRow + Math.ceil(smalls.length / numCols) + 2;
    var fi = 0;
    for (var r = 0; r < totalRows && fi < smalls.length; r++) {
      for (var c = 0; c < numCols && fi < smalls.length; c++) {
        if (!taken(r, c)) {
          mark(r, c, 1, 1);
          placements.push({
            tile: smalls[fi++],
            c1: c + 1, c2: c + 2,
            r1: r + 1, r2: r + 2
          });
        }
      }
    }

    return placements;
  }

  function applyLayout() {
    var grid = document.getElementById('gallery-grid');
    if (!grid) return;
    var tiles = Array.prototype.slice.call(grid.querySelectorAll('.gallery-tile'));
    if (!tiles.length) return;

    var numCols = getNumCols();
    var placements = packGrid(tiles, numCols);

    for (var i = 0; i < placements.length; i++) {
      var p = placements[i];
      p.tile.style.gridColumn = p.c1 + ' / ' + p.c2;
      p.tile.style.gridRow = p.r1 + ' / ' + p.r2;
    }
  }

  function init() {
    applyLayout();
    var t;
    window.addEventListener('resize', function () {
      clearTimeout(t);
      t = setTimeout(applyLayout, 150);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
