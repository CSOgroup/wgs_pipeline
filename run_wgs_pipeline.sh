#!/bin/bash

PIPELINE_VERSION="3.2.3"
MAX_MEMORY="100.GB"
MAX_CPUS=15
IGENOMES_BASE="${REFERENCES_PATH}/iGenomes"
TOOLS="freebayes,manta,controlfreec,vep"

die()
{
	local _ret="${2:-1}"
	test "${_PRINT_HELP:-no}" = yes && print_help >&2
	echo "$1" >&2
	exit "${_ret}"
}


begins_with_short_option()
{
	local first_option all_short_options='gh'
	first_option="${1:0:1}"
	test "$all_short_options" = "${all_short_options/$first_option/}" && return 1 || return 0
}

# THE DEFAULTS INITIALIZATION - POSITIONALS
_positionals=()
# THE DEFAULTS INITIALIZATION - OPTIONALS
_arg_genome="GATK.GRCh37"


print_help()
{
	printf '%s\n' "Whole-genome sequence Oricchiello Lab Pipeline"
	printf 'Usage: %s [-g|--genome <arg>] [-h|--help] [--version] <samplesheet> <outdir>\n' "$0"
	printf '\t%s\n' "<samplesheet>: path to the samplesheet CSV file"
	printf '\t%s\n' "<outdir>: path to the output directory where to store the results"
	printf '\t%s\n' "-g, --genome: genome to be used (default: 'GATK.GRCh37')"
	printf '\t%s\n' "-h, --help: Prints help"
	printf '\t%s\n' "--version: Prints version"
}


parse_commandline()
{
	_positionals_count=0
	while test $# -gt 0
	do
		_key="$1"
		case "$_key" in
			-g|--genome)
				test $# -lt 2 && die "Missing value for the optional argument '$_key'." 1
				_arg_genome="$2"
				shift
				;;
			--genome=*)
				_arg_genome="${_key##--genome=}"
				;;
			-g*)
				_arg_genome="${_key##-g}"
				;;
			-h|--help)
				print_help
				exit 0
				;;
			-h*)
				print_help
				exit 0
				;;
			--version)
				echo ${PIPELINE_VERSION}
				exit 0
				;;
			*)
				_last_positional="$1"
				_positionals+=("$_last_positional")
				_positionals_count=$((_positionals_count + 1))
				;;
		esac
		shift
	done
}


handle_passed_args_count()
{
	local _required_args_string="'samplesheet' and 'outdir'"
	test "${_positionals_count}" -ge 2 || _PRINT_HELP=yes die "FATAL ERROR: Not enough positional arguments - we require exactly 2 (namely: $_required_args_string), but got only ${_positionals_count}." 1
	test "${_positionals_count}" -le 2 || _PRINT_HELP=yes die "FATAL ERROR: There were spurious positional arguments --- we expect exactly 2 (namely: $_required_args_string), but got ${_positionals_count} (the last one was: '${_last_positional}')." 1
}


assign_positional_args()
{
	local _positional_name _shift_for=$1
	_positional_names="_arg_samplesheet _arg_outdir "

	shift "$_shift_for"
	for _positional_name in ${_positional_names}
	do
		test $# -gt 0 || break
		eval "$_positional_name=\${1}" || die "Error during argument parsing, possibly an Argbash bug." 1
		shift
	done
}

run(){
    local design_path=$1
    local output_path=$2
    local work_path=$3
    local log_path=$4
    local genome=$5

    echo "Running nf-core/sarek (${PIPELINE_VERSION}) with the following parameters"
    echo "- Design path: ${design_path}"
    echo "- Output path: ${output_path}"
    echo "- Work path: ${work_path}"
    echo "- Log path: ${log_path}"
    echo "- Genome: ${genome}"
	echo "- Variant calling tools: ${TOOLS}"
    echo "- iGenomes path: ${IGENOMES_BASE}"
    echo "- Maximum memory: ${MAX_MEMORY}"
	echo "- Maximum n. cpus: ${MAX_CPUS}"

    nextflow -log ${log_path} run nf-core/sarek \
                -r ${PIPELINE_VERSION} \
                -w ${work_path} \
                -profile docker \
                --max_memory ${MAX_MEMORY} \
                --max_cpus ${MAX_CPUS} \
                --outdir ${output_path} \
                --input ${design_path} \
                --genome ${genome} \
				--tools ${TOOLS} \
                --save_mapped \
                --save_output_as_bam \
				--igenomes_base ${IGENOMES_BASE} \
				-resume
}

parse_commandline "$@"
handle_passed_args_count
assign_positional_args 1 "${_positionals[@]}"


DESIGN_PATH=$_arg_samplesheet
OUTDIR=$_arg_outdir
GENOME=$_arg_genome

work_path="${OUTDIR}/work"
output_path="${OUTDIR}/results"
log_path="${OUTDIR}/logs"

mkdir -p ${OUTDIR}

run ${DESIGN_PATH} ${output_path} ${work_path} ${log_path} ${GENOME}