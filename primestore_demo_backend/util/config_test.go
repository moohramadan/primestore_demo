package util

import (
	"os"
	"path/filepath"
	"strings"
	"testing"
)

// validConfig returns a config that passes Validate.
// Each test case breaks exactly one field.
func validConfig() Config {
	return Config{
		DBDriver:          "postgres",
		DBSource:          "postgresql://user:pass@localhost:5432/db?sslmode=disable",
		HTTPServerAddress: "0.0.0.0:8080",
		TokenSecret:       strings.Repeat("a", 32),
		SMTPPort:          587,
		S3Bucket:          "my-bucket",
		AWSRegion:         "eu-west-1",
	}
}

func TestValidate(t *testing.T) {
	tests := []struct {
		name    string
		mutate  func(c *Config)
		wantErr string // substring; empty means no error expected
	}{
		{"valid config", func(c *Config) {}, ""},
		{"short token secret", func(c *Config) { c.TokenSecret = "short" }, "TOKEN_SECRET"},
		{"whitespace token secret", func(c *Config) { c.TokenSecret = strings.Repeat(" ", 40) }, "TOKEN_SECRET"},
		{"empty db source", func(c *Config) { c.DBSource = "" }, "DB_SOURCE"},
		{"empty db driver", func(c *Config) { c.DBDriver = "" }, "DB_DRIVER"},
		{"blank server address", func(c *Config) { c.HTTPServerAddress = "  " }, "SERVER_ADDRESS"},
		{"empty bucket", func(c *Config) { c.S3Bucket = "" }, "S3_BUCKET"},
		{"empty region", func(c *Config) { c.AWSRegion = "" }, "AWS_REGION"},
		{"smtp port zero", func(c *Config) { c.SMTPPort = 0 }, "SMTP_PORT"},
		{"smtp port too big", func(c *Config) { c.SMTPPort = 70000 }, "SMTP_PORT"},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			c := validConfig()
			tc.mutate(&c)

			err := c.Validate()
			if tc.wantErr == "" {
				if err != nil {
					t.Fatalf("expected no error, got: %v", err)
				}
				return
			}
			if err == nil {
				t.Fatalf("expected error containing %q, got nil", tc.wantErr)
			}
			if !strings.Contains(err.Error(), tc.wantErr) {
				t.Fatalf("expected error containing %q, got: %v", tc.wantErr, err)
			}
		})
	}
}

func TestValidateReportsAllProblems(t *testing.T) {
	c := validConfig()
	c.TokenSecret = "short"
	c.S3Bucket = ""
	c.SMTPPort = 0

	err := c.Validate()
	if err == nil {
		t.Fatal("expected an error")
	}
	for _, want := range []string{"TOKEN_SECRET", "S3_BUCKET", "SMTP_PORT"} {
		if !strings.Contains(err.Error(), want) {
			t.Errorf("error should mention %s, got: %v", want, err)
		}
	}
}

func TestValidateDoesNotLeakSecrets(t *testing.T) {
	c := validConfig()
	c.TokenSecret = "supersecret" // too short, so Validate fails

	err := c.Validate()
	if err == nil {
		t.Fatal("expected an error")
	}
	if strings.Contains(err.Error(), "supersecret") {
		t.Fatal("error message leaks the token secret")
	}
}

// clearEnv blanks every key so variables exported in your own shell
// can't leak into the test. t.Setenv restores them afterward.
func clearEnv(t *testing.T) {
	t.Helper()
	for _, k := range []string{
		"DB_DRIVER", "DB_SOURCE", "SERVER_ADDRESS", "TOKEN_SECRET",
		"SMTP_HOST", "SMTP_PORT", "SMTP_USERNAME", "SMTP_PASSWORD", "SMTP_FROM",
		"GOOGLE_CLIENT_ID", "S3_BUCKET", "S3_PUBLIC_BASE_URL",
		"AWS_REGION", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY",
	} {
		t.Setenv(k, "")
	}
}

func TestLoadConfigFromFile(t *testing.T) {
	clearEnv(t)
	dir := t.TempDir()
	content := "DB_DRIVER=postgres\nSERVER_ADDRESS=0.0.0.0:9000\nSMTP_PORT=2525\nS3_BUCKET=file-bucket\n"
	if err := os.WriteFile(filepath.Join(dir, ".env"), []byte(content), 0o600); err != nil {
		t.Fatal(err)
	}

	cfg, err := LoadConfig(dir)
	if err != nil {
		t.Fatalf("LoadConfig: %v", err)
	}
	if cfg.DBDriver != "postgres" || cfg.HTTPServerAddress != "0.0.0.0:9000" ||
		cfg.SMTPPort != 2525 || cfg.S3Bucket != "file-bucket" {
		t.Fatalf("unexpected config: %+v", cfg)
	}
}

func TestLoadConfigWithoutFile(t *testing.T) {
	clearEnv(t)
	t.Setenv("S3_BUCKET", "env-bucket")
	t.Setenv("SMTP_PORT", "465")

	cfg, err := LoadConfig(t.TempDir()) // empty dir: no .env
	if err != nil {
		t.Fatalf("a missing .env must not be an error, got: %v", err)
	}
	if cfg.S3Bucket != "env-bucket" || cfg.SMTPPort != 465 {
		t.Fatalf("env-only values were not loaded: %+v", cfg)
	}
}

// TODO (your turn): TestLoadConfigEnvOverridesFile
// 1. Write a .env into t.TempDir() with S3_BUCKET=file-bucket.
// 2. t.Setenv("S3_BUCKET", "env-bucket") AFTER clearEnv(t).
// 3. Call LoadConfig and check which value wins.
// Hint: AutomaticEnv + BindEnv gives env vars priority over the file.