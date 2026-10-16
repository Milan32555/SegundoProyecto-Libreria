/// <reference types="vite/client" />

interface ImportMetaEnv {
  /** URL del servidor GraphQL (opcional). Por defecto: http://localhost:8081/graphql */
  readonly VITE_URL_GRAPHQL?: string;
}
