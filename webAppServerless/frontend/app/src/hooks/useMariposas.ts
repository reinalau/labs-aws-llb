import { useState, useCallback, useEffect } from 'react';
import type { Mariposa } from '@/types/mariposas';
import { mariposasPrecargadas } from '@/data/mariposas';
import { awsConfig } from '@/aws-config';
import { useAuth } from '@/context/AuthContext';

export type NuevaMariposaInput = {
  nombreComun: string;
  nombreCientifico: string;
  descripcion: string;
  plantaNutricia: { nombreCientifico: string; nombreComun: string };
  ecorregion: string;
  imagen: File;
};

// ── Helper: request autenticado ──────────────────────────────
async function apiRequest<T>(
  path: string,
  token: string,
  options: RequestInit = {}
): Promise<T> {
  const res = await fetch(`${awsConfig.apiUrl}${path}`, {
    ...options,
    headers: {
      'Content-Type': 'application/json',
      Authorization: token,
      ...(options.headers || {}),
    },
  });
  if (!res.ok) {
    const body = await res.text();
    throw new Error(`API error ${res.status}: ${body}`);
  }
  return res.json() as Promise<T>;
}

// ── Hook principal ───────────────────────────────────────────
export function useMariposas() {
  const { getIdToken } = useAuth();
  const [userMariposas, setUserMariposas] = useState<Mariposa[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Cargar avistamientos del usuario desde DynamoDB via API Gateway
  const loadUserMariposas = useCallback(async () => {
    const token = getIdToken();
    if (!token) return;
    setIsLoading(true);
    setError(null);
    try {
      // El backend devuelve { mariposas: [...], count: X }
      const { mariposas: data } = await apiRequest<{ mariposas: any[] }>('/mariposas', token);
      
      const mapped = data.map((m) => ({
        id: m.id,
        nombreComun: m.nombreComun,
        nombreCientifico: m.nombreCientifico,
        descripcion: m.descripcion,
        plantaNutricia: m.plantaNutricia,
        ecorregion: m.ecorregion,
        usuarioSubido: true,
        usuarioId: m.usuarioId,
        fechaSubida: m.fechaSubida,
        // Usar imagenUrl si existe (creada por la Lambda) o construirla
        imagen: m.imagenUrl || `${awsConfig.cloudfrontUrl}/${m.imagenKey}`,
      }));
      setUserMariposas(mapped);
    } catch (err) {
      setError('Error al cargar avistamientos del servidor.');
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  }, [getIdToken]);

  // Agregar mariposa: 1) Presigned URL → PUT imagen en S3, 2) POST metadata en DynamoDB
  const addMariposa = useCallback(async (input: NuevaMariposaInput) => {
    const token = getIdToken();
    if (!token) throw new Error('Debes iniciar sesión para subir una mariposa.');
    setIsLoading(true);
    setError(null);
    try {
      // Paso 1: obtener Presigned URL de S3
      const ext = input.imagen.name.split('.').pop()?.toLowerCase() ?? 'jpg';
      const { uploadUrl, imagenKey } = await apiRequest<{ uploadUrl: string; imagenKey: string }>(
        '/mariposas/upload-url',
        token,
        {
          method: 'POST',
          body: JSON.stringify({
            fileExtension: ext,          // ← lo que espera la Lambda
            contentType: input.imagen.type,
          }),
        }
      );

      // Paso 2: subir imagen directo a S3 (sin pasar por Lambda)
      const uploadRes = await fetch(uploadUrl, {
        method: 'PUT',
        headers: { 'Content-Type': input.imagen.type },
        body: input.imagen,
      });
      if (!uploadRes.ok) throw new Error('Error al subir la imagen a S3.');

      // Paso 3: guardar metadata en DynamoDB
      const res = await apiRequest<{ mariposaId: string; fechaSubida: string }>('/mariposas', token, {
        method: 'POST',
        body: JSON.stringify({
          nombreComun: input.nombreComun,
          nombreCientifico: input.nombreCientifico,
          descripcion: input.descripcion,
          plantaNutricia: input.plantaNutricia,
          ecorregion: input.ecorregion,
          imagenKey: imagenKey,
        }),
      });

      // La Lambda solo devuelve el ID y fecha, construimos el objeto completo para la UI
      const conUrl: Mariposa = {
        id: res.mariposaId,
        nombreComun: input.nombreComun,
        nombreCientifico: input.nombreCientifico,
        descripcion: input.descripcion,
        plantaNutricia: input.plantaNutricia,
        ecorregion: input.ecorregion,
        usuarioSubido: true,
        fechaSubida: res.fechaSubida,
        imagen: `${awsConfig.cloudfrontUrl}/${imagenKey}`,
      };
      setUserMariposas((prev) => [conUrl, ...prev]);
      return conUrl;
    } catch (err) {
      const msg = err instanceof Error ? err.message : 'Error al subir la mariposa.';
      setError(msg);
      throw err;
    } finally {
      setIsLoading(false);
    }
  }, [getIdToken]);

  // Cargar automáticamente cuando el usuario está autenticado
  useEffect(() => {
    loadUserMariposas();
  }, [loadUserMariposas]);

  // Lista completa: precargadas (catálogo estático) + subidas por usuarios
  const allMariposas = [...mariposasPrecargadas, ...userMariposas];

  return {
    mariposas: allMariposas,
    userMariposas,
    isLoading,
    error,
    addMariposa,
    refreshMariposas: loadUserMariposas,
  };
}
