let currentMode = "freeroam";
let stats = {};
let lbData = { all: [], daily: [], weekly: [] };
let collectState = { list: [], owned: {} };
let currentLb = "all";

const backdrop = document.getElementById("tot-backdrop");
const wrapper = document.getElementById("tot-wrapper");
const navItems = document.querySelectorAll(".nav-item");
const modeCards = document.querySelectorAll(".mode-card");
const selectedModeSpan = document.getElementById("selected-mode");

const avatarImg = document.getElementById("avatar-img");
const avatarInput = document.getElementById("avatar-url");
const avatarBtn = document.getElementById("btnAvatarSave");

const lbBody = document.getElementById("lb-body");
const collectList = document.getElementById("collect-list");

const hdrLevel = document.getElementById("hdr-level");
const hdrXp    = document.getElementById("hdr-xp");
const hdrMoney = document.getElementById("hdr-money");

const statLevel = document.getElementById("stat-level");
const statXp    = document.getElementById("stat-xp");
const statDriftTotal = document.getElementById("stat-drift-total");
const statCollectCount = document.getElementById("stat-collect-count");
const statKD    = document.getElementById("stat-kd");

const statDrift        = document.getElementById("stat-drift");
const statDriftDaily   = document.getElementById("stat-drift-daily");
const statDriftWeekly  = document.getElementById("stat-drift-weekly");
const statMoney        = document.getElementById("stat-money");
const statPvpKills     = document.getElementById("stat-pvp-kills");
const statPvpDeaths    = document.getElementById("stat-pvp-deaths");
const statPvpKD        = document.getElementById("stat-pvp-kd");

const resourceName = typeof GetParentResourceName === "function"
    ? GetParentResourceName()
    : "tot_combined";

function setVisible(visible) {
    if (visible) {
        wrapper.classList.remove("hidden");
        backdrop.classList.remove("hidden");
        wrapper.classList.add("visible");
        backdrop.classList.add("visible");
    } else {
        wrapper.classList.remove("visible");
        backdrop.classList.remove("visible");
        setTimeout(() => {
            wrapper.classList.add("hidden");
            backdrop.classList.add("hidden");
        }, 150);
    }
}

function highlightCurrentMode() {
    modeCards.forEach(c => {
        if (c.dataset.mode === currentMode) c.classList.add("active");
        else c.classList.remove("active");
    });

    const card = document.querySelector(`.mode-card[data-mode="${currentMode}"]`);
    selectedModeSpan.textContent = card
        ? card.querySelector(".mode-title").textContent
        : currentMode;
}

function updateStatsUI() {
    const money = stats.money || 0;

    hdrLevel.textContent = stats.level || 1;
    hdrXp.textContent    = stats.xp || 0;
    hdrMoney.textContent = `${money.toLocaleString("tr-TR")} ₺`;

    statLevel.textContent = stats.level || 1;
    statXp.textContent    = stats.xp || 0;
    statDriftTotal.textContent = stats.drift_total || 0;
    statDrift.textContent      = stats.drift_total || 0;
    statDriftDaily.textContent = stats.drift_daily || 0;
    statDriftWeekly.textContent = stats.drift_weekly || 0;
    statMoney.textContent = money.toLocaleString("tr-TR");

    const k = stats.pvp_kills || 0;
    const d = stats.pvp_deaths || 0;
    const kdText = `${k} / ${d}`;
    statKD.textContent        = kdText;
    statPvpKills.textContent  = k;
    statPvpDeaths.textContent = d;
    statPvpKD.textContent     = d === 0 ? (k > 0 ? k.toFixed(2) : "0") : (k / d).toFixed(2);

    if (avatarImg && stats.avatar_url) {
        avatarImg.src = stats.avatar_url;
    } else if (avatarImg && !stats.avatar_url) {
        avatarImg.src = "https://i.imgur.com/3WZ5Q3E.png"; // default
    }

    // koleksiyon sayısı
    if (collectState.owned) {
        statCollectCount.textContent = Object.keys(collectState.owned).length;
    } else {
        statCollectCount.textContent = 0;
    }
}

function renderLeaderboard() {
    if (!lbBody) return;

    lbBody.innerHTML = "";
    const list = lbData[currentLb] || [];

    list.forEach((row, idx) => {
        const tr = document.createElement("tr");
        tr.innerHTML = `
            <td>${idx + 1}</td>
            <td>${row.name || "Bilinmiyor"}</td>
            <td>${row.level || 1}</td>
            <td>${row.score || 0}</td>
        `;
        lbBody.appendChild(tr);
    });
}

function renderCollectibles() {
    if (!collectList) return;
    collectList.innerHTML = "";
    let ownedCount = 0;

    (collectState.list || []).forEach(c => {
        const li = document.createElement("li");
        const owned = collectState.owned && collectState.owned[c.id];

        if (owned) {
            ownedCount++;
            li.classList.add("owned");
            li.textContent = `${c.id}. ${c.label} ✓`;
        } else {
            li.textContent = `${c.id}. ${c.label}`;
        }
        collectList.appendChild(li);
    });

    statCollectCount.textContent = ownedCount;
}

// NAV sekmeleri
navItems.forEach(btn => {
    btn.addEventListener("click", () => {
        navItems.forEach(b => b.classList.remove("active"));
        btn.classList.add("active");

        const target = btn.dataset.tab;
        document.querySelectorAll(".tab-page").forEach(page => {
            page.classList.toggle("hidden", page.id !== "tab-" + target);
        });
    });
});

// Mod kartları
modeCards.forEach(card => {
    card.addEventListener("click", () => {
        const mode = card.dataset.mode;
        fetch(`https://${resourceName}/selectMode`, {
            method: "POST",
            headers: {"Content-Type": "application/json; charset=UTF-8"},
            body: JSON.stringify({ mode })
        });

        modeCards.forEach(c => c.classList.remove("active"));
        card.classList.add("active");
        selectedModeSpan.textContent = card.querySelector(".mode-title").textContent;
    });
});

// Avatar kaydet
if (avatarBtn) {
    avatarBtn.addEventListener("click", () => {
        const url = avatarInput.value.trim();
        fetch(`https://${resourceName}/setAvatar`, {
            method: "POST",
            headers: {"Content-Type": "application/json; charset=UTF-8"},
            body: JSON.stringify({ url })
        });
    });
}

// LB butonları
document.querySelectorAll(".lb-btn").forEach(btn => {
    btn.addEventListener("click", () => {
        document.querySelectorAll(".lb-btn").forEach(b => b.classList.remove("active"));
        btn.classList.add("active");
        currentLb = btn.dataset.lb;
        renderLeaderboard();
    });
});

// Kapat
document.getElementById("btnClose").addEventListener("click", () => {
    fetch(`https://${resourceName}/close`, {
        method: "POST",
        body: "{}"
    });
});

// ESC ile kapatma
document.addEventListener("keyup", e => {
    if (e.key === "Escape") {
        fetch(`https://${resourceName}/close`, {
            method: "POST",
            body: "{}"
        });
    }
});

// NUI mesajları
window.addEventListener("message", event => {
    const data = event.data;
    if (!data || !data.action) return;

    if (data.action === "open") {
        currentMode = data.mode || currentMode;
        stats = data.stats || stats;
        lbData = data.lb || lbData;
        collectState = data.collectibles || collectState;

        highlightCurrentMode();
        updateStatsUI();
        renderLeaderboard();
        renderCollectibles();
        setVisible(true);
    }

    if (data.action === "close") {
        setVisible(false);
    }

    if (data.action === "setMode") {
        currentMode = data.mode || currentMode;
        highlightCurrentMode();
    }

    if (data.action === "updateStats") {
        stats = data.stats || stats;
        updateStatsUI();
    }

    if (data.action === "leaderboardUpdate") {
        lbData = data.lb || lbData;
        renderLeaderboard();
    }

    if (data.action === "collectiblesUpdate") {
        collectState = data.collectibles || collectState;
        renderCollectibles();
    }
});
