import { motion } from 'framer-motion';
import { ScrollReveal } from '../components/custom/ScrollReveal';
import { Leaf, Sparkles } from 'lucide-react';
import { storyConfig } from '../config';

export function StorySection() {
  // Null check for empty config
  if (!storyConfig.storyImage || storyConfig.heading.length === 0) {
    return null;
  }
  return (
    <section className="relative w-full py-24 md:py-32 bg-gradient-to-b from-[#05140A] via-[#0a1f12] to-[#0D2818] overflow-hidden">
      {/* Decorative Elements */}
      <div className="absolute top-0 left-0 w-full h-px bg-gradient-to-r from-transparent via-[#C9A227]/30 to-transparent" />
      
      {/* Background Pattern */}
      <div className="absolute inset-0 opacity-5">
        <div className="absolute top-20 left-10 w-64 h-64 rounded-full bg-[#C9A227] blur-3xl" />
        <div className="absolute bottom-20 right-10 w-80 h-80 rounded-full bg-[#2D6A4F] blur-3xl" />
      </div>

      <div className="relative z-10 max-w-7xl mx-auto px-6 lg:px-12">
        <div className="grid lg:grid-cols-2 gap-16 items-center">
          {/* Text Content */}
          <div className="order-2 lg:order-1">
            {storyConfig.label && (
              <ScrollReveal direction="left">
                <div className="flex items-center gap-3 mb-6">
                  <Leaf className="w-5 h-5 text-[#C9A227]" />
                  <span className="text-[#C9A227] text-sm tracking-[0.3em] uppercase">{storyConfig.label}</span>
                </div>
              </ScrollReveal>
            )}

            <ScrollReveal direction="left" delay={0.1}>
              <h2 className="text-4xl md:text-5xl lg:text-6xl font-bold text-[#F5F5DC] mb-8 leading-tight">
                {storyConfig.heading.map((line, index) => (
                  <span key={index}>
                    {line}
                    {index < storyConfig.heading.length - 1 && <br />}
                  </span>
                ))}
                {storyConfig.headingAccent && (
                  <>
                    <br />
                    <span className="gold-gradient-text">{storyConfig.headingAccent}</span>
                  </>
                )}
              </h2>
            </ScrollReveal>

            {storyConfig.paragraphs.length > 0 && (
              <ScrollReveal direction="left" delay={0.2}>
                <div className="space-y-6 text-[#8FBC8F] text-lg leading-relaxed">
                  {storyConfig.paragraphs.map((paragraph, index) => (
                    <p key={index}>{paragraph}</p>
                  ))}
                </div>
              </ScrollReveal>
            )}

            <ScrollReveal direction="left" delay={0.3}>
              <div className="mt-10 flex items-center gap-4">
                <div className="h-px flex-1 bg-gradient-to-r from-[#C9A227]/50 to-transparent" />
                <div className="flex items-center gap-2 text-[#C9A227]">
                  <Sparkles className="w-4 h-4" />
                  <span className="text-sm tracking-wider italic">Le Chocolatier Sauvage</span>
                </div>
              </div>
            </ScrollReveal>

            {/* Stats */}
            {storyConfig.stats.length > 0 && (
              <ScrollReveal direction="up" delay={0.4}>
                <div className="mt-12 grid grid-cols-3 gap-8">
                  {storyConfig.stats.map((stat, index) => (
                    <motion.div
                      key={stat.label}
                      className="text-center"
                      initial={{ opacity: 0, y: 20 }}
                      whileInView={{ opacity: 1, y: 0 }}
                      viewport={{ once: true }}
                      transition={{ delay: 0.5 + index * 0.1, duration: 0.6 }}
                    >
                      <div className="text-3xl md:text-4xl font-bold text-[#C9A227] mb-2">
                        {stat.value}
                      </div>
                      <div className="text-sm text-[#8FBC8F] tracking-wider">
                        {stat.label}
                      </div>
                    </motion.div>
                  ))}
                </div>
              </ScrollReveal>
            )}
          </div>

          {/* Image */}
          <ScrollReveal direction="right" delay={0.2} className="order-1 lg:order-2">
            <div className="relative">
              {/* Decorative Frame */}
              <div className="absolute -inset-4 border border-[#C9A227]/30 rounded-sm" />
              <div className="absolute -inset-8 border border-[#C9A227]/10 rounded-sm" />
              
              {/* Main Image */}
              <div className="relative overflow-hidden rounded-sm">
                <motion.img
                  src={storyConfig.storyImage}
                  alt="Brand Story"
                  className="w-full h-auto object-cover"
                  whileHover={{ scale: 1.02 }}
                  transition={{ duration: 0.6 }}
                />

                {/* Overlay Gradient */}
                <div className="absolute inset-0 bg-gradient-to-t from-[#0D2818]/60 via-transparent to-transparent" />
              </div>

              {/* Floating Badge */}
              <motion.div
                className="absolute -bottom-6 -left-6 bg-[#0D2818] border border-[#C9A227]/50 px-6 py-4"
                initial={{ opacity: 0, scale: 0.8 }}
                whileInView={{ opacity: 1, scale: 1 }}
                viewport={{ once: true }}
                transition={{ delay: 0.8, duration: 0.6 }}
              >
                <div className="text-[#C9A227] text-sm tracking-wider">Est. 2024</div>
                <div className="text-[#F5F5DC] text-xs text-[#8FBC8F]">Ecuador · Wild Cacao</div>
              </motion.div>
            </div>
          </ScrollReveal>
        </div>
      </div>

      {/* Bottom Border */}
      <div className="absolute bottom-0 left-0 w-full h-px bg-gradient-to-r from-transparent via-[#C9A227]/30 to-transparent" />
    </section>
  );
}
