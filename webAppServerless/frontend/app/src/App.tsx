import { useState, useRef } from 'react';
import { AuthProvider } from '@/context/AuthContext';
import { Navbar } from '@/components/Navbar';
import { HeroSection } from '@/sections/HeroSection';
import { GallerySection } from '@/sections/GallerySection';
import { UploadSection } from '@/sections/UploadSection';
import { FooterSection } from '@/sections/FooterSection';
import { useMariposas } from '@/hooks/useMariposas';
import { Toaster } from '@/components/ui/sonner';
import { toast } from 'sonner';

function AppContent() {
  const [currentPage, setCurrentPage] = useState<'home' | 'upload'>('home');
  const galleryRef = useRef<HTMLDivElement>(null);

  // Hook centralizado — maneja datos reales del backend
  const { mariposas, addMariposa, refreshMariposas } = useMariposas();

  const handleNavigate = (page: 'home' | 'upload') => {
    setCurrentPage(page);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleScrollToGallery = () => {
    if (galleryRef.current) {
      galleryRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  };

  const handleAddMariposa = async (data: Parameters<typeof addMariposa>[0]) => {
    try {
      await addMariposa(data);
      toast.success('Mariposa subida exitosamente', {
        description: `${data.nombreComun} ha sido guardada en la colección.`,
      });
      // Refrescar la galería con los datos del servidor
      await refreshMariposas();
      handleNavigate('home');
    } catch (err) {
      toast.error('Error al subir mariposa', {
        description: err instanceof Error ? err.message : 'Ocurrió un error inesperado.',
      });
      throw err; // Re-throw para que el spinner del formulario se detenga
    }
  };

  return (
    <div className="min-h-screen bg-[#05140A]">
      <Navbar onNavigate={handleNavigate} currentPage={currentPage} />

      {currentPage === 'home' ? (
        <main>
          <HeroSection onScrollToGallery={handleScrollToGallery} />
          <div ref={galleryRef}>
            <GallerySection userMariposas={mariposas.filter(m => m.usuarioSubido)} />
          </div>
          <FooterSection />
        </main>
      ) : (
        <main>
          <UploadSection onNavigateToHome={() => handleNavigate('home')} onSubmit={handleAddMariposa} />
          <FooterSection />
        </main>
      )}

      <Toaster
        position="bottom-right"
        toastOptions={{
          style: {
            background: '#0D2818',
            color: '#F5F5DC',
            border: '1px solid #1a4a2e',
          },
        }}
      />
    </div>
  );
}

function App() {
  return (
    <AuthProvider>
      <AppContent />
    </AuthProvider>
  );
}

export default App;
