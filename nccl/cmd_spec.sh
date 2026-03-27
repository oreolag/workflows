#!/usr/bin/env bash

# helpers
lower() {
  printf '%s' "${1,,}"
}

NEW_NCCL_DESCRIPTION="New description"
NEW_NCCL_FLAGS=(
  "name,n,Project name,-,-"
  "push,p,Push to GitHub,0|1,1"
)
NEW_NCCL_FLAGS_MANDATORY="name,push"

BUILD_NCCL_DESCRIPTION="Build description"
BUILD_NCCL_FLAGS=(
  "name,n,Project name,-,-"
)
BUILD_NCCL_FLAGS_MANDATORY="name"

DELETE_NCCL_DESCRIPTION="Deletes a $(lower NCCL) project"
DELETE_NCCL_FLAGS=(
  "name,n,Project name,-,-"
)
DELETE_NCCL_FLAGS_MANDATORY="name"

PROGRAM_NCCL_DESCRIPTION="Program description"
PROGRAM_NCCL_FLAGS=(
  "name,n,Project name,-,-"
)
PROGRAM_NCCL_FLAGS_MANDATORY="name"

RUN_NCCL_DESCRIPTION="Run description"
RUN_NCCL_FLAGS=(
  "name,n,Project name,-,-"
)
RUN_NCCL_FLAGS_MANDATORY="name"

VALIDATE_NCCL_DESCRIPTION="Validate description"
VALIDATE_NCCL_FLAGS=(
  "flag1,a,Flag 1 description,1-8,1"
  "flag2,b,Flag 2 description,8|16,8"
)
VALIDATE_NCCL_FLAGS_MANDATORY="flag1,flag2"