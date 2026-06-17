// Collapse / Expand All toggle for argument and example sections
document.addEventListener('DOMContentLoaded', function () {
  document.querySelectorAll('.collapse-btn').forEach(function (btn) {
    btn.addEventListener('click', function () {
      var section = btn.closest('.arg-section, .example-section');
      var items   = section.querySelectorAll('details.arg-item, details.example-item');
      var anyOpen = Array.from(items).some(function (d) { return d.open; });
      items.forEach(function (d) { d.open = !anyOpen; });
      btn.textContent = anyOpen ? 'Expand All' : 'Collapse All';
    });
  });
});
