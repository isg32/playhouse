path=/home/sapan/cuaosp

# D_T_Y
CUSTOM_DATE_YEAR="$(date -u +%Y)"
CUSTOM_DATE_MONTH="$(date -u +%m)"
CUSTOM_DATE_DAY="$(date -u +%d)"
CUSTOM_DATE_HOUR="$(date -u +%H)"
CUSTOM_DATE_MINUTE="$(date -u +%M)"
CUSTOM_BUILD_DATE="$CUSTOM_DATE_YEAR""$CUSTOM_DATE_MONTH""$CUSTOM_DATE_DAY"-"$CUSTOM_DATE_HOUR""$CUSTOM_DATE_MINUTE"

fkinfetchtools()
{
    sudo apt-get update 
    echo -ne '\n' | sudo apt-get upgrade
    echo -ne '\n' | sudo apt-get install git ccache schedtool lzop bison gperf build-essential zip curl zlib1g-dev g++-multilib python-networkx libxml2-utils bzip2 libbz2-dev libghc-bzlib-dev squashfs-tools pngcrush liblz4-tool optipng libc6-dev-i386 gcc-multilib libssl-dev gnupg flex lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev libgl1-mesa-dev xsltproc unzip python-pip python-dev libffi-dev libxml2-dev libxslt1-dev libjpeg8-dev openjdk-8-jdk imagemagick device-tree-compiler mailutils-mh expect python3-requests python-requests android-tools-fsutils sshpass
    sudo swapon --show
    sudo swapon /dev/sda
    sudo mount --bind /home/sapan/.cache /mnt/ccache2 && export USE_CCACHE=1 && export CCACHE_EXEC=/usr/bin/ccache && export CCACHE_DIR=/mnt/ccache2 && sudo ccache -M 50G -F 0
    sudo swapon --show
    git config --global user.email "sapangajjar101105@gmail.com"
    git config --global user.name "isg32"
} &> /dev/null

fkinfetchrepobin()
{
    cd $path
    mkdir bin
    PATH=$path/bin:$PATH
    curl https://storage.googleapis.com/git-repo-downloads/repo > $path/bin/repo
    chmod a+x $path/bin/repo
}

repoinandsink()
{
    cd $path
    mkdir cuaosp
    cd cuaosp
    echo -ne '\n' | repo init -u https://github.com/isg32/android_manifest_custom/.git --git-lfs --depth=1
    repo sync -c -j$(nproc --all) --force-sync --no-clone-bundle --no-tags
    git clone https://github.com/anoosragh69/vendor_priv-keys vendor/priv-keys

}

gettreesniga()
{
    cd $path/cuaosp
    git clone https://github.com/anoosragh69/android_device_motorola_hanoip device/motorola/hanoip
    git clone https://github.com/anoosragh69/android_device_motorola_hanoip-kernel device/motorola/hanoip-kernel
    git clone https://github.com/anoosragh69/android_kernel_motorola_hanoip kernel/motorola/hanoip
    git clone https://github.com/anoosragh69/android_vendor_motorola_hanoip vendor/motorola/hanoip
}

buildanduploadbaby()
{
    cd $path/cuaosp

    . build/envsetup.sh && lunch aosp_hanoip-userdebug && make -j$(nproc --all) target-files-package otatools
    echo "\n  Sigining Build...\n"

    sign_target_files_apks -o -d $path/vendor/priv-keys $path/cuaosp/out/target/product/hanoip/obj/PACKAGING/target_files_intermediates/*-target_files-*.zip $path/cuaosp/out/target/product/hanoip/signed-target-files.zip
    echo "\n  Signing Done...\n"

    ota_from_target_files -k $path/vendor/priv-keys/releasekey $path/cuaosp/out/target/product/hanoip/signed-target-files.zip $path/cuaosp/out/target/product/hanoip/CUAOSP_hanoip-14.0-$CUSTOM_BUILD_DATE.zip
    cp -r out/target/product/*/CUAOSP**.zip $path/
}



echo -n “Do You Want to Download Android Tools? “
read dtools
if [ $(dtools) == y ]; then
echo "===================================================="
echo "Downloading tools.."
echo "====================================================" 
fkinfetchtools
fi

echo -n “Do You Want to Download repo bin? “
read repobin
if [ $(repobin) == y ]; then
echo "===================================================="
echo "Downloading repo bin.."
echo "===================================================="
fkinfetchrepobin
fi

echo "===================================================="
echo "Downloading CUAOSP Source Code.."
echo "===================================================="
repoinandsink

echo "===================================================="
echo "Downloading Device source.."
echo "===================================================="
gettreesniga

echo "===================================================="
echo "Started building CUAOSP"
echo "===================================================="
buildanduploadbaby

echo "===================================================="
echo "Successfully build completed.."
echo "===================================================="

echo "\n Uploading Build... \n"
echo "====================================================\n"
ksau upload out/target/product/*/CUAOSP**.zip
