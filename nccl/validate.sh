#!/bin/bash

# example: odev validate nccl --ngpus 1 --nthreads 1 --minbytes 8M --maxbytes 1G --iters 20 --datatype float --stepfactor 2

# get script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUBCOMMAND="$(basename "${BASH_SOURCE[0]}" .sh)"

# derive from SCRIPT_DIR
CLI_NAME="$(basename "$(dirname "$(dirname "$SCRIPT_DIR")")")"
COMMAND="$(basename "$SCRIPT_DIR")"
ODEV_PATH="${ODEV_PATH:-"$(dirname "$SCRIPT_DIR")"}"

# get hostname
url="${HOSTNAME}"
hostname="${url%%.*}"

# format
bold=$(tput bold)
italic=$(tput sitm 2>/dev/null || true)
normal=$(tput sgr0)

# constants
CMDB_PATH="$(eval echo "$("$ODEV_PATH/src/read_yml.py" --db "$ODEV_PATH/constants.yml" paths cmdb)")"
COLOR_OREOL=$($ODEV_PATH/src/color_get.sh $ODEV_PATH COLOR_OREOL)
LOCAL_TEST="1"
PROJECTS_PATH="$(eval echo "$("$ODEV_PATH/src/read_yml.py" --db "$ODEV_PATH/constants.yml" paths projects)")"
VALIDATION_PROJECT_PATH="$PROJECTS_PATH/$COMMAND.$SUBCOMMAND.$hostname"

# check on users
# ...

# check on tools
installed="$("$ODEV_PATH/src/required_tools_print.sh" "$ODEV_PATH" "nvidia-smi")"
if [[ "$installed" == "0" ]]; then
  echo "Missing tool: $tool"
fi

# set KEY
KEY="$(printf '%s_%s' "$COMMAND" "$SUBCOMMAND" | tr '[:lower:]' '[:upper:]')"
#KEY="${COMMAND^^}"

# get cmd_spec.sh path
target="$(readlink -f "$ODEV_PATH/cmd/$COMMAND/$SUBCOMMAND.sh")"
CMD_SPEC_PATH="$(dirname "$target")"

# read command description, command flags, and mandatory flags
command_description="$("$ODEV_PATH/src/cmd_description_read.sh" "$ODEV_PATH" "$KEY" --db "$CMD_SPEC_PATH/cmd_spec.sh")"
mapfile -t flags < <("$ODEV_PATH/src/cmd_flags_read.sh" "$ODEV_PATH" "$KEY" --db "$CMD_SPEC_PATH/cmd_spec.sh")
mandatory_flags="$("$ODEV_PATH/src/cmd_mandatory_flags_read.sh" "$ODEV_PATH" "$KEY" --db "$CMD_SPEC_PATH/cmd_spec.sh")"

# (maybe) print help
print_range="1"
print_default="0"
print_both="0"
"$ODEV_PATH/src/cmd_help_print.sh" --maybe \
  "$CLI_NAME" "$COMMAND" "$SUBCOMMAND" "$command_description" \
  "$print_range" "$print_default" "$print_both" \
  "${flags[@]}" -- "$@" && exit 0 || true

# parse flags
parsed_flags="$("$ODEV_PATH/src/cmd_parse.sh" --params "${flags[@]}" -- "$@")" || exit 1

# run interactive prompt
parsed_flags="$("$ODEV_PATH/src/cmd_prompt.sh" --required "$mandatory_flags" --params "${flags[@]}" -- "$parsed_flags")" || exit 1

# read flags
if [[ -n "$parsed_flags" ]]; then
  declare -A V
  while IFS='=' read -r k v; do
    V["$k"]="$v"
  done <<< "$parsed_flags"
fi

# assign flags
devices=${V[devices]}
nthreads=${V[nthreads]}
minbytes=${V[minbytes]}
maxbytes=${V[maxbytes]}
iters=${V[iters]}
datatype=${V[datatype]}
stepfactor=${V[stepfactor]}

# check on flags
# ...

# check on devices
if [[ ! "$devices" =~ ^[0-9]+(,\ ?[0-9]+)*$ ]]; then
    echo "Invalid devices format: $devices"
    exit 1
fi

# convert devices to an array
devices_array=$(echo "$devices" | tr -d ' ')
IFS=',' read -ra devices_array <<< "$devices_array"

# remove duplicates
mapfile -t devices_array < <(printf "%s\n" "${devices_array[@]}" | awk '!seen[$0]++')

# nvidia-smi/CMDB validation
for d in "${devices_array[@]}"; do
    name_smi=$(nvidia-smi -i $d --query-gpu=name --format=csv,noheader)
    name_cmdb=$($CMDB_PATH/cmdb_get.py --db $CMDB_PATH/$hostname.yml gpu $d name)
    if [[ "$name_smi" != "$name_cmdb" ]]; then
      echo "Invalid device index: $d"
      exit 1
    fi
done

# derive ngpus
ngpus=${#devices_array[@]}

# set command flags
flags="--ngpus $ngpus --nthreads $nthreads --minbytes $minbytes --maxbytes $maxbytes --iters $iters --datatype $datatype --stepfactor $stepfactor"

# derived
MPI_HOME="$(eval echo "$("$ODEV_PATH/src/read_yml.py" --db "$CMDB_PATH/vars.yml" mpi home)")"

# set projects folder
if [[ ! -d "$PROJECTS_PATH" ]]; then
  mkdir -p "$PROJECTS_PATH"
  cp "$ODEV_PATH/src/github_push.sh" "$PROJECTS_PATH"
  cp "$ODEV_PATH/src/git_diff.sh" "$PROJECTS_PATH"
  chmod +x "$PROJECTS_PATH/github_push.sh" "$PROJECTS_PATH/git_diff.sh"
fi

# steps
# create folders
step_1="rm -rf $VALIDATION_PROJECT_PATH"
step_2="mkdir -p $VALIDATION_PROJECT_PATH"

# copy files from template
step_3="cp -r $ODEV_PATH/templates/nvidia/nccl-tests/. $VALIDATION_PROJECT_PATH"

# build
step_4="cd $VALIDATION_PROJECT_PATH"
if [ "$LOCAL_TEST" = "1" ]; then
    step_5="make"
else
    step_5="make MPI=1 MPI_HOME=$MPI_HOME"
fi

# run
step_6="cd $VALIDATION_PROJECT_PATH/build"
step_7="CUDA_VISIBLE_DEVICES=$devices ./all_gather_perf $flags"

# echo steps
echo ""
echo -e "${bold}$CLI_NAME $SUBCOMMAND $COMMAND $flags${normal}"
echo ""
echo -e "${COLOR_OREOL}$step_1${normal}"
echo -e "${COLOR_OREOL}$step_2${normal}"
echo -e "${COLOR_OREOL}$step_3${normal}"
echo -e "${COLOR_OREOL}$step_4${normal}"
echo -e "${COLOR_OREOL}$step_5${normal}"
echo -e "${COLOR_OREOL}$step_6${normal}"
echo -e "${COLOR_OREOL}$step_7${normal}"
echo ""

# eval steps
eval $step_1
eval $step_2
eval $step_3
eval $step_4
eval $step_5
eval $step_6
eval $step_7

# author: https://github.com/jmoya82