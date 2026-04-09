# Forest Chocolate Landing Page Template

A dark, elegant chocolate brand landing page with jungle-themed design, smooth Framer Motion animations, and interactive hotspot elements. Perfect for luxury chocolate, artisan food, or nature-inspired brands.

## Features

- **Hero Section** - Full-screen brand showcase with floating product image and decorative leaves
- **Story Section** - Brand narrative with image framing and statistics
- **Product Section** - Product highlight with features grid and pricing
- **Explore Section** - Interactive jungle scene with clickable hotspots and modals
- **Tasting Section** - Tasting guide with cards and flavor profile bars
- **Footer** - Brand info, navigation, contact details, and newsletter signup
- **Decorative Elements** - Mouse-following leaves with sway animations
- **Responsive Design** - Mobile-optimized layouts

## Tech Stack

- **React 19** + **TypeScript** + **Vite 7**
- **Tailwind CSS 3** with custom animations
- **Framer Motion** for scroll and interaction animations
- **Lucide React** for icons

## Quick Start

1. Clone or extract this template
2. Install dependencies:
   ```bash
   npm install
   ```
3. Edit `src/config.ts` with your content
4. Add images to `public/images/`
5. Run the dev server:
   ```bash
   npm run dev
   ```
6. Build for production:
   ```bash
   npm run build
   ```

## Configuration

All content is configured in `src/config.ts`. Edit this single file to customize your entire site. **Do not modify component files** - they contain pure logic and read from config.

### Hero Section

```typescript
export const heroConfig: HeroConfig = {
  subtitle: "",              // Top label (e.g., "Artisan Chocolatier")
  titleLine1: "",            // First title line (e.g., "CACAO")
  titleLine2: "",            // Second title line (e.g., "SAUVAGE")
  tagline: "",               // Subtitle text (e.g., "Wild Cacao · Jungle Secret Realm")
  chocolateText: "",         // Badge text (e.g., "85% Ecuadorian Dark Chocolate")
  ctaText: "",               // Button text (e.g., "Explore More")
  heroImage: "",             // Path: "images/hero_chocolate.jpg"
  leafImages: ["", ""],      // Decorative leaves [leaf1, leaf2]
};
```

**Example:**
```typescript
{
  subtitle: "Artisan Chocolatier",
  titleLine1: "CACAO",
  titleLine2: "SAUVAGE",
  tagline: "Wild Cacao · Jungle Secret Realm",
  chocolateText: "85% Ecuadorian Dark Chocolate",
  ctaText: "Explore More",
  heroImage: "images/hero_chocolate.jpg",
  leafImages: ["images/leaf_1.png", "images/leaf_2.png"]
}
```

---

### Story Section

```typescript
export const storyConfig: StoryConfig = {
  label: "",                 // Section label (e.g., "Brand Story")
  heading: [],               // Heading lines (e.g., ["Deep in the Jungle"])
  headingAccent: "",         // Accent line in gold (e.g., "Sweet Secret")
  paragraphs: [],            // Array of paragraph strings
  stats: [],                 // Array of { value: string, label: string }
  storyImage: "",            // Path: "images/brand_story_jungle.jpg"
};
```

**Example:**
```typescript
{
  label: "Brand Story",
  heading: ["Deep in the Jungle"],
  headingAccent: "Sweet Secret",
  paragraphs: [
    "Deep in the Ecuadorian rainforest, wild cacao trees grow quietly under the shelter of towering canopy...",
    "Every piece of Cacao Sauvage carries the mystery and romance of the tropical rainforest...",
    "We insist on single-origin, small-batch, handcrafted production..."
  ],
  stats: [
    { value: "85%", label: "Cacao Content" },
    { value: "72h", label: "Slow Roasted" },
    { value: "100%", label: "Handcrafted" }
  ],
  storyImage: "images/brand_story_jungle.jpg"
}
```

---

### Product Section

```typescript
export const productConfig: ProductConfig = {
  label: "",                 // Section label (e.g., "Product Showcase")
  heading: [],               // Heading lines (e.g., ["Jungle"])
  headingAccent: "",         // Accent line in gold (e.g., "Treasure")
  productTitle: "",          // Main product title
  description: "",           // Product description paragraph
  features: [],              // Array of feature strings
  price: "",                 // Price (e.g., "$298")
  priceLabel: "",            // Price label (e.g., "Price")
  specs: "",                 // Specifications (e.g., "80g / bar")
  specsLabel: "",            // Specs label (e.g., "Specification")
  ctaPrimary: "",            // Primary button (e.g., "Buy Now")
  ctaSecondary: "",          // Secondary button (e.g., "Learn More")
  productImage: "",          // Path: "images/product_packaging.jpg"
};
```

**Example:**
```typescript
{
  label: "Product Showcase",
  heading: ["Jungle"],
  headingAccent: "Treasure",
  productTitle: "85% Ecuadorian Dark Chocolate",
  description: "Wild cacao from the Ecuadorian rainforest, slow-roasted for 72 hours...",
  features: [
    "85% Cacao Content",
    "Single-origin Ecuador",
    "Wild Cacao Variety",
    "72h Slow Roasted",
    "Handcrafted",
    "No Preservatives"
  ],
  price: "$298",
  priceLabel: "Price",
  specs: "80g / bar",
  specsLabel: "Specification",
  ctaPrimary: "Buy Now",
  ctaSecondary: "Learn More",
  productImage: "images/product_packaging.jpg"
}
```

---

### Explore Section

```typescript
export const exploreConfig: ExploreConfig = {
  label: "",                 // Section label (e.g., "Interactive Experience")
  heading: [],               // Heading lines (e.g., ["Explore"])
  headingAccent: "",         // Accent line in gold (e.g., "Jungle")
  description: "",           // Section description
  hint: "",                  // Hint text (e.g., "Click the spots to explore more")
  exploreImage: "",          // Path: "images/explore_jungle.jpg"
  hotspots: [],              // Array of hotspot objects (see below)
};
```

**Hotspot Structure:**
```typescript
{
  id: string,                // Unique ID
  x: number,                 // X position (0-100%)
  y: number,                 // Y position (0-100%)
  title: string,             // Modal title
  description: string,       // Modal description
  iconType: "bird" | "pawprint" | "treepine" | "flower",
  image: string              // Modal image path
}
```

**Example:**
```typescript
{
  label: "Interactive Experience",
  heading: ["Explore"],
  headingAccent: "Jungle",
  description: "Click the spots in the scene to discover secrets hidden deep in the jungle",
  hint: "Click the spots to explore more",
  exploreImage: "images/explore_jungle.jpg",
  hotspots: [
    {
      id: "toucan",
      x: 25,
      y: 30,
      title: "Toucan",
      description: "The messenger of the tropical rainforest, delivering the jungle's news with its vibrant beak...",
      iconType: "bird",
      image: "images/toucan.png"
    }
    // ... more hotspots
  ]
}
```

---

### Tasting Section

```typescript
export const tastingConfig: TastingConfig = {
  label: "",                 // Section label (e.g., "Tasting Guide")
  heading: [],               // Heading lines (e.g., ["Tasting"])
  headingAccent: "",         // Accent line in gold (e.g., "Journey")
  description: "",           // Section description
  tastingCards: [],          // Array of tasting card objects (see below)
  flavorWheel: {
    title: "",               // Flavor wheel title
    description: "",         // Flavor wheel description
    tags: [],                // Array of flavor tag strings
    bars: []                 // Array of flavor bar objects (see below)
  }
};
```

**Tasting Card Structure:**
```typescript
{
  iconType: "eye" | "wind" | "sparkles",
  title: string,
  description: string,
  notes: string[]            // Array of note strings
}
```

**Flavor Bar Structure:**
```typescript
{
  label: string,
  value: number,             // 0-100
  color: string              // Hex color
}
```

**Example:**
```typescript
{
  label: "Tasting Guide",
  heading: ["Tasting"],
  headingAccent: "Journey",
  description: "Use your senses to explore every layer of Cacao Sauvage's flavor",
  tastingCards: [
    {
      iconType: "eye",
      title: "Appearance",
      description: "Deep as the jungle night, glossy as moonlight pours down",
      notes: ["Deep brown color", "Delicate luster", "Perfect snap"]
    }
    // ... more cards
  ],
  flavorWheel: {
    title: "Flavor Wheel",
    description: "Cacao Sauvage features a rich and complex flavor profile...",
    tags: ["Cacao", "Blackberry", "Vanilla", "Nuts", "Woody", "Floral"],
    bars: [
      { label: "Bitterness", value: 85, color: "#3D2817" }
      // ... more bars
    ]
  }
}
```

---

### Footer Section

```typescript
export const footerConfig: FooterConfig = {
  brandName: "",             // Brand name (e.g., "CACAO SAUVAGE")
  brandTagline: "",          // Brand tagline
  brandDescription: "",      // Brand description paragraph
  socialLinks: [],           // Array of { platform, href }
  navSectionTitle: "",       // Navigation section title
  navLinks: [],              // Array of { label, href }
  contactSectionTitle: "",   // Contact section title
  contactAddress: "",        // Address (use \n for line breaks)
  contactPhone: "",          // Phone number
  contactEmail: "",          // Email address
  newsletterTitle: "",       // Newsletter section title
  newsletterDescription: "", // Newsletter description
  newsletterPlaceholder: "", // Email input placeholder
  newsletterButton: "",      // Submit button text
  copyright: "",             // Copyright text
  policyLinks: []            // Array of { label, href }
};
```

---

### Site Metadata

```typescript
export const siteConfig: SiteConfig = {
  title: "",                 // Browser tab title
  description: "",           // Site description for SEO
  language: ""               // Language code
};
```

---

## Required Images

Add these images to the `public/images/` directory:

### Hero Section (3 images)
- **hero_chocolate.jpg** - Product photo, 800x1200 portrait
- **leaf_1.png** - Decorative leaf PNG with transparency, 800x800
- **leaf_2.png** - Decorative leaf PNG with transparency, 800x800

### Story Section (1 image)
- **brand_story_jungle.jpg** - Jungle scene photo, 1200x800 landscape

### Product Section (1 image)
- **product_packaging.jpg** - Product packaging photo, 800x1200 portrait

### Explore Section (5 images)
- **explore_jungle.jpg** - Interactive jungle scene, 1600x900 landscape
- **toucan.png** - Toucan illustration PNG with transparency, 600x600
- **jaguar.png** - Jaguar illustration PNG with transparency, 600x600
- **cacao.png** - Cacao illustration PNG with transparency, 600x600
- **orchid.png** - Orchid illustration PNG with transparency, 600x600

**Total: 10 images**

---

## Design

### Colors

- **Accent Gold:** `#C9A227`
- **Dark Green Backgrounds:** `#0D2818`, `#05140A`, `#0a1f12`
- **Beige Text:** `#F5F5DC`
- **Light Green Text:** `#8FBC8F`

### Animations

- **Hero:** Staggered entry, floating product, mouse-following leaves
- **Story:** Scroll reveals, hover effects, stats counter
- **Product:** Floating image, rotating decoratives, feature stagger
- **Explore:** Pulsing hotspots, modal entrance animations
- **Tasting:** Card hover lift, icon rotation, flavor bar fill
- **Footer:** Social icon scale, link slide, leaf rotation

---

## Build

```bash
npm run build
```

Output: `dist/` folder (ready for Vercel/Netlify/static hosting)

---

## Project Structure

```
├── src/
│   ├── config.ts              ← Edit for all content
│   ├── App.tsx                ← Root component
│   ├── sections/              ← All page sections
│   └── components/custom/     ← Reusable components
├── public/images/             ← Add 10 images here
└── package.json
```

---

## Notes

- **Edit only `src/config.ts`** and add images to `public/images/`
- Components auto-hide when config is empty
- All Framer Motion animations preserved
- Update `<title>` in `index.html`
- Optimize images before adding (WebP recommended)

---

## License

This template is provided as-is for use in your projects.
