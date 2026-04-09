import { motion, useMotionValue, useSpring } from 'framer-motion';
import { useEffect } from 'react';

interface JungleLeafProps {
  src: string;
  className?: string;
  size?: number;
  position: { x: string; y: string };
  rotation?: number;
  followMouse?: boolean;
  sway?: boolean;
  zIndex?: number;
}

export function JungleLeaf({
  src,
  className = '',
  size = 200,
  position,
  rotation = 0,
  followMouse = false,
  sway = false,
  zIndex = 10,
}: JungleLeafProps) {
  const mouseX = useMotionValue(0);
  const mouseY = useMotionValue(0);

  const springConfig = { damping: 30, stiffness: 100 };
  const leafX = useSpring(mouseX, springConfig);
  const leafY = useSpring(mouseY, springConfig);

  useEffect(() => {
    if (!followMouse) return;

    const handleMouseMove = (e: MouseEvent) => {
      const centerX = window.innerWidth / 2;
      const centerY = window.innerHeight / 2;
      mouseX.set((e.clientX - centerX) * 0.02);
      mouseY.set((e.clientY - centerY) * 0.02);
    };

    window.addEventListener('mousemove', handleMouseMove);
    return () => window.removeEventListener('mousemove', handleMouseMove);
  }, [followMouse, mouseX, mouseY]);

  return (
    <motion.div
      className={`absolute pointer-events-none ${className}`}
      style={{
        left: position.x,
        top: position.y,
        width: size,
        height: size,
        zIndex,
        x: followMouse ? leafX : 0,
        y: followMouse ? leafY : 0,
      }}
      initial={{ opacity: 0, scale: 0.8, rotate: rotation - 5 }}
      animate={{
        opacity: 1,
        scale: 1,
        rotate: rotation,
      }}
      transition={{
        duration: 1.2,
        ease: [0.34, 1.56, 0.64, 1],
      }}
    >
      <motion.img
        src={src}
        alt=""
        className="w-full h-full object-contain leaf-shadow"
        animate={sway ? {
          rotate: [-3, 3, -3],
        } : {}}
        transition={sway ? {
          duration: 4,
          repeat: Infinity,
          ease: "easeInOut",
        } : {}}
      />
    </motion.div>
  );
}
