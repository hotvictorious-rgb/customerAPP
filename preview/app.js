// State Management
const API_BASE = 'http://127.0.0.1:8080/api/v1';

let state = {
  currentTab: 'splash',
  categories: [],
  lgas: [],
  products: [],
  flagshipProducts: [],
  cart: [],
  selectedProduct: null,
  activeLgaId: 69,
  selectedCity: 'Uyo',
  selectedState: 'Akwa Ibom',
  selectedLgaId: 69,
  coverageStatus: 'pickup_and_delivery',
  statusBadge: '⚡ In-Shop Pickup & Same-Day Active',
  pendingCity: 'Uyo',
  pendingState: 'Akwa Ibom',
  pendingLgaId: 69,
  shops: [
    { id: 1, name: 'MegaTech Uyo Plaza', slug: 'megatech-uyo', lga_id: 69, lga_name: 'Uyo', address: '10 Aka Road, Uyo Plaza', logo: 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?auto=format&fit=crop&w=300&q=80', description: 'Official flagship smartphone and gadgets depot at Aka Road Plaza.' },
    { id: 2, name: 'Apex Computer Hub Uyo', slug: 'apex-hub', lga_id: 69, lga_name: 'Uyo', address: '14 Ikot Ekpene Road, Uyo', logo: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?auto=format&fit=crop&w=300&q=80', description: 'Certified laptops, workstations and accessories with full warranty.' },
    { id: 3, name: 'Eket Electronics Centre', slug: 'eket-electronics', lga_id: 70, lga_name: 'Eket', address: 'Plot 2 Grace Bill Road, Eket', logo: 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=300&q=80', description: 'Premium home appliances, Smart 4K TVs and sound systems.' },
    { id: 4, name: 'Ikot Ekpene Craft & Textiles', slug: 'ikot-ekpene-crafts', lga_id: 71, lga_name: 'Ikot Ekpene', address: 'Craft Market Complex, Ikot Ekpene', logo: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=300&q=80', description: 'Authentic raffia crafts, royal woven fabrics and heritage apparel.' }
  ],
  selectedShop: null,
  activeCategorySlug: null,
  fulfillmentType: 'doorstep_delivery',
  redeemCashback: false,
  activeOrder: {
    orderNumber: 'ORD-20261015-8192',
    otp: '491820',
    statusStep: 3,
    statusText: 'OUT FOR DELIVERY',
    items: [
      { name: 'Samsung Galaxy A54 5G 128GB', qty: 1, price: '₦320,000.00' }
    ],
    subtotal: '₦320,000.00',
    deliveryFee: '₦500.00',
    total: '₦320,500.00',
    cashbackEarned: '₦16,000.00',
    courierName: 'Emeka Okon',
    courierPhone: '+2348039120491',
    courierVehicle: 'Motorcycle (UYO-123-AK)',
    shopName: 'MegaTech Uyo Plaza',
    shopAddress: '10 Aka Road, Uyo'
  },
  activeReservation: {
    code: 'RES-89A4B12C',
    productName: 'iPhone 13 Pro Max 256GB Gold',
    qty: 1,
    total: '₦680,000.00',
    shopName: 'Victorious Flagship Gadgets',
    shopAddress: 'Plot 4, Shelter Afrique Estate, Uyo',
    expiresIn: '23h 48m'
  }
};

// Seed Fallback Data
const SEED_PRODUCTS = [
  {
    id: 1,
    name: 'Samsung Galaxy A54 5G 128GB Awesome Violet',
    unit_price: '320000.00',
    is_vmarket_flagship: true,
    pickup_enabled: true,
    shop: { name: 'MegaTech Uyo Plaza', lga_id: 69 },
    thumbnail: 'https://images.unsplash.com/photo-1610945265064-0e34e5519bbf?auto=format&fit=crop&w=400&q=80',
    description: 'Verified brand new flagship smartphone with official warranty in Akwa Ibom State.'
  },
  {
    id: 2,
    name: 'HP Pavilion 15 Core i5 16GB RAM 512GB SSD',
    unit_price: '780000.00',
    is_vmarket_flagship: true,
    pickup_enabled: true,
    shop: { name: 'Apex Computer Hub Uyo', lga_id: 69 },
    thumbnail: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=400&q=80',
    description: 'High performance laptop suitable for engineering, programming and corporate work.'
  },
  {
    id: 3,
    name: 'Smart 4K UHD LED TV 55 Inch Frameless',
    unit_price: '450000.00',
    is_vmarket_flagship: false,
    pickup_enabled: true,
    shop: { name: 'Eket Electronics Centre', lga_id: 70 },
    thumbnail: 'https://images.unsplash.com/photo-1593359677879-a4bb92f829d1?auto=format&fit=crop&w=400&q=80',
    description: 'Crystal clear cinematic display with HDR10+ and Dolby Audio sound.'
  },
  {
    id: 4,
    name: 'Apple iPhone 15 Pro 128GB Natural Titanium',
    unit_price: '1450000.00',
    is_vmarket_flagship: true,
    pickup_enabled: true,
    shop: { name: 'Victorious Flagship Gadgets', lga_id: 69 },
    thumbnail: 'https://images.unsplash.com/photo-1695048133142-1a20484d2569?auto=format&fit=crop&w=400&q=80',
    description: 'Aerospace-grade titanium design with A17 Pro chip and 48MP main camera.'
  },
  {
    id: 5,
    name: 'Royal Heritage Akwete Traditional Woven Fabric',
    unit_price: '45000.00',
    is_vmarket_flagship: false,
    pickup_enabled: true,
    shop: { name: 'Ikot Ekpene Craft & Textiles', lga_id: 71 },
    thumbnail: 'https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=400&q=80',
    description: 'Authentic handcrafted cultural attire from master weavers in Akwa Ibom.'
  },
  {
    id: 6,
    name: 'Fresh Premium Akwa Ibom Palm Oil (5 Litres)',
    unit_price: '18500.00',
    is_vmarket_flagship: false,
    pickup_enabled: false,
    shop: { name: 'Oron Agro Merchants', lga_id: 72 },
    thumbnail: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?auto=format&fit=crop&w=400&q=80',
    description: 'Pure, unadulterated grade-A organic red palm oil sourced directly from farm clusters.'
  }
];

const SEED_CATEGORIES = [
  { name: 'Phones & Tablets', slug: 'phones', icon: 'fa-mobile-screen-button' },
  { name: 'Laptops & Tech', slug: 'tech', icon: 'fa-laptop' },
  { name: 'Home Appliances', slug: 'appliances', icon: 'fa-tv' },
  { name: 'Fashion & Wear', slug: 'fashion', icon: 'fa-shirt' },
  { name: 'Groceries & Foods', slug: 'food', icon: 'fa-bowl-rice' },
  { name: 'Beauty & Health', slug: 'beauty', icon: 'fa-spa' }
];

// Initialize on Load
document.addEventListener('DOMContentLoaded', async () => {
  await initBackendData();
  renderHome();
  renderExploreCategories();
});

// Format Currency
function formatNaira(amount) {
  const num = parseFloat(amount) || 0;
  return '₦' + num.toLocaleString('en-NG', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

// Fetch live backend data with fallback
async function initBackendData() {
  // 0. Fetch Dynamic Remote Config
  try {
    const cfgRes = await fetch(`${API_BASE}/config`);
    if (cfgRes.ok) {
      const cfgData = await cfgRes.json();
      if (cfgData.status && cfgData.data) {
        state.config = cfgData.data;
        if (cfgData.data.active_corridors && cfgData.data.active_corridors.length > 0) {
          state.activeCorridors = cfgData.data.active_corridors;
        }
      }
    }
  } catch (_) {}

  // 0b. Fetch Dynamic Storefront Banners
  try {
    const bRes = await fetch(`${API_BASE}/banners`);
    if (bRes.ok) {
      const bData = await bRes.json();
      if (bData.status && bData.data && bData.data.hero_banners) {
        state.heroBanners = bData.data.hero_banners;
      }
    }
  } catch (_) {}

  const statusEl = document.getElementById('backend-status-text');
  try {
    const res = await fetch(`${API_BASE}/products`);
    if (res.ok) {
      const data = await res.json();
      if (data.status && data.data && data.data.data) {
        state.products = data.data.data;
        statusEl.textContent = `Backend Live (${state.products.length} Products Loaded)`;
      } else {
        state.products = SEED_PRODUCTS;
        statusEl.textContent = 'Backend Active (Using Seed Data)';
      }
    } else {
      state.products = SEED_PRODUCTS;
      statusEl.textContent = 'Backend 8080 Standby (Local Mode)';
    }
  } catch (e) {
    state.products = SEED_PRODUCTS;
    statusEl.textContent = 'Backend Standby (Interactive Simulator)';
  }

  try {
    const catRes = await fetch(`${API_BASE}/categories`);
    if (catRes.ok) {
      const catData = await catRes.json();
      if (catData.status && catData.data && catData.data.length > 0) {
        state.categories = catData.data;
      } else {
        state.categories = SEED_CATEGORIES;
      }
    } else {
      state.categories = SEED_CATEGORIES;
    }
  } catch (_) {
    state.categories = SEED_CATEGORIES;
  }

  try {
    const lgaRes = await fetch(`${API_BASE}/geography/lgas/3`);
    if (lgaRes.ok) {
      const lgaData = await lgaRes.json();
      if (lgaData.status && lgaData.data && lgaData.data.length > 0) {
        state.lgas = lgaData.data;
      }
    }
  } catch (_) {}

  state.flagshipProducts = state.products.filter(p => p.is_vmarket_flagship);
}

// Navigation Router
function switchTab(tabId) {
  state.currentTab = tabId;

  // Update views
  document.querySelectorAll('.screen-view').forEach(view => view.classList.remove('active'));
  const targetView = document.getElementById(`view-${tabId}`);
  if (targetView) targetView.classList.add('active');

  // Update bottom nav
  document.querySelectorAll('.nav-item').forEach(item => item.classList.remove('active'));
  const activeNavItem = document.getElementById(`tab-${tabId}`);
  if (activeNavItem) activeNavItem.classList.add('active');

  // Update studio pills
  document.querySelectorAll('.nav-pill-btn').forEach(btn => btn.classList.remove('active'));
  
  // Viewport scroll to top
  document.getElementById('viewport').scrollTop = 0;

  if (tabId === 'cart') renderCart();
  if (tabId === 'checkout') renderCheckout();
  if (tabId === 'orders') renderOrders();
  if (tabId === 'explore') renderExplore();
}

function enterMarketplace() {
  switchTab('home');
}

// Render LGA Chips dynamically
function renderLgaChips() {
  const container = document.getElementById('home-lga-chips-list');
  if (!container) return;
  const lgas = (state.activeCorridors && state.activeCorridors.length > 0) ? state.activeCorridors : (state.lgas.length > 0 ? state.lgas : [
    { id: 69, name: 'Uyo' },
    { id: 70, name: 'Eket' },
    { id: 71, name: 'Ikot Ekpene' },
    { id: 72, name: 'Oron' }
  ]);

  container.innerHTML = `
    <div class="lga-chip ${state.activeLgaId === null ? 'active' : ''}" onclick="filterLga(null, this)">All LGAs</div>
    ${lgas.map(lga => `
      <div class="lga-chip ${state.activeLgaId === lga.id ? 'active' : ''}" onclick="filterLga(${lga.id}, this)">
        ${lga.name} LGA
      </div>
    `).join('')}
  `;
}

// Render Home Screen
function renderHome() {
  // Update Header Location & Proximity Labels
  const headCity = document.getElementById('header-location-city');
  if (headCity) headCity.textContent = state.selectedCity;
  const proxBadge = document.getElementById('proximity-coverage-badge');
  if (proxBadge) proxBadge.textContent = state.statusBadge;

  // Render LGA Corridors
  renderLgaChips();

  // Render Categories
  const catContainer = document.getElementById('home-categories-list');
  catContainer.innerHTML = state.categories.map(cat => `
    <div class="category-circle-item" onclick="filterCategory('${cat.slug}')">
      <div class="category-circle">
        <i class="fa-solid ${cat.icon || 'fa-tag'}"></i>
      </div>
      <div class="category-label">${cat.name}</div>
    </div>
  `).join('');

  // Render Stores Closer to You (Matching _shops_grid.blade.php)
  renderStoresCloserToYou();

  // Render Flagship
  const flagshipGrid = document.getElementById('home-flagship-grid');
  const flagships = state.flagshipProducts.length > 0 ? state.flagshipProducts : state.products.slice(0, 2);
  flagshipGrid.innerHTML = flagships.map(p => createProductCardHtml(p)).join('');

  // Render Products
  renderHomeProducts();
}

function renderHomeProducts() {
  const grid = document.getElementById('home-products-grid');
  let filtered = [...state.products];
  if (state.activeLgaId) {
    filtered = filtered.filter(p => p.shop && p.shop.lga_id === state.activeLgaId);
  }

  document.getElementById('products-count-label').textContent = `${filtered.length} Verified Products`;
  grid.innerHTML = filtered.map(p => createProductCardHtml(p)).join('');
}

function createProductCardHtml(p) {
  const imgUrl = p.thumbnail || 'assets/vm_icon.jpg';
  const shopName = (p.shop && p.shop.name) ? p.shop.name : 'Verified Merchant';
  return `
    <div class="product-card" onclick="openProductDetails(${p.id})">
      <div class="product-card-img-wrap">
        <img src="${imgUrl}" alt="${p.name}" onerror="this.src='assets/vm_icon.jpg'">
        ${p.is_vmarket_flagship ? `<div class="flagship-badge"><i class="fa-solid fa-crown"></i> FLAGSHIP</div>` : ''}
        ${p.pickup_enabled ? `<div class="pickup-badge"><i class="fa-solid fa-store"></i> Pickup Ready</div>` : ''}
      </div>
      <div class="product-card-body">
        <div>
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2px;">
            <div class="shop-name-tag">${shopName}</div>
            <span style="font-size: 9.5px; font-weight: 800; color: #B45309; background: #FEF3C7; padding: 1px 6px; border-radius: 4px;">+5% Reward</span>
          </div>
          <div class="product-title">${p.name}</div>
        </div>
        <div class="product-card-footer">
          <div class="product-price">${formatNaira(p.unit_price)}</div>
          <button class="add-bag-btn" onclick="event.stopPropagation(); addToCart(${p.id})">
            <i class="fa-solid fa-plus"></i>
          </button>
        </div>
      </div>
    </div>
  `;
}

// Product Details Screen
function openProductDetails(id) {
  const product = state.products.find(p => p.id === id);
  if (!product) return;
  state.selectedProduct = product;

  const content = document.getElementById('details-content');
  const imgUrl = product.thumbnail || 'assets/vm_icon.jpg';
  const shopName = (product.shop && product.shop.name) ? product.shop.name : 'Verified Merchant Shop';

  content.innerHTML = `
    <div style="background: white; padding: 20px; text-align: center;">
      <img src="${imgUrl}" style="max-height: 220px; max-width: 100%; border-radius: 12px; object-fit: contain;">
    </div>
    <div style="padding: 16px; background: white; margin-top: 8px;">
      <div style="display: flex; gap: 8px; margin-bottom: 8px;">
        <span style="background: var(--success-light); color: var(--success); font-size: 10px; font-weight: 800; padding: 3px 8px; border-radius: 6px;">
          <i class="fa-solid fa-circle-check"></i> 7-Day Verified Fresh
        </span>
        <span style="background: var(--gold-light); color: var(--text-primary); font-size: 10px; font-weight: 800; padding: 3px 8px; border-radius: 6px;">
          +5% Sovereign Cashback
        </span>
      </div>
      <h2 style="font-size: 17px; font-weight: 800; color: var(--text-primary); margin-bottom: 8px;">${product.name}</h2>
      <div style="font-size: 22px; font-weight: 900; color: var(--primary-purple); margin-bottom: 16px;">
        ${formatNaira(product.unit_price)}
      </div>

      <div style="border-top: 1px solid var(--border-light); padding-top: 14px;">
        <div style="font-size: 12px; font-weight: 700; color: var(--text-secondary); margin-bottom: 4px;">Merchant Information</div>
        <div style="display: flex; align-items: center; gap: 10px;">
          <i class="fa-solid fa-store" style="color: var(--primary-purple); font-size: 20px;"></i>
          <div>
            <div style="font-size: 14px; font-weight: 800;">${shopName}</div>
            <div style="font-size: 11px; color: var(--text-secondary);">Akwa Ibom State Corridor • In-Shop Pickup Ready</div>
          </div>
        </div>
      </div>

      <div style="border-top: 1px solid var(--border-light); padding-top: 14px; margin-top: 14px;">
        <div style="font-size: 13px; font-weight: 800; margin-bottom: 6px;">Description</div>
        <p style="font-size: 12px; color: var(--text-secondary); line-height: 1.5;">${product.description || 'Verified authentic merchandise certified under Victorious MARKET sovereign compliance guidelines.'}</p>
      </div>

      <div style="margin-top: 24px; display: flex; flex-direction: column; gap: 10px;">
        <button class="btn-primary" onclick="addToCart(${product.id}); switchTab('cart')">
          <i class="fa-solid fa-bag-shopping"></i> Add to Bag & Buy Now
        </button>
        <button class="btn-secondary" style="background: var(--gold-light); border-color: var(--secondary-gold); color: #1a1a1a;" onclick="createQuickReservation(${product.id})">
          <i class="fa-solid fa-store"></i> Reserve for In-Shop Pickup (₦0.00 Paid Upfront)
        </button>
      </div>
    </div>
  `;

  switchTab('details');
}

// Cart Management
function addToCart(productId) {
  const product = state.products.find(p => p.id === productId);
  if (!product) return;

  const existing = state.cart.find(i => i.product.id === productId);
  if (existing) {
    existing.quantity += 1;
  } else {
    state.cart.push({ product, quantity: 1 });
  }

  updateCartBadges();
}

function updateCartQuantity(productId, delta) {
  const item = state.cart.find(i => i.product.id === productId);
  if (!item) return;

  item.quantity += delta;
  if (item.quantity <= 0) {
    state.cart = state.cart.filter(i => i.product.id !== productId);
  }

  updateCartBadges();
  renderCart();
}

function clearCart() {
  state.cart = [];
  updateCartBadges();
  renderCart();
}

function updateCartBadges() {
  const total = state.cart.reduce((sum, i) => sum + i.quantity, 0);
  document.querySelectorAll('.cart-badge-num').forEach(el => el.textContent = total);
  document.querySelectorAll('.cart-pill-count').forEach(el => el.textContent = total);
}

function getCartSubtotal() {
  return state.cart.reduce((sum, i) => sum + (parseFloat(i.product.unit_price) * i.quantity), 0);
}

function renderCart() {
  const container = document.getElementById('cart-content-area');
  if (state.cart.length === 0) {
    container.innerHTML = `
      <div style="text-align: center; padding: 60px 20px;">
        <div style="width: 80px; height: 80px; border-radius: 50%; background: #f1f3f7; display: inline-flex; align-items: center; justify-content: center; font-size: 34px; color: var(--text-muted); margin-bottom: 16px;">
          <i class="fa-solid fa-bag-shopping"></i>
        </div>
        <h3 style="font-size: 18px; font-weight: 800; margin-bottom: 6px;">Your Bag is Empty</h3>
        <p style="font-size: 12px; color: var(--text-secondary); margin-bottom: 24px;">Explore quality products and earn 5% instant sovereign cashback.</p>
        <button class="btn-primary" onclick="switchTab('home')">Start Exploring Market</button>
      </div>
    `;
    return;
  }

  const subtotal = getCartSubtotal();
  const cashbackEarned = subtotal * 0.05;

  container.innerHTML = `
    <div style="display: flex; flex-direction: column; gap: 12px; margin-bottom: 20px;">
      ${state.cart.map(item => `
        <div style="background: white; border-radius: 14px; padding: 12px; display: flex; gap: 12px; border: 1px solid var(--border-light);">
          <img src="${item.product.thumbnail || 'assets/vm_icon.jpg'}" style="width: 64px; height: 64px; border-radius: 8px; object-fit: cover;">
          <div style="flex: 1;">
            <div style="font-size: 13px; font-weight: 700; line-height: 1.3;">${item.product.name}</div>
            <div style="font-size: 14px; font-weight: 900; color: var(--primary-purple); margin: 4px 0;">
              ${formatNaira(parseFloat(item.product.unit_price) * item.quantity)}
            </div>
            <div style="display: flex; align-items: center; gap: 10px;">
              <div style="display: inline-flex; border: 1px solid var(--border-light); border-radius: 6px;">
                <button style="border: none; background: transparent; padding: 2px 8px; cursor: pointer;" onclick="updateCartQuantity(${item.product.id}, -1)">-</button>
                <span style="font-size: 12px; font-weight: 700; padding: 2px 6px;">${item.quantity}</span>
                <button style="border: none; background: transparent; padding: 2px 8px; cursor: pointer;" onclick="updateCartQuantity(${item.product.id}, 1)">+</button>
              </div>
              <button style="border: none; background: transparent; color: var(--danger); font-size: 12px; cursor: pointer;" onclick="updateCartQuantity(${item.product.id}, -999)">
                <i class="fa-solid fa-trash-can"></i>
              </button>
            </div>
          </div>
        </div>
      `).join('')}
    </div>

    <!-- Summary Box -->
    <div style="background: white; border-radius: 16px; padding: 16px; border: 1px solid var(--border-light);">
      <div style="display: flex; justify-content: space-between; margin-bottom: 6px; font-size: 13px;">
        <span style="color: var(--text-secondary);">Subtotal:</span>
        <span style="font-weight: 800;">${formatNaira(subtotal)}</span>
      </div>
      <div style="display: flex; justify-content: space-between; margin-bottom: 12px; font-size: 12px;">
        <span style="color: var(--success); font-weight: 700;">+5% Cashback Reward:</span>
        <span style="color: var(--success); font-weight: 800;">+${formatNaira(cashbackEarned)}</span>
      </div>
      <div style="border-top: 1px solid var(--border-light); padding-top: 12px; margin-bottom: 16px; display: flex; justify-content: space-between;">
        <span style="font-weight: 900; font-size: 15px;">Payable Now:</span>
        <span style="font-weight: 900; font-size: 18px; color: var(--primary-purple);">${formatNaira(subtotal)}</span>
      </div>
      <button class="btn-primary" onclick="switchTab('checkout')">
        Proceed to Directional Checkout <i class="fa-solid fa-arrow-right"></i>
      </button>
    </div>
  `;
}

// Directional Checkout Screen
function renderCheckout() {
  const container = document.getElementById('checkout-content-area');
  const subtotal = getCartSubtotal() || 320000;
  const deliveryFee = state.fulfillmentType === 'doorstep_delivery' ? 500 : 0;
  const cashbackDiscount = state.redeemCashback ? 2500 : 0;
  const total = subtotal + deliveryFee - cashbackDiscount;

  container.innerHTML = `
    <!-- Mode Switcher -->
    <div style="display: flex; background: #e9ecef; border-radius: 12px; padding: 4px; margin-bottom: 16px;">
      <button style="flex: 1; padding: 10px; border: none; border-radius: 8px; font-weight: 700; font-size: 12px; cursor: pointer; ${state.fulfillmentType === 'doorstep_delivery' ? 'background: var(--primary-purple); color: white;' : 'background: transparent; color: var(--text-secondary);'}" onclick="setFulfillment('doorstep_delivery')">
        <i class="fa-solid fa-truck"></i> Doorstep Delivery
      </button>
      <button style="flex: 1; padding: 10px; border: none; border-radius: 8px; font-weight: 700; font-size: 12px; cursor: pointer; ${state.fulfillmentType === 'in_shop_pickup' ? 'background: var(--primary-purple); color: white;' : 'background: transparent; color: var(--text-secondary);'}" onclick="setFulfillment('in_shop_pickup')">
        <i class="fa-solid fa-store"></i> In-Shop Pickup
      </button>
    </div>

    ${state.fulfillmentType === 'doorstep_delivery' ? `
      <!-- Address Card -->
      <div style="background: white; border-radius: 14px; padding: 14px; border: 1.5px solid var(--primary-purple); margin-bottom: 14px;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
          <span style="font-size: 13px; font-weight: 800;"><i class="fa-solid fa-location-dot" style="color: var(--primary-purple);"></i> Victor Akpan (Home)</span>
          <span style="font-size: 11px; color: var(--text-secondary);">+2348011110001</span>
        </div>
        <p style="font-size: 12px; color: var(--text-secondary);">14 Aka Road, Shelter Afrique Estate, Uyo LGA, Akwa Ibom State</p>
      </div>

      <!-- Live Directional Lane Result Card -->
      <div style="background: var(--success-light); border: 1px solid var(--success); border-radius: 12px; padding: 12px; margin-bottom: 16px; display: flex; align-items: center; justify-content: space-between;">
        <div style="display: flex; align-items: center; gap: 10px;">
          <i class="fa-solid fa-route" style="color: var(--success); font-size: 20px;"></i>
          <div>
            <div style="font-size: 12px; font-weight: 800; color: #1a1a1a;">Uyo ➔ Uyo Directional Lane</div>
            <div style="font-size: 11px; color: var(--text-secondary);">Authoritative fee by FulfillmentService (2-6 hours)</div>
          </div>
        </div>
        <div style="font-size: 15px; font-weight: 900; color: var(--primary-purple);">₦500.00</div>
      </div>
    ` : `
      <!-- In-Shop Pickup Info -->
      <div style="background: var(--gold-light); border: 1.2px solid var(--secondary-gold); border-radius: 14px; padding: 14px; margin-bottom: 16px;">
        <div style="font-size: 13px; font-weight: 800; color: #1a1a1a; margin-bottom: 4px;">
          <i class="fa-solid fa-shield-halved" style="color: var(--primary-purple);"></i> The Akwa Ibom Trust Model
        </div>
        <p style="font-size: 11px; color: #333; line-height: 1.4;">
          Your item is locked for 24 hours at the shop. Visit, physically examine the product in person, and pay digitally at the counter once 100% satisfied. (₦0.00 Delivery Fee).
        </p>
      </div>
    `}

    <!-- Cashback Toggle -->
    <div style="background: white; border-radius: 14px; padding: 12px 16px; border: 1.5px solid var(--secondary-gold); display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px;">
      <div>
        <div style="font-size: 13px; font-weight: 800;"><i class="fa-solid fa-stars" style="color: var(--gold-dark);"></i> Redeem Sovereign Cashback</div>
        <div style="font-size: 11px; color: var(--text-secondary);">Apply available ₦2,500.00 discount</div>
      </div>
      <input type="checkbox" style="width: 20px; height: 20px; accent-color: var(--primary-purple); cursor: pointer;" ${state.redeemCashback ? 'checked' : ''} onchange="toggleCashback(this.checked)">
    </div>

    <!-- Final Price Breakdown -->
    <div style="background: white; border-radius: 14px; padding: 16px; border: 1px solid var(--border-light); margin-bottom: 20px;">
      <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 6px;">
        <span style="color: var(--text-secondary);">Merchandise Subtotal:</span>
        <span style="font-weight: 700;">${formatNaira(subtotal)}</span>
      </div>
      <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 6px;">
        <span style="color: var(--text-secondary);">Directional Delivery:</span>
        <span style="font-weight: 700;">${formatNaira(deliveryFee)}</span>
      </div>
      ${state.redeemCashback ? `
        <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 6px;">
          <span style="color: var(--success); font-weight: 700;">Cashback Discount:</span>
          <span style="color: var(--success); font-weight: 700;">-₦2,500.00</span>
        </div>
      ` : ''}
      <div style="border-top: 1px solid var(--border-light); padding-top: 10px; margin-top: 10px; display: flex; justify-content: space-between;">
        <span style="font-size: 16px; font-weight: 900;">Grand Total:</span>
        <span style="font-size: 19px; font-weight: 900; color: var(--primary-purple);">${formatNaira(total)}</span>
      </div>
    </div>

    <button class="btn-primary" onclick="confirmPaymentAndTrack()">
      <i class="fa-solid fa-lock"></i> ${state.fulfillmentType === 'doorstep_delivery' ? 'Pay with Paystack' : 'Confirm In-Shop Reservation'}
    </button>
  `;
}

function setFulfillment(type) {
  state.fulfillmentType = type;
  renderCheckout();
}

function toggleCashback(checked) {
  state.redeemCashback = checked;
  renderCheckout();
}

function confirmPaymentAndTrack() {
  clearCart();
  alert('Payment verified via Paystack! Order created with live delivery tracking and Secret 6-Digit Delivery PIN.');
  switchTab('orders');
}

// In-Shop Reservation Demo
function openReservationDemo() {
  const container = document.getElementById('reservation-pass-area');
  const res = state.activeReservation;

  container.innerHTML = `
    <div style="background: var(--purple-gradient); border-radius: 20px; padding: 24px; color: white; text-align: center; box-shadow: 0 10px 30px rgba(94, 23, 235, 0.4); margin-bottom: 20px;">
      <div style="display: inline-block; background: var(--secondary-gold); color: #1a1a1a; font-size: 10px; font-weight: 900; padding: 3px 12px; border-radius: 20px; margin-bottom: 14px;">
        24-HOUR STOCK RESERVATION (₦0.00 PAID)
      </div>
      <div style="font-size: 11px; letter-spacing: 2px; color: rgba(255,255,255,0.7); font-weight: 700;">RESERVATION PASS CODE</div>
      <div style="font-size: 30px; font-weight: 900; letter-spacing: 4px; color: var(--secondary-gold); margin: 6px 0 16px 0;">
        ${res.code}
      </div>

      <!-- QR Code Placeholder -->
      <div style="background: white; border-radius: 14px; padding: 14px; display: inline-block; margin-bottom: 14px;">
        <img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=${res.code}" style="width: 140px; height: 140px; display: block;" onerror="this.src='assets/vm_icon.jpg'">
      </div>

      <div style="font-size: 13px; font-weight: 700;">${res.productName} (Qty: ${res.qty})</div>
      <div style="font-size: 12px; color: var(--secondary-gold); font-weight: 700; margin-top: 4px;">Pay at Shop: ${res.total}</div>
    </div>

    <!-- Merchant Branch Location -->
    <div style="background: white; border-radius: 16px; padding: 16px; border: 1px solid var(--border-light); margin-bottom: 20px;">
      <div style="font-size: 14px; font-weight: 800; margin-bottom: 4px;"><i class="fa-solid fa-store" style="color: var(--primary-purple);"></i> ${res.shopName}</div>
      <div style="font-size: 12px; color: var(--text-secondary); margin-bottom: 12px;">${res.shopAddress}</div>
      <div style="font-size: 12px; font-weight: 700; margin-bottom: 6px;">Inspection Instructions:</div>
      <ol style="font-size: 11px; color: var(--text-secondary); line-height: 1.5; padding-left: 18px;">
        <li>Visit the merchant branch before the 24-hr countdown expires.</li>
        <li>Present this reservation pass code or QR code to the counter staff.</li>
        <li>Physically inspect and test your item.</li>
        <li>Pay digitally when satisfied to release custody.</li>
      </ol>
    </div>

    <button class="btn-primary" onclick="switchTab('home')">Back to Marketplace</button>
  `;

  switchTab('reservation-pass');
}

function createQuickReservation(productId) {
  const product = state.products.find(p => p.id === productId);
  if (product) {
    state.activeReservation.productName = product.name;
    state.activeReservation.total = formatNaira(product.unit_price);
    state.activeReservation.shopName = (product.shop && product.shop.name) ? product.shop.name : 'Merchant Plaza';
  }
  openReservationDemo();
}

// Orders & Live Tracking View
function renderOrders() {
  const container = document.getElementById('orders-content-area');
  const o = state.activeOrder;

  container.innerHTML = `
    <!-- Secret 6-Digit Delivery PIN Card -->
    <div class="otp-gold-card">
      <div class="otp-title"><i class="fa-solid fa-shield-halved"></i> SECRET 6-DIGIT DELIVERY PIN</div>
      <div class="otp-digits-box" onclick="copyOtp('${o.otp}')">
        <span class="otp-number">${o.otp}</span>
        <i class="fa-solid fa-copy" style="color: var(--text-secondary);"></i>
      </div>
      <div class="otp-rule-box">
        <i class="fa-solid fa-triangle-exclamation"></i> Give this PIN to the courier ONLY AFTER physically inspecting your package at your doorstep.
      </div>
    </div>

    <!-- 5-Stage Live Progress Stepper -->
    <div class="stepper-wrap">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
        <span style="font-size: 13px; font-weight: 800;">Order: ${o.orderNumber}</span>
        <span style="background: rgba(94, 23, 235, 0.1); color: var(--primary-purple); font-size: 9px; font-weight: 900; padding: 2px 8px; border-radius: 10px;">
          ${o.statusText}
        </span>
      </div>

      <div class="step-row">
        <div class="step-marker-col">
          <div class="step-circle done"><i class="fa-solid fa-check"></i></div>
          <div class="step-line done"></div>
        </div>
        <div class="step-info">
          <h5>Order Confirmed</h5>
          <p>Payment settled & order locked</p>
        </div>
      </div>

      <div class="step-row">
        <div class="step-marker-col">
          <div class="step-circle done"><i class="fa-solid fa-check"></i></div>
          <div class="step-line done"></div>
        </div>
        <div class="step-info">
          <h5>Processing</h5>
          <p>Merchant package verification sign-off</p>
        </div>
      </div>

      <div class="step-row">
        <div class="step-marker-col">
          <div class="step-circle done"><i class="fa-solid fa-check"></i></div>
          <div class="step-line done"></div>
        </div>
        <div class="step-info">
          <h5>Counter Handover</h5>
          <p>Courier picked up package at counter</p>
        </div>
      </div>

      <div class="step-row">
        <div class="step-marker-col">
          <div class="step-circle active">4</div>
          <div class="step-line"></div>
        </div>
        <div class="step-info">
          <h5 style="color: var(--primary-purple);">Out for Delivery</h5>
          <p>Courier in transit to your doorstep</p>
        </div>
      </div>

      <div class="step-row">
        <div class="step-marker-col">
          <div class="step-circle">5</div>
        </div>
        <div class="step-info">
          <h5>Delivered</h5>
          <p>Custody finalized upon PIN entry</p>
        </div>
      </div>
    </div>

    <!-- Assigned Rider Card -->
    <div style="background: white; border-radius: 16px; padding: 14px; border: 1px solid var(--border-light); display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px;">
      <div style="display: flex; align-items: center; gap: 12px;">
        <div style="width: 44px; height: 44px; border-radius: 50%; background: rgba(94, 23, 235, 0.1); display: flex; align-items: center; justify-content: center; color: var(--primary-purple); font-size: 20px;">
          <i class="fa-solid fa-motorcycle"></i>
        </div>
        <div>
          <div style="font-size: 14px; font-weight: 800;">${o.courierName}</div>
          <div style="font-size: 11px; color: var(--text-secondary);">${o.courierVehicle}</div>
        </div>
      </div>
      <button style="background: var(--primary-purple); color: white; border: none; border-radius: 50%; width: 36px; height: 36px; cursor: pointer;" onclick="alert('Calling courier: ${o.courierPhone}')">
        <i class="fa-solid fa-phone"></i>
      </button>
    </div>

    <!-- Doorstep Confirmation Button -->
    <button class="btn-primary" style="background: var(--success);" onclick="confirmCustomerReceipt()">
      <i class="fa-solid fa-circle-check"></i> Customer Confirm Parcel Received
    </button>
  `;
}

function copyOtp(pin) {
  navigator.clipboard.writeText(pin);
  alert('Secret 6-Digit Delivery PIN copied: ' + pin);
}

function confirmCustomerReceipt() {
  state.activeOrder.statusStep = 4;
  state.activeOrder.statusText = 'DELIVERED';
  alert('Delivery custody confirmed! 5% cashback has been credited to your sovereign rewards wallet.');
  renderOrders();
}

// Explore Screen Rendering
function renderExploreCategories() {
  const container = document.getElementById('explore-category-pills');
  container.innerHTML = `
    <div class="lga-chip active" onclick="filterCategory(null, this)">All</div>
    ${state.categories.map(c => `
      <div class="lga-chip" onclick="filterCategory('${c.slug}', this)">${c.name}</div>
    `).join('')}
  `;
}

function renderExplore() {
  const grid = document.getElementById('explore-products-grid');
  grid.innerHTML = state.products.map(p => createProductCardHtml(p)).join('');
}

function handleSearch(query) {
  const q = query.toLowerCase();
  const filtered = state.products.filter(p => p.name.toLowerCase().includes(q));
  const grid = document.getElementById('explore-products-grid');
  grid.innerHTML = filtered.map(p => createProductCardHtml(p)).join('');
}

function filterCategory(slug, el) {
  if (el) {
    el.parentElement.querySelectorAll('.lga-chip').forEach(c => c.classList.remove('active'));
    el.classList.add('active');
  }
  const filtered = slug ? state.products.filter(p => p.category && p.category.slug === slug) : state.products;
  const grid = document.getElementById('explore-products-grid');
  grid.innerHTML = (filtered.length > 0 ? filtered : state.products).map(p => createProductCardHtml(p)).join('');
  switchTab('explore');
}

function filterLga(lgaId, el) {
  if (el) {
    el.parentElement.querySelectorAll('.lga-chip').forEach(c => c.classList.remove('active'));
    el.classList.add('active');
  }
  state.activeLgaId = lgaId;
  renderHomeProducts();
}

// Support & Calls
function triggerCall() {
  alert('Dialing Victorious MARKET Call-to-Order Line: +2349118949035');
}

function triggerWhatsApp() {
  window.open('https://wa.me/2349118949035?text=Hello%20Victorious%20MARKET,%20I%20need%20assistance', '_blank');
}

// Stores Closer to You (Matching _shops_grid.blade.php)
function renderStoresCloserToYou() {
  const container = document.getElementById('home-shops-grid');
  const cityLabel = document.getElementById('proximity-city-name');
  if (cityLabel) cityLabel.textContent = state.selectedCity;
  if (!container) return;

  const filteredShops = state.shops.filter(s => s.lga_id === state.selectedLgaId);
  const displayShops = filteredShops.length > 0 ? filteredShops : state.shops;

  container.innerHTML = displayShops.slice(0, 4).map(s => `
    <div class="shop-tile" onclick="openShopProfile(${s.id})">
      <div class="shop-tile-thumb-wrap">
        <img src="${s.logo}" alt="${s.name}" onerror="this.src='assets/vm_icon.jpg'">
        <span class="shop-tile-floating-badge">🏪 ${s.lga_name} Plaza</span>
      </div>
      <div class="shop-tile-name">${s.name}</div>
      <div class="shop-tile-sub">In-Shop Inspection Ready</div>
    </div>
  `).join('');
}

// Comprehensive Nigerian Geography Dataset for Multi-State Support
const nigeriaGeography = [
  // Akwa Ibom State
  { name: 'Uyo', state: 'Akwa Ibom', id: 69 },
  { name: 'Eket', state: 'Akwa Ibom', id: 70 },
  { name: 'Ikot Ekpene', state: 'Akwa Ibom', id: 71 },
  { name: 'Oron', state: 'Akwa Ibom', id: 72 },
  { name: 'Abak', state: 'Akwa Ibom', id: 65 },
  { name: 'Ikot Abasi', state: 'Akwa Ibom', id: 66 },
  { name: 'Etinan', state: 'Akwa Ibom', id: 67 },
  { name: 'Ibiono Ibom', state: 'Akwa Ibom', id: 68 },
  { name: 'Itu', state: 'Akwa Ibom', id: 73 },

  // Lagos State
  { name: 'Ikeja', state: 'Lagos', id: 101 },
  { name: 'Lekki / Eti-Osa', state: 'Lagos', id: 102 },
  { name: 'Surulere', state: 'Lagos', id: 103 },
  { name: 'Alimosho', state: 'Lagos', id: 104 },
  { name: 'Lagos Island', state: 'Lagos', id: 105 },
  { name: 'Kosofe', state: 'Lagos', id: 106 },
  { name: 'Oshodi-Isolo', state: 'Lagos', id: 107 },
  { name: 'Ikorodu', state: 'Lagos', id: 108 },

  // Rivers State
  { name: 'Port Harcourt', state: 'Rivers', id: 201 },
  { name: 'Obio-Akpor', state: 'Rivers', id: 202 },
  { name: 'Eleme', state: 'Rivers', id: 203 },
  { name: 'Oyigbo', state: 'Rivers', id: 204 },

  // FCT Abuja
  { name: 'Abuja Municipal (AMAC)', state: 'FCT Abuja', id: 301 },
  { name: 'Bwari', state: 'FCT Abuja', id: 302 },
  { name: 'Gwagwalada', state: 'FCT Abuja', id: 303 },
  { name: 'Kuje', state: 'FCT Abuja', id: 304 },

  // Cross River State
  { name: 'Calabar Municipal', state: 'Cross River', id: 401 },
  { name: 'Calabar South', state: 'Cross River', id: 402 },
  { name: 'Ikom', state: 'Cross River', id: 403 },

  // Delta State
  { name: 'Warri South', state: 'Delta', id: 501 },
  { name: 'Oshimili South (Asaba)', state: 'Delta', id: 502 },
  { name: 'Uvwie (Effurun)', state: 'Delta', id: 503 },

  // Edo State
  { name: 'Oredo (Benin City)', state: 'Edo', id: 601 },
  { name: 'Ikpoba-Okha', state: 'Edo', id: 602 },

  // Enugu State
  { name: 'Enugu North', state: 'Enugu', id: 701 },
  { name: 'Enugu South', state: 'Enugu', id: 702 },

  // Anambra State
  { name: 'Onitsha North', state: 'Anambra', id: 801 },
  { name: 'Awka South', state: 'Anambra', id: 803 },

  // Oyo State
  { name: 'Ibadan North', state: 'Oyo', id: 901 },
  { name: 'Ibadan South-West', state: 'Oyo', id: 902 },

  // Kano State
  { name: 'Kano Municipal', state: 'Kano', id: 1001 },
  { name: 'Fagge', state: 'Kano', id: 1003 },

  // Kaduna State
  { name: 'Kaduna North', state: 'Kaduna', id: 1101 },
  { name: 'Zaria', state: 'Kaduna', id: 1103 },

  // Imo State
  { name: 'Owerri Municipal', state: 'Imo', id: 1201 },

  // Abia State
  { name: 'Aba North', state: 'Abia', id: 1301 },
  { name: 'Umuahia North', state: 'Abia', id: 1303 }
];

// Interactive Location Modal Functions (Matching newVmarket vmLocationModal)
function openLocationModal() {
  document.getElementById('locationModal').classList.add('active');
  document.getElementById('locationModalOverlay').classList.add('active');
  handleStateFilterChange(state.selectedState || 'Akwa Ibom');
  updateModalFeedback(state.selectedCity, state.selectedState, state.selectedLgaId);
}

function closeLocationModal() {
  document.getElementById('locationModal').classList.remove('active');
  document.getElementById('locationModalOverlay').classList.remove('active');
  const sug = document.getElementById('lgaSuggestionsList');
  if (sug) sug.style.display = 'none';
}

function handleStateFilterChange(stateName) {
  const container = document.getElementById('modalStateLgasWrap');
  const header = document.getElementById('modalLgasHeader');
  if (!container) return;

  if (header) {
    header.textContent = `LOCAL GOVERNMENTS IN ${stateName.toUpperCase()}:`;
  }

  const lgas = stateName === 'All' 
    ? nigeriaGeography 
    : nigeriaGeography.filter(l => l.state.toLowerCase() === stateName.toLowerCase());

  if (lgas.length === 0) {
    container.innerHTML = `<p style="font-size: 11px; color: var(--text-secondary); margin: 4px 0;">Dispatches to ${stateName} via Nationwide Transit.</p>`;
    return;
  }

  container.innerHTML = lgas.map(lga => {
    const isSelected = (state.pendingLgaId || state.selectedLgaId) === lga.id;
    return `
      <button type="button" class="city-chip ${isSelected ? 'active' : ''}" onclick="selectLocation('${lga.name}', '${lga.state}', ${lga.id}, this)">
        <span class="dot"></span> ${lga.name} LGA
      </button>
    `;
  }).join('');
}

function selectLocation(city, stateName, lgaId, btnEl) {
  state.pendingCity = city;
  state.pendingState = stateName;
  state.pendingLgaId = lgaId;

  if (btnEl) {
    document.querySelectorAll('.city-chip').forEach(c => c.classList.remove('active'));
    btnEl.classList.add('active');
  }

  updateModalFeedback(city, stateName, lgaId);
}

function updateModalFeedback(city, stateName, lgaId) {
  const hasLocal = state.shops.some(s => s.lga_id === lgaId);
  let statusText = '';
  let badgeText = '';

  if (hasLocal || [69, 70, 71, 72].includes(lgaId)) {
    statusText = '⚡ In-Shop Pickup & Same-Day Delivery Active';
    badgeText = '⚡ In-Shop Pickup & Same-Day Active';
  } else if ([65, 66, 67, 101, 102, 201, 301].includes(lgaId)) {
    statusText = '🚚 Transit Delivery Corridor Active (12-24 hrs)';
    badgeText = '🚚 Transit Delivery Corridor Active';
  } else {
    statusText = '📦 Nationwide Park Dispatch Active';
    badgeText = '📦 Nationwide Park Dispatch';
  }

  const prevCity = document.getElementById('modalPreviewCity');
  const prevStatus = document.getElementById('modalPreviewStatus');
  if (prevCity) prevCity.textContent = `${city}, ${stateName} State`;
  if (prevStatus) prevStatus.textContent = statusText;

  state.statusBadge = badgeText;
}

function handleLgaSearch(query) {
  const sug = document.getElementById('lgaSuggestionsList');
  if (!query || query.trim().length === 0) {
    if (sug) sug.style.display = 'none';
    return;
  }

  const q = query.toLowerCase().trim();
  const matched = nigeriaGeography.filter(l => l.name.toLowerCase().includes(q) || l.state.toLowerCase().includes(q));

  if (matched.length > 0) {
    sug.innerHTML = matched.map(m => `
      <div class="lga-suggestion-item" onclick="selectLocation('${m.name}', '${m.state}', ${m.id}); document.getElementById('lgaSearchInput').value = '${m.name}'; document.getElementById('lgaSuggestionsList').style.display = 'none';">
        <i class="fa-solid fa-location-dot" style="color: var(--primary-purple); margin-right: 6px;"></i>
        <strong>${m.name} LGA</strong> <span style="color: var(--text-secondary); font-size: 11px;">(${m.state} State)</span>
      </div>
    `).join('');
    sug.style.display = 'block';
  } else {
    sug.style.display = 'none';
  }
}

function clearLgaSearch() {
  const inp = document.getElementById('lgaSearchInput');
  if (inp) inp.value = '';
  const sug = document.getElementById('lgaSuggestionsList');
  if (sug) sug.style.display = 'none';
}

function confirmLocationSelection() {
  state.selectedCity = state.pendingCity || state.selectedCity;
  state.selectedState = state.pendingState || state.selectedState;
  state.selectedLgaId = state.pendingLgaId || state.selectedLgaId;
  state.activeLgaId = state.selectedLgaId;

  // Update header pill
  const headCity = document.getElementById('header-location-city');
  if (headCity) headCity.textContent = state.selectedCity;

  // Update proximity strip
  const badge = document.getElementById('proximity-coverage-badge');
  if (badge) badge.textContent = state.statusBadge;

  // Update stores proximity title
  const proxCity = document.getElementById('proximity-city-name');
  if (proxCity) proxCity.textContent = state.selectedCity;

  closeLocationModal();

  // Re-render marketplace with new location context
  renderHome();
}

// Dedicated Merchant Shop Profile (Matching shop.blade.php)
function openShopProfile(shopId) {
  const shop = state.shops.find(s => s.id === shopId) || state.shops[0];
  state.selectedShop = shop;

  const title = document.getElementById('shop-header-title');
  if (title) title.textContent = shop.name;

  const content = document.getElementById('shop-profile-content');
  const shopProducts = state.products.filter(p => p.shop && p.shop.name === shop.name);
  const displayProducts = shopProducts.length > 0 ? shopProducts : state.products.slice(0, 3);

  content.innerHTML = `
    <!-- Shop Banner Card -->
    <div style="background: white; padding: 20px 16px; border-bottom: 1px solid var(--border-light); text-align: center;">
      <img src="${shop.logo}" style="width: 72px; height: 72px; border-radius: 14px; object-fit: cover; border: 2px solid var(--primary-purple); margin-bottom: 10px; box-shadow: 0 4px 12px rgba(94,23,235,0.15);">
      <h2 style="font-size: 17px; font-weight: 900; margin: 0 0 4px 0; color: #0F172A;">${shop.name}</h2>
      <div style="display: inline-flex; align-items: center; gap: 6px; background: rgba(94,23,235,0.08); color: var(--primary-purple); font-size: 11px; font-weight: 800; padding: 3px 10px; border-radius: 20px; margin-bottom: 8px;">
        <i class="fa-solid fa-store"></i> ${shop.lga_name} Commercial Corridor
      </div>
      <p style="font-size: 11.5px; color: var(--text-secondary); margin: 0; line-height: 1.4;">${shop.description}</p>
      
      <!-- In-Shop Trust Badge -->
      <div style="margin-top: 14px; background: var(--gold-light); border: 1.2px solid var(--secondary-gold); border-radius: 10px; padding: 10px 12px; display: flex; align-items: center; gap: 10px; text-align: left;">
        <i class="fa-solid fa-shield-halved" style="color: var(--primary-purple); font-size: 20px;"></i>
        <div>
          <div style="font-size: 12px; font-weight: 800; color: #1E293B;">Verified In-Shop Inspection Partner</div>
          <div style="font-size: 10.5px; color: #475569;">Walk in and inspect items at ${shop.address} with ₦0.00 down.</div>
        </div>
      </div>
    </div>

    <!-- Shop Catalog Feed -->
    <div style="padding: 16px;">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 12px;">
        <h3 style="font-size: 14px; font-weight: 800; margin: 0; color: #0F172A;">Verified Merchant Items (${displayProducts.length})</h3>
        <span style="font-size: 11px; color: var(--text-secondary); font-weight: 600;">Fresh 7-Day Stock</span>
      </div>
      <div class="product-grid">
        ${displayProducts.map(p => createProductCardHtml(p)).join('')}
      </div>
    </div>
  `;

  switchTab('shop');
}
