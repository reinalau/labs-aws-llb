import { motion } from 'framer-motion';
import { ScrollReveal } from '../components/custom/ScrollReveal';
import { Check, ShoppingBag } from 'lucide-react';
import { productConfig } from '../config';

export function ProductSection() {
  // Null check for empty config
  if (!productConfig.productImage || !productConfig.productTitle) {
    return null;
  }

  return (
    <section className="relative w-full py-24 md:py-32 bg-gradient-to-b from-[#0D2818] via-[#0a1f12] to-[#05140A] overflow-hidden">
      {/* Background Elements */}
      <div className="absolute inset-0">
        <div className="absolute top-1/4 left-0 w-96 h-96 bg-[#2D6A4F]/10 rounded-full blur-3xl" />
        <div className="absolute bottom-1/4 right-0 w-80 h-80 bg-[#C9A227]/5 rounded-full blur-3xl" />
      </div>

      <div className="relative z-10 max-w-7xl mx-auto px-6 lg:px-12">
        {/* Section Header */}
        <ScrollReveal className="text-center mb-16">
          {productConfig.label && (
            <span className="text-[#C9A227] text-sm tracking-[0.3em] uppercase mb-4 block">
              {productConfig.label}
            </span>
          )}
          <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold text-[#F5F5DC]">
            {productConfig.heading.map((line, index) => (
              <span key={index}>{line}</span>
            ))}
            {productConfig.headingAccent && (
              <span className="gold-gradient-text">{productConfig.headingAccent}</span>
            )}
          </h2>
        </ScrollReveal>

        <div className="grid lg:grid-cols-2 gap-16 items-center">
          {/* Product Image */}
          <ScrollReveal direction="left" className="relative">
            <div className="relative flex justify-center">
              {/* Glow Effect */}
              <div className="absolute inset-0 bg-[#C9A227]/10 blur-3xl scale-75" />
              
              {/* Main Product Image */}
              <motion.div
                className="relative"
                animate={{ y: [0, -8, 0] }}
                transition={{
                  duration: 5,
                  repeat: Infinity,
                  ease: "easeInOut",
                }}
              >
                <img
                  src={productConfig.productImage}
                  alt="Product Packaging"
                  className="relative w-full max-w-lg h-auto object-contain drop-shadow-2xl"
                />
              </motion.div>

              {/* Decorative Elements */}
              <motion.div
                className="absolute -top-8 -right-8 w-24 h-24 border border-[#C9A227]/30 rounded-full"
                animate={{ rotate: 360 }}
                transition={{ duration: 20, repeat: Infinity, ease: "linear" }}
              />
              <motion.div
                className="absolute -bottom-4 -left-4 w-16 h-16 border border-[#C9A227]/20 rounded-full"
                animate={{ rotate: -360 }}
                transition={{ duration: 15, repeat: Infinity, ease: "linear" }}
              />
            </div>
          </ScrollReveal>

          {/* Product Info */}
          <div>
            <ScrollReveal direction="right" delay={0.1}>
              <h3 className="text-3xl md:text-4xl font-bold text-[#F5F5DC] mb-4">
                {productConfig.productTitle}
              </h3>
            </ScrollReveal>

            {productConfig.description && (
              <ScrollReveal direction="right" delay={0.2}>
                <p className="text-[#8FBC8F] text-lg mb-8 leading-relaxed">
                  {productConfig.description}
                </p>
              </ScrollReveal>
            )}

            {/* Features List */}
            {productConfig.features.length > 0 && (
              <ScrollReveal direction="right" delay={0.3}>
                <div className="grid grid-cols-2 gap-4 mb-10">
                  {productConfig.features.map((feature, index) => (
                    <motion.div
                      key={feature}
                      className="flex items-center gap-3"
                      initial={{ opacity: 0, x: 20 }}
                      whileInView={{ opacity: 1, x: 0 }}
                      viewport={{ once: true }}
                      transition={{ delay: 0.4 + index * 0.05, duration: 0.5 }}
                    >
                      <div className="w-5 h-5 rounded-full bg-[#C9A227]/20 flex items-center justify-center flex-shrink-0">
                        <Check className="w-3 h-3 text-[#C9A227]" />
                      </div>
                      <span className="text-[#F5F5DC] text-sm">{feature}</span>
                    </motion.div>
                  ))}
                </div>
              </ScrollReveal>
            )}

            {/* Price and CTA */}
            {(productConfig.price || productConfig.specs) && (
              <ScrollReveal direction="right" delay={0.4}>
                <div className="flex items-center gap-8 mb-8">
                  {productConfig.price && (
                    <div>
                      {productConfig.priceLabel && (
                        <span className="text-[#8FBC8F] text-sm block mb-1">{productConfig.priceLabel}</span>
                      )}
                      <span className="text-4xl font-bold text-[#C9A227]">{productConfig.price}</span>
                    </div>
                  )}
                  {productConfig.price && productConfig.specs && (
                    <div className="h-12 w-px bg-[#C9A227]/30" />
                  )}
                  {productConfig.specs && (
                    <div>
                      {productConfig.specsLabel && (
                        <span className="text-[#8FBC8F] text-sm block mb-1">{productConfig.specsLabel}</span>
                      )}
                      <span className="text-[#F5F5DC]">{productConfig.specs}</span>
                    </div>
                  )}
                </div>
              </ScrollReveal>
            )}

            {(productConfig.ctaPrimary || productConfig.ctaSecondary) && (
              <ScrollReveal direction="right" delay={0.5}>
                <div className="flex gap-4">
                  {productConfig.ctaPrimary && (
                    <motion.button
                      className="flex-1 flex items-center justify-center gap-3 px-8 py-4 bg-[#C9A227] text-[#0D2818] font-semibold tracking-wider uppercase transition-all duration-300"
                      whileHover={{ scale: 1.02, boxShadow: '0 0 30px rgba(201, 162, 39, 0.4)' }}
                      whileTap={{ scale: 0.98 }}
                    >
                      <ShoppingBag className="w-5 h-5" />
                      {productConfig.ctaPrimary}
                    </motion.button>
                  )}
                  {productConfig.ctaSecondary && (
                    <motion.button
                      className="px-8 py-4 border border-[#C9A227] text-[#C9A227] font-semibold tracking-wider uppercase transition-all duration-300 hover:bg-[#C9A227]/10"
                      whileHover={{ scale: 1.02 }}
                      whileTap={{ scale: 0.98 }}
                    >
                      {productConfig.ctaSecondary}
                    </motion.button>
                  )}
                </div>
              </ScrollReveal>
            )}
          </div>
        </div>
      </div>
    </section>
  );
}
