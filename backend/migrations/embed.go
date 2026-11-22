// Package migrations embeds the SQL migration files so the API binary can
// apply them on startup without shipping the directory separately.
package migrations

import "embed"

//go:embed *.sql
var FS embed.FS
