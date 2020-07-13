#! /bin/bash
timeStamp="$(date --utc '+%F_%T')"
results_dir=/root/benchmark/$(basename $0).${timeStamp}
lizard_dir=/mnt/lizardfs/

mkdir -p ${results_dir}
echo "Results in: ${results_dir}"
echo DirectIO=true > ${lizard_dir}/.lizardfs_tweaks
cat ${lizard_dir}/.lizardfs_tweaks > ${results_dir}/lizardfs_tweaks
ps aux |  grep lizard | grep mfsmount > ${results_dir_dir}/mount_process

for size in 1G 2G; do
  for threads in 1 8 16 32 64; do
    for goal in xor2 1 2 3 ec_2data_1parity ; do
      name=${HOSTNAME}.4k.${size}.${threads}.${goal}
      cat ${lizard_dir}/.stats > ${results_dir}/${name}.stats.before
      echo "starting ${name}..."
      fio --filename=${lizard_dir}/${goal}/${name}.fio --direct=1 --rw=randrw --refill_buffers --norandommap --randrepeat=0 --ioengine=libaio --bs=4k --rwmixread=100 --iodepth=16 --numjobs=${threads} --runtime=3600 --size=${size} --name=${name} --output=${results_dir}/${name}.json --output-format=json
    done
    cat ${lizard_dir}/.stats > ${results_dir}/${name}.stats.after
    echo "sleeping between next test."
    sleep 6 # waiting 1 minute between tests
    cat ${lizard_dir}/.stats > ${results_dir}/${name}.stats.after.sleeping
  done
done
