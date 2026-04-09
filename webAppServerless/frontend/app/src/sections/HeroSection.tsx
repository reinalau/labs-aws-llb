import { motion } from 'framer-motion';
import { ChevronDown } from 'lucide-react';
import { ButterflyIcon } from '@/components/ButterflyIcon';
import { Button } from '@/components/ui/button';

interface HeroSectionProps {
  onScrollToGallery: () => void;
}

export function HeroSection({ onScrollToGallery }: HeroSectionProps) {
  return (
    <section className="relative min-h-screen flex items-center justify-center overflow-hidden">
      {/* Background Image */}
      <div className="absolute inset-0">
        <img
          src="/images/hero_pampa.jpg"
          alt="Pampa argentino"
          className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-b from-[#05140A]/70 via-[#05140A]/50 to-[#05140A]" />
      </div>

      {/* Floating Butterflies Decoration */}
      <motion.div
        className="absolute top-24 left-16 opacity-30 text-[#C9A227]"
        animate={{ y: [0, -20, 0], rotate: [-5, 10, -5] }}
        transition={{ duration: 7, repeat: Infinity, ease: "easeInOut" }}
      >
        <ButterflyIcon className="w-24 h-24 drop-shadow-2xl" />
      </motion.div>

      <motion.div
        className="absolute bottom-40 right-16 opacity-20 text-[#8FBC8F]"
        animate={{ y: [0, 25, 0], rotate: [10, -5, 10] }}
        transition={{ duration: 9, repeat: Infinity, ease: "easeInOut" }}
      >
        <ButterflyIcon className="w-40 h-40 drop-shadow-2xl" />
      </motion.div>

      {/* Content */}
      <div className="relative z-10 text-center px-4 max-w-4xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
        >
          <div className="flex items-center justify-center gap-2 mb-6">
            <ButterflyIcon className="w-8 h-8 text-[#C9A227]" />
            <span className="text-[#8FBC8F] text-lg tracking-widest uppercase">
              Provincia de Buenos Aires
            </span>
            <ButterflyIcon className="w-8 h-8 text-[#C9A227]" />
          </div>
        </motion.div>

        <motion.h1
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="text-5xl md:text-7xl font-bold mb-6"
        >
          <span className="text-[#F5F5DC]">MARIPOSAS</span>
          <br />
          <span className="text-[#C9A227]">BONAERENSES</span>
        </motion.h1>

        <motion.p
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.4 }}
          className="text-xl text-[#8FBC8F] mb-8 max-w-2xl mx-auto"
        >
          Descubre la diversidad de mariposas nativas de la provincia de Buenos Aires.
          Conoce sus características, plantas nutricias y ecorregiones.
        </motion.p>

        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.6 }}
        >
          <Button
            onClick={onScrollToGallery}
            size="lg"
            className="bg-[#C9A227] hover:bg-[#b8921f] text-[#05140A] font-bold px-8 py-6 text-lg"
          >
            <ButterflyIcon className="w-5 h-5 mr-2" />
            Explorar Especies
          </Button>
        </motion.div>

        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ duration: 0.8, delay: 1 }}
          className="mt-16"
        >
          <div className="flex items-center justify-center gap-8 text-[#8FBC8F]">
            <div className="text-center">
              <div className="text-3xl font-bold text-[#C9A227]">8+</div>
              <div className="text-sm">Especies</div>
            </div>
            <div className="w-px h-12 bg-[#1a4a2e]" />
            <div className="text-center">
              <div className="text-3xl font-bold text-[#C9A227]">3</div>
              <div className="text-sm">Ecorregiones</div>
            </div>
            <div className="w-px h-12 bg-[#1a4a2e]" />
            <div className="text-center">
              <div className="text-3xl font-bold text-[#C9A227]">100%</div>
              <div className="text-sm">Nativas</div>
            </div>
          </div>
        </motion.div>
      </div>

      {/* Scroll Indicator */}
      <motion.div
        className="absolute bottom-4 left-1/2 -translate-x-1/2 cursor-pointer"
        animate={{ y: [0, 10, 0] }}
        transition={{ duration: 2, repeat: Infinity }}
        onClick={onScrollToGallery}
      >
        <ChevronDown className="w-8 h-8 text-[#C9A227]" />
      </motion.div>
    </section>
  );
}
