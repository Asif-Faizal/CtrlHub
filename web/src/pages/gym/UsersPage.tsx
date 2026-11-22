import { Card, PageHeader } from "../../components/ui";
import { UserManager } from "../../components/UserManager";

export function UsersPage() {
  return (
    <>
      <PageHeader title="User management" subtitle="Staff accounts for this gym. All users share the same gym data, limited by their role." />
      <Card>
        <UserManager baseUrl="/gym/users" resetUrl={(id) => `/gym/users/${id}/reset-password`} />
      </Card>
    </>
  );
}
