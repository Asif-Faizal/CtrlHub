import type { ReactNode } from "react";
import { errorMessage } from "../../api/client";

interface PageStateProps {
  state: "loading" | "empty" | "error";
  message?: string;
  action?: ReactNode;
}

export function PageState({ state, message, action }: PageStateProps) {
  if (state === "loading") {
    return (
      <div role="status" className="flex items-center justify-center gap-2 py-16 text-sm text-slate-500">
        <span className="h-4 w-4 animate-spin rounded-full border-2 border-slate-400 border-t-transparent" />
        {message ?? "Loading…"}
      </div>
    );
  }
  const tone = state === "error" ? "text-rose-700 bg-rose-50 ring-rose-200" : "text-slate-500 bg-white ring-slate-200";
  return (
    <div role={state === "error" ? "alert" : undefined} className={`flex flex-col items-center gap-3 rounded-lg px-6 py-12 text-center text-sm ring-1 ${tone}`}>
      <p>{message ?? (state === "empty" ? "Nothing here yet." : "Something went wrong.")}</p>
      {action}
    </div>
  );
}

interface QueryStateProps<T> {
  query: { isPending: boolean; isError: boolean; error: unknown; data: T | undefined; refetch: () => unknown };
  isEmpty?: (data: T) => boolean;
  emptyMessage?: string;
  emptyAction?: ReactNode;
  children: (data: T) => ReactNode;
}

// QueryState renders the loading, error and empty states of a TanStack query
// consistently and calls children only with loaded data.
export function QueryState<T>({ query, isEmpty, emptyMessage, emptyAction, children }: QueryStateProps<T>) {
  if (query.isPending) return <PageState state="loading" />;
  if (query.isError || query.data === undefined) {
    return (
      <PageState
        state="error"
        message={errorMessage(query.error)}
        action={
          <button className="text-sm font-medium underline" onClick={() => query.refetch()}>
            Try again
          </button>
        }
      />
    );
  }
  if (isEmpty?.(query.data)) return <PageState state="empty" message={emptyMessage} action={emptyAction} />;
  return <>{children(query.data)}</>;
}
