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

with open( "../src/lut_rom_pkg.sv", "w+" ) as f:
  f.write( "package lut_rom_pkg;\n\n" )
  f.write( "parameter logic [%d : 0] INIT_DATA [%d : 0] = {\n" % (( bits - 1 ), ( 2 ** bits - 1 )) )
  for i in range( upper_value - 1, 0, -1 ):
    f.write( "  %d\'h%x,\n" % ( bits, gamma_value[i]) )
  f.write( "  %d\'h%x };\n\n" % (bits, gamma_value[0]) )
  f.write( "endpackage" )
