import { create } from 'zustand';
import { namespaceApi, type Namespace } from '@/api';

interface NamespaceState {
  currentNamespace: string;
  namespaceShowName: string;
  namespaces: Namespace[];
  loading: boolean;
  error: string | null;
  namespaceChangeGuard: (() => boolean) | null;
}

interface NamespaceActions {
  setNamespace: (id: string, showName: string) => void;
  fetchNamespaces: () => Promise<void>;
  getCurrentNamespace: () => string;
  setNamespaceChangeGuard: (guard: (() => boolean) | null) => void;
  getNamespaceChangeGuard: () => (() => boolean) | null;
}

type NamespaceStore = NamespaceState & NamespaceActions;

export const getDefaultNamespaceFromHash = (hash: string): string => {
  // Try namespaceId first (used by AI detail pages)
  const namespaceIdMatch = hash.match(/[?&]namespaceId=([^&]*)/);
  if (namespaceIdMatch) {
    return decodeURIComponent(namespaceIdMatch[1]);
  }
  // Fall back to legacy namespace param
  const namespaceMatch = hash.match(/[?&]namespace=([^&]*)/);
  if (namespaceMatch) {
    return decodeURIComponent(namespaceMatch[1]);
  }
  return '';
};

export const getNamespaceSearchAfterSwitch = (
  search: string,
  namespaceId: string,
  namespaceShowName: string,
): string | null => {
  const params = new URLSearchParams(search);

  // If route uses namespaceId param (AI detail pages)
  if (params.has('namespaceId')) {
    params.set('namespaceId', namespaceId);
    return params.toString();
  }

  // If route uses legacy namespace param
  if (params.has('namespace')) {
    params.set('namespace', namespaceId);
    params.set('namespaceShowName', namespaceShowName);
    return params.toString();
  }

  // Route doesn't use namespace params
  return null;
};

const getDefaultNamespace = (): string => {
  return getDefaultNamespaceFromHash(window.location.hash);
};

export const useNamespaceStore = create<NamespaceStore>((set, get) => ({
  // State
  currentNamespace: getDefaultNamespace(),
  namespaceShowName: '',
  namespaces: [],
  loading: false,
  error: null,
  namespaceChangeGuard: null,

  // Actions
  setNamespace: (id: string, showName: string) => {
    set({
      currentNamespace: id,
      namespaceShowName: showName,
    });
  },

  fetchNamespaces: async () => {
    set({ loading: true, error: null });
    try {
      const response = await namespaceApi.list();
      // Response interceptor already unwraps response.data (returns HTTP body)
      // Body structure: { code: 0, data: [...namespaces] }
      const body = response as unknown as { code: number; data: Namespace[] };
      const namespaces = body.data || [];
      
      // If no current namespace set, use the first one or empty
      const currentNamespace = get().currentNamespace;
      if (!currentNamespace && namespaces.length > 0) {
        const defaultNs = namespaces.find(ns => ns.namespace === 'public') || namespaces[0];
        set({
          namespaces,
          currentNamespace: defaultNs.namespace,
          namespaceShowName: defaultNs.namespaceShowName,
          loading: false,
        });
      } else {
        set({
          namespaces,
          loading: false,
        });
      }
    } catch (error) {
      const message = error instanceof Error ? error.message : 'Failed to fetch namespaces';
      set({ loading: false, error: message });
    }
  },

  getCurrentNamespace: () => {
    return get().currentNamespace;
  },

  setNamespaceChangeGuard: (guard: (() => boolean) | null) => {
    set({ namespaceChangeGuard: guard });
  },

  getNamespaceChangeGuard: () => {
    return get().namespaceChangeGuard;
  },
}));
