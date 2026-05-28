document.addEventListener('DOMContentLoaded', () => {
  // --- NAV: scroll state + active link ---
  const nav = document.getElementById('nav');
  const navToggle = document.getElementById('navToggle');
  const navLinks = document.getElementById('navLinks');

  window.addEventListener('scroll', () => {
    nav.classList.toggle('scrolled', window.scrollY > 60);
    const sections = document.querySelectorAll('section[id]');
    let current = '';
    sections.forEach(s => {
      if (s.getBoundingClientRect().top <= 120) current = s.id;
    });
    navLinks.querySelectorAll('.nav__link').forEach(l => {
      l.classList.toggle('active', l.getAttribute('href') === `#${current}`);
    });
  }, { passive: true });

  // --- NAV: mobile toggle ---
  if (navToggle) {
    navToggle.addEventListener('click', () => {
      const open = navLinks.classList.toggle('open');
      navToggle.setAttribute('aria-expanded', open);
      document.body.style.overflow = open ? 'hidden' : '';
    });
  }

  document.addEventListener('keydown', e => {
    if (e.key === 'Escape' && navLinks.classList.contains('open')) {
      navLinks.classList.remove('open');
      navToggle.setAttribute('aria-expanded', 'false');
      document.body.style.overflow = '';
    }
  });

  navLinks.querySelectorAll('a').forEach(a => a.addEventListener('click', () => {
    navLinks.classList.remove('open');
    navToggle.setAttribute('aria-expanded', 'false');
    document.body.style.overflow = '';
  }));

  // --- SMOOTH SCROLL with nav offset ---
  document.querySelectorAll('a[href^="#"]').forEach(a => {
    a.addEventListener('click', e => {
      const target = document.querySelector(a.getAttribute('href'));
      if (target) {
        e.preventDefault();
        window.scrollTo({
          top: target.offsetTop - 80,
          behavior: 'smooth'
        });
      }
    });
  });

  // --- PAPER ACCORDION ---
  document.querySelectorAll('.paper-row').forEach(row => {
    const head = row.querySelector('.paper-row__head');
    const body = row.querySelector('.paper-row__body');
    function toggle() {
      const wasOpen = row.classList.contains('expanded');
      document.querySelectorAll('.paper-row').forEach(r => {
        r.classList.remove('expanded');
        r.querySelector('.paper-row__head').setAttribute('aria-expanded', 'false');
        r.querySelector('.paper-row__body').style.maxHeight = '0';
      });
      if (!wasOpen) {
        row.classList.add('expanded');
        head.setAttribute('aria-expanded', 'true');
        body.style.maxHeight = body.scrollHeight + 'px';
      }
    }
    if (head) {
      head.addEventListener('click', e => { if (!e.target.closest('a')) toggle(); });
      head.addEventListener('keydown', e => { if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); toggle(); } });
    }
  });

  // --- RESEARCH FILTER ---
  document.querySelectorAll('.filter-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      const field = btn.dataset.field;
      document.querySelectorAll('.research-card').forEach(card => {
        card.style.display = (field === 'all' || (card.dataset.fields || '').split(' ').includes(field)) ? '' : 'none';
      });
      document.querySelectorAll('.paper-row').forEach(row => {
        const show = field === 'all' || !row.dataset.field || row.dataset.field === field;
        row.classList.toggle('hidden', !show);
        if (!show) {
          row.classList.remove('expanded');
          row.querySelector('.paper-row__body').style.maxHeight = '0';
        }
      });
    });
  });

  // --- FOOTER YEAR ---
  const footerYear = document.getElementById('footerYear');
  if (footerYear) footerYear.textContent = new Date().getFullYear();

  // --- CONTACT FORM ---
  const form = document.getElementById('contactForm');
  const submitBtn = document.getElementById('formSubmit');
  if (form) {
    form.addEventListener('submit', e => {
      e.preventDefault();
      const originalText = submitBtn.textContent;
      submitBtn.textContent = 'Sending...';
      submitBtn.disabled = true;
      
      // Simulate network request
      setTimeout(() => {
        submitBtn.textContent = 'Sent';
        submitBtn.style.background = 'var(--slate)';
        
        setTimeout(() => {
          submitBtn.textContent = originalText;
          submitBtn.disabled = false;
          submitBtn.style.background = '';
          form.reset();
        }, 3000);
      }, 1000);
    });
  }

  // --- GSAP ANIMATIONS ---
  gsap.registerPlugin(ScrollTrigger, TextPlugin);

  // 0. HERO CINEMATIC SEQUENCE
  gsap.set('.hero__eyebrow',     { opacity: 0 });
  gsap.set('.hero__name',        { filter: 'blur(10px)', scale: 0.96, opacity: 0 });
  gsap.set('.hero__underline',   { scaleX: 0, opacity: 0 });
  gsap.set('.hero__fields',      { opacity: 0, y: 25 });
  gsap.set('.hero__desc',        { opacity: 0, y: 20 });
  gsap.set('.hero__pillars',     { opacity: 0, y: 20 });
  gsap.set('.hero__credentials', { opacity: 0 });
  gsap.set('.hero__socials',     { opacity: 0, y: 15 });
  gsap.set('.hero__stats',       { opacity: 0, y: 20 });
  gsap.set('.hero__stat-num',    { opacity: 0, y: 15 });

  const heroTL = gsap.timeline({ delay: 1 });
  heroTL
    .to('.hero__eyebrow',     { opacity: 1, duration: 1.2, ease: 'power2.out' }, 0)
    .to('.hero__name',        { opacity: 1, filter: 'blur(0px)', scale: 1, duration: 1.6, ease: 'power2.out' }, 0.8)
    .to('.hero__underline',   { opacity: 1, scaleX: 1, duration: 0.9, ease: 'power2.inOut' }, 2.2)
    .to('.hero__fields',      { opacity: 1, y: 0, duration: 0.9, ease: 'power3.out', stagger: 0.25 }, 2.8)
    .to('.hero__desc',        { opacity: 1, y: 0, duration: 0.9, ease: 'power2.out' }, 3.5)
    .to('.hero__pillars',     { opacity: 1, y: 0, duration: 0.9, ease: 'power3.out' }, 4.1)
    .to('.hero__credentials', { opacity: 1, duration: 0.7, ease: 'power2.out' }, 4.7)
    .to('.hero__socials',     { opacity: 1, y: 0, duration: 0.7, ease: 'power2.out' }, 4.9)
    .to('.hero__stats',       { opacity: 1, y: 0, duration: 0.8, ease: 'power2.out' }, 5.1)
    .to('.hero__stat-num',    { opacity: 1, y: 0, duration: 0.7, ease: 'power3.out', stagger: 0.15 }, 5.4);

  // Video parallax on scroll
  gsap.to('.hero__bg video', {
    yPercent: 12, ease: 'none',
    scrollTrigger: { trigger: '#hero', start: 'top top', end: 'bottom top', scrub: true }
  });

  // Hero content fades out on scroll
  gsap.to('.hero__content', {
    opacity: 0, y: -40, ease: 'none',
    scrollTrigger: { trigger: '#hero', start: '55% top', end: 'bottom top', scrub: true }
  });


  // 2. PHYSICS DROP + TITLE GLOW
  // Scoped strictly to cards INSIDE .research__areas to avoid hiding foundation cards
  gsap.set(".research__areas .research-card", { opacity: 0, y: -250 });

  const researchTL = gsap.timeline({
    scrollTrigger: {
      trigger: ".research__areas",
      start: "top 85%",
      toggleActions: "play reverse play reverse",
    }
  });

  gsap.utils.toArray(".research__areas .research-card").forEach((card, i) => {
    const title = card.querySelector(".research-card__title");
    
    // Drop the card
    researchTL.fromTo(card, 
      { y: -250, opacity: 0 },
      {
        y: 0,
        opacity: 1,
        duration: 1.0, // Restored longer duration for the bounce to settle
        ease: "bounce.out", // REBOUND IS BACK
        stagger: 0.6
      }, 
      i * 0.6 // Consistent sequential timing
    );

    // Pulse the title glow exactly when the card first hits the 'floor'
    researchTL.to(title, {
      color: "var(--gold)",
      textShadow: "0 0 20px rgba(184,132,26,0.8)",
      duration: 0.3,
      yoyo: true,
      repeat: 1,
      ease: "power2.out"
    }, ">-0.4"); // Adjusted trigger to hit during the first contact
  });

  // 2. MARGIN REVEAL ANIMATION (EDITORIAL LOOK)
  gsap.utils.toArray(".pub-item:not(.reports-item):not(.journal-list .pub-item):not(.awards-list .pub-item):not(.media-list .pub-item):not(.conference-list .pub-item):not(.talks-list .pub-item)").forEach((item) => {
    const year = item.querySelector(".pub-item__year");
    const content = item.querySelector("div");
    const title = item.querySelector(".pub-item__title");
    
    const tl = gsap.timeline({
      scrollTrigger: {
        trigger: item,
        start: "top 95%",
        toggleActions: "play none none reverse"
      }
    });

    // Prepare the content for the right-side slide
    gsap.set(content, { x: 40, opacity: 0 });

    tl.to(item, { opacity: 1, duration: 0.1 })
      .to(year, { 
        opacity: 1, 
        x: 0, 
        duration: 0.8, 
        ease: "back.out(1.7)" 
      }, "start")
      .to(content, {
        opacity: 1,
        x: 0,
        duration: 0.8,
        ease: "power2.out"
      }, "start+=0.1")
      .to(title, {
        color: "#B8841A",
        textShadow: "0 0 12px rgba(184,132,26,0.5)",
        duration: 0.4,
        ease: "power2.out"
      }, "start")
      .to(title, {
        color: "var(--ink)",
        textShadow: "0 0 0px rgba(184,132,26,0)",
        duration: 0.6,
        ease: "power2.in"
      }, "+=0.2");
  });

  // 3. SPECIAL REPORTS ANIMATION (LINE & NODES)
  const reportsList = document.querySelector("#reports-list");
  if (reportsList) {
    const line = reportsList.querySelector("#reports-line");
    const items = reportsList.querySelectorAll(".reports-item");
    
    // The line draws down as you scroll through the section
    gsap.to(line, {
      scaleY: 1,
      ease: "none",
      scrollTrigger: {
        trigger: reportsList,
        start: "top 75%",
        end: "bottom 85%",
        scrub: true
      }
    });

    // Set initial states
    items.forEach((item) => {
      const year = item.querySelector(".pub-item__year");
      const content = item.querySelector("div:not(.pub-node)");
      const node = item.querySelector(".pub-node");
      gsap.set(year, { x: -40, opacity: 0 });
      gsap.set(content, { x: 40, opacity: 0 });
      gsap.set(node, { scale: 0, opacity: 0 });
      gsap.set(item, { opacity: 0 });
    });

    // Animate in chunks of 4 — each chunk fires when its first item enters view
    const chunkSize = 4;
    for (let c = 0; c < items.length; c += chunkSize) {
      const chunk = Array.from(items).slice(c, c + chunkSize);
      gsap.timeline({
        scrollTrigger: {
          trigger: chunk[0],
          start: "top 82%",
          toggleActions: "play none none reverse"
        }
      }).add(() => {
        chunk.forEach((item, j) => {
          const year = item.querySelector(".pub-item__year");
          const content = item.querySelector("div:not(.pub-node)");
          const title = item.querySelector(".pub-item__title");
          const node = item.querySelector(".pub-node");
          gsap.timeline({ delay: j * 0.06 })
            .to(item, { opacity: 1, duration: 0.1 }, "start")
            .to(node, { scale: 1, opacity: 1, duration: 0.3, ease: "back.out(2)" }, "start")
            .add(() => node.classList.add("glow"), "-=0.1")
            .to(year, { opacity: 1, x: 0, duration: 0.5, ease: "power2.out" }, "-=0.1")
            .to(content, { opacity: 1, x: 0, duration: 0.5, ease: "power2.out" }, "-=0.5")
            .to(title, { color: "#B8841A", textShadow: "0 0 15px rgba(184,132,26,0.6)", duration: 0.25 }, "-=0.25")
            .to(title, { color: "var(--ink)", textShadow: "0 0 0px rgba(184,132,26,0)", duration: 0.35 }, "+=0.1")
            .add(() => node.classList.remove("glow"), "-=0.2");
        });
      });
    }
  }

  // 4. ARCHIVAL LEDGER (JOURNAL PAPERS)
  const journalItems = gsap.utils.toArray(".journal-list .pub-item");
  // Set initial states
  journalItems.forEach((item) => {
    const scanner = document.createElement("div");
    scanner.className = "scanner-line";
    item.appendChild(scanner);
    gsap.set(item, { opacity: 0, x: -10, filter: "blur(4px)" });
    const year = item.querySelector(".pub-item__year");
    const content = item.querySelector("div");
    if (year) gsap.set(year, { opacity: 0, x: -10 });
    if (content) gsap.set(content, { clipPath: "inset(0 100% 0 0)" });
  });

  // Animate in chunks of 4
  const journalList = document.querySelector(".journal-list");
  if (journalList) {
    const chunkSize = 4;
    for (let c = 0; c < journalItems.length; c += chunkSize) {
      const chunk = journalItems.slice(c, c + chunkSize);
      gsap.timeline({
        scrollTrigger: {
          trigger: chunk[0],
          start: "top 82%",
          toggleActions: "play none none reverse"
        }
      }).add(() => {
        chunk.forEach((item, j) => {
          const scanner = item.querySelector(".scanner-line");
          const content = item.querySelector("div");
          const year = item.querySelector(".pub-item__year");
          gsap.timeline({ delay: j * 0.07 })
            .to(item, { opacity: 1, x: 0, filter: "blur(0px)", duration: 0.35 })
            .to(scanner, { opacity: 1, duration: 0.1 }, "scan")
            .to(scanner, { left: "100%", duration: 0.6, ease: "power3.inOut" }, "scan")
            .to(content, { clipPath: "inset(0 0% 0 0)", duration: 0.6, ease: "power3.inOut" }, "scan")
            .to(year, { opacity: 1, x: 0, duration: 0.4, ease: "back.out(1.4)" }, "scan+=0.05")
            .add(() => item.classList.add("revealed"), "scan+=0.25")
            .to(scanner, { opacity: 0, duration: 0.2 }, "scan+=0.5");
        });
      });
    }
  }

  // 5. MEDALLION IMPACT (AWARDS)
  const awardsItems = gsap.utils.toArray(".awards-list .pub-item");
  awardsItems.forEach((item) => {
    const medallion = document.createElement("div");
    medallion.className = "medallion";
    item.appendChild(medallion);
    const ripple = document.createElement("div");
    ripple.className = "impact-ripple";
    item.appendChild(ripple);
    const content = item.querySelector("div");
    const year = item.querySelector(".pub-item__year");
    gsap.set(item, { opacity: 0 });
    gsap.set(content, { opacity: 0, x: 20 });
    gsap.set(year, { opacity: 0, x: -20 });
  });

  // Animate in chunks of 4
  const awardsList = document.querySelector(".awards-list");
  if (awardsList) {
    const chunkSize = 4;
    for (let c = 0; c < awardsItems.length; c += chunkSize) {
      const chunk = awardsItems.slice(c, c + chunkSize);
      gsap.timeline({
        scrollTrigger: {
          trigger: chunk[0],
          start: "top 82%",
          toggleActions: "play none none reverse"
        }
      }).add(() => {
        chunk.forEach((item, j) => {
          const medallion = item.querySelector(".medallion");
          const ripple = item.querySelector(".impact-ripple");
          const content = item.querySelector("div");
          const year = item.querySelector(".pub-item__year");
          gsap.timeline({ delay: j * 0.08 })
            .to(item, { opacity: 1, duration: 0.1 })
            .fromTo(medallion, { y: -80, opacity: 0 }, { y: 0, opacity: 1, duration: 0.4, ease: "bounce.out" })
            .fromTo(ripple, { scale: 1, opacity: 1 }, { scale: 5, opacity: 0, duration: 0.5, ease: "power2.out" }, "-=0.25")
            .to(year, { opacity: 1, x: 0, duration: 0.3, ease: "back.out(1.7)" }, "-=0.4")
            .to(content, { opacity: 1, x: 0, duration: 0.35, ease: "power2.out" }, "-=0.35");
        });
      });
    }
  }

  // 6. FEATURED PROJECT: COUNTER-FLOW REVEAL
  const stateStory = document.querySelector("#state-story");
  if (stateStory) {
    const leftSide = stateStory.querySelector(".state-story-left");
    const rightSide = stateStory.querySelector(".state-story-card");
    
    const projectTL = gsap.timeline({
      scrollTrigger: {
        trigger: stateStory,
        start: "top 75%",
        toggleActions: "play none none reverse"
      }
    });

    // LEFT: Descending Reveal (Top-Down)
    projectTL.from(leftSide.querySelectorAll("h2, p, div"), {
      y: -60,
      opacity: 0,
      duration: 1,
      stagger: 0.2,
      ease: "power3.out"
    }, "start");

    // RIGHT: Ascending Reveal (Bottom-Up)
    projectTL.from(rightSide, {
      y: 100,
      opacity: 0,
      duration: 1.2,
      ease: "power3.out"
    }, "start");

    // Inner Card Details: Delayed Fade-In
    projectTL.from(rightSide.querySelectorAll(".practice__sub-title, .expect-list li, .tag--dark"), {
      opacity: 0,
      x: 20,
      stagger: 0.1,
      duration: 0.6,
      ease: "power2.out"
    }, "start+=0.8");
  }

  // 7. NEWS TICKER (MEDIA ARTICLES)
  const mediaItems = gsap.utils.toArray(".media-list .pub-item");
  const mediaData = mediaItems.map((item) => {
    const year = item.querySelector(".pub-item__year");
    const title = item.querySelector(".pub-item__title");
    const meta = item.querySelector(".pub-item__meta");
    const textTarget = title.querySelector('a') || title;
    const originalText = textTarget.textContent;
    title.style.minHeight = title.offsetHeight + "px";
    textTarget.textContent = "";
    gsap.set(item, { opacity: 0, x: -10 });
    gsap.set(year, { opacity: 0, x: -10 });
    gsap.set(meta, { opacity: 0 });
    return { item, year, meta, textTarget, originalText };
  });

  // Animate in chunks of 4
  const mediaList = document.querySelector(".media-list");
  if (mediaList) {
    const chunkSize = 4;
    for (let c = 0; c < mediaData.length; c += chunkSize) {
      const chunk = mediaData.slice(c, c + chunkSize);
      gsap.timeline({
        scrollTrigger: {
          trigger: chunk[0].item,
          start: "top 82%",
          toggleActions: "play none none reverse"
        }
      }).add(() => {
        chunk.forEach(({ item, year, meta, textTarget, originalText }, j) => {
          const typeDuration = Math.min(originalText.length * 0.01, 0.7);
          gsap.timeline({ delay: j * 0.06 })
            .to(item, { opacity: 1, x: 0, duration: 0.1 })
            .to(year, { opacity: 1, x: 0, duration: 0.3 }, "start")
            .to(textTarget, {
              text: { value: originalText },
              duration: typeDuration,
              ease: "none",
              onStart: () => item.classList.add("typing"),
              onComplete: () => { gsap.delayedCall(0.4, () => item.classList.remove("typing")); }
            }, "start+=0.1")
            .to(meta, { opacity: 1, duration: 0.3 }, ">-0.1");
        });
      });
    }
  }

  // 8. COURSES & PEDAGOGY: LIQUID EDGE & NODE ANIMATION
  gsap.utils.toArray(".course-card").forEach((card) => {
    // 1. Inject SVG for Liquid Border
    const svgHTML = `
      <svg class="liquid-border" width="100%" height="100%" xmlns="http://www.w3.org/2000/svg">
        <rect x="0" y="0" width="100%" height="100%" rx="10" ry="10" />
      </svg>
    `;
    card.insertAdjacentHTML('afterbegin', svgHTML);

    // 2. Inject Icon & Node Header
    const iconHeaderHTML = `
      <div class="course-icon-header">
        <div class="course-node"></div>
        <svg class="course-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
          <path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20"></path>
        </svg>
      </div>
    `;
    card.insertAdjacentHTML('afterbegin', iconHeaderHTML);

    // 3. GSAP Entrance Animation (Content only)
    const contentElements = card.querySelectorAll(".course-icon-header, .course-card__title, .course-card__desc, .course-card__tags");
    
    gsap.timeline({
      scrollTrigger: {
        trigger: card,
        start: "top 85%",
        toggleActions: "play none none reverse"
      }
    })
    .from(contentElements, {
      opacity: 0,
      y: 10,
      stagger: 0.15,
      duration: 0.8,
      ease: "power2.out"
    });
  });

  // 9. CONFERENCE TIMELINE (LINE & NODES)
  const conferenceList = document.querySelector("#conference-list");
  if (conferenceList) {
    const line = conferenceList.querySelector("#conference-line");
    const items = conferenceList.querySelectorAll(".conference-item");
    
    // The line draws down as you scroll through the section
    gsap.to(line, {
      scaleY: 1,
      ease: "none",
      scrollTrigger: {
        trigger: conferenceList,
        start: "top 80%",
        end: "bottom 85%",
        scrub: true
      }
    });

    // Set initial states
    items.forEach((item) => {
      const year = item.querySelector(".pub-item__year");
      const content = item.querySelector("div:not(.pub-node)");
      const node = item.querySelector(".pub-node");
      gsap.set(year, { y: -60, opacity: 0 });
      gsap.set(content, { x: 20, opacity: 0 });
      gsap.set(node, { scale: 0, opacity: 0 });
      gsap.set(item, { opacity: 0 });
    });

    // Animate in chunks of 4
    const chunkSize = 4;
    for (let c = 0; c < items.length; c += chunkSize) {
      const chunk = Array.from(items).slice(c, c + chunkSize);
      gsap.timeline({
        scrollTrigger: {
          trigger: chunk[0],
          start: "top 82%",
          toggleActions: "play none none reverse"
        }
      }).add(() => {
        chunk.forEach((item, j) => {
          const year = item.querySelector(".pub-item__year");
          const content = item.querySelector("div:not(.pub-node)");
          const node = item.querySelector(".pub-node");
          gsap.timeline({ delay: j * 0.07 })
            .to(item, { opacity: 1, duration: 0.1 }, "start")
            .to(node, { scale: 1, opacity: 1, duration: 0.3, ease: "back.out(2)" }, "start")
            .add(() => node.classList.add("glow"), "-=0.1")
            .to(year, { opacity: 1, y: 0, duration: 0.5, ease: "bounce.out" }, "-=0.2")
            .to(content, { opacity: 1, x: 0, duration: 0.5, ease: "power2.out" }, "-=0.5")
            .add(() => node.classList.remove("glow"), "-=0.2");
        });
      });
    }
  }

  // 10. SPOTLIGHT FOCUS (SELECTED TALKS)
  const talksItems = gsap.utils.toArray(".talks-list .pub-item");
  talksItems.forEach((item) => {
    const year = item.querySelector(".pub-item__year");
    gsap.set(item, { opacity: 0, scale: 0.97, filter: "blur(6px)" });
    if (year) gsap.set(year, { opacity: 0, x: -10 });
  });

  // Animate in chunks of 4
  const talksList = document.querySelector(".talks-list");
  if (talksList) {
    const chunkSize = 4;
    for (let c = 0; c < talksItems.length; c += chunkSize) {
      const chunk = talksItems.slice(c, c + chunkSize);
      gsap.timeline({
        scrollTrigger: {
          trigger: chunk[0],
          start: "top 82%",
          toggleActions: "play none none reverse"
        }
      }).add(() => {
        chunk.forEach((item, j) => {
          const year = item.querySelector(".pub-item__year");
          gsap.timeline({ delay: j * 0.07 })
            .to(item, { opacity: 1, scale: 1, filter: "blur(0px)", duration: 0.55, ease: "power2.out" })
            .to(year, { opacity: 1, x: 0, duration: 0.35 }, "-=0.4")
            .add(() => item.classList.add("focused"), "-=0.3")
            .to({}, { duration: 0.4 })
            .add(() => {});
        });
      });
    }
  }

  // 11. TIMELINE ANIMATIONS
  
  // A. MOVING NODE ANIMATION (PROFESSIONAL EXPERIENCE ONLY)
  const expTimeline = document.querySelector(".exp-timeline");
  if (expTimeline) {
    const line = expTimeline.querySelector(".timeline__line");
    const node = document.getElementById("moving-node");
    const items = expTimeline.querySelectorAll(".timeline__item");
    if (!node || !line || items.length === 0) return;
    


    // 1. Move the Node along the line with Scrub
    let activeItemRef = null;
    const tlRect = expTimeline.getBoundingClientRect();
    
    // We calculate midY relative to the STARTING top of the node (72px from tl top)
    const itemCache = Array.from(items).map(item => {
      const role = item.querySelector(".timeline__role");
      if (!role) return null;
      const roleRect = role.getBoundingClientRect();
      
      return {
        el: item,
        role: role,
        dot: item.querySelector(".timeline__dot"),
        midY: (roleRect.top + roleRect.height / 2) - (tlRect.top + 72)
      };
    }).filter(Boolean);

    gsap.to(node, {
      y: () => line.offsetHeight,
      ease: "none",
      scrollTrigger: {
        trigger: expTimeline,
        start: "top 75%", 
        end: "bottom 75%",
        scrub: 0.2,
        onUpdate: (self) => {
          gsap.set(node, { opacity: self.progress > 0 && self.progress < 1 ? 1 : 0 });
          
          // Sync Highlight: Find the nearest item based on node's current Y
          const nodeY = gsap.getProperty(node, "y");
          let nearest = null;
          let minDistance = Infinity;

          itemCache.forEach(cache => {
            const dist = Math.abs(nodeY - cache.midY);
            if (dist < minDistance) {
              minDistance = dist;
              nearest = cache;
            }
          });

          if (nearest && nearest.el !== activeItemRef) {
            // Deactivate previous
            if (activeItemRef) {
              const prev = itemCache.find(c => c.el === activeItemRef);
              if (prev) {
                prev.role.classList.remove("is-active");
                if (prev.dot) prev.dot.classList.remove("active");
              }
            }
            // Activate new
            nearest.role.classList.add("is-active");
            if (nearest.dot) nearest.dot.classList.add("active");
            activeItemRef = nearest.el;
          }
        }
      }
    });

    // 2. Draw the line (Keep this separate for the scaleY animation)
    gsap.to(line, {
      scaleY: 1,
      ease: "none",
      scrollTrigger: {
        trigger: expTimeline,
        start: "top 75%",
        end: "bottom 75%",
        scrub: 0.2
      }
    });
  }

  // B. ORIGINAL SIGNAL FLOW (FOR EDUCATION & OTHER NON-OUTREACH, NON-EXP TIMELINES)
  document.querySelectorAll(".timeline:not(.exp-timeline):not(.outreach-timeline)").forEach((timeline) => {
    const line = timeline.querySelector(".timeline__line");
    const items = timeline.querySelectorAll(".timeline__item");
    
    gsap.to(line, {
      scaleY: 1,
      ease: "none",
      scrollTrigger: {
        trigger: timeline,
        start: "top 75%",
        end: "bottom 85%",
        scrub: true
      }
    });

    items.forEach((item) => {
      const dot = item.querySelector(".timeline__dot");
      const period = item.querySelector(".timeline__period");
      const role = item.querySelector(".timeline__role");
      const org = item.querySelector(".timeline__org");
      const desc = item.querySelector(".timeline__desc");

      const itemTL = gsap.timeline({
        scrollTrigger: {
          trigger: item,
          start: "top 70%",
          toggleActions: "play none none reverse"
        }
      });

      itemTL.from(item, { opacity: 0, duration: 0.1 })
            .from(dot, { scale: 0, opacity: 0, duration: 0.5, ease: "back.out(2)" }, "start")
            .add(() => {
              item.classList.add("active");
            }, "start")
            .from(period, { opacity: 0, x: -20, duration: 0.5 }, "start+=0.1")
            .from(role, { opacity: 0, scaleX: 0.5, duration: 0.6, ease: "power2.out" }, "start+=0.2")
            .from([org, desc].filter(el => el !== null), { opacity: 0, y: 10, stagger: 0.1, duration: 0.5 }, "start+=0.3");
    });
  });

  // 12. OUTREACH TIMELINES (STEPPED SCRUB WITH CLEAN UNDERLINES)
  gsap.utils.toArray(".outreach-timeline").forEach((timeline) => {
    const line = timeline.querySelector(".timeline__line");
    const items = timeline.querySelectorAll(".timeline__item");
    
    const masterTL = gsap.timeline({
      scrollTrigger: {
        trigger: timeline,
        start: "top 70%",
        end: "bottom 80%",
        scrub: 1
      }
    });

    items.forEach((item, index) => {
      const dot = item.querySelector(".timeline__dot");
      const role = item.querySelector(".timeline__role");
      const growTo = (index + 1) / items.length;

      // 1. Grow line precisely to the node
      masterTL.to(line, { 
        scaleY: growTo, 
        duration: 1.2, 
        ease: "power2.inOut" 
      });

      // 2. Trigger Node Glow and Sharp Underline simultaneously
      masterTL.to(dot, { 
        "--dot-glow": 1, 
        "--dot-scale": 1.3, 
        duration: 0.5,
        ease: "back.out(1.5)"
      }, ">-0.1");

      masterTL.to(role, { 
        "--underline-scale": 1,
        "--role-color": "var(--gold)",
        duration: 0.8,
        ease: "power3.out"
      }, "<");
      
      // 3. Pause briefly
      masterTL.to({}, { duration: 0.3 });
    });
  });

  // 13. BLUEPRINT ROLL-OUT (EDUCATION)
  gsap.utils.toArray(".edu-card").forEach((card, i) => {
    const elements = card.children;
    
    gsap.set(card, { 
      clipPath: "inset(0 0 100% 0)",
      opacity: 0,
      y: 20
    });

    const tl = gsap.timeline({
      scrollTrigger: {
        trigger: card,
        start: "top 85%",
        toggleActions: "play none none reverse"
      }
    });

    tl.to(card, {
      clipPath: "inset(0 0 0% 0)",
      opacity: 1,
      y: 0,
      duration: 1.2,
      ease: "power3.inOut"
    })
    .from(elements, {
      opacity: 0,
      x: -10,
      stagger: 0.1,
      duration: 0.5,
      ease: "power2.out"
    }, "-=0.6");
  }); // closes .edu-card forEach

  // 14. RESEARCH GRANTS (STAGGERED LIST)
  gsap.from(".grant-card", {
    scrollTrigger: {
      trigger: ".grants-grid",
      start: "top 90%",
      toggleActions: "play none none reverse"
    },
    opacity: 0,
    y: 30,
    stagger: 0.2,
    duration: 0.8,
    ease: "power2.out"
  });

  // 15. FOUNDATION RESEARCH CARDS — each card triggers itself
  gsap.utils.toArray(".foundation-card").forEach((card, i) => {
    gsap.fromTo(card,
      { opacity: 0, y: 30 },
      {
        opacity: 1,
        y: 0,
        duration: 0.8,
        delay: i * 0.12,
        ease: "power2.out",
        scrollTrigger: {
          trigger: card,
          start: "top 92%",
          toggleActions: "play none none reverse"
        }
      }
    );
  });

}); // closes DOMContentLoaded
