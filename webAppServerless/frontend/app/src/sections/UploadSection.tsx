import { useState } from 'react';
import { motion } from 'framer-motion';
import { UploadMariposaForm } from '@/components/UploadMariposaForm';
import type { NuevaMariposaInput } from '@/hooks/useMariposas';
import { useAuth } from '@/context/AuthContext';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { Info, Lock } from 'lucide-react';
import { Button } from '@/components/ui/button';

interface UploadSectionProps {
  onNavigateToHome: () => void;
  onSubmit: (data: NuevaMariposaInput) => Promise<void>;
}

export function UploadSection({ onNavigateToHome, onSubmit }: UploadSectionProps) {
  const { isAuthenticated, user } = useAuth();
  const [showTechInfo, setShowTechInfo] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (data: NuevaMariposaInput) => {
    setIsSubmitting(true);
    try {
      await onSubmit(data);
    } finally {
      setIsSubmitting(false);
    }
  };

  if (!isAuthenticated) {
    return (
      <section className="min-h-screen pt-24 px-4 bg-[#05140A]">
        <div className="max-w-2xl mx-auto">
          <motion.div
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            <Alert className="bg-[#0D2818] border-[#C9A227] text-[#F5F5DC]">
              <Lock className="h-5 w-5 text-[#C9A227]" />
              <AlertDescription className="flex flex-col gap-4">
                <span>Debes iniciar sesión para subir mariposas.</span>
                <Button
                  onClick={onNavigateToHome}
                  className="bg-[#C9A227] hover:bg-[#b8921f] text-[#05140A] font-bold w-fit"
                >
                  Volver al Inicio
                </Button>
              </AlertDescription>
            </Alert>
          </motion.div>
        </div>
      </section>
    );
  }

  return (
    <section className="min-h-screen pt-24 pb-12 px-4 bg-[#05140A]">
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="text-center mb-8"
        >
          <div className="flex items-center justify-center gap-2 mb-4">
            <Info className="w-6 h-6 text-[#C9A227]" />
            <span className="text-[#8FBC8F] text-sm tracking-widest uppercase">
              Contribuye
            </span>
            <Info className="w-6 h-6 text-[#C9A227]" />
          </div>
          
          <h2 className="text-4xl md:text-5xl font-bold text-[#F5F5DC] mb-4">
            Subir <span className="text-[#C9A227]">Mariposa</span>
          </h2>
          
          <p className="text-lg text-[#8FBC8F] max-w-2xl mx-auto">
            Comparte tus avistamientos de mariposas nativas. Tu contribución ayuda a 
            documentar la biodiversidad de la provincia de Buenos Aires.
          </p>
        </motion.div>

        {/* Info Alert */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.2 }}
          className="mb-8"
        >
          <Alert className="bg-[#0D2818] border-[#1a4a2e] text-[#8FBC8F]">
            <Info 
              className="h-5 w-5 text-[#C9A227] cursor-pointer hover:text-[#e0c25a] transition-colors" 
              onClick={() => setShowTechInfo(!showTechInfo)}
            />
            <AlertDescription>
              <div className="flex flex-col gap-2">
                <div>
                  <strong className="text-[#C9A227]">{user?.nombre || 'Usuario'}</strong>, asegúrate de que la fotografía sea clara y la información sea precisa.
                </div>
                {showTechInfo && (
                  <motion.div 
                    initial={{ opacity: 0, height: 0 }}
                    animate={{ opacity: 1, height: 'auto' }}
                    className="text-sm mt-2 pt-2 border-t border-[#1a4a2e]/50"
                  >
                    *(Info técnica)* Los datos se guardarán en <strong className="text-[#C9A227]">Amazon DynamoDB</strong> a través de 
                    <strong className="text-[#C9A227]"> API Gateway</strong> y 
                    <strong className="text-[#C9A227]"> AWS Lambda</strong>.
                  </motion.div>
                )}
              </div>
            </AlertDescription>
          </Alert>
        </motion.div>

        {/* Form */}
        <motion.div
          initial={{ opacity: 0, y: 30 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8, delay: 0.4 }}
        >
          <UploadMariposaForm onSubmit={handleSubmit} isLoading={isSubmitting} />
        </motion.div>
      </div>
    </section>
  );
}
