import type { Mariposa } from '@/types/mariposas';
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog';
import { Badge } from '@/components/ui/badge';
import { Leaf, MapPin, Info, Sprout } from 'lucide-react';
import { ecorregiones } from '@/types/mariposas';

interface MariposaDetailProps {
  mariposa: Mariposa | null;
  isOpen: boolean;
  onClose: () => void;
}

export function MariposaDetail({ mariposa, isOpen, onClose }: MariposaDetailProps) {
  if (!mariposa) return null;

  const ecorregion = ecorregiones.find(e => e.id === mariposa.ecorregion);

  return (
    <Dialog open={isOpen} onOpenChange={onClose}>
      <DialogContent className="sm:max-w-[700px] bg-[#0D2818] border-[#1a4a2e] text-[#F5F5DC] max-h-[90vh] overflow-y-auto">
        <DialogHeader>
          <DialogTitle className="text-3xl font-bold text-[#C9A227]">
            {mariposa.nombreComun}
          </DialogTitle>
        </DialogHeader>
        
        <div className="grid md:grid-cols-2 gap-6 mt-4">
          <div className="space-y-4">
            <div className="aspect-[3/4] rounded-lg overflow-hidden">
              <img
                src={mariposa.imagen}
                alt={mariposa.nombreComun}
                className="w-full h-full object-cover"
              />
            </div>
          </div>
          
          <div className="space-y-6">
            <div>
              <p className="text-lg italic text-[#8FBC8F] mb-2">
                {mariposa.nombreCientifico}
              </p>
              <Badge variant="outline" className="border-[#C9A227] text-[#C9A227]">
                <MapPin className="w-3 h-3 mr-1" />
                {ecorregion?.nombre || mariposa.ecorregion}
              </Badge>
            </div>
            
            <div className="space-y-3">
              <div className="flex items-start gap-3">
                <Info className="w-5 h-5 text-[#C9A227] mt-0.5 flex-shrink-0" />
                <div>
                  <h4 className="font-semibold text-[#F5F5DC] mb-1">Descripción</h4>
                  <p className="text-sm text-[#8FBC8F]">{mariposa.descripcion}</p>
                </div>
              </div>
              
              <div className="flex items-start gap-3">
                <Sprout className="w-5 h-5 text-[#C9A227] mt-0.5 flex-shrink-0" />
                <div>
                  <h4 className="font-semibold text-[#F5F5DC] mb-1">Planta Nutricia</h4>
                  <p className="text-sm text-[#8FBC8F]">
                    <span className="italic">{mariposa.plantaNutricia.nombreCientifico}</span>
                    <br />
                    <span className="text-[#C9A227]">{mariposa.plantaNutricia.nombreComun}</span>
                  </p>
                </div>
              </div>
              
              <div className="flex items-start gap-3">
                <Leaf className="w-5 h-5 text-[#C9A227] mt-0.5 flex-shrink-0" />
                <div>
                  <h4 className="font-semibold text-[#F5F5DC] mb-1">Ecorregión</h4>
                  <p className="text-sm text-[#8FBC8F]">
                    {ecorregion?.nombre}
                    <br />
                    <span className="text-xs">{ecorregion?.descripcion}</span>
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </DialogContent>
    </Dialog>
  );
}
