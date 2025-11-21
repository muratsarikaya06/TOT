let currentMode = null;
let isIntro = false;

const wrapper = document.getElementById('hub-wrapper');
const blurLayer = document.getElementById('blur-layer');
const closeBtn = document.getElementById('hub-close');
const modeCards = document.querySelectorAll('.mode-card');
const modeLabel = document.getElementById('current-mode-label');

function setVisible(v) {
    if (v) {
        wrapper.classList.add('visible');
        wrapper.classList.remove('hidden');
    } else {
        wrapper.classList.remove('visible');
        setTimeout(() => wrapper.classList.add('hidden'), 200);
    }
}

function updateModeLabel() {
    if (!currentMode) {
        modeLabel.textContent = 'Seçili mod: Henüz seçilmedi';
        return;
    }
    let txt = 'Seçili mod: ';
    if (currentMode === 'freeroam') txt += 'Serbest Gezinti';
    else if (currentMode === 'pvp') txt += 'PvP';
    else if (currentMode === 'roleplay') txt += 'Roleplay';
    else txt += currentMode;

    modeLabel.textContent = txt;

    modeCards.forEach(c => {
        if (c.dataset.mode === currentMode) c.classList.add('active');
        else c.classList.remove('active');
    });
}

// NUI events from Lua
window.addEventListener('message', (event) => {
    const data = event.data;
    if (!data || !data.action) return;

    if (data.action === 'open') {
        isIntro = !!data.intro;
        currentMode = data.mode || null;
        updateModeLabel();
        setVisible(true);
    }

    if (data.action === 'close') {
        setVisible(false);
    }

    if (data.action === 'setModeLabel') {
        currentMode = data.mode || null;
        updateModeLabel();
    }
});

// Mode card click
modeCards.forEach(card => {
    card.addEventListener('click', () => {
        const mode = card.dataset.mode;
        fetch(`https://${GetParentResourceName()}/selectMode`, {
            method: 'POST',
            headers: {'Content-Type': 'application/json; charset=UTF-8'},
            body: JSON.stringify({ mode })
        }).then(r => r.json()).then(res => {
            if (res.ok) {
                currentMode = mode;
                updateModeLabel();
            }
        }).catch(() => {});
    });
});

// Close
closeBtn.addEventListener('click', () => {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        body: '{}'
    }).catch(() => {});
});

// ESC kapatma
document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            body: '{}'
        }).catch(() => {});
    }
});
