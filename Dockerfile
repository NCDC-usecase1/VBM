FROM vistalab/fsl-v5.0
RUN apt-get update --assume-yes
RUN apt-get --assume-yes install software-properties-common
RUN apt-get install --reinstall ca-certificates
RUN add-apt-repository ppa:deadsnakes/ppa

RUN apt-get update && apt-get install --assume-yes python3.6 
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3.6 get-pip.py
RUN rm /usr/bin/python3
RUN ln -s /usr/bin/python3.6 /usr/local/bin/python3


ADD ./FSfslVBM /home/FSfslVBM
ADD ./freesurfer-6.0.0 /home/freesurfer-6.0.0

RUN pip3 install -r /home/FSfslVBM/requirements.txt

## environement variables
ENV FSLDIR=/usr/share/fsl/5.0
ENV FREESURFER_HOME=/home/freesurfer-6.0.0
ENV VBM_DIR=/home/FSfslVBM
ENV TEMPLATE=$VBM_DIR/mni_icbm152_gm_kNN.nii
ENV CONFIG=$VBM_DIR/GM_2_MNI152GM_1mm.cnf
RUN cp $FREESURFER_HOME/bin/libgomp.so.1 /lib/x86_64-linux-gnu/

WORKDIR $VBM_DIR

#./fsl_vbm_pipeline.sh -i /input/aseg.mgz -o /output/ -f $FREESURFER_HOME  -v $VBM_DIR -n test_result -t $TEMPLATE -c $CONFIG