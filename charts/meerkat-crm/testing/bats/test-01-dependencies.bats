#!/usr/bin/env bats

load '_config_setup'

@test "Deps are installed" {
    command -v kind
    command -v helm
    command -v kubectl
}
