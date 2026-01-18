let Recipes = {};
let CurrentCategory = null;
let SelectedRecipe = null;
let Inventory = {};
let PlayerLevel = 1;
let PlayerXP = 0;
let MaxXP = 100;

const app = document.getElementById('app');
const categoryContainer = document.getElementById('categories');
const recipesGrid = document.getElementById('recipes-grid');
const detailsPanel = document.getElementById('selection-details');
const noSelection = document.getElementById('no-selection');

window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'open') {
        Recipes = data.recipes;
        Inventory = data.inventory.items;
        PlayerLevel = data.inventory.level;
        PlayerXP = data.inventory.xp;
        MaxXP = data.inventory.nextLevelXP;

        updateLevelUI();
        setupCategories(data.allowedCategories);
        app.style.display = 'flex';
    }

    if (data.action === 'close') {
        app.style.display = 'none';
        resetUI();
    }
});

function updateLevelUI() {
    document.getElementById('player-level').innerText = PlayerLevel;
    const progress = (PlayerXP / MaxXP) * 100;
    document.getElementById('xp-bar').style.width = progress + '%';
    document.getElementById('xp-text').innerText = `${PlayerXP} / ${MaxXP} XP`;
}

function resetUI() {
    SelectedRecipe = null;
    noSelection.style.display = 'flex';
    detailsPanel.style.display = 'none';
    document.getElementById('search-input').value = '';
}

function setupCategories(allowed) {
    categoryContainer.innerHTML = '';
    const firstCat = allowed[0];

    allowed.forEach(catKey => {
        const cat = Recipes[catKey];
        if (!cat) return;

        const el = document.createElement('div');
        el.className = `category-item ${catKey === firstCat ? 'active' : ''}`;
        el.innerHTML = `
            <i class="${cat.icon}"></i>
            <span>${cat.label.toUpperCase()}</span>
        `;
        el.onclick = () => selectCategory(catKey, el);
        categoryContainer.appendChild(el);
    });

    selectCategory(firstCat);
}

function selectCategory(catKey, element) {
    if (element) {
        document.querySelectorAll('.category-item').forEach(i => i.classList.remove('active'));
        element.classList.add('active');
    }

    CurrentCategory = catKey;
    document.getElementById('category-title').innerText = Recipes[catKey].label.toUpperCase();

    const items = Recipes[catKey].items;
    document.getElementById('category-count').innerText = `${items.length} BLUEPRINTS READY`;
    renderRecipes(items);
}

function renderRecipes(items) {
    recipesGrid.innerHTML = '';
    items.forEach(item => {
        const isBlueprintLocked = item.blueprint && !Inventory[item.blueprint];
        const isLevelLocked = item.level && PlayerLevel < item.level;
        const isLocked = isBlueprintLocked || isLevelLocked;

        const card = document.createElement('div');
        card.className = `recipe-card ${SelectedRecipe && SelectedRecipe.name === item.name ? 'active' : ''} ${isLocked ? 'locked' : ''} ${isLevelLocked ? 'level-locked' : ''}`;

        let statusIcon = '';
        if (isLevelLocked) statusIcon = `<i class="fa-solid fa-medal"></i> Lvl ${item.level}`;
        else if (isBlueprintLocked) statusIcon = '<i class="fa-solid fa-lock"></i>';

        card.innerHTML = `
            <div class="card-status">${statusIcon}</div>
            <img src="https://cfx-nui-ox_inventory/web/images/${item.name}.png" alt="${item.label}" style="${isLocked ? 'filter: grayscale(1) opacity(0.3);' : ''}">
            <span>${item.label}</span>
        `;
        card.onclick = () => selectRecipe(item, card, isBlueprintLocked, isLevelLocked);
        recipesGrid.appendChild(card);
    });
}

function selectRecipe(item, card, isBlueprintLocked, isLevelLocked) {
    const isLocked = isBlueprintLocked || isLevelLocked;
    SelectedRecipe = item;
    SelectedRecipe.isLocked = isLocked;
    SelectedRecipe.isLevelLocked = isLevelLocked;

    // UI Feedback for selection
    document.querySelectorAll('.recipe-card').forEach(c => c.classList.remove('active'));
    card.classList.add('active');

    noSelection.style.display = 'none';
    detailsPanel.style.display = 'flex';

    const iconEl = document.getElementById('item-icon');
    iconEl.src = `https://cfx-nui-ox_inventory/web/images/${item.name}.png`;
    iconEl.style.filter = isLocked ? 'grayscale(1) opacity(0.2)' : '';

    document.getElementById('item-name').innerText = item.label;
    document.getElementById('item-time').innerText = (item.duration / 1000) + 's';

    let desc = item.description || "Specifications available for construction.";
    if (isLevelLocked) desc = `SYSTEM ALERT: Insufficient authorization. Crafting Level ${item.level} required for this module.`;
    else if (isBlueprintLocked) desc = "SCHEMATIC ENCRYPTED: Valid blueprint required for assembly.";

    document.getElementById('item-desc').innerText = desc;

    const ingList = document.getElementById('ingredients-list');
    ingList.innerHTML = '';

    let totalReq = 0;
    let totalMet = 0;

    item.ingredients.forEach(ing => {
        totalReq++;
        const owned = Inventory[ing.item] || 0;
        const isEnough = owned >= ing.amount;
        if (isEnough) totalMet++;

        const percentage = Math.min((owned / ing.amount) * 100, 100);

        const el = document.createElement('div');
        el.className = 'component-bar';
        el.style.opacity = isLocked ? '0.3' : '1';
        el.innerHTML = `
            <div class="fill-progress" style="width: ${percentage}%"></div>
            <div class="comp-body">
                <div class="comp-info">
                    <img src="https://cfx-nui-ox_inventory/web/images/${ing.item}.png">
                    <span>${ing.item.charAt(0).toUpperCase() + ing.item.slice(1)}</span>
                </div>
                <span class="comp-stat ${isEnough ? 'owned' : 'missing'}">${owned}/${ing.amount}</span>
            </div>
        `;
        ingList.appendChild(el);
    });

    const craftBtn = document.getElementById('craft-button');
    if (isLevelLocked) {
        craftBtn.innerHTML = `<span class="btn-text">REQUIRES LEVEL ${item.level}</span>`;
        craftBtn.style.background = '#331a00';
        craftBtn.style.pointerEvents = 'none';
        craftBtn.style.boxShadow = 'none';
    } else if (isBlueprintLocked) {
        craftBtn.innerHTML = '<span class="btn-text">LOCKED: NEED BLUEPRINT</span>';
        craftBtn.style.background = '#222';
        craftBtn.style.pointerEvents = 'none';
        craftBtn.style.boxShadow = 'none';
    } else {
        craftBtn.innerHTML = '<span class="btn-text">START ASSEMBLY</span><div class="btn-shine"></div>';
        craftBtn.style.background = 'var(--accent)';
        craftBtn.style.pointerEvents = 'all';
        craftBtn.style.boxShadow = '';
    }

    document.getElementById('comp-count').innerText = isLocked ? "ACCESS DENIED" : `${totalMet}/${totalReq} READY`;
}

document.getElementById('craft-button').onclick = () => {
    if (!SelectedRecipe || SelectedRecipe.isLocked) return;

    fetch(`https://${GetParentResourceName()}/craft`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            item: SelectedRecipe.name,
            category: CurrentCategory
        })
    });
};

document.onkeyup = (e) => {
    if (e.key === 'Escape') {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST'
        });
    }
};

// Search functionality
document.getElementById('search-input').oninput = (e) => {
    const val = e.target.value.toLowerCase();
    const allInCat = Recipes[CurrentCategory].items;
    const filtered = allInCat.filter(i => {
        return i.label.toLowerCase().includes(val) || i.name.toLowerCase().includes(val);
    });
    renderRecipes(filtered);
};
