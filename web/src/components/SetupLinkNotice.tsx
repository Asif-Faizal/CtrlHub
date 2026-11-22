import { useState } from "react";

// Shows a one-time password setup link that the admin shares with the user
// out of band. The link is not stored anywhere in the UI after dismissal.
export function SetupLinkNotice({ url, onDismiss }: { url: string; onDismiss?: () => void }) {
  const [copied, setCopied] = useState(false);
  const copy = async () => {
    await navigator.clipboard.writeText(url);
    setCopied(true);
  };
  return (
    <div className="space-y-2 rounded-md bg-amber-50 p-4 text-sm ring-1 ring-amber-200">
      <p className="font-medium text-amber-800">One-time password setup link</p>
      <p className="text-amber-700">Share this link securely with the user. It works once and expires; it will not be shown again.</p>
      <div className="flex gap-2">
        <input readOnly value={url} className="min-w-0 flex-1 rounded border border-amber-300 bg-white px-2 py-1 font-mono text-xs" onFocus={(e) => e.target.select()} />
        <button onClick={copy} className="rounded bg-amber-600 px-2 py-1 text-xs font-medium text-white">
          {copied ? "Copied" : "Copy"}
        </button>
        {onDismiss && (
          <button onClick={onDismiss} className="rounded px-2 py-1 text-xs text-amber-800 ring-1 ring-amber-300">
            Done
          </button>
        )}
      </div>
    </div>
  );
}
