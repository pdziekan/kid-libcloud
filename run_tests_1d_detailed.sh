#!/bin/bash
cd kid_a_setup 


export LD_LIBRARY_PATH=..:bin:$LD_LIBRARY_PATH 
export LD_PRELOAD=ptrutil.so 
export PYTHONPATH=/mnt/local/pdziekan/lib64/python2.7/site-packages/

iter=-1

for sd_conc in 10000
do
  for sstp_cond in 10 100 
  do
    for sstp_coal in 10 100
    do
      for ntot in 50e6 150e6 300e6
      do
        for spinup in 0 1e8
        do
          RAIN="NORAIN"
          if [ ${spinup} == "0" ] ; then
            RAIN="RAIN"
          fi
          for wctrl in 2 3
          do
            if [ ${wctrl} == "2" ] ; then
              sed -i 's/wctrl(1)=3/wctrl(1)=2/g' namelists/kida_icmw1D_libcloud_lgr.nml
            fi
            if [ ${wctrl} == "3" ] ; then
              sed -i 's/wctrl(1)=2/wctrl(1)=3/g' namelists/kida_icmw1D_libcloud_lgr.nml
            fi
            OUTDIR=/mnt/local/pdziekan/wyniki/kid-a/1D/output_SdConc${sd_conc}_SstpCond${sstp_cond}_SstpCoal${sstp_coal}_wctrl${wctrl}_ntot${ntot}_${RAIN} && mkdir ${OUTDIR}

            # parallel runs on 3 GPUs
            #iter=$(($iter+1))
            #CUDA_DEVICE=$(($iter%3))
            #CUDA_VISIBLE_DEVICES=${CUDA_DEVICE} FILEOUT=${OUTDIR} python ../kid_1D.py --sstp_coal=$sstp_coal --sstp_cond=$sstp_cond --backend="CUDA" --sd_conc=$sd_conc --n_tot=$ntot --spinup_rain=$spinup & 
            #sleep 2

            # sequential runs of an ensemble on 1 GPU
            for iter in {1..10}
            do
              mkdir ${OUTDIR}/${iter} 
              FILEOUT=${OUTDIR}/${iter} python ../kid_1D.py --sstp_coal=$sstp_coal --sstp_cond=$sstp_cond --backend="CUDA" --sd_conc=$sd_conc --n_tot=$ntot --spinup_rain=$spinup 
            done

          done
        done
      done
    done
  done
done

echo "done"
