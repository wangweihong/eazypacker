#!/usr/bin/env bash


set -o errexit
set -o nounset
set -o pipefail

[[ -n ${DEBUG:-} ]] && set -o xtrace

# **DO NOT** change the Packer version unless it is available under MPL v2.0.
_version="1.9.4"

# Change directories to the parent directory of the one in which this
# script is located.
cd "$(dirname "${BASH_SOURCE[0]}")/.."

source hack/lib/util.sh

# Some Linux distributions such as Fedora, RHEL, CentOS have a tool
# called packer installed by default at /usr/sbin, which will pass the
# command check, but is not the Packer we need for image builds. So we
# need to check if the Packer executable present on the machine is not
# that one. The default packer tool provided by cracklib does not have a
# version command and hangs indefinitely when the version command is
# invoked, so we are timeboxing it to 10 seconds. This shouldn't be the
# case with Packer installed from Hashicorp releases, which should give
# us a version number. This helps us distinguish the two Packer executables.
if (command -v packer && timeout 10 packer version) >/dev/null 2>&1; then exit 0; fi

mkdir -p .local/bin && cd .local/bin

SED="sed"
if command -v gsed >/dev/null; then
  SED="gsed"
fi
if ! (${SED} --version 2>&1 | grep -q GNU); then
  echo "!!! GNU sed is required.  If on macOS, use 'brew install gnu-sed'." >&2
  exit 1
fi

_chkfile="packer_${_version}_SHA256SUMS"
_chk_url="https://releases.hashicorp.com/packer/${_version}/${_chkfile}"
_zipfile="packer_${_version}_${HOSTOS}_${HOSTARCH}.zip"
_zip_url="https://releases.hashicorp.com/packer/${_version}/${_zipfile}"
curl -SsLO "${_chk_url}"
curl -SsLO "${_zip_url}"
${SED} -i -n "/${HOSTOS}_${HOSTARCH}/p" "${_chkfile}"
checksum_sha256 "${_chkfile}"
unzip -o "${_zipfile}"
rm -f "${_chkfile}" "${_zipfile}"
echo "'packer' has been installed to $(pwd), make sure this directory is in your \$PATH"
