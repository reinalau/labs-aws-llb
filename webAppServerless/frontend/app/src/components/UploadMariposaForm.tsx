import { useState, useRef } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Textarea } from '@/components/ui/textarea';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { useAuth } from '@/context/AuthContext';
import { Upload, Camera, Loader2, X } from 'lucide-react';

interface UploadMariposaFormProps {
  onSubmit: (data: {
    nombreComun: string;
    nombreCientifico: string;
    descripcion: string;
    plantaNutricia: { nombreCientifico: string; nombreComun: string };
    ecorregion: string;
    imagen: File;
  }) => Promise<void>;
  isLoading?: boolean;
}

export function UploadMariposaForm({ onSubmit, isLoading: externalLoading }: UploadMariposaFormProps) {
  useAuth(); // El usuario está disponible si es necesario
  const fileInputRef = useRef<HTMLInputElement>(null);
  const [isLocalLoading, setIsLocalLoading] = useState(false);
  const isLoading = externalLoading ?? isLocalLoading;
  const [previewUrl, setPreviewUrl] = useState<string | null>(null);
  const [selectedFile, setSelectedFile] = useState<File | null>(null);
  
  const [formData, setFormData] = useState({
    nombreComun: '',
    nombreCientifico: '',
    descripcion: '',
    plantaNutriciaCientifico: '',
    plantaNutriciaComun: '',
    ecorregion: 'pampeana'
  });

  const handleFileSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      setSelectedFile(file);
      const url = URL.createObjectURL(file);
      setPreviewUrl(url);
    }
  };

  const clearImage = () => {
    setSelectedFile(null);
    setPreviewUrl(null);
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedFile) return;

    setIsLocalLoading(true);
    try {
      await onSubmit({
        nombreComun: formData.nombreComun,
        nombreCientifico: formData.nombreCientifico,
        descripcion: formData.descripcion,
        plantaNutricia: {
          nombreCientifico: formData.plantaNutriciaCientifico,
          nombreComun: formData.plantaNutriciaComun
        },
        ecorregion: formData.ecorregion,
        imagen: selectedFile
      });
      
      // Reset form
      setFormData({
        nombreComun: '',
        nombreCientifico: '',
        descripcion: '',
        plantaNutriciaCientifico: '',
        plantaNutriciaComun: '',
        ecorregion: 'pampeana'
      });
      clearImage();
    } finally {
      setIsLocalLoading(false);
    }
  };

  return (
    <Card className="bg-[#0D2818] border-[#1a4a2e] text-[#F5F5DC]">
      <CardHeader>
        <CardTitle className="flex items-center gap-2 text-xl text-[#C9A227]">
          <Camera className="w-5 h-5" />
          Subir Nueva Mariposa
        </CardTitle>
      </CardHeader>
      
      <CardContent>
        <form onSubmit={handleSubmit} className="space-y-6">
          {/* Image Upload */}
          <div className="space-y-2">
            <Label className="text-[#8FBC8F]">Fotografía</Label>
            <div className="relative">
              {previewUrl ? (
                <div className="relative aspect-video rounded-lg overflow-hidden">
                  <img
                    src={previewUrl}
                    alt="Preview"
                    className="w-full h-full object-cover"
                  />
                  <button
                    type="button"
                    onClick={clearImage}
                    className="absolute top-2 right-2 p-1 bg-red-500/80 rounded-full hover:bg-red-500 transition-colors"
                  >
                    <X className="w-4 h-4 text-white" />
                  </button>
                </div>
              ) : (
                <div
                  onClick={() => fileInputRef.current?.click()}
                  className="aspect-video border-2 border-dashed border-[#1a4a2e] rounded-lg flex flex-col items-center justify-center cursor-pointer hover:border-[#C9A227]/50 transition-colors bg-[#05140A]/50"
                >
                  <Upload className="w-10 h-10 text-[#8FBC8F] mb-2" />
                  <p className="text-sm text-[#8FBC8F]">Haz clic para seleccionar una imagen</p>
                  <p className="text-xs text-[#8FBC8F]/60 mt-1">JPG, PNG hasta 10MB</p>
                </div>
              )}
              <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                onChange={handleFileSelect}
                className="hidden"
                required
              />
            </div>
          </div>

          <div className="grid md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="nombreComun" className="text-[#8FBC8F]">Nombre Común *</Label>
              <Input
                id="nombreComun"
                value={formData.nombreComun}
                onChange={(e) => setFormData({ ...formData, nombreComun: e.target.value })}
                placeholder="Ej: Bandera Argentina"
                required
                className="bg-[#05140A] border-[#1a4a2e] text-[#F5F5DC] placeholder:text-[#8FBC8F]/50"
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="nombreCientifico" className="text-[#8FBC8F]">Nombre Científico *</Label>
              <Input
                id="nombreCientifico"
                value={formData.nombreCientifico}
                onChange={(e) => setFormData({ ...formData, nombreCientifico: e.target.value })}
                placeholder="Ej: Morpho episthropus"
                required
                className="bg-[#05140A] border-[#1a4a2e] text-[#F5F5DC] placeholder:text-[#8FBC8F]/50 italic"
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="descripcion" className="text-[#8FBC8F]">Descripción *</Label>
            <Textarea
              id="descripcion"
              value={formData.descripcion}
              onChange={(e) => setFormData({ ...formData, descripcion: e.target.value })}
              placeholder="Describe las características de la mariposa..."
              required
              rows={4}
              className="bg-[#05140A] border-[#1a4a2e] text-[#F5F5DC] placeholder:text-[#8FBC8F]/50 resize-none"
            />
          </div>

          <div className="grid md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <Label htmlFor="plantaNutriciaComun" className="text-[#8FBC8F]">Planta Nutricia (Nombre Común) *</Label>
              <Input
                id="plantaNutriciaComun"
                value={formData.plantaNutriciaComun}
                onChange={(e) => setFormData({ ...formData, plantaNutriciaComun: e.target.value })}
                placeholder="Ej: Coronillo"
                required
                className="bg-[#05140A] border-[#1a4a2e] text-[#F5F5DC] placeholder:text-[#8FBC8F]/50"
              />
            </div>
            
            <div className="space-y-2">
              <Label htmlFor="plantaNutriciaCientifico" className="text-[#8FBC8F]">Planta Nutricia (Científico) *</Label>
              <Input
                id="plantaNutriciaCientifico"
                value={formData.plantaNutriciaCientifico}
                onChange={(e) => setFormData({ ...formData, plantaNutriciaCientifico: e.target.value })}
                placeholder="Ej: Scutia buxifolia"
                required
                className="bg-[#05140A] border-[#1a4a2e] text-[#F5F5DC] placeholder:text-[#8FBC8F]/50 italic"
              />
            </div>
          </div>

          <div className="space-y-2">
            <Label htmlFor="ecorregion" className="text-[#8FBC8F]">Ecorregión *</Label>
            <select
              id="ecorregion"
              value={formData.ecorregion}
              onChange={(e) => setFormData({ ...formData, ecorregion: e.target.value })}
              required
              className="w-full bg-[#05140A] border border-[#1a4a2e] text-[#F5F5DC] rounded-md px-3 py-2 focus:outline-none focus:ring-2 focus:ring-[#C9A227]/50"
              style={{ colorScheme: 'dark' }}
            >
              <option value="pampeana" style={{ background: '#05140A', color: '#F5F5DC' }}>Pampeana</option>
              <option value="espinal" style={{ background: '#05140A', color: '#F5F5DC' }}>Espinal</option>
              <option value="delta" style={{ background: '#05140A', color: '#F5F5DC' }}>Delta e Islas del Paraná</option>
            </select>
          </div>

          <Button
            type="submit"
            disabled={isLoading || !selectedFile}
            className="w-full bg-[#C9A227] hover:bg-[#b8921f] text-[#05140A] font-bold py-3"
          >
            {isLoading ? (
              <>
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                Subiendo...
              </>
            ) : (
              <>
                <Upload className="mr-2 h-4 w-4" />
                Subir Mariposa
              </>
            )}
          </Button>

          <p className="text-xs text-center text-[#8FBC8F]/70">
            Los datos se guardarán en DynamoDB vía API Gateway
          </p>
        </form>
      </CardContent>
    </Card>
  );
}
