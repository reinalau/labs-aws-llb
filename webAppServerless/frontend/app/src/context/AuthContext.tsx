import React, { createContext, useContext, useState, useCallback, useEffect } from 'react';
import {
  CognitoUserPool,
  CognitoUser,
  AuthenticationDetails,
  CognitoUserSession,
} from 'amazon-cognito-identity-js';
import { awsConfig } from '@/aws-config';

// ── Pool de Cognito ──────────────────────────────────────────
const userPool = new CognitoUserPool({
  UserPoolId: awsConfig.cognito.userPoolId,
  ClientId:   awsConfig.cognito.clientId,
});

// ── Tipos ────────────────────────────────────────────────────
interface User {
  id: string;
  nombre: string;
  email: string;
  idToken: string;   // JWT que se envía en Authorization header
}

interface AuthContextType {
  user: User | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<void>;
  logout: () => void;
  isLoading: boolean;
  error: string | null;
  getIdToken: () => string | null;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

// ── Helper: extraer usuario de la sesión ─────────────────────
function buildUser(session: CognitoUserSession, email: string): User {
  const payload = session.getIdToken().decodePayload();
  return {
    id:      payload['sub'] as string,
    nombre:  (payload['custom:nombre'] as string) || email.split('@')[0],
    email,
    idToken: session.getIdToken().getJwtToken(),
  };
}

// ── Provider ─────────────────────────────────────────────────
export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Restaurar sesión al cargar la página (token guardado por el SDK en localStorage)
  useEffect(() => {
    const cognitoUser = userPool.getCurrentUser();
    if (!cognitoUser) { setIsLoading(false); return; }
    cognitoUser.getSession((err: Error | null, session: CognitoUserSession | null) => {
      if (err || !session?.isValid()) { setIsLoading(false); return; }
      const email = session.getIdToken().decodePayload()['email'] as string;
      setUser(buildUser(session, email));
      setIsLoading(false);
    });
  }, []);

  // Login real contra AWS Cognito
  const login = useCallback(async (email: string, password: string) => {
    setIsLoading(true);
    setError(null);

    return new Promise<void>((resolve, reject) => {
      const cognitoUser = new CognitoUser({ Username: email, Pool: userPool });
      const authDetails  = new AuthenticationDetails({ Username: email, Password: password });

      cognitoUser.authenticateUser(authDetails, {
        onSuccess: (session: CognitoUserSession) => {
          setUser(buildUser(session, email));
          setIsLoading(false);
          resolve();
        },
        onFailure: (err: { message: string }) => {
          const msg = err.message === 'Incorrect username or password.'
            ? 'Email o contraseña incorrectos.'
            : err.message;
          setError(msg);
          setIsLoading(false);
          reject(new Error(msg));
        },
        newPasswordRequired: () => {
          const msg = 'Debes cambiar tu contraseña temporal desde la consola de AWS Cognito.';
          setError(msg);
          setIsLoading(false);
          reject(new Error(msg));
        },
      });
    });
  }, []);

  const logout = useCallback(() => {
    userPool.getCurrentUser()?.signOut();
    setUser(null);
    setError(null);
  }, []);

  const getIdToken = useCallback(() => user?.idToken ?? null, [user]);

  return (
    <AuthContext.Provider value={{ user, isAuthenticated: !!user, login, logout, isLoading, error, getIdToken }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth debe usarse dentro de un AuthProvider');
  return ctx;
}
