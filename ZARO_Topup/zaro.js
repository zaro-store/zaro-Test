
document.addEventListener("DOMContentLoaded", () => {

  // Mobile navigation
  const navbar = document.querySelector(".navbar");
  const navLinks = document.querySelector(".nav-links");

  if (navbar && navLinks) {
    const menuButton = document.createElement("button");

    menuButton.className = "mobile-menu-button";
    menuButton.type = "button";
    menuButton.textContent = "☰";
    menuButton.setAttribute("aria-label", "فتح القائمة");
    menuButton.setAttribute("aria-expanded", "false");

    navbar.insertBefore(menuButton, navLinks);

    menuButton.addEventListener("click", () => {
      const isOpen = navLinks.classList.toggle("menu-open");
      menuButton.textContent = isOpen ? "✕" : "☰";
      menuButton.setAttribute("aria-expanded", String(isOpen));
    });

    navLinks.querySelectorAll("a").forEach(link => {
      link.addEventListener("click", () => {
        navLinks.classList.remove("menu-open");
        menuButton.textContent = "☰";
        menuButton.setAttribute("aria-expanded", "false");
      });
    });
  }

  // Reveal elements on scroll
  const revealElements = document.querySelectorAll(
    ".game-card, .section-heading, .promo-content, .hero-content"
  );

  revealElements.forEach(element => {
    element.classList.add("reveal");
  });

  if ("IntersectionObserver" in window) {
    const observer = new IntersectionObserver(entries => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add("revealed");
          observer.unobserve(entry.target);
        }
      });
    }, {
      threshold: 0.12
    });

    revealElements.forEach(element => observer.observe(element));
  } else {
    revealElements.forEach(element => {
      element.classList.add("revealed");
    });
  }

  // Interactive game cards
  document.querySelectorAll(".game-card").forEach(card => {
    card.addEventListener("mouseenter", () => {
      card.style.setProperty("--hover-scale", "1");
    });

    card.addEventListener("mouseleave", () => {
      card.style.removeProperty("--hover-scale");
    });
  });

  // Current year
  document.querySelectorAll(".footer p").forEach(footer => {
    footer.textContent = footer.textContent.replace(
      /©\s*\d{4}/,
      `© ${new Date().getFullYear()}`
    );
  });

});
