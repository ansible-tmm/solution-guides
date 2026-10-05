(function () {
  var EXCLUDED_CLASSES = ['header-logo', 'footer-logo', 'card-partner-logo', 'guide-vendor-logo', 'guide-tool-logo', 'guide-hero-callout__icon', 'guide-hero-partner__partner', 'guide-aiops-circle', 'guide-how-work-starts', 'guide-closing-logo'];
  var overlay = null;
  var overlayImg = null;
  var closeBtn = null;
  var lastFocused = null;

  function shouldEnhance(img) {
    if (!img.closest('section')) return false;
    if (img.closest('.cards-layout')) return false;
    if (img.id === 'konami-easter-egg') return false;

    for (var i = 0; i < EXCLUDED_CLASSES.length; i++) {
      if (img.classList.contains(EXCLUDED_CLASSES[i])) return false;
    }

    var src = img.getAttribute('src') || '';
    if (src.indexOf('twemoji') !== -1) return false;
    if (/\.svg(\?|#|$)/i.test(src)) return false;

    var widthAttr = parseInt(img.getAttribute('width'), 10);
    if (!isNaN(widthAttr) && widthAttr <= 280) return false;

    return true;
  }

  function getOverlay() {
    if (overlay) return overlay;

    overlay = document.createElement('div');
    overlay.className = 'image-lightbox';
    overlay.setAttribute('role', 'dialog');
    overlay.setAttribute('aria-modal', 'true');
    overlay.setAttribute('aria-hidden', 'true');
    overlay.setAttribute('aria-label', 'Full size image');

    closeBtn = document.createElement('button');
    closeBtn.type = 'button';
    closeBtn.className = 'image-lightbox__close';
    closeBtn.setAttribute('aria-label', 'Close full size image');
    closeBtn.innerHTML = '<i class="fas fa-times" aria-hidden="true"></i>';

    overlayImg = document.createElement('img');
    overlayImg.className = 'image-lightbox__img';
    overlayImg.alt = '';

    overlay.appendChild(overlayImg);
    overlay.appendChild(closeBtn);
    document.body.appendChild(overlay);

    closeBtn.addEventListener('click', closeLightbox);
    overlay.addEventListener('click', function (e) {
      if (e.target === overlay) closeLightbox();
    });
    overlayImg.addEventListener('click', closeLightbox);
    document.addEventListener('keydown', onKeyDown);

    return overlay;
  }

  function onKeyDown(e) {
    if (!overlay || !overlay.classList.contains('image-lightbox--open')) return;

    if (e.key === 'Escape') {
      e.preventDefault();
      closeLightbox();
      return;
    }

    if (e.key === 'Tab') {
      var focusable = [closeBtn, overlayImg].filter(function (el) {
        return el && !el.disabled;
      });
      if (focusable.length === 0) return;

      var first = focusable[0];
      var last = focusable[focusable.length - 1];

      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    }
  }

  function openLightbox(img) {
    var box = getOverlay();
    lastFocused = img;

    overlayImg.src = img.currentSrc || img.src;
    overlayImg.alt = img.alt || '';

    box.setAttribute('aria-label', img.alt ? 'Full size image: ' + img.alt : 'Full size image');
    box.setAttribute('aria-hidden', 'false');
    box.classList.add('image-lightbox--open');
    document.body.classList.add('image-lightbox-open');
    closeBtn.focus();
  }

  function closeLightbox() {
    if (!overlay) return;

    overlay.classList.remove('image-lightbox--open');
    overlay.setAttribute('aria-hidden', 'true');
    document.body.classList.remove('image-lightbox-open');
    overlayImg.removeAttribute('src');

    if (lastFocused && typeof lastFocused.focus === 'function') {
      lastFocused.focus();
    }
    lastFocused = null;
  }

  function enhanceImage(img) {
    if (img.classList.contains('guide-image')) return;

    img.classList.add('guide-image');
    img.setAttribute('tabindex', '0');
    img.setAttribute('role', 'button');

    var label = img.alt ? 'View full size: ' + img.alt : 'View full size image';
    img.setAttribute('aria-label', label);

    img.addEventListener('click', function () {
      openLightbox(img);
    });

    img.addEventListener('keydown', function (e) {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        openLightbox(img);
      }
    });
  }

  function init() {
    document.querySelectorAll('section img').forEach(function (img) {
      if (shouldEnhance(img)) enhanceImage(img);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
