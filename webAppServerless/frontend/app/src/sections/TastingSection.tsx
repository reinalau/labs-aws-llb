import { motion } from 'framer-motion';
import { ScrollReveal } from '../components/custom/ScrollReveal';
import { Eye, Wind, Sparkles } from 'lucide-react';
import { tastingConfig } from '../config';
import type { TastingCardConfig } from '../config';

export function TastingSection() {
  // Null check for empty config
  if (tastingConfig.tastingCards.length === 0) {
    return null;
  }

  // Map iconType string to icon component
  const getIcon = (iconType: TastingCardConfig['iconType']) => {
    const iconMap = {
      eye: <Eye className="w-8 h-8" />,
      wind: <Wind className="w-8 h-8" />,
      sparkles: <Sparkles className="w-8 h-8" />,
    };
    return iconMap[iconType];
  };
  return (
    <section className="relative w-full py-24 md:py-32 bg-gradient-to-b from-[#0D2818] via-[#0a1f12] to-[#05140A] overflow-hidden">
      {/* Background Elements */}
      <div className="absolute inset-0">
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-[#C9A227]/5 rounded-full blur-3xl" />
        <div className="absolute bottom-0 right-1/4 w-80 h-80 bg-[#2D6A4F]/10 rounded-full blur-3xl" />
      </div>

      <div className="relative z-10 max-w-7xl mx-auto px-6 lg:px-12">
        {/* Section Header */}
        <ScrollReveal className="text-center mb-16">
          {tastingConfig.label && (
            <span className="text-[#C9A227] text-sm tracking-[0.3em] uppercase mb-4 block">
              {tastingConfig.label}
            </span>
          )}
          <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold text-[#F5F5DC] mb-4">
            {tastingConfig.heading.map((line, index) => (
              <span key={index}>{line}</span>
            ))}
            {tastingConfig.headingAccent && (
              <span className="gold-gradient-text">{tastingConfig.headingAccent}</span>
            )}
          </h2>
          {tastingConfig.description && (
            <p className="text-[#8FBC8F] text-lg max-w-2xl mx-auto">
              {tastingConfig.description}
            </p>
          )}
        </ScrollReveal>

        {/* Tasting Cards */}
        <div className="grid md:grid-cols-3 gap-8">
          {tastingConfig.tastingCards.map((card, index) => (
            <ScrollReveal key={card.title} delay={index * 0.15} direction="up">
              <motion.div
                className="relative group h-full"
                whileHover={{ y: -8 }}
                transition={{ duration: 0.3 }}
              >
                <div className="relative h-full bg-gradient-to-br from-[#0D2818] to-[#05140A] border border-[#C9A227]/20 p-8 overflow-hidden transition-all duration-300 group-hover:border-[#C9A227]/50 group-hover:shadow-lg group-hover:shadow-[#C9A227]/10">
                  {/* Background Glow */}
                  <div className="absolute -top-20 -right-20 w-40 h-40 bg-[#C9A227]/10 rounded-full blur-3xl opacity-0 group-hover:opacity-100 transition-opacity duration-500" />

                  {/* Icon */}
                  <motion.div
                    className="relative w-16 h-16 mb-6 rounded-full bg-[#C9A227]/10 border border-[#C9A227]/30 flex items-center justify-center text-[#C9A227]"
                    whileHover={{ rotate: 360 }}
                    transition={{ duration: 0.8 }}
                  >
                    {getIcon(card.iconType)}
                  </motion.div>

                  {/* Content */}
                  <h3 className="text-2xl font-bold text-[#F5F5DC] mb-3">
                    {card.title}
                  </h3>
                  <p className="text-[#8FBC8F] mb-6 leading-relaxed">
                    {card.description}
                  </p>

                  {/* Notes */}
                  <div className="space-y-2">
                    {card.notes.map((note, noteIndex) => (
                      <motion.div
                        key={note}
                        className="flex items-center gap-3"
                        initial={{ opacity: 0, x: -10 }}
                        whileInView={{ opacity: 1, x: 0 }}
                        viewport={{ once: true }}
                        transition={{ delay: 0.3 + noteIndex * 0.1 }}
                      >
                        <div className="w-1.5 h-1.5 rounded-full bg-[#C9A227]" />
                        <span className="text-[#F5F5DC]/80 text-sm">{note}</span>
                      </motion.div>
                    ))}
                  </div>

                  {/* Bottom Line */}
                  <div className="absolute bottom-0 left-0 right-0 h-0.5 bg-gradient-to-r from-transparent via-[#C9A227] to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-300" />
                </div>
              </motion.div>
            </ScrollReveal>
          ))}
        </div>

        {/* Flavor Profile */}
        {(tastingConfig.flavorWheel.title || tastingConfig.flavorWheel.bars.length > 0) && (
          <ScrollReveal delay={0.4} className="mt-20">
            <div className="relative bg-gradient-to-br from-[#0D2818]/80 to-[#05140A]/80 border border-[#C9A227]/20 rounded-lg p-8 md:p-12">
              <div className="grid md:grid-cols-2 gap-12 items-center">
                {/* Flavor Wheel Description */}
                <div>
                  {tastingConfig.flavorWheel.title && (
                    <h3 className="text-2xl md:text-3xl font-bold text-[#F5F5DC] mb-4">
                      {tastingConfig.flavorWheel.title}
                    </h3>
                  )}
                  {tastingConfig.flavorWheel.description && (
                    <p className="text-[#8FBC8F] leading-relaxed mb-6">
                      {tastingConfig.flavorWheel.description}
                    </p>
                  )}
                  {tastingConfig.flavorWheel.tags.length > 0 && (
                    <div className="flex flex-wrap gap-3">
                      {tastingConfig.flavorWheel.tags.map((note) => (
                        <span
                          key={note}
                          className="px-4 py-2 bg-[#C9A227]/10 border border-[#C9A227]/30 text-[#C9A227] text-sm rounded-full"
                        >
                          {note}
                        </span>
                      ))}
                    </div>
                  )}
                </div>

                {/* Visual Flavor Bars */}
                {tastingConfig.flavorWheel.bars.length > 0 && (
                  <div className="space-y-4">
                    {tastingConfig.flavorWheel.bars.map((item) => (
                  <div key={item.label}>
                    <div className="flex justify-between mb-2">
                      <span className="text-[#F5F5DC] text-sm">{item.label}</span>
                      <span className="text-[#C9A227] text-sm">{item.value}%</span>
                    </div>
                    <div className="h-2 bg-[#1A4D2E]/50 rounded-full overflow-hidden">
                      <motion.div
                        className="h-full rounded-full"
                        style={{ backgroundColor: item.color }}
                        initial={{ width: 0 }}
                        whileInView={{ width: `${item.value}%` }}
                        viewport={{ once: true }}
                        transition={{ duration: 1, delay: 0.5, ease: [0.22, 1, 0.36, 1] }}
                      />
                    </div>
                  </div>
                ))}
                  </div>
                )}
              </div>
            </div>
          </ScrollReveal>
        )}
      </div>
    </section>
  );
}
