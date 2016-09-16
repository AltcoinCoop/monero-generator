#! /usr/bin/env bash


# Bash script for change coin files

# Exit immediately if an error occurs, or if an undeclared variable is used
set -o errexit


[ "$OSTYPE" != "win"* ] || die "Windows is not supported"


# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.


while getopts "c:z" opt; do
    case "$opt" in
    c)  COMPILE_ARGS=${OPTARG}
        ;;
    z)  archive=1
    esac
done
archive=${archive:-0}

shift $((OPTIND-1))

cd ${NEW_COIN_PATH}

# Compile!
if [[ "$OSTYPE" == "msys" ]]; then
	cmake -G "Visual Studio 12 Win64" "..\.."
	msbuild.exe Bytecoin.sln /property:Configuration=Release ${COMPILE_ARGS}
else
	make release-static
fi

if [[ $? == "0" ]]; then
	echo "Compilation successful"
fi

# Move and zip binaries
if [[ $archive == "1" ]]; then
	BUILD_PATH="${WORK_FOLDERS_PATH}/builds"
	MAC_BUILD_NAME="${__CONFIG_core_CRYPTONOTE_NAME}-mac"
	LINUX_BUILD_NAME="${__CONFIG_core_CRYPTONOTE_NAME}-linux"
	WINDOWS_BUILD_NAME="${__CONFIG_core_CRYPTONOTE_NAME}-windows"
	ALL_BUILD_FILES="${__CONFIG_core_CRYPTONOTE_NAME}-all-files"

	case "$OSTYPE" in
	  msys*) 	rm -f ${BUILD_PATH}/${WINDOWS_BUILD_NAME}.zip
		rm -rf ${BUILD_PATH}/${WINDOWS_BUILD_NAME}
		mkdir -p ${BUILD_PATH}/${WINDOWS_BUILD_NAME}
		cp ${NEW_COIN_PATH}/build/release/bin/monerod.exe ${BUILD_PATH}/${WINDOWS_BUILD_NAME}
		cp ${NEW_COIN_PATH}/build/release/bin/monero-wallet-cli.exe ${BUILD_PATH}/${WINDOWS_BUILD_NAME}
		if [[ " ${__CONFIG_extensions_text} " == *"multiply.json"* ]]; then
			rm -rf ${BUILD_PATH}/${WINDOWS_BUILD_NAME}/configs/.git
			rm -rf ${BUILD_PATH}/${WINDOWS_BUILD_NAME}/configs/.gitignore
		fi
		cd ${BUILD_PATH}
		zip -r ${WINDOWS_BUILD_NAME}.zip ${WINDOWS_BUILD_NAME}/
		;;
	  darwin*)  	rm -f ${BUILD_PATH}/${MAC_BUILD_NAME}.zip
		rm -rf ${BUILD_PATH}/${MAC_BUILD_NAME}
		mkdir -p ${BUILD_PATH}/${MAC_BUILD_NAME}
		cp ${NEW_COIN_PATH}/build/release/bin/monerod ${BUILD_PATH}/${MAC_BUILD_NAME}
		cp ${NEW_COIN_PATH}/build/release/bin/monero-wallet-cli ${BUILD_PATH}/${MAC_BUILD_NAME}
		if [[ " ${__CONFIG_extensions_text} " == *"multiply.json"* ]]; then
			rm -rf ${BUILD_PATH}/${MAC_BUILD_NAME}/configs/.git
			rm -rf ${BUILD_PATH}/${MAC_BUILD_NAME}/configs/.gitignore
		fi
		cd ${BUILD_PATH}
		zip -r ${MAC_BUILD_NAME}.zip ${MAC_BUILD_NAME}/
		;;
	  *)	rm -f ${BUILD_PATH}/${LINUX_BUILD_NAME}.tar.gz
		rm -rf ${BUILD_PATH}/${LINUX_BUILD_NAME}
		mkdir -p ${BUILD_PATH}/${LINUX_BUILD_NAME}
		cp ${NEW_COIN_PATH}/build/release/bin/monerod ${BUILD_PATH}/${LINUX_BUILD_NAME}
		cp ${NEW_COIN_PATH}/build/release/bin/monero-wallet-cli ${BUILD_PATH}/${LINUX_BUILD_NAME}
		if [[ " ${__CONFIG_extensions_text} " == *"multiply.json"* ]]; then
			rm -rf ${BUILD_PATH}/${LINUX_BUILD_NAME}/configs/.git
			rm -rf ${BUILD_PATH}/${LINUX_BUILD_NAME}/configs/.gitignore
		fi
		cd ${BUILD_PATH}
		tar -zcvf ${LINUX_BUILD_NAME}.tar.gz ${LINUX_BUILD_NAME}
		;;
	esac

	rm -rf ${BUILD_PATH}/${ALL_BUILD_FILES}
	mkdir -p ${BUILD_PATH}/${ALL_BUILD_FILES}
	cp -R ${NEW_COIN_PATH}/build/release/src/ ${BUILD_PATH}/${ALL_BUILD_FILES}/
	if [[ " ${__CONFIG_extensions_text} " == *"multiply.json"* ]]; then
		git clone https://github.com/forknote/configs.git ${BUILD_PATH}/${ALL_BUILD_FILES}/configs
		rm -rf ${BUILD_PATH}/${ALL_BUILD_FILES}/configs/.git
		rm -rf ${BUILD_PATH}/${ALL_BUILD_FILES}/configs/.gitignore
	fi

	rm -rf "${NEW_COIN_PATH}/build"
fi
