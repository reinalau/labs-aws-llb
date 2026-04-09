import { useState, useRef } from 'react';
import { motion } from 'framer-motion';
import { MariposaCard } from '@/components/MariposaCard';
import { MariposaDetail } from '@/components/MariposaDetail';
import type { Mariposa } from '@/types/mariposas';
import { mariposasPrecargadas } from '@/data/mariposas';
import { ecorregiones } from '@/types/mariposas';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Badge } from '@/components/ui/badge';
import { Input } from '@/components/ui/input';
import { MapPin, Leaf, Search } from 'lucide-react';

interface GallerySectionProps {
  userMariposas?: Mariposa[];
}

export function GallerySection({ userMariposas = [] }: GallerySectionProps) {
  const [selectedMariposa, setSelectedMariposa] = useState<Mariposa | null>(null);
  const [isDetailOpen, setIsDetailOpen] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  const sectionRef = useRef<HTMLElement>(null);

  const allMariposas = [...mariposasPrecargadas, ...userMariposas];

  const handleCardClick = (mariposa: Mariposa) => {
    setSelectedMariposa(mariposa);
    setIsDetailOpen(true);
  };

  const filterMariposas = (ecorregionId: string) => {
    let filtered = allMariposas;

    if (ecorregionId !== 'all') {
      filtered = filtered.filter(m => m.ecorregion === ecorregionId);
    }

    if (searchQuery.trim()) {
      const query = searchQuery.toLowerCase().trim();
      filtered = filtered.filter(m =>
        m.nombreComun.toLowerCase().includes(query) ||
        m.nombreCientifico.toLowerCase().includes(query) ||
        m.plantaNutricia.nombreCientifico.toLowerCase().includes(query) ||
        m.plantaNutricia.nombreComun.toLowerCase().includes(query)
      );
    }

    return filtered;
  };

  return (
    <section ref={sectionRef} className="py-20 px-4 bg-[#05140A]">
      <div className="max-w-7xl mx-auto">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
          className="text-center mb-12"
        >
          <div className="flex items-center justify-center gap-2 mb-4">
            <Leaf className="w-6 h-6 text-[#C9A227]" />
            <span className="text-[#8FBC8F] text-sm tracking-widest uppercase">
              Colección
            </span>
            <Leaf className="w-6 h-6 text-[#C9A227]" />
          </div>

          <h2 className="text-4xl md:text-5xl font-bold text-[#F5F5DC] mb-4">
            Especies <span className="text-[#C9A227]">Nativas</span>
          </h2>

          <p className="text-lg text-[#8FBC8F] max-w-2xl mx-auto">
            Conoce las mariposas que habitan en los diferentes ecosistemas de la provincia de Buenos Aires.
            Cada especie está vinculada a plantas nutricias específicas.
          </p>
        </motion.div>

        {/* Tabs */}
        <Tabs defaultValue="all" className="w-full">
          <div className="flex flex-col md:flex-row justify-between items-center gap-4 mb-8">
            <TabsList className="flex flex-wrap justify-center gap-2 bg-transparent h-auto p-0">
              <TabsTrigger
                value="all"
                className="data-[state=active]:bg-[#C9A227] data-[state=active]:text-[#05140A] bg-[#0D2818] text-[#8FBC8F] border border-[#1a4a2e]"
              >
                <MapPin className="w-4 h-4 mr-1" />
                Todas
                <Badge variant="secondary" className="ml-2 bg-[#05140A] text-[#8FBC8F]">
                  {filterMariposas('all').length}
                </Badge>
              </TabsTrigger>

              {ecorregiones.map((eco) => (
                <TabsTrigger
                  key={eco.id}
                  value={eco.id}
                  className="data-[state=active]:bg-[#C9A227] data-[state=active]:text-[#05140A] bg-[#0D2818] text-[#8FBC8F] border border-[#1a4a2e]"
                >
                  <MapPin className="w-4 h-4 mr-1" />
                  {eco.nombre}
                  <Badge variant="secondary" className="ml-2 bg-[#05140A] text-[#8FBC8F]">
                    {filterMariposas(eco.id).length}
                  </Badge>
                </TabsTrigger>
              ))}
            </TabsList>

            {/* Search Box */}
            <div className="relative w-full md:w-72">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-[#8FBC8F]" />
              <Input
                type="text"
                placeholder="Buscar mariposa o planta..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                className="pl-10 bg-[#0D2818] border-[#1a4a2e] text-[#F5F5DC] placeholder:text-[#8FBC8F]/50 focus-visible:ring-[#C9A227]"
              />
            </div>
          </div>

          <TabsContent value="all">
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {filterMariposas('all').map((mariposa, index) => (
                <motion.div
                  key={mariposa.id}
                  initial={{ opacity: 0, y: 30 }}
                  whileInView={{ opacity: 1, y: 0 }}
                  viewport={{ once: true }}
                  transition={{ duration: 0.5, delay: index * 0.1 }}
                >
                  <MariposaCard
                    mariposa={mariposa}
                    onClick={() => handleCardClick(mariposa)}
                  />
                </motion.div>
              ))}
            </div>
          </TabsContent>

          {ecorregiones.map((eco) => (
            <TabsContent key={eco.id} value={eco.id}>
              <div className="mb-6 p-4 bg-[#0D2818] rounded-lg border border-[#1a4a2e]">
                <h3 className="text-xl font-bold text-[#C9A227] mb-2">{eco.nombre}</h3>
                <p className="text-[#8FBC8F]">{eco.descripcion}</p>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                {filterMariposas(eco.id).map((mariposa, index) => (
                  <motion.div
                    key={mariposa.id}
                    initial={{ opacity: 0, y: 30 }}
                    whileInView={{ opacity: 1, y: 0 }}
                    viewport={{ once: true }}
                    transition={{ duration: 0.5, delay: index * 0.1 }}
                  >
                    <MariposaCard
                      mariposa={mariposa}
                      onClick={() => handleCardClick(mariposa)}
                    />
                  </motion.div>
                ))}
              </div>
            </TabsContent>
          ))}
        </Tabs>

        {/* Info Section */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.8 }}
          className="mt-16 p-8 bg-gradient-to-r from-[#0D2818] to-[#1a4a2e] rounded-2xl border border-[#1a4a2e]"
        >
          <div className="grid md:grid-cols-3 gap-8 text-center">
            <div>
              <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-[#C9A227]/20 flex items-center justify-center">
                <Leaf className="w-8 h-8 text-[#C9A227]" />
              </div>
              <h4 className="text-lg font-bold text-[#F5F5DC] mb-2">Plantas Nutricias</h4>
              <p className="text-sm text-[#8FBC8F]">
                Cada mariposa depende de plantas específicas para su ciclo de vida.
              </p>
            </div>

            <div>
              <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-[#C9A227]/20 flex items-center justify-center">
                <MapPin className="w-8 h-8 text-[#C9A227]" />
              </div>
              <h4 className="text-lg font-bold text-[#F5F5DC] mb-2">Ecorregiones</h4>
              <p className="text-sm text-[#8FBC8F]">
                Tres ecorregiones diferentes: Pampeana, Espinal y Delta.
              </p>
            </div>

            <div>
              <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-[#C9A227]/20 flex items-center justify-center">
                <Leaf className="w-8 h-8 text-[#C9A227]" />
              </div>
              <h4 className="text-lg font-bold text-[#F5F5DC] mb-2">Conservación</h4>
              <p className="text-sm text-[#8FBC8F]">
                Las mariposas son bioindicadores del estado de los ecosistemas.
              </p>
            </div>
          </div>
        </motion.div>
      </div>

      <MariposaDetail
        mariposa={selectedMariposa}
        isOpen={isDetailOpen}
        onClose={() => setIsDetailOpen(false)}
      />
    </section>
  );
}
