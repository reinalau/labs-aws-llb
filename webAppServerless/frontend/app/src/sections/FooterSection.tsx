import { motion } from 'framer-motion';
import { Leaf, MapPin, Mail, ExternalLink } from 'lucide-react';
import { ButterflyIcon } from '@/components/ButterflyIcon';

export function FooterSection() {
  return (
    <footer className="bg-[#05140A] border-t border-[#1a4a2e]">
      <div className="max-w-7xl mx-auto px-4 py-16">
        <div className="grid md:grid-cols-4 gap-8">
          {/* Brand */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6 }}
            className="md:col-span-2"
          >
            <div className="flex items-center gap-2 mb-4">
              <ButterflyIcon className="w-8 h-8 text-[#C9A227]" />
              <div className="flex items-center gap-2">
                <span className="text-2xl font-bold text-[#F5F5DC]">
                  Mariposas <span className="text-[#C9A227]">Bonaerenses</span>
                </span>
                <div className="flex flex-col w-7 h-5 mt-1 rounded-sm overflow-hidden opacity-90" title="Argentina">
                  <div className="flex-1 bg-[#74ACDF]" />
                  <div className="flex-1 bg-white flex items-center justify-center">
                    <div className="w-[5px] h-[5px] rounded-full bg-[#F6B40E]" />
                  </div>
                  <div className="flex-1 bg-[#74ACDF]" />
                </div>
              </div>
            </div>
            <p className="text-[#8FBC8F] mb-6 max-w-md">
              Proyecto de documentación de la biodiversidad de mariposas nativas
              de la provincia de Buenos Aires, Argentina.
            </p>
            <div className="flex items-center gap-4 text-sm text-[#8FBC8F]">
              <span className="flex items-center gap-1">
                <Leaf className="w-4 h-4 text-[#C9A227]" />
                Educación Ambiental
              </span>
              <span className="flex items-center gap-1">
                <MapPin className="w-4 h-4 text-[#C9A227]" />
                Buenos Aires, Argentina
              </span>
            </div>
          </motion.div>

          {/* Links */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.2 }}
          >
            <h4 className="text-lg font-bold text-[#F5F5DC] mb-4">Enlaces</h4>
            <ul className="space-y-2">
              <li>
                <a
                  href="https://www.ambiente.gba.gob.ar/"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-[#8FBC8F] hover:text-[#C9A227] transition-colors flex items-center gap-1"
                >
                  Ministerio de Ambiente BA
                  <ExternalLink className="w-3 h-3" />
                </a>
              </li>
              <li>
                <a
                  href="https://www.ambiente.gba.gob.ar/pdfs/002_Catalogo_Nativas_ABRIL2024.pdf"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-[#8FBC8F] hover:text-[#C9A227] transition-colors flex items-center gap-1"
                >
                  Plan Nativas
                </a>
              </li>
            </ul>
          </motion.div>

          {/* Contact */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            whileInView={{ opacity: 1, y: 0 }}
            viewport={{ once: true }}
            transition={{ duration: 0.6, delay: 0.4 }}
          >
            <h4 className="text-lg font-bold text-[#F5F5DC] mb-4">Contacto</h4>
            <div className="space-y-3 text-[#8FBC8F]">
              <p className="flex items-start gap-2">
                <MapPin className="w-5 h-5 text-[#C9A227] flex-shrink-0 mt-0.5" />
                <span>
                  Laura Bolaños<br />
                </span>
              </p>
              <p className="flex items-center gap-2">
                <Mail className="w-5 h-5 text-[#C9A227]" />
                <span>https://laurabolanos-cloud.netlify.app</span>
              </p>
            </div>
          </motion.div>
        </div>

        {/* Bottom */}
        <motion.div
          initial={{ opacity: 0 }}
          whileInView={{ opacity: 1 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6, delay: 0.6 }}
          className="mt-12 pt-8 border-t border-[#1a4a2e] text-center"
        >
          <p className="text-sm text-[#8FBC8F]/70">
            © {new Date().getFullYear()} Mariposas Bonaerenses. Plantá nativas!
          </p>
          <p className="text-xs text-[#8FBC8F]/50 mt-2">
            Basado en el fascículo "Mariposas Bonaerenses" del Ministerio de Ambiente de la Provincia de Buenos Aires.
          </p>
        </motion.div>
      </div>
    </footer>
  );
}
