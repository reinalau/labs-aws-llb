// ============================================================================
// Configuration File for Forest Chocolate Website Template
// ============================================================================
// Edit this file to customize all content on your site.
// Do NOT modify component files - they read from this config.

// Hero Section Configuration
export interface HeroConfig {
  subtitle: string;
  titleLine1: string;
  titleLine2: string;
  tagline: string;
  chocolateText: string;
  ctaText: string;
  heroImage: string;
  leafImages: [string, string];
}

export const heroConfig: HeroConfig = {
  subtitle: "",
  titleLine1: "",
  titleLine2: "",
  tagline: "",
  chocolateText: "",
  ctaText: "",
  heroImage: "",
  leafImages: ["", ""],
};

// Story Section Configuration
export interface StoryStatConfig {
  value: string;
  label: string;
}

export interface StoryConfig {
  label: string;
  heading: string[];
  headingAccent: string;
  paragraphs: string[];
  stats: StoryStatConfig[];
  storyImage: string;
}

export const storyConfig: StoryConfig = {
  label: "",
  heading: [],
  headingAccent: "",
  paragraphs: [],
  stats: [],
  storyImage: "",
};

// Product Section Configuration
export interface ProductConfig {
  label: string;
  heading: string[];
  headingAccent: string;
  productTitle: string;
  description: string;
  features: string[];
  price: string;
  priceLabel: string;
  specs: string;
  specsLabel: string;
  ctaPrimary: string;
  ctaSecondary: string;
  productImage: string;
}

export const productConfig: ProductConfig = {
  label: "",
  heading: [],
  headingAccent: "",
  productTitle: "",
  description: "",
  features: [],
  price: "",
  priceLabel: "",
  specs: "",
  specsLabel: "",
  ctaPrimary: "",
  ctaSecondary: "",
  productImage: "",
};

// Explore Section Configuration
export interface HotspotConfig {
  id: string;
  x: number;
  y: number;
  title: string;
  description: string;
  iconType: "bird" | "pawprint" | "treepine" | "flower";
  image: string;
}

export interface ExploreConfig {
  label: string;
  heading: string[];
  headingAccent: string;
  description: string;
  hint: string;
  exploreImage: string;
  hotspots: HotspotConfig[];
}

export const exploreConfig: ExploreConfig = {
  label: "",
  heading: [],
  headingAccent: "",
  description: "",
  hint: "",
  exploreImage: "",
  hotspots: [],
};

// Tasting Section Configuration
export interface TastingCardConfig {
  iconType: "eye" | "wind" | "sparkles";
  title: string;
  description: string;
  notes: string[];
}

export interface FlavorBarConfig {
  label: string;
  value: number;
  color: string;
}

export interface TastingConfig {
  label: string;
  heading: string[];
  headingAccent: string;
  description: string;
  tastingCards: TastingCardConfig[];
  flavorWheel: {
    title: string;
    description: string;
    tags: string[];
    bars: FlavorBarConfig[];
  };
}

export const tastingConfig: TastingConfig = {
  label: "",
  heading: [],
  headingAccent: "",
  description: "",
  tastingCards: [],
  flavorWheel: {
    title: "",
    description: "",
    tags: [],
    bars: [],
  },
};

// Footer Section Configuration
export interface SocialLinkConfig {
  platform: "instagram" | "facebook" | "twitter";
  href: string;
}

export interface NavLinkConfig {
  label: string;
  href: string;
}

export interface PolicyLinkConfig {
  label: string;
  href: string;
}

export interface FooterConfig {
  brandName: string;
  brandTagline: string;
  brandDescription: string;
  socialLinks: SocialLinkConfig[];
  navSectionTitle: string;
  navLinks: NavLinkConfig[];
  contactSectionTitle: string;
  contactAddress: string;
  contactPhone: string;
  contactEmail: string;
  newsletterTitle: string;
  newsletterDescription: string;
  newsletterPlaceholder: string;
  newsletterButton: string;
  copyright: string;
  policyLinks: PolicyLinkConfig[];
}

export const footerConfig: FooterConfig = {
  brandName: "",
  brandTagline: "",
  brandDescription: "",
  socialLinks: [],
  navSectionTitle: "",
  navLinks: [],
  contactSectionTitle: "",
  contactAddress: "",
  contactPhone: "",
  contactEmail: "",
  newsletterTitle: "",
  newsletterDescription: "",
  newsletterPlaceholder: "",
  newsletterButton: "",
  copyright: "",
  policyLinks: [],
};

// Site Metadata
export interface SiteConfig {
  title: string;
  description: string;
  language: string;
}

export const siteConfig: SiteConfig = {
  title: "",
  description: "",
  language: "",
};
