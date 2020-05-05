#!/usr/bin/python3

import numpy as np
import sys

bits  = int( sys.argv[2] )

gamma       = float( sys.argv[1] )
upper_value = 2 ** bits
gamma_value = []

for i in range( upper_value ):
  rel_value       = float( i ) / float( upper_value - 1 )
  gamma_rel_value = rel_value ** gamma
  gamma_value.append( int( gamma_rel_value * ( upper_value - 1 ) ) )

with open( "./gamma_rom.hex", "w+" ) as f:
  for i in range( upper_value ):
    f.write( hex( gamma_value[i] )[2 :] + "\n" )
