import type { Mariposa } from '@/types/mariposas';
import { Card, CardContent } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Leaf, Camera } from 'lucide-react';

interface MariposaCardProps {
  mariposa: Mariposa;
  onClick?: () => void;
}

export function MariposaCard({ mariposa, onClick }: MariposaCardProps) {
  return (
    <Card 
      onClick={onClick}
      className="group cursor-pointer overflow-hidden bg-[#0a1f12] border-[#1a4a2e] hover:border-[#C9A227]/50 transition-all duration-300 hover:shadow-xl hover:shadow-[#C9A227]/10"
    >
      <div className="relative aspect-[3/4] overflow-hidden">
        <img
          src={mariposa.imagen}
          alt={mariposa.nombreComun}
          className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-[#05140A] via-transparent to-transparent opacity-60" />
        
        {mariposa.usuarioSubido && (
          <Badge className="absolute top-3 right-3 bg-[#C9A227] text-[#05140A]">
            <Camera className="w-3 h-3 mr-1" />
            Usuario
          </Badge>
        )}
        
        <div className="absolute bottom-0 left-0 right-0 p-4">
          <h3 className="text-xl font-bold text-[#F5F5DC] mb-1">
            {mariposa.nombreComun}
          </h3>
          <p className="text-sm text-[#8FBC8F] italic mb-2">
            {mariposa.nombreCientifico}
          </p>
          <div className="flex items-center gap-2 text-xs text-[#C9A227]">
            <Leaf className="w-3 h-3" />
            <span className="truncate">
              {mariposa.plantaNutricia.nombreComun}
            </span>
          </div>
        </div>
      </div>
      
      <CardContent className="p-4 bg-[#0D2818]">
        <p className="text-sm text-[#8FBC8F] line-clamp-2">
          {mariposa.descripcion}
        </p>
      </CardContent>
    </Card>
  );
}
