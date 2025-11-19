let isVisible = false;

window.addEventListener('message', function (event) {
    const data = event.data || {};

    if (data.action === 'panel') {
        isVisible = !!data.show;
        document.getElementById('container').style.display = isVisible ? 'flex' : 'none';
    }

    if (data.action === 'updateScores') {
        updateTable(data.scores || []);
    }

    if (data.action === 'updateMoney') {
        updateMoneyLabel(data.money || 0);
    }

    if (data.action === 'updatePlayerSummary') {
        updateProfile(data.summary || {});
    }
});

function updateTable(scores) {
    const tbody = document.getElementById('score-body');
    tbody.innerHTML = '';

    if (!scores || scores.length === 0) {
        const tr = document.createElement('tr');
        const td = document.createElement('td');
        td.colSpan = 3;
        td.style.textAlign = 'center';
        td.style.opacity = '0.75';
        td.textContent = 'Henüz drift skoru yok.';
        tr.appendChild(td);
        tbody.appendChild(tr);
        return;
    }

    scores.forEach((row, idx) => {
        const tr = document.createElement('tr');

        const tdRank = document.createElement('td');

        let medal = '';
        if (idx === 0) medal = '🥇 ';
        else if (idx === 1) medal = '🥈 ';
        else if (idx === 2) medal = '🥉 ';

        tdRank.textContent = medal + (idx + 1);

        const tdName = document.createElement('td');
        tdName.textContent = row.name || ('ID ' + row.id);

        const tdScore = document.createElement('td');
        tdScore.textContent = row.score || 0;

        tr.appendChild(tdRank);
        tr.appendChild(tdName);
        tr.appendChild(tdScore);

        tbody.appendChild(tr);
    });
}

document.getElementById('btn-close').addEventListener('click', () => {
    closeUI();
});

document.addEventListener('keydown', (e) => {
    if (!isVisible) return;

    if (
        e.key === 'Escape' || e.keyCode === 27 ||
        e.key === 'F10'    || e.keyCode === 121
    ) {
        e.preventDefault();
        closeUI();
    }
});

function closeUI() {
    if (!isVisible) return;
    isVisible = false;
    document.getElementById('container').style.display = 'none';

    try {
        fetch('https://' + GetParentResourceName() + '/close', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=utf-8' },
            body: '{}'
        });
    } catch (e) {}
}

const tabs  = document.querySelectorAll('.tab');
const pages = document.querySelectorAll('.page');

tabs.forEach(btn => {
    btn.addEventListener('click', () => {
        const page = btn.getAttribute('data-page');

        tabs.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        pages.forEach(p => {
            if (p.classList.contains('page-' + page)) {
                p.classList.add('active');
            } else {
                p.classList.remove('active');
            }
        });
    });
});

const modeButtons = document.querySelectorAll('.mode-btn');

modeButtons.forEach(btn => {
    btn.addEventListener('click', () => {
        const mode = btn.getAttribute('data-mode');

        modeButtons.forEach(b => b.classList.remove('active'));
        btn.classList.add('active');

        try {
            fetch('https://' + GetParentResourceName() + '/changeMode', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json; charset=utf-8' },
                body: JSON.stringify({ mode })
            });
        } catch (e) {}
    });
});

function updateMoneyLabel(amount) {
    const elHeader = document.getElementById('money-value');
    const elProfile = document.getElementById('profile-money');

    let text;
    try {
        text = amount.toLocaleString('tr-TR') + ' ₺';
    } catch (e) {
        text = amount + ' ₺';
    }

    if (elHeader)  elHeader.textContent  = text;
    if (elProfile) elProfile.textContent = text;
}

function updateProfile(summary) {
    const nameEl        = document.getElementById('profile-name');
    const totalDriftEl  = document.getElementById('profile-total-drift');
    const bestScoreEl   = document.getElementById('profile-best-score');
    const driftCountEl  = document.getElementById('profile-drift-count');
    const killsEl       = document.getElementById('profile-kills');
    const pointsEl      = document.getElementById('profile-points');

    if (nameEl)       nameEl.textContent       = summary.name || 'Bilinmiyor';
    if (totalDriftEl) totalDriftEl.textContent = (summary.totalDrift || 0) + ' pts';
    if (bestScoreEl)  bestScoreEl.textContent  = (summary.bestScore || 0) + ' pts';
    if (driftCountEl) driftCountEl.textContent = summary.driftCount || 0;
    if (killsEl)      killsEl.textContent      = summary.kills || 0;
    if (pointsEl)     pointsEl.textContent     = summary.points || 0;
}
