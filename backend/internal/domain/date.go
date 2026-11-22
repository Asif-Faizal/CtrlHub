package domain

import (
	"database/sql/driver"
	"fmt"
	"strings"
	"time"
)

const DateLayout = "2006-01-02"

// Date is a calendar date without time-of-day, serialized as "YYYY-MM-DD".
type Date struct{ time.Time }

func NewDate(y int, m time.Month, d int) Date { return Date{time.Date(y, m, d, 0, 0, 0, 0, time.UTC)} }

func ParseDate(s string) (Date, error) {
	t, err := time.Parse(DateLayout, s)
	if err != nil {
		return Date{}, fmt.Errorf("invalid date %q, expected YYYY-MM-DD", s)
	}
	return Date{t}, nil
}

// Today returns the current calendar date in the given IANA timezone.
func Today(now time.Time, tz string) Date {
	loc, err := time.LoadLocation(tz)
	if err != nil {
		loc = time.UTC
	}
	l := now.In(loc)
	return NewDate(l.Year(), l.Month(), l.Day())
}

func (d Date) String() string               { return d.Format(DateLayout) }
func (d Date) AddDays(n int) Date           { return Date{d.AddDate(0, 0, n)} }
func (d Date) Before(o Date) bool           { return d.Time.Before(o.Time) }
func (d Date) After(o Date) bool            { return d.Time.After(o.Time) }
func (d Date) Equal(o Date) bool            { return d.Time.Equal(o.Time) }
func (d Date) DaysUntil(o Date) int         { return int(o.Sub(d.Time).Hours() / 24) }
func (d Date) MarshalJSON() ([]byte, error) { return []byte(`"` + d.String() + `"`), nil }

func (d *Date) UnmarshalJSON(b []byte) error {
	s := strings.Trim(string(b), `"`)
	if s == "" || s == "null" {
		*d = Date{}
		return nil
	}
	p, err := ParseDate(s)
	if err != nil {
		return err
	}
	*d = p
	return nil
}

func (d Date) Value() (driver.Value, error) { return d.String(), nil }

func (d *Date) Scan(v any) error {
	switch t := v.(type) {
	case time.Time:
		*d = NewDate(t.Year(), t.Month(), t.Day())
	case []byte:
		p, err := ParseDate(string(t)[:10])
		if err != nil {
			return err
		}
		*d = p
	case string:
		p, err := ParseDate(t[:10])
		if err != nil {
			return err
		}
		*d = p
	default:
		return fmt.Errorf("cannot scan %T into Date", v)
	}
	return nil
}

// NullDate is an optional Date.
type NullDate struct {
	Date  Date
	Valid bool
}

func (n NullDate) MarshalJSON() ([]byte, error) {
	if !n.Valid {
		return []byte("null"), nil
	}
	return n.Date.MarshalJSON()
}

func (n *NullDate) UnmarshalJSON(b []byte) error {
	s := strings.Trim(string(b), `"`)
	if s == "" || s == "null" {
		*n = NullDate{}
		return nil
	}
	if err := n.Date.UnmarshalJSON(b); err != nil {
		return err
	}
	n.Valid = true
	return nil
}

func (n NullDate) Value() (driver.Value, error) {
	if !n.Valid {
		return nil, nil
	}
	return n.Date.String(), nil
}

func (n *NullDate) Scan(v any) error {
	if v == nil {
		*n = NullDate{}
		return nil
	}
	n.Valid = true
	return n.Date.Scan(v)
}
