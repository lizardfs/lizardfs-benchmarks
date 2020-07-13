#! /bin/bash
timeStamp="$(date --utc '+%F_%T')"
results_dir=/root/benchmark/$(basename $0).${timeStamp}
lizard_dir=/mnt/lizardfs/

mkdir -p ${results_dir}
echo "Results in: ${results_dir}"
echo DirectIO=true > ${lizard_dir}/.lizardfs_tweaks
cat ${lizard_dir}/.lizardfs_tweaks > ${results_dir}/lizardfs_tweaks
ps aux |  grep lizard | grep mfsmount > ${results_dir_dir}/mount_process

for size in 1G 3G 6G; do
  for file in /mnt/nvme0n1/random-data.dd /dev/zero ; do
  filename=$(basename ${file})
    for threads in 1 3 6 ; do
      for goal in xor2 1 2 3 ec_2data_1parity ; do
        name=${HOSTNAME}.${size}.${filename}.${threads}.${goal}
        cat ${lizard_dir}/.stats > ${results_dir}/${name}.stats.before
        echo -n "starting ${name}..."
        for ((thread = 0; thread < threads; ++thread)); do
          pv --size ${size} --stop-at-size --force -N ${name}.${thread} ${file} 2>&1 > ${lizard_dir}/${goal}/${name}.${thread} | sed 's/\r/\n/g'> ${results_dir}/pv.${name}.${thread}.log &
        done
        echo -n "waiting..."
        cat ${lizard_dir}/.stats > ${results_dir}/${name}.stats.during
        wait
        cat ${lizard_dir}/.stats > ${results_dir}/${name}.stats.after
        echo "sleeping between next test."
        sleep 6 # waiting 1 minute between tests
        cat ${lizard_dir}/.stats > ${results_dir}/${name}.stats.after.sleeping
      done
    done
  done
done
