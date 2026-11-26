package orders

import (
	"go/parser"
	"go/token"
	"io/fs"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"testing"
)

// The orders module may only touch its own tables and its own packages
// (docs/adr-001-orders-module.md). These tests fail the build when someone
// breaks that rule, so the boundary is enforced, not just documented.

// Tables owned by other modules. Orders SQL must never mention them.
var forbiddenTables = []string{
	"users",
	"refresh_tokens",
	"addresses",
	"products",
	"product_images",
	"product_variants",
	"seller_profiles",
	"categories",
	"brands",
}

// Import paths the orders module must not depend on, except in adapters/.
var forbiddenImports = []string{
	"primestore_demo_backend/api",
	"primestore_demo_backend/db/sqlc",
	"primestore_demo_backend/util",
}

var sqlComment = regexp.MustCompile(`--[^\n]*`)

func TestOrdersSQLOnlyTouchesOrdersTables(t *testing.T) {
	dir := filepath.Join("store", "queries")

	var scanned int
	err := filepath.WalkDir(dir, func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() || !strings.HasSuffix(path, ".sql") {
			return nil
		}

		raw, err := os.ReadFile(path)
		if err != nil {
			return err
		}
		sql := sqlComment.ReplaceAllString(string(raw), "")

		for _, table := range forbiddenTables {
			if regexp.MustCompile(`(?i)\b` + regexp.QuoteMeta(table) + `\b`).MatchString(sql) {
				t.Errorf("%s mentions table %q, which belongs to another module. "+
					"Get that data through a port in ports.go instead", path, table)
			}
		}
		scanned++
		return nil
	})
	if err != nil {
		t.Fatalf("walking %s: %v", dir, err)
	}
	if scanned == 0 {
		t.Fatalf("no .sql files found in %s: the test would pass without checking anything", dir)
	}
}

func TestOrdersDoesNotImportOtherModules(t *testing.T) {
	fset := token.NewFileSet()

	var scanned int
	err := filepath.WalkDir(".", func(path string, d fs.DirEntry, err error) error {
		if err != nil {
			return err
		}
		if d.IsDir() {
			if d.Name() == "adapters" {
				return filepath.SkipDir // adapters are the allowed bridge
			}
			return nil
		}
		if !strings.HasSuffix(path, ".go") {
			return nil
		}

		file, err := parser.ParseFile(fset, path, nil, parser.ImportsOnly)
		if err != nil {
			return err
		}
		scanned++

		for _, imp := range file.Imports {
			importPath, err := strconv.Unquote(imp.Path.Value)
			if err != nil {
				return err
			}
			for _, forbidden := range forbiddenImports {
				if importPath == forbidden || strings.HasPrefix(importPath, forbidden+"/") {
					t.Errorf("%s imports %q: only internal/orders/adapters may depend on the rest of the app",
						path, importPath)
				}
			}
		}
		return nil
	})
	if err != nil {
		t.Fatalf("walking the orders module: %v", err)
	}
	if scanned == 0 {
		t.Fatal("no .go files scanned: the test would pass without checking anything")
	}
}
