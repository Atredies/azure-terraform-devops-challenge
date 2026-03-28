package tests

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// TestVnetModuleValidation validates the VNET module produces a valid plan.
// Run with: cd tests && go test -v -run TestVnetModuleValidation -timeout 10m
func TestVnetModuleValidation(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../environments/dev",
		Vars: map[string]interface{}{
			"ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7test-key-for-plan-only test@test",
		},
		PlanFilePath: "./tfplan-test",
		NoColor:      true,
	})

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	// Verify resource group is created
	rgResource := plan.ResourcePlannedValuesMap["azurerm_resource_group.this"]
	assert.NotNil(t, rgResource, "Resource group should be planned")
	assert.Equal(t, "rg-challenge-dev-eus-001", rgResource.AttributeValues["name"])
	assert.Equal(t, "eastus", rgResource.AttributeValues["location"])

	// Verify VNET is created with correct naming
	vnetResource := plan.ResourcePlannedValuesMap["module.vnet.azurerm_virtual_network.this"]
	assert.NotNil(t, vnetResource, "VNET should be planned")
	assert.Equal(t, "vnet-challenge-dev-eus-001", vnetResource.AttributeValues["name"])

	// Verify subnets are created (app + data for dev)
	appSubnet := plan.ResourcePlannedValuesMap["module.vnet.azurerm_subnet.this[\"app\"]"]
	dataSubnet := plan.ResourcePlannedValuesMap["module.vnet.azurerm_subnet.this[\"data\"]"]
	assert.NotNil(t, appSubnet, "App subnet should be planned")
	assert.NotNil(t, dataSubnet, "Data subnet should be planned")
	assert.Equal(t, "snet-challenge-app-dev-eus-001", appSubnet.AttributeValues["name"])
	assert.Equal(t, "snet-challenge-data-dev-eus-001", dataSubnet.AttributeValues["name"])

	// Verify NSGs are created per subnet
	appNsg := plan.ResourcePlannedValuesMap["module.vnet.azurerm_network_security_group.this[\"app\"]"]
	dataNsg := plan.ResourcePlannedValuesMap["module.vnet.azurerm_network_security_group.this[\"data\"]"]
	assert.NotNil(t, appNsg, "App NSG should be planned")
	assert.NotNil(t, dataNsg, "Data NSG should be planned")
	assert.Equal(t, "nsg-challenge-app-dev-eus-001", appNsg.AttributeValues["name"])
}

// TestVnetModuleOutputs verifies expected outputs are present in the plan.
func TestVnetModuleOutputs(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../environments/dev",
		Vars: map[string]interface{}{
			"ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7test-key-for-plan-only test@test",
		},
		PlanFilePath: "./tfplan-test-outputs",
		NoColor:      true,
	})

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	// Verify key outputs exist
	assert.Contains(t, plan.RawPlan.PlannedValues.Outputs, "resource_group_name")
	assert.Contains(t, plan.RawPlan.PlannedValues.Outputs, "vnet_id")
	assert.Contains(t, plan.RawPlan.PlannedValues.Outputs, "vnet_name")
	assert.Contains(t, plan.RawPlan.PlannedValues.Outputs, "subnet_ids")
	assert.Contains(t, plan.RawPlan.PlannedValues.Outputs, "vm_public_ip")
	assert.Contains(t, plan.RawPlan.PlannedValues.Outputs, "storage_account_name")

	// Verify static output values
	assert.Equal(t, "rg-challenge-dev-eus-001", plan.RawPlan.PlannedValues.Outputs["resource_group_name"].Value)
	assert.Equal(t, "vnet-challenge-dev-eus-001", plan.RawPlan.PlannedValues.Outputs["vnet_name"].Value)
	assert.Equal(t, "stchallengedeveus001", plan.RawPlan.PlannedValues.Outputs["storage_account_name"].Value)
}

// TestVmModuleNaming verifies VM resources follow naming convention.
func TestVmModuleNaming(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../environments/dev",
		Vars: map[string]interface{}{
			"ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7test-key-for-plan-only test@test",
		},
		PlanFilePath: "./tfplan-test-vm",
		NoColor:      true,
	})

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	// Verify VM naming convention
	vmResource := plan.ResourcePlannedValuesMap["module.vm.azurerm_linux_virtual_machine.this"]
	assert.NotNil(t, vmResource, "VM should be planned")
	assert.Equal(t, "vm-challenge-dev-eus-001", vmResource.AttributeValues["name"])
	assert.Equal(t, "Standard_B1s", vmResource.AttributeValues["size"])
	assert.Equal(t, "azureadmin", vmResource.AttributeValues["admin_username"])

	// Verify NIC naming
	nicResource := plan.ResourcePlannedValuesMap["module.vm.azurerm_network_interface.this"]
	assert.NotNil(t, nicResource, "NIC should be planned")
	assert.Equal(t, "nic-challenge-dev-eus-001", nicResource.AttributeValues["name"])

	// Verify public IP exists in dev (public_ip_enabled = true)
	pipResource := plan.ResourcePlannedValuesMap["module.vm.azurerm_public_ip.this[0]"]
	assert.NotNil(t, pipResource, "Public IP should be planned for dev")
	assert.Equal(t, "pip-challenge-dev-eus-001", pipResource.AttributeValues["name"])
}

// TestStorageModuleConfig verifies storage account configuration.
func TestStorageModuleConfig(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../environments/dev",
		Vars: map[string]interface{}{
			"ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7test-key-for-plan-only test@test",
		},
		PlanFilePath: "./tfplan-test-storage",
		NoColor:      true,
	})

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	// Verify storage account
	storageResource := plan.ResourcePlannedValuesMap["module.blob_storage.azurerm_storage_account.this"]
	assert.NotNil(t, storageResource, "Storage account should be planned")
	assert.Equal(t, "stchallengedeveus001", storageResource.AttributeValues["name"])
	assert.Equal(t, "Standard", storageResource.AttributeValues["account_tier"])
	assert.Equal(t, "LRS", storageResource.AttributeValues["account_replication_type"])
	assert.Equal(t, true, storageResource.AttributeValues["https_traffic_only_enabled"])
	assert.Equal(t, "TLS1_2", storageResource.AttributeValues["min_tls_version"])
	assert.Equal(t, false, storageResource.AttributeValues["allow_nested_items_to_be_public"])

	// Verify container
	containerResource := plan.ResourcePlannedValuesMap["module.blob_storage.azurerm_storage_container.this"]
	assert.NotNil(t, containerResource, "Storage container should be planned")
	assert.Equal(t, "data", containerResource.AttributeValues["name"])
	assert.Equal(t, "private", containerResource.AttributeValues["container_access_type"])
}

// TestResourceCount verifies the expected number of resources in the plan.
func TestResourceCount(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../environments/dev",
		Vars: map[string]interface{}{
			"ssh_public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC7test-key-for-plan-only test@test",
		},
		PlanFilePath: "./tfplan-test-count",
		NoColor:      true,
	})

	plan := terraform.InitAndPlanAndShowWithStruct(t, terraformOptions)

	// Dev should create exactly 13 resources
	resourceCount := len(plan.ResourcePlannedValuesMap)
	assert.Equal(t, 13, resourceCount, "Dev environment should plan exactly 13 resources")
}
