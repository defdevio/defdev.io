package main

import (
	"time"
)

type TerraformPlan struct {
	FormatVersion    string `json:"format_version"`
	TerraformVersion string `json:"terraform_version"`
	PlannedValues    struct {
		RootModule struct {
			Resources []struct {
				Address       string `json:"address"`
				Mode          string `json:"mode"`
				Type          string `json:"type"`
				Name          string `json:"name"`
				ProviderName  string `json:"provider_name"`
				SchemaVersion int    `json:"schema_version"`
				Values        struct {
					Content             string      `json:"content"`
					ContentBase64       interface{} `json:"content_base64"`
					DirectoryPermission string      `json:"directory_permission"`
					FilePermission      string      `json:"file_permission"`
					Filename            string      `json:"filename"`
					SensitiveContent    interface{} `json:"sensitive_content"`
					Source              interface{} `json:"source"`
				} `json:"values"`
				SensitiveValues struct {
					SensitiveContent bool `json:"sensitive_content"`
				} `json:"sensitive_values"`
			} `json:"resources"`
		} `json:"root_module"`
	} `json:"planned_values"`
	ResourceChanges []struct {
		Address      string `json:"address"`
		Mode         string `json:"mode"`
		Type         string `json:"type"`
		Name         string `json:"name"`
		ProviderName string `json:"provider_name"`
		Change       struct {
			Actions []string    `json:"actions"`
			Before  interface{} `json:"before"`
			After   struct {
				Content             string      `json:"content"`
				ContentBase64       interface{} `json:"content_base64"`
				DirectoryPermission string      `json:"directory_permission"`
				FilePermission      string      `json:"file_permission"`
				Filename            string      `json:"filename"`
				SensitiveContent    interface{} `json:"sensitive_content"`
				Source              interface{} `json:"source"`
			} `json:"after"`
			AfterUnknown struct {
				ContentBase64Sha256 bool `json:"content_base64sha256"`
				ContentBase64Sha512 bool `json:"content_base64sha512"`
				ContentMd5          bool `json:"content_md5"`
				ContentSha1         bool `json:"content_sha1"`
				ContentSha256       bool `json:"content_sha256"`
				ContentSha512       bool `json:"content_sha512"`
				ID                  bool `json:"id"`
			} `json:"after_unknown"`
			BeforeSensitive bool `json:"before_sensitive"`
			AfterSensitive  struct {
				SensitiveContent bool `json:"sensitive_content"`
			} `json:"after_sensitive"`
		} `json:"change"`
	} `json:"resource_changes"`
	Configuration struct {
		ProviderConfig struct {
			Local struct {
				Name     string `json:"name"`
				FullName string `json:"full_name"`
			} `json:"local"`
		} `json:"provider_config"`
		RootModule struct {
			Resources []struct {
				Address           string `json:"address"`
				Mode              string `json:"mode"`
				Type              string `json:"type"`
				Name              string `json:"name"`
				ProviderConfigKey string `json:"provider_config_key"`
				Expressions       struct {
					Content struct {
						ConstantValue string `json:"constant_value"`
					} `json:"content"`
					Filename struct {
						References []string `json:"references"`
					} `json:"filename"`
				} `json:"expressions"`
				SchemaVersion int `json:"schema_version"`
			} `json:"resources"`
		} `json:"root_module"`
	} `json:"configuration"`
	Timestamp time.Time `json:"timestamp"`
	Applyable bool      `json:"applyable"`
	Complete  bool      `json:"complete"`
	Errored   bool      `json:"errored"`
}
