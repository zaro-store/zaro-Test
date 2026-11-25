
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

  // Platform-wide maintenance mode, controlled from the admin dashboard.
  import("https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm")
    .then(async ({ createClient }) => {
      const client = createClient("https://rtqdcbkttrxbmglzllmv.supabase.co", "sb_publishable_iqwtKiJMmx9QEO4l1Zo7iQ_kHvZZH0c");
      const { data, error } = await client.from("app_settings").select("setting_value").eq("setting_key", "maintenance_mode").maybeSingle();
      if (error || data?.setting_value !== true) return;
      const overlay = document.createElement("main");
      overlay.setAttribute("role", "alert");
      overlay.style.cssText = "position:fixed;inset:0;z-index:999999;background:#080808;color:#fff;display:grid;place-content:center;text-align:center;padding:28px;font-family:Cairo,sans-serif";
      overlay.innerHTML = '<div style="color:#ff7900;font-size:34px;font-weight:900;letter-spacing:3px">ZARO.</div><h1 style="color:#ffc400">نرجعلك قريب</h1><p style="max-width:440px;line-height:2;color:#ddd">المتجر تحت الصيانة حاليًا لتحسين الخدمة. حاول مرة تانية بعد قليل.</p>';
      document.body.appendChild(overlay);
    })
    .catch(error => console.warn("ZARO platform settings unavailable", error));

  // Current year
  document.querySelectorAll(".footer p").forEach(footer => {
    footer.textContent = footer.textContent.replace(
      /©\s*\d{4}/,
      `© ${new Date().getFullYear()}`
    );
  });

});
