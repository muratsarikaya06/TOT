let visible = false
let selectedMode = 'freeroam'
let activeMode = null

const hub = document.getElementById('hub')
const driftTable = document.getElementById('drift-table')

function setVisible(state) {
    visible = state
    if (state) {
        hub.classList.remove('hidden')
    } else {
        hub.classList.add('hidden')
    }
}

window.addEventListener('message', (event) => {
    const data = event.data
    if (!data || !data.action) return

    if (data.action === 'setVisible') {
        setVisible(data.state)
    } else if (data.action === 'setPlayerData') {
        applyPlayerData(data.data || {})
    } else if (data.action === 'setField') {
        applyField(data.field, data.value)
    } else if (data.action === 'setDriftTop') {
        fillDriftTable(data.rows || [])
    }
})

function applyPlayerData(p) {
    document.getElementById('stat-money').textContent = (p.money || 0) + ' ₺'
    document.getElementById('stat-xp').textContent = p.xp || 0
    document.getElementById('stat-level').textContent = p.level || 1

    document.getElementById('p-level').textContent = p.level || 1
    document.getElementById('p-xp').textContent = p.xp || 0
    document.getElementById('p-drift-total').textContent = p.drift_total || 0
    document.getElementById('p-collectibles').textContent = p.collectibles || 0
    document.getElementById('p-pvp-kd').textContent = (p.pvp_kills || 0) + ' / ' + (p.pvp_deaths || 0)

    if (p.avatar_url) {
        document.getElementById('avatar-img').style.backgroundImage = `url('${p.avatar_url}')`
        document.getElementById('avatar-url').value = p.avatar_url
    }

    activeMode = p.mode || 'freeroam'
    selectedMode = activeMode
    document.getElementById('active-mode').textContent = modeLabel(activeMode)
    updateModeCards()
}

function applyField(field, value) {
    if (field === 'mode') {
        activeMode = value
        selectedMode = value
        document.getElementById('active-mode').textContent = modeLabel(value)
        updateModeCards()
    } else if (field === 'avatar_url') {
        if (value) {
            document.getElementById('avatar-img').style.backgroundImage = `url('${value}')`
            document.getElementById('avatar-url').value = value
        }
    }
}

function modeLabel(mode) {
    if (mode === 'pvp') return 'PvP'
    if (mode === 'roleplay') return 'Roleplay'
    return 'Serbest Gezinme'
}

function updateModeCards() {
    document.querySelectorAll('.mode-card').forEach(card => {
        const m = card.dataset.mode
        card.classList.toggle('active', m === selectedMode)
    })
}

document.querySelectorAll('.mode-card').forEach(card => {
    card.addEventListener('click', () => {
        selectedMode = card.dataset.mode
        updateModeCards()
    })
})

document.getElementById('mode-confirm').addEventListener('click', () => {
    if (selectedMode && selectedMode !== activeMode) {
        fetch(`https://tot_combined/changeMode`, {
            method: 'POST',
            body: JSON.stringify({ mode: selectedMode })
        })
    }
})

document.getElementById('avatar-save').addEventListener('click', () => {
    const url = document.getElementById('avatar-url').value.trim()
    fetch(`https://tot_combined/saveAvatar`, {
        method: 'POST',
        body: JSON.stringify({ url })
    })
})

document.querySelectorAll('.tab-btn').forEach(btn => {
    btn.addEventListener('click', () => {
        const tab = btn.dataset.tab
        document.querySelectorAll('.tab-btn').forEach(b => b.classList.toggle('active', b === btn))
        document.querySelectorAll('.tab-panel').forEach(p => p.classList.toggle('active', p.dataset.tab === tab))
    })
})

document.querySelectorAll('[data-action="close"]').forEach(btn => {
    btn.addEventListener('click', () => {
        fetch('https://tot_combined/close', { method: 'POST', body: '{}' })
    })
})

function fillDriftTable(rows) {
    driftTable.innerHTML = ''
    rows.forEach((row, idx) => {
        const tr = document.createElement('tr')
        tr.innerHTML = `<td>${idx+1}</td><td>${row.name}</td><td>${row.drift_total}</td>`
        driftTable.appendChild(tr)
    })
}
