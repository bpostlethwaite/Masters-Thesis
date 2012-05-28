delta=60
for idepth in 20 40 60 80 120 140  160 180 200 220 240 260 280 300 320 330 \
340 360 380 400 420 440 460 480 500 520 540 560 580 600 
do
  tsS=`get_tt -z $idepth -d $delta -p ScS | head -1 | awk '{print $3}'`
  tS=`get_tt -z $idepth -d $delta -p S | head -1 | awk '{print $3}'`
  echo $idepth $tsS $tS | awk '{print $1,$2-$3}' 
done
