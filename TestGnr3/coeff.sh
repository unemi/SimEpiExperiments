#! /bin/csh
awk '{x+=$1;x2+=$1*$1;p+=$2;t+=$3;xp+=$1*$2;xt+=$1*$3;n++}\
END{d=n*x2-x*x;printf "%.4f %.4f\n", (n*xp-x*p)/d, (n*xt-x*t)/d}' peak
