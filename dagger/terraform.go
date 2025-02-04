package main

import (
	"context"
	"dagger/def-dev-io/internal/dagger"
	"encoding/json"
	"fmt"
	"slices"
)

func (m *DefDevIo) TerraformPlan(
	ctx context.Context,
	directory *dagger.Directory,
	// path where the plan output should be stored
	// +optional
	// +default="tfplan"
	planOutput string,
	// automatically apply the terraform plan
	// +default=false
	autoApply bool,
	// set the version of the terraform binary to use
	// +default="1.8.4"
	terraformVersion string,
	awsCredentials *dagger.File,
	appSource *dagger.Directory,
) *DefDevIo {
	ctr, err := m.TerraformContainer(directory, terraformVersion, awsCredentials, appSource)
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
		"-out", planOutput,
		"-json",
	})

	_, err = plan.Stderr(ctx)
	if err != nil {
		println(plan.Stderr(ctx))
		return nil
	}

	show := plan.WithExec([]string{
		"terraform",
		"show",
		"-no-color",
		"-json", planOutput,
	})

	output, err := show.Stdout(ctx)
	if err != nil {
		println(err)
		return nil
	}

	var tfPlan TerraformPlan
	err = json.Unmarshal([]byte(output), &tfPlan)
	if err != nil {
		println(err)
		return nil
	}

	var deleteActions []string
	if len(tfPlan.ResourceChanges) > 0 {
		for _, resourceChanges := range tfPlan.ResourceChanges {
			for _, changeAction := range resourceChanges.Change.Actions {
				if changeAction == "delete" {
					deleteActions = append(deleteActions, changeAction)
				}
			}
		}
	}

	if slices.Contains(deleteActions, "delete") {
		m.Actions = deleteActions
		return &DefDevIo{Plan: nil}
	}

	return &DefDevIo{Plan: plan}
}

func (m *DefDevIo) TerraformSpecPlan(
	ctx context.Context,
	// the app source code directory
	appSource *dagger.Directory,
	// the directory of the terraform code
	directory *dagger.Directory,
	// the terraform version to use
	// +default="1.10.5"
	terraformVersion string,
	// the path to the AWS credentials file
	awsCredentials *dagger.File,
	// the terraform .tfvars file to use
	tfVarFile string,
) (string, error) {
	ctr, err := m.TerraformContainer(directory, terraformVersion, awsCredentials, appSource)
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
		"-var-file",
		tfVarFile,
	})

	return plan.Stdout(ctx)
}

func (m *DefDevIo) AutoApply(ctx context.Context) *dagger.File {
	apply := m.Plan.WithExec([]string{
		"terraform",
		"apply",
		"-auto-approve",
		"-state-out", "terraform.tfstate",
	})

	return apply.File("./terraform.tfstate")
}

func (m *DefDevIo) TerraformContainer(directory *dagger.Directory, terraformVersion string, awsCredentials *dagger.File, appSource *dagger.Directory) (*dagger.Container, error) {
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
