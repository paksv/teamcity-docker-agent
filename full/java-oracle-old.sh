#!/bin/bash

# Installs Oracle JDK: 1.4, 1.5, 1.6, 1.7

apt-get -y install libc6-i386

function installJDK {
    local VERSION=$1
    local ARCH=$2
    local FILE=jdk-$VERSION-linux_$ARCH.tar.gz
    local DIR=/usr/lib/jvm/jdk-$VERSION-$ARCH
    local URL="${3:-https://repo.labs.intellij.net/download/oracle/$FILE}"
    downloadFile $URL $FILE
    mkdir -p "$DIR"
    tar -xzf "/tmp/$FILE" --strip-components=1 -C "$DIR"
    rm "/tmp/$FILE"
}

function downloadFile {
    local URL=$1
    local FILE=$2
    echo "Downloading ${URL} into $FILE"
    curl "$URL" --output "/tmp/$FILE"
}

installJDK 7.79 x64
installJDK 7.79 i586

# Obsolete unsupported versions
#installJDK '9.0.4' x64
#installJDK '10.0.2' x64


######################################################
cd /tmp

distrs=(
    jdk-6.45-linux_i586.bin     \
    jdk-6.45-linux_x64.bin      \
    jdk-5.0.22-linux_x64.bin    \
    jdk-5.0.22-linux_i586.bin   \
    jdk-1.4.2.19-linux_i586.bin \
)
for FILE in ${distrs[*]}
do
  downloadFile https://repo.labs.intellij.net/download/oracle/$FILE $FILE
done

sed -i 's/\.\/$outname$/\.\/$outname -q/' jdk-6.45-linux_i586.bin
chmod +x jdk-6.45-linux_i586.bin
./jdk-6.45-linux_i586.bin
mkdir -p /usr/lib/jvm/jdk-6u45
mv jdk1.6.0_45/* /usr/lib/jvm/jdk-6u45
rmdir jdk1.6.0_45
rm jdk-6.45-linux_i586.bin

sed -i 's/\.\/$outname$/\.\/$outname -q/' jdk-6.45-linux_x64.bin
chmod +x jdk-6.45-linux_x64.bin
./jdk-6.45-linux_x64.bin
mkdir -p /usr/lib/jvm/jdk-6u45-x64
mv jdk1.6.0_45/* /usr/lib/jvm/jdk-6u45-x64
rmdir jdk1.6.0_45
rm jdk-6.45-linux_x64.bin

sed -i 's/^more <<"EOF"$/cat <<"EOF" >\/dev\/null/' jdk-5.0.22-linux_i586.bin
sed -i 's/agreed=$/agreed=1/' jdk-5.0.22-linux_i586.bin
sed -i 's/\.\/$outname$/\.\/$outname -q/' jdk-5.0.22-linux_i586.bin
chmod +x jdk-5.0.22-linux_i586.bin
./jdk-5.0.22-linux_i586.bin
mkdir -p /usr/lib/jvm/jdk-5u22
mv jdk1.5.0_22/* /usr/lib/jvm/jdk-5u22
rmdir jdk1.5.0_22
rm jdk-5.0.22-linux_i586.bin

sed -i 's/^more <<"EOF"$/cat <<"EOF" >\/dev\/null/' jdk-5.0.22-linux_x64.bin
sed -i 's/agreed=$/agreed=1/' jdk-5.0.22-linux_x64.bin
sed -i 's/\.\/$outname$/\.\/$outname -q/' jdk-5.0.22-linux_x64.bin
chmod +x jdk-5.0.22-linux_x64.bin
./jdk-5.0.22-linux_x64.bin
mkdir -p /usr/lib/jvm/jdk-5u22-x64
mv jdk1.5.0_22/* /usr/lib/jvm/jdk-5u22-x64
rmdir jdk1.5.0_22
rm jdk-5.0.22-linux_x64.bin

sed -i 's/^more <<"EOF"$/cat <<"EOF" >\/dev\/null/' jdk-1.4.2.19-linux_i586.bin
sed -i 's/agreed=$/agreed=1/' jdk-1.4.2.19-linux_i586.bin
sed -i 's/\.\/$outname$/\.\/$outname -q/' jdk-1.4.2.19-linux_i586.bin
chmod +x jdk-1.4.2.19-linux_i586.bin
./jdk-1.4.2.19-linux_i586.bin
mkdir -p /usr/lib/jvm/jdk-1.4.2.19
mv j2sdk1.4.2_19/* /usr/lib/jvm/jdk-1.4.2.19
mv j2sdk1.4.2_19/.systemPrefs /usr/lib/jvm/jdk-1.4.2.19
rmdir j2sdk1.4.2_19
rm jdk-1.4.2.19-linux_i586.bin

######################################################################
VERSION=2.2.0
FILE=tzupdater-$VERSION.jar
downloadFile https://repo.labs.intellij.net/oracle_jdk/oracle/tzupdater/$VERSION/$FILE $FILE
# tzdata has 1.5 bytecode, so 1.4 can't use it
# 1.5 32bit crashes for unknown reason
ls /usr/lib/jvm/jdk-*/bin/java | grep -v '/jdk-1.4' | grep -v '/jdk-5u22/' | xargs -n1 -I% sh -c "% -jar ./$FILE -u || true"
rm $FILE

cat >/tmp/jb.cer <<EOF
-----BEGIN CERTIFICATE-----
MIIFvjCCA6agAwIBAgIQMYHnK1dpIZVCoitWqBwhXjANBgkqhkiG9w0BAQsFADBn
MRMwEQYKCZImiZPyLGQBGRYDTmV0MRgwFgYKCZImiZPyLGQBGRYISW50ZWxsaUox
FDASBgoJkiaJk/IsZAEZFgRMYWJzMSAwHgYDVQQDExdKZXRCcmFpbnMgRW50ZXJw
cmlzZSBDQTAeFw0xMjEyMjkxMDEyMzJaFw0zMjEyMjkxMDIyMzBaMGcxEzARBgoJ
kiaJk/IsZAEZFgNOZXQxGDAWBgoJkiaJk/IsZAEZFghJbnRlbGxpSjEUMBIGCgmS
JomT8ixkARkWBExhYnMxIDAeBgNVBAMTF0pldEJyYWlucyBFbnRlcnByaXNlIENB
MIICIjANBgkqhkiG9w0BAQEFAAOCAg8AMIICCgKCAgEAzPCE2gPgKECo5CB3BTAw
4XrrNpg+YwTMzeNNDYs4VdPzBq0snWsbm5qP6z1GBGUTr4agERQUxc4//gZMR0UJ
89GWVNYPbZ/MrkfyaOiem8xosuZ+7WoFu4nYnKbBBMBA7S2idrPSmPv2wYiHJCY7
eN2AdViiFSAUeGw/7pIgou92/4Bbm6SSzRBKBYfRIfwq0ZgETSIjhNR5o3XJB5i2
CkSjMk7kNiMWBaq+Alv+Um/xMFnl5jiq9H7YAALgH/mZHr8ANniSyBwkj4r/7GQ3
UIYwoLrGxSOSEY9UhEpdqQkRbSSjQiFYMlhYEAtLERK4KZObTuUgdiE6Wk38EOKZ
wy1eE/EIh8vWBHFSH5opPSK4dyamxj9o5c2g1hJ07ZBUCV/nsrKb+ruMkwBfI286
+HPTMUmoKuUfSfHZ5TiuF5EvcSD7Df2ZCFpRugPs26FRGvtsiBMEmu4u6fu5RNkh
s7Ueq6ISblt6dj/youywiAZnyrtNKJVyK0m051g9b2IokHjrk9XTswTqBHDjZKYr
YG/5jDSSzvR/ptR9YIrHF0a9A6LQLZ6ews4FUO6O/RhiYXV8FggD7ZUg019OBUx3
rF1L3GBYA8YhYP/N18r8DqOaFgUiRDyeRMbka9OXZ2KJT6iL+mOfg/svSW8lc4Ly
EgcyJ9sk7MRwrhlp3Kc0W7UCAwEAAaNmMGQwEwYJKwYBBAGCNxQCBAYeBABDAEEw
CwYDVR0PBAQDAgGGMA8GA1UdEwEB/wQFMAMBAf8wHQYDVR0OBBYEFB/HK/yYoWW9
vr2XAyhcMmV3gSfGMBAGCSsGAQQBgjcVAQQDAgEAMA0GCSqGSIb3DQEBCwUAA4IC
AQBnYu49dZRBK9W3voy6bgzz64sZfX51/RIA6aaoHAH3U1bC8EepChqWeRgijGCD
CBvLTk7bk/7fgXPPvL+8RwYaxEewCi7t1RQKqPmNvUnEnw28OLvYLBEO7a4yeN5Y
YaZwdfVH+0qMvTqMQku5p5Xx3dY+DAm4EqXEFD0svfeMJmOA+R1CIqRz1CXnN2FY
A+86m7WLmGZ8oWlRUJDa1etqrE3ZxXHH/IunVJOGOfaQVkid3u3ageyUOnMw/iME
7vi0UNVYVsCjXYZxrzCDLCxtguZaV4rMYvLRt1oUxZ+VnmdVa3aW0W//GQ70sqh2
KQDtIF6Iumf8ya4vA0+K+AAowOSR/k4jQzlWQdZvJNMHP/Jc0OyJyHEegjtWssrS
NoRtI6V4j277ugWF1Xpt1x0YxYyGSZTI4rqGLqVT8x6Llr24YaHCdp56rKWC/5ob
IFZ7tJys7oQqof11ANDExrnHv/FEE39VDlfEIUVGyCpsyKbzO7MPfdOce2bIaQOS
dQ76TpYClrnezikJgp9MSQmd3+ozs9w1upGynHNGNmVhzZ5sex9voWcGoyjmOFhs
wg13S9Hjy3VYq8y0krRYLEGLctd4vnxWGzJzUNSnqezwHZRl4v4Ejp3dQUZP+5sY
1F81Vj1G264YnZAcWp5x3GTI4K6+k9Xx3pwUPcKOYdlpZQ==
-----END CERTIFICATE-----
EOF
for jh in $(find /usr/lib/jvm/ -maxdepth 1 -type d | grep -v '/jdk-1.4'); do
  [ ! -f "$jh/bin/keytool" ] && continue
  certs_file="$(find "$jh" -name 'cacerts')"
  echo "java home: $jh, certs file: $certs_file"
  "$jh/bin/keytool" -import -alias jetbrains -file /tmp/jb.cer -keystore "$certs_file" -storepass changeit -noprompt || true
done