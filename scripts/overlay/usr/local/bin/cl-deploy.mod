function duplicate_uuid() {
for i in $(seq 1 4);do
	local PUUID=$(sgdisk --info=${i} ${SRC} | awk '(/Partition unique GUID/)&&($0=$NF)');
	sgdisk --partition-guid=${i}:"${PUUID}" ${DST};
done
}

function post_deploy() {
	duplicate_uuid
}

[[ -n ${DST} ]] || return
[[ -n ${SRC} ]] || return

[[ -b ${DST} ]] || return
[[ -b ${SRC} ]] || return

post_deploy
