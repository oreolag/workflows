#!/usr/bin/env bash

# new
NEW_DESCRIPTION="Creates a NVIDIA Collective Communications Library (NCCL) project"
NEW_FLAGS=(
  "name,n,Project name,-,-"
  "push,p,Push to GitHub,0|1,1"
)
NEW_FLAGS_MANDATORY="name,push"

# build
BUILD_DESCRIPTION="Builds your nccl project"
BUILD_FLAGS=(
  "name,n,Project name,-,-"
)
BUILD_FLAGS_MANDATORY="name"

# delete
DELETE_DESCRIPTION="Deletes a nccl project"
DELETE_FLAGS=(
  "name,n,Project name,-,-"
)
DELETE_FLAGS_MANDATORY="name"

# program
PROGRAM_DESCRIPTION="Programs your nccl project to a specified device"
PROGRAM_FLAGS=(
  "name,n,Project name,-,-"
  "device,d,Device index,-,-"
)
PROGRAM_FLAGS_MANDATORY="name,device"

# run
RUN_DESCRIPTION="Runs your nccl project"
RUN_FLAGS=(
  "name,n,Project name,-,-"
)
RUN_FLAGS_MANDATORY="name"

# validate
VALIDATE_DESCRIPTION="NVIDIA Collective Communications Library (NCCL) validation"
VALIDATE_FLAGS=(
  "ngpus,g,Number of GPUs,1-8,1"
  "nthreads,t,Threads per process,1-64,1"
  "minbytes,b,Minimum message size,1B|4K|8M|1G,8M"
  "maxbytes,e,Maximum message size,1B|4K|1G|16G,1G"
  "iters,n,Timed iterations,1-1000,20"
  "datatype,d,Specify which datatype to use,int8|half|bfloat16|float,float"
  "stepfactor,f,Multiplication factor between sizes,2|4|8,2"
)
VALIDATE_FLAGS_MANDATORY="ngpus,minbytes,maxbytes"