package util

import (
	"errors"
	"fmt"
	"strings"

	"github.com/spf13/viper"
)

// Config stores all configurations of the application
// The values are read with viper from a config or environment variable
type Config struct {
	DBDriver           string `mapstructure:"DB_DRIVER"`
	DBSource           string `mapstructure:"DB_SOURCE"`
	HTTPServerAddress  string `mapstructure:"HTTP_SERVER_ADDRESS"`
	TokenSecret        string `mapstructure:"TOKEN_SECRET"`
	SMTPHost           string `mapstructure:"SMTP_HOST"`
	SMTPPort           int    `mapstructure:"SMTP_PORT"`
	SMTPUsername       string `mapstructure:"SMTP_USERNAME"`
	SMTPPassword       string `mapstructure:"SMTP_PASSWORD"`
	SMTPFrom           string `mapstructure:"SMTP_FROM"`
	GoogleClientID     string `mapstructure:"GOOGLE_CLIENT_ID"`
	S3Bucket           string `mapstructure:"S3_BUCKET"`
	S3PublicBaseURL    string `mapstructure:"S3_PUBLIC_BASE_URL"`
	AWSRegion          string `mapstructure:"AWS_REGION"`
	AWSAccessKeyID     string `mapstructure:"AWS_ACCESS_KEY_ID"`
	AWSSecretAccessKey string `mapstructure:"AWS_SECRET_ACCESS_KEY"`
}

func LoadConfig(path string) (config Config, err error) {
	v := viper.New()
	v.AddConfigPath(path)
	v.SetConfigName(".env")
	v.SetConfigType("env")
	v.AutomaticEnv()

	// Make env-only values visible to Unmarshal.
	for _, key := range []string{
		"DB_DRIVER", "DB_SOURCE", "HTTP_SERVER_ADDRESS", "TOKEN_SECRET",
		"SMTP_HOST", "SMTP_PORT", "SMTP_USERNAME", "SMTP_PASSWORD", "SMTP_FROM",
		"GOOGLE_CLIENT_ID", "S3_BUCKET", "S3_PUBLIC_BASE_URL",
		"AWS_REGION", "AWS_ACCESS_KEY_ID", "AWS_SECRET_ACCESS_KEY",
	} {
		if err = v.BindEnv(key); err != nil {
			return
		}
	}
	// A missing file is fine; any other read error is not.
	var notFound viper.ConfigFileNotFoundError
	if err = v.ReadInConfig(); err != nil && !errors.As(err, &notFound) {
		return
	}

	err = v.Unmarshal(&config)
	return
}

func (c Config) Validate() error {
	var errs []error

	if len(strings.TrimSpace(c.TokenSecret)) < 32 {
		errs = append(errs, errors.New("TOKEN_SECRET must be at least 32 characters"))
	}
	if strings.TrimSpace(c.DBSource) == "" {
		errs = append(errs, errors.New("DB_SOURCE is not set"))
	}
    
	if strings.TrimSpace(c.DBDriver) == "" {
		errs = append(errs, errors.New("DB_DRIVER is not set"))
	}

	if strings.TrimSpace(c.AWSRegion) == "" {
		errs = append(errs, errors.New("AWS_REGION is not set"))
	}

	if strings.TrimSpace(c.HTTPServerAddress) == "" {
		errs = append(errs, errors.New("SERVER_ADDRESS is not set"))
	}
	if strings.TrimSpace(c.S3Bucket) == "" {
		errs = append(errs, errors.New("S3_BUCKET is not set"))
	}
	if c.SMTPPort < 1 || c.SMTPPort > 65535 {
	errs = append(errs, fmt.Errorf("SMTP_PORT must be between 1 and 65535, got %d", c.SMTPPort))
    }

	return errors.Join(errs...)
}