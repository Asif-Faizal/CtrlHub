import { useQuery, useQueryClient, type UseQueryOptions } from "@tanstack/react-query";
import { api } from "./client";

export async function getJSON<T>(url: string, params?: Record<string, unknown>): Promise<T> {
  const { data } = await api.get<T>(url, { params });
  return data;
}

// useGet keys queries by URL and params, so invalidating a URL prefix (for
// example "/gym/members") refreshes every page and filter of that list.
export function useGet<T>(url: string, params?: Record<string, unknown>, options?: Partial<UseQueryOptions<T>>) {
  return useQuery<T>({
    queryKey: [url, params ?? {}],
    queryFn: () => getJSON<T>(url, params),
    ...options,
  });
}

export function useInvalidate() {
  const qc = useQueryClient();
  return (...prefixes: string[]) =>
    Promise.all(
      prefixes.map((p) =>
        qc.invalidateQueries({ predicate: (q) => typeof q.queryKey[0] === "string" && (q.queryKey[0] as string).startsWith(p) }),
      ),
    );
}
