#require fsl software
import os
import subprocess
import shutil
from optparse import OptionParser
import time

def image_png(image, outputdir):

    outputfile = os.path.join(os.path.splitext(os.path.splitext(os.path.basename(image))[0])[0] + '.png')
    if os.path.exists(outputfile):
        return

    id = str( abs((image).__hash__() ) )
    temp_dir = os.path.join(outputdir,'temp_' + os.path.splitext(os.path.splitext(os.path.basename(image))[0])[0])
    if not os.path.exists(temp_dir):
        os.mkdir(temp_dir)

    slicer='slicer'
    png='pngappend'
    

    # generate inspection renderings
    #slicer $FA_epi $t1w_wm -i 0 0.8 -z 0.5 $tmp/l2.png -z 0.55 $tmp/l3.png -z 0.6 $tmp/l4.png -z 0.65 $tmp/l5.png -z 0.7 $tmp/l6.png	
    slicer1= '%s %s -z 0.4 %s -z 0.45 %s -z 0.5 %s -z 0.6 %s -z 0.65 %s -z 0.7 %s' % (slicer, image, os.path.join(temp_dir, 'l2.png'), os.path.join(temp_dir, 'l3.png'), os.path.join(temp_dir, 'l4.png'), os.path.join(temp_dir, 'l5.png'), os.path.join(temp_dir, 'l6.png') , os.path.join(temp_dir, 'l7.png'))
    os.popen(slicer1)
    # slicer $FA_epi $t1w_wm -i 0 0.8 -x 0.4 $tmp/n1.png -x 0.45 $tmp/n2.png -x 0.5 $tmp/n3.png -x 0.55 $tmp/n4.png -x 0.6 $tmp/n5.png 
    slicer2= '%s %s -x 0.4 %s -x 0.45 %s -x 0.5 %s -x 0.55 %s -x 0.6 %s' % (slicer, image, os.path.join(temp_dir, 'n1.png'), os.path.join(temp_dir, 'n2.png'), os.path.join(temp_dir, 'n3.png'), os.path.join(temp_dir, 'n4.png'), os.path.join(temp_dir, 'n5.png'))
    os.popen(slicer2)
    # slicer $FA_epi $t1w_wm -i 0 0.8 -y 0.4 $tmp/m1.png -y 0.45 $tmp/m2.png -y 0.5 $tmp/m3.png -x y.55 $tmp/m4.png -y 0.6 $tmp/m5.png  
    slicer3= '%s %s -y 0.3 %s -y 0.35 %s -y 0.4 %s -y 0.45 %s -y 0.5 %s  -y 0.55 %s  -y 0.6 %s' % (slicer, image, os.path.join(temp_dir, 'm1.png'), os.path.join(temp_dir, 'm2.png'), os.path.join(temp_dir, 'm3.png'), os.path.join(temp_dir, 'm4.png'), os.path.join(temp_dir, 'm5.png'), os.path.join(temp_dir, 'm6.png'), os.path.join(temp_dir, 'm7.png'))
    os.popen(slicer3)
    
    # stitches
    #pngappend $tmp/l2.png + $tmp/l3.png + $tmp/l4.png + $tmp/l5.png + $tmp/l6.png $tmp/ax1.png
    png1= '%s %s + %s + %s + %s + %s + %s %s' % (png, os.path.join(temp_dir, 'l2.png'), os.path.join(temp_dir, 'l3.png'), os.path.join(temp_dir, 'l4.png'), os.path.join(temp_dir, 'l5.png'), os.path.join(temp_dir, 'l6.png'), os.path.join(temp_dir, 'l7.png'), os.path.join(temp_dir,'ax1.png'))
    os.popen(png1)
    time.sleep(0.5)
    #pngappend $tmp/n1.png + $tmp/n2.png + $tmp/n3.png + $tmp/n4.png + $tmp/n5.png $tmp/ax2.png
    png2= '%s %s + %s + %s + %s + %s %s' % (png, os.path.join(temp_dir, 'n1.png'), os.path.join(temp_dir, 'n2.png'), os.path.join(temp_dir, 'n3.png'), os.path.join(temp_dir, 'n4.png'), os.path.join(temp_dir, 'n5.png'), os.path.join(temp_dir,'ax2.png'))
    os.popen(png2)
    time.sleep(0.5)
    #pngappend $tmp/m1.png + $tmp/m2.png + $tmp/m3.png + $tmp/m4.png + $tmp/m5.png $tmp/ax3.png
    png3= '%s %s + %s + %s + %s + %s + %s + %s %s' % (png, os.path.join(temp_dir, 'm1.png'), os.path.join(temp_dir, 'm2.png'), os.path.join(temp_dir, 'm3.png'), os.path.join(temp_dir, 'm4.png'), os.path.join(temp_dir, 'm5.png'), os.path.join(temp_dir, 'm6.png'), os.path.join(temp_dir, 'm7.png'), os.path.join(temp_dir,'ax3.png'))
    os.popen(png3)
    time.sleep(0.5)

    png4= '%s %s - %s - %s %s' % (png, os.path.join(temp_dir,'ax1.png'), os.path.join(temp_dir,'ax2.png'), os.path.join(temp_dir,'ax3.png'), outputdir+outputfile)
    os.popen(png4)
    
    print('Output image written: ' + outputdir+outputfile)  


image_path='/jyu/'
outputdir='jyu/QC/QC_slices/'
outliers=list(pd.read_csv('/jyu/QC/QC/outlier_mri_id.csv')['MRI'])

for i in range(len(outliers)):
    image_png(image_path+outliers[i],outputdir) 