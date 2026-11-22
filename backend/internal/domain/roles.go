package domain

import "slices"

type Role string

const (
	RolePlatformAdmin Role = "PLATFORM_ADMIN"
	RoleGymAdmin      Role = "GYM_ADMIN"
	RoleGymManager    Role = "GYM_MANAGER"
	RoleReceptionist  Role = "RECEPTIONIST"
	RoleTrainer       Role = "TRAINER"
)

// Role IDs match the seed rows in the roles table.
var roleIDs = map[Role]int{
	RolePlatformAdmin: 1,
	RoleGymAdmin:      2,
	RoleGymManager:    3,
	RoleReceptionist:  4,
	RoleTrainer:       5,
}

func (r Role) ID() int { return roleIDs[r] }

func (r Role) IsGymRole() bool {
	switch r {
	case RoleGymAdmin, RoleGymManager, RoleReceptionist, RoleTrainer:
		return true
	}
	return false
}

func ParseGymRole(s string) (Role, bool) {
	r := Role(s)
	return r, r.IsGymRole()
}

type Permission string

const (
	PermTenantRead       Permission = "tenant.read"
	PermTenantUpdate     Permission = "tenant.update"
	PermUsersManage      Permission = "users.manage"
	PermMembersRead      Permission = "members.read"
	PermMembersWrite     Permission = "members.write"
	PermPlansRead        Permission = "plans.read"
	PermPlansWrite       Permission = "plans.write"
	PermMembershipsRead  Permission = "memberships.read"
	PermMembershipsWrite Permission = "memberships.write"
	PermPaymentsRead     Permission = "payments.read"
	PermPaymentsWrite    Permission = "payments.write"
	PermAttendanceRead   Permission = "attendance.read"
	PermAttendanceWrite  Permission = "attendance.write"
	PermHolidaysRead     Permission = "holidays.read"
	PermHolidaysWrite    Permission = "holidays.write"
	PermLeadsRead        Permission = "leads.read"
	PermLeadsWrite       Permission = "leads.write"
	PermCampaignsRead    Permission = "campaigns.read"
	PermCampaignsWrite   Permission = "campaigns.write"
	PermCampaignsApprove Permission = "campaigns.approve"
	PermWhatsAppRead     Permission = "whatsapp.read"
	PermWhatsAppManage   Permission = "whatsapp.manage"
	PermAutomationManage Permission = "automation.manage"
	PermMessagesRead     Permission = "messages.read"
	PermReportsRead      Permission = "reports.read"
	PermPlatformManage   Permission = "platform.manage"
)

var allGymPermissions = []Permission{
	PermTenantRead, PermTenantUpdate, PermUsersManage,
	PermMembersRead, PermMembersWrite, PermPlansRead, PermPlansWrite,
	PermMembershipsRead, PermMembershipsWrite, PermPaymentsRead, PermPaymentsWrite,
	PermAttendanceRead, PermAttendanceWrite, PermHolidaysRead, PermHolidaysWrite,
	PermLeadsRead, PermLeadsWrite, PermCampaignsRead, PermCampaignsWrite, PermCampaignsApprove,
	PermWhatsAppRead, PermWhatsAppManage, PermAutomationManage, PermMessagesRead, PermReportsRead,
}

var rolePermissions = map[Role][]Permission{
	RolePlatformAdmin: {PermPlatformManage},
	RoleGymAdmin:      allGymPermissions,
	RoleGymManager: without(allGymPermissions,
		PermUsersManage, PermTenantUpdate, PermWhatsAppManage),
	RoleReceptionist: {
		PermTenantRead, PermMembersRead, PermMembersWrite, PermPlansRead,
		PermMembershipsRead, PermMembershipsWrite, PermPaymentsRead, PermPaymentsWrite,
		PermAttendanceRead, PermAttendanceWrite, PermHolidaysRead, PermLeadsRead, PermLeadsWrite,
	},
	RoleTrainer: {
		PermTenantRead, PermMembersRead, PermAttendanceRead, PermAttendanceWrite, PermHolidaysRead,
	},
}

func without(perms []Permission, remove ...Permission) []Permission {
	out := make([]Permission, 0, len(perms))
	for _, p := range perms {
		if !slices.Contains(remove, p) {
			out = append(out, p)
		}
	}
	return out
}

func (r Role) Permissions() []Permission { return slices.Clone(rolePermissions[r]) }

func (r Role) Can(p Permission) bool { return slices.Contains(rolePermissions[r], p) }
