#!/usr/bin/env bash

# new
NEW_NCCL_DESCRIPTION="Creates a NVIDIA Collective Communications Library (NCCL) project"
NEW_NCCL_FLAGS=(
  "name,n,NCCL project name,-,-"
)
NEW_NCCL_FLAGS_MANDATORY="name"

# build
BUILD_NCCL_DESCRIPTION="Builds your NVIDIA Collective Communications Library (NCCL) project"
BUILD_NCCL_FLAGS=(
  "name,n,NCCL project name,-,-"
)
BUILD_NCCL_FLAGS_MANDATORY="name"

# program
PROGRAM_NCCL_DESCRIPTION="Programs your NCCL project to a specified device"
PROGRAM_NCCL_FLAGS=(
  "name,n,NCCL project name,-,-"
  "device,d,Device index,-,-"
)
PROGRAM_NCCL_FLAGS_MANDATORY="name,device"

# run
RUN_NCCL_DESCRIPTION="Runs your NCCL project"
RUN_NCCL_FLAGS=(
  "name,n,NCCL project name,-,-"
)
RUN_NCCL_FLAGS_MANDATORY="name"

# validate
VALIDATE_NCCL_DESCRIPTION="NVIDIA Collective Communications Library (NCCL) validation"
VALIDATE_NCCL_FLAGS=(
  "ngpus,g,Number of GPUs,1-8,1"
  "nthreads,t,Threads per process,1-64,1"
  "minbytes,b,Minimum message size,1B|4K|8M|1G,8M"
  "maxbytes,e,Maximum message size,1B|4K|1G|16G,1G"
  "iters,n,Timed iterations,1-1000,20"
  "datatype,d,Specify which datatype to use,int8|half|bfloat16|float,float"
  "stepfactor,f,Multiplication factor between sizes,2|4|8,2"
)
VALIDATE_NCCL_FLAGS_MANDATORY="ngpus,minbytes,maxbytes"