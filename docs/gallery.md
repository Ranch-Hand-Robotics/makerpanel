---
title: Explore panels
description: Find your next starting point. Search open MakerPanel designs for keyboards, controls, displays, and more.
---

<section class="gallery-header" aria-labelledby="gallery-title">
  <div>
    <p class="eyebrow">THE OPEN PARTS BIN / MAKERPANEL GALLERY</p>
    <h1 id="gallery-title">Good ideas.<br>Ready to remix.</h1>
    <p>Find the piece that gets you started. Explore the designs, take the source files, and make something that’s yours.</p>
  </div>
  <a class="button button-dark" href="https://github.com/Ranch-Hand-Robotics/makerpanel/issues/new?template=submit-panel.yml">Share your design <span aria-hidden="true">↗</span></a>
</section>

<form class="gallery-toolbar" id="gallery-filters" aria-label="Filter panels" hidden>
  <label class="search-field"><span aria-hidden="true">⌕</span><input id="panel-search" type="search" name="q" aria-label="Search panels" placeholder="Search panels, ideas, components…" autocomplete="off"></label>
  <label for="panel-category">Category<select id="panel-category" name="category" aria-label="Category"><option value="">All categories</option></select></label>
  <label for="panel-sort">Sort by<select id="panel-sort" name="sort" aria-label="Sort by"><option value="title">Name: A–Z</option><option value="width">Width: smallest first</option></select></label>
</form>
<div class="gallery-summary"><span id="gallery-count" role="status" aria-live="polite">Opening the parts bin…</span><button class="clear-filters" id="clear-filters" type="button" hidden>Clear filters</button></div>
<div id="gallery-root" aria-busy="true"><p>Loading panel designs…</p></div>
<noscript><p>The searchable gallery needs JavaScript. You can still <a href="https://github.com/Ranch-Hand-Robotics/makerpanel/tree/main/examples">browse all panel designs and source files on GitHub</a>.</p></noscript>
<div class="gallery-contribute">Don’t see the panel you need? That might be your next project. <a href="create-panel.html">Make the missing piece ↗</a></div>
<script type="module" src="js/gallery.js"></script>