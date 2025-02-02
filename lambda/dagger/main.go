// A generated module for Lambda functions
//
// This module has been generated via dagger init and serves as a reference to
// basic module structure as you get started with Dagger.
//
// Two functions have been pre-created. You can modify, delete, or add to them,
// as needed. They demonstrate usage of arguments and return types using simple
// echo and grep commands. The functions can be called from the dagger CLI or
// from one of the SDKs.
//
// The first line in this comment block is a short description line and the
// rest is a long description with more detail on the module's purpose or usage,
// if appropriate. All modules should have a short description.

package main

import (
	"context"
	"dagger/lambda/internal/dagger"
	"fmt"
)

type Lambda struct{}

func (m *Lambda) Publish(ctx context.Context, source *dagger.Directory, appSources []*dagger.File, awsCredentials *dagger.File, region string, awsAccountId string, repo string) (string, error) {
	ctr := m.Build(source, appSources)
	return m.EcrPush(ctx, awsCredentials, region, awsAccountId, repo, ctr)
}

func (m *Lambda) Build(source *dagger.Directory, appSources []*dagger.File) *dagger.Container {
	build := m.BuildEnv(source).
		WithExec([]string{"go", "build", "-o", "lambda-emailer"}).
		Directory("/src")
	return dag.Container().From("alpine").
		WithDirectory("/app", build).
		WithFiles("/app/mjml/email.mjml", appSources).
		WithEntrypoint([]string{"/app/lambda-emailer"})
}

func (m *Lambda) BuildEnv(source *dagger.Directory) *dagger.Container {
	goCache := dag.CacheVolume("go")
	return dag.Container().
		From("golang:alpine").
		WithDirectory("/src", source).
		WithMountedCache("/root/.cache/go-build", goCache).
		WithWorkdir("/src").
		WithExec([]string{"go", "mod", "tidy"})
}

// example usage: "dagger call get-secret --aws-credentials ~/.aws/credentials"
func (m *Lambda) GetSecret(ctx context.Context, awsCredentials *dagger.File) (string, error) {
	ctr, err := m.WithAwsSecret(ctx, dag.Container().From("ubuntu:latest"), awsCredentials)
	if err != nil {
		return "", err
	}
	return ctr.
		WithExec([]string{"bash", "-c", "cat /root/.aws/credentials | base64"}).
		Stdout(ctx)
}

func (m *Lambda) WithAwsSecret(ctx context.Context, ctr *dagger.Container, awsCredentials *dagger.File) (*dagger.Container, error) {
	credsFile, err := awsCredentials.Contents(ctx)
	if err != nil {
		return nil, err
	}
	secret := dag.SetSecret("aws-credential", credsFile)
	return ctr.WithMountedSecret("/root/.aws/credentials", secret), nil
}

func (m *Lambda) AwsCli(ctx context.Context, awsCredentials *dagger.File) (*dagger.Container, error) {
	ctr := dag.Container().
		From("public.ecr.aws/aws-cli/aws-cli:latest")
	ctr, err := m.WithAwsSecret(ctx, ctr, awsCredentials)
	if err != nil {
		return nil, err
	}
	return ctr, nil
}

// example usage: "dagger call ecr-push --region us-east-1 --aws-credentials ~/.aws/credentials --aws-account-id 12345 --repo test"
func (m *Lambda) EcrPush(ctx context.Context, awsCredentials *dagger.File, region, awsAccountId, repo string, pushCtr *dagger.Container) (string, error) {
	// Get the ECR login password so we can authenticate with Publish WithRegistryAuth
	ctr, err := m.AwsCli(ctx, awsCredentials)
	if err != nil {
		return "", err
	}
	regCred, err := ctr.
		WithExec([]string{"aws", "ecr", "get-login-password", "--region", region}).
		Stdout(ctx)
	if err != nil {
		return "", err
	}
	secret := dag.SetSecret("aws-reg-cred", regCred)
	ecrHost := fmt.Sprintf("%s.dkr.ecr.%s.amazonaws.com", awsAccountId, region)
	ecrWithRepo := fmt.Sprintf("%s/%s", ecrHost, repo)

	return pushCtr.WithRegistryAuth(ecrHost, "AWS", secret).Publish(ctx, ecrWithRepo)
}
