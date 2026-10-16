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
  redeemWalletCredit: false,
  walletCreditAvailable: 320000,
  activeOrder: {
    orderNumber: 'VM-ORD-9081',
    otp: '883921',
    courierPickupOtp: '482910',
    riderArrived: false,
    statusStep: 3,
    statusText: 'OUT FOR DELIVERY',
    pickupCounterPhoto: 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=400&q=80',
    doorstepDeliveryPhoto: null,
    deliveryAttemptPhoto: null,
    deliveryFailureReason: null,
    walletCreditApplied: '0.00',
    items: [
      {
        name: 'Samsung Galaxy A54 5G 128GB Awesome Violet',
        qty: 1,
        price: '₦320,000.00',
        acceptedQty: 1,
        rejectedQty: 0,
        rejectionCategory: null,
        defectPhoto: null
      }
    ],
    subtotal: '₦320,000.00',
    deliveryFee: '₦500.00',
    total: '₦320,500.00',
    cashbackEarned: '₦16,000.00',
    courierName: 'Emeka Okon (Rider Dispatch)',
    courierPhone: '+2348039120491',
    courierVehicle: 'TVS HLX Plus (UYO-123-AK)',
    shopName: 'MegaTech Uyo Plaza',
    shopAddress: '10 Aka Road, Uyo Plaza'
  },
  activeReservation: {
    code: 'RES-884291',
    productName: 'Samsung Galaxy A54 5G 128GB Awesome Violet',
    qty: 1,
    total: '₦320,000.00',
    shopName: 'MegaTech Uyo Plaza',
    shopAddress: '10 Aka Road, Uyo Plaza',
    expiresIn: '23h 59m'
  },
  returnCases: [
    {
      caseNumber: 'RET-20261016-0001',
      orderNumber: 'VM-ORD-9081',
      status: 'opened',
      statusLabel: 'Under Review',
      reason: 'defective_product',
      reasonLabel: 'Defective / Not Working',
      amount: '₦320,000.00',
      description: 'Screen does not turn on even after charging for 2 hours.',
      vendorOtp: '782901',
      date: 'Today, 12:15 PM'
    }
  ],
  walletCredits: {
    available: '₦320,000.00',
    history: [
      {
        id: 1,
        type: 'Doorstep Rejection Refund',
        amount: '₦320,000.00',
        status: 'AVAILABLE',
        notes: 'Doorstep parcel refusal refund for order VM-ORD-9081',
        date: 'Today, 12:30 PM'
      }
    ]
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
    youtube_video_id: 'eWpT35yFv4c',
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
function switchTab(tabId, extra) {
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
  document.querySelectorAll('.nav-pill-btn').forEach(btn => {
    btn.classList.remove('active');
    const oc = btn.getAttribute('onclick') || '';
    if (oc.includes(`'${tabId}'`)) btn.classList.add('active');
  });
  
  // Viewport scroll to top
  const vp = document.getElementById('viewport');
  if (vp) vp.scrollTop = 0;

  if (tabId === 'cart') renderCart();
  if (tabId === 'checkout') renderCheckout();
  if (tabId === 'orders') renderOrders();
  if (tabId === 'explore') renderExplore();
  if (tabId === 'returns') renderReturns(extra);
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

      ${product.youtube_video_id ? `
        <!-- Verified Product Demonstration Video (Zero-Trust YouTube Stream) -->
        <div style="border-top: 1px solid var(--border-light); padding-top: 14px; margin-top: 14px;">
          <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
            <div style="font-size: 13px; font-weight: 800; color: #0F172A; display: flex; align-items: center; gap: 6px;">
              <i class="fa-brands fa-youtube" style="color: #EF4444; font-size: 18px;"></i> Verified Demonstration Video
            </div>
            <span style="background: #FEE2E2; color: #DC2626; font-size: 9.5px; font-weight: 900; padding: 2px 8px; border-radius: 6px;">
              YouTube HD
            </span>
          </div>
          <div style="border-radius: 12px; overflow: hidden; position: relative; padding-top: 56.25%; background: #000; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
            <iframe 
              style="position: absolute; top: 0; left: 0; width: 100%; height: 100%; border: none;"
              src="https://www.youtube-nocookie.com/embed/${product.youtube_video_id}?rel=0" 
              title="${product.name} Video Review"
              allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" 
              sandbox="allow-scripts allow-same-origin allow-presentation"
              allowfullscreen>
            </iframe>
          </div>
          <div style="font-size: 10.5px; color: #64748B; margin-top: 6px; display: flex; align-items: center; gap: 4px;">
            <i class="fa-solid fa-shield-halved" style="color: var(--primary-purple);"></i> Zero-Trust Stream: No server-side HTTP calls. Sandboxed Google CDN.
          </div>
        </div>
      ` : ''}

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

  if (state.cart.length > 0 && product.shop && state.cart[0].product.shop) {
    if (state.cart[0].product.shop.name !== product.shop.name) {
      const confirmClear = confirm(
        `Single-Store Checkout: Your bag currently contains items from ${state.cart[0].product.shop.name}. Would you like to clear your bag and start a new order from ${product.shop.name}?`
      );
      if (!confirmClear) return;
      state.cart = [];
    }
  }

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
  const grossTotal = Math.max(0, subtotal + deliveryFee - cashbackDiscount);
  const walletCreditDeduction = state.redeemWalletCredit ? Math.min(grossTotal, state.walletCreditAvailable) : 0;
  const netPayable = Math.max(0, grossTotal - walletCreditDeduction);

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

    <!-- Spendable Wallet Credit 100% Toggle -->
    <div style="background: #F0FDF4; border-radius: 14px; padding: 12px 16px; border: 1.5px solid #22C55E; display: flex; align-items: center; justify-content: space-between; margin-bottom: 12px;">
      <div>
        <div style="font-size: 13px; font-weight: 800; color: #166534;"><i class="fa-solid fa-wallet"></i> Apply Spendable Wallet Credit (100%)</div>
        <div style="font-size: 11px; color: #15803D;">Available balance: ${formatNaira(state.walletCreditAvailable)}</div>
      </div>
      <input type="checkbox" style="width: 20px; height: 20px; accent-color: #16A34A; cursor: pointer;" ${state.redeemWalletCredit ? 'checked' : ''} onchange="toggleWalletCredit(this.checked)">
    </div>

    <!-- Cashback Toggle -->
    <div style="background: white; border-radius: 14px; padding: 12px 16px; border: 1.5px solid var(--secondary-gold); display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px;">
      <div>
        <div style="font-size: 13px; font-weight: 800;"><i class="fa-solid fa-stars" style="color: var(--gold-dark);"></i> Redeem Sovereign Cashback</div>
        <div style="font-size: 11px; color: var(--text-secondary);">Apply available ₦2,500.00 reward discount</div>
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
      ${state.redeemWalletCredit && walletCreditDeduction > 0 ? `
        <div style="display: flex; justify-content: space-between; font-size: 13px; margin-bottom: 6px;">
          <span style="color: #16A34A; font-weight: 700;">Wallet Credit Applied:</span>
          <span style="color: #16A34A; font-weight: 700;">-${formatNaira(walletCreditDeduction)}</span>
        </div>
      ` : ''}
      <div style="border-top: 1px solid var(--border-light); padding-top: 10px; margin-top: 10px; display: flex; justify-content: space-between;">
        <span style="font-size: 16px; font-weight: 900;">Payable Now:</span>
        <span style="font-size: 19px; font-weight: 900; color: ${netPayable === 0 ? '#16A34A' : 'var(--primary-purple)'};">${formatNaira(netPayable)}</span>
      </div>
    </div>

    <button class="btn-primary" style="${netPayable === 0 ? 'background: #16A34A;' : ''}" onclick="confirmPaymentAndTrack(${netPayable === 0})">
      <i class="fa-solid fa-lock"></i> ${
        state.fulfillmentType === 'in_shop_pickup'
          ? 'Confirm In-Shop Reservation'
          : (netPayable === 0 ? 'Instant 100% Wallet Settlement (₦0.00)' : 'Pay with Paystack (' + formatNaira(netPayable) + ')')
      }
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

function toggleWalletCredit(checked) {
  state.redeemWalletCredit = checked;
  renderCheckout();
}

function confirmPaymentAndTrack(isWalletSettled) {
  clearCart();
  if (isWalletSettled) {
    state.activeOrder.walletCreditApplied = state.activeOrder.total;
    alert('Instant 100% Wallet Settlement Complete!\nNo card charges incurred. Your order is locked with doorstep OTP custody.');
  } else {
    alert('Payment verified via Paystack! Order created with live delivery tracking and Secret 6-Digit Delivery PIN.');
  }
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

  const isDelivered = o.statusStep >= 4;
  const riderArrived = o.riderArrived && !isDelivered;

  container.innerHTML = `
    <!-- Top Action / State Card -->
    ${riderArrived ? `
      <!-- Doorstep Arrival Code Entry Card (Active when Courier is outside) -->
      <div style="background: var(--purple-gradient); border-radius: 20px; padding: 22px; color: white; margin-bottom: 20px; box-shadow: 0 10px 25px rgba(94, 23, 235, 0.4); border: 2px solid var(--secondary-gold);">
        <div style="display: flex; align-items: center; gap: 12px; margin-bottom: 12px;">
          <div style="width: 36px; height: 36px; border-radius: 50%; background: var(--secondary-gold); display: flex; align-items: center; justify-content: center; color: #1a1a1a; font-size: 18px;">
            <i class="fa-solid fa-bell"></i>
          </div>
          <div>
            <div style="font-size: 11px; font-weight: 900; letter-spacing: 1.2px; color: var(--secondary-gold);">COURIER HAS ARRIVED!</div>
            <div style="font-size: 15px; font-weight: 800;">${o.courierName} is at your doorstep</div>
          </div>
        </div>

        <p style="font-size: 12px; color: rgba(255,255,255,0.85); line-height: 1.4; margin-bottom: 14px;">
          Physically inspect your parcel and security seal first. Once satisfied, enter the 6-digit Delivery Code received via SMS/WhatsApp below to confirm receipt:
        </p>

        <!-- 6-Digit Code Input Field -->
        <div style="background: white; border-radius: 14px; padding: 6px; display: flex; align-items: center; margin-bottom: 12px; border: 2px solid var(--secondary-gold);">
          <input id="doorstep-otp-input" type="text" maxlength="6" placeholder="Enter 6-Digit Code" style="flex: 1; border: none; outline: none; font-size: 24px; font-weight: 900; letter-spacing: 8px; text-align: center; color: var(--primary-purple); padding: 8px;">
        </div>

        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px;">
          <span style="font-size: 11px; color: rgba(255,255,255,0.7);">Code received via SMS/WhatsApp</span>
          <button style="background: rgba(255,255,255,0.2); border: 1px solid var(--secondary-gold); color: var(--secondary-gold); border-radius: 20px; padding: 4px 12px; font-size: 11px; font-weight: 800; cursor: pointer;" onclick="autofillDoorstepOtp('${o.otp}')">
            <i class="fa-solid fa-bolt"></i> Auto-Fill (${o.otp})
          </button>
        </div>

        <button class="btn-primary" style="background: var(--success); width: 100%; font-size: 14px; font-weight: 800;" onclick="submitDoorstepOtp()">
          <i class="fa-solid fa-circle-check"></i> Confirm Delivery & Release Custody
        </button>

        <div style="margin-top: 12px; text-align: center;">
          <button style="background: none; border: none; color: #FCA5A5; font-size: 11px; font-weight: 800; text-decoration: underline; cursor: pointer;" onclick="showDoorstepRejectionGuide()">
            <i class="fa-solid fa-triangle-exclamation"></i> Wrong Item or Damaged? Reject Delivery Protocol
          </button>
        </div>
      </div>
    ` : isDelivered ? `
      <!-- Delivery Completed Celebration Card -->
      <div style="background: var(--success-light); border-radius: 20px; padding: 20px; border: 1.5px solid var(--success); margin-bottom: 20px; text-align: center;">
        <div style="width: 50px; height: 50px; border-radius: 50%; background: var(--success); color: white; display: inline-flex; align-items: center; justify-content: center; font-size: 24px; margin-bottom: 10px;">
          <i class="fa-solid fa-check"></i>
        </div>
        <h3 style="font-size: 17px; font-weight: 900; color: #1a1a1a; margin-bottom: 4px;">Delivery Completed & Verified</h3>
        <p style="font-size: 13px; font-weight: 800; color: var(--success); margin-bottom: 14px;">
          +${o.cashbackEarned} Sovereign Cashback Credited to Rewards Wallet
        </p>
        <button class="btn-secondary" style="border-color: var(--primary-purple); color: var(--primary-purple); font-weight: 800; padding: 8px 16px; border-radius: 10px;" onclick="switchTab('wallet')">
          <i class="fa-solid fa-wallet"></i> View Sovereign Cashback Balance
        </button>

        <div style="margin-top: 14px; padding: 12px; background: white; border-radius: 12px; border: 1px solid #E2E8F0; display: flex; align-items: center; justify-content: space-between; gap: 8px;">
          <div style="text-align: left;">
            <div style="font-size: 11px; font-weight: 800; color: #1E293B;"><i class="fa-solid fa-shield-halved" style="color: var(--primary-purple);"></i> 24h Return Window Active</div>
            <div style="font-size: 10px; color: #64748B;">Item defective or wrong? Open a return claim before funds unlock to vendor.</div>
          </div>
          <button style="background: #FEE2E2; color: #DC2626; border: none; padding: 6px 12px; border-radius: 8px; font-size: 11px; font-weight: 800; cursor: pointer; white-space: nowrap;" onclick="switchTab('returns', { tab: 'form', orderNumber: '${o.orderNumber}' })">
            Request Return
          </button>
        </div>
      </div>
    ` : `
      <!-- Standard Secret 6-Digit Delivery PIN Card -->
      <div class="otp-gold-card">
        <div class="otp-title"><i class="fa-solid fa-shield-halved"></i> SECRET 6-DIGIT DELIVERY PIN</div>
        <div class="otp-digits-box" onclick="copyOtp('${o.otp}')">
          <span class="otp-number">${o.otp}</span>
          <i class="fa-solid fa-copy" style="color: var(--text-secondary);"></i>
        </div>
        <div class="otp-rule-box">
          <i class="fa-solid fa-triangle-exclamation"></i> When courier presses "I'm Here" at your doorstep, an input box will activate on this screen to finalize custody.
        </div>
      </div>

      <!-- Simulation Button for Live Handshake Demo -->
      <button style="width: 100%; border: 1.5px dashed var(--secondary-gold); background: #FFFBEB; border-radius: 14px; padding: 12px; margin-bottom: 20px; font-size: 13px; font-weight: 800; color: #B45309; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px;" onclick="simulateRiderArrival()">
        <i class="fa-solid fa-location-dot"></i> Simulate Courier "I'm Here" Doorstep Arrival
      </button>
    `}

    <!-- 5-Stage Live Progress Stepper -->
    <div class="stepper-wrap">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 14px;">
        <span style="font-size: 13px; font-weight: 800;">Order: ${o.orderNumber}</span>
        <span style="background: ${isDelivered ? 'var(--success-light)' : riderArrived ? 'var(--gold-light)' : 'rgba(94, 23, 235, 0.1)'}; color: ${isDelivered ? 'var(--success)' : riderArrived ? 'var(--gold-dark)' : 'var(--primary-purple)'}; font-size: 9.5px; font-weight: 900; padding: 3px 9px; border-radius: 10px;">
          ${isDelivered ? 'DELIVERED & VERIFIED' : riderArrived ? 'COURIER AT DOORSTEP' : o.statusText}
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
          <div class="step-circle ${isDelivered ? 'done' : 'active'}">${isDelivered ? '<i class="fa-solid fa-check"></i>' : '4'}</div>
          <div class="step-line ${isDelivered ? 'done' : ''}"></div>
        </div>
        <div class="step-info">
          <h5 style="color: ${isDelivered ? 'var(--text-primary)' : 'var(--primary-purple)'};">${riderArrived ? 'Courier Arrived at Doorstep' : 'Out for Delivery'}</h5>
          <p>${riderArrived ? 'Rider waiting outside • Enter PIN below' : 'Courier in transit to your destination'}</p>
        </div>
      </div>

      <div class="step-row">
        <div class="step-marker-col">
          <div class="step-circle ${isDelivered ? 'done' : ''}">${isDelivered ? '<i class="fa-solid fa-check"></i>' : '5'}</div>
        </div>
        <div class="step-info">
          <h5 style="color: ${isDelivered ? 'var(--success)' : 'inherit'};">Delivered</h5>
          <p>Custody finalized upon PIN entry</p>
        </div>
      </div>
    </div>

    <!-- Delivery Attempt Warning Card (If rider recorded failed attempt) -->
    ${o.deliveryAttemptPhoto ? `
      <div style="background: #FFFBEB; border: 1.5px solid #F59E0B; border-radius: 16px; padding: 16px; margin-bottom: 16px;">
        <div style="display: flex; gap: 10px; align-items: center; margin-bottom: 8px;">
          <i class="fa-solid fa-triangle-exclamation" style="color: #D97706; font-size: 22px;"></i>
          <div>
            <div style="font-size: 13px; font-weight: 800; color: #92400E;">Delivery Attempt Notice (${o.deliveryFailureReason || 'Gate Locked / Customer Unreachable'})</div>
            <div style="font-size: 11px; color: #B45309;">Courier was unable to reach you at the address. Live photo proof attached:</div>
          </div>
        </div>
        <img src="${o.deliveryAttemptPhoto}" style="width: 100%; height: 160px; object-fit: cover; border-radius: 10px; margin-bottom: 10px; border: 1px solid #FCD34D;">
        <div style="display: flex; gap: 8px;">
          <button class="btn-primary" style="flex: 1; background: #D97706; font-size: 12px; padding: 9px;" onclick="alert('Calling courier: ' + state.activeOrder.courierPhone)">
            <i class="fa-solid fa-phone"></i> Call Courier Now
          </button>
          <button style="border: 1px solid #D97706; background: transparent; color: #92400E; border-radius: 10px; padding: 8px 12px; font-size: 11px; font-weight: 800; cursor: pointer;" onclick="clearAttemptNotice()">
            Dismiss
          </button>
        </div>
      </div>
    ` : ''}

    <!-- Immutable Visual Audit Trail Card -->
    <div style="background: white; border-radius: 16px; padding: 16px; border: 1px solid var(--border-light); margin-bottom: 16px; box-shadow: 0 4px 12px rgba(0,0,0,0.03);">
      <div style="display: flex; align-items: center; gap: 8px; margin-bottom: 12px;">
        <i class="fa-solid fa-camera-retro" style="color: var(--primary-purple); font-size: 18px;"></i>
        <div>
          <div style="font-size: 13px; font-weight: 800; color: #0F172A;">Verified Visual Audit Trail</div>
          <div style="font-size: 10.5px; color: #64748B;">Live camera snapshots certified on immutable ledger</div>
        </div>
      </div>
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 10px;">
        <div>
          <div style="font-size: 10.5px; font-weight: 800; color: #475569; margin-bottom: 4px;">Counter Pickup Proof</div>
          <img src="${o.pickupCounterPhoto}" style="width: 100%; height: 100px; object-fit: cover; border-radius: 10px; border: 1px solid #E2E8F0;" alt="Counter Pickup">
        </div>
        <div>
          <div style="font-size: 10.5px; font-weight: 800; color: #475569; margin-bottom: 4px;">Doorstep Custody</div>
          ${isDelivered ? `
            <img src="${o.doorstepDeliveryPhoto || 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?auto=format&fit=crop&w=400&q=80'}" style="width: 100%; height: 100px; object-fit: cover; border-radius: 10px; border: 1px solid #E2E8F0;" alt="Doorstep Delivery">
          ` : `
            <div style="width: 100%; height: 100px; border-radius: 10px; border: 1.5px dashed #CBD5E1; display: flex; flex-direction: column; align-items: center; justify-content: center; color: #94A3B8; font-size: 10px; text-align: center; padding: 6px;">
              <i class="fa-solid fa-hourglass-half" style="font-size: 16px; margin-bottom: 4px;"></i>
              Pending Handover
            </div>
          `}
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

    <!-- Interactive Simulator Controls -->
    <div style="background: #F8FAFC; border-radius: 14px; padding: 12px; border: 1px dashed #CBD5E1; margin-bottom: 20px;">
      <div style="font-size: 11px; font-weight: 800; color: #64748B; margin-bottom: 8px; text-transform: uppercase;">
        <i class="fa-solid fa-flask"></i> Protocol Handshake Simulations
      </div>
      <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 8px;">
        <button style="border: 1px solid var(--secondary-gold); background: #FFFBEB; border-radius: 8px; padding: 8px; font-size: 11px; font-weight: 800; color: #B45309; cursor: pointer;" onclick="simulateRiderArrival()">
          Simulate "I'm Here"
        </button>
        <button style="border: 1px solid #F59E0B; background: #FEF3C7; border-radius: 8px; padding: 8px; font-size: 11px; font-weight: 800; color: #92400E; cursor: pointer;" onclick="simulateLockedGate()">
          Simulate Locked Gate
        </button>
      </div>
    </div>
  `;
}

function copyOtp(pin) {
  navigator.clipboard.writeText(pin);
  alert('Secret 6-Digit Delivery PIN copied: ' + pin);
}

function simulateRiderArrival() {
  state.activeOrder.riderArrived = true;
  renderOrders();
  setTimeout(() => {
    const input = document.getElementById('doorstep-otp-input');
    if (input) {
      input.focus();
      input.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  }, 100);
}

function autofillDoorstepOtp(otp) {
  const input = document.getElementById('doorstep-otp-input');
  if (input) input.value = otp;
}

function submitDoorstepOtp() {
  const input = document.getElementById('doorstep-otp-input');
  const enteredOtp = input ? input.value.trim() : '';

  if (enteredOtp.length !== 6) {
    alert('Please enter a valid 6-digit numeric Delivery Code.');
    return;
  }

  if (enteredOtp !== state.activeOrder.otp) {
    alert('Verification code invalid! Please enter the 6-digit Delivery PIN you received via SMS/WhatsApp (' + state.activeOrder.otp + ').');
    return;
  }

  state.activeOrder.statusStep = 4;
  state.activeOrder.statusText = 'DELIVERED';
  state.activeOrder.doorstepDeliveryPhoto = 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?auto=format&fit=crop&w=400&q=80';
  state.activeOrder.riderArrived = false;
  alert('Delivery custody confirmed! Escrow released and +16,000.00 Cashback credited to your Sovereign Rewards Wallet.');
  renderOrders();
}

function simulateLockedGate() {
  state.activeOrder.deliveryAttemptPhoto = 'https://images.unsplash.com/photo-1558036117-15d82a90b9b1?auto=format&fit=crop&w=500&q=80';
  state.activeOrder.deliveryFailureReason = 'gate_locked';
  state.activeOrder.statusText = 'DELIVERY ATTEMPT FAILED (LOCKED GATE)';
  state.activeOrder.riderArrived = false;
  alert('Rider recorded failed delivery attempt!\nReason: Gate Locked / Customer Unreachable.\nLive photo proof has been logged to your tracking screen.');
  renderOrders();
}

function clearAttemptNotice() {
  state.activeOrder.deliveryAttemptPhoto = null;
  state.activeOrder.deliveryFailureReason = null;
  renderOrders();
}

function reorderReplacement(orderNumber) {
  const newOrderNum = 'VM-ORD-' + Math.floor(1000 + Math.random() * 9000);
  const newOtp = String(Math.floor(100000 + Math.random() * 900000));

  state.activeOrder = {
    orderNumber: newOrderNum,
    otp: newOtp,
    courierPickupOtp: '519283',
    riderArrived: false,
    statusStep: 1,
    statusText: 'PROCESSING REPLACEMENT',
    pickupCounterPhoto: 'https://images.unsplash.com/photo-1586528116311-ad8dd3c8310d?auto=format&fit=crop&w=400&q=80',
    doorstepDeliveryPhoto: null,
    deliveryAttemptPhoto: null,
    deliveryFailureReason: null,
    walletCreditApplied: '320,000.00',
    items: [
      {
        name: 'Samsung Galaxy A54 5G 128GB Awesome Violet (Replacement)',
        qty: 1,
        price: '₦320,000.00',
        acceptedQty: 1,
        rejectedQty: 0,
        rejectionCategory: null,
        defectPhoto: null
      }
    ],
    subtotal: '₦320,000.00',
    deliveryFee: '₦500.00',
    total: '₦320,500.00',
    cashbackEarned: '₦16,000.00',
    courierName: 'Emeka Okon (Rider Dispatch)',
    courierPhone: '+2348039120491',
    courierVehicle: 'TVS HLX Plus (UYO-123-AK)',
    shopName: 'MegaTech Uyo Plaza',
    shopAddress: '10 Aka Road, Uyo Plaza'
  };

  alert(`Replacement Order Dispatched!\nOrder Number: ${newOrderNum}\nPaid seamlessly with your Wallet Credit refund. Live tracking initialized.`);
  switchTab('orders');
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

// Returns & Claims Screen Renderer
function renderReturns(extra) {
  const container = document.getElementById('returns-content-area');
  if (!container) return;

  const activeSubTab = (extra && extra.tab) ? extra.tab : 'cases';
  const prefilledOrder = (extra && extra.orderNumber) ? extra.orderNumber : state.activeOrder.orderNumber;

  container.innerHTML = `
    <!-- Top Sub-Tabs -->
    <div style="display: flex; background: #E2E8F0; padding: 3px; border-radius: 12px; margin-bottom: 16px;">
      <button style="flex: 1; padding: 8px; border: none; border-radius: 10px; font-size: 12px; font-weight: 800; cursor: pointer; transition: all 0.2s; background: ${activeSubTab === 'cases' ? 'white' : 'transparent'}; color: ${activeSubTab === 'cases' ? 'var(--primary-purple)' : '#64748B'}; box-shadow: ${activeSubTab === 'cases' ? '0 2px 6px rgba(0,0,0,0.08)' : 'none'};" onclick="renderReturns({ tab: 'cases' })">
        <i class="fa-solid fa-list-check"></i> Return Cases (${state.returnCases.length})
      </button>
      <button style="flex: 1; padding: 8px; border: none; border-radius: 10px; font-size: 12px; font-weight: 800; cursor: pointer; transition: all 0.2s; background: ${activeSubTab === 'form' ? 'white' : 'transparent'}; color: ${activeSubTab === 'form' ? 'var(--primary-purple)' : '#64748B'}; box-shadow: ${activeSubTab === 'form' ? '0 2px 6px rgba(0,0,0,0.08)' : 'none'};" onclick="renderReturns({ tab: 'form', orderNumber: '${prefilledOrder}' })">
        <i class="fa-solid fa-triangle-exclamation"></i> File a Claim
      </button>
    </div>

    ${activeSubTab === 'cases' ? `
      <!-- TAB 1: CASES LIST -->
      ${state.returnCases.length === 0 ? `
        <div style="text-align: center; padding: 40px 20px; color: #64748B;">
          <i class="fa-solid fa-shield-cat" style="font-size: 48px; color: #CBD5E1; margin-bottom: 12px;"></i>
          <h4 style="font-size: 15px; font-weight: 800; color: #1E293B; margin-bottom: 4px;">No Active Return Disputes</h4>
          <p style="font-size: 12px; line-height: 1.4;">All your delivered orders are in good standing under 24h sovereign protection.</p>
        </div>
      ` : `
        <div>
          ${state.returnCases.map(c => `
            <div style="background: white; border-radius: 16px; padding: 16px; border: 1px solid var(--border-light); margin-bottom: 14px; box-shadow: 0 4px 12px rgba(0,0,0,0.03);">
              <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
                <span style="font-size: 14px; font-weight: 900; color: #0F172A;">${c.caseNumber}</span>
                <span style="background: ${c.status === 'refunded' ? 'var(--success-light)' : 'rgba(94, 23, 235, 0.1)'}; color: ${c.status === 'refunded' ? 'var(--success)' : 'var(--primary-purple)'}; font-size: 10px; font-weight: 900; padding: 3px 8px; border-radius: 8px; text-transform: uppercase;">
                  ${c.statusLabel}
                </span>
              </div>
              <div style="font-size: 12px; color: var(--text-secondary); margin-bottom: 6px;">
                Order Ref: <strong style="color: #0F172A;">${c.orderNumber}</strong> • Reason: <strong style="color: #0F172A;">${c.reasonLabel}</strong>
              </div>
              <div style="font-size: 12px; color: #475569; background: #F8FAFC; padding: 10px; border-radius: 8px; margin-bottom: 10px; border-left: 3px solid var(--primary-purple);">
                "${c.description}"
              </div>
              <div style="display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #F1F5F9; padding-top: 10px; margin-bottom: 10px;">
                <div>
                  <div style="font-size: 10px; color: #64748B; font-weight: 700;">REFUNDABLE ESCROW:</div>
                  <div style="font-size: 15px; font-weight: 900; color: var(--primary-purple);">${c.amount}</div>
                </div>
                ${c.vendorOtp ? `
                  <div style="text-align: right;">
                    <div style="font-size: 10px; color: #64748B; font-weight: 700;">VENDOR RETURN OTP:</div>
                    <div style="font-size: 14px; font-weight: 900; color: #0F766E; font-family: monospace; letter-spacing: 2px;">${c.vendorOtp}</div>
                  </div>
                ` : ''}
              </div>

              <!-- 1-Click Replacement Reorder Option -->
              <button style="width: 100%; background: #EFF6FF; border: 1.2px solid #3B82F6; color: #1D4ED8; border-radius: 10px; padding: 8px 12px; font-size: 11.5px; font-weight: 800; cursor: pointer; display: flex; align-items: center; justify-content: center; gap: 8px;" onclick="reorderReplacement('${c.orderNumber}')">
                <i class="fa-solid fa-arrows-rotate"></i> 1-Click Reorder Replacement Unit
              </button>
            </div>
          `).join('')}
        </div>
      `}
    ` : `
      <!-- TAB 2: FILE DISPUTE FORM -->
      <div style="background: white; border-radius: 16px; padding: 18px; border: 1px solid var(--border-light);">
        <!-- Guarantee Banner -->
        <div style="background: #FEF3C7; border: 1px solid #FDE68A; border-radius: 10px; padding: 12px; display: flex; gap: 10px; margin-bottom: 16px;">
          <i class="fa-solid fa-shield-halved" style="color: #D97706; font-size: 18px; margin-top: 2px;"></i>
          <div style="font-size: 11.5px; color: #92400E; line-height: 1.4;">
            <strong>24-Hour Sovereign Return Guarantee:</strong> Customer funds remain locked in platform escrow until goods are fully verified or returned.
          </div>
        </div>

        <div style="margin-bottom: 14px;">
          <label style="display: block; font-size: 11px; font-weight: 800; color: #64748B; margin-bottom: 6px; text-transform: uppercase;">Delivered Order Number</label>
          <input type="text" id="dispute-order-input" value="${prefilledOrder}" style="width: 100%; padding: 10px; border-radius: 10px; border: 1.5px solid #CBD5E1; font-size: 13px; font-weight: 700; outline: none; background: #F8FAFC;">
        </div>

        <div style="margin-bottom: 14px;">
          <label style="display: block; font-size: 11px; font-weight: 800; color: #64748B; margin-bottom: 6px; text-transform: uppercase;">Primary Reason for Return</label>
          <select id="dispute-reason-select" style="width: 100%; padding: 10px; border-radius: 10px; border: 1.5px solid #CBD5E1; font-size: 12.5px; font-weight: 700; outline: none; background: #F8FAFC;">
            <option value="defective_product">Defective / Not Working</option>
            <option value="wrong_item_sent">Wrong Item Delivered</option>
            <option value="misdescribed_counterfeit">Counterfeit / Misdescribed</option>
            <option value="damaged_in_transit">Damaged in Transit</option>
            <option value="missing_item">Missing Item / Parts from Box</option>
            <option value="change_of_mind">Change of Mind (Original Seal Intact)</option>
          </select>
        </div>

        <div style="margin-bottom: 18px;">
          <label style="display: block; font-size: 11px; font-weight: 800; color: #64748B; margin-bottom: 6px; text-transform: uppercase;">Detailed Explanation of Defect</label>
          <textarea id="dispute-notes-input" rows="4" placeholder="Explain the defect, mismatch, or damage in detail..." style="width: 100%; padding: 10px; border-radius: 10px; border: 1.5px solid #CBD5E1; font-size: 12.5px; outline: none; background: #F8FAFC; resize: none;"></textarea>
        </div>

        <button class="btn-primary" style="width: 100%; padding: 12px; font-size: 13px; font-weight: 800;" onclick="submitReturnClaim()">
          <i class="fa-solid fa-paper-plane"></i> Submit Return & Dispute Claim
        </button>
      </div>
    `}
  `;
}

function submitReturnClaim() {
  const orderInput = document.getElementById('dispute-order-input');
  const reasonSelect = document.getElementById('dispute-reason-select');
  const notesInput = document.getElementById('dispute-notes-input');

  const orderNum = orderInput ? orderInput.value.trim() : state.activeOrder.orderNumber;
  const reasonVal = reasonSelect ? reasonSelect.value : 'defective_product';
  const reasonLabel = reasonSelect ? reasonSelect.options[reasonSelect.selectedIndex].text : 'Defective';
  const notes = notesInput ? notesInput.value.trim() : '';

  if (!notes || notes.length < 5) {
    alert('Please provide a brief explanation of the issue.');
    return;
  }

  const newCaseNum = 'RET-' + new Date().toISOString().slice(0, 10).replace(/-/g, '') + '-' + String(Math.floor(1000 + Math.random() * 9000));
  const newVendorOtp = String(Math.floor(100000 + Math.random() * 900000));

  state.returnCases.unshift({
    caseNumber: newCaseNum,
    orderNumber: orderNum,
    status: 'opened',
    statusLabel: 'Case Opened (Escrow Locked)',
    reason: reasonVal,
    reasonLabel: reasonLabel,
    amount: state.activeOrder.total,
    description: notes,
    vendorOtp: newVendorOtp,
    date: 'Just now'
  });

  alert(`Return Claim Submitted Successfully!\nCase Number: ${newCaseNum}\nEscrow funds are safely frozen pending courier pickup.`);
  renderReturns({ tab: 'cases' });
}

// Doorstep Rejection Guidance Protocol
function showDoorstepRejectionGuide() {
  alert(
    "DOORSTEP REFUSAL PROTOCOL:\n\n" +
    "1. Inspect your parcel before entering or sharing the 6-digit Delivery Code.\n" +
    "2. If damaged, incorrect, or defective: REFUSE TO ENTER OR SHARE THE CODE.\n" +
    "3. The courier marks 'Customer Rejected Doorstep Delivery' on their terminal.\n" +
    "4. Platform Escrow automatically refunds 100% of your funds directly into your Spendable Wallet Credits instantly."
  );
}
