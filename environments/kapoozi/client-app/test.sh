#!/bin/bash

# wait for client deployments
$SCRIPT_DIR/tools/wait-for-rollout.sh deployment gh-action-client-deployment client 10