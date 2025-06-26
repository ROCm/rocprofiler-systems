#!/usr/bin/env bash

: ${USER:=$(whoami)}
: ${ROCM_VERSIONS:="6.2.0"}
: ${DISTRO:=ubuntu}
: ${VERSIONS:=20.04}
: ${PYTHON_VERSIONS:="6 7 8 9 10 11 12 13"}
: ${BUILD_CI:=""}
: ${PUSH:=0}
: ${PULL:=--pull}
: ${RETRY:=3}

set -e

tolower()
{
    echo "$@" | awk -F '\\|~\\|' '{print tolower($1)}';
}

toupper()
{
    echo "$@" | awk -F '\\|~\\|' '{print toupper($1)}';
}

usage()
{
    print_option() { printf "    --%-20s %-24s     %s\n" "${1}" "${2}" "${3}"; }
    echo "Options:"
    print_option "help -h"   "" "This message"
    print_option "no-pull"   "" "Do not pull down most recent base container"
    print_option "matrix -m" "[ubuntu|opensuse|rhel]" "Shows compatibility matrix"

    echo ""
    print_default_option() { printf "    --%-20s %-24s     %s (default: %s)\n" "${1}" "${2}" "${3}" "$(tolower ${4})"; }
    print_default_option distro "[ubuntu|opensuse|rhel]" "OS distribution" "${DISTRO}"
    print_default_option versions "[VERSION] [VERSION...]" "Ubuntu, OpenSUSE, or RHEL release" "${VERSIONS}"
    print_default_option rocm-versions "[VERSION] [VERSION...]" "ROCm versions (format: Major.Minor.Patch, patch defaults to 0 if not specified)" "${ROCM_VERSIONS}"
    print_default_option python-versions "[VERSION] [VERSION...]" "Python 3 minor releases" "${PYTHON_VERSIONS}"
    print_default_option "user -u" "[USERNAME]" "DockerHub username" "${USER}"
    print_default_option "retry -r" "[N]" "Number of attempts to build (to account for network errors)" "${RETRY}"
    print_default_option push "" "Push the image to Dockerhub" ""
    #print_default_option lto "[on|off]" "Enable LTO" "${LTO}"
}

send-error()
{
    usage
    echo -e "\nError: ${@}"
    exit 1
}

# Prints compatibility matrix by scanning .github/workflows/containers.yml matrix
show-matrix()
{
    local filter_distro="${1:-}"
    local workflow_file="../.github/workflows/containers.yml"

    if [ -n "${filter_distro}" ]; then
        filter_distro=$(tolower "${filter_distro}")
        case "${filter_distro}" in
            ubuntu|opensuse|rhel)
                ;;
            *)
                echo -e "\n Error: Unsupported distribution '${filter_distro}'"
                echo "   Supported distributions: ubuntu, opensuse, rhel"
                echo ""
                exit 1
                ;;
        esac
    fi
    if [ ! -f "${workflow_file}" ]; then
        echo -e "\n Error: Cannot find ${workflow_file}"
        exit 1
    fi

    echo ""
    if [ -n "${filter_distro}" ]; then
        echo "        Supported ${filter_distro} + ROCm Combinations     "
        echo "   =============================================="
    else
        echo "        Supported OS + ROCm Combinations     "
        echo "   =========================================="
    fi
    echo ""
    echo "   OS Distribution    Version    ROCm Version"
    echo "   ----------------   -------    ------------"

    awk -v filter="${filter_distro}" '
    /rocprofiler-systems-release:/, /steps:/ {
        if (/- os-distro:/) {
            gsub(/[[:space:]]*- os-distro:[[:space:]]*"/, "")
            gsub(/"/, "")
            distro = $0
        }
        if (/os-version:/) {
            gsub(/[[:space:]]*os-version:[[:space:]]*"/, "")
            gsub(/"/, "")
            version = $0
        }
        if (/rocm-version:/) {
            gsub(/[[:space:]]*rocm-version:[[:space:]]*"/, "")
            gsub(/"/, "")
            rocm = $0
            if (rocm == "0.0") {
                rocm = "0.0"
            } else {
                rocm = rocm
            }
            if (filter == "" || distro == filter) {
                printf "   %-16s   %-9s  %s\n", distro, version, rocm
            }
        }
    }
    ' "${workflow_file}"

    echo ""
    echo "ROCm '0.0' means no ROCm installation (CPU-only build)"
    echo ""
    echo "Note: Patch versions are also supported (See: https://repo.radeon.com/amdgpu-install/)"
    echo ""
}

verbose-run()
{
    echo -e "\n### Executing \"${@}\"... ###\n"
    eval "${@}"
}

verbose-build()
{
    echo -e "\n### Executing \"${@}\" a maximum of ${RETRY} times... ###\n"
    for i in $(seq 1 1 ${RETRY})
    do
        set +e
        eval "${@}"
        local RETC=$?
        set -e
        if [ "${RETC}" -eq 0 ]; then
            break
        else
            echo -en "\n### Command failed with error code ${RETC}... "
            if [ "${i}" -ne "${RETRY}" ]; then
                echo -e "Retrying... ###\n"
                sleep 3
            else
                echo -e "Exiting... ###\n"
                exit ${RETC}
            fi
        fi
    done
}

reset-last()
{
    last() { send-error "Unsupported argument :: ${1}"; }
}

reset-last

n=0
while [[ $# -gt 0 ]]
do
    case "${1}" in
        -h|--help)
            usage
            exit 0
            ;;
        -m|--matrix)
            shift
            if [[ $# -gt 0 && ! "${1}" =~ ^-- ]]; then
                show-matrix "${1}"
            else
                show-matrix
            fi
            exit 0
            ;;
        "--distro")
            shift
            DISTRO=$(tolower ${1})
            last() { DISTRO="${DISTRO} $(tolower${1})"; }
            ;;
        "--versions")
            shift
            VERSIONS=${1}
            last() { VERSIONS="${VERSIONS} ${1}"; }
            ;;
        "--rocm-versions")
            shift
            ROCM_VERSIONS=${1}
            last() { ROCM_VERSIONS="${ROCM_VERSIONS} ${1}"; }
            ;;
        "--python-versions")
            shift
            PYTHON_VERSIONS=${1}
            last() { PYTHON_VERSIONS="${PYTHON_VERSIONS} ${1}"; }
            ;;
        --user|-u)
            shift
            USER=${1}
            reset-last
            ;;
        --push)
            PUSH=1
            reset-last
            ;;
        --no-pull)
            PULL=""
            reset-last
            ;;
        --retry|-r)
            shift
            RETRY=${1}
            reset-last
            ;;
        "--*")
            send-error "Unsupported argument at position $((${n} + 1)) :: ${1}"
            ;;
        *)
            last ${1}
            ;;
    esac
    n=$((${n} + 1))
    shift
done

DOCKER_FILE="Dockerfile.${DISTRO}"

if [ "${RETRY}" -lt 1 ]; then
    RETRY=1
fi

if [ -n "${BUILD_CI}" ]; then DOCKER_FILE="${DOCKER_FILE}.ci"; fi
if [ ! -f ${DOCKER_FILE} ]; then cd docker; fi
if [ ! -f ${DOCKER_FILE} ]; then send-error "File \"${DOCKER_FILE}\" not found"; fi

for VERSION in ${VERSIONS}
do
    VERSION_MAJOR=$(echo ${VERSION} | sed 's/\./ /g' | awk '{print $1}')
    VERSION_MINOR=$(echo ${VERSION} | sed 's/\./ /g' | awk '{print $2}')
    VERSION_PATCH=$(echo ${VERSION} | sed 's/\./ /g' | awk '{print $3}')
    for ROCM_VERSION in ${ROCM_VERSIONS}
    do
        ROCM_MAJOR=$(echo ${ROCM_VERSION} | sed 's/\./ /g' | awk '{print $1}')
        ROCM_MINOR=$(echo ${ROCM_VERSION} | sed 's/\./ /g' | awk '{print $2}')
        ROCM_PATCH=$(echo ${ROCM_VERSION} | sed 's/\./ /g' | awk '{print $3}')
        if [ -z "${ROCM_PATCH}" ]  || ([ "${ROCM_MAJOR}" = "0" ] && [ "${ROCM_MINOR}" = "0" ]); then
            ROCM_PATCH=0
        fi
        CONTAINER=${USER}/rocprofiler-systems:release-base-${DISTRO}-${VERSION}-rocm-${ROCM_MAJOR}.${ROCM_MINOR}.${ROCM_PATCH}
        if [ -n "${ROCM_PATCH}" ]; then
            ROCM_VERSN=$(( (${ROCM_MAJOR}*10000)+(${ROCM_MINOR}*100)+(${ROCM_PATCH}) ))
            ROCM_SEP="."
        else
            ROCM_VERSN=$(( (${ROCM_MAJOR}*10000)+(${ROCM_MINOR}*100) ))
            ROCM_SEP=""
        fi
        if [ "${DISTRO}" = "ubuntu" ]; then
            ROCM_REPO_DIST="ubuntu"
            ROCM_REPO_VERSION=${ROCM_VERSION}
            case "${ROCM_VERSION}" in
                6.*)
                    case "${VERSION}" in
                        24.04)
                            ROCM_REPO_DIST="noble"
                            ;;
                        22.04)
                            ROCM_REPO_DIST="jammy"
                            ;;
                        20.04)
                            ROCM_REPO_DIST="focal"
                            ;;
                        *)
                            ;;
                    esac
                    ROCM_DEB=amdgpu-install_${ROCM_MAJOR}.${ROCM_MINOR}.${ROCM_VERSN}-1_all.deb
                    ;;
                *)
                    ;;
            esac
            verbose-build docker build . ${PULL} --progress plain -f ${DOCKER_FILE} --tag ${CONTAINER} --build-arg DISTRO=${DISTRO} --build-arg VERSION=${VERSION} --build-arg ROCM_VERSION=${ROCM_VERSION} --build-arg ROCM_REPO_VERSION=${ROCM_REPO_VERSION} --build-arg ROCM_REPO_DIST=${ROCM_REPO_DIST} --build-arg AMDGPU_DEB=${ROCM_DEB} --build-arg PYTHON_VERSIONS=\"${PYTHON_VERSIONS}\"
        elif [ "${DISTRO}" = "rhel" ]; then
            if [ -z "${VERSION_MINOR}" ]; then
                send-error "Please provide a major and minor version of the OS. Supported: >= 8.8, <= 9.4"
            fi

            # Components used to create the sub-URL below
            #   set <OS-VERSION> in amdgpu-install/<ROCM-VERSION>/rhel/<OS-VERSION>
            RPM_PATH=${VERSION_MAJOR}.${VERSION_MINOR}
            RPM_TAG=".el${VERSION_MAJOR}"

            # set the sub-URL in https://repo.radeon.com/amdgpu-install/<sub-URL>
            case "${ROCM_VERSION}" in
                6.*)
                    ROCM_RPM=${ROCM_VERSION}/rhel/${RPM_PATH}/amdgpu-install-${ROCM_MAJOR}.${ROCM_MINOR}.${ROCM_VERSN}-1${RPM_TAG}.noarch.rpm
                    ;;
                0.0)
                    ;;
                *)
                    send-error "Unsupported combination :: ${DISTRO}-${VERSION} + ROCm ${ROCM_VERSION}"
                    ;;
            esac

            # use Rocky Linux as a base image for RHEL builds
            DISTRO_BASE_IMAGE=rockylinux/rockylinux

            verbose-build docker build . ${PULL} --progress plain -f ${DOCKER_FILE} --tag ${CONTAINER} --build-arg DISTRO=${DISTRO_BASE_IMAGE} --build-arg VERSION=${VERSION} --build-arg ROCM_VERSION=${ROCM_VERSION} --build-arg AMDGPU_RPM=${ROCM_RPM} --build-arg PYTHON_VERSIONS=\"${PYTHON_VERSIONS}\"
        elif [ "${DISTRO}" = "opensuse" ]; then
            case "${VERSION}" in
                15.*)
                    DISTRO_IMAGE="opensuse/leap"
                    echo "DISTRO_IMAGE: ${DISTRO_IMAGE}"
                    ;;
                *)
                    send-error "Invalid opensuse version ${VERSION}. Supported: 15.x"
                    ;;
            esac
            case "${ROCM_VERSION}" in
                6.*)
                    ROCM_RPM=${ROCM_VERSION}/sle/${VERSION}/amdgpu-install-${ROCM_MAJOR}.${ROCM_MINOR}.${ROCM_VERSN}-1.noarch.rpm
                    ;;
                0.0)
                    ;;
                *)
                    send-error "Unsupported combination :: ${DISTRO}-${VERSION} + ROCm ${ROCM_VERSION}"
                ;;
            esac
            if [[ "${VERSION_MAJOR}" -le 15 && "${VERSION_MINOR}" -le 5 ]]; then
                PERL_REPO="15.6"
            else
                PERL_REPO="${VERSION_MAJOR}.${VERSION_MINOR}"
            fi
            verbose-build docker build . ${PULL} --progress plain -f ${DOCKER_FILE} --tag ${CONTAINER} --build-arg DISTRO=${DISTRO_IMAGE} --build-arg VERSION=${VERSION} --build-arg ROCM_VERSION=${ROCM_VERSION} --build-arg AMDGPU_RPM=${ROCM_RPM} --build-arg PERL_REPO=${PERL_REPO} --build-arg PYTHON_VERSIONS=\"${PYTHON_VERSIONS}\"
        fi
        if [ "${PUSH}" -ne 0 ]; then
            docker push ${CONTAINER}
        fi
    done
done
