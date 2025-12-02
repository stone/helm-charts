#!/usr/bin/env bats

load '_config_setup'

@test "Helm test passes" {
    run helm test ${RELEASE_NAME} --namespace ${NAMESPACE}
    [ "$status" -eq 0 ]
}

# @test "Service endpoint is accessible from test pod" {
#     run kubectl run test-curl --image=curlimages/curl:latest --rm --restart=Never -n ${NAMESPACE} -- curl -s -o /dev/null -w "%{http_code}" http://${RELEASE_NAME}-its-mytabs:47777/ --max-time 10
#     [ "$status" -eq 0 ]
#     [[ "$output" =~ ^200 ]]
# }
