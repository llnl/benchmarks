#!/bin/bash
#flux: --exclusive
#flux: --setattr=thp=always
#flux: --setattr=hugepages=460GB
#flux: --coral2-hugepages
#flux: --conf=resource.rediscover=true
#flux: --time-limit=60
#flux: --output='miniemfcr30.{{id}}.out'
#flux: --error='miniemfcr30.{{id}}.err'
# flux alloc -N1 --exclusive --setattr=thp=always -setattr=hugepages=460GB --coral2-hugepages --conf=resource.rediscover=true --time-limit=120

# Runtime switches
export MINIEM_OUTER_TAG="${MINIEM_OUTER_TAG:-retry}"
export MINIEM_RETRY=${MINIEM_RETRY:-1}
export MINIEM_TAG="${MINIEM_TAG:-interactive}"
export MINIEM_ELEMENTS=${MINIEM_ELEMENTS:-128}
# export MINIEM_DT=${MINIEM_DT:-4.44e-13}

# Dynamic Flux environment
export SLURM_JOB_ID=${SLURM_JOB_ID:-424242}
export FLUX_JOB_ID=${FLUX_JOB_ID:-`flux getattr jobid`}
export MINIEM_NUM_NODES=${MINIEM_NUM_NODES:=`flux getattr size`}
export MINIEM_PRETTY_NUM_NODES=` printf '%04d\n' "${MINIEM_NUM_NODES}" `
export MINIEM_PRETTY_ELEMENTS=` printf '%03d\n' "${MINIEM_ELEMENTS}" `
export DIR_CASE="${MINIEM_OUTER_TAG}-N${MINIEM_PRETTY_NUM_NODES}-E${MINIEM_PRETTY_ELEMENTS}-F${FLUX_JOB_ID}"


for (( i=0; i<${MINIEM_RETRY}; i++ )); do
    miniem_pretty_try=` printf '%02d\n' "${i}" `
    secstamp="`date '+%Y%m%d-%H%M%S'`"
    m_tag="${DIR_CASE}-T${miniem_pretty_try}-D${secstamp}-R${RANDOM}"
    mkdir -p "${m_tag}"
    cp -a *.xml "${m_tag}"
    cp -a load-jje-env.sh "${m_tag}"
    cp -a interactive.sh "${m_tag}"
    pushd "${m_tag}"
    ln -s ../PanzerMiniEM_BlockPrec.exe
    MINIEM_TAG=${m_tag} \
        MINIEM_ELEMENTS=${MINIEM_ELEMENTS} \
        ./interactive.sh
    popd
done


exit 0
