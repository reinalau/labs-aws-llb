import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { useAuth } from '@/context/AuthContext';
import { LoginModal } from './LoginModal';
import { User, LogOut, Plus, Menu, X } from 'lucide-react';
import { ButterflyIcon } from '@/components/ButterflyIcon';

interface NavbarProps {
  onNavigate: (page: 'home' | 'upload') => void;
  currentPage: string;
}

export function Navbar({ onNavigate, currentPage }: NavbarProps) {
  const { isAuthenticated, user, logout } = useAuth();
  const [isLoginOpen, setIsLoginOpen] = useState(false);
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  const handleLogout = () => {
    logout();
    onNavigate('home');
  };

  return (
    <>
      <nav className="fixed top-0 left-0 right-0 z-50 bg-[#05140A]/90 backdrop-blur-md border-b border-[#1a4a2e]">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            {/* Logo */}
            <div 
              className="flex items-center gap-2 cursor-pointer"
              onClick={() => onNavigate('home')}
            >
              <ButterflyIcon className="w-8 h-8 text-[#C9A227]" />
              <div className="flex items-center gap-2">
                <span className="text-xl font-bold text-[#F5F5DC]">
                  Mariposas <span className="text-[#C9A227]">Bonaerenses</span>
                </span>
                <div className="flex flex-col w-6 h-4 rounded-sm overflow-hidden opacity-90" title="Argentina">
                  <div className="flex-1 bg-[#74ACDF]" />
                  <div className="flex-1 bg-white flex items-center justify-center">
                    <div className="w-[4px] h-[4px] rounded-full bg-[#F6B40E]" />
                  </div>
                  <div className="flex-1 bg-[#74ACDF]" />
                </div>
              </div>
            </div>

            {/* Desktop Navigation */}
            <div className="hidden md:flex items-center gap-4">
              <Button
                variant="ghost"
                onClick={() => onNavigate('home')}
                className={`text-[#F5F5DC] hover:text-[#C9A227] hover:bg-[#1a4a2e]/50 ${
                  currentPage === 'home' ? 'text-[#C9A227]' : ''
                }`}
              >
                Inicio
              </Button>

              {isAuthenticated && (
                <Button
                  variant="ghost"
                  onClick={() => onNavigate('upload')}
                  className={`text-[#F5F5DC] hover:text-[#C9A227] hover:bg-[#1a4a2e]/50 ${
                    currentPage === 'upload' ? 'text-[#C9A227]' : ''
                  }`}
                >
                  <Plus className="w-4 h-4 mr-1" />
                  Subir
                </Button>
              )}

              {isAuthenticated ? (
                <div className="flex items-center gap-3">
                  <span className="text-sm text-[#8FBC8F]">
                    Hola, {user?.nombre}
                  </span>
                  <Button
                    variant="outline"
                    onClick={handleLogout}
                    className="border-[#C9A227] text-[#C9A227] hover:bg-[#C9A227] hover:text-[#05140A]"
                  >
                    <LogOut className="w-4 h-4 mr-1" />
                    Salir
                  </Button>
                </div>
              ) : (
                <Button
                  onClick={() => setIsLoginOpen(true)}
                  className="bg-[#C9A227] hover:bg-[#b8921f] text-[#05140A] font-bold"
                >
                  <User className="w-4 h-4 mr-1" />
                  Ingresar
                </Button>
              )}
            </div>

            {/* Mobile Menu Button */}
            <button
              className="md:hidden p-2 text-[#F5F5DC]"
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)}
            >
              {isMobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>

          {/* Mobile Menu */}
          {isMobileMenuOpen && (
            <div className="md:hidden py-4 border-t border-[#1a4a2e]">
              <div className="flex flex-col gap-2">
                <Button
                  variant="ghost"
                  onClick={() => {
                    onNavigate('home');
                    setIsMobileMenuOpen(false);
                  }}
                  className="justify-start text-[#F5F5DC] hover:text-[#C9A227]"
                >
                  Inicio
                </Button>

                {isAuthenticated && (
                  <Button
                    variant="ghost"
                    onClick={() => {
                      onNavigate('upload');
                      setIsMobileMenuOpen(false);
                    }}
                    className="justify-start text-[#F5F5DC] hover:text-[#C9A227]"
                  >
                    <Plus className="w-4 h-4 mr-1" />
                    Subir Mariposa
                  </Button>
                )}

                {isAuthenticated ? (
                  <>
                    <div className="px-4 py-2 text-sm text-[#8FBC8F]">
                      {user?.email}
                    </div>
                    <Button
                      variant="outline"
                      onClick={handleLogout}
                      className="border-[#C9A227] text-[#C9A227]"
                    >
                      <LogOut className="w-4 h-4 mr-1" />
                      Cerrar Sesión
                    </Button>
                  </>
                ) : (
                  <Button
                    onClick={() => {
                      setIsLoginOpen(true);
                      setIsMobileMenuOpen(false);
                    }}
                    className="bg-[#C9A227] text-[#05140A] font-bold"
                  >
                    <User className="w-4 h-4 mr-1" />
                    Iniciar Sesión
                  </Button>
                )}
              </div>
            </div>
          )}
        </div>
      </nav>

      <LoginModal isOpen={isLoginOpen} onClose={() => setIsLoginOpen(false)} />
    </>
  );
}
