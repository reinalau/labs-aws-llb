import { motion, AnimatePresence } from 'framer-motion';
import { ScrollReveal } from '../components/custom/ScrollReveal';
import { useState } from 'react';
import { X, Bird, PawPrint, TreePine, Flower2 } from 'lucide-react';
import { exploreConfig } from '../config';
import type { HotspotConfig } from '../config';

export function ExploreSection() {
  // Null check for empty config
  if (!exploreConfig.exploreImage || exploreConfig.hotspots.length === 0) {
    return null;
  }

  const [activeHotspot, setActiveHotspot] = useState<HotspotConfig | null>(null);

  // Map iconType string to icon component
  const getIcon = (iconType: HotspotConfig['iconType']) => {
    const iconMap = {
      bird: <Bird className="w-5 h-5" />,
      pawprint: <PawPrint className="w-5 h-5" />,
      treepine: <TreePine className="w-5 h-5" />,
      flower: <Flower2 className="w-5 h-5" />,
    };
    return iconMap[iconType];
  };

  return (
    <section className="relative w-full py-24 md:py-32 bg-gradient-to-b from-[#05140A] via-[#0a1f12] to-[#0D2818] overflow-hidden">
      {/* Section Header */}
      <div className="relative z-10 max-w-7xl mx-auto px-6 lg:px-12 mb-16">
        <ScrollReveal className="text-center">
          {exploreConfig.label && (
            <span className="text-[#C9A227] text-sm tracking-[0.3em] uppercase mb-4 block">
              {exploreConfig.label}
            </span>
          )}
          <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold text-[#F5F5DC] mb-4">
            {exploreConfig.heading.map((line, index) => (
              <span key={index}>{line}</span>
            ))}
            {exploreConfig.headingAccent && (
              <span className="gold-gradient-text">{exploreConfig.headingAccent}</span>
            )}
          </h2>
          {exploreConfig.description && (
            <p className="text-[#8FBC8F] text-lg max-w-2xl mx-auto">
              {exploreConfig.description}
            </p>
          )}
        </ScrollReveal>
      </div>

      {/* Interactive Image */}
      <ScrollReveal className="relative z-10 max-w-6xl mx-auto px-6 lg:px-12">
        <div className="relative rounded-lg overflow-hidden">
          {/* Main Jungle Image */}
          <img
            src={exploreConfig.exploreImage}
            alt="Explore Scene"
            className="w-full h-auto object-cover"
          />

          {/* Overlay */}
          <div className="absolute inset-0 bg-gradient-to-t from-[#05140A]/80 via-transparent to-[#05140A]/30" />

          {/* Hotspots */}
          {exploreConfig.hotspots.map((hotspot, index) => (
            <motion.button
              key={hotspot.id}
              className="absolute w-12 h-12 -translate-x-1/2 -translate-y-1/2 z-20"
              style={{ left: `${hotspot.x}%`, top: `${hotspot.y}%` }}
              onClick={() => setActiveHotspot(hotspot)}
              initial={{ opacity: 0, scale: 0 }}
              whileInView={{ opacity: 1, scale: 1 }}
              viewport={{ once: true }}
              transition={{ delay: 0.5 + index * 0.15, duration: 0.5 }}
              whileHover={{ scale: 1.2 }}
            >
              {/* Pulse Rings */}
              <span className="absolute inset-0 rounded-full bg-[#C9A227]/30 pulse-ring" />
              <span className="absolute inset-0 rounded-full bg-[#C9A227]/20 pulse-ring animation-delay-200" />
              
              {/* Center Dot */}
              <span className="absolute inset-2 rounded-full bg-[#C9A227] flex items-center justify-center shadow-lg shadow-[#C9A227]/50">
                <span className="w-2 h-2 rounded-full bg-[#F5F5DC]" />
              </span>
            </motion.button>
          ))}

          {/* Hint Text */}
          {exploreConfig.hint && (
            <motion.div
              className="absolute bottom-6 left-1/2 -translate-x-1/2 text-[#8FBC8F] text-sm tracking-wider"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              transition={{ delay: 1.5 }}
            >
              {exploreConfig.hint}
            </motion.div>
          )}
        </div>
      </ScrollReveal>

      {/* Info Modal */}
      <AnimatePresence>
        {activeHotspot && (
          <motion.div
            className="fixed inset-0 z-50 flex items-center justify-center p-6"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            onClick={() => setActiveHotspot(null)}
          >
            {/* Backdrop */}
            <motion.div
              className="absolute inset-0 bg-[#05140A]/90 backdrop-blur-sm"
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
            />

            {/* Modal Content */}
            <motion.div
              className="relative bg-gradient-to-br from-[#0D2818] to-[#05140A] border border-[#C9A227]/30 rounded-lg max-w-lg w-full overflow-hidden"
              initial={{ opacity: 0, scale: 0.9, y: 20 }}
              animate={{ opacity: 1, scale: 1, y: 0 }}
              exit={{ opacity: 0, scale: 0.9, y: 20 }}
              transition={{ type: 'spring', damping: 25, stiffness: 300 }}
              onClick={(e) => e.stopPropagation()}
            >
              {/* Close Button */}
              <button
                className="absolute top-4 right-4 z-10 w-10 h-10 rounded-full bg-[#C9A227]/10 flex items-center justify-center text-[#C9A227] hover:bg-[#C9A227]/20 transition-colors"
                onClick={() => setActiveHotspot(null)}
              >
                <X className="w-5 h-5" />
              </button>

              {/* Image */}
              <div className="relative h-48 bg-gradient-to-b from-[#1A4D2E]/50 to-transparent flex items-center justify-center">
                <motion.img
                  src={activeHotspot.image}
                  alt={activeHotspot.title}
                  className="h-40 w-auto object-contain"
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: 0.2 }}
                />
              </div>

              {/* Content */}
              <div className="p-8">
                <div className="flex items-center gap-3 mb-4">
                  <div className="w-10 h-10 rounded-full bg-[#C9A227]/20 flex items-center justify-center text-[#C9A227]">
                    {getIcon(activeHotspot.iconType)}
                  </div>
                  <h3 className="text-2xl font-bold text-[#F5F5DC]">
                    {activeHotspot.title}
                  </h3>
                </div>
                <p className="text-[#8FBC8F] leading-relaxed">
                  {activeHotspot.description}
                </p>
              </div>

              {/* Decorative Border */}
              <div className="absolute inset-x-0 bottom-0 h-1 bg-gradient-to-r from-transparent via-[#C9A227] to-transparent" />
            </motion.div>
          </motion.div>
        )}
      </AnimatePresence>
    </section>
  );
}
