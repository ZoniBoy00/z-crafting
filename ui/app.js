/**
 * Z-Crafting UI - Modern Crafting Interface
 * FiveM Crafting System
 */

let Recipes = {};
let CurrentCategory = null;
let SelectedRecipe = null;
let Inventory = {};
let PlayerLevel = 1;
let PlayerXP = 0;
let MaxXP = 100;

// DOM Elements
const app = document.getElementById('app');
const categoryContainer = document.getElementById('categories');
const recipesGrid = document.getElementById('recipes-grid');
const detailsPanel = document.getElementById('selection-details');
const noSelection = document.getElementById('no-selection');

// Message Handler
window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.action === 'open') {
        Recipes = data.recipes || {};
        Inventory = data.inventory || {};
        PlayerLevel = data.level || 1;
        PlayerXP = data.xp || 0;
        MaxXP = data.nextLevelXP || 100;

        updateLevelUI();
        setupCategories(data.allowedCategories);
        
        // Show UI with animation - use requestAnimationFrame to ensure CSS transition works
        app.style.display = 'flex';
        requestAnimationFrame(() => {
            requestAnimationFrame(() => {
                app.classList.add('visible');
            });
        });
        document.body.style.overflow = 'hidden';
    }

    if (data.action === 'close') {
        app.classList.remove('visible');
        setTimeout(() => {
            app.style.display = 'none';
        }, 200);
        resetUI();
    }
});

// Update Level Display
function updateLevelUI() {
    document.getElementById('player-level').innerText = PlayerLevel;
    const progress = Math.min((PlayerXP / MaxXP) * 100, 100);
    document.getElementById('xp-bar').style.width = progress + '%';
    document.getElementById('xp-text').innerText = `${PlayerXP.toLocaleString()} / ${MaxXP.toLocaleString()} XP`;
}

// Reset UI State
function resetUI() {
    SelectedRecipe = null;
    noSelection.style.display = 'flex';
    detailsPanel.style.display = 'none';
    document.getElementById('search-input').value = '';
}

// Setup Category Navigation
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
            <span>${capitalizeFirst(cat.label)}</span>
        `;
        el.onclick = () => selectCategory(catKey, el);
        categoryContainer.appendChild(el);
    });

    selectCategory(firstCat);
}

// Capitalize First Letter
function capitalizeFirst(str) {
    return str.charAt(0).toUpperCase() + str.slice(1).toLowerCase();
}

// Select Category
function selectCategory(catKey, element) {
    if (element) {
        document.querySelectorAll('.category-item').forEach(i => i.classList.remove('active'));
        element.classList.add('active');
    }

    CurrentCategory = catKey;
    const category = Recipes[catKey];
    
    document.getElementById('category-title').innerText = capitalizeFirst(category.label);

    const items = category.items;
    const availableCount = items.filter(item => {
        const isBlueprintLocked = item.blueprint && !Inventory[item.blueprint];
        const isLevelLocked = item.level && PlayerLevel < item.level;
        return !isBlueprintLocked && !isLevelLocked;
    }).length;

    document.getElementById('category-count').innerText = `${availableCount} of ${items.length} blueprints available`;
    
    // Reset selection when changing category
    resetUI();
    renderRecipes(items);
}

// Render Recipe Cards
function renderRecipes(items) {
    recipesGrid.innerHTML = '';

    if (items.length === 0) {
        recipesGrid.innerHTML = `
            <div class="empty-grid-state">
                <p>No blueprints found</p>
            </div>
        `;
        return;
    }

    items.forEach((item, index) => {
        const isBlueprintLocked = item.blueprint && !Inventory[item.blueprint];
        const isLevelLocked = item.level && PlayerLevel < item.level;
        const isLocked = isBlueprintLocked || isLevelLocked;

        const card = document.createElement('div');
        card.className = `recipe-card ${SelectedRecipe && SelectedRecipe.name === item.name ? 'active' : ''} ${isLocked ? 'locked' : ''} ${isLevelLocked ? 'level-locked' : ''}`;
        card.style.animationDelay = `${index * 30}ms`;

        let statusIcon = '';
        if (isLevelLocked) {
            statusIcon = `<i class="fa-solid fa-medal"></i> ${item.level}`;
        } else if (isBlueprintLocked) {
            statusIcon = '<i class="fa-solid fa-lock"></i>';
        }

        card.innerHTML = `
            <div class="card-status">${statusIcon}</div>
            <img src="https://cfx-nui-ox_inventory/web/images/${item.name}.png" 
                 alt="${item.label}"
                 style="${isLocked ? 'filter: grayscale(1) brightness(0.5);' : ''}"
                 onerror="this.style.display='none'">
            <span>${item.label}</span>
        `;
        
        card.onclick = () => selectRecipe(item, card, isBlueprintLocked, isLevelLocked);
        recipesGrid.appendChild(card);
    });
}

// Select Recipe
function selectRecipe(item, card, isBlueprintLocked, isLevelLocked) {
    const isLocked = isBlueprintLocked || isLevelLocked;
    SelectedRecipe = { ...item, isLocked, isLevelLocked, isBlueprintLocked };

    // Update card selection
    document.querySelectorAll('.recipe-card').forEach(c => c.classList.remove('active'));
    card.classList.add('active');

    // Show details panel
    noSelection.style.display = 'none';
    detailsPanel.style.display = 'flex';

    // Update preview image
    const iconEl = document.getElementById('item-icon');
    const fallbackEl = document.getElementById('image-fallback');
    
    // Reset image state
    iconEl.style.display = 'block';
    iconEl.style.filter = isLocked ? 'grayscale(1) brightness(0.4)' : '';
    fallbackEl.classList.remove('visible');
    
    // Set image source
    iconEl.src = `https://cfx-nui-ox_inventory/web/images/${item.name}.png`;
    
    // Handle image load error - show fallback
    iconEl.onerror = function() { 
        this.style.display = 'none'; 
        fallbackEl.classList.add('visible');
    };
    
    // Handle successful image load
    iconEl.onload = function() {
        this.style.display = 'block';
        fallbackEl.classList.remove('visible');
    };

    // Update item info
    document.getElementById('item-name').innerText = item.label;
    document.getElementById('item-time').innerText = formatDuration(item.duration);

    // Update description
    let desc = item.description || "A craftable item with standard specifications.";
    if (isLevelLocked) {
        desc = `Requires Crafting Level ${item.level} to unlock this blueprint.`;
    } else if (isBlueprintLocked) {
        desc = "Blueprint required. Find or purchase the schematic to unlock.";
    }
    document.getElementById('item-desc').innerText = desc;

    // Update blueprint requirement display
    updateBlueprintRequirement(item, isBlueprintLocked);

    // Update ingredients
    updateIngredientsList(item.ingredients, isLocked);

    // Update craft button
    updateCraftButton(item, isLocked, isLevelLocked, isBlueprintLocked);
}

// Update Blueprint Requirement Display
function updateBlueprintRequirement(item, isBlueprintLocked) {
    const blueprintSection = document.getElementById('blueprint-requirement');
    const blueprintNameEl = document.getElementById('blueprint-name');
    
    if (item.blueprint) {
        blueprintSection.style.display = 'flex';
        
        // Format blueprint name for display
        const formattedName = item.blueprint.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
        blueprintNameEl.innerText = formattedName;
        
        // Update state based on ownership
        blueprintSection.classList.remove('owned', 'missing');
        if (isBlueprintLocked) {
            blueprintSection.classList.add('missing');
        } else {
            blueprintSection.classList.add('owned');
        }
    } else {
        blueprintSection.style.display = 'none';
    }
}

// Format Duration
function formatDuration(ms) {
    const seconds = Math.floor(ms / 1000);
    if (seconds < 60) return `${seconds}s`;
    const minutes = Math.floor(seconds / 60);
    const remainingSeconds = seconds % 60;
    return remainingSeconds > 0 ? `${minutes}m ${remainingSeconds}s` : `${minutes}m`;
}

// Update Ingredients List
function updateIngredientsList(ingredients, isLocked) {
    const ingList = document.getElementById('ingredients-list');
    ingList.innerHTML = '';

    let totalReq = 0;
    let totalMet = 0;

    ingredients.forEach(ing => {
        totalReq++;
        const owned = Inventory[ing.item] || 0;
        const isEnough = owned >= ing.amount;
        if (isEnough) totalMet++;

        const percentage = Math.min((owned / ing.amount) * 100, 100);
        const itemName = ing.item.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());

        const el = document.createElement('div');
        el.className = 'component-bar';
        el.style.opacity = isLocked ? '0.4' : '1';
        el.innerHTML = `
            <div class="fill-progress" style="width: ${isEnough ? percentage : 0}%"></div>
            <div class="comp-body">
                <div class="comp-info">
                    <img src="https://cfx-nui-ox_inventory/web/images/${ing.item}.png" 
                         alt="${itemName}"
                         onerror="this.style.display='none'">
                    <span>${itemName}</span>
                </div>
                <span class="comp-stat ${isEnough ? 'owned' : 'missing'}">${owned}/${ing.amount}</span>
            </div>
        `;
        ingList.appendChild(el);
    });

    const countEl = document.getElementById('comp-count');
    if (isLocked) {
        countEl.innerText = "Locked";
        countEl.style.color = 'var(--error)';
    } else {
        countEl.innerText = `${totalMet}/${totalReq} Ready`;
        countEl.style.color = totalMet === totalReq ? 'var(--success)' : 'var(--text-muted)';
    }

    return { totalReq, totalMet };
}

// Update Craft Button
function updateCraftButton(item, isLocked, isLevelLocked, isBlueprintLocked) {
    const craftBtn = document.getElementById('craft-button');
    const ingredients = item.ingredients;
    
    let totalMet = 0;
    let totalReq = ingredients.length;
    
    ingredients.forEach(ing => {
        const owned = Inventory[ing.item] || 0;
        if (owned >= ing.amount) totalMet++;
    });

    const hasEnoughIngredients = totalMet === totalReq;

    // Reset styles
    craftBtn.style.pointerEvents = 'all';
    craftBtn.className = 'craft-button';

    if (isLevelLocked) {
        craftBtn.innerHTML = `<span class="button-text">Level ${item.level} Required</span>`;
        craftBtn.className = 'craft-button locked';
        craftBtn.style.pointerEvents = 'none';
    } else if (isBlueprintLocked) {
        craftBtn.innerHTML = '<span class="button-text">Blueprint Required</span>';
        craftBtn.className = 'craft-button locked';
        craftBtn.style.pointerEvents = 'none';
    } else if (!hasEnoughIngredients) {
        craftBtn.innerHTML = '<span class="button-text">Missing Materials</span>';
        craftBtn.className = 'craft-button missing';
        craftBtn.style.pointerEvents = 'none';
    } else {
        craftBtn.innerHTML = '<span class="button-text">Begin Crafting</span><div class="button-glow"></div>';
        craftBtn.className = 'craft-button active';
    }
}

// Craft Button Click
document.getElementById('craft-button').onclick = () => {
    if (!SelectedRecipe || SelectedRecipe.isLocked) return;

    // Check ingredients again
    const hasAll = SelectedRecipe.ingredients.every(ing => {
        const owned = Inventory[ing.item] || 0;
        return owned >= ing.amount;
    });

    if (!hasAll) return;

    fetch(`https://${getNuiResourceName()}/craft`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            item: SelectedRecipe.name,
            category: CurrentCategory
        })
    }).catch(() => {});
};

// Close UI Function
function closeUI() {
    app.classList.remove('visible');
    setTimeout(() => {
        app.style.display = 'none';
    }, 200);
    resetUI();
    document.body.style.overflow = '';
    
    fetch(`https://${getNuiResourceName()}/close`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    }).catch(() => {});
}

// Escape Key Handler
document.onkeyup = (e) => {
    if (e.key === 'Escape' && app.style.display !== 'none') {
        closeUI();
    }
};

// Search Functionality
document.getElementById('search-input').oninput = (e) => {
    const val = e.target.value.toLowerCase().trim();
    const allInCat = Recipes[CurrentCategory]?.items || [];
    
    if (val === '') {
        renderRecipes(allInCat);
        return;
    }

    const filtered = allInCat.filter(i => {
        return i.label.toLowerCase().includes(val) || 
               i.name.toLowerCase().includes(val);
    });
    
    renderRecipes(filtered);
};

// Debounce helper for search (optional enhancement)
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

// Get resource name helper - FiveM injects GetParentResourceName globally
function getNuiResourceName() {
    if (typeof window.GetParentResourceName === 'function') {
        return window.GetParentResourceName();
    }
    return 'z-crafting';
}
