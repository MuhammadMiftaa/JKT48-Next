// src/lib/env.ts
// Helper untuk mengakses environment variables yang di-inject at runtime

interface RuntimeEnv {
  NEXT_PUBLIC_API_URL?: string;
  NEXT_PUBLIC_ENVIRONMENT?: string;
  FIREBASE_API_KEY?: string;
  FIREBASE_AUTH_DOMAIN?: string;
  FIREBASE_PROJECT_ID?: string;
  FIREBASE_STORAGE_BUCKET?: string;
  FIREBASE_MESSAGING_SENDER_ID?: string;
  FIREBASE_APP_ID?: string;
}

declare global {
  interface Window {
    __ENV__?: RuntimeEnv;
  }
}

/**
 * Get environment variable from runtime config or fallback to build-time
 * Priority: window.__ENV__ > process.env
 */
export function getEnv(key: keyof RuntimeEnv): string | undefined {
  // Client-side: check runtime config first
  if (typeof window !== "undefined" && window.__ENV__) {
    return window.__ENV__[key];
  }

  // Fallback to build-time env (for development)
  return process.env[key];
}

/**
 * Get API URL with fallback
 */
export function getApiUrl(): string {
  return getEnv("NEXT_PUBLIC_API_URL") || "http://localhost:3000/api";
}

/**
 * Get environment name
 */
export function getEnvironment(): string {
  return getEnv("NEXT_PUBLIC_ENVIRONMENT") || "development";
}

/**
 * Check if production
 */
export function isProduction(): boolean {
  return getEnvironment() === "production";
}

/**
 * Firebase configuration from runtime env
 */
export function getFirebaseConfig() {
  return {
    apiKey: getEnv("FIREBASE_API_KEY") || process.env.FIREBASE_API_KEY,
    authDomain:
      getEnv("FIREBASE_AUTH_DOMAIN") || process.env.FIREBASE_AUTH_DOMAIN,
    projectId: getEnv("FIREBASE_PROJECT_ID") || process.env.FIREBASE_PROJECT_ID,
    storageBucket:
      getEnv("FIREBASE_STORAGE_BUCKET") || process.env.FIREBASE_STORAGE_BUCKET,
    messagingSenderId:
      getEnv("FIREBASE_MESSAGING_SENDER_ID") ||
      process.env.FIREBASE_MESSAGING_SENDER_ID,
    appId: getEnv("FIREBASE_APP_ID") || process.env.FIREBASE_APP_ID,
  };
}

/**
 * Export all env variables for debugging (only in development)
 */
export function logEnvVariables() {
  if (!isProduction()) {
    console.log("🔧 Environment Variables:", {
      API_URL: getApiUrl(),
      ENVIRONMENT: getEnvironment(),
      FIREBASE_PROJECT_ID: getEnv("FIREBASE_PROJECT_ID"),
    });
  }
}

export default {
  getEnv,
  getApiUrl,
  getEnvironment,
  isProduction,
  getFirebaseConfig,
  logEnvVariables,
};
