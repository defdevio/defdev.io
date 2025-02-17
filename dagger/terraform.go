package main

import (
	"context"
	"dagger/def-dev-io/internal/dagger"
	"fmt"
)

// Run terraform plan with the plan file saved to a DefDevIo Dagger container: "terraform-plan --terraform-version 1.10.5 --app-source ./src/ --aws-credentials ~/.aws/credentials --directory ./infra --tf-var-file environments/prod.tfvars"
func (m *DefDevIo) TerraformPlan(
	ctx context.Context,
	// Path on host of files to upload to AWS S3
	appSource *dagger.Directory,
	// Path on host to an AWS credentials file
	awsCredentials *dagger.File,
	// Path on host to terraform code
	directory *dagger.Directory,
	// Container path where the plan output should be stored
	// +optional
	// +default="tfplan"
	planOutput string,
	// Version of terraform to use
	// +default="1.8.4"
	terraformVersion string,
	// Path on host to the tfvars file to use
	tfVarFile string,
) *DefDevIo {
	ctr, err := m.terraformContainer(directory, terraformVersion, awsCredentials, appSource)
	if err != nil {
		return nil
	}

	init := ctr.WithExec([]string{
		"terraform",
		"init",
	})

	plan := init.WithExec([]string{
		"terraform",
		"plan",
		"-var-file", tfVarFile,
		"-out", planOutput,
	})

	_, err = plan.Stderr(ctx)
	if err != nil {
		println(plan.Stderr(ctx))
		return nil
	}

	return &DefDevIo{plan: plan}
}

// Run a terraform plan and print the result to stdout: "terraform-spec-plan --terraform-version 1.10.5 --app-source ./src/ --aws-credentials ~/.aws/credentials --directory ./infra --tf-var-file environments/prod.tfvars"
func (m *DefDevIo) TerraformSpecPlan(
	ctx context.Context,
	// Path on host of files to upload to S3
	appSource *dagger.Directory,
	// Path on host to an AWS credentials file
	awsCredentials *dagger.File,
	// Path on host to terraform code
	directory *dagger.Directory,
	// The terraform version to use
	// +default="1.10.5"
	terraformVersion string,
	// Path on host to the tfvars file to use
	tfVarFile string,
) (string, error) {
	ctr, err := m.terraformContainer(directory, terraformVersion, awsCredentials, appSource)
	if err != nil {
		return "", err
	}

	init := ctr.WithExec([]string{
		"terraform",
		"init",
	})

	plan := init.WithExec([]string{
		"terraform",
		"plan",
		"-var-file", tfVarFile,
	})

	return plan.Stdout(ctx)
}

// Auto apply the plan saved to a DefDevIo Dagger container: "terraform-plan --terraform-version 1.10.5 --app-source ./src/ --aws-credentials ~/.aws/credentials --directory ./infra --tf-var-file environments/prod.tfvars terraform-auto-apply"
func (m *DefDevIo) TerraformAutoApply(
	ctx context.Context,
	// The tfplan file to apply
	// +optional
	// +default="tfplan"
	planInput string,
) (string, error) {
	if m.plan != nil {
		apply := m.plan.WithExec([]string{
			"terraform",
			"apply",
			planInput,
		})

		return apply.Stdout(ctx)
	}

	return "", fmt.Errorf("errors were present: canceling auto apply")
}

func (m *DefDevIo) terraformContainer(directory *dagger.Directory, terraformVersion string, awsCredentials *dagger.File, appSource *dagger.Directory) (*dagger.Container, error) {
	ctr := dag.Container().
		From(fmt.Sprintf("hashicorp/terraform:%s", terraformVersion)).
		WithMountedDirectory("/mnt", directory).
		WithDirectory("/src", appSource).
		WithWorkdir("/mnt")

	ctr, err := m.withAwsSecret(context.TODO(), ctr, awsCredentials)
	if err != nil {
		return nil, err
	}

	return ctr, nil
}
