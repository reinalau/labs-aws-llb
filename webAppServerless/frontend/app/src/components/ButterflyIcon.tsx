import React from 'react';

export const ButterflyIcon = (props: React.SVGProps<SVGSVGElement> & { size?: number | string }) => {
  const { size = 24, ...rest } = props;
  return (
    <svg 
      xmlns="http://www.w3.org/2000/svg" 
      width={size} 
      height={size} 
      viewBox="0 0 680 520" 
      fill="currentColor" 
      {...rest}
    >
      {/* ALAS IZQUIERDAS */}
      <g>
        {/* Ala superior izquierda */}
        <path d="M 335 252 C 315 195, 235 140, 150 118 C 85  100, 42  128, 55  178 C 68  225, 138 250, 205 258 C 260 264, 310 260, 335 256 Z" />
        {/* Ala inferior izquierda */}
        <path d="M 330 270 C 295 300, 210 338, 138 362 C 78  382, 42  364, 48  328 C 55  292, 112 272, 178 270 C 238 268, 300 269, 330 270 Z" />
      </g>

      {/* ALAS DERECHAS (espejo) */}
      <g transform="translate(680,0) scale(-1,1)">
        {/* Ala superior derecha */}
        <path d="M 335 252 C 315 195, 235 140, 150 118 C 85  100, 42  128, 55  178 C 68  225, 138 250, 205 258 C 260 264, 310 260, 335 256 Z" />
        {/* Ala inferior derecha */}
        <path d="M 330 270 C 295 300, 210 338, 138 362 C 78  382, 42  364, 48  328 C 55  292, 112 272, 178 270 C 238 268, 300 269, 330 270 Z" />
      </g>

      {/* CUERPO CENTRAL */}
      <ellipse cx="340" cy="262" rx="10" ry="88" />
      
      {/* Cabeza */}
      <circle cx="340" cy="172" r="14" />

      {/* Antenas */}
      <path d="M 337 162 C 318 138, 302 112, 296 92" fill="none" stroke="currentColor" strokeWidth="8" strokeLinecap="round" />
      <circle cx="296" cy="92" r="5.5" />

      <path d="M 343 162 C 362 138, 378 112, 384 92" fill="none" stroke="currentColor" strokeWidth="8" strokeLinecap="round" />
      <circle cx="384" cy="92" r="5.5" />
    </svg>
  );
};
