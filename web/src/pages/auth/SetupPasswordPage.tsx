import { useState, type FormEvent } from "react";
import { Link, useSearchParams } from "react-router";
import { api, errorMessage } from "../../api/client";
import { Button, FormError, Input } from "../../components/ui";
import { AuthCard } from "./LoginPage";

export function SetupPasswordPage() {
  const [params] = useSearchParams();
  const token = params.get("token") ?? "";
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [busy, setBusy] = useState(false);
  const [done, setDone] = useState(false);

  const onSubmit = async (e: FormEvent) => {
    e.preventDefault();
    if (password !== confirm) {
      setError("Passwords do not match");
      return;
    }
    setError(null);
    setBusy(true);
    try {
      await api.post("/auth/setup-password", { token, password });
      setDone(true);
    } catch (err) {
      setError(errorMessage(err));
    } finally {
      setBusy(false);
    }
  };

  if (!token) {
    return (
      <AuthCard title="Invalid link">
        <p className="text-sm text-slate-600">This password setup link is missing its token. Ask your administrator for a new link.</p>
      </AuthCard>
    );
  }

  if (done) {
    return (
      <AuthCard title="Password set">
        <p className="mb-4 text-sm text-slate-600">Your password has been saved. You can now sign in.</p>
        <Link to="/login" className="text-sm font-medium text-indigo-600">
          Go to sign in →
        </Link>
      </AuthCard>
    );
  }

  return (
    <AuthCard title="Set your password" subtitle="This link works once and expires after a limited time.">
      <form onSubmit={onSubmit} className="space-y-4">
        <FormError message={error} />
        <Input label="New password" type="password" autoComplete="new-password" minLength={8} required value={password} onChange={(e) => setPassword(e.target.value)} hint="At least 8 characters." />
        <Input label="Confirm password" type="password" autoComplete="new-password" required value={confirm} onChange={(e) => setConfirm(e.target.value)} />
        <Button type="submit" loading={busy} className="w-full">
          Save password
        </Button>
      </form>
    </AuthCard>
  );
}
